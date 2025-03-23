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

# Log files
LOG_FILE="$SCRIPT_DIR/installation.log"
SUMMARY_FILE="$SCRIPT_DIR/summary.md"

# Function to log messages
log() {
    local message="$1"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo -e "[$timestamp] $message" | tee -a "$LOG_FILE"
}

# Function to append to summary.md
summary_log() {
    local message="$1"
    local type="$2"  # 'header', 'subheader', 'success', 'error', 'warning', 'info', 'code', 'normal'
    
    case "$type" in
        "header")
            echo -e "# $message" >> "$SUMMARY_FILE"
            ;;
        "subheader")
            echo -e "## $message" >> "$SUMMARY_FILE"
            ;;
        "success")
            echo -e "✅ **Success:** $message" >> "$SUMMARY_FILE"
            ;;
        "error")
            echo -e "❌ **Error:** $message" >> "$SUMMARY_FILE"
            ;;
        "warning")
            echo -e "⚠️ **Warning:** $message" >> "$SUMMARY_FILE"
            ;;
        "info")
            echo -e "ℹ️ **Info:** $message" >> "$SUMMARY_FILE"
            ;;
        "code")
            echo -e "```\n$message\n```" >> "$SUMMARY_FILE"
            ;;
        *)
            echo -e "$message" >> "$SUMMARY_FILE"
            ;;
    esac
}

# Function to print colored section headers
print_section() {
    echo -e "${BLUE}==================================================================${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}==================================================================${NC}"
    log "SECTION: $1"
    summary_log "$1" "subheader"
}

# Function to print colored status messages
print_status() {
    case "$2" in
        "info")
            echo -e "${CYAN}[INFO]${NC} $1"
            log "INFO: $1"
            summary_log "$1" "info"
            ;;
        "success")
            echo -e "${GREEN}[SUCCESS]${NC} $1"
            log "SUCCESS: $1"
            summary_log "$1" "success"
            ;;
        "warning")
            echo -e "${YELLOW}[WARNING]${NC} $1"
            log "WARNING: $1"
            summary_log "$1" "warning"
            ;;
        "error")
            echo -e "${RED}[ERROR]${NC} $1"
            log "ERROR: $1"
            summary_log "$1" "error"
            ;;
        *)
            echo -e "$1"
            log "$1"
            summary_log "$1" "normal"
            ;;
    esac
}

# Function to capture command output with proper logging
run_command() {
    local cmd="$1"
    local description="$2"
    local output_file=$(mktemp)
    
    print_status "Running: $description" "info"
    log "COMMAND: $cmd"
    summary_log "Running: $description" "info"
    summary_log "$cmd" "code"
    
    # Run the command and capture output and exit code
    set -o pipefail
    eval "$cmd" 2>&1 | tee "$output_file"
    local exit_code=$?
    set +o pipefail
    
    # Process the result
    if [ $exit_code -eq 0 ]; then
        print_status "$description completed successfully." "success"
        summary_log "Command output:" "normal"
        summary_log "$(cat "$output_file" | head -n 20)" "code"
        if [ $(wc -l < "$output_file") -gt 20 ]; then
            summary_log "... (output truncated, see full log)" "normal"
        fi
    else
        print_status "$description failed with exit code $exit_code." "error"
        summary_log "Command failed with exit code $exit_code" "error"
        summary_log "Error output:" "normal"
        summary_log "$(cat "$output_file")" "code"
    fi
    
    rm "$output_file"
    return $exit_code
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
    
    # Save system information to summary
    summary_log "System Information" "subheader"
    summary_log "- **Distribution**: $DISTRO_NAME $DISTRO_VERSION" "normal"
    summary_log "- **Distribution Family**: $DISTRO_FAMILY" "normal"
    summary_log "- **Kernel**: $(uname -r)" "normal"
    summary_log "- **Architecture**: $(uname -m)" "normal"
    summary_log "- **Installation Date**: $(date)" "normal"
    summary_log "" "normal"
}

