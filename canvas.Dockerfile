FROM node:lts
USER root

# entry point script with bootstrap
RUN cat >/start.sh <<EOF
#!/bin/bash
set -eo pipefail

[ -d "/home/node/openclaw-canvas-web/dist" ] || {
    npm config set prefix /home/node/npm;
    cd /home/node/openclaw-canvas-web;
    npm run clean || true;
    npm run setup;
    VITE_BASE=/canvas/ npm run build;
    cd mcp;
    npm run build;
}

npx tsx /home/node/openclaw-canvas-web/src/server/index.ts
EOF

RUN chmod 777 /start.sh

# non-root user
USER node
ENV USER=node
ENV PATH="/home/node/npm/bin:/home/node/.local/bin:${PATH}"
ENTRYPOINT /start.sh
