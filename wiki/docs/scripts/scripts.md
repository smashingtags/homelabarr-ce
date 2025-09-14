![Image of HomelabARR CLI](/img/container_images/docker-homelabarr-cli.png)

<p align="left">
    <a href="https://discord.gg/Pc7mXX786x">
        <img src="https://discord.com/api/guilds/830478558995415100/widget.png?label=Discord%20Server&logo=discord" alt="Join HomelabARR CLI on Discord">
    </a>
        <a href="https://github.com/smashingtags/homelabarr-cli/releases">
        <img src="https://img.shields.io/github/downloads/smashingtags/homelabarr-cli/total?label=Total%20Downloads&logo=github" alt="Total Releases Downloaded from GitHub">
    </a>
    <a href="https://github.com/smashingtags/homelabarr-cli/releases/latest">
        <img src="https://img.shields.io/github/v/release/smashingtags/homelabarr-cli?include_prereleases&label=Latest%20Release&logo=github" alt="Latest Official Release on GitHub">
    </a>
    <a href="https://github.com/smashingtags/homelabarr-cli/blob/main/LICENSE">
        <img src="https://img.shields.io/github/license/smashingtags/homelabarr-cli?label=License&logo=gnu" alt="GNU General Public License">
    </a>
</p>

# HomelabARR CLI Scripts

HomelabARR CLI includes a comprehensive collection of utility scripts for maintenance, automation, and system management. These scripts help keep your media server stack running smoothly and efficiently.

## 🧹 Maintenance Scripts

### YAML Cleanup Script

**Location:** `/clean-yaml-files.sh`

**Purpose:** Standardizes and cleans up YAML installer files across the entire application library.

```bash
# Run YAML cleanup (from root directory)
sudo ./clean-yaml-files.sh
```

**What it does:**
- Removes metadata junk (author comments, shebang lines)
- Ensures all YAML files start with proper `---` delimiter
- Standardizes format for consistency and reliability
- Processes 489+ YAML files across all application categories

**Features:**
- ✅ Safe processing with temporary file backup
- 📄 Detailed progress reporting
- 🛑 Skips empty files automatically
- 📏 Handles both `services:` and `version:` YAML formats

### Docker Maintenance

**Docker System Cleanup:**
```bash
# Remove unused containers, networks, images
sudo ./scripts/docker/dockerprune.sh
```

**Backup All Containers:**
```bash
# Create backup of all container configurations
sudo ./backup.sh
```

**Disk Cleanup:**
```bash
# Clean up system disk space
sudo ./scripts/disk_cleanup.sh
```

## 🎬 Plex Specific Scripts

### Plex Database Optimization
```bash
# Optimize Plex database for better performance
sudo ./scripts/plex/plex-optimize-db.sh
```

### Plex Trash Management
```bash
# Empty Plex trash to free up disk space
sudo ./scripts/plex/plex-empty-trash.sh
```

## 🔒 Security Scripts

### IP Banning
```bash
# Ban malicious IPs from accessing your server
sudo ./scripts/security/badips.sh

# General IP banning utility
sudo ./scripts/security/bann.sh

# Traefik-specific IP banning
sudo ./scripts/security/traefik-bann.sh
```

## 📊 Monitoring Scripts

### System Health Checks
```bash
# Check system resources and container status
sudo ./scripts/monitoring/health-check.sh
```

### Log Management
```bash
# Rotate and manage container logs
sudo ./scripts/logging/log-rotation.sh
```

## 🔄 Automation Scripts

### Automatic Updates
```bash
# Update all containers to latest versions
sudo ./scripts/automation/update-containers.sh
```

### Scheduled Maintenance
```bash
# Setup automated maintenance tasks
sudo ./scripts/automation/setup-cron.sh
```

## 🛠️ How to Use Scripts

### Prerequisites
- Ubuntu/Debian system with Docker installed
- Root or sudo access
- HomelabARR CLI installed

### General Usage
1. Navigate to the HomelabARR CLI directory
2. Make scripts executable: `chmod +x script-name.sh`
3. Run with sudo: `sudo ./script-name.sh`

### Safety Tips
- ⚠️ Always backup your data before running maintenance scripts
- 📋 Review script contents before execution
- 🗺 Test in a non-production environment first
- 📝 Check logs after script execution

## 🔍 Script Categories

| Category | Location | Purpose |
|----------|----------|----------|
| **Docker** | `/scripts/docker/` | Container management and cleanup |
| **Plex** | `/scripts/plex/` | Plex server optimization |
| **Security** | `/scripts/security/` | Security and access control |
| **Monitoring** | `/scripts/monitoring/` | System health and performance |
| **Automation** | `/scripts/automation/` | Automated maintenance tasks |
| **Backup** | `/scripts/backup/` | Data backup and restore |

## 📚 Advanced Usage

### Creating Custom Scripts

```bash
# Template for new scripts
#!/bin/bash

# Script Name: custom-script.sh
# Purpose: Describe what your script does
# Author: Your Name

echo "Starting custom maintenance task..."

# Your script logic here

echo "Custom maintenance task completed!"
```

### Scheduling Scripts

```bash
# Add to crontab for automated execution
crontab -e

# Example: Run YAML cleanup weekly
0 2 * * 0 /path/to/homelabarr-cli/clean-yaml-files.sh

# Example: Run Docker cleanup daily
0 3 * * * /path/to/homelabarr-cli/scripts/docker/dockerprune.sh
```

### Logging Script Output

```bash
# Redirect output to log file
sudo ./clean-yaml-files.sh >> /var/log/homelabarr-maintenance.log 2>&1

# View maintenance logs
tail -f /var/log/homelabarr-maintenance.log
```

## 🎆 Script Highlights

### Recent Additions

**🧹 YAML Cleanup Script (Latest)**
- Standardized 489+ YAML files
- Improved deployment reliability
- Automated maintenance workflow
- Consistent formatting across all applications

## 📝 Contributing Scripts

Want to contribute your own scripts? We welcome community contributions!

1. Fork the repository
2. Create your script in the appropriate `/scripts/` subdirectory
3. Follow our coding standards and add documentation
4. Submit a pull request

## 📚 Documentation

For more detailed information:
- [Maintenance Scripts](maintenance.md) - Deep dive into system maintenance
- [Security Scripts](security.md) - Advanced security configurations
- [Automation Scripts](automation.md) - Setting up automated workflows

## Support

Kindly report any issues/broken-parts/bugs on [github](https://github.com/smashingtags/homelabarr-cli/issues) or [discord](https://discord.gg/Pc7mXX786x)

**☕ [Support Development](https://ko-fi.com/homelabarr)** - Help keep HomelabARR CLI scripts growing and improving!

- Join our [![Discord: https://discord.gg/Pc7mXX786x](https://img.shields.io/badge/Discord-gray.svg?style=for-the-badge)](https://discord.gg/Pc7mXX786x) for Support
