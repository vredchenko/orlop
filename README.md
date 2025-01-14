# orlop

Orlop Deck project - an opinionated CLI tool-belt.

## Dependencies

- docker && docker compose
- bun.js

## Quick start

```sh
# clean up prev container and rebuild
./dev.sh

# develop toolchain
cd src/
bun install
```

## build Dockerfile

`./dev.sh`

```sh
# build
docker build -t orlop-base:dev .

# run with interactive shell
docker run -it orlop-base bash

# run and exec bash (get container to wait?)
#docker run -d --name mycontainer orlop-base
#docker exec -it mycontainer bash

# clean up
docker rm -f mycontainer
```