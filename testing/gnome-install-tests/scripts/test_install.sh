#!/bin/bash

# Script to test GNOME installation in a Docker container

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
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

# Function to check if a package is installed
is_package_installed() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
        
        case $DISTRO in
            ubuntu|debian|linuxmint|pop|elementary|zorin)
                dpkg -l | grep -q $1
                return $?
                ;;
            fedora|rhel|centos|rocky|alma)
                rpm -q $1 > /dev/null
                return $?
                ;;
            arch|manjaro|endeavouros|artix|garuda)
                pacman -Q $1 > /dev/null 2>&1
                return $?
                ;;
            opensuse*)
                rpm -q $1 > /dev/null
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

# Function to check if a service is enabled
is_service_enabled() {
    if command -v systemctl &> /dev/null; then
        systemctl is-enabled $1 > /dev/null 2>&1
        return $?
    else
        echo "systemctl not available, cannot check service status"
        return 1
    fi
}

# Function to check for the presence of configuration files
check_config_files() {
    CONFIG_DIR=$1
    if [ -d "$CONFIG_DIR" ]; then
        print_success "Configuration directory $CONFIG_DIR exists"
        return 0
    else
        print_error "Configuration directory $CONFIG_DIR does not exist"
        return 1
    fi
}

# Main test function
run_tests() {
    print_section "Starting GNOME Installation Tests"
    
    # Record start time
    START_TIME=$(date +%s)
    
    # Detect distribution
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        print_success "Testing on distribution: $NAME $VERSION_ID"
    else
        print_error "Cannot determine distribution"
        exit 1
    fi
    
    # Test 1: Run the installation script with non-interactive mode
    print_section "Test 1: Running GNOME Installation Script"
    # We'll use a modified command that simulates user input
    chmod +x ./install_gnome.sh
    # Using 'yes' to automatically answer 'y' to all prompts
    yes | ./install_gnome.sh || \
    {
        print_error "Installation script failed"
        return 1
    }
    print_success "Installation script completed"
    
    # Test 2: Check if key GNOME packages are installed
    print_section "Test 2: Checking if GNOME packages are installed"
    PACKAGES=("gnome-shell" "gnome-session" "gnome-terminal" "gnome-control-center")
    
    for package in "${PACKAGES[@]}"; do
        if is_package_installed $package; then
            print_success "$package is installed"
        else
            print_error "$package is not installed"
            FAILED=1
        fi
    done
    
    # Test 3: Check if GDM service is enabled (if systemd is available)
    print_section "Test 3: Checking GDM service"
    if command -v systemctl &> /dev/null; then
        if is_service_enabled gdm; then
            print_success "GDM service is enabled"
        else
            print_error "GDM service is not enabled"
            FAILED=1
        fi
    else
        print_success "Skipping systemd service check (not available in container)"
    fi
    
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