FROM python:3.14-alpine
COPY --from=docker.io/astral/uv:latest /uv /uvx /bin/
USER root

# base packages
RUN apk add -U bash curl git

# kiro user
RUN addgroup -S kiro && adduser -S -D -u 1000 -G kiro kiro
WORKDIR /home/kiro

# entry point script with bootstrap
RUN cat >/main.sh <<EOF
#!/bin/bash
set -eo pipefail

[ -f "/home/kiro/.bashrc" ] || {
    cd /home/kiro;
    echo 'PATH="\$HOME/.local/bin:\$PATH"' >> .bashrc;
    curl -fsSL https://cli.kiro.dev/install | bash;
    git clone https://github.com/jwadow/kiro-gateway;
    cd kiro-gateway;
    uv venv;
    uv pip install -r requirements.txt;
}

cd /home/kiro/kiro-gateway
source .venv/bin/activate
uv run main.py
EOF

RUN chmod 777 /main.sh && chown -R kiro:kiro /home/kiro

# non-root user
USER kiro

ENTRYPOINT /main.sh

