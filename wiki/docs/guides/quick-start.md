# Quick Start Guide

## Overview

HomelabARR CE is a comprehensive Docker-based media server stack that provides automated deployment and management of 100+ self-hosted applications including Plex, Radarr, Sonarr, and more.

## Prerequisites

- **OS**: Ubuntu 18.04+ or Debian 10+ (x86_64)
- **RAM**: 4GB minimum, 8GB+ recommended
- **Storage**: 20GB+ free space
- **Domain**: Valid domain with Cloudflare DNS management
- **Network**: Internet connection for downloads

## Quick Installation

### 1. Download and Setup

```bash
# Clone repository
git clone https://github.com/smashingtags/homelabarr-ce.git
cd homelabarr-ce

# Make scripts executable (CRITICAL)
chmod +x install.sh preinstall/install.sh preinstall/installer/ubuntu.sh
chmod +x .installer/ubuntu.sh .installer/homelabber homelabarr-ce.sh
find scripts/ traefik/ apps/ -name "*.sh" -exec chmod +x {} \;

# Create compatibility symlink
sudo ln -sf "$(pwd)" /opt/homelabarr
```

### 2. Run Installation

```bash
sudo ./install.sh
```

### 3. Installation Menu

Choose from the main menu:

1. **HomelabARR CE - Traefik + Authelia** (run this first)
   - Sets up reverse proxy and authentication
   - Configures SSL certificates
   - Prepares infrastructure

2. **HomelabARR CE - Applications** (run after Traefik)
   - Installs media servers (Plex, Jellyfin)
   - Deploys media managers (Radarr, Sonarr)
   - Sets up download clients (qBittorrent, SABnzbd)

## Quick Troubleshooting

### Permission Errors
```bash
chmod +x install.sh
find . -name "*.sh" -exec chmod +x {} \;
```

### Path Issues
```bash
sudo ln -sf "$(pwd)" /opt/homelabarr
```

### Docker Issues
```bash
# Verify Docker installation
docker --version
docker-compose --version

# If missing, installer will handle it automatically
```

## Next Steps

1. **Configure Domain**: Set up your Cloudflare DNS and API tokens
2. **Setup Authelia**: Configure user authentication
3. **Deploy Applications**: Use the CLI menu to install desired apps
4. **Configure Media Paths**: Set up your media library structure

## Access Your Services

After installation:
- **Main Dashboard**: `https://your-domain.com`
- **Traefik Dashboard**: `https://traefik.your-domain.com`
- **Authentication**: `https://auth.your-domain.com`

## Getting Help

- **Detailed Installation Guide**: [Linux Installation](../install/linux-installation.md)
- **GitHub Issues**: Report bugs and feature requests
- **Documentation**: Full wiki available in this site

---

**Ready to get started?** Run the installation commands above and follow the interactive menu!