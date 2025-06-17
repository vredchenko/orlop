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

- ansible/
- docker && docker compose
- bun.js
- python 3.13


## Install on VM using Ansible

> Note: currently configured for homebox VM

```bash
# install Ansible on control machine
sudo apt install ansible -y
sudo apt install sshpass -y

# for exposing VM on hostos network
sudo apt install bridge-utils nmap -y

# cd into this directory
cd ansible

# test connectivity
ansible homebox -i inventory/hosts.yml -m ping

# apply config to target machine
ansible-playbook -i inventory/hosts.yml playbooks/site.yml -vv
```

## Quick start

```sh
# develop toolchain
cd src/
bun install

```

## directory structure

- `/src` is where the dev codebase lives - a mix of ts / python / bash

## dev notes

```sh
docker image rm orlopdeck:dev -f
docker build --progress=plain --platform linux/amd64 -t orlopdeck:dev .
docker run -it orlopdeck:dev -c /bin/bash
```
