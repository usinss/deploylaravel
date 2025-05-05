#!/bin/bash
# Laravel Deployment Tools - Initial Setup Script
# This script downloads setup scripts and saves them for interactive use

# Print header
echo "======================================================"
echo "      Laravel Deployment Tools - Initial Setup       "
echo "======================================================"

# Function to check if a command exists
command_exists() {
  command -v "$1" &> /dev/null
}

# Check for wget
if ! command_exists wget; then
  echo "wget is not installed. Installing wget..."
  sudo apt-get update
  sudo apt-get install -y wget
fi

# Download the scripts silently
echo "Downloading setup scripts..."

# Download the user creation script
wget -q https://raw.githubusercontent.com/usinss/deploylaravel/main/new_droplet_user.sh -O new_droplet_user.sh
if [ $? -ne 0 ]; then
  echo "Failed to download the user creation script. Please check your internet connection."
  exit 1
fi

# Download the installation script
wget -q https://raw.githubusercontent.com/usinss/deploylaravel/main/install.sh -O install.sh
if [ $? -ne 0 ]; then
  echo "Failed to download the installation script. Please check your internet connection."
  exit 1
fi

# Make scripts executable
chmod +x new_droplet_user.sh
chmod +x install.sh

echo "Scripts downloaded successfully."
echo
echo "=== NEXT STEPS ==="
echo "1. Create a non-root user with:"
echo "   sudo ./new_droplet_user.sh"
echo
echo "2. After creating the user, log in as that user and run:"
echo "   sudo ./install.sh"
echo
echo "The scripts are now ready to use."
echo "======================================================"
