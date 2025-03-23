# Testing Frameworks

This directory contains frameworks for testing the installation scripts and configuration files in the Fresh Ubuntu Setup project.

## Overview

The testing frameworks are designed to ensure that installation scripts work correctly across different Linux distributions. They use Docker containers to create isolated environments for each distribution, making it easy to test without affecting your host system.

## Available Frameworks

### 1. Package Testing Framework

Location: `package-test-framework/`

This framework tests individual package installation scripts (like Firefox, VS Code, Docker, etc.) to ensure they work correctly across different Linux distributions.

Features:
- Tests package installation, binary availability, and configuration
- Supports multiple Linux distributions (Ubuntu, Fedora, Arch)
- Can test specific packages or all packages at once

[View Package Testing Framework Documentation](package-test-framework/README.md)

### 2. GNOME Installation Testing Framework

Location: `gnome-install-tests/`

This framework specifically tests the GNOME Desktop Environment installation and customization scripts, ensuring they work correctly across different Linux distributions.

Features:
- Tests GNOME installation and package availability
- Tests GNOME customization (themes, extensions, settings)
- Supports multiple Linux distributions

[View GNOME Testing Framework Documentation](gnome-install-tests/README.md)

## Requirements

To use these testing frameworks, you need:

- Docker installed on your system
- Bash shell
- Internet connection (for pulling Docker images and downloading packages)

## Getting Started

1. Ensure Docker is installed and running:
   ```bash
   docker --version
   ```

2. Navigate to the specific testing framework directory:
   ```bash
   cd package-test-framework
   # or
   cd gnome-install-tests
   ```

3. Follow the instructions in the respective README files to run the tests.

## Adding New Tests

Each framework has its own documentation on how to add new test cases or support for additional Linux distributions. See the framework-specific README files for details. 