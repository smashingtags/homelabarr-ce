# HomelabARR Ecosystem Integration Guide

This guide provides comprehensive instructions for restoring and integrating the complete HomelabARR ecosystem after the recent merge issues.

## Overview

The HomelabARR ecosystem consists of six core components that work together to provide a complete self-hosted media server solution:

1. **homelabarr-cli** (main repo) - CLI deployment tool
2. **homelabarr-main** - Modern React web interface with Docker management
3. **homelabarr-uploader-main** - Automated cloud upload service
4. **homelabarr-containers-master** - Custom container definitions
5. **homelabarr-assets-main** - Shared assets and resources
6. **local-persist-master** - Docker volume persistence plugin

## Architecture

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

### Service Dependencies
```
Local Persist Plugin (base layer)
    ↑
Mount Enhanced Service
    ↑
Uploader Service → Backend API
    ↑                ↑
Frontend Web Interface
```

## Integration Components

### 1. Local Persist Volume Plugin

**Purpose**: Enables named Docker volumes to persist in specific host locations instead of Docker's default volume directory.

**Key Features**:
- Static Go binary for maximum compatibility
- Containerized deployment
- Supports all filesystem mount points
- Essential for HomelabARR volume management

**Configuration**: `apps/system/local-persist-plugin.yml`

### 2. Enhanced Mount Service

**Purpose**: Multi-provider cloud storage management with cost tracking and modern web interface.

**Key Features**:
- Multiple cloud provider support (Google Drive, Backblaze, OneDrive, pCloud)
- Cost tracking and alerts
- VFS caching for performance
- Union filesystem support
- Web-based configuration interface

**Configuration**: `apps/system/mount-enhanced.yml`

### 3. Uploader Service

**Purpose**: Automated upload management for completed downloads with multi-drive support.

**Key Features**:
- Automated cloud uploads
- Multi-drive configuration support
- Integration with Autoscan for media library updates
- Bandwidth limiting and scheduling
- Notification support via Apprise
- Web interface for monitoring

**Configuration**: `apps/system/homelabarr-uploader.yml`

### 4. Web Interface

**Purpose**: Modern React-based management interface with CLI-based Docker integration.

**Key Features**:
- Real Docker container deployment
- Cross-platform compatibility (Windows/Linux/macOS)
- CLI-based architecture (no Docker socket issues)
- 90+ pre-configured application templates
- Live container status monitoring
- Integration with existing HomelabARR CLI

**Configuration**: `apps/system/homelabarr-web-interface.yml`

## Installation Procedures

### Prerequisites

1. **System Requirements**:
   - Ubuntu 20.04+ or Debian 11+
   - Docker 20.10+
   - Docker Compose 2.0+
   - 4GB RAM minimum
   - 20GB free disk space

2. **Network Requirements**:
   - Valid domain with Cloudflare DNS management
   - Traefik reverse proxy installed
   - Authelia authentication (optional but recommended)

3. **Existing HomelabARR CLI**:
   - Properly configured `.env` file
   - Traefik and proxy network operational
   - Application data directory structure

### Installation Methods

#### Method 1: Quick Installation (Recommended)

```bash
# 1. Navigate to HomelabARR CLI directory
cd /path/to/homelabarr-cli

# 2. Make installation script executable
chmod +x install-ecosystem.sh

# 3. Run complete ecosystem installation
sudo ./install-ecosystem.sh

# 4. Edit environment configuration
sudo nano .env

# 5. Restart services with your configuration
sudo docker-compose -f ecosystem-integration.yml down
sudo docker-compose -f ecosystem-integration.yml up -d
```

#### Method 2: Component-by-Component Installation

```bash
# 1. Install Local Persist Plugin (Required First)
sudo docker-compose -f apps/system/local-persist-plugin.yml up -d

# 2. Wait for plugin to be ready
sudo docker exec homelabarr_local_persist test -S /run/docker/plugins/local-persist.sock

# 3. Install Enhanced Mount Service
sudo docker-compose -f apps/system/mount-enhanced.yml up -d

# 4. Install Uploader Service (depends on mount)
sudo docker-compose -f apps/system/homelabarr-uploader.yml up -d

# 5. Install Web Interface
sudo docker-compose -f apps/system/homelabarr-web-interface.yml up -d
```

#### Method 3: Selective Installation

```bash
# Web Interface Only
sudo ./install-ecosystem.sh -m web-only

# Uploader Service Only
sudo ./install-ecosystem.sh -m uploader-only

# Essential Services Only
sudo ./install-ecosystem.sh -m minimal
```

### Environment Configuration

Copy and customize the environment file:

```bash
# Copy template
cp .env.ecosystem .env

# Edit configuration
nano .env
```

**Key Variables to Configure**:

