# Start with Ubuntu minimal base image
FROM ubuntu:latest

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Update package list and install minimal Python setup and build essentials
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    curl \
    unzip \
    sudo \
    build-essential \
    pkg-config \
    vim \
    git \
    bash-completion \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Set Python3 as default python
RUN ln -s /usr/bin/python3 /usr/bin/python

# Create orlop user with sudo privileges
RUN useradd -m -s /bin/bash orlop && \
    echo "orlop ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/orlop

# Install Go
RUN curl -L https://go.dev/dl/go1.22.0.linux-amd64.tar.gz | tar -C /usr/local -xzf -
ENV PATH="/usr/local/go/bin:${PATH}"

# Install Rust (for orlop user)
ENV RUSTUP_HOME=/usr/local/rustup
ENV CARGO_HOME=/usr/local/cargo
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/usr/local/cargo/bin:${PATH}"

# Install latest stable Bun
RUN curl -fsSL https://bun.sh/install | bash && \
    # Make bun available for orlop user too
    cp -r /root/.bun /home/orlop/.bun && \
    chown -R orlop:orlop /home/orlop/.bun

# Add Bun to PATH for all users
ENV PATH="/home/orlop/.bun/bin:${PATH}"

# Set up enhanced shell environment
COPY --chown=orlop:orlop <<-"EOF" /home/orlop/.bashrc
# Enhanced bash configuration
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

# History settings
HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoreboth
shopt -s histappend

# Better prompt with git info if available
if [ -f /etc/bash_completion.d/git-prompt ]; then
    . /etc/bash_completion.d/git-prompt
    PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[33m\]$(__git_ps1 " (%s)")\[\033[00m\]\$ '
else
    PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
fi

# Useful aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'

# Environment variables
export EDITOR=vim
export VISUAL=vim
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Add local bin to PATH
export PATH="$HOME/.local/bin:$PATH"
EOF

# Set working directory and make sure orlop owns it
WORKDIR /orlop
RUN chown orlop:orlop /orlop && \
    # Ensure orlop can access Rust and Cargo
    chown -R orlop:orlop ${RUSTUP_HOME} ${CARGO_HOME}

# Switch to orlop user
USER orlop

# Set the more capable interactive shell as entrypoint
ENTRYPOINT ["/bin/bash"]
CMD ["--login"]