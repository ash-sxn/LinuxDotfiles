#!/bin/bash

# Docker installation script

# Package information
PACKAGE_NAME="Docker"
PACKAGE_DESCRIPTION="Platform for developing, shipping, and running applications in containers"
PACKAGE_DOTFILES_DIR="$HOME/.docker"

# Docker Compose version to install
DOCKER_COMPOSE_VERSION="v2.26.0"

# Detect the Linux distribution
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
        VERSION_ID=$VERSION_ID
        
        # Handle distribution families
        case $DISTRO in
            ubuntu|debian|linuxmint|pop|elementary|zorin)
                DISTRO_FAMILY="debian"
                ;;
            fedora|rhel|centos|rocky|alma)
                DISTRO_FAMILY="redhat"
                ;;
            arch|manjaro|endeavouros|artix|garuda)
                DISTRO_FAMILY="arch"
                ;;
            opensuse*)
                DISTRO_FAMILY="suse"
                ;;
            *)
                DISTRO_FAMILY="unknown"
                ;;
        esac
    else
        DISTRO="unknown"
        DISTRO_FAMILY="unknown"
        VERSION_ID="unknown"
    fi
    
    echo "Detected distribution: $DISTRO (Family: $DISTRO_FAMILY, Version: $VERSION_ID)"
}

# Check if Docker is already installed
is_docker_installed() {
    if command -v docker &> /dev/null; then
        return 0  # true, package is installed
    else
        return 1  # false, package is not installed
    fi
}

# Check if Docker Compose is already installed
is_docker_compose_installed() {
    if command -v docker-compose &> /dev/null || command -v docker compose &> /dev/null; then
        return 0  # true, package is installed
    else
        return 1  # false, package is not installed
    fi
}

# Get the latest Docker Compose version
get_latest_docker_compose_version() {
    echo "Checking for the latest Docker Compose version..."
    if command -v curl &> /dev/null; then
        LATEST_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep -o '"tag_name": "[^"]*' | cut -d'"' -f4)
        if [ -n "$LATEST_VERSION" ]; then
            DOCKER_COMPOSE_VERSION=$LATEST_VERSION
            echo "Latest Docker Compose version: $DOCKER_COMPOSE_VERSION"
        else
            echo "Could not determine the latest version, using default: $DOCKER_COMPOSE_VERSION"
        fi
    else
        echo "curl not installed, using default Docker Compose version: $DOCKER_COMPOSE_VERSION"
    fi
}

# Install Docker on Debian-based systems
install_docker_debian() {
    echo "Installing Docker on Debian-based system..."
    
    # Update package index
    sudo apt update
    
    # Install prerequisites
    sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release
    
    # Remove any old Docker installations
    sudo apt remove -y docker docker-engine docker.io containerd runc || true
    
    # Add Docker's official GPG key
    curl -fsSL https://download.docker.com/linux/$DISTRO/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    
    # Add Docker repository
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/$DISTRO $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Update package index again
    sudo apt update
    
    # Install Docker Engine
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    
    return $?
}

# Install Docker on Red Hat-based systems
install_docker_redhat() {
    echo "Installing Docker on Red Hat-based system..."
    
    # Remove any old Docker installations
    sudo yum remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine podman runc || true
    
    # Install prerequisites
    if [ "$DISTRO" = "fedora" ]; then
        sudo dnf -y install dnf-plugins-core
        sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
        sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    else
        # For RHEL, CentOS, etc.
        sudo yum install -y yum-utils
        sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
        sudo yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    fi
    
    return $?
}

# Install Docker on Arch-based systems
install_docker_arch() {
    echo "Installing Docker on Arch-based system..."
    
    if command -v yay &> /dev/null; then
        yay -S --noconfirm docker docker-compose docker-buildx
    elif command -v paru &> /dev/null; then
        paru -S --noconfirm docker docker-compose docker-buildx
    else
        sudo pacman -S --noconfirm docker docker-compose docker-buildx
    fi
    
    return $?
}

