# HomelabARR Enhanced Mount Container - Installation Guide

## Overview

The HomelabARR Enhanced Mount Container is a drop-in replacement for the standard `homelabarr-mount` container with multi-provider cloud storage support, cost tracking, and modern web interface.

## Prerequisites

### System Requirements
- Ubuntu/Debian Linux (HomelabARR CLI supported platforms)
- Docker and Docker Compose installed
- Minimum 4GB RAM and 2 CPU cores for optimal performance
- FUSE support enabled (`modprobe fuse`)

### HomelabARR CLI Requirements
- HomelabARR CLI v2.0+ installed
- Traefik proxy configured (for Traefik mode)
- Authelia authentication (for Traefik mode)
- Local-persist volume plugin installed

## Installation Methods

### Method 1: Traefik Mode (Recommended)

For full HomelabARR CLI integration with reverse proxy and authentication:

```bash
# 1. Copy the enhanced mount configuration
sudo cp mount-enhanced-traefik.yml /opt/homelabarr/apps/system/mount-enhanced.yml

# 2. Configure environment variables
sudo nano /opt/homelabarr/.env

# Add or update these variables:
GDRIVE_ENABLED=true
BACKBLAZE_ENABLED=false
ONEDRIVE_ENABLED=false
PCLOUD_ENABLED=false
UPLOAD_CONCURRENCY=4
COST_LIMIT_MONTHLY=50
PROVIDER_SELECTION=auto

# 3. Install via HomelabARR CLI
sudo /opt/homelabarr/apps/install.sh
# Select "System Apps" -> "Mount Enhanced"

# 4. Access web interface
# Visit: https://mount.yourdomain.com
```

### Method 2: Local Mode

For standalone installation without Traefik:

```bash
# 1. Copy the local mount configuration
sudo cp mount-enhanced-local.yml /opt/homelabarr/apps/local-mode-apps/mount-enhanced.yml

# 2. Install via HomelabARR CLI local mode
sudo /opt/homelabarr/apps/install.sh
# Select "Local Mode Apps" -> "Mount Enhanced"

# 3. Access web interface
# Visit: http://localhost:8080
```

### Method 3: Manual Docker Compose

For custom installations:

```bash
# 1. Clone the repository
git clone https://github.com/smashingtags/rclone-unionfs-mount.git
cd rclone-unionfs-mount

# 2. Copy environment template
cp .env.template .env

# 3. Configure providers and settings
nano .env

# 4. Deploy with Docker Compose
docker-compose -f docker-compose.enhanced.yml up -d
```

## Provider Configuration

### Google Drive Setup

