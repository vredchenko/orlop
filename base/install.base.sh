#!/usr/bin/env bash

# TODO fix env vars:
source ./orlop.env
env | grep '^ORLOP_'

# ----------------------------------------------
# Init filesystem
# ----------------------------------------------

mkdir -p "$ORLOP_TMP_DIR"
mkdir -p "$ORLOP_BIN_DIR"
mkdir -p "$ORLOP_CONF_DIR"
mkdir -p "$ORLOP_FONTS_DIR"
#touch "$ORLOP_BASHRC" TODO copied across by Dockerfile so no need


# Set Python3 as default python
sudo ln -s /usr/bin/python3 /usr/bin/python

# TODO Install Go
#curl -L https://go.dev/dl/go1.22.0.linux-amd64.tar.gz | tar -C /usr/local -xzf -
#export PATH="/usr/local/go/bin:${PATH}"

# TODO Install Rust (for orlop user)
#export RUSTUP_HOME=/usr/local/rustup
#export CARGO_HOME=/usr/local/cargo
#curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
#export PATH="/usr/local/cargo/bin:${PATH}"
# TODO check cargo is installed: cargo -v

# TODO Install latest stable Bun
#curl -fsSL https://bun.sh/install | bash && \
#  # Make bun available for orlop user too
#  cp -r /root/.bun /home/orlop/.bun && \
#  chown -R orlop:orlop /home/orlop/.bun
## Add Bun to PATH for all users
#export PATH="/home/orlop/.bun/bin:${PATH}"

# TODO install FNM


# ----------------------------------------------
# Install nerdfonts
# ----------------------------------------------
# nerd font
# ref: https://linuxtldr.com/install-fonts-on-linux/
# (pick a font here: https://www.nerdfonts.com/font-downloads?ref=linuxtldr.com)
#sudo apt install -y fontconfig
#
#cd "$ORLOP_TMP_DIR"
#wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/DejaVuSansMono.zip
#unzip DejaVuSansMono.zip -d "$ORLOP_FONTS_DIR/DejaVuSansMono"
#rm DejaVuSansMono.zip
#
#wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/FiraCode.zip
#unzip FiraCode.zip -d "$ORLOP_FONTS_DIR/FiraCode"
#rm FiraCode.zip
#
#fc-cache -f -v

# ----------------------------------------------
# Install starship shell
# ----------------------------------------------
# ref: https://starship.rs/guide/
curl -sS https://starship.rs/install.sh | sh
echo 'eval "$(starship init bash)"' >> "$ORLOP_BASHRC"

starship preset tokyo-night -o ~/.config/starship.toml

