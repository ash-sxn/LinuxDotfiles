# GNOME Installation Testing Framework

This directory contains a testing framework to automatically verify the functionality of the GNOME installation and customization scripts across different Linux distributions using Docker containers.

## Overview

The testing framework is designed to validate that the installation and customization scripts work correctly on different Linux distributions. It uses Docker containers to create isolated environments for each distribution, making it easy to test without affecting the host system.

## Directory Structure

```
gnome-install-tests/
├── dockerfiles/             # Dockerfile for each supported distribution
│   ├── ubuntu.Dockerfile
│   ├── fedora.Dockerfile
│   └── arch.Dockerfile
├── scripts/                 # Test scripts that run inside the containers
│   ├── test_install.sh      # Tests the GNOME installation script
│   └── test_customization.sh # Tests the GNOME customization script
├── tests/                   # Generated directory for test execution
├── run_tests.sh             # Main script to run all tests
└── README.md                # This file
```

## Requirements

- Docker installed on your system
- Bash shell
- Internet connection (for pulling Docker images and downloading packages)

## How to Use

1. Make sure Docker is installed and running on your system:
   ```bash
   docker --version
   ```

2. Ensure all scripts are executable:
   ```bash
   chmod +x run_tests.sh
   chmod +x scripts/*.sh
   ```

3. Run the tests:
   ```bash
   ./run_tests.sh
   ```

This will:
- Build Docker images for each distribution if they don't exist
- Copy the necessary scripts to the test directories
- Run the installation and customization tests in Docker containers
- Display a summary of passed and failed tests

## Test Types

### Installation Tests (`test_install.sh`)

This test validates that the GNOME installation script:
- Executes successfully
- Installs the required GNOME packages
- Enables the necessary services

### Customization Tests (`test_customization.sh`)

This test validates that the GNOME customization script:
- Executes successfully
- Installs the specified themes and extensions
- Applies the correct settings

## Extending the Framework

### Adding a New Distribution

1. Create a new Dockerfile in the `dockerfiles` directory:
   ```bash
   touch dockerfiles/new_distro.Dockerfile
   ```

2. Add the distribution to the `DISTRIBUTIONS` array in `run_tests.sh`:
   ```bash
   DISTRIBUTIONS=("ubuntu" "fedora" "arch" "new_distro")
   ```

### Adding a New Test Type

1. Create a new test script in the `scripts` directory:
   ```bash
   touch scripts/test_new_feature.sh
   ```

2. Add the test type to the `TEST_TYPES` array in `run_tests.sh`:
   ```bash
   TEST_TYPES=("install" "customization" "new_feature")
   ```

## Troubleshooting

If tests fail, you can debug by manually running individual tests:

```bash
# Build the Docker image
docker build -t gnome-test-ubuntu -f ./dockerfiles/ubuntu.Dockerfile ./tests/ubuntu

# Run the container interactively
docker run --privileged -it --rm -v ./tests/ubuntu:/app gnome-test-ubuntu /bin/bash

# Inside the container, you can run the test script manually
./test_install.sh
```

## Notes

- Tests run with the `--privileged` flag to allow systemd operations
- Each test is independent and will not affect other tests
- The framework is designed to be extensible for additional distributions and test types 