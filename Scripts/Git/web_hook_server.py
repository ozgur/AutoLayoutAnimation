#!/usr/bin/env python
# -*- coding: utf-8 -*-

import BaseHTTPServer
import cgi
import json
import sys
import time

class WebhookHandler(BaseHTTPServer.BaseHTTPRequestHandler):
    URLS = {"/jira": "This url goes to Jira"}

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
        form = cgi.FieldStorage(
            self.rfile, self.headers, environ={"REQUEST_METHOD": "POST"}
        )
        print json.loads(form.file.read())
        self.set_headers()
        self.wfile.write(json.dumps({"response": "OK"}))


def run(host, port, handler):
    server = BaseHTTPServer.HTTPServer((host, port), handler)
    print time.asctime(), "- Webhook server {}:{} started.".format(host, port)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    server.server_close()
    print time.asctime(), "- Webhook server {}:{} stopped.".format(host, port)


if __name__ == "__main__":
    run("localhost", int(sys.argv[1]), handler=WebhookHandler)
