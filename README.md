# OpenClaw docker setup

This is my docker and docker compose setup for OpenClaw with an API-compatible gateway for kiro, which allows the use of Anthropic models, minimax-m2.1, etc. using kiro's affordable pro plan rather than pay-as-you-go rates from Google, Amazon Bedrock, etc.

Note: You will need a separate model for memory search that supports embeddings. Its usage costs should be negligible. I am currently using `gemini/gemini-embedding-001` via the Google AI free preview.

## OpenClaw

- `node:lts` is used for the base image
- Homebrew is installed in the image
- Some utilities available in `apt` are installed with `brew` to obtain newer versions
- A D-bus user session manager is started before the OpenClaw gateway
- OpenClaw is executed as a non-root user

## Kiro Gateway

- Uses the [kiro-gateway][] project to serve kiro desktop models via an OpenAI-compatible API
- First container startup will run the bootstrap script, and then you must use `kiro-cli login` to provide credentials
  - Fire up a shell session with `docker compose exec -it --entrypoint /bin/bash kiro`
  - Run the `kiro-cli login --use-device-flow` command
  - Visit the provided link
  - Fire up a second shell session
  - Visit the callback URL in the second session with `curl`
- Subsequent container init should load the kiro gateway successfully

[kiro-gateway]: https://github.com/jwadow/kiro-gateway

