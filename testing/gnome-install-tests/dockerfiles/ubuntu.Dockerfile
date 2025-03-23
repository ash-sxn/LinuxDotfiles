# Ubuntu Dockerfile for testing GNOME installation scripts
FROM ubuntu:22.04

# Avoid prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies for script testing
RUN apt-get update && apt-get install -y \
    sudo \
    curl \
    wget \
    git \
    dbus \
    dbus-x11 \
    procps \
    software-properties-common \
    bash \
    systemd \
    systemd-sysv \
    coreutils \
    apt-utils \
    tzdata \
    locales \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# Set up locale
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Create a test user with sudo access
RUN useradd -m testuser -s /bin/bash && \
    echo "testuser:testpassword" | chpasswd && \
    adduser testuser sudo && \
    echo "testuser ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/testuser

# Set working directory
WORKDIR /home/testuser

# Copy test scripts
COPY scripts/ /home/testuser/scripts/
COPY tests/ /home/testuser/tests/
COPY ../install_gnome.sh /home/testuser/
COPY ../setup_gnome_complete.sh /home/testuser/

# Fix permissions
RUN chown -R testuser:testuser /home/testuser

# Entrypoint for testing
USER testuser
ENTRYPOINT ["/bin/bash"] 