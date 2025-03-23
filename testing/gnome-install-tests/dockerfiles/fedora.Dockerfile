# Fedora Dockerfile for testing GNOME installation scripts
FROM fedora:38

# Install dependencies for script testing
RUN dnf -y update && dnf install -y \
    sudo \
    curl \
    wget \
    git \
    dbus \
    dbus-x11 \
    procps-ng \
    bash \
    systemd \
    coreutils \
    python3 \
    langpacks-en \
    glibc-langpack-en \
    && dnf clean all

# Set up locale
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Create a test user with sudo access
RUN useradd -m testuser -s /bin/bash && \
    echo "testuser:testpassword" | chpasswd && \
    usermod -aG wheel testuser && \
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