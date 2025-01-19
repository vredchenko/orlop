# Start with Ubuntu minimal base image
FROM ubuntu:latest

# TODO: recycle https://glab.tinkerlab.dev/sofias-pets/orlop-deck/-/blob/dev/Dockerfile?ref_type=heads

# Print architecture info during build
#RUN uname -a

# Install sudo
ENV DEBIAN_FRONTEND=noninteractive

# Update and install sudo with more detailed error output
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
    sudo \
    python3 \
    python3-pip \
    curl \
    wget \
    unzip \
    build-essential \
    pkg-config \
    git \
    bash-completion \
    lsd gdu micro htop \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean && \
    mkdir /orlop


# Create orlop user with sudo privileges
RUN useradd -m -s /bin/bash orlop && \
  echo "orlop ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/orlop

# Set up enhanced shell environment
COPY --chown=orlop:orlop base/bashrc /home/orlop/.bashrc

# Set working directory and make sure orlop owns it
WORKDIR /orlop
RUN chown orlop:orlop /orlop
    # Ensure orlop can access Rust and Cargo
#    chown -R orlop:orlop ${RUSTUP_HOME} ${CARGO_HOME}

# Switch to orlop user
USER orlop

COPY --chown=orlop:orlop base/orlop.env orlop.env
COPY --chown=orlop:orlop base/install.base.sh install.base.sh

# Set the more capable interactive shell as entrypoint
ENTRYPOINT ["/bin/bash"]
CMD ["--login"]