```bash
# Domain Configuration
DOMAIN=yourdomain.com
CLOUDFLARE_EMAIL=your-email@domain.com
CLOUDFLARE_API_KEY=your-cloudflare-api-key

# Directory Paths
APPDATA=/opt/appdata
DOWNLOADFOLDER=/mnt/downloads
UNIONFS=/mnt/unionfs

# Docker Configuration
DOCKER_GID=999  # Get with: getent group docker | cut -d: -f3

# Authentication (if using Authelia)
AUTH_ENABLED=true
DEFAULT_ADMIN_PASSWORD=secure-password
```

## Service Integration Points

### 1. Volume Integration

All services use the local-persist plugin for consistent volume management:

```yaml
volumes:
  service_data:
    driver: local-persist
    driver_opts:
      mountpoint: ${APPDATA}/service/data
```

### 2. Network Integration

Services communicate via the `proxy` network:

```yaml
networks:
  proxy:
    name: proxy
    external: true
```

### 3. Authentication Integration

Services integrate with Authelia for centralized authentication:

```yaml
labels:
  - "traefik.http.routers.service.middlewares=authelia@docker"
```

### 4. Service Discovery

Services discover each other via container names:

```bash
# Uploader connects to mount service
UPLOADER_MOUNT=mount-enhanced:8554

# Backend connects to other services
MOUNT_URL=http://mount-enhanced:8080
UPLOADER_URL=http://homelabarr-uploader:9999
```

## Testing Procedures

### 1. Health Check Verification

```bash
# Check all container health
sudo docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Detailed health information
sudo docker inspect homelabarr_backend | jq '.[0].State.Health'
```

### 2. Network Connectivity Testing

```bash
# Test service-to-service communication
sudo docker exec homelabarr_backend curl -I http://mount-enhanced:8080/health
sudo docker exec homelabarr_backend curl -I http://homelabarr-uploader:9999/health

# Test external access (replace with your domain)
curl -I https://homelabarr.yourdomain.com
curl -I https://api.yourdomain.com/health
```

### 3. Volume Persistence Testing

```bash
# Verify local-persist plugin
sudo docker exec homelabarr_local_persist test -S /run/docker/plugins/local-persist.sock

# Test volume creation
sudo docker volume create -d local-persist -o mountpoint=/tmp/test-volume --name test-volume

# Verify volume location
ls -la /tmp/test-volume

# Cleanup test volume
sudo docker volume rm test-volume
```

### 4. Integration API Testing

```bash
# Test backend API endpoints
curl -X GET https://api.yourdomain.com/api/containers
curl -X GET https://api.yourdomain.com/api/applications
curl -X GET https://api.yourdomain.com/health

# Test container deployment
curl -X POST https://api.yourdomain.com/api/deploy \
  -H "Content-Type: application/json" \
  -d '{"appId": "it-tools", "config": {}, "mode": "standard"}'
```

### 5. Uploader Service Testing

```bash
# Check uploader status
sudo docker logs homelabarr_uploader

# Test configuration files
sudo ls -la /opt/appdata/system/uploader/
sudo ls -la /opt/appdata/system/servicekeys/

# Verify mount integration
sudo docker exec homelabarr_uploader ls -la /mnt
```

## Troubleshooting

### Common Issues

#### 1. Local Persist Plugin Not Starting

```bash
# Check plugin logs
sudo docker logs homelabarr_local_persist

# Verify socket creation
sudo ls -la /run/docker/plugins/

# Restart plugin
sudo docker-compose -f apps/system/local-persist-plugin.yml restart
```

#### 2. Mount Service Issues

```bash
# Check FUSE support
sudo lsmod | grep fuse

# Verify privileged access
sudo docker inspect homelabarr_mount_enhanced | jq '.[0].HostConfig.Privileged'

# Check mount points
sudo docker exec homelabarr_mount_enhanced df -h
```

#### 3. Web Interface Connection Issues

```bash
# Check backend connectivity
sudo docker exec homelabarr_frontend curl -I http://homelabarr-backend:3001/health

# Verify Docker socket access
sudo docker exec homelabarr_backend docker ps

# Check environment variables
sudo docker exec homelabarr_backend env | grep DOCKER
```

#### 4. Uploader Service Issues

```bash
# Check rclone configuration
sudo docker exec homelabarr_uploader rclone config show

# Verify service keys
sudo ls -la /opt/appdata/system/servicekeys/

# Test mount connectivity
sudo docker exec homelabarr_uploader ping mount-enhanced
```

### Log Analysis

```bash
# View all ecosystem logs
sudo docker-compose -f ecosystem-integration.yml logs -f

# Service-specific logs
sudo docker logs homelabarr_backend -f
sudo docker logs homelabarr_uploader -f
sudo docker logs homelabarr_mount_enhanced -f
```

