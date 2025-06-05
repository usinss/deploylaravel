#!/bin/bash
# Laravel development server startup script for macOS (M4 compatible)
# Optimized for macOS with Homebrew-installed tools

# Function to handle Ctrl+C
cleanup() {
    echo -e "\n\nStopping Laravel server..."
    kill $PHP_PID 2>/dev/null
    exit 0
}

# Set up trap for Ctrl+C
trap cleanup SIGINT

echo "Starting Laravel development environment with fresh state..."

# Check if we're in a Laravel project
if [ ! -f "artisan" ]; then
    echo "Error: This doesn't appear to be a Laravel project directory."
    echo "Please run this command from your Laravel project root."
    exit 1
fi

# Check for required tools
echo "Checking for required tools..."

# Check for PHP (Homebrew or system)
if ! command -v php &> /dev/null; then
    echo "Error: PHP is not installed. Install via Homebrew: brew install php"
    exit 1
fi

# Check for Node.js/npm (Homebrew or system)
if ! command -v npm &> /dev/null; then
    echo "Warning: npm is not installed. Install via Homebrew: brew install node"
    echo "Skipping frontend asset building..."
    SKIP_NPM=true
fi

# Display versions for debugging
echo "PHP version: $(php --version | head -n 1)"
if [ "$SKIP_NPM" != "true" ]; then
    echo "Node version: $(node --version)"
    echo "npm version: $(npm --version)"
fi

# Clear all Laravel caches
echo "==================================="
echo "Clearing all Laravel caches..."
echo "==================================="

# Clear application cache
echo "Clearing application cache..."
php artisan cache:clear

# Clear route cache
echo "Clearing route cache..."
php artisan route:clear

# Clear configuration cache
echo "Clearing config cache..."
php artisan config:clear

# Clear compiled views
echo "Clearing compiled views..."
php artisan view:clear

# Clear compiled classes and services
echo "Clearing compiled classes..."
php artisan clear-compiled

# Clear cached bootstrap files
echo "Clearing optimized class loader..."
php artisan optimize:clear

# Optional: Clear event cache (if you're using event caching)
echo "Clearing event cache..."
php artisan event:clear 2>/dev/null || true

# Optional: Clear scheduled task cache (if exists)
echo "Clearing schedule cache..."
php artisan schedule:clear-cache 2>/dev/null || true

# Rebuild caches
echo "==================================="
echo "Rebuilding caches..."
echo "==================================="

# Create config cache for better performance
echo "Caching configuration..."
php artisan config:cache

# Create route cache for better performance
echo "Caching routes..."
php artisan route:cache

# Create event cache if needed (optional)
echo "Caching events..."
php artisan event:cache 2>/dev/null || true

# NPM operations (only if npm is available)
if [ "$SKIP_NPM" != "true" ]; then
    echo "==================================="
    echo "Managing frontend assets..."
    echo "==================================="

    # Check if package.json exists
    if [ -f "package.json" ]; then
        # Install npm dependencies
        echo "Installing npm dependencies..."
        npm ci

        # Clean previous builds (macOS compatible)
        echo "Cleaning previous builds..."
        if npm run clean 2>/dev/null; then
            echo "Build cleaned via npm script"
        else
            # Fallback: remove build directories
            rm -rf public/build public/hot public/mix-manifest.json 2>/dev/null || true
            echo "Build directories cleaned manually"
        fi

        # Build fresh assets
        echo "Building assets..."
        if npm run build 2>/dev/null; then
            echo "Assets built successfully"
        elif npm run dev 2>/dev/null; then
            echo "Assets built using dev script"
        else
            echo "Warning: Could not build assets. Continuing without frontend compilation..."
        fi
    else
        echo "No package.json found, skipping frontend asset building..."
    fi
else
    echo "Skipping npm operations (npm not available)"
fi

# Start the server
echo "==================================="
echo "Starting Laravel development server..."
echo "==================================="
echo "Server will start at: http://127.0.0.1:8000"
echo "Press Ctrl+C to stop the server."
echo "==================================="

# Start the server and store its PID
php artisan serve &
PHP_PID=$!

# Wait for the server process
wait $PHP_PID