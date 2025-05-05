# Laravel Deployment Tools

A collection of scripts to quickly set up and manage Laravel applications on Ubuntu 24.04 servers.

## Features

- **Complete Server Setup**: Automatically installs and configures NGINX, PHP 8.3, MariaDB, and all required dependencies
- **Security-Focused**: Includes firewall configuration (UFW), secure MySQL setup, and proper file permissions
- **Project Management**: Easy deployment of multiple Laravel projects on a single server
- **SSL Support**: One-command HTTPS setup using Let's Encrypt certificates
- **Update Tool**: Simple project updates with change detection and conflict handling

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

## Updating the Deployment Tools

To update to the latest version:

```bash
# Download the latest version
curl -s -o install.sh https://raw.githubusercontent.com/usinss/deploylaravel/main/install.sh

# Make it executable
chmod +x install.sh

# Run the installer
sudo ./install.sh
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.

This license ensures that all modified versions of this software must also remain open source, protecting the freedom to use, modify, and share this code for everyone.

For the full text of the license, please see: https://www.gnu.org/licenses/gpl-3.0.en.html
