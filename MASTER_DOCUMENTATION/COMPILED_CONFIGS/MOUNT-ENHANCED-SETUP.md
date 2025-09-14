# HomelabARR Mount Enhanced - Setup Guide

## Overview

HomelabARR Mount Enhanced is a drop-in replacement for the standard homelabarr-mount container with multi-provider cloud storage support, cost tracking, and a modern web interface.

## Available Deployment Modes

### 1. Full Mode (Traefik + Authelia)
- **File**: `F:\Coding Projects\homelabarr\apps\addons\mount-enhanced.yml`
- **Network**: Uses `proxy` network with Traefik reverse proxy
- **SSL**: Automatic via Cloudflare DNS challenges
- **Authentication**: Authelia middleware integration
- **Access**: `https://mount.yourdomain.com`

### 2. Local Mode (Direct Access)
- **File**: `F:\Coding Projects\homelabarr\apps\local-mode-apps\mount-enhanced-local.yml`
- **Network**: Uses `homelabarr-cli-local` bridge network
- **SSL**: None (local network)
- **Authentication**: Optional/disabled
- **Access**: `http://localhost:8190`

### 3. Template Mode (Configurable)
- **File**: `F:\Coding Projects\homelabarr\apps\.config\mount-enhanced-local-template.yml`
- **Purpose**: Template for customized deployments using environment variables

## Environment Configuration

All mount-enhanced deployments use the standard HomelabARR environment variables:

### Core Variables (Required)
```bash
ID=1000                           # User/Group ID for file permissions
TZ=America/New_York              # Your timezone
UMASK=002                        # File creation mask
RESTARTAPP=unless-stopped        # Container restart policy
APPFOLDER=/opt/appdata          # Base application data path
```

### Mount Enhanced Specific Variables
```bash
# Container Image
MOUNT_ENHANCED_IMAGE=ghcr.io/smashingtags/homelabarr-mount-enhanced:latest

# Port Configuration (Local Mode)
MOUNT_ENHANCED_WEB_PORT=8190
MOUNT_ENHANCED_METRICS_PORT=9190

# Provider Configuration
GDRIVE_ENABLED=true
BACKBLAZE_ENABLED=false
ONEDRIVE_ENABLED=false
PCLOUD_ENABLED=false

# Performance Settings
UPLOAD_CONCURRENCY=4
VFS_CACHE_MODE=writes
VFS_CACHE_SIZE=100GB
BUFFER_SIZE=48M

# Cost Management
COST_LIMIT_MONTHLY=50
PROVIDER_SELECTION=auto
COST_ALERTS=enabled

# Web Interface
WEB_UI=enabled
METRICS_ENABLED=true
LOG_LEVEL=INFO
```

## Deployment Instructions

### Full Mode Deployment
```bash
# Navigate to HomelabARR CLI directory
cd homelabarr-cli

# Deploy using standard app installer
sudo ./apps/install.sh

# Select "Addons" category, then "mount-enhanced"
```

### Local Mode Deployment
```bash
# Navigate to local mode apps
cd homelabarr-cli/apps/local-mode-apps

# Deploy directly with docker-compose
docker-compose -f mount-enhanced-local.yml --env-file ../config/.env up -d

# Access web interface
open http://localhost:8190
```

### Template Mode Deployment
```bash
# Navigate to config directory
cd homelabarr-cli/apps/.config

# Copy template and customize
cp mount-enhanced-local-template.yml my-mount-enhanced.yml

# Edit environment variables in .env file
nano .env

# Deploy customized configuration
docker-compose -f my-mount-enhanced.yml --env-file .env up -d
```

## Volume Structure

Mount Enhanced follows HomelabARR volume conventions:

```
${APPFOLDER}/mount-enhanced/
├── config/              # Main configuration directory
│   ├── rclone/         # rclone configurations
│   └── cache/          # VFS cache directory
├── move/               # Upload staging directory
├── unionfs/            # Mounted cloud storage
├── data/               # Application data
└── logs/               # Application logs
```

## Integration Features

### Traefik Integration (Full Mode)
- Automatic SSL certificates via Cloudflare DNS
- Authelia authentication middleware
- Domain-based routing: `https://mount.yourdomain.com`

### Monitoring Integration
- Prometheus metrics on port 9090
- Health checks compatible with monitoring stack
- Container resource limits and reservations

### Docker Management
- Compatible with Dockupdater for automatic updates
- Proper health check implementation
- Resource management with limits and reservations

## Security Features

### FUSE Mounting
- Privileged container with SYS_ADMIN capability
- Access to `/dev/fuse` device
- AppArmor unconfined for FUSE operations

### Network Security
- Uses standard HomelabARR network patterns
- No unnecessary port exposure in full mode
- Proper container isolation

## Cloud Provider Setup

### Google Drive
1. Create Google Cloud project
2. Enable Drive API
3. Create OAuth2 credentials
4. Configure in environment variables

### Backblaze B2
1. Create Backblaze account
2. Generate application key
3. Create bucket
4. Configure credentials

### OneDrive
1. Register Azure app
2. Configure OAuth2 permissions
3. Obtain client credentials
4. Set up authentication

### pCloud
1. Create pCloud account
2. Generate app password
3. Configure credentials

## Cost Tracking

Mount Enhanced includes advanced cost tracking:

- **Real-time monitoring**: Track upload/download costs
- **Monthly limits**: Set spending limits per provider
- **Automatic selection**: Choose cheapest provider automatically
- **Alert system**: Notifications when approaching limits
- **Historical data**: Cost analysis and reporting

## Troubleshooting

### Common Issues

1. **FUSE mounting fails**
   - Ensure privileged mode is enabled
   - Check `/dev/fuse` device access
   - Verify SYS_ADMIN capability

2. **Web interface not accessible**
   - Check port configuration
   - Verify container health status
   - Review firewall settings

3. **Cloud provider authentication**
   - Verify credentials in environment
   - Check rclone configuration
   - Review provider-specific setup

### Health Checks
```bash
# Check container status
docker ps | grep mount-enhanced

# Check health endpoint
curl http://localhost:8190/health

# View container logs
docker logs mount-enhanced
```

## Support

For support and troubleshooting:
- GitHub Issues: https://github.com/smashingtags/homelabarr-cli/issues
- Discord: https://discord.gg/Pc7mXX786x
- Documentation: https://github.com/smashingtags/homelabarr-cli/wiki