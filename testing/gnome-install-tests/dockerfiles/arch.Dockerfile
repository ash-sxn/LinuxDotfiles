# Arch Linux Dockerfile for testing GNOME installation scripts
FROM archlinux:latest

# Install dependencies for script testing
RUN pacman -Syu --noconfirm && pacman -S --noconfirm \
    sudo \
    curl \
    wget \
    git \
    dbus \
    procps-ng \
    bash \
    systemd \
    coreutils \
    python \
    && pacman -Scc --noconfirm

# Create a test user with sudo access
RUN useradd -m testuser -s /bin/bash && \
    echo "testuser:testpassword" | chpasswd && \
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