# Laravel Deployment Tools

A collection of scripts to quickly set up and manage Laravel applications on Ubuntu 24.04 servers.

## Features

- **Complete Server Setup**: Automatically installs and configures NGINX, PHP 8.3, MariaDB, and all required dependencies
- **Security-Focused**: Includes firewall configuration (UFW), secure MySQL setup, and proper file permissions
- **Project Management**: Easy deployment of multiple Laravel projects on a single server
- **SSL Support**: One-command HTTPS setup using Let's Encrypt certificates
- **Update Tool**: Simple project updates with change detection and conflict handling
- **Development Utilities**: Includes tools for easier local development workflow

## Quick Installation

### Minimal Setup Approach (Recommended)

1. Download the user creation script:
```bash
wget https://raw.githubusercontent.com/usinss/deploylaravel/main/new_droplet_user.sh
```

2. Make it executable:
```bash
chmod +x new_droplet_user.sh
```

3. Execute the script to create a non-root user with sudo privileges:
```bash
sudo ./new_droplet_user.sh
```

4. Log in as the new user, then download the installation script:
```bash
wget https://raw.githubusercontent.com/usinss/deploylaravel/main/install.sh
```

5. Make it executable:
```bash
chmod +x install.sh
```

6. Execute the script to set up Laravel deployment tools:
```bash
sudo ./install.sh
```

### Alternative Method (One-liner)

Create a non-root user with sudo privileges:
```bash
wget -qO- https://raw.githubusercontent.com/usinss/deploylaravel/main/new_droplet_user.sh | sudo bash
```

Then install Laravel deployment tools (login as the new user first):
```bash
wget -qO- https://raw.githubusercontent.com/usinss/deploylaravel/main/install.sh | sudo bash
```

## Security Best Practices

When deploying on a new server (especially Digital Ocean droplets), we recommend:

1. **Create a non-root user first** using `new_droplet_user.sh`
2. **Log in as the new user** with sudo privileges
3. **Then install** the deployment tools using `install.sh`

This approach follows the principle of least privilege for better security.

## Server Requirements

- Ubuntu 24.04 LTS
- Minimum 1GB RAM (2GB+ recommended for production)
- 20GB+ disk space
- Root or sudo access

## Available Commands After Installation

Once installation is complete, you'll have access to the following commands:

### Setting up a new Laravel project

```bash
setup-laravel-project <project_name> <domain_name> <git_repo_url> [branch]
```

Example:
```bash
setup-laravel-project myblog example.com git@github.com:username/blog.git main
```

### Updating an existing Laravel project

```bash
update-laravel-project <project_name> [branch]
```

Example:
```bash
update-laravel-project myblog main
```

### Setting up HTTPS with Let's Encrypt

```bash
setup-https <project_name> <domain_name>
```

Example:
```bash
setup-https myblog example.com
```

## Firewall Configuration

The installation script configures UFW (Uncomplicated Firewall) to:

- Allow SSH (port 22)
- Allow HTTP (port 80)
- Allow HTTPS (port 443)
- Block all other incoming connections

If you lose SSH access after enabling the firewall:
1. Access your server via your provider's console
2. Run: `sudo ufw disable`
3. Reconfigure with: `sudo ufw allow 22/tcp` before enabling again

## Troubleshooting

### SSH Key Issues
```bash
# Check the SSH key
cat /var/www/.ssh/id_ed25519.pub

# Add this key to your Git repository's deploy keys
```

### Database Connection Issues
If your Laravel application cannot connect to MariaDB:
```bash
# Check if MariaDB is running
sudo systemctl status mariadb

# Verify database user has correct permissions
sudo mysql -e "SHOW GRANTS FOR 'your_db_user'@'localhost';"
```

### Permission Problems
```bash
# Fix Laravel directory permissions
sudo chown -R www-data:www-data /var/www/your_project
sudo chmod -R 755 /var/www/your_project
sudo chmod -R 775 /var/www/your_project/storage /var/www/your_project/bootstrap/cache
```

## Development Utilities

### Laravel Serve Utility

The `laravel-serve` utility is a development tool that helps you quickly start a Laravel project with a clean development environment. It:

- Clears all Laravel caches
- Rebuilds caches for optimal performance
- Installs npm dependencies
- Builds frontend assets
- Starts the Laravel development server

#### Installation

Install the utility with a single command:

For system-wide installation (available to all users):
```bash
curl -s https://raw.githubusercontent.com/usinss/deploylaravel/main/misc/laravel-serve/install.sh | sudo bash
```

For user-local installation (only available to current user):
```bash
curl -s https://raw.githubusercontent.com/usinss/deploylaravel/main/misc/laravel-serve/install.sh | bash
```

The installation type is automatically determined:
- With sudo: System-wide installation to /usr/local/bin
- Without sudo: User-local installation to ~/.bin

For the user-local installation, the script will:
- Create a hidden ~/.bin directory in your home folder
- Add this directory to your PATH in ~/.bashrc
- Make the command available after terminal restart or sourcing ~/.bashrc

#### Usage

Navigate to your Laravel project directory and run:

```bash
laravel-serve
```

This will prepare your development environment and start the server at http://127.0.0.1:8000.

## Updating the Deployment Tools

### Quick Update (Scripts Only)

To update only the deployment scripts without reinstalling apps or regenerating configurations:

```bash
# Download the latest version
curl -s -o install.sh https://raw.githubusercontent.com/usinss/deploylaravel/main/install.sh

# Make it executable
chmod +x install.sh

# Run in update mode
sudo ./install.sh --update
```

This will:
- Update the `setup-laravel-project`, `update-laravel-project`, and `setup-https` scripts
- Preserve existing SSH keys and configuration
- Skip system package installation and service restarts
- Maintain existing production branch settings

### Full Reinstallation

For a complete reinstallation (useful when upgrading server components):

```bash
# Download the latest version
curl -s -o install.sh https://raw.githubusercontent.com/usinss/deploylaravel/main/install.sh

# Make it executable
chmod +x install.sh

# Run the full installer
sudo ./install.sh
```

**Note**: The `--update` flag is recommended for most use cases as it's faster and preserves your existing configuration.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the GNU General Public License v3.0

This license ensures that all modified versions of this software must also remain open source, protecting the freedom to use, modify, and share this code for everyone.

For the full text of the license, please see: https://www.gnu.org/licenses/gpl-3.0.en.html
