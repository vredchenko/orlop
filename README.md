# orlop

Orlop Deck project - an opinionated CLI tool-belt

## Dependencies

- docker && docker compose
- bun.js
- python 3.12

## Quick start

```sh
# clean up prev container and rebuild
./dev.sh

# develop toolchain
cd src/
bun install

# check github repo for latest release
export GITHUB_TOKEN=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 && \
python src/check_release.py dundee gdu

source example.env
python src/check_release.py dundee gdu
python src/check_release.py lsd-rs lsd
python src/check_release.py BurntSushi ripgrep
python src/check_release.py tomnomnom gron
python src/check_release.py zyedidia micro

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
