#!/bin/bash
# Laravel Deployment Tools - Main Installer
# This script sets up a complete Laravel production environment on Ubuntu 24.04
# Usage: ./install.sh [--update]

# Exit on any error
set -e

# Configuration - Edit these variables if needed
PHP_VERSION="8.3"
DEFAULT_PROD_BRANCH="DEMO"

# Parse command line arguments
UPDATE_ONLY=false
for arg in "$@"; do
    case $arg in
        --update)
            UPDATE_ONLY=true
            shift
            ;;
        *)
            echo "Usage: $0 [--update]"
            echo "  --update    Only update deployment scripts, skip app installation and config generation"
            exit 1
            ;;
    esac
done

# Script Header
if [ "$UPDATE_ONLY" = true ]; then
    echo "====================================================="
    echo "        Laravel Deployment Tools Updater             "
    echo "        Updating deployment scripts only...          "
    echo "====================================================="
else
    echo "====================================================="
    echo "        Laravel Deployment Tools Installer           "
    echo "        For Ubuntu 24.04 / PHP ${PHP_VERSION}        "
    echo "====================================================="
fi

# Skip system installation steps in update mode
if [ "$UPDATE_ONLY" = false ]; then
    # Update system
    echo "Updating system packages..."
    sudo apt update
    sudo apt upgrade -y

    # Set correct time zone and enable ntp
    sudo timedatectl set-timezone Europe/Riga
    sudo apt-get install ntp

    # Install and configure Firewall (UFW)
    echo "Installing Uncomplicated Firewall (UFW)..."
    sudo apt install -y ufw

    echo "Configuring firewall to allow only SSH (22), HTTP (80), and HTTPS (443)..."
    # Critical: Add SSH rule first to prevent lockout
    echo "Adding SSH rule first to prevent lockout..."
    sudo ufw allow 22/tcp comment 'Allow SSH'

    # Check if SSH rule was added successfully
    echo "Verifying SSH rule was added correctly..."
    if sudo ufw status | grep -q "22/tcp"; then
        echo "SSH rule confirmed successfully."
    else
        echo "WARNING: SSH rule wasn't added correctly. For safety, not enabling firewall."
        echo "Please manually configure UFW after installation is complete."
        echo "You can do this by running: sudo ufw allow 22/tcp && sudo ufw enable"
        echo ""
        echo "Continuing with the rest of the installation..."
        # Skip the rest of the firewall configuration for safety
        goto_next_step=true
    fi

    if [ "$goto_next_step" != "true" ]; then
        # Set default policies
        sudo ufw default deny incoming
        sudo ufw default allow outgoing

        # Allow web ports
        sudo ufw allow 80/tcp comment 'Allow HTTP'
        sudo ufw allow 443/tcp comment 'Allow HTTPS'

        # Safety measure: Allow user to confirm before enabling
        echo ""
        echo "FIREWALL SAFETY CHECK:"
        echo "The firewall is about to be enabled with the following rules:"
        echo " - SSH (22/tcp): ALLOWED"
        echo " - HTTP (80/tcp): ALLOWED"
        echo " - HTTPS (443/tcp): ALLOWED"
        echo " - All other incoming connections: BLOCKED"
        echo ""
        read -p "Are you sure you want to enable the firewall now? (y/n): " confirm_firewall
        if [[ $confirm_firewall == "y" || $confirm_firewall == "Y" ]]; then
            echo "Enabling firewall..."
            sudo ufw --force enable
            sudo ufw status verbose
            echo "Firewall is now active."
            
            # Add safety information
            echo ""
            echo "IMPORTANT: If you lose connection to this server after enabling the firewall,"
            echo "you may need to access the server console directly via your provider's dashboard."
            echo ""
        else
            echo "Firewall has NOT been enabled at your request."
            echo "You can enable it later with: sudo ufw enable"
            echo ""
        fi
    fi

    # Install NGINX
    echo "Installing NGINX..."
    sudo apt install -y nginx

    # Install expect for automation
    echo "Installing expect tool..."
    sudo apt install -y expect

    # Install MariaDB
    echo "Installing MariaDB server and client..."
    sudo apt install -y mariadb-server mariadb-client

    # Automated secure MariaDB installation without changing root password
    echo "Securing MariaDB installation..."
    sudo tee /tmp/secure_mysql.expect > /dev/null << 'EOF'
