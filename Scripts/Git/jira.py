#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Please refer to https://github.com/redbeacon/marketpro-ios/wiki/Jira-Integration for more information.

__author__ = "Ozgur Vatansever"
__copyright__ = "Copyright 2015, Techshed"


import argparse
import BaseHTTPServer
import base64
import cgi
import json
import os
import random
import re
import shlex
import signal
import time
import subprocess
import sys
import urllib2


def case_insensitive_match(first, second):
    return first.lower() == second.lower()


def enum(**enums):
    """Creates enumeration with given parameters.
    Example: Numbers = enum(ONE="one", TWO="two", THREE="three")
    Original code taken from: http://bit.ly/1Nw8XGR
    """
    return type('Enum', (), enums)


HTTPMethod = enum(GET="GET", POST="POST", PUT="PUT", DELETE="DELETE")
Status = enum(OPEN="Open", IN_PROGRESS="In Progress", REOPENED="Reopened")
Transition = enum(START_PROGRESS="Start Progress", RESOLVE_ISSUE="Resolve Issue")
RELATED_ISSUE_TYPE="has to be finished together with"


class JiraRequest(object):
    """Base class for representing a single HTTP request made to JIRA RESTful
    api.

    Each should know the host name, the endpoint and the user credentials
    that will be used for authenticating user through HTTP Basic authentication.

    Arguments:
    host -- API host name without scheme. (ex: jira.atlassian.com)
    url  -- API endpoint url. (ex: /rest/api/2/issue/OV-1234)
    auth -- A tuple of username and password used for authentication.

    Keyword arguments:
    data      -- Body of request if there is any. Must be in JSON format.
    headers   -- Additional HTTP headers dict that will be sent.
    force_ssl -- A boolean to force SSL usage. Will determine the URL scheme.
    """
    def __init__(
        self, host, url, auth, data=None, headers=None, force_ssl=True):

        scheme = "https" if force_ssl else "http"
        self.url = "{}://{}{}".format(scheme, host, url)
        self.auth = auth
        self.data = data

        self.headers = headers or {}
        self.headers.update({"Content-Type": "application/json"})

        # Currently, we support only two methods. :)
        self.method = HTTPMethod.POST if data else HTTPMethod.GET

        self.response = None
        self.status_code = None

    @property
    def request(self):
        """Returns an actual `urllib2.Request` instance from this class with the
        given `data` and `headers` passed upon initialization of the class.

        Please keep in mind, this property is just a getter so that every time
        you call this ivar, a new instance is created.
        """
        if self.method == HTTPMethod.GET:
            request = urllib2.Request(self.url)
        else:
            request = urllib2.Request(self.url, json.dumps(self.data))

        for key, value in self.headers.items():
            request.add_header(key, value)

        if self.auth:
            username, password = self.auth
            auth = base64.encodestring("%s:%s" % (username, password))
            auth = auth.replace("\n", "")  # need to trim trailing new line.
            request.add_header("Authorization", "Basic %s" % auth)

        return request

    def handle_response(self, response):
        """A middleware function to process the response object returned from
        API call.

        Default implementation of this function sets `self.status_code` and
        `self.response` and, then closes the HTTP connection.

        Any subclass intending to execute additional logic regarding processing
        and parsing the response should subclass this method and call
        `super.handle_response(response)` first before adding the extra work.
        """
        self.status_code = response.getcode()
        self.response = response.read()
        response.close()


class TaskDetailsRequest(JiraRequest):
    """A Request for getting the details of a JIRA task.

    Arguments:
    host     -- API host name without scheme. (ex: jira.atlassian.com)
    task_key -- Identifier that represents a task in JIRA. (ex: OV-1234)
    username -- JIRA username for authentication.
    password -- JIRA password for authentication.
    """
    def __init__(self, host, task_key, username, password):
        super(TaskDetailsRequest, self).__init__(
            host, "/rest/api/2/issue/{}".format(task_key), (username, password)
        )

    def handle_response(self, response):
        """A middleware function to process the response object returned from
        API call.

        Converts `self.response` into a dictionary using `json.loads` only if
        HTTP status is 200.
        """
        super(TaskDetailsRequest, self).handle_response(response)
        if self.status_code == 200:
            self.response = json.loads(self.response)