# Function to check dependencies
check_dependencies() {
    print_section "Checking Dependencies"
    
    local missing_deps=()
    local required_deps=("curl" "wget" "git" "grep" "sed" "awk")
    
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
                    run_command "sudo apt update && sudo apt install -y ${missing_deps[*]}" "Installing dependencies (apt)"
                    ;;
                redhat)
                    run_command "sudo dnf install -y ${missing_deps[*]}" "Installing dependencies (dnf)"
                    ;;
                arch)
                    run_command "sudo pacman -S --noconfirm ${missing_deps[*]}" "Installing dependencies (pacman)"
                    ;;
                suse)
                    run_command "sudo zypper install -y ${missing_deps[*]}" "Installing dependencies (zypper)"
                    ;;
                *)
                    print_status "Unsupported distribution for automatic dependency installation." "error"
                    print_status "Please install the following dependencies manually: ${missing_deps[*]}" "error"
                    summary_log "Unsupported distribution for automatic dependency installation. Please install dependencies manually: ${missing_deps[*]}" "error"
                    exit 1
                    ;;
            esac
            
            # Verify installation of dependencies
            local still_missing=()
            for dep in "${missing_deps[@]}"; do
                if ! command -v "$dep" &> /dev/null; then
                    still_missing+=("$dep")
                fi
            done
            
            if [ ${#still_missing[@]} -gt 0 ]; then
                print_status "Some dependencies could not be installed: ${still_missing[*]}" "error"
                print_status "Please install them manually and try again." "error"
                summary_log "Failed to install dependencies: ${still_missing[*]}" "error"
                exit 1
            else
                print_status "All dependencies successfully installed." "success"
            fi
        else
            print_status "Dependencies are required for this script to work properly." "error"
            summary_log "User declined to install required dependencies." "error"
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
        ["Desktop"]="packages/desktop"
        ["System"]="packages/system"
    )
    
    # Reset package arrays
    declare -A available_packages
    declare -A package_categories_map
    declare -A package_descriptions
    
    # Summary logging
    summary_log "Available Packages" "subheader"
    
    # Discover packages in each category
    for category in "${!package_categories[@]}"; do
        local category_path="${package_categories[$category]}"
        
        if [ -d "$SCRIPT_DIR/$category_path" ]; then
            print_status "Checking category: $category" "info"
            summary_log "### $category" "normal"
            
            # Find all installation scripts in the category directory
            for package_script in "$SCRIPT_DIR/$category_path"/*/*.sh; do
                if [ -f "$package_script" ]; then
                    # Extract package name from directory name
                    local package_dir=$(dirname "$package_script")
                    local package_name=$(basename "$package_dir")
                    
                    # Read package description if available
                    local description=""
                    local full_description=""
                    
                    if [ -f "$package_dir/description.txt" ]; then
                        description=$(head -n 1 "$package_dir/description.txt")
                        # Get full description for summary
                        full_description=$(cat "$package_dir/description.txt")
                    else
                        # Try to extract from the script file
                        description=$(grep "PACKAGE_DESCRIPTION" "$package_script" | cut -d'"' -f2 || echo "No description available")
                        full_description="$description"
                    fi
                    
                    # Add to available packages
                    available_packages["$package_name"]="$description"
                    package_categories_map["$package_name"]="$category"
                    package_descriptions["$package_name"]="$full_description"
                    
                    print_status "Found package: $package_name - $description" "info"
                    summary_log "- **$package_name**: $description" "normal"
                fi
            done
            
            # Add a blank line after each category in the summary
            summary_log "" "normal"
        else
            print_status "Category directory not found: $category_path" "warning"
        fi
    done
    
    if [ ${#available_packages[@]} -eq 0 ]; then
        print_status "No packages found. Please make sure package directories are properly set up." "error"
        summary_log "No packages found. Please make sure package directories are properly set up." "error"
        exit 1
    else
        print_status "Found ${#available_packages[@]} packages across ${#package_categories[@]} categories." "success"
        summary_log "Found **${#available_packages[@]}** packages across **${#package_categories[@]}** categories." "success"
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
    
    summary_log "Selected Packages" "subheader"
    
    # Option for selecting all packages
    read -p "Do you want to install all packages? (y/N): " install_all
    
    if [[ $install_all =~ ^[Yy]$ ]]; then
        for package in "${!available_packages[@]}"; do
            selected_packages["$package"]=1
            print_status "Selected: $package" "success"
        done
        summary_log "User selected all packages" "info"
    else
        # Option for selecting packages by category
        for category in "${!package_categories[@]}"; do
            if [ -n "${category_packages[$category]}" ]; then
                echo -e "\n${MAGENTA}${category}${NC}"
                echo -e "${MAGENTA}$(printf '=%.0s' $(seq 1 ${#category}))${NC}"
                
                # Option to select all packages in category
                read -p "Install all packages in $category? (y/N): " install_category
                
                if [[ $install_category =~ ^[Yy]$ ]]; then
                    for package in ${category_packages[$category]}; do
                        selected_packages["$package"]=1
                        print_status "Selected: $package" "success"
                    done
                    summary_log "User selected all packages in category: $category" "info"
                else
                    # Individual package selection
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
            fi
        done
    fi
    
    # Confirm selection
    if [ ${#selected_packages[@]} -eq 0 ]; then
        print_status "No packages selected." "warning"
        summary_log "No packages were selected." "warning"
        read -p "Do you want to continue without installing any packages? (y/N): " continue_choice
        
        if [[ ! $continue_choice =~ ^[Yy]$ ]]; then
            print_status "Installation cancelled." "info"
            summary_log "Installation cancelled by user." "info"
            exit 0
        fi
    else
        summary_log "### Selected Packages:" "normal"
        echo -e "\n${GREEN}Selected packages:${NC}"
        for package in "${!selected_packages[@]}"; do
            echo -e "  - $package (${package_categories_map[$package]})"
            summary_log "- **$package** (${package_categories_map[$package]})" "normal"
        done
        
        read -p "Do you want to proceed with the installation? (Y/n): " confirm_choice
        
        if [[ $confirm_choice =~ ^[Nn]$ ]]; then
            print_status "Installation cancelled." "info"
            summary_log "Installation cancelled by user." "info"
            exit 0
        fi
    fi
}

# Function to verify if a package is installed successfully
verify_package_installation() {
    local package="$1"
    local install_script="$2"
    local verification_failed=false
    
    print_status "Verifying installation of $package..." "info"
    
    # Try to extract the verification command from the install script
    local is_installed_function=$(grep -A 10 "is_installed()" "$install_script" | grep -v 'return' | grep -v '{' | grep -v '}' | grep -v '#' | head -n 1)
    
    if [ -n "$is_installed_function" ]; then
        # Extract the command used to check if the package is installed
        local check_cmd=$(echo "$is_installed_function" | sed 's/^\s*if\s\+\(.*\)\s\+&>.*$/\1/')
        
        if [ -n "$check_cmd" ]; then
            print_status "Running verification command: $check_cmd" "info"
            
            # Execute the verification command
            if eval "$check_cmd" &>/dev/null; then
                print_status "Verification successful: $package is properly installed." "success"
                summary_log "Verification successful: $package is properly installed." "success"
                return 0
            else
                print_status "Verification failed: $package command not found or not working properly." "error"
                summary_log "Verification failed: $package command not found or not working properly." "error"
                verification_failed=true
            fi
        else
            print_status "Could not extract verification command from install script." "warning"
            verification_failed=true
        fi
    else
        print_status "No installation verification function found in script." "warning"
        verification_failed=true
    fi
    
    # Additional verifications if the automatic verification didn't work
    if $verification_failed; then
        # Check common system paths for binary
        if command -v "$package" &>/dev/null; then
            print_status "Found '$package' binary in PATH." "success"
            summary_log "Found '$package' binary in PATH." "success"
            return 0
        else
            print_status "Could not find '$package' binary in PATH." "warning"
            summary_log "Could not find '$package' binary in PATH." "warning"
        fi
        
        # For GUI applications, check if .desktop file exists
        if [ -f "/usr/share/applications/$package.desktop" ] || [ -f "/usr/local/share/applications/$package.desktop" ]; then
            print_status "Found desktop entry for $package." "success"
            summary_log "Found desktop entry for $package." "success"
            return 0
        fi
        
        # Check if package exists in package manager database
        case $DISTRO_FAMILY in
            debian)
                if dpkg -l | grep -q "$package"; then
                    print_status "Package $package found in dpkg database." "success"
                    summary_log "Package $package found in dpkg database." "success"
                    return 0
                fi
                ;;
            redhat)
                if rpm -q "$package" &>/dev/null; then
                    print_status "Package $package found in rpm database." "success"
                    summary_log "Package $package found in rpm database." "success"
                    return 0
                fi
                ;;
            arch)
                if pacman -Q "$package" &>/dev/null; then
                    print_status "Package $package found in pacman database." "success"
                    summary_log "Package $package found in pacman database." "success"
                    return 0
                fi
                ;;
            suse)
                if zypper search -i "$package" | grep -q "^i "; then
                    print_status "Package $package found in zypper database." "success"
                    summary_log "Package $package found in zypper database." "success"
                    return 0
                fi
                ;;
        esac
        
        print_status "Could not verify if $package was installed correctly." "warning"
        summary_log "Could not verify if $package was installed correctly. It may or may not be working properly." "warning"
        return 1
    fi
    
    return 0
}

# Function to install selected packages
install_selected_packages() {
    print_section "Installing Selected Packages"
    
    local install_successes=0
    local install_failures=0
    local verified_installs=0
    local verification_failures=0
    
    summary_log "Installation Results" "subheader"
    
    for package in "${!selected_packages[@]}"; do
        local category="${package_categories_map[$package]}"
        local package_path="$SCRIPT_DIR/packages/${category,,}/$package"
        local install_script="$package_path/install.sh"
        
        summary_log "### $package" "normal"
        summary_log "**Category**: ${category}" "normal"
        summary_log "**Description**:" "normal"
        summary_log "${package_descriptions[$package]}" "normal"
        summary_log "**Installation Log**:" "normal"
        
        if [ -f "$install_script" ]; then
            print_status "Installing $package..." "info"
            log "Starting installation of $package"
            
            # Make the script executable if it's not already
            chmod +x "$install_script"
            
            # Start time for installation
            local start_time=$(date +%s)
            
            # Run the installation script with detailed output capture
            local output_file=$(mktemp)
            
            {
                bash "$install_script"
                local install_exit_code=$?
            } > >(tee -a "$output_file") 2>&1
            
            # End time for installation
            local end_time=$(date +%s)
            local duration=$((end_time - start_time))
            
            summary_log "Installation took $duration seconds." "info"
            
            # Process full output for summary
            summary_log "```" "normal"
            cat "$output_file" | head -n 50 >> "$SUMMARY_FILE"
            if [ $(wc -l < "$output_file") -gt 50 ]; then
                echo "... (output truncated, see full log)" >> "$SUMMARY_FILE"
            fi
            summary_log "```" "normal"
            
            # Remove temporary file
            rm "$output_file"
            
            # Check if installation was successful
            if [ $install_exit_code -eq 0 ]; then
                print_status "Installation script for $package completed successfully." "success"
                summary_log "Installation script for $package completed successfully with exit code 0." "success"
                ((install_successes++))
                
                # Verify installation
                if verify_package_installation "$package" "$install_script"; then
                    ((verified_installs++))
                else
                    ((verification_failures++))
                    summary_log "WARNING: The package may have installed but verification was not successful. It may still work correctly." "warning"
                fi
            else
                print_status "Installation script for $package failed with exit code $install_exit_code." "error"
                summary_log "Installation script for $package failed with exit code $install_exit_code." "error"
                ((install_failures++))
            fi
        else
            print_status "Installation script not found for $package: $install_script" "error"
            log "Installation script not found for $package: $install_script"
            summary_log "Installation script not found: $install_script" "error"
            ((install_failures++))
        fi
        
        # Add spacing between package entries in summary
        summary_log "" "normal"
    done
    
    # Print installation summary
    print_section "Installation Summary"
    summary_log "Installation Summary" "subheader"
    
    print_status "Successfully installed: $install_successes packages" "success"
    summary_log "Successfully installed: $install_successes packages" "success"
    
    print_status "Verified working installations: $verified_installs packages" "info"
    summary_log "Verified working installations: $verified_installs packages" "info"
    
    if [ $verification_failures -gt 0 ]; then
        print_status "Installations with verification issues: $verification_failures packages" "warning"
        summary_log "Installations with verification issues: $verification_failures packages" "warning"
    fi
    
    if [ $install_failures -gt 0 ]; then
        print_status "Failed installations: $install_failures packages" "error"
        print_status "Check the log file for details: $LOG_FILE" "info"
        print_status "Check the summary file for details: $SUMMARY_FILE" "info"
        summary_log "Failed installations: $install_failures packages" "error"
    fi
}

# Function to setup dotfiles
setup_dotfiles() {
    print_section "Setting Up Dotfiles"
    
    read -p "Would you like to set up configuration files (dotfiles)? (y/N): " setup_config_choice
    
    if [[ $setup_config_choice =~ ^[Yy]$ ]]; then
        print_status "Setting up dotfiles..." "info"
        summary_log "Dotfiles Configuration" "subheader"
        
        # Loop through installed packages and set up their configurations
        for package in "${!selected_packages[@]}"; do
            local category="${package_categories_map[$package]}"
            local package_path="$SCRIPT_DIR/packages/${category,,}/$package"
            local config_script="$package_path/config_setup.sh"
            
            summary_log "### $package Configuration" "normal"
            
            if [ -f "$config_script" ]; then
                print_status "Setting up configuration for $package..." "info"
                chmod +x "$config_script"
                
                # Capture configuration output
                local output_file=$(mktemp)
                
                {
                    bash "$config_script"
                    local config_exit_code=$?
                } > >(tee -a "$output_file") 2>&1
                
                # Process output for summary
                summary_log "```" "normal"
                cat "$output_file" | head -n 30 >> "$SUMMARY_FILE"
                if [ $(wc -l < "$output_file") -gt 30 ]; then
                    echo "... (output truncated, see full log)" >> "$SUMMARY_FILE"
                fi
                summary_log "```" "normal"
                
                # Remove temporary file
                rm "$output_file"
                
                if [ $config_exit_code -eq 0 ]; then
                    print_status "Successfully set up configuration for $package." "success"
                    log "Successfully set up configuration for $package"
                    summary_log "Successfully set up configuration for $package." "success"
                else
                    print_status "Failed to set up configuration for $package." "error"
                    log "Failed to set up configuration for $package with exit code $config_exit_code"
                    summary_log "Failed to set up configuration for $package with exit code $config_exit_code." "error"
                fi
            else
                # Check if there's a config directory without a script
                local config_dir="$package_path/config"
                if [ -d "$config_dir" ]; then
                    print_status "Found configuration directory for $package but no setup script." "warning"
                    print_status "You may need to manually set up the configuration files in: $config_dir" "info"
                    log "Manual configuration needed for $package: $config_dir"
                    summary_log "Found configuration directory but no setup script. Manual configuration may be needed in: $config_dir" "warning"
                else
                    summary_log "No configuration files found for $package." "info"
                fi
            fi
            
            # Add spacing between package entries in summary
            summary_log "" "normal"
        done
        
        print_status "Dotfiles setup completed." "success"
        summary_log "Dotfiles setup completed." "success"
    else
        print_status "Skipping dotfiles setup." "info"
        summary_log "User chose to skip dotfiles setup." "info"
    fi
}

# Main function
main() {
    print_section "Linux Dotfiles Installation Script"
    
    # Create a fresh log file
    echo "# Installation Log - $(date)" > "$LOG_FILE"
    
    # Create a fresh summary file with header
    echo "# Linux Dotfiles Installation Summary" > "$SUMMARY_FILE"
    echo "" >> "$SUMMARY_FILE"
    echo "**Installation Date:** $(date)" >> "$SUMMARY_FILE"
    echo "" >> "$SUMMARY_FILE"
    
    log "Starting installation script"
    
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
    
    summary_log "Final Notes" "subheader"
    summary_log "- Log file has been saved to: \`$LOG_FILE\`" "normal"
    summary_log "- This summary has been saved to: \`$SUMMARY_FILE\`" "normal"
    
    print_status "Thank you for using LinuxDotfiles!" "success"
    print_status "Log file has been saved to: $LOG_FILE" "info"
    print_status "Summary file has been saved to: $SUMMARY_FILE" "info"
    
    log "Installation script completed"
    
    # Final summary note
    summary_log "" "normal"
    summary_log "Installation completed at $(date)" "normal"
}

# Run the main function
main 