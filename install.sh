#!/bin/bash

# LinuxDotfiles - Installation Script
# Main script to install selected packages and configure dotfiles

# Colors for better UI
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Log file
LOG_FILE="$SCRIPT_DIR/installation.log"

# Function to log messages
log() {
    local message="$1"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo -e "[$timestamp] $message" | tee -a "$LOG_FILE"
}

# Function to print colored section headers
print_section() {
    echo -e "${BLUE}==================================================================${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}==================================================================${NC}"
}

# Function to print colored status messages
print_status() {
    case "$2" in
        "info")
            echo -e "${CYAN}[INFO]${NC} $1"
            ;;
        "success")
            echo -e "${GREEN}[SUCCESS]${NC} $1"
            ;;
        "warning")
            echo -e "${YELLOW}[WARNING]${NC} $1"
            ;;
        "error")
            echo -e "${RED}[ERROR]${NC} $1"
            ;;
        *)
            echo -e "$1"
            ;;
    esac
}

# Function to detect the Linux distribution
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
        DISTRO_VERSION=$VERSION_ID
        DISTRO_NAME=$NAME
        
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
        DISTRO_VERSION="unknown"
        DISTRO_NAME="Unknown Distribution"
    fi
    
    print_status "Detected distribution: $DISTRO_NAME $DISTRO_VERSION (Family: $DISTRO_FAMILY)" "info"
    log "Detected distribution: $DISTRO_NAME $DISTRO_VERSION (Family: $DISTRO_FAMILY)"
}

# Function to check dependencies
check_dependencies() {
    print_section "Checking Dependencies"
    
    local missing_deps=()
    local required_deps=("curl" "wget" "git")
    
    for dep in "${required_deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing_deps+=("$dep")
        fi
    done
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        print_status "The following dependencies are missing: ${missing_deps[*]}" "warning"
        read -p "Would you like to install the missing dependencies? (y/N): " install_deps
        
        if [[ $install_deps =~ ^[Yy]$ ]]; then
            case $DISTRO_FAMILY in
                debian)
                    sudo apt update
                    sudo apt install -y "${missing_deps[@]}"
                    ;;
                redhat)
                    sudo dnf install -y "${missing_deps[@]}"
                    ;;
                arch)
                    sudo pacman -S --noconfirm "${missing_deps[@]}"
                    ;;
                suse)
                    sudo zypper install -y "${missing_deps[@]}"
                    ;;
                *)
                    print_status "Unsupported distribution for automatic dependency installation." "error"
                    print_status "Please install the following dependencies manually: ${missing_deps[*]}" "error"
                    exit 1
                    ;;
            esac
        else
            print_status "Dependencies are required for this script to work properly." "error"
            exit 1
        fi
    else
        print_status "All required dependencies are installed." "success"
    fi
}

