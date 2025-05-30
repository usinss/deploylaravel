#!/bin/bash
# Laravel development server startup script with complete cache clearing

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

# NPM operations
echo "==================================="
echo "Managing frontend assets..."
echo "==================================="

# Install npm dependencies
echo "Installing npm dependencies..."
npm ic

# Clean previous builds
echo "Cleaning previous builds..."
npm run clean 2>/dev/null || rm -rf public/build

# Build fresh assets
echo "Building assets..."
npm run build

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
