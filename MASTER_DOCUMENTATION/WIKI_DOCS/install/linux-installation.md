# Linux Installation Guide

## Overview

This guide covers the complete installation process for HomelabARR CLI on Linux systems (Ubuntu/Debian). The installer has been fixed to work properly from any directory location and includes comprehensive error handling.

## Prerequisites

### System Requirements
- **Operating System**: Ubuntu 18.04+ or Debian 10+
- **Architecture**: x86_64 (ARM not supported)
- **RAM**: Minimum 4GB, Recommended 8GB+
- **Storage**: Minimum 20GB free space
- **CPU**: 2+ cores recommended
- **Network**: Internet connection for container downloads

### Required Dependencies
The installer will automatically install these if missing:
- **Docker**: Latest stable version
- **Docker Compose**: v2.0+
- **Git**: For repository management
- **Curl/Wget**: For downloading components

### Domain and DNS Requirements
- Valid domain name with Cloudflare DNS management
- Cloudflare API token with Zone:Edit permissions
- Subdomain configuration capability

## Installation Process

### Step 1: Download and Prepare

```bash
# Clone the repository
git clone https://github.com/smashingtags/homelabarr-cli.git
cd homelabarr-cli

# Make all scripts executable (CRITICAL - fixes common permission issues)
chmod +x install.sh
chmod +x preinstall/install.sh
chmod +x preinstall/installer/ubuntu.sh
chmod +x .installer/ubuntu.sh
chmod +x .installer/homelabber
chmod +x homelabarr-cli.sh
chmod +x backup.sh
chmod +x quick-deploy.sh

# Make all scripts in subdirectories executable
find scripts/ -name "*.sh" -exec chmod +x {} \;
find traefik/ -name "*.sh" -exec chmod +x {} \;
find apps/ -name "*.sh" -exec chmod +x {} \;
```

### Step 2: Create Symlink (Compatibility Fix)

The installer expects the project to be located at `/opt/homelabarr` but users typically clone to their home directory. Create a symlink to ensure compatibility:

```bash
# Create symlink from expected location to actual location
sudo mkdir -p /opt
sudo ln -sf "$(pwd)" /opt/homelabarr

# Verify symlink creation
ls -la /opt/homelabarr
```

### Step 3: Run the Installation

```bash
# Run the main installer
sudo ./install.sh
```

### Step 4: Installation Menu Navigation

After running the installer, you'll see the main menu:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    🚀 HomelabARR CLI
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    [ 1 ] HomelabARR CLI - Traefik + Authelia
    [ 2 ] HomelabARR CLI - Applications

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    [ EXIT or Z ] - Exit
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

#### Option 1: Traefik + Authelia Setup
- Installs and configures Traefik reverse proxy
- Sets up Authelia authentication
- Configures Cloudflare integration
- Generates SSL certificates
- **Choose this first** for initial setup

#### Option 2: Applications
- Installs Docker Compose applications
- Media servers (Plex, Jellyfin, Emby)
- Media managers (Radarr, Sonarr, Lidarr)
- Download clients (qBittorrent, SABnzbd)
- Request apps (Overseerr, Petio)

## Post-Installation

### Verify Installation

```bash
# Check Docker installation
docker --version
docker-compose --version

# Verify containers are running
docker ps

# Check HomelabARR CLI command
homelabarr-cli --version
```

### Configuration

1. **Domain Configuration**: Update your domain settings in the configuration files
2. **Cloudflare API**: Configure your Cloudflare API tokens
3. **Authelia Setup**: Configure user authentication
4. **SSL Certificates**: Verify automatic certificate generation

### Access Your Services

After successful installation:
- **Main Dashboard**: `https://your-domain.com`
- **Traefik Dashboard**: `https://traefik.your-domain.com`
- **Authelia**: `https://auth.your-domain.com`

## Troubleshooting

### Common Issues and Solutions

#### 1. Permission Denied Errors

**Symptom**: `bash: ./install.sh: Permission denied`

**Solution**:
```bash
# Make all scripts executable
chmod +x install.sh
chmod +x preinstall/install.sh
chmod +x preinstall/installer/ubuntu.sh
chmod +x .installer/ubuntu.sh
find . -name "*.sh" -exec chmod +x {} \;
```

#### 2. Directory Not Found Errors

**Symptom**: `Error: Could not find preinstall directory`

**Solution**:
```bash
# Ensure you're in the correct directory
pwd
ls -la preinstall/

# Create symlink if missing
sudo ln -sf "$(pwd)" /opt/homelabarr
```

#### 3. Docker Installation Issues

**Symptom**: Installer stuck on Docker installation