# Install Docker on SUSE-based systems
install_docker_suse() {
    echo "Installing Docker on SUSE-based system..."
    
    # Add Docker repository
    sudo zypper addrepo https://download.docker.com/linux/sles/docker-ce.repo
    
    # Refresh repositories
    sudo zypper refresh
    
    # Install Docker
    sudo zypper install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin docker-buildx-plugin
    
    return $?
}

# Install Docker using the convenience script (generic method)
install_docker_generic() {
    echo "Installing Docker using the convenience script..."
    
    # Download and run the Docker installation script
    curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
    sudo sh /tmp/get-docker.sh
    
    # Clean up
    rm /tmp/get-docker.sh
    
    return $?
}

# Install Docker Compose v2 binary plugin
install_docker_compose_plugin() {
    echo "Installing Docker Compose v2 as a plugin..."
    
    if [ -z "$DOCKER_COMPOSE_VERSION" ]; then
        get_latest_docker_compose_version
    fi
    
    # Check if docker compose plugin already exists
    if docker compose version &> /dev/null; then
        echo "Docker Compose plugin is already installed."
        return 0
    fi
    
    # Create the CLI plugins directory if it doesn't exist
    mkdir -p ~/.docker/cli-plugins
    
    # Download the appropriate Docker Compose binary
    ARCH=$(uname -m)
    case $ARCH in
        x86_64)
            COMPOSE_ARCH="x86_64"
            ;;
        aarch64|arm64)
            COMPOSE_ARCH="aarch64"
            ;;
        *)
            echo "Architecture $ARCH not supported for Docker Compose installation."
            return 1
            ;;
    esac
    
    COMPOSE_URL="https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-linux-${COMPOSE_ARCH}"
    echo "Downloading Docker Compose from: $COMPOSE_URL"
    
    curl -SL "$COMPOSE_URL" -o ~/.docker/cli-plugins/docker-compose
    chmod +x ~/.docker/cli-plugins/docker-compose
    
    # Verify installation
    if docker compose version &> /dev/null; then
        echo "Docker Compose plugin installed successfully!"
        docker compose version
        return 0
    else
        echo "Failed to install Docker Compose plugin."
        return 1
    fi
}

# Configure Docker to start on boot
configure_docker_service() {
    echo "Configuring Docker service..."
    
    # Enable Docker service to start on boot
    sudo systemctl enable docker.service
    sudo systemctl enable containerd.service
    
    # Start Docker service if not already running
    if ! systemctl is-active --quiet docker; then
        sudo systemctl start docker.service
    fi
    
    echo "Docker service configured to start automatically on boot."
}

# Add user to the docker group
add_user_to_docker_group() {
    echo "Adding user to the docker group for rootless operation..."
    
    # Create the docker group if it doesn't exist
    sudo groupadd -f docker
    
    # Add the current user to the docker group
    sudo usermod -aG docker $USER
    
    echo "User '$USER' added to the docker group."
    echo "NOTE: You may need to log out and log back in for the group changes to take effect."
}

# Install Docker credential helper
install_credential_helper() {
    echo "Would you like to install Docker credential helper? This helps securely store Docker registry credentials. (y/N): "
    read -r install_cred_helper
    
    if [[ "$install_cred_helper" =~ ^[Yy]$ ]]; then
        case $DISTRO_FAMILY in
            debian)
                sudo apt install -y pass gnupg2
                ;;
            redhat)
                if [ "$DISTRO" = "fedora" ]; then
                    sudo dnf install -y pass gnupg2
                else
                    sudo yum install -y pass gnupg2
                fi
                ;;
            arch)
                sudo pacman -S --noconfirm pass gnupg
                ;;
            suse)
                sudo zypper install -y pass gnupg2
                ;;
            *)
                echo "Skipping credential helper installation for unsupported distribution."
                return
                ;;
        esac
        
        mkdir -p ~/.docker
        
        # Create Docker config if it doesn't exist
        if [ ! -f ~/.docker/config.json ]; then
            echo '{}' > ~/.docker/config.json
        fi
        
        # Configure credential helper
        if command -v jq &> /dev/null; then
            # Use jq to properly update the JSON file
            jq '.credsStore = "pass"' ~/.docker/config.json > ~/.docker/config.json.tmp
            mv ~/.docker/config.json.tmp ~/.docker/config.json
        else
            # Fallback to simple method if jq is not available
            if ! grep -q "credsStore" ~/.docker/config.json; then
                # Create backup
                cp ~/.docker/config.json ~/.docker/config.json.bak
                # Simple replace for empty config
                if [ "$(cat ~/.docker/config.json)" = "{}" ]; then
                    echo '{"credsStore": "pass"}' > ~/.docker/config.json
                else
                    # This is a very simplified approach, may not work for complex configs
                    sed -i 's/\({.*\)}/\1, "credsStore": "pass"}/' ~/.docker/config.json
                fi
            fi
        fi
        
        echo "Docker credential helper installed and configured."
    else
        echo "Skipping credential helper installation."
    fi
}

