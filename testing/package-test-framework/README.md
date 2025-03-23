# Package Testing Framework

This framework allows you to automatically test installation scripts for various packages across different Linux distributions using Docker containers.

## Overview

The testing framework is designed to validate that installation scripts work correctly on different Linux distributions. It uses Docker containers to create isolated environments for each distribution, making it easy to test without affecting your host system.

## Directory Structure

```
package-test-framework/
├── Dockerfile.template        # Template Dockerfile for container creation
├── test_package_install.sh    # Generic test script for package installation
├── run_package_tests.sh       # Script to run tests across all distros
├── tests/                     # Generated directory for test execution
└── README.md                  # This file
```

## Requirements

- Docker installed on your system
- Bash shell
- Internet connection (for pulling Docker images and downloading packages)

## How to Use

### Testing Specific Packages

To test specific packages:

```bash
./run_package_tests.sh firefox vscode docker
```

This will test the installation scripts for Firefox, VS Code, and Docker across all configured distributions.

### Testing All Packages

To test all packages that have installation scripts:

```bash
./run_package_tests.sh
```

This will automatically discover and test all packages in the `packages/` directory.

## What Gets Tested

For each package, the framework tests:

1. If the installation script executes successfully
2. If the binary is available in PATH after installation
3. If the package is installed according to the package manager
4. If the configuration directory exists

## Supported Distributions

The framework currently tests on:

- Ubuntu 22.04
- Ubuntu 24.04
- Fedora 38
- Arch Linux (latest)

## Adding New Distributions

To add a new distribution for testing, edit the `DISTRIBUTIONS` array in `run_package_tests.sh`:

```bash
DISTRIBUTIONS=(
    "ubuntu:22.04"
    "ubuntu:24.04"
    "fedora:38"
    "archlinux:latest"
    "your-new-distro:version"
)
```

## Troubleshooting

If tests fail, you can manually build and run the container to debug:

```bash
# Create the test directory
mkdir -p package-test-framework/tests/firefox-ubuntu-22.04

# Copy test script and install script
cp package-test-framework/test_package_install.sh package-test-framework/tests/firefox-ubuntu-22.04/
cp packages/browsers/firefox/install.sh package-test-framework/tests/firefox-ubuntu-22.04/

# Create Dockerfile
sed 's/\${DISTRO}/ubuntu:22.04/g' package-test-framework/Dockerfile.template > package-test-framework/tests/firefox-ubuntu-22.04/Dockerfile

# Build and run the container interactively
docker build -t package-test-firefox-ubuntu-22.04 package-test-framework/tests/firefox-ubuntu-22.04
docker run --privileged -it --rm package-test-firefox-ubuntu-22.04 /bin/bash

# Inside the container, you can run the test script manually
./test_package_install.sh firefox ./install.sh
```

## Notes

- Tests run with the `--privileged` flag to allow systemd operations
- Each test is independent and will not affect other tests
- The framework is designed to be extensible for additional distributions 