class TaskTransitionsRequest(JiraRequest):
    """Represents a request for getting all possible transitions of a JIRA
    task which it can move into.

    Arguments:
    host     -- API host name without scheme. (ex: jira.atlassian.com)
    task_key -- Identifier that represents a task in JIRA. (ex: OV-1234)
    username -- JIRA username for authentication.
    password -- JIRA password for authentication.
    """
    def __init__(self, host, task_key, username, password):
        super(TaskTransitionsRequest, self).__init__(
            host,
            "/rest/api/2/issue/{}/transitions".format(task_key),
            (username, password)
        )

    def handle_response(self, response):
        """A middleware function to process the response object returned from
        API call.

        Converts `self.response` into a dictionary using `json.loads` only if
        HTTP status is 200.
        """
        super(TaskTransitionsRequest, self).handle_response(response)
        if self.status_code == 200:
            self.response = json.loads(self.response)


class UpdateTaskRequest(JiraRequest):
    """Represents a request for editing some fields of a JIRA task including
    transitioning to new state and, adding new comments.

    Arguments:
    host           -- API host name without scheme. (ex: jira.atlassian.com)
    task_key       -- Identifier that represents a task in JIRA. (ex: OV-1234)
    transition_key -- ID of the transition.
    username       -- JIRA username for authentication.
    password       -- JIRA password for authentication.

    Keyword arguments:
    comment -- Comment to be added into task history. Omitted if it is NULL.
    """
    def __init__(
        self, host, task_key, transition_key, username, password,
        assignee=None, comment=None):

        data = {"transition": {"id": transition_key}}
        if comment:
            data.update({"update": {"comment": [{"add": {"body": comment}}]}})
        if assignee:
            data.update({"fields": {"assignee": {"name": assignee}}})

        url = "/rest/api/2/issue/{}/transitions".format(task_key)
        super(UpdateTaskRequest, self).__init__(host, url, (username, password), data)


class AddCommentRequest(JiraRequest):
    """Represents a request for adding comment into a task.

    Arguments:
    host           -- API host name without scheme. (ex: jira.atlassian.com)
    task_key       -- Identifier that represents a task in JIRA. (ex: OV-1234)
    transition_key -- ID of the transition.
    username       -- JIRA username for authentication.
    password       -- JIRA password for authentication.
    comment        -- Comment to be added into task history.
    """
    def __init__(self, host, task_key, username, password, comment):
        data = {"body": comment}
        url = "/rest/api/2/issue/{}/comment".format(task_key)
        super(AddCommentRequest, self).__init__(host, url, (username, password), data)


def make_http_request(request):
    """Helper function for firing an HTTP request with given JIRA request
    returning the response.

    Arguments:
    request -- A `JiraRequest` instance.
    """
    print "{0: <4}".format(request.method), "->", request.url
    response = urllib2.urlopen(request.request)
    request.handle_response(response)
    return request.response


def get_task(host, task_key, user, password, statuses=None):
    """Shortcut function for getting task details as a Python dictionary.

    There are possible check points such as:
    - If the fetched task is not currently assigned to current user, then
    this function returns NULL.
    - If the fetched task's status is not equal to given status, then
    this function returns NULL.

    Arguments:
    host     -- host address of the Rest API.
    task_key -- Identifier that represents a task in JIRA. (ex: OV-1234)
    username -- JIRA username for authentication.
    password -- JIRA password for authentication.

    Keyword arguments:
    statuses -- List of status for doing additional lookup along with
    `task_key` for finding the task. Omitted when it is left NULL.
    """
    if not (task_key and re.compile("^[A-Z]{2,3}-\d+$").match(task_key)):
        return None

    try:
        task = make_http_request(TaskDetailsRequest(host, task_key, user, password))
    except urllib2.HTTPError:
        return None

    if not task:
        return None

    assignee = task["fields"]["assignee"]["key"]
    if not case_insensitive_match(assignee, user):
        return None

    if not statuses:
        return task

    task_status = task["fields"]["status"]["name"]
    if not any(case_insensitive_match(task_status, st) for st in statuses):
        return None

    return task


def start_task(host, task_key, user, password):
    """Shortcut function for transitioning a task to "In Progress". Internally
    it calls `get_task` to retrieve the task info and updates the status if
    possible.

    Arguments:
    host     -- API host name without scheme. (ex: jira.atlassian.com)
    task_key -- Identifier that represents a task in JIRA. (ex: OV-1234)
    username -- JIRA username for authentication.
    password -- JIRA password for authentication.
    """
    task = get_task(host, task_key, user, password, (Status.OPEN, Status.REOPENED))
    if not task:
        return False

    transitions = make_http_request(
        TaskTransitionsRequest(host, task_key, user, password)
    )
    if not transitions:
        return False

    for transition in transitions["transitions"]:
        if case_insensitive_match(transition["name"], Transition.START_PROGRESS):
            make_http_request(
                UpdateTaskRequest(host, task_key, transition["id"], user, password)
            )
            break

    for task in task["fields"].get("issuelinks", []):
        if case_insensitive_match(task["type"]["inward"], RELATED_ISSUE_TYPE):
            related_task_key = task.get("inwardIssue", {}).get("key")
            start_task(host, related_task_key, user, password)

    return True