# Setup basic configuration
setup_basic_config() {
    echo "Setting up basic Docker configuration..."
    
    # Create Docker config directory if it doesn't exist
    mkdir -p ~/.docker
    
    # Create a basic daemon.json file with some useful defaults
    if [ ! -f /etc/docker/daemon.json ]; then
        echo "Creating daemon.json with recommended settings..."
        
        # Create a temporary file
        cat > /tmp/daemon.json << EOL
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "default-address-pools": [
    {"base": "172.17.0.0/16", "size": 24},
    {"base": "172.18.0.0/16", "size": 24},
    {"base": "172.19.0.0/16", "size": 24}
  ],
  "experimental": false,
  "features": {
    "buildkit": true
  }
}
EOL
        
        # Move the file to the correct location
        sudo mkdir -p /etc/docker
        sudo mv /tmp/daemon.json /etc/docker/
        
        echo "Basic daemon.json configuration created."
    else
        echo "Docker daemon configuration already exists, skipping."
    fi
    
    # Create or update ~/.docker/config.json with useful defaults
    if [ ! -f ~/.docker/config.json ]; then
        echo "Creating user config.json with recommended settings..."
        
        cat > ~/.docker/config.json << EOL
{
  "detachKeys": "ctrl-e,e",
  "experimental": "disabled",
  "features": {
    "buildkit": true
  }
}
EOL
        
        echo "Basic user config.json created."
    else
        echo "Docker user configuration already exists, skipping."
    fi
}

# Setup configuration
setup_config() {
    echo "Setting up Docker configuration..."
    
    # Add current user to the docker group
    read -p "Would you like to add your user to the docker group? This allows running Docker without sudo (recommended) (Y/n): " add_user_choice
    if [[ ! "$add_user_choice" =~ ^[Nn]$ ]]; then
        add_user_to_docker_group
    fi
    
    # Configure Docker credential helper
    install_credential_helper
    
    # Setup basic configuration
    read -p "Would you like to set up basic Docker configuration files with recommended settings? (Y/n): " basic_config_choice
    if [[ ! "$basic_config_choice" =~ ^[Nn]$ ]]; then
        setup_basic_config
    fi
    
    # Restart Docker service to apply changes
    sudo systemctl restart docker.service
    
    echo "Docker has been configured successfully!"
}

# Verify Docker installation by running a test container
verify_docker_installation() {
    echo "Verifying Docker installation..."
    
    # Run hello-world container
    docker run --rm hello-world
    
    # Check the exit status
    if [ $? -eq 0 ]; then
        echo "Docker is working correctly!"
        return 0
    else
        echo "Docker verification failed. There might be an issue with the installation."
        return 1
    fi
}

