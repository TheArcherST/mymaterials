FROM python:3.12-slim-bookworm@sha256:e697c81897302a4c4333bade000d98038fbb21eb064f8ee1fd42d02ebcd9d337
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates git openssh-client make libatomic1 curl tini \
    fonts-noto-core fonts-jetbrains-mono \
    && rm -rf /var/lib/apt/lists/*
COPY tools/install.py tools/versions.json /opt/build-tools/
RUN python /opt/build-tools/install.py --bin-dir /usr/local/bin
RUN python - <<'PY'
import hashlib, json, urllib.request, subprocess
from pathlib import Path
v = json.loads(Path('/opt/build-tools/versions.json').read_text())
url = f"https://github.com/coder/code-server/releases/download/v{v['code_server']}/code-server_{v['code_server']}_amd64.deb"
data = urllib.request.urlopen(url, timeout=120).read()
assert hashlib.sha256(data).hexdigest() == v['code_server_sha256'], 'code-server checksum mismatch'
Path('/tmp/code-server.deb').write_bytes(data)
subprocess.run(['dpkg', '-i', '/tmp/code-server.deb'], check=True)
Path('/tmp/code-server.deb').unlink()
PY
RUN useradd --create-home --uid 1000 --shell /bin/bash editor \
    && mkdir -p /home/editor/workspace && chown editor:editor /home/editor/workspace
COPY infra/editor-entrypoint.sh /usr/local/bin/editor-entrypoint
RUN chmod 755 /usr/local/bin/editor-entrypoint
USER editor
ENV HOME=/home/editor
WORKDIR /home/editor/workspace
EXPOSE 8080
ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/editor-entrypoint"]
