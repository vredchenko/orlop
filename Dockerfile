# Enhanced Orlop Deck - CLI toolbelt with latest versions from GitHub releases
FROM ubuntu:24.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV CARGO_HOME=/usr/local/cargo
ENV RUSTUP_HOME=/usr/local/rustup
ENV PATH=/usr/local/cargo/bin:$PATH

# Install base dependencies
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
    sudo \
    python3 \
    python3-pip \
    curl \
    wget \
    unzip \
    tar \
    gzip \
    xz-utils \
    build-essential \
    pkg-config \
    git \
    bash-completion \
    htop \
    ca-certificates \
    jq \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Create orlop user with sudo privileges
RUN useradd -m -s /bin/bash orlop && \
    echo "orlop ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/orlop && \
    mkdir -p /usr/local/bin && \
    chown orlop:orlop /usr/local/bin

# Install Rust (required for some tools)
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path && \
    chmod -R a+w $RUSTUP_HOME $CARGO_HOME

# Function to get latest release tag from GitHub API
# Install ripgrep (latest from GitHub releases)
RUN RIPGREP_VERSION=$(curl -s https://api.github.com/repos/BurntSushi/ripgrep/releases/latest | jq -r .tag_name) && \
    echo "Installing ripgrep $RIPGREP_VERSION" && \
    curl -L "https://github.com/BurntSushi/ripgrep/releases/download/$RIPGREP_VERSION/ripgrep_${RIPGREP_VERSION}-1_amd64.deb" -o ripgrep.deb && \
    dpkg -i ripgrep.deb && \
    rm ripgrep.deb

# Install bat (latest from GitHub releases)
RUN BAT_VERSION=$(curl -s https://api.github.com/repos/sharkdp/bat/releases/latest | jq -r .tag_name) && \
    BAT_VERSION_CLEAN=$(echo $BAT_VERSION | sed 's/^v//') && \
    echo "Installing bat $BAT_VERSION" && \
    curl -L "https://github.com/sharkdp/bat/releases/download/$BAT_VERSION/bat_${BAT_VERSION_CLEAN}_amd64.deb" -o bat.deb && \
    dpkg -i bat.deb && \
    rm bat.deb

# Install delta (latest from GitHub releases)
RUN DELTA_VERSION=$(curl -s https://api.github.com/repos/dandavison/delta/releases/latest | jq -r .tag_name) && \
    echo "Installing delta $DELTA_VERSION" && \
    curl -L "https://github.com/dandavison/delta/releases/download/$DELTA_VERSION/git-delta_${DELTA_VERSION}_amd64.deb" -o delta.deb && \
    dpkg -i delta.deb && \
    rm delta.deb

# Install fzf (latest from GitHub releases)
RUN FZF_VERSION=$(curl -s https://api.github.com/repos/junegunn/fzf/releases/latest | jq -r .tag_name) && \
    FZF_VERSION_CLEAN=$(echo $FZF_VERSION | sed 's/^v//') && \
    echo "Installing fzf $FZF_VERSION" && \
    curl -L "https://github.com/junegunn/fzf/releases/download/$FZF_VERSION/fzf-${FZF_VERSION_CLEAN}-linux_amd64.tar.gz" -o fzf.tar.gz && \
    tar -xzf fzf.tar.gz -C /usr/local/bin/ && \
    rm fzf.tar.gz

# Install starship (latest from GitHub releases)
RUN STARSHIP_VERSION=$(curl -s https://api.github.com/repos/starship/starship/releases/latest | jq -r .tag_name) && \
    echo "Installing starship $STARSHIP_VERSION" && \
    curl -L "https://github.com/starship/starship/releases/download/$STARSHIP_VERSION/starship-x86_64-unknown-linux-gnu.tar.gz" -o starship.tar.gz && \
    tar -xzf starship.tar.gz -C /usr/local/bin/ && \
    rm starship.tar.gz

# Install gdu (latest from GitHub releases)
RUN GDU_VERSION=$(curl -s https://api.github.com/repos/dundee/gdu/releases/latest | jq -r .tag_name) && \
    GDU_VERSION_CLEAN=$(echo $GDU_VERSION | sed 's/^v//') && \
    echo "Installing gdu $GDU_VERSION" && \
    curl -L "https://github.com/dundee/gdu/releases/download/$GDU_VERSION/gdu_linux_amd64.tgz" -o gdu.tgz && \
    tar -xzf gdu.tgz -C /usr/local/bin/ && \
    rm gdu.tgz

# Install lsd (latest from GitHub releases)
RUN LSD_VERSION=$(curl -s https://api.github.com/repos/lsd-rs/lsd/releases/latest | jq -r .tag_name) && \
    LSD_VERSION_CLEAN=$(echo $LSD_VERSION | sed 's/^v//') && \
    echo "Installing lsd $LSD_VERSION" && \
    curl -L "https://github.com/lsd-rs/lsd/releases/download/$LSD_VERSION/lsd_${LSD_VERSION_CLEAN}_amd64.deb" -o lsd.deb && \
    dpkg -i lsd.deb && \
    rm lsd.deb

# Install micro (latest from GitHub releases)
RUN MICRO_VERSION=$(curl -s https://api.github.com/repos/zyedidia/micro/releases/latest | jq -r .tag_name) && \
    MICRO_VERSION_CLEAN=$(echo $MICRO_VERSION | sed 's/^v//') && \
    echo "Installing micro $MICRO_VERSION" && \
    curl -L "https://github.com/zyedidia/micro/releases/download/$MICRO_VERSION/micro-${MICRO_VERSION_CLEAN}-linux64.tar.gz" -o micro.tar.gz && \
    tar -xzf micro.tar.gz && \
    mv micro-${MICRO_VERSION_CLEAN}/micro /usr/local/bin/ && \
    rm -rf micro.tar.gz micro-${MICRO_VERSION_CLEAN}

# Install gron (latest from GitHub releases)
RUN GRON_VERSION=$(curl -s https://api.github.com/repos/tomnomnom/gron/releases/latest | jq -r .tag_name) && \
    GRON_VERSION_CLEAN=$(echo $GRON_VERSION | sed 's/^v//') && \
    echo "Installing gron $GRON_VERSION" && \
    curl -L "https://github.com/tomnomnom/gron/releases/download/$GRON_VERSION/gron-linux-amd64-${GRON_VERSION_CLEAN}.tgz" -o gron.tgz && \
    tar -xzf gron.tgz -C /usr/local/bin/ && \
    rm gron.tgz

# Install additional useful tools from releases
# fd (file finder)
RUN FD_VERSION=$(curl -s https://api.github.com/repos/sharkdp/fd/releases/latest | jq -r .tag_name) && \
    FD_VERSION_CLEAN=$(echo $FD_VERSION | sed 's/^v//') && \
    echo "Installing fd $FD_VERSION" && \
    curl -L "https://github.com/sharkdp/fd/releases/download/$FD_VERSION/fd_${FD_VERSION_CLEAN}_amd64.deb" -o fd.deb && \
    dpkg -i fd.deb && \
    rm fd.deb

# Install hexyl (hex viewer)
RUN HEXYL_VERSION=$(curl -s https://api.github.com/repos/sharkdp/hexyl/releases/latest | jq -r .tag_name) && \
    HEXYL_VERSION_CLEAN=$(echo $HEXYL_VERSION | sed 's/^v//') && \
    echo "Installing hexyl $HEXYL_VERSION" && \
    curl -L "https://github.com/sharkdp/hexyl/releases/download/$HEXYL_VERSION/hexyl_${HEXYL_VERSION_CLEAN}_amd64.deb" -o hexyl.deb && \
    dpkg -i hexyl.deb && \
    rm hexyl.deb

# Install hyperfine (benchmarking tool)
RUN HYPERFINE_VERSION=$(curl -s https://api.github.com/repos/sharkdp/hyperfine/releases/latest | jq -r .tag_name) && \
    HYPERFINE_VERSION_CLEAN=$(echo $HYPERFINE_VERSION | sed 's/^v//') && \
    echo "Installing hyperfine $HYPERFINE_VERSION" && \
    curl -L "https://github.com/sharkdp/hyperfine/releases/download/$HYPERFINE_VERSION/hyperfine_${HYPERFINE_VERSION_CLEAN}_amd64.deb" -o hyperfine.deb && \
    dpkg -i hyperfine.deb && \
    rm hyperfine.deb

# Install procs (process viewer)
RUN PROCS_VERSION=$(curl -s https://api.github.com/repos/dalance/procs/releases/latest | jq -r .tag_name) && \
    echo "Installing procs $PROCS_VERSION" && \
    curl -L "https://github.com/dalance/procs/releases/download/$PROCS_VERSION/procs-${PROCS_VERSION}-x86_64-linux.zip" -o procs.zip && \
    unzip procs.zip -d /usr/local/bin/ && \
    rm procs.zip

# Install tokei (code statistics)
RUN TOKEI_VERSION="v12.1.2" && \
    echo "Installing tokei $TOKEI_VERSION" && \
    curl -L "https://github.com/XAMPPRocky/tokei/releases/download/$TOKEI_VERSION/tokei-x86_64-unknown-linux-gnu.tar.gz" -o tokei.tar.gz && \
    tar -xzf tokei.tar.gz -C /usr/local/bin/ && \
    rm tokei.tar.gz

# Install bottom (system monitor)
RUN BOTTOM_VERSION=$(curl -s https://api.github.com/repos/ClementTsang/bottom/releases/latest | jq -r .tag_name) && \
    echo "Installing bottom $BOTTOM_VERSION" && \
    curl -L "https://github.com/ClementTsang/bottom/releases/download/$BOTTOM_VERSION/bottom_x86_64-unknown-linux-gnu.tar.gz" -o bottom.tar.gz && \
    tar -xzf bottom.tar.gz -C /usr/local/bin/ && \
    rm bottom.tar.gz

# Install dust (disk usage analyzer)
RUN DUST_VERSION=$(curl -s https://api.github.com/repos/bootandy/dust/releases/latest | jq -r .tag_name) && \
    echo "Installing dust $DUST_VERSION" && \
    curl -L "https://github.com/bootandy/dust/releases/download/$DUST_VERSION/dust-${DUST_VERSION}-x86_64-unknown-linux-gnu.tar.gz" -o dust.tar.gz && \
    tar -xzf dust.tar.gz && \
    mv dust-${DUST_VERSION}-x86_64-unknown-linux-gnu/dust /usr/local/bin/ && \
    rm -rf dust.tar.gz dust-${DUST_VERSION}-x86_64-unknown-linux-gnu

# Install GitLab CLI (glab)
RUN GLAB_VERSION=$(curl -s https://api.github.com/repos/profclems/glab/releases/latest | jq -r .tag_name) && \
    GLAB_VERSION_CLEAN=$(echo $GLAB_VERSION | sed 's/^v//') && \
    echo "Installing glab $GLAB_VERSION" && \
    curl -L "https://github.com/profclems/glab/releases/download/$GLAB_VERSION/glab_${GLAB_VERSION_CLEAN}_Linux_x86_64.deb" -o glab.deb && \
    dpkg -i glab.deb && \
    rm glab.deb

# Install GitHub CLI (gh)
RUN GH_VERSION=$(curl -s https://api.github.com/repos/cli/cli/releases/latest | jq -r .tag_name) && \
    GH_VERSION_CLEAN=$(echo $GH_VERSION | sed 's/^v//') && \
    echo "Installing gh $GH_VERSION" && \
    curl -L "https://github.com/cli/cli/releases/download/$GH_VERSION/gh_${GH_VERSION_CLEAN}_linux_amd64.deb" -o gh.deb && \
    dpkg -i gh.deb && \
    rm gh.deb

# Install MinIO Client (mc)
RUN echo "Installing MinIO Client (mc)" && \
    curl -L "https://dl.min.io/client/mc/release/linux-amd64/mc" -o /usr/local/bin/mc && \
    chmod +x /usr/local/bin/mc

# Set working directory and make sure orlop owns it
WORKDIR /orlop
RUN mkdir -p /orlop && chown orlop:orlop /orlop

# Copy configuration files if they exist (optional)
# COPY --chown=orlop:orlop base/bashrc /home/orlop/.bashrc
# COPY --chown=orlop:orlop base/orlop.env /orlop/orlop.env
# COPY --chown=orlop:orlop base/install.base.sh /orlop/install.base.sh

# Create default configuration
RUN echo '#!/bin/bash' > /home/orlop/.bashrc && \
    echo 'export PATH="$HOME/.local/bin:$PATH:/usr/local/bin"' >> /home/orlop/.bashrc && \
    echo 'eval "$(starship init bash)"' >> /home/orlop/.bashrc && \
    echo 'alias ls="lsd"' >> /home/orlop/.bashrc && \
    echo 'alias l="lsd -la"' >> /home/orlop/.bashrc && \
    echo 'alias cat="bat"' >> /home/orlop/.bashrc && \
    echo 'alias find="fd"' >> /home/orlop/.bashrc && \
    echo 'alias grep="rg"' >> /home/orlop/.bashrc && \
    echo 'alias ps="procs"' >> /home/orlop/.bashrc && \
    echo 'alias du="dust"' >> /home/orlop/.bashrc && \
    echo 'alias top="btm"' >> /home/orlop/.bashrc && \
    chown orlop:orlop /home/orlop/.bashrc

# Configure git to use delta as default pager
RUN git config --global core.pager delta && \
    git config --global interactive.diffFilter 'delta --color-only' && \
    git config --global delta.navigate true && \
    git config --global merge.conflictStyle zdiff3

# Create starship config directory and set preset
RUN mkdir -p /home/orlop/.config && \
    starship preset tokyo-night -o /home/orlop/.config/starship.toml && \
    chown -R orlop:orlop /home/orlop/.config

# Switch to orlop user
USER orlop

# Verify installations by showing versions
RUN echo "=== Installed CLI Tools ===" && \
    echo "ripgrep: $(rg --version | head -n1)" && \
    echo "bat: $(bat --version)" && \
    echo "delta: $(delta --version)" && \
    echo "fzf: $(fzf --version)" && \
    echo "starship: $(starship --version)" && \
    echo "gdu: $(gdu --version)" && \
    echo "lsd: $(lsd --version)" && \
    echo "micro: $(micro --version)" && \
    echo "gron: $(gron --version)" && \
    echo "fd: $(fd --version)" && \
    echo "hexyl: $(hexyl --version)" && \
    echo "hyperfine: $(hyperfine --version)" && \
    echo "procs: $(procs --version)" && \
    echo "tokei: $(tokei --version)" && \
    echo "bottom: $(btm --version)" && \
    echo "dust: $(dust --version)" && \
    echo "glab: $(glab --version)" && \
    echo "gh: $(gh --version | head -n1)" && \
    echo "mc: $(mc --version | head -n1)"

# Set the enhanced shell as entrypoint
ENTRYPOINT ["/bin/bash"]
CMD ["--login"]
