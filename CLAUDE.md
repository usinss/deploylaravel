# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This repository contains scripts for deploying and managing Laravel applications on Ubuntu 24.04 servers. The tools automate the setup of NGINX, PHP 8.3, MariaDB, and other dependencies required for running Laravel applications in production.

## Key Scripts

- `install.sh`: Main installer script that sets up the complete Laravel deployment environment
- `new_droplet_user.sh`: Creates a new non-root user with sudo privileges (recommended for security)
- `setup.sh`: Initial setup script that downloads and runs both scripts in sequence
- `misc/laravel-serve/laravel-serve.sh`: Development server script with complete cache clearing

## Available Commands After Installation

After the installation process is complete, the following commands become available on the server:

1. **Setting up a new Laravel project**:
   ```bash
   setup-laravel-project <project_name> <domain_name> <git_repo_url> [branch]
   ```

2. **Updating an existing Laravel project**:
   ```bash
   update-laravel-project <project_name> [branch]
   ```

3. **Setting up HTTPS with Let's Encrypt**:
   ```bash
   setup-https <project_name> <domain_name>
   ```

## Deployment Workflow

The typical workflow for setting up a new server and deploying Laravel applications:

1. Create a non-root user with sudo privileges:
   ```bash
   wget https://raw.githubusercontent.com/usinss/deploylaravel/main/new_droplet_user.sh
   chmod +x new_droplet_user.sh
   sudo ./new_droplet_user.sh
   ```

2. After logging in as the new user, install Laravel deployment tools:
   ```bash
   wget https://raw.githubusercontent.com/usinss/deploylaravel/main/install.sh
   chmod +x install.sh
   sudo ./install.sh
   ```

3. To deploy a Laravel application:
   ```bash
   setup-laravel-project myblog example.com git@github.com:username/blog.git main
   ```

4. To enable HTTPS:
   ```bash
   setup-https myblog example.com
   ```

## Development Environment

For local development, the repository includes a Laravel development server script:

```bash
./misc/laravel-serve/laravel-serve.sh
```

This script:
- Clears all Laravel caches
- Rebuilds caches
- Installs npm dependencies
- Builds frontend assets
- Starts the Laravel development server

## Firewall Configuration

The installation script configures UFW (Uncomplicated Firewall) to:
- Allow SSH (port 22)
- Allow HTTP (port 80)
- Allow HTTPS (port 443)
- Block all other incoming connections

## Server Configuration

The installed environment includes:
- NGINX as web server
- PHP 8.3 with required extensions
- MariaDB as database server
- Composer for PHP dependencies
- Git for version control
- Let's Encrypt for SSL certificates