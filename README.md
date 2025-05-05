# Laravel Deployment Tools

A comprehensive set of scripts for setting up and managing Laravel applications on Ubuntu 24.04 servers, with security best practices built-in.

## Overview

This toolset simplifies the deployment and maintenance of Laravel applications on a production server. It includes:

- **Automated server setup**: PHP, Nginx, MariaDB, and more
- **Project deployment**: Easy setup for multiple Laravel projects
- **HTTPS configuration**: One-command SSL setup with Let's Encrypt
- **Security features**: Firewall configuration and user management
- **Maintenance tools**: Project update scripts with change detection

## Security First Installation (Recommended for Digital Ocean)

When deploying on a Digital Ocean droplet (or any new server), we recommend following these security best practices:

1. **Create a non-root user** first using the provided script
2. **Then install** the Laravel deployment tools as the new user

### Step 1: Create a Non-Root User (Digital Ocean Droplets)

Log in to your server as the root user, then:

```bash
# Download the user creation script
wget https://raw.githubusercontent.com/yourusername/laravel-deployment-tools/main/new_droplet_user.sh

# Make it executable
chmod +x new_droplet_user.sh

# Run the script
sudo ./new_droplet_user.sh
```

The script will:
- Create a new user with sudo privileges
- Set up SSH keys for the new user
- Configure secure permissions

### Step 2: Log in as the New User

After creating the new user, log out of the root account and log in as the new user:

```bash
ssh your_new_username@your_server_ip
```

### Step 3: Install Laravel Deployment Tools

Now as the new user with sudo privileges, run:

```bash
# Download the installation script
wget https://raw.githubusercontent.com/yourusername/laravel-deployment-tools/main/install.sh

# Make it executable
chmod +x install.sh

# Run the installer
sudo ./install.sh
```

## Standard Installation (For Secure Environments)

If you're in a secure environment or have already set up a non-root user:

```bash
# Download the installation script
wget https://raw.githubusercontent.com/yourusername/laravel-deployment-tools/main/install.sh

# Make it executable
chmod +x install.sh

# Run the installer
sudo ./install.sh
```

## What Gets Installed

The installer sets up:

- **Firewall (UFW)**: Configured to allow only HTTP (80), HTTPS (443), and SSH (22)
- **Nginx**: Web server optimized for Laravel
- **MariaDB**: Database server with secure configuration
- **PHP 8.3**: With all extensions Laravel needs
- **Composer**: For PHP dependency management
- **Let's Encrypt tools**: For SSL certificates
- **Deployment scripts**: For managing Laravel projects

## Available Commands

After installation, you'll have access to these commands:

### `setup-laravel-project`

Sets up a new Laravel project from a Git repository.

```bash
setup-laravel-project <project_name> <domain_name> <git_repo_url> [branch]
```

Example:
```bash
setup-laravel-project myblog example.com git@github.com:username/blog.git main
```

### `update-laravel-project`

Updates an existing Laravel project.

```bash
update-laravel-project <project_name> [branch]
```

Example:
```bash
update-laravel-project myblog main
```

### `setup-https`

Sets up HTTPS for a project using Let's Encrypt.

```bash
setup-https <project_name> <domain_name>
```

Example:
```bash
setup-https myblog example.com
```

## Security Features

This toolset implements several security best practices:

- **Firewall configuration**: Only essential ports are open
- **MariaDB security**: Automated secure setup
- **HTTPS support**: Easy SSL certificate setup
- **Non-root deployment**: Projects use www-data user
- **Secure file permissions**: Properly set for Laravel directories
- **Session security**: Secure cookie configuration

## Firewall Configuration

The installer sets up UFW (Uncomplicated Firewall) with these rules:

- **Default policy**: Deny all incoming traffic, allow all outgoing traffic
- **SSH (Port 22)**: Allowed for secure shell access
- **HTTP (Port 80)**: Allowed for web traffic
- **HTTPS (Port 443)**: Allowed for secure web traffic

### Important: Firewall Safety Measures

The installation script includes several safety measures to prevent lockouts:

1. SSH access is configured first, before any restrictive rules
2. Verification step to confirm SSH rule was properly added
3. Optional confirmation prompt before enabling the firewall
4. Fallback option if SSH rule wasn't added correctly

### Recovering from Firewall Lockout

If you lose SSH access after enabling the firewall:

1. Access your server via your cloud provider's console (e.g., Digital Ocean's Console)
2. Login and run: `sudo ufw disable`
3. Reconfigure the firewall with: `sudo ufw allow 22/tcp` before enabling again

### Managing the Firewall

To check your firewall status:

```bash
sudo ufw status verbose
```

To allow additional ports if needed:

```bash
sudo ufw allow <port_number>/tcp
```

To disable the firewall if necessary:

```bash
sudo ufw disable
```

## Troubleshooting

### SSH Key Issues

If you have problems connecting to your Git repositories:

```bash
# Check the SSH key
cat /var/www/.ssh/id_ed25519.pub

# Make sure you've added this key to your Git repository's deploy keys
```

### Firewall Issues

If you need to access additional services:

```bash
# Allow new port
sudo ufw allow <port_number>/tcp

# Check firewall status
sudo ufw status verbose
```

### Permission Problems

If you encounter "Permission denied" errors:

```bash
# Fix Laravel directory permissions
sudo chown -R www-data:www-data /var/www/your_project
sudo chmod -R 755 /var/www/your_project
sudo chmod -R 775 /var/www/your_project/storage /var/www/your_project/bootstrap/cache
```

## Updating the Scripts

To update these tools to the latest version:

```bash
# Download the latest version
wget https://raw.githubusercontent.com/yourusername/laravel-deployment-tools/main/install.sh

# Make it executable
chmod +x install.sh

# Run the installer
sudo ./install.sh
```

## License

[MIT License](LICENSE)

## Contributions

Contributions are welcome! Please feel free to submit a Pull Request.
