#!/usr/bin/env python
# -*- coding: utf-8 -*-

import argparse
import BaseHTTPServer
import base64
import cgi
import json
import os
import re
import time
import socket
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


class StartTaskRequest(JiraRequest):
    def __init__(self, task_id, transition_id, username, password):
        url = "/rest/api/2/issue/{}/transitions".format(task_id)
        params = {"transition": {"id": transition_id}}
        super(StartTaskRequest, self).__init__(url, (username, password), params)
        self.transition_id = transition_id


def make_jira_request(request):
    print "{0: <4}".format(request.method), "->", request.url
    response = urllib2.urlopen(request.request)
    request.handle_response(response)
    return request.response


def start_task(task_key, user, password):
    if not re.compile("^[A-Z]{2,3}-\d+$").match(task_key):
        return

    task = make_jira_request(TaskDetailsRequest(task_key, user, password))

    if task is None:
        return
    if task["fields"]["assignee"]["key"] != user:
        return
    if task["fields"]["status"]["name"].lower() != "open":
        return

    transitions = make_jira_request(
        TaskTransitionsRequest(task_key, user, password)
    )
    if transitions is None:
        return

    for transition in transitions["transitions"]:
        if transition["name"].lower() == "start progress":
            return make_jira_request(
                StartTaskRequest(task_key, transition["id"], user, password)
            )


class JiraWebhookHandler(BaseHTTPServer.BaseHTTPRequestHandler):
    def set_headers(self):
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.end_headers()

    def do_HEAD(self):
        self.set_headers()

    def do_GET(self):
        self.set_headers()
        self.wfile.write(json.dumps({"response": "OK"}))

    def do_POST(self):
        print self.path
        if self.path == "/jira":
            form = cgi.FieldStorage(
                self.rfile, self.headers, environ={"REQUEST_METHOD": "POST"}
            )
            print json.loads(form.file.read())
            self.set_headers()


def run_webhook(host, port, handler=JiraWebhookHandler):
    server = BaseHTTPServer.HTTPServer((host, port), handler)
    print time.asctime(), "- Webhook server {}:{} started.".format(host, port)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    server.server_close()
    print time.asctime(), "- Webhook server {}:{} stopped.".format(host, port)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "-l", "--listen", help="start webhook server", action="store_true"
    )
    parser.add_argument(
        "-p", "--port", help="webook server port", type=int, default=8888
    )
    parser.add_argument("-u", "--user", help="JIRA username", type=str)
    parser.add_argument("-w", "--password", help="JIRA password", type=str)
    parser.add_argument(
        "-b", "--branch", help="branch name", type=str, default="master"
    )
    args = parser.parse_args()

    if not (args.user and args.password):
        return

    if args.listen:
        run_webhook("127.0.0.1", args.port, JiraWebhookHandler)
    else:
        start_task(args.branch, args.user, args.password)


if __name__ == "__main__":
    main()
