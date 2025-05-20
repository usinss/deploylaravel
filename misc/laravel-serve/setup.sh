#!/bin/bash
# Laravel Serve - Setup Script
# This script downloads and executes the laravel-serve installer

# Exit on any error
set -e

echo "====================================================="
echo "        Laravel Serve Utility Setup                  "
echo "====================================================="

# Install curl if needed, with or without sudo
install_curl() {
    if command -v sudo &> /dev/null; then
        echo "curl not found. Installing curl (may prompt for sudo password)..."
        sudo apt update && sudo apt install -y curl
    else
        echo "curl not found, and sudo not available."
        echo "Please install curl manually before running this script."
        exit 1
    fi
}

# Check for curl
if ! command -v curl &> /dev/null; then
    install_curl
fi

echo "Downloading laravel-serve installer..."
curl -s -o /tmp/laravel-serve-install.sh https://raw.githubusercontent.com/usinss/deploylaravel/main/misc/laravel-serve/install.sh

echo "Making installer executable..."
chmod +x /tmp/laravel-serve-install.sh

echo "Running installer..."
bash /tmp/laravel-serve-install.sh
# The installer will determine if sudo is needed and handle it appropriately

# Clean up
echo "Cleaning up..."
rm /tmp/laravel-serve-install.sh

echo "====================================================="
echo "Setup complete! You can now use the 'laravel-serve' command"
echo "from any Laravel project directory."
echo "====================================================="