# Function to discover available packages
discover_packages() {
    print_section "Discovering Available Packages"
    
    # Define package categories and their paths
    declare -A package_categories
    package_categories=(
        ["Terminal"]="packages/terminal"
        ["Development"]="packages/development"
        ["Browsers"]="packages/browsers"
        ["Productivity"]="packages/productivity"
        ["Multimedia"]="packages/multimedia"
        ["System"]="packages/system"
    )
    
    # Reset package arrays
    declare -A available_packages
    declare -A package_categories_map
    
    # Discover packages in each category
    for category in "${!package_categories[@]}"; do
        local category_path="${package_categories[$category]}"
        
        if [ -d "$SCRIPT_DIR/$category_path" ]; then
            print_status "Checking category: $category" "info"
            
            # Find all installation scripts in the category directory
            for package_script in "$SCRIPT_DIR/$category_path"/*/*.sh; do
                if [ -f "$package_script" ]; then
                    # Extract package name from directory name
                    local package_dir=$(dirname "$package_script")
                    local package_name=$(basename "$package_dir")
                    
                    # Read package description if available
                    local description=""
                    if [ -f "$package_dir/description.txt" ]; then
                        description=$(head -n 1 "$package_dir/description.txt")
                    else
                        # Try to extract from the script file
                        description=$(grep "PACKAGE_DESCRIPTION" "$package_script" | cut -d'"' -f2 || echo "No description available")
                    fi
                    
                    # Add to available packages
                    available_packages["$package_name"]="$description"
                    package_categories_map["$package_name"]="$category"
                    
                    print_status "Found package: $package_name - $description" "info"
                fi
            done
        else
            print_status "Category directory not found: $category_path" "warning"
        fi
    done
    
    if [ ${#available_packages[@]} -eq 0 ]; then
        print_status "No packages found. Please make sure package directories are properly set up." "error"
        exit 1
    else
        print_status "Found ${#available_packages[@]} packages across ${#package_categories[@]} categories." "success"
    fi
}

# Function to display the package selection menu
select_packages() {
    print_section "Select Packages to Install"
    
    declare -A selected_packages
    declare -A category_packages
    
    # Organize packages by category for display
    for package in "${!available_packages[@]}"; do
        local category="${package_categories_map[$package]}"
        if [ -z "${category_packages[$category]}" ]; then
            category_packages[$category]="$package"
        else
            category_packages[$category]="${category_packages[$category]} $package"
        fi
    done
    
    # Display and select packages by category
    for category in "${!package_categories[@]}"; do
        if [ -n "${category_packages[$category]}" ]; then
            echo -e "\n${MAGENTA}${category}${NC}"
            echo -e "${MAGENTA}$(printf '=%.0s' $(seq 1 ${#category}))${NC}"
            
            for package in ${category_packages[$category]}; do
                local description="${available_packages[$package]}"
                read -p "Install $package ($description)? (y/N): " install_choice
                
                if [[ $install_choice =~ ^[Yy]$ ]]; then
                    selected_packages["$package"]=1
                    print_status "Selected: $package" "success"
                else
                    print_status "Skipped: $package" "info"
                fi
            done
        fi
    done
    
    # Confirm selection
    if [ ${#selected_packages[@]} -eq 0 ]; then
        print_status "No packages selected." "warning"
        read -p "Do you want to continue without installing any packages? (y/N): " continue_choice
        
        if [[ ! $continue_choice =~ ^[Yy]$ ]]; then
            print_status "Installation cancelled." "info"
            exit 0
        fi
    else
        echo -e "\n${GREEN}Selected packages:${NC}"
        for package in "${!selected_packages[@]}"; do
            echo -e "  - $package (${package_categories_map[$package]})"
        done
        
        read -p "Do you want to proceed with the installation? (Y/n): " confirm_choice
        
        if [[ $confirm_choice =~ ^[Nn]$ ]]; then
            print_status "Installation cancelled." "info"
            exit 0
        fi
    fi
}

# Function to install selected packages
install_selected_packages() {
    print_section "Installing Selected Packages"
    
    local install_successes=0
    local install_failures=0
    
    for package in "${!selected_packages[@]}"; do
        local category="${package_categories_map[$package]}"
        local package_path="$SCRIPT_DIR/packages/${category,,}/$package"
        local install_script="$package_path/install.sh"
        
        if [ -f "$install_script" ]; then
            print_status "Installing $package..." "info"
            log "Starting installation of $package"
            
            # Make the script executable if it's not already
            chmod +x "$install_script"
            
            # Run the installation script
            if bash "$install_script"; then
                print_status "Successfully installed $package." "success"
                log "Successfully installed $package"
                ((install_successes++))
            else
                print_status "Failed to install $package." "error"
                log "Failed to install $package with exit code $?"
                ((install_failures++))
            fi
        else
            print_status "Installation script not found for $package: $install_script" "error"
            log "Installation script not found for $package: $install_script"
            ((install_failures++))
        fi
    done
    
    # Print installation summary
    print_section "Installation Summary"
    print_status "Successfully installed: $install_successes packages" "success"
    
    if [ $install_failures -gt 0 ]; then
        print_status "Failed installations: $install_failures packages" "error"
        print_status "Check the log file for details: $LOG_FILE" "info"
    fi
}

# Function to setup dotfiles
setup_dotfiles() {
    print_section "Setting Up Dotfiles"
    
    read -p "Would you like to set up configuration files (dotfiles)? (y/N): " setup_config_choice
    
    if [[ $setup_config_choice =~ ^[Yy]$ ]]; then
        print_status "Setting up dotfiles..." "info"
        
        # Loop through installed packages and set up their configurations
        for package in "${!selected_packages[@]}"; do
            local category="${package_categories_map[$package]}"
            local package_path="$SCRIPT_DIR/packages/${category,,}/$package"
            local config_script="$package_path/config_setup.sh"
            
            if [ -f "$config_script" ]; then
                print_status "Setting up configuration for $package..." "info"
                chmod +x "$config_script"
                
                if bash "$config_script"; then
                    print_status "Successfully set up configuration for $package." "success"
                    log "Successfully set up configuration for $package"
                else
                    print_status "Failed to set up configuration for $package." "error"
                    log "Failed to set up configuration for $package with exit code $?"
                fi
            else
                # Check if there's a config directory without a script
                local config_dir="$package_path/config"
                if [ -d "$config_dir" ]; then
                    print_status "Found configuration directory for $package but no setup script." "warning"
                    print_status "You may need to manually set up the configuration files in: $config_dir" "info"
                    log "Manual configuration needed for $package: $config_dir"
                fi
            fi
        done
        
        print_status "Dotfiles setup completed." "success"
    else
        print_status "Skipping dotfiles setup." "info"
    fi
}

# Main function
main() {
    print_section "Linux Dotfiles Installation Script"
    log "Starting installation script"
    
    # Create a fresh log file
    echo "# Installation Log - $(date)" > "$LOG_FILE"
    
    # Detect the Linux distribution
    detect_distro
    
    # Check dependencies
    check_dependencies
    
    # Discover available packages
    discover_packages
    
    # Let the user select packages to install
    select_packages
    
    # Install the selected packages
    install_selected_packages
    
    # Setup dotfiles
    setup_dotfiles
    
    print_section "Installation Complete"
    print_status "Thank you for using LinuxDotfiles!" "success"
    print_status "Log file has been saved to: $LOG_FILE" "info"
    
    log "Installation script completed"
}

# Run the main function
main 