#!/usr/bin/expect -f
set timeout 10

spawn mariadb-secure-installation

expect "Enter current password for root (enter for none):"
send "\r"

expect {
    "Switch to unix_socket authentication" {
        send "n\r"
        exp_continue
    }
    "Change the root password?" {
        send "n\r"
        exp_continue
    }
    "Remove anonymous users?" {
        send "y\r"
        exp_continue
    }
    "Disallow root login remotely?" {
        send "y\r"
        exp_continue
    }
    "Remove test database and access to it?" {
        send "y\r"
        exp_continue
    }
    "Reload privilege tables now?" {
        send "y\r"
        exp_continue
    }
    "Thanks for using MariaDB!" {
        # We're done
    }
    timeout {
        puts "Timeout occurred"
        exit 1
    }
}
EOF

    sudo chmod +x /tmp/secure_mysql.expect
    # Run with sudo directly
    sudo /tmp/secure_mysql.expect
    sudo rm /tmp/secure_mysql.expect

    # Install PHP and required modules
    echo "Installing PHP ${PHP_VERSION} and required modules..."
    sudo apt install -y php${PHP_VERSION} php${PHP_VERSION}-fpm php${PHP_VERSION}-cli php${PHP_VERSION}-common php${PHP_VERSION}-mysql \
                        php${PHP_VERSION}-zip php${PHP_VERSION}-gd php${PHP_VERSION}-mbstring php${PHP_VERSION}-curl php${PHP_VERSION}-xml \
                        php${PHP_VERSION}-bcmath php${PHP_VERSION}-intl php${PHP_VERSION}-soap php${PHP_VERSION}-fileinfo

    # Install zip/unzip utilities
    echo "Installing zip/unzip utilities..."
    sudo apt install -y zip unzip

    # Install Git
    echo "Installing Git..."
    sudo apt install -y git

    # Install cURL
    echo "Installing cURL..."
    sudo apt install -y curl

    # Install Composer
    echo "Installing Composer..."
    curl -sS https://getcomposer.org/installer | php
    sudo mv composer.phar /usr/local/bin/composer
    sudo chmod +x /usr/local/bin/composer

    # Ask for production branch name
    read -p "Enter the name of your production branch [${DEFAULT_PROD_BRANCH}]: " PRODUCTION_BRANCH
    PRODUCTION_BRANCH=${PRODUCTION_BRANCH:-$DEFAULT_PROD_BRANCH}

    # Create and prepare SSH directory with proper permissions for www-data
    echo "Setting up SSH directory for www-data user..."
    sudo mkdir -p /var/www/.ssh
    sudo chown -R www-data:www-data /var/www
    sudo chown -R www-data:www-data /var/www/.ssh
    sudo chmod 700 /var/www/.ssh

    # Generate SSH key as www-data
    echo "Generating SSH key..."
    sudo -u www-data ssh-keygen -t ed25519 -f /var/www/.ssh/id_ed25519 -N ""
    sudo chmod 600 /var/www/.ssh/id_ed25519

    # Ensure the key is readable
    sudo chmod 644 /var/www/.ssh/id_ed25519.pub

    # Display the public key - use sudo to read it to avoid permission issues
    echo "Generated SSH public key for www-data user:"
    sudo cat /var/www/.ssh/id_ed25519.pub
    echo "======================================================================"
    echo "IMPORTANT: Add this public key to your Git repository's deploy keys!"
    echo "======================================================================"

    # Configure git for www-data
    sudo -u www-data git config --global user.name "www-data"
    sudo -u www-data git config --global user.email "www-data@server.com"
else
    echo "Skipping system installation steps (update mode)..."
    # Read existing production branch from config if it exists
    if [ -f "/etc/laravel-deploy/config" ]; then
        echo "Reading existing configuration..."
        source /etc/laravel-deploy/config
        PRODUCTION_BRANCH=${PRODUCTION_BRANCH:-$DEFAULT_PROD_BRANCH}
        echo "Using existing production branch: ${PRODUCTION_BRANCH}"
    else
        echo "No existing configuration found, using default production branch: ${DEFAULT_PROD_BRANCH}"
        PRODUCTION_BRANCH=$DEFAULT_PROD_BRANCH
    fi
