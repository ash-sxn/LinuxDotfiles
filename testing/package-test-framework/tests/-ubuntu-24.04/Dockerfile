# Template Dockerfile for testing package installation scripts
ARG DISTRO=ubuntu:22.04
FROM ubuntu:24.04

# Avoid prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Install common dependencies
RUN if command -v apt-get > /dev/null; then \
        apt-get update && apt-get install -y \
        sudo curl wget git dbus \
        python3 locales systemd; \
    elif command -v dnf > /dev/null; then \
        dnf -y update && dnf -y install \
        sudo curl wget git dbus \
        python3 systemd; \
    elif command -v pacman > /dev/null; then \
        pacman -Syu --noconfirm && pacman -S --noconfirm \
        sudo curl wget git dbus \
        python systemd procps-ng bash coreutils; \
    elif command -v zypper > /dev/null; then \
        zypper refresh && zypper -n install \
        sudo curl wget git dbus \
        python3 systemd; \
    fi

# Set up locale
RUN if command -v locale-gen > /dev/null; then \
        locale-gen en_US.UTF-8; \
    fi
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Create a test user
RUN useradd -m testuser && \
    echo "testuser ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/testuser && \
    chmod 0440 /etc/sudoers.d/testuser

# Create a directory for test scripts
WORKDIR /app

# Copy test files
COPY . /app/

# Fix permissions
RUN chown -R testuser:testuser /app && \
    chmod +x /app/*.sh

# Switch to test user
USER testuser

# Set the entry point
ENTRYPOINT ["/bin/bash"] 