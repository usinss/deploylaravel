#!/bin/bash
# Laravel Deployment Tools - Initial Setup Script
# This script downloads both setup scripts and runs them in sequence
# with proper user input handling

# Set colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Print header
echo -e "${BLUE}======================================================${NC}"
echo -e "${BLUE}      Laravel Deployment Tools - Initial Setup       ${NC}"
echo -e "${BLUE}======================================================${NC}"

# Function to check if a command exists
command_exists() {
  command -v "$1" &> /dev/null
}

# Check for wget
if ! command_exists wget; then
  echo -e "${YELLOW}wget is not installed. Installing wget...${NC}"
  sudo apt-get update
  sudo apt-get install -y wget
fi

# Instead of direct execution, we'll first download all scripts
echo -e "${GREEN}Downloading the setup scripts...${NC}"

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

echo -e "${GREEN}Scripts downloaded successfully.${NC}"
echo
echo -e "${YELLOW}=== IMPORTANT INSTRUCTIONS ===${NC}"
echo -e "1. First, create a non-root user with:"
echo -e "   ${BLUE}sudo ./new_droplet_user.sh${NC}"
echo
echo -e "2. After creating the user, log in as that user and run:"
echo -e "   ${BLUE}sudo ./install.sh${NC}"
echo
echo -e "${GREEN}The scripts are now ready to run interactively.${NC}"
echo -e "${BLUE}======================================================${NC}"

# Ask if they want to run the user creation script now
echo -e -n "${YELLOW}Would you like to run the user creation script now? (y/n): ${NC}"
read -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo -e "${GREEN}Running user creation script...${NC}"
  sudo ./new_droplet_user.sh
  echo
  echo -e "${GREEN}User creation complete.${NC}"
  echo -e "${YELLOW}Please log in as the new user and run:${NC}"
  echo -e "${BLUE}sudo ./install.sh${NC}"
else
  echo -e "${GREEN}You can run the scripts manually when ready.${NC}"
fi

echo -e "${BLUE}======================================================${NC}"
