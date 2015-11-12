#!/usr/bin/env python
# -*- coding: utf-8 -*-

import base64
import json
import os
import re
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


def main():
    if len(sys.argv) < 4:
        return

    branch, user, password = sys.argv[1:]

    if not re.compile("^[A-Z]{2,3}-\d+$").match(branch):
        return

    task = make_jira_request(TaskDetailsRequest(branch, user, password))

    if task is None:
        return

    if task["fields"]["assignee"]["key"] != user:
        return

    if task["fields"]["status"]["name"].lower() != "open":
        return

    transitions = make_jira_request(
        TaskTransitionsRequest(branch, user, password)
    )

    if transitions is None:
        return

    for transition in transitions["transitions"]:
        if transition["name"].lower() == "start progress":
            return make_jira_request(
                StartTaskRequest(branch, transition["id"], user, password)
            )


if __name__ == "__main__":
    main()