# Main installation function
install_package() {
    echo "Installing $PACKAGE_NAME..."
    
    # Check if Docker is already installed
    if is_docker_installed; then
        docker_version=$(docker --version)
        echo "Docker is already installed: $docker_version"
        read -p "Do you want to reinstall it? (y/N): " reinstall_choice
        
        if [[ ! "$reinstall_choice" =~ ^[Yy]$ ]]; then
            echo "Skipping Docker installation."
            read -p "Do you want to update the Docker configuration? (y/N): " config_choice
            if [[ "$config_choice" =~ ^[Yy]$ ]]; then
                setup_config
            fi
            return
        fi
    fi
    
    # Install Docker based on distribution family
    case $DISTRO_FAMILY in
        debian)
            install_docker_debian
            ;;
        redhat)
            install_docker_redhat
            ;;
        arch)
            install_docker_arch
            ;;
        suse)
            install_docker_suse
            ;;
        *)
            echo "Unsupported distribution for direct installation."
            echo "Trying generic installation method..."
            install_docker_generic
            ;;
    esac
    
    # Check if Docker was installed successfully
    if ! is_docker_installed; then
        echo "Docker installation failed."
        exit 1
    fi
    
    # Configure Docker service
    configure_docker_service
    
    # Install Docker Compose if not installed by the package
    if ! command -v docker compose &> /dev/null; then
        install_docker_compose_plugin
    fi
    
    # Setup Docker configuration
    read -p "Do you want to set up Docker configuration? (Y/n): " config_choice
    if [[ ! "$config_choice" =~ ^[Nn]$ ]]; then
        setup_config
    fi
    
    # Verify Docker installation
    read -p "Do you want to verify the Docker installation by running a test container? (Y/n): " verify_choice
    if [[ ! "$verify_choice" =~ ^[Nn]$ ]]; then
        verify_docker_installation
    fi
    
    echo "$PACKAGE_NAME has been successfully installed!"
}

# Uninstall package
uninstall_package() {
    echo "Uninstalling $PACKAGE_NAME..."
    
    if ! is_docker_installed; then
        echo "Docker is not installed."
        return
    fi
    
    read -p "Are you sure you want to uninstall Docker? This will remove all Docker containers, images, volumes, and networks. (y/N): " choice
    if [[ "$choice" =~ ^[Yy]$ ]]; then
        echo "Proceeding with Docker uninstallation..."
        
        # Stop Docker service
        sudo systemctl stop docker.service containerd.service
        
        # Disable services
        sudo systemctl disable docker.service containerd.service
        
        # Remove Docker based on distribution family
        case $DISTRO_FAMILY in
            debian)
                sudo apt purge -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
                sudo apt autoremove -y
                ;;
            redhat)
                if [ "$DISTRO" = "fedora" ]; then
                    sudo dnf remove -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
                else
                    sudo yum remove -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
                fi
                ;;
            arch)
                sudo pacman -Rs --noconfirm docker docker-compose docker-buildx
                ;;
            suse)
                sudo zypper remove -y docker-ce docker-ce-cli containerd.io docker-compose-plugin docker-buildx-plugin
                ;;
            *)
                echo "Manual uninstallation required for your distribution."
                echo "Please check Docker documentation for uninstallation instructions."
                ;;
        esac
        
        # Remove Docker Compose plugin
        rm -f ~/.docker/cli-plugins/docker-compose
        
        # Ask about removing Docker data
        read -p "Do you want to remove all Docker data (images, containers, volumes, etc.)? (y/N): " remove_data_choice
        if [[ "$remove_data_choice" =~ ^[Yy]$ ]]; then
            echo "Removing Docker data directories..."
            
            # Remove Docker data directories
            sudo rm -rf /var/lib/docker
            sudo rm -rf /var/lib/containerd
            
            # Remove Docker configuration
            sudo rm -rf /etc/docker
            
            # Remove user Docker configuration, but back it up first
            if [ -d ~/.docker ]; then
                mkdir -p ~/.docker-backup-$(date +%Y%m%d-%H%M%S)
                cp -r ~/.docker/* ~/.docker-backup-$(date +%Y%m%d-%H%M%S)/ 2>/dev/null || true
                rm -rf ~/.docker
            fi
            
            echo "All Docker data has been removed."
        else
            echo "Docker data preserved. You can remove it manually by deleting /var/lib/docker and /var/lib/containerd."
        fi
        
        echo "Docker has been uninstalled."
    else
        echo "Uninstallation cancelled."
    fi
}

# Parse command line arguments
if [ "$1" == "uninstall" ]; then
    detect_distro
    uninstall_package
else
    detect_distro
    install_package
fi 