fi

# Configure NGINX for Laravel
echo "Creating NGINX server block template for Laravel..."
cat > /tmp/laravel-template.conf << 'EOF'
server {
    listen 80;
    server_name PROJECT_DOMAIN;
    root /var/www/PROJECT_NAME/public;
    
    index index.php index.html index.htm;
    
    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }
    
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.3-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
    
    location ~ /\.ht {
        deny all;
    }
    
    # Add cache headers for static assets
    location ~* \.(css|js|jpg|jpeg|png|gif|ico|svg)$ {
        expires 30d;
        add_header Cache-Control "public, no-transform";
    }
}
EOF

sudo mv /tmp/laravel-template.conf /etc/nginx/sites-available/laravel-template.conf

# Create a config file to store settings
echo "Creating configuration file..."
sudo mkdir -p /etc/laravel-deploy
cat > /tmp/laravel-deploy.conf << EOF
# Laravel Deployment Configuration
PRODUCTION_BRANCH="${PRODUCTION_BRANCH}"
PHP_VERSION="${PHP_VERSION}"
EOF

sudo mv /tmp/laravel-deploy.conf /etc/laravel-deploy/config
sudo chmod 644 /etc/laravel-deploy/config

# Create project setup script
echo "Creating project setup script..."
cat > /tmp/setup-laravel-project << 'EOF'
#!/bin/bash
# Laravel Project Setup Script
# Usage: setup-laravel-project <project_name> <domain_name> <git_repo_url> [production_branch]

# Source configuration
source /etc/laravel-deploy/config

if [ "$#" -lt 3 ]; then
    echo "Usage: setup-laravel-project <project_name> <domain_name> <git_repo_url> [production_branch]"
    exit 1
fi

PROJECT_NAME=$1
DOMAIN_NAME=$2
GIT_REPO_URL=$3
# Use command line branch if specified, otherwise use config file value
BRANCH=${4:-$PRODUCTION_BRANCH}

echo "Setting up Laravel project: $PROJECT_NAME"
echo "Domain: $DOMAIN_NAME"
echo "Git Repository: $GIT_REPO_URL"
echo "Production Branch: $BRANCH"

# Create project directory
if [ -d "/var/www/$PROJECT_NAME" ]; then
    echo "Project directory already exists. Skipping git clone."
else
    echo "Cloning repository..."
    sudo -u www-data git clone $GIT_REPO_URL /var/www/$PROJECT_NAME
    
    if [ $? -ne 0 ]; then
        echo "Failed to clone repository. Check if the SSH key has been added to the repository."
        exit 1
    fi
fi

# Go to project directory
cd /var/www/$PROJECT_NAME

# Checkout specified branch
echo "Checking out $BRANCH branch..."
sudo -u www-data git checkout $BRANCH
sudo -u www-data git pull origin $BRANCH