1. **Create Google Cloud Project**:
   - Visit [Google Cloud Console](https://console.cloud.google.com)
   - Create new project or select existing
   - Enable Google Drive API

2. **Create Service Account**:
   ```bash
   # Access the container
   docker exec -it homelabarr-mount-enhanced bash
   
   # Run provider setup
   /app/enhanced/providers/setup-gdrive.sh
   ```

3. **Configure Multiple Accounts** (for quota management):
   ```bash
   # Add additional service accounts
   rclone config create gdrive1 drive service_account_file /config/gdrive1.json
   rclone config create gdrive2 drive service_account_file /config/gdrive2.json
   ```

### Backblaze B2 Setup

1. **Create B2 Account**:
   - Visit [Backblaze B2](https://www.backblaze.com/b2/)
   - Create application keys

2. **Configure B2**:
   ```bash
   # Access container
   docker exec -it homelabarr-mount-enhanced bash
   
   # Setup B2
   /app/enhanced/providers/setup-b2.sh
   # Enter your Application Key ID and Key
   ```

### OneDrive Setup

1. **Register Application**:
   - Visit [Microsoft App Registration](https://portal.azure.com)
   - Register new application

2. **Configure OneDrive**:
   ```bash
   # Interactive setup
   docker exec -it homelabarr-mount-enhanced rclone config
   # Select "New remote" -> "Microsoft OneDrive"
   ```

### pCloud Setup

1. **Get pCloud Account**:
   - Create account at [pCloud](https://www.pcloud.com)

2. **Configure pCloud**:
   ```bash
   # Interactive setup
   docker exec -it homelabarr-mount-enhanced rclone config
   # Select "New remote" -> "pCloud"
   ```

## Advanced Configuration

### Cost Tracking Setup

The enhanced container includes automatic cost tracking:

```bash
# Set monthly budget
COST_LIMIT_MONTHLY=50

# Configure alerts
COST_ALERTS=enabled

# Provider selection strategy
PROVIDER_SELECTION=cheapest  # or auto, fastest, balanced
```

### Performance Optimization

```bash
# Increase upload concurrency
UPLOAD_CONCURRENCY=8

# Configure VFS cache
VFS_CACHE_MODE=full
VFS_CACHE_SIZE=200GB

# Buffer size optimization
BUFFER_SIZE=64M
```

### Multi-Provider Strategy

```bash
# Enable multiple providers
GDRIVE_ENABLED=true
BACKBLAZE_ENABLED=true
ONEDRIVE_ENABLED=true

# Automatic provider selection
PROVIDER_SELECTION=auto

# Manual provider preference
CLOUD_PROVIDER=cheapest  # or gdrive, b2, onedrive, pcloud
```

## Monitoring and Maintenance

### Web Interface Features

Access the enhanced web interface at your configured URL:

- **Dashboard**: Real-time status and metrics
- **Provider Management**: Enable/disable cloud providers
- **Cost Tracking**: Monthly spend and budget alerts
- **Performance Monitoring**: Upload/download speeds
- **Mount Status**: Active mounts and health
- **Log Viewer**: Recent activity and errors

### Prometheus Metrics

The container exposes metrics on port 9090:

```bash
# View metrics
curl http://localhost:9090/metrics

# Key metrics:
# - cloud_storage_cost_total
# - cloud_storage_uploads_total
# - cloud_storage_bytes_transferred
# - rclone_mount_status
# - mergerfs_mount_status
```

### Log Management

Logs are stored in `/opt/appdata/mount-enhanced/logs/`:

```bash
# View recent activity
docker logs homelabarr-mount-enhanced

# View cost tracking logs
tail -f /opt/appdata/mount-enhanced/logs/cost-tracker.log

# View provider performance
tail -f /opt/appdata/mount-enhanced/logs/providers.log
```

## Troubleshooting

### Common Issues

1. **Mount Failures**:
   ```bash
   # Check FUSE support
   modprobe fuse
   
   # Verify permissions
   ls -la /dev/fuse
   
   # Check container logs
   docker logs homelabarr-mount-enhanced
   ```

2. **Provider Authentication**:
   ```bash
   # Re-authenticate
   docker exec -it homelabarr-mount-enhanced rclone config reconnect <provider>
   
   # Test connection
   docker exec -it homelabarr-mount-enhanced rclone ls <provider>:
   ```

3. **Performance Issues**:
   ```bash
   # Check cache usage
   docker exec -it homelabarr-mount-enhanced df -h /config/cache
   
   # Monitor resource usage
   docker stats homelabarr-mount-enhanced
   ```

### Health Checks

The container includes comprehensive health monitoring:

```bash
# Manual health check
docker exec homelabarr-mount-enhanced /app/enhanced/health-check.sh

# Check all mounts
docker exec homelabarr-mount-enhanced /app/enhanced/verify-mounts.sh

# Provider connectivity test
docker exec homelabarr-mount-enhanced /app/enhanced/test-providers.sh
```

## Migration from Standard Mount

### Backup Current Configuration

```bash
# Stop existing mount container
docker stop homelabarr-mount

# Backup configuration
sudo cp -r /opt/appdata/mount /opt/appdata/mount-backup

# Backup rclone config
sudo cp -r /config/rclone /config/rclone-backup
```

### Migration Process

```bash
# 1. Install enhanced container (don't start yet)
sudo /opt/homelabarr/apps/install.sh

# 2. Migrate configuration
sudo cp -r /opt/appdata/mount-backup/* /opt/appdata/mount-enhanced/

# 3. Update configuration for enhanced features
sudo nano /opt/homelabarr/.env
# Add new environment variables

# 4. Start enhanced container
docker-compose -f /opt/homelabarr/apps/system/mount-enhanced.yml up -d

# 5. Verify migration
docker logs homelabarr-mount-enhanced
```

### Rollback Plan

If issues occur, rollback is simple:

```bash
# Stop enhanced container
docker stop homelabarr-mount-enhanced

# Restore original
sudo cp -r /opt/appdata/mount-backup/* /opt/appdata/mount/

# Start original container
docker-compose -f /opt/homelabarr/apps/system/mount.yml up -d
```

## Security Considerations

### API Keys and Secrets

- Store sensitive credentials in Docker secrets or environment files
- Use service accounts instead of personal accounts where possible
- Rotate credentials regularly
- Monitor access logs for suspicious activity

### Network Security

- Use Authelia authentication for external access
- Configure Cloudflare WAF rules for additional protection
- Limit container network access to required services only
- Enable container resource limits

### Data Protection

- Enable encryption at rest for cloud providers that support it
- Use VPN or private networks for data transfer
- Regular backup of configuration and critical data
- Monitor cost and usage for anomalies

## Support and Documentation

### Resources

- **GitHub Repository**: https://github.com/smashingtags/rclone-unionfs-mount
- **HomelabARR Documentation**: https://docs.homelabarr.dev
- **Original Author Attribution**: PhysK (original rclone-unionfs-mount)
- **rclone Documentation**: https://rclone.org/docs/

### Getting Help

1. **Check Logs**: Always start with container and application logs
2. **Health Checks**: Use built-in health check scripts
3. **Community Support**: HomelabARR Discord/Forums
4. **GitHub Issues**: Report bugs and feature requests

### Contributing

Contributions welcome! Please:
- Follow existing code patterns
- Test thoroughly before submitting PRs
- Update documentation for new features
- Maintain backward compatibility where possible