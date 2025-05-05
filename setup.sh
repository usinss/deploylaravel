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

echo -e "${GREEN}Step 1: Downloading the user creation script...${NC}"
wget -q https://raw.githubusercontent.com/usinss/deploylaravel/main/new_droplet_user.sh
if [ $? -ne 0 ]; then
  echo "Failed to download the user creation script. Please check your internet connection."
  exit 1
fi

echo -e "${GREEN}Step 2: Making the script executable...${NC}"
chmod +x new_droplet_user.sh

echo -e "${GREEN}Step 3: Running user creation script...${NC}"
echo -e "${YELLOW}You will be prompted to enter a username and password for the new user.${NC}"
echo -e "${YELLOW}This user will have sudo privileges.${NC}"
echo

# Run the user creation script
sudo ./new_droplet_user.sh

# Check if user creation was successful
if [ $? -ne 0 ]; then
  echo -e "${YELLOW}User creation may have failed. Check the log for details.${NC}"
  echo "You can try to run the script manually with: sudo ./new_droplet_user.sh"
  exit 1
fi

echo
echo -e "${GREEN}Step 4: Downloading the Laravel deployment tools installer...${NC}"
wget -q https://raw.githubusercontent.com/usinss/deploylaravel/main/install.sh
if [ $? -ne 0 ]; then
  echo "Failed to download the installation script. Please check your internet connection."
  exit 1
fi

echo -e "${GREEN}Step 5: Making the installer executable...${NC}"
chmod +x install.sh

echo -e "${GREEN}Step 6: Ready to install Laravel deployment tools${NC}"
echo -e "${YELLOW}IMPORTANT: You should now log in as the new user you just created${NC}"
echo -e "${YELLOW}and run the installer script with: sudo ./install.sh${NC}"
echo
echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}Setup preparation complete!${NC}"
echo -e "${GREEN}What to do next:${NC}"
echo -e "1. Log out and log back in as the new user you created"
echo -e "2. Navigate to the directory where install.sh was saved"
echo -e "3. Run: ${YELLOW}sudo ./install.sh${NC}"
echo -e "${BLUE}======================================================${NC}"
