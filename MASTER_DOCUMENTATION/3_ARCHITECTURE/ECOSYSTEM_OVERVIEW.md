# HomelabARR Ecosystem Complete Guide
**Date: August 18, 2025**

## 📋 Overview

HomelabARR is a comprehensive self-hosted media server ecosystem that simplifies the deployment and management of 100+ containerized applications. The ecosystem provides a unified platform for media automation, monitoring, and cloud integration with multiple deployment options to suit different user needs and technical requirements.

### Core Philosophy
- **Unified Deployment**: Single CLI tool managing diverse application stacks
- **Flexible Architecture**: Support for both production and testing environments
- **Community-Driven**: Open-source development with active Discord community
- **Professional Grade**: Enterprise-ready security and monitoring capabilities

---

## 🏗️ Ecosystem Architecture

### Repository Components

The HomelabARR ecosystem consists of multiple interconnected repositories:

#### **homelabarr-cli** (Main Repository)
- **Purpose**: Primary CLI deployment tool and application catalog
- **Location**: [github.com/smashingtags/homelabarr-cli](https://github.com/smashingtags/homelabarr-cli)
- **Key Features**: 
  - 100+ pre-configured Docker Compose applications
  - Traefik reverse proxy integration
  - Authelia authentication system
  - Local and production deployment modes
  - Comprehensive monitoring stack

#### **homelabarr-web-interface** (React Web UI)
- **Purpose**: Modern web interface for container management
- **Integration**: CLI-based Docker deployment without socket dependencies
- **Features**:
  - Real-time container monitoring
  - Cross-platform compatibility (Windows/Linux/macOS)
  - 90+ application templates
  - Live deployment progress tracking

#### **homelabarr-uploader** (Automated Upload Service)
- **Purpose**: Cloud upload automation for completed downloads
- **Features**:
  - Multi-cloud provider support (Google Drive, Backblaze, OneDrive, pCloud)
  - Autoscan integration for media library updates
  - Bandwidth limiting and scheduling
  - Apprise notification support

#### **homelabarr-containers** (Custom Container Library)
- **Purpose**: Additional specialized container definitions
- **Content**: Enhanced and optimized container configurations

#### **homelabarr-assets** (Shared Resources)
- **Purpose**: Common assets, documentation, and branding materials
- **Content**: Icons, templates, and shared configuration files

#### **local-persist** (Volume Persistence Plugin)
- **Purpose**: Docker volume persistence in custom host locations
- **Features**:
  - Static Go binary for maximum compatibility
  - Containerized deployment
  - Essential for HomelabARR volume management

### Network Topology
```
┌─────────────────────────────────────────────────────────────────┐
│                        Traefik Reverse Proxy                    │
│                      (SSL/TLS Termination)                      │
└─────────────────────┬───────────────────────────────────────────┘
                      │
                ┌─────┴─────┐
                │   proxy   │ (Docker Network)
                │  Network  │
                └─────┬─────┘
      ┌───────────────┼───────────────┐
      │               │               │
┌─────▼─────┐  ┌─────▼─────┐  ┌─────▼─────┐
│ Web UI    │  │ Uploader  │  │  Mount    │
│ Frontend  │  │ Service   │  │ Enhanced  │
│ + Backend │  │           │  │           │
└───────────┘  └───────────┘  └───────────┘
      │               │               │
      └───────────────┼───────────────┘
                      │
                ┌─────▼─────┐
                │   Local   │
                │  Persist  │
                │  Plugin   │
                └───────────┘
```

---

## 🚀 Installation Methods

### Method 1: CLI-Based Installers

#### Local Mode (No Domain Required)
**Perfect for testing, development, and local network access**

**Quick Start Command:**
```bash
cd ~ && sudo rm -rf homelabarr-cli 2>/dev/null; git clone https://github.com/smashingtags/homelabarr-cli.git && cd homelabarr-cli && chmod +x setup-local-mode.sh && ./setup-local-mode.sh
```

**Step-by-Step Process:**
```bash
# 1. Clone repository
git clone https://github.com/smashingtags/homelabarr-cli.git
cd homelabarr-cli

# 2. Configure local mode
chmod +x setup-local-mode.sh
./setup-local-mode.sh

# 3. Launch interactive deployment
./deploy-local.sh
```

**Local Mode Features:**
- Direct IP:PORT access (e.g., http://localhost:32400)
- No domain or Cloudflare setup required
- 150+ pre-converted applications available
- Perfect for home lab testing and development
- Immediate deployment without reverse proxy complexity

**Use Cases:**
- Local network access only
- Testing and development
- Learning HomelabARR CLI
- Quick prototype deployments
- Home lab environments

#### Traefik Mode (Production with Domain)
**Full-featured production deployment with security and SSL**

**Installation Commands:**
```bash
# 1. Clone and prepare
git clone https://github.com/smashingtags/homelabarr-cli.git
cd homelabarr-cli
chmod +x install.sh

# 2. Run production installer
sudo ./install.sh

# 3. Access CLI interface
sudo homelabarr-cli -i
```

**Prerequisites for Traefik Mode:**
- Valid domain name with Cloudflare DNS management
- Cloudflare Global API Key and Zone ID
- Ubuntu 22.04 LTS or Debian 11+
- 4GB RAM minimum, 20GB disk space
- 2 CPU cores minimum

**Production Features:**
- Traefik reverse proxy with automatic SSL
- Authelia multi-factor authentication
- Cloudflare integration for DNS and DDoS protection
- Domain-based access (e.g., https://plex.yourdomain.com)
- Enterprise-grade security and monitoring

### Method 2: Web-Based Installer
**Modern React interface for visual deployment management**

**Access Method:**
```bash
# Deploy web interface component
sudo docker-compose -f apps/system/homelabarr-web-interface.yml up -d

# Access web interface
# https://homelabarr.yourdomain.com (Traefik mode)
# http://localhost:3000 (Local mode)
```

**Web Interface Features:**
- Visual application browser with 90+ templates
- Real-time deployment progress tracking
- Container status monitoring and logs
- Cross-platform compatibility
- No Docker socket dependencies (CLI-based deployment)

**Configuration Through UI:**
- Point-and-click application deployment
- Environment variable management
- Container resource allocation
- Network configuration
- Volume persistence settings

**Advantages:**
- User-friendly interface for non-technical users
- Visual feedback during deployments
- Integrated documentation and help
- Mobile-responsive design
- Real-time status updates

### Method 3: Complete Ecosystem
**Full integration deployment with all services working together**

**Ecosystem Installation:**
```bash
# 1. Clone main repository
git clone https://github.com/smashingtags/homelabarr-cli.git
cd homelabarr-cli

# 2. Run complete ecosystem installer
chmod +x install-ecosystem.sh
sudo ./install-ecosystem.sh

# 3. Configure environment
sudo nano .env

# 4. Deploy integrated services
sudo docker-compose -f ecosystem-integration.yml up -d
```

**Ecosystem Components Deployed:**
- **Local Persist Plugin**: Advanced volume management
- **Enhanced Mount Service**: Multi-cloud storage integration
- **Uploader Service**: Automated cloud upload pipeline
- **Web Interface**: React-based management frontend
- **Backend API**: RESTful service integration
- **Network Infrastructure**: Unified Docker networking

**Complete Ecosystem Benefits:**
- Seamless integration between all components
- Unified volume and network management
- Automated upload and processing pipelines
- Centralized monitoring and logging
- Production-ready scalability

---

## 📖 Command Reference

### Installation Commands

#### Core Installation
```bash
# Full production installation
sudo ./install.sh

# Local mode installation
./install-local.sh

# Complete ecosystem installation
sudo ./install-ecosystem.sh

# Traefik stack installation
sudo ./traefik/install.sh
```

#### Selective Installation
```bash
# Web interface only
sudo ./install-ecosystem.sh -m web-only

# Uploader service only
sudo ./install-ecosystem.sh -m uploader-only

# Essential services only
sudo ./install-ecosystem.sh -m minimal
```

### Deployment Commands

#### Local Mode Deployment
```bash
# Interactive deployment menu
./deploy-local.sh

# Quick popular stack deployment
./deploy-local.sh --quick-stack

# Specific application deployment
docker-compose -f apps/local-mode-apps/plex.yml up -d
```

#### Application-Specific Deployment
```bash
# Deploy single application
sudo ./apps/install.sh

# Deploy by category
sudo docker-compose -f apps/mediaserver/plex.yml up -d
sudo docker-compose -f apps/mediamanager/radarr.yml up -d
sudo docker-compose -f apps/downloadclients/qbittorrent.yml up -d
```

### Management Commands

#### Container Management
```bash
# View running containers
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Container logs
docker logs <container_name> -f

# Container stats
docker stats

# Health checks
docker inspect <container_name> | jq '.[0].State.Health'
```

#### System Maintenance
```bash
# Docker system cleanup
sudo ./scripts/docker/dockerprune.sh

# Disk cleanup
sudo ./scripts/disk_cleanup.sh

# Backup all containers
sudo ./backup.sh
```

### Testing Commands

#### Local Testing
```bash
# Test ecosystem components
./test-ecosystem.sh

# Validate configurations
./apps/.config/validate-configs.sh

# Port conflict resolution
./apps/.config/fix-port-conflicts.sh auto
```

#### Integration Testing
```bash
# Test service connectivity
curl -I http://localhost:32400/web/index.html  # Plex
curl -I http://localhost:7878/api/v3/system/status  # Radarr
curl -I http://localhost:8989/api/v3/system/status  # Sonarr

# Test backend API
curl -X GET https://api.yourdomain.com/api/containers
curl -X GET https://api.yourdomain.com/health
```

### Ecosystem Commands

#### Complete Ecosystem Management
```bash
# Deploy complete ecosystem
sudo docker-compose -f ecosystem-integration.yml up -d

# View ecosystem logs
sudo docker-compose -f ecosystem-integration.yml logs -f

# Restart ecosystem services
sudo docker-compose -f ecosystem-integration.yml restart

# Stop ecosystem
sudo docker-compose -f ecosystem-integration.yml down
```

---

## 🧪 Testing Guide

### Local Testing

#### How to Test Locally
1. **Clone Repository:**
   ```bash
   git clone https://github.com/smashingtags/homelabarr-cli.git
   cd homelabarr-cli
   ```

2. **Setup Local Environment:**
   ```bash
   ./setup-local-mode.sh
   cp .env.example .env
   # Edit .env with your local settings
   ```

3. **Deploy Test Applications:**
   ```bash
   ./deploy-local.sh
   # Select option 1 for popular stack
   # Or option 50 to browse all applications
   ```

#### Verification Steps
```bash
# Check Docker installation
docker --version
docker-compose --version

# Verify container health
docker ps --filter "status=running"

# Test application access
curl -I http://localhost:32400  # Plex
curl -I http://localhost:7878   # Radarr
curl -I http://localhost:8989   # Sonarr
```

#### Common Test Scenarios
1. **Media Server Stack:**
   - Deploy Plex, Jellyfin, or Emby
   - Verify web interface accessibility
   - Test media library scanning

2. **Download Automation:**
   - Deploy qBittorrent, Radarr, Sonarr
   - Test API connectivity between services
   - Verify download processing workflow

3. **Monitoring Stack:**
   - Deploy Grafana, Prometheus, Netdata
   - Verify metrics collection
   - Test dashboard functionality

### Integration Testing

#### Testing Ecosystem Components
```bash
# 1. Local Persist Plugin Testing
sudo docker exec homelabarr_local_persist test -S /run/docker/plugins/local-persist.sock

# 2. Mount Service Testing
sudo docker exec homelabarr_mount_enhanced df -h
sudo docker exec homelabarr_mount_enhanced ls -la /mnt

# 3. Uploader Service Testing
sudo docker logs homelabarr_uploader
sudo docker exec homelabarr_uploader rclone config show

# 4. Web Interface Testing
curl -I http://localhost:3000
curl -X GET http://localhost:3001/api/health
```

#### Validation Commands
```bash
# Configuration validation
./apps/.config/validate-configs.sh

# Network connectivity testing
sudo docker exec homelabarr_backend curl -I http://mount-enhanced:8080/health
sudo docker exec homelabarr_backend curl -I http://homelabarr-uploader:9999/health

# Volume persistence testing
sudo docker volume create -d local-persist -o mountpoint=/tmp/test-volume --name test-volume
ls -la /tmp/test-volume
sudo docker volume rm test-volume
```

---

## 🌐 Production Deployment

### Prerequisites

#### System Requirements
- **Operating System**: Ubuntu 22.04 LTS (Stable) or Debian 11+
- **CPU**: 2 Cores minimum (x86/x64 architecture)
- **RAM**: 4GB minimum (8GB recommended for full stack)
- **Storage**: 20GB minimum (100GB+ recommended for media)
- **Server Type**: VPS, VM, or Dedicated Server

#### Network Requirements
- **Domain**: Valid domain name with Cloudflare DNS management
- **SSL**: Cloudflare account (free tier sufficient)
- **Ports**: 80, 443 accessible from internet
- **IP**: Static IP address recommended

#### Software Prerequisites
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install required packages
sudo apt install -y curl wget git

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

### Step-by-Step Deployment

#### 1. Domain and Cloudflare Setup
```bash
# Required Cloudflare settings:
# - SSL = FULL (not FULL/STRICT)
# - Always on = YES
# - HTTP to HTTPS = YES
# - RocketLoader and Brotli/Onion Routing = NO
# - TLS min = 1.2
# - TLS = v1.3

# Add A-Record pointing to server IP
# Obtain Cloudflare Global API Key and Zone ID
```

#### 2. Repository Setup
```bash
# Clone repository
git clone https://github.com/smashingtags/homelabarr-cli.git
cd homelabarr-cli

# Make installation script executable
chmod +x install.sh
```

#### 3. Production Installation
```bash
# Run interactive installer
sudo ./install.sh

# Follow prompts for:
# - Domain configuration
# - Cloudflare API credentials
# - User account creation
# - Application selection
```

#### 4. Environment Configuration
```bash
# Edit environment variables
sudo nano .env

# Key variables to configure:
DOMAIN=yourdomain.com
CLOUDFLARE_EMAIL=your-email@domain.com
CLOUDFLARE_API_KEY=your-cloudflare-api-key
APPDATA=/opt/appdata
DOWNLOADFOLDER=/mnt/downloads
AUTH_ENABLED=true
```

#### 5. Service Deployment
```bash
# Deploy Traefik stack first
sudo ./traefik/install.sh

# Deploy applications
sudo homelabarr-cli -i

# Or deploy ecosystem
sudo ./install-ecosystem.sh
```

### Post-Deployment Verification

#### Health Checks
```bash
# Verify Traefik is running
sudo docker logs traefik

# Check certificate generation
sudo docker logs cf-companion

# Verify Authelia authentication
sudo docker logs authelia

# Test application access
curl -I https://plex.yourdomain.com
curl -I https://radarr.yourdomain.com
```

#### Security Verification
```bash
# Test SSL certificate
openssl s_client -connect yourdomain.com:443 -servername yourdomain.com

# Verify Authelia protection
curl -I https://radarr.yourdomain.com
# Should redirect to auth.yourdomain.com

# Check firewall rules
sudo ufw status
```

#### Performance Monitoring
```bash
# Container resource usage
docker stats

# Disk usage
df -h
docker system df

# Network connectivity
docker network ls
docker network inspect proxy
```

### Monitoring and Maintenance

#### Regular Monitoring Tasks
1. **Health Monitoring:**
   ```bash
   # Weekly health check
   sudo ./install-ecosystem.sh -d  # Dry run
   ```

2. **Log Rotation:**
   ```bash
   # Rotate container logs
   sudo docker-compose logs --tail=1000 > system.log
   ```

3. **Security Updates:**
   ```bash
   # Update system packages
   sudo apt update && sudo apt upgrade -y
   
   # Update container images
   sudo docker-compose pull
   sudo docker-compose up -d
   ```

4. **Backup Procedures:**
   ```bash
   # Backup configuration
   sudo tar -czf homelabarr-config-backup.tar.gz /opt/appdata/
   
   # Backup environment files
   sudo tar -czf homelabarr-env-backup.tar.gz .env
   ```

---

## 🎯 Quick Start Scenarios

### "I just want to test locally"

**Perfect for learning and testing without any setup complexity**

```bash
# One-line deployment
cd ~ && sudo rm -rf homelabarr-cli 2>/dev/null; git clone https://github.com/smashingtags/homelabarr-cli.git && cd homelabarr-cli && chmod +x setup-local-mode.sh && ./setup-local-mode.sh

# After setup completes, run:
./deploy-local.sh

# Select option 1 for popular media stack
# Access apps directly:
# - Plex: http://localhost:32400
# - Radarr: http://localhost:7878
# - Sonarr: http://localhost:8989
# - qBittorrent: http://localhost:8082
```

**What you get:**
- Immediate access to popular media applications
- No domain or authentication requirements
- Perfect for testing and learning
- Easy cleanup and reinstallation

### "I'm deploying to production"

**Full-featured production environment with security and SSL**

```bash
# Prerequisites:
# 1. Valid domain name
# 2. Cloudflare account with API credentials
# 3. Ubuntu 22.04 LTS server

# Install Docker if not present
curl -fsSL https://get.docker.com | sudo sh

# Clone and install
git clone https://github.com/smashingtags/homelabarr-cli.git
cd homelabarr-cli
sudo ./install.sh

# Follow interactive prompts for domain and Cloudflare setup
# Access via: https://plex.yourdomain.com
```

**What you get:**
- Professional SSL certificates
- Multi-factor authentication via Authelia
- Reverse proxy with automatic routing
- External access from anywhere
- Enterprise-grade security

### "I want the full ecosystem"

**Complete integrated ecosystem with all advanced features**

```bash
# Full ecosystem with web interface and cloud integration
git clone https://github.com/smashingtags/homelabarr-cli.git
cd homelabarr-cli

# Install complete ecosystem
sudo ./install-ecosystem.sh

# Configure environment
sudo nano .env  # Add your settings

# Deploy all services
sudo docker-compose -f ecosystem-integration.yml up -d

# Access web interface at https://homelabarr.yourdomain.com
```

**What you get:**
- Web-based management interface
- Automated cloud upload service
- Enhanced mount service for multiple cloud providers
- Local persist volume management
- Complete integration between all services

### "I prefer web-based management"

**Modern React interface for visual container management**

```bash
# Deploy web interface only
git clone https://github.com/smashingtags/homelabarr-cli.git
cd homelabarr-cli

# Install web interface component
sudo ./install-ecosystem.sh -m web-only

# Or manually deploy
sudo docker-compose -f apps/system/homelabarr-web-interface.yml up -d

# Access at http://localhost:3000 (local) or https://homelabarr.yourdomain.com
```

**What you get:**
- Visual application browser
- Point-and-click deployments
- Real-time monitoring
- Mobile-responsive interface
- No command-line knowledge required

---

## 🛠️ Troubleshooting

### Common Issues and Solutions

#### Local Mode Issues

**Problem: Docker not found**
```bash
# Install Docker
curl -fsSL https://get.docker.com | sudo sh
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
# Logout and login again
```

**Problem: Port conflicts**
```bash
# Check what's using the port
sudo netstat -tulpn | grep :32400

# Stop conflicting service
sudo systemctl stop <service-name>

# Or use port mapping in docker-compose
ports:
  - "32401:32400"  # Use different external port
```

**Problem: Apps not accessible**
```bash
# Check container status
docker ps

# Check logs
docker logs <container-name>

# Verify network connectivity
docker network ls
docker network inspect homelabarr_default
```

#### Production Mode Issues

**Problem: SSL certificate not generated**
```bash
# Check Cloudflare settings
# Verify API key and Zone ID
# Check cf-companion logs
sudo docker logs cf-companion

# Manually force certificate generation
sudo docker exec traefik traefik version
```

**Problem: Authelia authentication not working**
```bash
# Check Authelia logs
sudo docker logs authelia

# Verify user configuration
sudo nano /opt/appdata/authelia/configuration.yml

# Reset user password
sudo docker exec authelia authelia crypto hash generate pbkdf2 --password 'newpassword'
```

**Problem: Domain not resolving**
```bash
# Check DNS propagation
nslookup yourdomain.com
dig yourdomain.com

# Verify Cloudflare DNS settings
# Check A-record points to correct IP
```

#### Ecosystem Integration Issues

**Problem: Local persist plugin not working**
```bash
# Check plugin status
sudo docker logs homelabarr_local_persist

# Verify socket creation
sudo ls -la /run/docker/plugins/

# Restart plugin
sudo docker-compose -f apps/system/local-persist-plugin.yml restart
```

**Problem: Mount service issues**
```bash
# Check FUSE support
sudo lsmod | grep fuse

# Verify privileged access
sudo docker inspect homelabarr_mount_enhanced | jq '.[0].HostConfig.Privileged'

# Check mount points
sudo docker exec homelabarr_mount_enhanced df -h
```

**Problem: Web interface connection issues**
```bash
# Check backend connectivity
sudo docker exec homelabarr_frontend curl -I http://homelabarr-backend:3001/health

# Verify Docker socket access
sudo docker exec homelabarr_backend docker ps

# Check environment variables
sudo docker exec homelabarr_backend env | grep DOCKER
```

### Log Analysis

#### Viewing System Logs
```bash
# All ecosystem logs
sudo docker-compose -f ecosystem-integration.yml logs -f

# Service-specific logs
sudo docker logs homelabarr_backend -f
sudo docker logs traefik -f
sudo docker logs authelia -f

# System logs
sudo journalctl -u docker -f
sudo tail -f /var/log/syslog
```

#### Performance Monitoring
```bash
# Container resource usage
docker stats

# Volume usage
docker system df

# Network analysis
sudo netstat -tulpn
sudo docker network inspect proxy
```

---

## 🤝 Community & Support

### Official Channels
- **Discord Community**: [discord.gg/Pc7mXX786x](https://discord.gg/Pc7mXX786x) - Real-time community support and discussions
- **GitHub Repository**: [github.com/smashingtags/homelabarr-cli](https://github.com/smashingtags/homelabarr-cli) - Source code and issue tracking
- **Documentation Hub**: [Confluence Space](https://mjashley.atlassian.net/wiki/spaces/hlcli/overview) - Comprehensive technical documentation
- **Project Management**: [Jira Board](https://mjashley.atlassian.net/jira/software/projects/HL/boards/34) - Development tracking and planning

### Support Development
- **Ko-fi Support**: [ko-fi.com/homelabarr](https://ko-fi.com/homelabarr) - Support ongoing development and hosting costs
- **GitHub Sponsors**: Contribute to sustainable open-source development
- **Community Contributions**: Code contributions, documentation improvements, and bug reports

### Getting Help
1. **Check Documentation First**: Browse this guide and the GitHub wiki
2. **Search Existing Issues**: Check GitHub issues for similar problems
3. **Join Discord**: Ask questions in the community channels
4. **Report Bugs**: Create detailed GitHub issues with logs and system information
5. **Feature Requests**: Propose new features through GitHub discussions

### Contributing
- **Code Contributions**: Submit pull requests with improvements
- **Documentation**: Help improve guides and tutorials
- **Testing**: Test new features and report feedback
- **Community Support**: Help other users in Discord channels

---

## 📊 Summary

The HomelabARR Ecosystem provides a comprehensive solution for self-hosted media server management with multiple deployment options to suit different needs:

### ✅ **Local Mode Benefits**
- **Zero Setup Complexity**: Works immediately without domain or SSL requirements
- **Perfect for Testing**: Ideal for learning and experimenting
- **Direct Access**: Simple IP:PORT access to all applications
- **Quick Deployment**: 5-minute setup from clone to running applications

### ✅ **Production Mode Benefits**
- **Enterprise Security**: Authelia authentication with 2FA support
- **Automatic SSL**: Let's Encrypt certificates via Cloudflare integration
- **External Access**: Secure access from anywhere with clean URLs
- **Professional Grade**: Ready for serious home lab and small business use

### ✅ **Complete Ecosystem Benefits**
- **Unified Management**: Web interface for visual container management
- **Cloud Integration**: Automated upload service with multi-provider support
- **Advanced Monitoring**: Grafana dashboards and Prometheus metrics
- **Scalable Architecture**: Microservices design for easy expansion

### ✅ **Community & Support**
- **Active Discord**: Real-time community support and discussions
- **Comprehensive Documentation**: Detailed guides and troubleshooting
- **Regular Updates**: Continuous development and feature additions
- **Open Source**: Transparent development with community contributions

---

*Last updated: August 18, 2025 | HomelabARR CLI Ecosystem v2.5+*

**🏠 [Return to Documentation Home](https://mjashley.atlassian.net/wiki/spaces/hlcli/overview)** | **🎮 [Join Discord Community](https://discord.gg/Pc7mXX786x)** | **☕ [Support Development](https://ko-fi.com/homelabarr)**