def resolve_task(host, task_key, user, password, assignee=None, comment=None):
    """Shortcut function for transitioning a task to "Resolved". Internally
    it calls `get_task` to retrieve the task info and updates the status if
    possible.

    Arguments:
    host     -- API host name without scheme. (ex: jira.atlassian.com)
    task_key -- Identifier that represents a task in JIRA. (ex: OV-1234)
    username -- JIRA username for authentication.
    password -- JIRA password for authentication.

    Keyword arguments:
    assignee -- New assignee of task after the transition. Optional.
    comment  -- Additional comment message after transition. Optional.
    """
    task = get_task(host, task_key, user, password, (Status.IN_PROGRESS,))
    if not task:
        return False

    transitions = make_http_request(
        TaskTransitionsRequest(host, task_key, user, password)
    )
    if not transitions:
        return False

    for transition in transitions["transitions"]:
        if case_insensitive_match(transition["name"], Transition.RESOLVE_ISSUE):
            make_http_request(
                UpdateTaskRequest(host, task_key, transition["id"],
                                  user, password, assignee, comment)
            )
            return True

    return False


class JiraWebhookHandler(BaseHTTPServer.BaseHTTPRequestHandler):
    """Class for handling incoming requests originated from Github webhooks.

    Only responds to POST requested as explained in great detail in Github
    webhook documentation.

    When a POST request is made to the handler, it gathers all required
    information to mark the corresponding JIRA task as "Resolved" and calls
    the designated API endpoint to do so.
    """
    JIRA_WEBHOOK_URL = "/jira"

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

        if case_insensitive_match(self.path, self.JIRA_WEBHOOK_URL):
            form = cgi.FieldStorage(
                self.rfile, self.headers, environ={"REQUEST_METHOD": "POST"}
            )
            data = json.loads(form.file.read())

            if case_insensitive_match(data["action"], "closed"):
                pull_request = data["pull_request"]

                if pull_request["merged"] is True:
                    return

                branch = pull_request["head"]["ref"]
                comment = "Merged {}".format(pull_request["html_url"])
                assignee = random.choice(self.server.qa_users or [None])
                resolve_task(
                    self.server.jira_host, branch, self.server.user,
                    self.server.password, assignee, comment)

            elif case_insensitive_match(data["action"], "opened"):
                pull_request = data["pull_request"]

                if pull_request["merged"] is True:
                    return

                branch = pull_request["head"]["ref"]
                comment = "In code review: {}".format(pull_request["html_url"])
                make_http_request(AddCommentRequest(
                    self.server.jira_host, branch, self.server.user,
                    self.server.password, comment))


class JiraWebhookServer(BaseHTTPServer.HTTPServer):
    """Server instance subclassed from `BaseHTTPServer.HTTPServer` to just
    hold the authentication credentials passed from the bash environment.
    """
    def __init__(self, jira_host, user, password, qa_users, *args, **kwargs):
        BaseHTTPServer.HTTPServer.__init__(self, *args, **kwargs)
        self.jira_host = jira_host
        self.user = user
        self.password = password
        self.qa_users = qa_users


def run_server_forever(port, jira_host, user, password, qa_users,
                       handler_class=JiraWebhookHandler, force_kill=False):
    """ Starts webhook server. """
    host = "127.0.0.1"  # localhost
    server = JiraWebhookServer(
        jira_host, user, password, qa_users, (host, port), handler_class)

    print time.asctime(), "- Webhook server {}:{} started.".format(host, port)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    server.server_close()
    print time.asctime(), "- Webhook server {}:{} stopped.".format(host, port)


def kill_server(port):
    """ Kills any server process listening to given port. """
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
    parser.add_argument(
        "-b", "--branch", help="Git branch name", type=str, default="master"
    )
    parser.add_argument("-n", "--host", help="JIRA API host", type=str)
    parser.add_argument("-u", "--user", help="JIRA username", type=str)
    parser.add_argument("-w", "--password", help="JIRA password", type=str)
    parser.add_argument("-q", "--qa", help="JIRA QA users", nargs="*", type=str)
    args = parser.parse_args()

    if not (args.user and args.password):
        return False

    if args.force:
        kill_server(args.port)

    if args.listen:
        run_server_forever(
            args.port, args.host, args.user, args.password, args.qa,
            force_kill=args.force)
        return True
    else:
        return start_task(args.host, args.branch, args.user, args.password)


if __name__ == "__main__":
    main()