# Copy environment file if it doesn't exist
if [ ! -f ".env" ]; then
    echo "Creating .env file..."
    sudo -u www-data cp .env.example .env
    
    # Prompt for database information
    echo "===== DATABASE CONFIGURATION ====="
    read -p "Database name: " DB_NAME
    read -p "Database username: " DB_USERNAME
    read -sp "Database password: " DB_PASSWORD
    echo ""  # Add a newline after password input
    read -p "Database host [localhost]: " DB_HOST
    DB_HOST=${DB_HOST:-localhost}
    
    # Create the database user and database
    echo "Setting up database..."
    # First create database and user
    sudo mysql -e "CREATE DATABASE IF NOT EXISTS \`$DB_NAME\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    sudo mysql -e "CREATE USER IF NOT EXISTS '$DB_USERNAME'@'$DB_HOST' IDENTIFIED BY '$DB_PASSWORD';"
    sudo mysql -e "GRANT ALL PRIVILEGES ON \`$DB_NAME\`.* TO '$DB_USERNAME'@'$DB_HOST';"
    sudo mysql -e "FLUSH PRIVILEGES;"

    # Verify the user was created correctly
    echo "Verifying database user..."
    if sudo mysql -e "SELECT User, Host FROM mysql.user WHERE User = '$DB_USERNAME';" | grep -q "$DB_USERNAME"; then
        echo "Database user created successfully."
    else
        echo "ERROR: Failed to create database user."
        exit 1
    fi
    
    # Update the .env file with database information - correctly escape special chars
    echo "Updating .env with database information..."
    sudo -u www-data sed -i "s/DB_HOST=.*/DB_HOST=$DB_HOST/" .env
    sudo -u www-data sed -i "s/DB_DATABASE=.*/DB_DATABASE=$DB_NAME/" .env
    sudo -u www-data sed -i "s/DB_USERNAME=.*/DB_USERNAME=$DB_USERNAME/" .env
    # Use double quotes for variable expansion in the password (in case of special chars)
    sudo -u www-data sed -i "s/DB_PASSWORD=.*/DB_PASSWORD=\"$DB_PASSWORD\"/" .env
    
    # Optional: Ask for APP_URL
    read -p "Application URL [http://$DOMAIN_NAME]: " APP_URL
    APP_URL=${APP_URL:-http://$DOMAIN_NAME}
    sudo -u www-data sed -i "s|APP_URL=.*|APP_URL=$APP_URL|" .env
    
    # Set APP_ENV to production
    sudo -u www-data sed -i "s/APP_ENV=.*/APP_ENV=production/" .env
    sudo -u www-data sed -i "s/APP_DEBUG=.*/APP_DEBUG=false/" .env
    
    echo "Database configuration completed."
fi

# Install dependencies (production only)
echo "Installing composer dependencies (production only)..."
sudo -u www-data composer install --no-dev --optimize-autoloader

# Set proper permissions
echo "Setting proper permissions..."
sudo chown -R www-data:www-data .
sudo chmod -R 755 .
sudo chmod -R 775 storage bootstrap/cache

# Generate application key if needed
if grep -q "APP_KEY=base64:" .env; then
    echo "App key already exists in .env"
else
    echo "Generating application key..."
    sudo -u www-data php artisan key:generate
fi

# Run migrations
echo "Running database migrations..."
sudo -u www-data php artisan migrate --force

#Initial data seed
echo "Running database seeders..."
sudo -u www-data php artisan db:seed --force

#build js and css
sudo -u www-data npm ic
sudo -u www-data npm run build

# Optimize for production
echo "Optimizing Laravel for production..."
sudo -u www-data php artisan config:cache
sudo -u www-data php artisan route:cache
sudo -u www-data php artisan view:cache
sudo -u www-data php artisan optimize

# Create and enable NGINX configuration
echo "Creating NGINX configuration..."
sudo cp /etc/nginx/sites-available/laravel-template.conf /etc/nginx/sites-available/$PROJECT_NAME.conf
sudo sed -i "s/PROJECT_NAME/$PROJECT_NAME/g" /etc/nginx/sites-available/$PROJECT_NAME.conf
sudo sed -i "s/PROJECT_DOMAIN/$DOMAIN_NAME/g" /etc/nginx/sites-available/$PROJECT_NAME.conf

# Update PHP version in the Nginx config if needed
if [ "$PHP_VERSION" != "8.3" ]; then
    sudo sed -i "s/php8.3-fpm.sock/php${PHP_VERSION}-fpm.sock/g" /etc/nginx/sites-available/$PROJECT_NAME.conf
fi

if [ ! -L "/etc/nginx/sites-enabled/$PROJECT_NAME.conf" ]; then
    sudo ln -s /etc/nginx/sites-available/$PROJECT_NAME.conf /etc/nginx/sites-enabled/
fi

# Test NGINX configuration
sudo nginx -t

# Restart NGINX if test passed
if [ $? -eq 0 ]; then
    echo "Restarting NGINX..."
    sudo systemctl restart nginx
else
    echo "NGINX configuration test failed. Please check the configuration."
    exit 1
fi

echo "Laravel project $PROJECT_NAME has been successfully set up!"
echo "Domain: http://$DOMAIN_NAME"
echo ""
echo "IMPORTANT: Don't forget to:"
echo "1. Enable HTTPS by running setup-https <project_name> <domain_name>"
echo "2. Consider securing your .env file with: sudo chmod 640 .env"
EOF

# Create update script
echo "Creating project update script..."
cat > /tmp/update-laravel-project << 'EOF'
#!/bin/bash
# Laravel Project Update Script with Change Detection
# Usage: update-laravel-project <project_name> [production_branch]

# Source configuration
source /etc/laravel-deploy/config

if [ "$#" -lt 1 ]; then
    echo "Usage: update-laravel-project <project_name> [production_branch]"
    exit 1
fi

PROJECT_NAME=$1
# Use command line branch if specified, otherwise use config file value
BRANCH=${2:-$PRODUCTION_BRANCH}
PROJECT_DIR="/var/www/$PROJECT_NAME"

if [ ! -d "$PROJECT_DIR" ]; then
    echo "Error: Project directory $PROJECT_DIR does not exist."
    exit 1
fi

cd $PROJECT_DIR

echo "Updating Laravel project: $PROJECT_NAME (Branch: $BRANCH)"

# Check for local changes
echo "Checking for local changes in $PROJECT_NAME..."
if sudo -u www-data git status --porcelain | grep -q .; then
    echo "WARNING: Local changes detected in project files."
    echo "These changes may conflict with the update from the $BRANCH branch."
    echo ""
    echo "Changes found:"
    sudo -u www-data git status --short
    echo ""
    
    read -p "Would you like to discard these local changes before updating? (y/n): " RESTORE_CHANGES
    if [[ $RESTORE_CHANGES == "y" || $RESTORE_CHANGES == "Y" ]]; then
        echo "Restoring files to original state..."
        sudo -u www-data -H sh -c "cd /var/www/$PROJECT_NAME && git restore ."
        echo "Local changes have been discarded."
    else
        echo "Continuing with update. Note that git may fail to update if there are conflicts."
        echo "If update fails, you can manually restore files with:"
        echo "sudo -u www-data -H sh -c \"cd /var/www/$PROJECT_NAME && git restore .\""
    fi
fi

# Pull latest changes
echo "Pulling latest changes from $BRANCH branch..."
if ! sudo -u www-data git pull origin $BRANCH; then
    echo "ERROR: Failed to pull latest changes."
    echo "This may be due to local modifications conflicting with updates."
    echo "You can restore the project to its original state with:"
    echo "sudo -u www-data -H sh -c \"cd /var/www/$PROJECT_NAME && git restore .\""
    exit 1
fi

# Install dependencies (in case they changed)
echo "Updating composer dependencies..."
sudo -u www-data composer install --no-dev --optimize-autoloader

# Run migrations
echo "Running database migrations..."
sudo -u www-data php artisan migrate --force

#re-build js and css
sudo -u www-data npm ic
sudo -u www-data npm run build

# Clear and rebuild cache
echo "Clearing and rebuilding cache..."
sudo -u www-data php artisan cache:clear
sudo -u www-data php artisan config:clear
sudo -u www-data php artisan route:clear
sudo -u www-data php artisan view:clear

# Optimize for production
echo "Optimizing Laravel for production..."
sudo -u www-data php artisan config:cache
sudo -u www-data php artisan route:cache
sudo -u www-data php artisan view:cache
sudo -u www-data php artisan optimize

# Restart PHP-FPM
echo "Restarting PHP-FPM..."
sudo systemctl restart php${PHP_VERSION}-fpm

echo "Laravel project $PROJECT_NAME has been successfully updated!"
EOF

# Create HTTPS setup script
echo "Creating HTTPS setup script..."
cat > /tmp/setup-https << 'EOF'
#!/bin/bash
# HTTPS Setup Script for Laravel Projects
# Usage: setup-https <project_name> <domain_name>

if [ "$#" -lt 2 ]; then
    echo "Usage: setup-https <project_name> <domain_name>"
    exit 1
fi

PROJECT_NAME=$1
DOMAIN_NAME=$2
PROJECT_DIR="/var/www/$PROJECT_NAME"

if [ ! -d "$PROJECT_DIR" ]; then
    echo "Error: Project directory $PROJECT_DIR does not exist."
    exit 1
fi

# Check if certbot is installed
if ! command -v certbot &> /dev/null; then
    echo "Installing Certbot..."
    sudo apt update
    sudo apt install -y certbot python3-certbot-nginx
fi

# Set up SSL with Certbot
echo "Setting up HTTPS for $DOMAIN_NAME..."
sudo certbot --nginx -d $DOMAIN_NAME

# Update Laravel .env for HTTPS
echo "Updating Laravel environment for HTTPS..."
cd $PROJECT_DIR

# Update APP_URL to use HTTPS
sudo -u www-data sed -i "s|^APP_URL=http://|APP_URL=https://|" .env

# Add or update session security settings
if grep -q "SESSION_SECURE_COOKIE" .env; then
    sudo -u www-data sed -i "s/SESSION_SECURE_COOKIE=.*/SESSION_SECURE_COOKIE=true/" .env
else
    echo "SESSION_SECURE_COOKIE=true" | sudo -u www-data tee -a .env
fi

if grep -q "SESSION_SAME_SITE" .env; then
    sudo -u www-data sed -i "s/SESSION_SAME_SITE=.*/SESSION_SAME_SITE=lax/" .env
else
    echo "SESSION_SAME_SITE=lax" | sudo -u www-data tee -a .env
fi

if grep -q "SESSION_HTTP_ONLY" .env; then
    sudo -u www-data sed -i "s/SESSION_HTTP_ONLY=.*/SESSION_HTTP_ONLY=true/" .env
else
    echo "SESSION_HTTP_ONLY=true" | sudo -u www-data tee -a .env
fi

# Clear Laravel cache
echo "Clearing Laravel cache..."
sudo -u www-data php artisan config:clear
sudo -u www-data php artisan cache:clear
sudo -u www-data php artisan view:clear
sudo -u www-data php artisan route:clear
sudo -u www-data php artisan optimize

echo "HTTPS has been successfully set up for $DOMAIN_NAME!"
echo "Your Laravel application is now accessible via https://$DOMAIN_NAME"
EOF

# Move scripts to proper location and make them executable
sudo mv /tmp/setup-laravel-project /usr/local/bin/
sudo mv /tmp/update-laravel-project /usr/local/bin/
sudo mv /tmp/setup-https /usr/local/bin/
sudo chmod +x /usr/local/bin/setup-laravel-project
sudo chmod +x /usr/local/bin/update-laravel-project
sudo chmod +x /usr/local/bin/setup-https

# Only restart services in full installation mode
if [ "$UPDATE_ONLY" = false ]; then
    echo "Restarting services..."
    sudo systemctl restart nginx
    sudo systemctl restart php${PHP_VERSION}-fpm
fi

echo "===================================================="
if [ "$UPDATE_ONLY" = true ]; then
    echo "    Laravel Deployment Tools Update Complete       "
    echo "===================================================="
    echo ""
    echo "Updated deployment scripts:"
    echo "1. setup-laravel-project"
    echo "2. update-laravel-project" 
    echo "3. setup-https"
    echo ""
    echo "Configuration preserved in /etc/laravel-deploy/config"
else
    echo "    Laravel Deployment Tools Installation Complete   "
    echo "===================================================="
    echo ""
    echo "Production branch set to: ${PRODUCTION_BRANCH}"
    echo ""
    echo "Available commands:"
    echo "1. setup-laravel-project <project_name> <domain_name> <git_repo_url> [branch]"
    echo "2. update-laravel-project <project_name> [branch]"
    echo "3. setup-https <project_name> <domain_name>"
    echo ""
    echo "Don't forget to add the www-data SSH public key to your Git repository's deploy keys!"
    echo ""
    echo "To view the SSH key again:"
    echo "  cat /var/www/.ssh/id_ed25519.pub"
    echo ""
    echo "Configuration is stored in /etc/laravel-deploy/config"
fi
echo "===================================================="
