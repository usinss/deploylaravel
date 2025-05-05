#!/bin/bash
# Script to add a new non-root user to Digital Ocean droplet
# and copy SSH keys from root user
# Usage: sudo ./add-digital-ocean-user.sh

# Check if script is run as root
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root or with sudo privileges"
  exit 1
fi

# Setup logging
LOG_FILE="$(pwd)/add-user.log"
echo "Starting user creation at $(date)" > "$LOG_FILE"

# Function for logging
log_message() {
    local message="$1"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] $message" | tee -a "$LOG_FILE"
}

# Prompt for username
read -p "Enter new username: " username
log_message "Creating new user: $username"

# Check if the user already exists
if id "$username" &>/dev/null; then
    log_message "ERROR: User $username already exists"
    echo "ERROR: User $username already exists"
    exit 1
fi

# Prompt for password
read -sp "Enter password for $username: " userpass
echo ""
log_message "Password provided for user $username"

# Create the user non-interactively with home directory
log_message "Creating user account..."
useradd -m -s /bin/bash "$username"

if [ $? -ne 0 ]; then
    log_message "ERROR: Failed to create user $username"
    echo "Failed to create user. Check $LOG_FILE for details."
    exit 1
fi

# Set password for the new user
echo "$username:$userpass" | chpasswd

log_message "User $username created successfully with home directory"

# Add user to sudo group
log_message "Adding user to sudo group..."
usermod -aG sudo "$username"

if [ $? -ne 0 ]; then
    log_message "WARNING: Failed to add user to sudo group"
    echo "WARNING: Failed to add user to sudo group"
fi

# Create .ssh directory
log_message "Creating SSH directory..."
mkdir -p /home/$username/.ssh

# Set ownership for the entire home directory
log_message "Setting ownership for home directory..."
chown -R $username:$username /home/$username

# Set permissions for the home directory itself (not recursive)
log_message "Setting home directory permissions..."
chmod 755 /home/$username

# Check if root SSH key exists
if [ -f /root/.ssh/authorized_keys ]; then
    log_message "Copying SSH keys from root user..."
    cp /root/.ssh/authorized_keys /home/$username/.ssh/
    
    # Ensure .ssh directory has the correct restrictive permissions
    log_message "Setting secure permissions for SSH files..."
    chmod 700 /home/$username/.ssh
    chmod 600 /home/$username/.ssh/authorized_keys
    chown -R $username:$username /home/$username/.ssh
    
    log_message "SSH keys copied successfully with secure permissions"
else
    log_message "WARNING: No SSH keys found for root user"
    echo "WARNING: No SSH keys found for root user"
    
    # Still set proper permissions on .ssh directory even if no keys were copied
    chmod 700 /home/$username/.ssh
    chown -R $username:$username /home/$username/.ssh
fi

log_message "User setup completed successfully"
echo "================================================================="
echo "User $username has been created successfully!"
echo "SSH keys from root user have been copied (if they existed)"
echo "The user has been added to the sudo group"
echo ""
echo "You can now log in with:"
echo "  ssh $username@your-droplet-ip"
echo ""
echo "A log file has been created at: $LOG_FILE"
echo "================================================================="