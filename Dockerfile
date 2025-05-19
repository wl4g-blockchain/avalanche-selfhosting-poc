# SPDX-License-Identifier: GNU GENERAL PUBLIC LICENSE Version 3
#
# Copyleft (c) 2024 James Wong. This file is part of James Wong.
# is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the
# Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# James Wong is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with James Wong.  If not, see <https://www.gnu.org/licenses/>.
#
# IMPORTANT: Any software that fully or partially contains or uses materials
# covered by this license must also be released under the GNU GPL license.
# This includes modifications and derived works.
#

FROM registry.cn-shenzhen.aliyuncs.com/wl4g/debian:bookworm AS base

ARG BUILD_MIRROR_URL=http://mirrors.aliyun.com
ARG DEBIAN_FRONTEND=noninteractive

LABEL maintainer="${PROJECT_MAINTAINER}" \
      description="${PROJECT_DESC}" \
      org.opencontainers.image.title=docker-avalanche-localnet \
      org.opencontainers.image.source=docker-avalanche-localnet \
      org.opencontainers.image.version=master \
      build.repo.url=https://github.com/wl4g-blockchain/docker-avalanche-localnet \
      build.repo.commit=${BUILD_COMMIT_ID} \
      build.repo.tag=master \
      build.deps.mirror.url=${BUILD_MIRROR_URL}

# Set up fast APT sources and such as:
#   Debian Official Default: http://deb.debian.org
#   Alibaba Cloud Internal: http://mirrors.cloud.aliyuncs.com
#   Alibaba Cloud External: http://mirrors.aliyun.com
RUN rm -f /etc/apt/sources.list.d/debian.sources && \
    echo "deb ${BUILD_MIRROR_URL}/debian bookworm main contrib non-free non-free-firmware" > /etc/apt/sources.list && \
    echo "deb ${BUILD_MIRROR_URL}/debian-security bookworm-security main contrib non-free non-free-firmware" >> /etc/apt/sources.list && \
    echo "deb ${BUILD_MIRROR_URL}/debian bookworm-updates main contrib non-free non-free-firmware" >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        pkg-config \
        ca-certificates \
        procps \
        curl \
        tree \
        net-tools \
        python3 \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /root

RUN echo "alias ll='ls -al'" >> ~/.bashrc && \
    echo "alias cls=clear" >> ~/.bashrc && \
    curl -vL -o /bin/avalanche-cli 'https://github.com/ava-labs/avalanche-cli/releases/download/v1.8.10/avalanche-cli_1.8.10_linux_amd64.tar.gz' && \
    mkdir -p ~/.avalanche-cli/bin/avalanchego/avalanchego-v1.13.0/ && \
    curl -vL -o ~/.avalanche-cli/bin/avalanchego/avalanchego-v1.13.0/avalanchego 'https://github.com/ava-labs/avalanchego/releases/download/v1.13.0/avalanchego-linux-amd64-v1.13.0.tar.gz' && \
    mkdir -p ~/.avalanche-cli/bin/subnet-evm/subnet-evm-v0.7.3/ && \
    curl -vL -o ~/.avalanche-cli/bin/subnet-evm/subnet-evm-v0.7.3/avalanchego 'https://github.com/ava-labs/subnet-evm/releases/download/v0.7.3/evm_0.7.3_linux_amd64.tar.gz'

COPY <<"EOF" fake-api-github-server.py
from http.server import BaseHTTPRequestHandler, HTTPServer
import json
import ssl
import socket
import os

def get_local_ip():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        s.connect(('10.255.255.256', 1))
        ip = s.getsockname()[0]
    except Exception:
        ip = '127.0.0.1'
    finally:
        s.close()
    return ip

class MockGitHubAPI(BaseHTTPRequestHandler):
    def log_message(self, format, *args):
        # Custom the logging format.
        client_ip = self.client_address[0]
        user_agent = self.headers.get('User-Agent', '-')
        print(f'[REQUEST] {client_ip} -> "{self.command} {self.path} {self.request_version}" | User-Agent: {user_agent}', flush=True)

    def do_GET(self):
        client_ip = self.client_address[0]
        user_agent = self.headers.get('User-Agent', '-')

        # Log request details
        print(f"Handling request from {client_ip}")
        print(f"Requested path: {self.path}")
        print(f"User-Agent: {user_agent}")
        print("-" * 60)

        # Skip leading slash and replace / with _
        file_name = self.path.lstrip('/').replace('/', '_') + '.json'
        print(f"Loading file name: {file_name}", flush=True)

        if os.path.exists(file_name):
            try:
                with open(file_name, 'r') as f:
                    data = json.load(f)
                self.send_response(200)
                self.send_header('Content-type', 'application/json')
                self.end_headers()
                self.wfile.write(json.dumps(data).encode())
                print(f"[RESPONSE] Returning mocked JSON from {file_name}")
            except Exception as e:
                print(f"[ERROR] Failed to read {file_name}: {e}")
                self.send_response(500)
                self.end_headers()
        else:
            print(f"[WARNING] No mock file found for path: {self.path} (looked for {file_name})")
            self.send_response(404)
            self.end_headers()

