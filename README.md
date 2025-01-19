# Orlop Deck - an opinionated CLI toolbelt

**What's with the naming?**

> The orlop is the lowest deck in a ship (except for very old ships).
> It is the deck or part of a deck where the cables are stowed, usually below the water line.
> It has been suggested the name originates from "overlooping" of the cables, or alternatively,
> that the name is a corruption of "overlap", referring to an overlapping,
> balcony-like half deck occupying a portion of the ship's lowest deck space.
> According to the Oxford English Dictionary, the word descends from Dutch overloop from the verb overlopen,
> "to run (over); extend".

https://en.wikipedia.org/wiki/Orlop_deck


## Dependencies

- docker && docker compose
- bun.js
- python 3.12

## Quick start

```sh
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

## directory structure

- `/base` dir is for common dependencies and assets that form the base layer of an installation, such as
    NerdFonts, Starship Shell, etc
- `/lib` dir contains an inventory of Orlop Deck tools, one per subdirectory. Every such subdirectory is
  expected to conform to a specific file structure
- `/templates/lib-item` defines specific file structure for subdirectories in `/lib`
- `/src` is where the dev codebase lives - a mix of ts / python / bash

## dev notes

```sh
docker image rm orlopdeck:dev -f
docker build --progress=plain --platform linux/amd64 -t orlopdeck:dev .
docker run -it orlopdeck:dev -c /bin/bash
```
