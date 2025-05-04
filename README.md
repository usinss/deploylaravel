# Laravel Deployment Tools

A comprehensive suite of deployment scripts for Laravel applications on Ubuntu 24.04 servers.

## Overview

This repository contains a set of scripts designed to automate the setup, deployment, and maintenance of Laravel applications in production environments. The tools provide a streamlined workflow for deploying pre-built Laravel projects without requiring Node.js on the production server.

## Features

- **Complete Server Setup**: Automates the installation of NGINX, MariaDB, PHP, Composer, and all required dependencies
- **Configurable Production Branch**: Deploy from any branch of your repository (default: DEMO)
- **SSH Key Management**: Automatically generates and configures SSH keys for secure Git operations
- **Database Configuration**: Interactive database setup with validation and proper security
- **HTTPS Support**: Easy SSL certificate setup via Let's Encrypt
- **Update Management**: Update deployed projects with local change detection and conflict resolution
- **PHP Version Flexibility**: Configurable PHP version support

## Requirements

- Ubuntu 24.04 LTS server
- Root or sudo access
- Git repository with a Laravel project

## Installation

1. Clone this repository to your Ubuntu 24.04 server:

```bash
git clone https://github.com/username/laravel-deployment-tools.git
cd laravel-deployment-tools
chmod +x install.sh
```

2. Run the installer:

```bash
sudo ./install.sh
```

3. During installation, you'll be prompted to select your production branch name. The default is "DEMO".

4. After installation, you'll receive an SSH public key that must be added to your Laravel project's repository as a deploy key.

## Available Commands

After installation, the following commands will be available:

### 1. Setup Laravel Project

```bash
# Usage:
sudo setup-laravel-project <project_name> <domain_name> <git_repo_url> [branch]

# Example:
sudo setup-laravel-project myapp example.com git@github.com:username/myapp.git
```

This command:
- Clones your Laravel repository
- Checks out the production branch
- Sets up the database (interactive)
- Configures NGINX
- Runs Laravel migrations
- Optimizes for production

### 2. Update Laravel Project

```bash
# Usage:
sudo update-laravel-project <project_name> [branch]

# Example:
sudo update-laravel-project myapp
```

This command:
- Detects local changes and offers to discard them
- Pulls latest changes from the production branch
- Updates Composer dependencies
- Runs migrations
- Rebuilds Laravel cache

### 3. Setup HTTPS

```bash
# Usage:
sudo setup-https <project_name> <domain_name>

# Example:
sudo setup-https myapp example.com
```

This command:
- Installs Certbot if needed
- Obtains and configures SSL certificates
- Updates Laravel environment for secure cookies
- Clears Laravel cache

## Preparing Your Laravel Project for Deployment

For optimal deployment, your Laravel project should have a dedicated production branch with pre-compiled assets. In your development environment:

1. Checkout your production branch (e.g., DEMO):
```bash
git checkout -b DEMO
```

2. Install and build assets:
```bash
npm ci
npm run build  # or npm run prod for Laravel Mix
```

3. Force add the built assets:
```bash
git add public/build -f  # for Vite
# OR
git add public/css -f    # for Laravel Mix
git add public/js -f     # for Laravel Mix
```

4. Ensure your `.env.example` is properly configured for production
5. Commit and push the changes

## Configuration

The deployment tools store configuration in `/etc/laravel-deploy/config`. You can edit this file to change settings like:

- `PRODUCTION_BRANCH`: The default branch to deploy from
- `PHP_VERSION`: PHP version to use

## Troubleshooting

### SSH Key Issues

If deployment fails with SSH errors:
```bash
# View the SSH public key again
cat /var/www/.ssh/id_ed25519.pub

# Make sure this key is added to your repository's deploy keys
```

### Database Connection Errors

If you encounter database connection issues:
```bash
# Check if the database user exists
sudo mysql -e "SELECT User, Host FROM mysql.user WHERE User = 'your_db_user';"

# Create or update database user
sudo mysql -e "CREATE USER IF NOT EXISTS 'your_db_user'@'localhost' IDENTIFIED BY 'your_password';"
sudo mysql -e "GRANT ALL PRIVILEGES ON your_database.* TO 'your_db_user'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"
```

### HTTPS/SSL Issues

For 419 "Page Expired" errors after setting up HTTPS:
```bash
# Update your .env file with proper session settings
cd /var/www/your_project_name
sudo nano .env

# Add or update these lines:
# SESSION_SECURE_COOKIE=true
# SESSION_SAME_SITE=lax
# SESSION_HTTP_ONLY=true

# Clear Laravel cache
sudo -u www-data php artisan config:clear
sudo -u www-data php artisan cache:clear
```

## License

MIT License - Feel free to use and modify these scripts for your own projects.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.