def run():
    server_address = ('0.0.0.0', 443)
    httpd = HTTPServer(server_address, MockGitHubAPI)

    httpd.socket = ssl.wrap_socket(
        httpd.socket,
        keyfile='key.pem',
        certfile='cert.pem',
        server_side=True,
        ssl_version=ssl.PROTOCOL_TLSv1_2
    )

    local_ip = get_local_ip()
    print(f"✅ Starting HTTPS mock GitHub API server on https://{local_ip}:443...")
    print("Serving mock JSON files based on path:")
    print("  e.g., /repos/ava-labs/avalanchego/releases/latest -> repos_ava-labs_avalanchego_releases_latest.json")
    print("-" * 60)

    httpd.serve_forever()

if __name__ == '__main__':
    run()
EOF

COPY <<"EOF" repos_ava-labs_avalanchego_releases_latest.json
{
  "url": "https://api.github.com/repos/ava-labs/avalanchego/releases/207632852",
  "id": 207632852,
  "author": {},
  "node_id": "RE_kwDODq-TvM4MYDnU",
  "tag_name": "v1.13.0",
  "name": "Fortuna - C-Chain Fee Overhaul",
  "draft": false,
  "prerelease": false,
  "created_at": "2025-03-21T17:43:17Z",
  "assets": [
    {
      "url": "https://api.github.com/repos/ava-labs/avalanchego/releases/assets/240171753",
      "id": 240171753,
      "node_id": "RA_kwDODq-TvM4OULrp",
      "name": "avalanchego-linux-amd64-v1.13.0.tar.gz",
      "content_type": "application/x-gzip",
      "size": 37265715,
      "updated_at": "2025-03-24T01:50:11Z",
      "browser_download_url": "https://github.com/ava-labs/avalanchego/releases/download/v1.13.0/avalanchego-linux-amd64-v1.13.0.tar.gz"
    }
  ]
}
EOF

COPY <<"EOF" repos_ava-labs_avalanchego_releases.json
[
  {
    "url": "https://api.github.com/repos/ava-labs/avalanchego/releases/207632852",
    "id": 207632852,
    "author": {},
    "node_id": "RE_kwDODq-TvM4MYDnU",
    "tag_name": "v1.13.0",
    "name": "Fortuna - C-Chain Fee Overhaul",
    "draft": false,
    "prerelease": false,
    "created_at": "2025-03-21T17:43:17Z",
    "assets": [
      {
        "url": "https://api.github.com/repos/ava-labs/avalanchego/releases/assets/240171753",
        "id": 240171753,
        "node_id": "RA_kwDODq-TvM4OULrp",
        "name": "avalanchego-linux-amd64-v1.13.0.tar.gz",
        "content_type": "application/x-gzip",
        "size": 37265715,
        "updated_at": "2025-03-24T01:50:11Z",
        "browser_download_url": "https://github.com/ava-labs/avalanchego/releases/download/v1.13.0/avalanchego-linux-amd64-v1.13.0.tar.gz"
	     }
	   ]
	}
]
EOF

COPY <<"EOF" openssl.cnf 
[ req ]
default_bits        = 4096
default_md          = sha256
distinguished_name  = req_distinguished_name
req_extensions      = req_ext
x509_extensions     = v3_req
prompt              = no

[ req_distinguished_name ]
C  = US
ST = California
L  = San Francisco
O  = MyOrg
OU = MyTeam
CN = api.github.com

[ req_ext ]
subjectAltName = @alt_names

[ v3_req ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = api.github.com
EOF

RUN echo "127.0.0.1 api.github.com" >> /etc/hosts && \
    openssl req -x509 -new -nodes -keyout key.pem -out cert.pem -days 365 -config openssl.cnf -sha256 && \
    cp cert.pem /usr/local/share/ca-certificates/github.crt && \
    update-ca-certificates

ENTRYPOINT [ "bash" , "-c", "tail", "-f", "/dev/null"]