**Solution**:
```bash
# Install Docker manually
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Log out and back in, then retry
sudo ./install.sh
```

#### 4. Infinite Loop in Installer

**Symptom**: Installer keeps returning to preinstall menu

**Solution**: This was fixed in the latest version. Ensure you have the updated `ubuntu.sh` file:
```bash
# Check Docker installation status
docker --version

# If Docker is installed but installer loops, check the logic in:
cat .installer/ubuntu.sh | grep "command -v docker"
```

#### 5. Missing Preinstall Scripts

**Symptom**: `ubuntu.sh` script not found in `preinstall/installer/`

**Solution**: The installer now includes the missing Ubuntu installation script:
```bash
# Verify the script exists
ls -la preinstall/installer/ubuntu.sh

# If missing, it should be created automatically during installation
```

### Path Compatibility Issues

If you encounter path-related errors:

1. **Verify symlink exists**:
   ```bash
   ls -la /opt/homelabarr
   ```

2. **Recreate symlink if needed**:
   ```bash
   sudo rm -f /opt/homelabarr
   sudo ln -sf "$(pwd)" /opt/homelabarr
   ```

3. **Check working directory**:
   ```bash
   pwd  # Should show your cloned directory path
   ```

### Network Issues

If containers fail to start:

1. **Check Docker network**:
   ```bash
   docker network ls
   docker network inspect proxy
   ```

2. **Recreate proxy network**:
   ```bash
   docker network create proxy
   ```

### Log Analysis

For detailed troubleshooting:

```bash
# Check container logs
docker logs <container_name>

# Check Docker daemon logs
sudo journalctl -u docker.service

# Check system logs
sudo journalctl -xe
```

## Technical Details

### Fixed Issues Summary

The following critical issues were resolved to ensure proper installation:

1. **Path Resolution**: Fixed installer expecting `/opt/homelabarr` when users run from `~/homelabarr-cli`
2. **Missing Scripts**: Created missing `preinstall/installer/ubuntu.sh` for Docker installation
3. **Infinite Loop**: Fixed installer logic that caused endless preinstall loops
4. **Permissions**: Standardized executable permissions across all shell scripts
5. **Symlink Creation**: Automated symlink creation for path compatibility

### Installer Architecture

```
install.sh
├── Detects OS (Ubuntu/Debian)
├── Calls .installer/ubuntu.sh
└── ubuntu.sh
    ├── Checks Docker installation
    ├── Shows main menu if Docker exists
    └── Redirects to preinstall if Docker missing
```

### Directory Structure Post-Install

```
/opt/homelabarr/          # Symlink to actual directory
├── apps/                 # Application Docker Compose files
├── traefik/             # Traefik configuration and templates
├── scripts/             # Maintenance and utility scripts
├── preinstall/          # System preparation scripts
└── .installer/          # Installation scripts
```

## Advanced Configuration

### Environment Variables

Key environment variables to configure:

```bash
# Domain configuration
DOMAIN=your-domain.com
CLOUDFLARE_EMAIL=your-email@domain.com
CLOUDFLARE_API_KEY=your-api-key

# User configuration
PUID=1000
PGID=1000
TZ=America/New_York

# Paths
APPDATA=/opt/appdata
DOWNLOADS=/opt/downloads
MEDIA=/opt/media
```

### Security Hardening

After installation, consider these security measures:

1. **Firewall Configuration**:
   ```bash
   sudo ufw enable
   sudo ufw allow 80/tcp
   sudo ufw allow 443/tcp
   sudo ufw allow 22/tcp
   ```

2. **Fail2Ban Setup**:
   ```bash
   sudo apt install fail2ban
   sudo systemctl enable fail2ban
   ```

3. **Regular Updates**:
   ```bash
   # Update system packages
   sudo apt update && sudo apt upgrade

   # Update Docker containers
   docker-compose pull
   docker-compose up -d
   ```

## Next Steps

After successful installation:

1. **Configure Cloudflare**: Set up DNS records and API tokens
2. **Setup Authelia**: Configure user accounts and authentication
3. **Install Applications**: Choose applications from the CLI menu
4. **Configure Media Paths**: Set up your media library structure
5. **Setup Backups**: Configure automated backup solutions
6. **Monitor System**: Set up monitoring and alerting

## Support and Documentation

- **GitHub Repository**: https://github.com/smashingtags/homelabarr-cli
- **Wiki Documentation**: Available in `wiki/docs/` directory
- **Issue Reporting**: Use GitHub Issues for bug reports
- **Community Support**: Discord/Reddit communities

---

**Note**: This installation process has been tested and verified on Ubuntu 20.04 LTS and Ubuntu 22.04 LTS. Debian 10+ should work with minimal modifications.