### Performance Monitoring

```bash
# Container resource usage
sudo docker stats

# Volume usage
sudo docker system df

# Network connectivity
sudo docker network inspect proxy
sudo docker network inspect homelabarr
```

## Maintenance

### Regular Maintenance Tasks

1. **Health Monitoring**:
   ```bash
   # Weekly health check
   sudo ./install-ecosystem.sh -d  # Dry run to verify status
   ```

2. **Log Rotation**:
   ```bash
   # Rotate container logs
   sudo docker-compose -f ecosystem-integration.yml logs --tail=1000 > ecosystem.log
   ```

3. **Volume Cleanup**:
   ```bash
   # Clean unused volumes
   sudo docker volume prune -f
   ```

4. **Image Updates**:
   ```bash
   # Update all images
   sudo docker-compose -f ecosystem-integration.yml pull
   sudo docker-compose -f ecosystem-integration.yml up -d
   ```

### Backup Procedures

```bash
# Backup configuration
sudo tar -czf homelabarr-config-backup.tar.gz /opt/appdata/homelabarr/

# Backup volume data
sudo tar -czf homelabarr-volumes-backup.tar.gz /opt/appdata/

# Backup environment and compose files
sudo tar -czf homelabarr-compose-backup.tar.gz .env ecosystem-integration.yml apps/system/
```

## Advanced Configuration

### Custom Container Integration

To integrate additional containers from `homelabarr-containers-master`:

1. **Copy Container Definitions**:
   ```bash
   cp .claude/homelabarr-other-git-repositories/homelabarr-containers-master/apps/* apps/
   ```

2. **Update Image References**:
   ```yaml
   services:
     custom-service:
       image: ghcr.io/homelabarr/custom-service:latest
   ```

3. **Add to Ecosystem**:
   ```yaml
   # Add to ecosystem-integration.yml
   depends_on:
     - local-persist
   ```

### Performance Tuning

#### Mount Service Optimization
```yaml
environment:
  - VFS_CACHE_SIZE=200GB
  - UPLOAD_CONCURRENCY=8
  - BUFFER_SIZE=64M
```

#### Uploader Service Optimization
```yaml
environment:
  - TRANSFERS=4
  - BANDWIDTH_LIMIT=100M
  - MIN_AGE_UPLOAD=5
```

#### Backend API Optimization
```yaml
deploy:
  resources:
    limits:
      memory: 2G
      cpus: '2.0'
```

## Migration from Previous Versions

### From Legacy HomelabARR

1. **Export Existing Configuration**:
   ```bash
   sudo cp /opt/homelabarr/.env .env.backup
   sudo cp -r /opt/homelabarr/compose/ compose.backup/
   ```

2. **Migrate Volume Paths**:
   ```bash
   # Update paths in .env
   sed -i 's|/opt/homelabarr|/opt/appdata|g' .env
   ```

3. **Deploy New Ecosystem**:
   ```bash
   sudo ./install-ecosystem.sh
   ```

### From Standalone Components

1. **Stop Existing Services**:
   ```bash
   sudo docker stop $(sudo docker ps -q --filter "name=mount")
   sudo docker stop $(sudo docker ps -q --filter "name=uploader")
   ```

2. **Backup Data**:
   ```bash
   sudo docker cp existing_mount:/config /tmp/mount-config-backup
   sudo docker cp existing_uploader:/config /tmp/uploader-config-backup
   ```

3. **Deploy Integrated Ecosystem**:
   ```bash
   sudo ./install-ecosystem.sh
   ```

4. **Restore Configuration**:
   ```bash
   sudo cp -r /tmp/mount-config-backup/* /opt/appdata/mount-enhanced/config/
   sudo cp -r /tmp/uploader-config-backup/* /opt/appdata/uploader/config/
   ```

## Support and Community

- **Documentation**: [HomelabARR Wiki](https://github.com/smashingtags/homelabarr-cli/wiki)
- **Issues**: [GitHub Issues](https://github.com/smashingtags/homelabarr-cli/issues)
- **Community**: [Discord Server](https://discord.gg/Pc7mXX786x)
- **Updates**: Follow repository releases for ecosystem updates

## Conclusion

This integration restores the complete HomelabARR ecosystem functionality with:

✅ **Unified Volume Management** - Local persist plugin ensures consistent data persistence  
✅ **Automated Upload Pipeline** - Seamless integration between download, processing, and cloud upload  
✅ **Modern Web Interface** - CLI-based Docker management with cross-platform support  
✅ **Enhanced Mount Services** - Multi-provider cloud storage with cost tracking  
✅ **Centralized Authentication** - Integrated Authelia support for security  
✅ **Scalable Architecture** - Microservices design for easy expansion and maintenance  

The ecosystem is now restored and ready for production use with all components working together as designed.