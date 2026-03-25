FROM node:lts
USER root

# base packages
RUN apt-get update && apt-get install -y \
    asciinema \
    build-essential \
    chromium \
    curl \
    dbus \
    dbus-user-session \
    file \
    fonts-noto-color-emoji \
    git \
    jq \
    procps \
    sqlite3 \
    tmux \
    vim-tiny \
    wordnet \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# homebrew dir
RUN mkdir -p /home/linuxbrew/.linuxbrew && chown -R node:node /home/linuxbrew

# entry point script with bootstrap
RUN cat >/start.sh <<EOF
#!/bin/bash
set -eo pipefail

[ -f "/home/node/.npmrc" ] || {
    npm config set prefix /home/node/npm;
    npm i -g openclaw@latest clawhub mcporter awslabs.openapi-mcp-server;
}

dbus-daemon --session --fork --address=unix:path=/tmp/dbus-session.sock
openclaw gateway
EOF

RUN chmod 777 /start.sh

# non-root user
USER node
ENV USER=node

# install homebrew
RUN NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
ENV PATH="/home/node/npm/bin:/home/node/.local/bin:/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:${PATH}"

# homebrew packages
RUN brew install gh go

ENTRYPOINT ["/start.sh"]
