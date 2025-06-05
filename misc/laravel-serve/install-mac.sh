#!/bin/bash
# Installer script for Laravel Serve (Mac M4 version)
# This script installs laravel-serve as a global command

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_status "Installing Laravel Serve for macOS..."

# Check if we're on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "This installer is designed for macOS only."
    exit 1
fi

# Define installation paths
INSTALL_DIR="/usr/local/bin"
SCRIPT_NAME="laravel-serve"
SCRIPT_PATH="$INSTALL_DIR/$SCRIPT_NAME"

# Check if /usr/local/bin exists and is in PATH
if [ ! -d "$INSTALL_DIR" ]; then
    print_warning "/usr/local/bin doesn't exist. Creating it..."
    sudo mkdir -p "$INSTALL_DIR"
fi

# Check if /usr/local/bin is in PATH
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    print_warning "/usr/local/bin is not in your PATH."
    echo "Add this line to your shell profile (~/.zshrc, ~/.bash_profile, etc.):"
    echo "export PATH=\"$INSTALL_DIR:\$PATH\""
fi

# Get the directory where this installer script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_SCRIPT="$SCRIPT_DIR/laravel-serve-mac.sh"

# Check if source script exists
if [ ! -f "$SOURCE_SCRIPT" ]; then
    print_error "Source script not found at: $SOURCE_SCRIPT"
    print_error "Please run this installer from the misc/laravel-serve/ directory."
    exit 1
fi

# Install the script
print_status "Installing laravel-serve to $SCRIPT_PATH..."

# Copy and rename the script
sudo cp "$SOURCE_SCRIPT" "$SCRIPT_PATH"

# Make it executable
sudo chmod +x "$SCRIPT_PATH"

# Verify installation
if [ -f "$SCRIPT_PATH" ] && [ -x "$SCRIPT_PATH" ]; then
    print_status "✅ Laravel Serve installed successfully!"
    echo ""
    echo "Usage:"
    echo "  cd /path/to/your/laravel/project"
    echo "  laravel-serve"
    echo ""
    echo "The command will:"
    echo "  • Clear all Laravel caches"
    echo "  • Rebuild caches for better performance"
    echo "  • Install npm dependencies and build assets"
    echo "  • Start the Laravel development server at http://127.0.0.1:8000"
    echo ""
    
    # Test if command is available
    if command -v laravel-serve &> /dev/null; then
        print_status "✅ Command 'laravel-serve' is available in your PATH"
    else
        print_warning "Command 'laravel-serve' is not yet available in your current session"
        print_warning "Either restart your terminal or run: source ~/.zshrc (or your shell profile)"
    fi
else
    print_error "Installation failed. Please check permissions and try again."
    exit 1
fi

print_status "Installation complete!"