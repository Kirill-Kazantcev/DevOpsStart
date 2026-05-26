#!/usr/bin/env python3
import http.server
import socket
import os

class Handler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/hostname':
            self.send_response(200)
            self.send_header('Content-Type', 'text/plain')
            self.end_headers()
            self.wfile.write(socket.gethostname().encode())
        else:
            super().do_GET()

if __name__ == '__main__':
    os.chdir('/app')
    server = http.server.HTTPServer(('0.0.0.0', 80), Handler)
    print(f"Server running on port 80, hostname: {socket.gethostname()}")
    server.serve_forever()
