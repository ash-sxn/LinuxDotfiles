#!/bin/bash

# Master script to test multiple package installation scripts across different distros
# Usage: ./run_package_tests.sh [<package1> <package2> ...] 
# If no packages are specified, all packages will be tested

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

# Base directory for the fresh_ubuntu_setup project
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

# Define distributions to test on
DISTRIBUTIONS=(
    "ubuntu:22.04"
    "ubuntu:24.04"
    "fedora:38"
    "archlinux:latest"
)

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install Docker first."
    exit 1
fi

# Function to get all available packages
get_all_packages() {
    local packages=()
    
    # List all directories in packages/**
    for category_dir in "$PROJECT_DIR"/packages/*; do
        if [ -d "$category_dir" ]; then
            for package_dir in "$category_dir"/*; do
                if [ -d "$package_dir" ] && [ -f "$package_dir/install.sh" ]; then
                    # Get the package name from the directory name
                    package_name=$(basename "$package_dir")
                    packages+=("$package_name:$package_dir/install.sh")
                fi
            done
        fi
    done
    
    echo "${packages[@]}"
}

# Function to run test for a specific package on a specific distribution
run_package_test() {
    local package_info=$1
    local distro=$2
    
    # Parse package info
    IFS=':' read -r package_name install_script <<< "$package_info"
    
    print_section "Testing $package_name on $distro"
    
    # Create a temporary directory for this test
    local test_dir="$PROJECT_DIR/package-test-framework/tests/$package_name-$(echo $distro | tr ':' '-')"
    mkdir -p "$test_dir"
    
    # Copy test script and install script
    cp "$PROJECT_DIR/package-test-framework/test_package_install.sh" "$test_dir/"
    cp "$install_script" "$test_dir/"
    
    # Create Dockerfile for this test
    sed "s|\${DISTRO}|$distro|g" "$PROJECT_DIR/package-test-framework/Dockerfile.template" > "$test_dir/Dockerfile"
    
    # Build the Docker image
    print_info "Building Docker image for $package_name on $distro..."
    docker build -t "package-test-$package_name-$(echo $distro | tr ':' '-')" "$test_dir" > /dev/null 2>&1
    
    if [ $? -ne 0 ]; then
        print_error "Failed to build Docker image for $package_name on $distro"
        return 1
    else
        print_success "Docker image built successfully"
    fi
    
    # Run the Docker container with the test
    print_info "Running test for $package_name on $distro..."
    docker run --privileged --rm \
        "package-test-$package_name-$(echo $distro | tr ':' '-')" \
        ./test_package_install.sh "$package_name" "./$(basename "$install_script")"
    
    if [ $? -ne 0 ]; then
        print_error "Test for $package_name on $distro failed"
        FAILED_TESTS+=("$package_name on $distro")
        return 1
    else
        print_success "Test for $package_name on $distro passed"
        PASSED_TESTS+=("$package_name on $distro")
        return 0
    fi
}

# Main function
main() {
    print_section "Package Installation Test Suite"
    
    # Create arrays to track test results
    PASSED_TESTS=()
    FAILED_TESTS=()
    
    # Create test directories
    mkdir -p "$PROJECT_DIR/package-test-framework/tests"
    
    # Determine which packages to test
    if [ $# -gt 0 ]; then
        # Test specific packages
        for package_name in "$@"; do
            # Find the install script for this package
            found=false
            for category_dir in "$PROJECT_DIR"/packages/*; do
                if [ -d "$category_dir/$package_name" ] && [ -f "$category_dir/$package_name/install.sh" ]; then
                    PACKAGES+=("$package_name:$category_dir/$package_name/install.sh")
                    found=true
                    break
                fi
            done
            
            if [ "$found" = false ]; then
                print_error "Package $package_name not found or has no install.sh script"
            fi
        done
    else
        # Test all packages
        readarray -t PACKAGES < <(get_all_packages)
    fi
    
    if [ ${#PACKAGES[@]} -eq 0 ]; then
        print_error "No packages to test"
        exit 1
    fi
    
    print_info "Found ${#PACKAGES[@]} packages to test"
    
    # Run tests for each package and distribution
    for package_info in "${PACKAGES[@]}"; do
        for distro in "${DISTRIBUTIONS[@]}"; do
            run_package_test "$package_info" "$distro"
        done
    done
    
    # Print summary
    print_section "Test Summary"
    
    if [ ${#PASSED_TESTS[@]} -gt 0 ]; then
        echo -e "${GREEN}Passed Tests (${#PASSED_TESTS[@]})${NC}:"
        for test in "${PASSED_TESTS[@]}"; do
            echo -e "  ${GREEN}✓${NC} $test"
        done
    fi
    
    if [ ${#FAILED_TESTS[@]} -gt 0 ]; then
        echo -e "${RED}Failed Tests (${#FAILED_TESTS[@]})${NC}:"
        for test in "${FAILED_TESTS[@]}"; do
            echo -e "  ${RED}✗${NC} $test"
        done
        exit 1
    else
        print_success "All tests passed"
        exit 0
    fi
}

# Run the main function with all arguments
main "$@" 