#!/bin/bash

# Script to test GNOME customization in a Docker container

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

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if an extension is installed
is_extension_installed() {
    if command_exists gnome-extensions; then
        gnome-extensions list | grep -q "$1"
        return $?
    else
        # Fallback for older GNOME versions
        ls -la ~/.local/share/gnome-shell/extensions | grep -q "$1"
        return $?
    fi
}

# Function to check for the presence of a theme
check_theme() {
    THEME_TYPE=$1  # gtk, icon, shell
    THEME_NAME=$2
    
    case $THEME_TYPE in
        gtk)
            if [ -d "/usr/share/themes/$THEME_NAME" ] || [ -d "$HOME/.themes/$THEME_NAME" ]; then
                print_success "GTK theme $THEME_NAME is installed"
                return 0
            else
                print_error "GTK theme $THEME_NAME is not installed"
                return 1
            fi
            ;;
        icon)
            if [ -d "/usr/share/icons/$THEME_NAME" ] || [ -d "$HOME/.icons/$THEME_NAME" ] || [ -d "$HOME/.local/share/icons/$THEME_NAME" ]; then
                print_success "Icon theme $THEME_NAME is installed"
                return 0
            else
                print_error "Icon theme $THEME_NAME is not installed"
                return 1
            fi
            ;;
        shell)
            if [ -d "/usr/share/gnome-shell/theme/$THEME_NAME" ] || [ -d "$HOME/.themes/$THEME_NAME/gnome-shell" ] || [ -d "/usr/share/themes/$THEME_NAME/gnome-shell" ]; then
                print_success "Shell theme $THEME_NAME is installed"
                return 0
            else
                print_error "Shell theme $THEME_NAME is not installed"
                return 1
            fi
            ;;
        *)
            print_error "Unknown theme type: $THEME_TYPE"
            return 1
            ;;
    esac
}

# Function to check if gsettings is properly configured
check_gsettings() {
    KEY=$1
    EXPECTED_VALUE=$2
    
    if command_exists gsettings; then
        ACTUAL_VALUE=$(gsettings get $KEY)
        # Remove quotes if present
        ACTUAL_VALUE=${ACTUAL_VALUE//\'/}
        ACTUAL_VALUE=${ACTUAL_VALUE//\"/}
        
        if [ "$ACTUAL_VALUE" = "$EXPECTED_VALUE" ]; then
            print_success "gsettings key $KEY is correctly set to $EXPECTED_VALUE"
            return 0
        else
            print_error "gsettings key $KEY is set to $ACTUAL_VALUE, expected $EXPECTED_VALUE"
            return 1
        fi
    else
        print_error "gsettings command not found"
        return 1
    fi
}

# Main test function
run_tests() {
    print_section "Starting GNOME Customization Tests"
    
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
    
    # Test 1: Run the customization script
    print_section "Test 1: Running GNOME Customization Script"
    chmod +x ./setup_gnome_complete.sh
    yes | ./setup_gnome_complete.sh custom || \
    {
        print_error "Customization script failed"
        return 1
    }
    print_success "Customization script completed"
    
    # Test 2: Check for the presence of themes
    print_section "Test 2: Checking themes"
    check_theme "gtk" "WhiteSur-Dark"
    check_theme "icon" "Numix-Circle"
    
    # Test 3: Check for installed extensions
    print_section "Test 3: Checking extensions"
    EXTENSIONS=(
        "dash-to-dock@micxgx.gmail.com"
        "user-theme@gnome-shell-extensions.gcampax.github.com"
        "blur-my-shell@aunetx"
    )
    
    for extension in "${EXTENSIONS[@]}"; do
        if is_extension_installed $extension; then
            print_success "Extension $extension is installed"
        else
            print_error "Extension $extension is not installed"
            FAILED=1
        fi
    done
    
    # Test 4: Check gsettings configurations
    print_section "Test 4: Checking gsettings configurations"
    # These are just examples, adjust based on your actual customization settings
    check_gsettings "org.gnome.desktop.interface color-scheme" "prefer-dark" || FAILED=1
    check_gsettings "org.gnome.desktop.wm.preferences button-layout" "appmenu:minimize,maximize,close" || FAILED=1
    
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