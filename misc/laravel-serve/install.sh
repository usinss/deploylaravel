#!/bin/bash
# Laravel Serve - Installation Script
# This script installs the laravel-serve utility to your system

# Function to handle the system-wide installation
install_system_wide() {
    echo "Installing system-wide to /usr/local/bin/laravel-serve..."
    if sudo mv /tmp/laravel-serve.sh /usr/local/bin/laravel-serve; then
        sudo chmod +x /usr/local/bin/laravel-serve
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
    
    # Create hidden bin directory in user's home if it doesn't exist
    mkdir -p "$HOME/.bin"
    
    # Copy the script to user's hidden bin directory (use cp instead of mv to preserve the temp file)
    cp /tmp/laravel-serve.sh "$HOME/.bin/laravel-serve"
    chmod +x "$HOME/.bin/laravel-serve"
    
    # Make sure the user's hidden bin directory is in PATH
    if [[ ":$PATH:" != *":$HOME/.bin:"* ]]; then
        echo "Adding $HOME/.bin to your PATH in .bashrc..."
        echo 'export PATH="$HOME/.bin:$PATH"' >> "$HOME/.bashrc"
        
        # Add the directory to the current PATH
        export PATH="$HOME/.bin:$PATH"
        echo "PATH updated for current session."
    fi
    
    echo "User-local installation successful!"
    echo "You can now use the command 'laravel-serve' in any Laravel project directory."
    echo "If the command is not found, use: ~/.bin/laravel-serve"
    return 0
}

# Only exit on critical errors, not all errors
set +e

echo "====================================================="
echo "        Laravel Serve Utility Installer             "
echo "====================================================="

# Download the script from GitHub
echo "Downloading laravel-serve script..."
curl -s -o /tmp/laravel-serve.sh https://raw.githubusercontent.com/usinss/deploylaravel/main/misc/laravel-serve/laravel-serve.sh

# Check if download was successful
if [ ! -s /tmp/laravel-serve.sh ]; then
    echo "Error: Failed to download laravel-serve.sh from GitHub"
    exit 1
fi

# Make it executable
echo "Setting file permissions..."
chmod +x /tmp/laravel-serve.sh

# Check if running as root or with sudo
if [ "$(id -u)" -eq 0 ]; then
    # Running as root or with sudo - use system-wide installation
    echo "Running with root privileges. Using system-wide installation."
    if install_system_wide; then
        SUCCESS=true
    else
        echo "System-wide installation failed."
        exit 1
    fi
else
    # Not running as root - use user-local installation
    echo "Running without root privileges. Using user-local installation."
    if install_user_local; then
        SUCCESS=true
        INSTALL_LOCAL="y"
    else
        SUCCESS=false
    fi
fi

if [ "$SUCCESS" = true ]; then
    echo "====================================================="
    echo "    Laravel Serve utility installed successfully!    "
    echo "====================================================="
    echo ""
    echo "You can now use 'laravel-serve' command from any Laravel project directory."
    echo "Usage: cd /path/to/laravel/project && laravel-serve"
    
    # Add instructions for local installation
    if [[ "$INSTALL_LOCAL" == "y" || "$INSTALL_LOCAL" == "Y" ]]; then
        echo ""
        echo "NOTE: If the 'laravel-serve' command is not found, you can:"
        echo "  1. Restart your terminal, or"
        echo "  2. Run 'source ~/.bashrc', or"
        echo "  3. Use the full path: ~/.bin/laravel-serve"
    fi
    echo ""
else
    echo "====================================================="
    echo "            Installation failed!                     "
    echo "====================================================="
    exit 1
fi