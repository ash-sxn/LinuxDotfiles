#!/bin/bash

# Generic script to test package installation scripts
# Usage: ./test_package_install.sh <package_name> <install_script_path> [binary_to_check] [config_dir_to_check]

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print section header
print_section() {
    echo -e "\n${YELLOW}===================================${NC}"
    echo -e "${YELLOW}   $1${NC}"
    echo -e "${YELLOW}===================================${NC}\n"
}

# Function to print success message
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Function to print error message
print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Function to print info message
print_info() {
    echo -e "${CYAN}ℹ $1${NC}"
}

# Check parameters
if [ -z "$1" ] || [ -z "$2" ]; then
    print_error "Usage: $0 <package_name> <install_script_path> [binary_to_check] [config_dir_to_check]"
    exit 1
fi

PACKAGE_NAME=$1
INSTALL_SCRIPT=$2
BINARY_TO_CHECK=${3:-$PACKAGE_NAME}
CONFIG_DIR=${4:-"~/.config/$PACKAGE_NAME"}

# Detect distribution
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
        DISTRO_VERSION=$VERSION_ID
        DISTRO_NAME=$NAME
        
        # Determine distribution family
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
        
        print_success "Detected distribution: $DISTRO_NAME $DISTRO_VERSION ($DISTRO_FAMILY family)"
        return 0
    else
        print_error "Could not detect distribution"
        return 1
    fi
}

# Function to check if a package is installed
is_package_installed() {
    PACKAGE=$1
    
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
        
        case $DISTRO in
            ubuntu|debian|linuxmint|pop|elementary|zorin)
                dpkg -l | grep -q $PACKAGE
                return $?
                ;;
            fedora|rhel|centos|rocky|alma)
                rpm -q $PACKAGE > /dev/null 2>&1
                return $?
                ;;
            arch|manjaro|endeavouros|artix|garuda)
                pacman -Q $PACKAGE > /dev/null 2>&1
                return $?
                ;;
            opensuse*)
                rpm -q $PACKAGE > /dev/null 2>&1
                return $?
                ;;
            *)
                echo "Unsupported distribution for package check: $DISTRO"
                return 1
                ;;
        esac
    else
        echo "Cannot determine distribution"
        return 1
    fi
}

# Function to check if a binary is in PATH
is_binary_in_path() {
    BINARY=$1
    if command -v $BINARY &> /dev/null; then
        print_success "Binary '$BINARY' is in PATH"
        return 0
    else
        print_error "Binary '$BINARY' is not in PATH"
        return 1
    fi
}

# Function to check if a configuration directory exists
check_config_dir() {
    DIR=$1
    EXPANDED_DIR=$(eval echo $DIR)
    
    if [ -d "$EXPANDED_DIR" ]; then
        print_success "Configuration directory '$DIR' exists"
        return 0
    else
        print_error "Configuration directory '$DIR' does not exist"
        return 1
    fi
}

# Main test function
run_tests() {
    print_section "Testing installation of $PACKAGE_NAME"
    
    # Record start time
    START_TIME=$(date +%s)
    
    # Detect distribution
    detect_distro
    
    # Test 1: Make sure the script exists and is executable
    print_section "Test 1: Checking install script"
    if [ -f "$INSTALL_SCRIPT" ]; then
        print_success "Install script exists at $INSTALL_SCRIPT"
        
        if [ -x "$INSTALL_SCRIPT" ]; then
            print_success "Install script is executable"
        else
            print_info "Making install script executable"
            chmod +x "$INSTALL_SCRIPT"
        fi
    else
        print_error "Install script does not exist at $INSTALL_SCRIPT"
        return 1
    fi
    
    # Test 2: Run the installation script
    print_section "Test 2: Running installation script"
    # Using 'yes' to automatically answer 'y' to all prompts
    yes | $INSTALL_SCRIPT || \
    {
        print_error "Installation script failed"
        return 1
    }
    print_success "Installation script completed"
    
    # Test 3: Check if the binary is in PATH
    print_section "Test 3: Checking if binary is installed"
    is_binary_in_path $BINARY_TO_CHECK || FAILED=1
    
    # Test 4: Check if package is installed using package manager
    # This is a fallback test in case the binary check fails
    print_section "Test 4: Checking if package is installed"
    if is_package_installed $PACKAGE_NAME; then
        print_success "Package '$PACKAGE_NAME' is installed according to package manager"
    else
        print_info "Package '$PACKAGE_NAME' not found in package manager (may be installed from source or snap/flatpak)"
    fi
    
    # Test 5: Check if configuration directory exists
    print_section "Test 5: Checking configuration"
    check_config_dir $CONFIG_DIR || print_info "Configuration directory check failed (may not be created yet)"
    
    # Record end time and calculate duration
    END_TIME=$(date +%s)
    DURATION=$((END_TIME - START_TIME))
    
    # Print summary
    print_section "Test Summary"
    if [ "$FAILED" == "1" ]; then
        print_error "Some tests failed"
        echo -e "Test completed in ${RED}$DURATION seconds${NC} with errors."
        return 1
    else
        print_success "All tests passed"
        echo -e "Test completed in ${GREEN}$DURATION seconds${NC} successfully."
        return 0
    fi
}

# Run the tests
run_tests
exit $? 