# OpenClaw docker setup

This is my docker and docker compose setup for OpenClaw with an API-compatible gateway for [Kiro][], which allows the use of Anthropic models, minimax-m2.1, etc. using Kiro's affordable pro plan rather than pay-as-you-go rates from Google, Amazon Bedrock, etc.I have also included my own [openclaw-canvas-web][] server for agent-driven web UIs.

Note: You will need a separate model for memory search that supports embeddings. Its usage costs should be negligible. I am currently using `gemini/gemini-embedding-001` via the Google AI free preview.

## OpenClaw

- `node:lts` is used for the base image
- Homebrew is installed in the image
- Some utilities available in `apt` are installed with `brew` to obtain newer versions
- A D-bus user session manager is started before the OpenClaw gateway
- OpenClaw is executed as a non-root user

### Extras

- `awslabs.openapi-mcp-server` - Make MCP servers from OpenAPI spec docs on the fly
- `asciinema` - Record terminal transcript sessions as videos and upload to https://asciinema.org
- `chromium` - Chromium browser, able to headlessly control browser sessions
- `dbus-user-session` - Provides a user-level D-bus session
- `gh` - GitHub command line tool
- `jq` - Parse and manipulate JSON data
- `sqlite3` - Access SQLite databases
- `tmux` - Headless PTY sessions that agents can control, even in kludge mode
- `wordnet` - Dictionary, thesaurus, and more

## Kiro Gateway

- Uses the [kiro-gateway][] project to serve Kiro desktop models via an OpenAI-compatible API
- First container startup will run the bootstrap script, and then you must use `kiro-cli login` to provide credentials
  - Fire up a shell session with `docker compose exec -it --entrypoint /bin/bash kiro`
  - Run the `kiro-cli login --use-device-flow &` command in the background
  - Visit the provided link
  - Visit the callback URL with `curl`
- Subsequent container init should load the Kiro gateway successfully

### Alternate login method

You can copy the contents of your `~/.local/share/kiro-cli/data.sqlite3` file into the volume used by the container after you've logged in using a Kiro Desktop installation.

## Canvas web server

The [openclaw-canvas-web][] server is being served at `/canvas`, with individual agent sessions available at `/canvas/session/<agent>` (example: `/canvas/session/main`). Agents should be able to use this server with the accompanying skill in order to build reactive web interfaces.

You will need to clone the repository into the docker volume being mounted into the container. The default location is `/home/node/openclaw-canvas-web`.

## Traefik

This setup assumes you have an external docker network, `proxy`, that the [Traefik][] proxy is attached to. You will also need to configure your own TLS resolver (mine is `home_dot_arpa` in my Traefik config). Yank out all the custom network configuration and the docker labels if you have a different stack.

[kiro]: https://kiro.dev
[kiro-gateway]: https://github.com/jwadow/kiro-gateway
[openclaw-canvas-web]: https://github.com/haliphax-openclaw/openclaw-canvas-web
[traefik]: https://traefik.io/traefik

