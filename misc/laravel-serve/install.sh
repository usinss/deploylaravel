#!/bin/bash
# Laravel Serve - Installation Script
# This script installs the laravel-serve utility to your system

# Function to handle the system-wide installation
install_system_wide() {
    echo "Installing system-wide to /usr/local/bin/laravel-serve..."
    if sudo mv /tmp/laravel-serve.sh /usr/local/bin/laravel-serve; then
        echo "System-wide installation successful!"
        return 0
    else
        echo "System-wide installation failed."
        return 1
    fi
}

# Function to handle the user-local installation
install_user_local() {
    echo "Installing for current user only..."
    
    # Create bin directory in user's home if it doesn't exist
    mkdir -p "$HOME/bin"
    
    # Move the script to user's bin directory
    mv /tmp/laravel-serve.sh "$HOME/bin/laravel-serve"
    
    # Make sure the user's bin directory is in PATH
    if [[ ":$PATH:" != *":$HOME/bin:"* ]]; then
        echo "Adding $HOME/bin to your PATH in .bashrc..."
        echo 'export PATH="$HOME/bin:$PATH"' >> "$HOME/.bashrc"
        echo "Please restart your terminal or run 'source ~/.bashrc' to update your PATH."
    fi
    
    echo "User-local installation successful!"
    return 0
}

# Exit on any error
set -e

echo "====================================================="
echo "        Laravel Serve Utility Installer             "
echo "====================================================="

# Download laravel-serve.sh
echo "Downloading laravel-serve script..."
curl -s -o /tmp/laravel-serve.sh https://raw.githubusercontent.com/usinss/deploylaravel/main/misc/laravel-serve/laravel-serve.sh

# Make it executable
echo "Setting file permissions..."
chmod +x /tmp/laravel-serve.sh

# Try to install system-wide first
if [ "$(id -u)" -eq 0 ]; then
    # Already running as root
    echo "Installing to /usr/local/bin/laravel-serve..."
    mv /tmp/laravel-serve.sh /usr/local/bin/laravel-serve
    SUCCESS=true
else
    # Try with sudo
    echo "Attempting system-wide installation (may prompt for sudo password)..."
    if install_system_wide; then
        SUCCESS=true
    else
        # Ask user if they want to install locally
        echo "System-wide installation failed or sudo not available."
        read -p "Would you like to install for the current user only? (y/n): " INSTALL_LOCAL
        if [[ $INSTALL_LOCAL == "y" || $INSTALL_LOCAL == "Y" ]]; then
            if install_user_local; then
                SUCCESS=true
            else
                SUCCESS=false
            fi
        else
            SUCCESS=false
        fi
    fi
fi

if [ "$SUCCESS" = true ]; then
    echo "====================================================="
    echo "    Laravel Serve utility installed successfully!    "
    echo "====================================================="
    echo ""
    echo "You can now use 'laravel-serve' command from any Laravel project directory."
    echo "Usage: cd /path/to/laravel/project && laravel-serve"
    echo ""
else
    echo "====================================================="
    echo "            Installation failed!                     "
    echo "====================================================="
    exit 1
fi