# /// script
# dependencies = ["flask", "termcolor"]
# ///

import argparse
from flask import Flask, Response, request
from termcolor import colored
from werkzeug.serving import WSGIRequestHandler

app = Flask(__name__)

ALLOWED_METHODS = ['GET', 'POST', 'PUT', 'PATCH', 'DELETE']

@app.route('/', defaults={'path': ''}, methods=ALLOWED_METHODS)
@app.route('/<path:path>', methods=ALLOWED_METHODS)
def catch_all(path):
    # Separate this request from others.
    print("\n")

    # Print request information.
    print(colored(f'Received {request.method} -> {request.url}', 'red'))
    print(colored(f"From {request.environ['REMOTE_ADDR']}:{request.environ['REMOTE_PORT']}", 'red'))
    print(colored('Request Body:', 'green'))
    if all([chr(x).isprintable() for x in request.data if x not in [10, 13]]):
        print(request.data.decode())
    else:
        print(request.data)
    print(colored('Request Headers:', 'green'))
    print(str(request.headers).strip())

    # Return generic successful response.
    resp = Response("awesome")
    resp.headers['Connection'] = 'keep-alive'
    return resp

if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description='A Simple HTTP/S Server Which Echoes'
    )
    parser.add_argument('-p', '--port', default=9999, type=int,
        help='destination port number')
    args = parser.parse_args()
    WSGIRequestHandler.protocol_version = "HTTP/1.1"
    app.run(host='0.0.0.0', port=args.port, debug=True)
