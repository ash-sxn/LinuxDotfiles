#!/bin/bash

# Master script to build Docker images and run tests for each distribution

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

# Array of distributions to test
DISTRIBUTIONS=("ubuntu" "fedora" "arch")

# Test types
TEST_TYPES=("install" "customization")

# Function to run a specific test
run_test() {
    DISTRO=$1
    TEST_TYPE=$2
    
    print_section "Running $TEST_TYPE test for $DISTRO"
    
    # Copy the necessary scripts to the test directory
    mkdir -p ./gnome-install-tests/tests/$DISTRO
    cp ./install_gnome.sh ./gnome-install-tests/tests/$DISTRO/
    cp ./setup_gnome_complete.sh ./gnome-install-tests/tests/$DISTRO/
    cp ./gnome-install-tests/scripts/test_$TEST_TYPE.sh ./gnome-install-tests/tests/$DISTRO/
    
    # Build the Docker image if it doesn't exist
    if ! docker image inspect gnome-test-$DISTRO > /dev/null 2>&1; then
        print_info "Building Docker image for $DISTRO..."
        docker build -t gnome-test-$DISTRO -f ./gnome-install-tests/dockerfiles/$DISTRO.Dockerfile ./gnome-install-tests/tests/$DISTRO
        
        if [ $? -ne 0 ]; then
            print_error "Failed to build Docker image for $DISTRO"
            return 1
        else
            print_success "Docker image for $DISTRO built successfully"
        fi
    else
        print_info "Using existing Docker image for $DISTRO"
    fi
    
    # Run the Docker container with the test
    print_info "Running $TEST_TYPE test in Docker container for $DISTRO..."
    docker run --privileged --rm -v ./gnome-install-tests/tests/$DISTRO:/app gnome-test-$DISTRO ./test_$TEST_TYPE.sh
    
    if [ $? -ne 0 ]; then
        print_error "$TEST_TYPE test for $DISTRO failed"
        FAILED_TESTS+=("$DISTRO - $TEST_TYPE")
        return 1
    else
        print_success "$TEST_TYPE test for $DISTRO passed"
        PASSED_TESTS+=("$DISTRO - $TEST_TYPE")
        return 0
    fi
}

# Main function
main() {
    print_section "GNOME Installation and Customization Test Suite"
    
    # Check if Docker is installed
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    # Create arrays to track test results
    PASSED_TESTS=()
    FAILED_TESTS=()
    
    # Create test directories
    mkdir -p ./gnome-install-tests/tests
    
    # Make sure the test scripts are executable
    chmod +x ./gnome-install-tests/scripts/*.sh
    
    # Run tests for each distribution and test type
    for distro in "${DISTRIBUTIONS[@]}"; do
        for test_type in "${TEST_TYPES[@]}"; do
            run_test $distro $test_type
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

# Run the main function
main 