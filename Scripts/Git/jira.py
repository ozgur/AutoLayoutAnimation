#!/usr/bin/env python
# -*- coding: utf-8 -*-

import argparse
import BaseHTTPServer
import base64
import cgi
import json
import os
import re
import signal
import time
import shlex
import socket
import subprocess
import sys
import urllib2


class JiraRequest(object):
    HOST = "https://hdlabs.atlassian.net"

    def __init__(self, url, auth=None, params=None, headers=None):
        self.url = self.HOST + url
        self.auth = auth
        self.params = params
        self.response = None
        self.status_code = None
        self.headers = headers or {}
        self.headers.update({"Content-Type": "application/json"})
        self.method = "POST" if params else "GET"

    @property
    def request(self):
        if self.params:
            request = urllib2.Request(self.url, json.dumps(self.params))
        else:
            request = urllib2.Request(self.url)


        for key, value in self.headers.items():
            request.add_header(key, value)

        if self.auth:
            username, password = self.auth
            auth = base64.encodestring("%s:%s" % (username, password))
            auth = auth.replace("\n", "")  # need to trim trailing new line.
            request.add_header("Authorization", "Basic %s" % auth)

        return request

    def handle_response(self, response):
        self.status_code = response.getcode()
        self.response = response.read()
        response.close()


class TaskDetailsRequest(JiraRequest):
    def __init__(self, task_id, username, password):
        url = "/rest/api/2/issue/{}".format(task_id)
        super(TaskDetailsRequest, self).__init__(url, (username, password))

    def handle_response(self, response):
        super(TaskDetailsRequest, self).handle_response(response)
        if self.status_code == 200:
            self.response = json.loads(self.response)


class TaskTransitionsRequest(JiraRequest):
    def __init__(self, task_id, username, password):
        url = "/rest/api/2/issue/{}/transitions".format(task_id)
        super(TaskTransitionsRequest, self).__init__(url, (username, password))

    def handle_response(self, response):
        super(TaskTransitionsRequest, self).handle_response(response)
        if self.status_code == 200:
            self.response = json.loads(self.response)


class UpdateTaskRequest(JiraRequest):
    def __init__(self, task_id, transition_id, username, password, comment=None):
        url = "/rest/api/2/issue/{}/transitions".format(task_id)
        params = {"transition": {"id": transition_id}}
        if comment:
            params["update"] = {"comment": [{"add": {"body": comment}}]}
        super(UpdateTaskRequest, self).__init__(url, (username, password), params)
        self.transition_id = transition_id


def make_jira_request(request):
    print "{0: <4}".format(request.method), "->", request.url
    response = urllib2.urlopen(request.request)
    request.handle_response(response)
    return request.response


def start_task(task_key, user, password):
    if not re.compile("^[A-Z]{2,3}-\d+$").match(task_key):
        return False

    task = make_jira_request(TaskDetailsRequest(task_key, user, password))

    if task is None:
        return False

    if task["fields"]["assignee"]["key"] != user:
        return False

    if task["fields"]["status"]["name"].lower() != "open":
        return False

    transitions = make_jira_request(
        TaskTransitionsRequest(task_key, user, password)
    )
    if transitions is None:
        return False

    for transition in transitions["transitions"]:
        if transition["name"].lower() == "start progress":
            make_jira_request(
                UpdateTaskRequest(task_key, transition["id"], user, password)
            )
            return True

    return False


def resolve_task(task_key, user, password, comment=None):
    if not re.compile("^[A-Z]{2,3}-\d+$").match(task_key):
        return False

    task = make_jira_request(TaskDetailsRequest(task_key, user, password))
    if task is None:
        return False
    if task["fields"]["assignee"]["key"] != user:
        return False
    if task["fields"]["status"]["name"].lower() != "in progress":
        return False

    transitions = make_jira_request(
        TaskTransitionsRequest(task_key, user, password)
    )
    if transitions is None:
        return False

    for transition in transitions["transitions"]:
        if transition["name"].lower() == "resolve issue":
            make_jira_request(
                UpdateTaskRequest(
                    task_key, transition["id"], user, password, comment)
            )
            return True

    return False


class JiraWebhookHandler(BaseHTTPServer.BaseHTTPRequestHandler):
    BASE_BRANCH = "master"

    def set_headers(self):
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.end_headers()

    def do_HEAD(self):
        self.set_headers()

    def do_GET(self):
        self.set_headers()

    def do_POST(self):
        self.set_headers()
        if self.path == "/jira":
            form = cgi.FieldStorage(
                self.rfile, self.headers, environ={"REQUEST_METHOD": "POST"}
            )
            data = json.loads(form.file.read())
            if data["action"].lower() != "closed":
                return

            pull_request = data["pull_request"]
            if pull_request["base"]["ref"] != self.BASE_BRANCH:
                return
            if pull_request["merged"] is not True:
                return
            branch = pull_request["head"]["ref"]
            comment = "Merged {}".format(pull_request["html_url"])
            resolve_task(branch, self.server.user, self.server.password, comment)


class JiraWebhookServer(BaseHTTPServer.HTTPServer):
    def __init__(self, user, password, *args, **kwargs):
        BaseHTTPServer.HTTPServer.__init__(self, *args, **kwargs)
        self.user = user
        self.password = password


def run_server_forever(user, password, host, port,
                       handler_class=JiraWebhookHandler, force_kill=False):

    server = JiraWebhookServer(user, password, (host, port), handler_class)
    print time.asctime(), "- Webhook server {}:{} started.".format(host, port)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    server.server_close()
    print time.asctime(), "- Webhook server {}:{} stopped.".format(host, port)

def kill_server(port):
    lsof = subprocess.Popen(
        shlex.split("lsof -n -i4TCP:{}".format(port)), stdout=subprocess.PIPE
    )
    grep = subprocess.Popen(
        shlex.split("grep LISTEN"), stdin=lsof.stdout, stdout=subprocess.PIPE
    )
    awk = subprocess.Popen(
        shlex.split("awk '{ print $2; }'"), stdin=grep.stdout, stdout=subprocess.PIPE
    )
    out, error = awk.communicate()
    lsof.kill()

    if error:
        return False
    elif not out:
        return True
    else:
        os.kill(int(out), signal.SIGTERM)
        return True


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "-l", "--listen", help="start webhook server", action="store_true"
    )
    parser.add_argument(
        "-p", "--port", help="webook server port", type=int, default=8888
    )
    parser.add_argument(
        "-f", "--force", help="force kill server", action="store_true"
    )
    parser.add_argument("-u", "--user", help="JIRA username", type=str)
    parser.add_argument("-w", "--password", help="JIRA password", type=str)
    parser.add_argument(
        "-b", "--branch", help="branch name", type=str, default="master"
    )
    args = parser.parse_args()

    if not (args.user and args.password):
        return False

    if args.force:
        kill_server(args.port)

    if args.listen:
        run_server_forever(
            args.user, args.password, "127.0.0.1", args.port, force_kill=args.force
        )
        return True
    else:
        return start_task(args.branch, args.user, args.password)


if __name__ == "__main__":
    main()
