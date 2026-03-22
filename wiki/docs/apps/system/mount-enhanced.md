# Enhanced Cloud Mount Storage

## Overview

**homelabarr-mount-enhanced** is an advanced cloud storage mounting solution that provides multi-provider support, real-time cost tracking, and modern web interface. It's a compatible drop-in replacement for the standard `homelabarr-mount` container with enhanced features.

### Key Features

- **Multi-Provider Support**: Google Drive, Backblaze B2, OneDrive, pCloud
- **Cost Tracking**: Real-time monitoring and budget management
- **Intelligent Selection**: Automatic provider selection based on cost/performance
- **Modern Interface**: Bootstrap 5 responsive web dashboard
- **Enhanced Monitoring**: Prometheus metrics and health checks
- **User Controls**: Configurable upload/move settings (previously locked)

### Original Attribution

This enhanced version is based on the original `rclone-unionfs-mount` created by **PhysK**, which provided the foundation for cloud storage automation in the homelab community. We've built upon this excellent work to create a more feature-rich and cost-effective solution.

## Installation

### Traefik Mode (Recommended)

For production deployments with SSL and authentication:

```bash
# Install via HomelabARR CE
sudo ./apps/install.sh
# Select: System Apps > Enhanced Cloud Mount

# Access via browser
https://mount.yourdomain.com
```

### Local Mode

For development or standalone installations:

```bash
# Install via HomelabARR CE
sudo ./apps/install.sh
# Select: Local Mode Apps > Enhanced Cloud Mount

# Access via browser
http://localhost:8190
```

## Configuration

### Environment Variables

#### Provider Settings
```bash
# Enable/disable providers
GDRIVE_ENABLED=true
BACKBLAZE_ENABLED=false
ONEDRIVE_ENABLED=false
PCLOUD_ENABLED=false

# Provider selection strategy
PROVIDER_SELECTION=auto  # auto, cheapest, fastest, balanced
```

#### Performance Settings
```bash
# Upload optimization
UPLOAD_CONCURRENCY=4     # Concurrent uploads (1-8)
VFS_CACHE_MODE=writes    # VFS cache mode
VFS_CACHE_SIZE=100GB     # Cache size limit
BUFFER_SIZE=48M          # Buffer size for transfers
```

#### Cost Management
```bash
# Budget controls
COST_LIMIT_MONTHLY=50    # Monthly budget in USD
COST_ALERTS=enabled      # Enable cost alerts
PROVIDER_SELECTION=cheapest  # Cost optimization
```

### Provider Setup

#### Google Drive
1. Create Google Cloud Project
2. Enable Google Drive API
3. Create service account credentials
4. Configure multiple accounts for quota management

```bash
# Access container for setup
docker exec -it homelabarr_mount_enhanced bash
/app/enhanced/providers/setup-gdrive.sh
```

#### Backblaze B2
1. Create Backblaze B2 account
2. Generate application keys
3. Configure bucket settings

```bash
# Configure B2
docker exec -it homelabarr_mount_enhanced bash
/app/enhanced/providers/setup-b2.sh
```

#### OneDrive
1. Register Azure application
2. Configure OAuth permissions
3. Complete authentication flow

```bash
# Interactive setup
docker exec -it homelabarr_mount_enhanced rclone config
```

#### pCloud
1. Create pCloud account
2. Generate authentication token
3. Configure endpoint settings

## Web Interface

### Dashboard Features

The enhanced web interface provides comprehensive management:

- **Real-time Status**: Mount health and performance metrics
- **Provider Management**: Enable/disable cloud providers
- **Cost Dashboard**: Monthly spend tracking and budget alerts
- **Performance Monitor**: Upload/download speeds and quotas
- **Configuration**: Adjust settings without container restart
- **Log Viewer**: Recent activity and error diagnostics

### API Endpoints

RESTful API for automation and monitoring:

```bash
# Health check
GET /api/v2/health

# Provider status
GET /api/v2/providers

# Cost tracking
GET /api/v2/costs

# Performance metrics
GET /api/v2/metrics
```

## Monitoring

### Prometheus Metrics

The container exposes detailed metrics for monitoring:

```bash
# Key metrics available:
cloud_storage_cost_total           # Total monthly cost
cloud_storage_uploads_total        # Upload count by provider
cloud_storage_bytes_transferred    # Data transfer volume
rclone_mount_status               # Mount health status
mergerfs_mount_status             # MergerFS status
provider_quota_usage              # Quota utilization
```

### Health Checks

Comprehensive health monitoring:

- Web interface responsiveness
- Mount point availability
- Provider connectivity
- FUSE device access
- Disk space monitoring
- Service process status

## Performance Optimization

### Cache Configuration

Optimize performance with proper caching:

```bash
# Full cache for active libraries
VFS_CACHE_MODE=full
VFS_CACHE_SIZE=200GB

# Writes cache for uploads
VFS_CACHE_MODE=writes
VFS_CACHE_SIZE=100GB

# Minimal cache for limited storage
VFS_CACHE_MODE=minimal
VFS_CACHE_SIZE=1GB
```

### Upload Optimization

Maximize transfer speeds:

```bash
# High-performance settings
UPLOAD_CONCURRENCY=8
BUFFER_SIZE=64M

# Balanced settings
UPLOAD_CONCURRENCY=4
BUFFER_SIZE=48M

# Conservative settings
UPLOAD_CONCURRENCY=2
BUFFER_SIZE=16M
```

## Cost Management

### Provider Cost Comparison

| Provider | Storage Cost/TB/Month | Transfer Cost | Best Use Case |
|----------|----------------------|---------------|---------------|
| Backblaze B2 | $5 | $0.01/GB | Cost-effective archives |
| Google Workspace | $30/user | Free | Active media libraries |
| OneDrive Business | $5/user | Free | Microsoft integration |
| pCloud Lifetime | $350 once | Free | Personal collections |

### Budget Management

- **Real-time Tracking**: Monitor costs as they accrue
- **Budget Alerts**: Email notifications at 80%/100% thresholds
- **Provider Switching**: Automatic failover to cheaper options
- **Usage Analytics**: Detailed breakdown by provider and operation

## Migration

### From Standard Mount

Seamless migration from `homelabarr-mount`:

1. **Backup Configuration**:
   ```bash
   sudo cp -r /opt/appdata/mount /opt/appdata/mount-backup
   ```

2. **Install Enhanced Version**:
   ```bash
   sudo ./apps/install.sh
   # Select Enhanced Cloud Mount
   ```

3. **Migrate Settings**:
   ```bash
   sudo cp -r /opt/appdata/mount-backup/* /opt/appdata/mount-enhanced/
   ```

4. **Test and Validate**:
   ```bash
   docker logs homelabarr_mount_enhanced
   ```

### Rollback Plan

Easy rollback if needed:

```bash
# Stop enhanced container
docker stop homelabarr_mount_enhanced

# Restore original
sudo cp -r /opt/appdata/mount-backup/* /opt/appdata/mount/

# Start original container
docker compose -f /opt/homelabarr/apps/system/mount.yml up -d
```

## Troubleshooting

### Common Issues

#### Mount Failures
```bash
# Check FUSE support
modprobe fuse
lsmod | grep fuse

# Verify permissions
ls -la /dev/fuse

# Check logs
docker logs homelabarr_mount_enhanced
```

#### Provider Authentication
```bash
# Re-authenticate provider
docker exec -it homelabarr_mount_enhanced rclone config reconnect gdrive

# Test connectivity
docker exec -it homelabarr_mount_enhanced rclone ls gdrive:
```

#### Performance Issues
```bash
# Check cache usage
docker exec -it homelabarr_mount_enhanced df -h /config/cache

# Monitor resources
docker stats homelabarr_mount_enhanced

# Review performance logs
tail -f /opt/appdata/mount-enhanced/logs/performance.log
```

### Health Check Commands

```bash
# Manual health check
docker exec homelabarr_mount_enhanced /app/enhanced/health-check.sh

# Verify all mounts
docker exec homelabarr_mount_enhanced /app/enhanced/verify-mounts.sh

# Test provider connectivity
docker exec homelabarr_mount_enhanced /app/enhanced/test-providers.sh
```

## Security

### Best Practices

- **Service Accounts**: Use dedicated service accounts, not personal credentials
- **Credential Rotation**: Regularly rotate API keys and tokens
- **Access Monitoring**: Review access logs for suspicious activity
- **Network Security**: Use Authelia authentication for external access
- **Encryption**: Enable encryption at rest where supported

### Authelia Integration

For Traefik deployments, Authelia provides:
- Multi-factor authentication
- Session management
- Access control policies
- Audit logging

## Support

### Resources

- **Documentation**: This guide and inline help
- **GitHub Issues**: Bug reports and feature requests
- **Community**: HomelabARR Discord/Forums
- **Original Work**: Credit to PhysK for foundational concepts

### Getting Help

1. Check container logs first
2. Run health check scripts
3. Review provider-specific documentation
4. Search existing GitHub issues
5. Create detailed issue report if needed

## Advanced Configuration

### Service Account Rotation

For Google Drive quota management:

```bash
# Configure multiple service accounts
rclone config create gdrive1 drive service_account_file /config/gdrive1.json
rclone config create gdrive2 drive service_account_file /config/gdrive2.json
rclone config create gdrive3 drive service_account_file /config/gdrive3.json

# Enable rotation
GDRIVE_ROTATION=enabled
GDRIVE_ACCOUNTS=3
```

### Custom Provider Selection

```bash
# Define selection logic
PROVIDER_SELECTION=custom
SELECTION_RULES='{"morning": "gdrive", "evening": "b2", "weekend": "onedrive"}'
```

### Integration with Media Servers

```bash
# Plex integration
PLEX_INTEGRATION=enabled
PLEX_LIBRARY_SCAN=auto

# Jellyfin integration
JELLYFIN_INTEGRATION=enabled
JELLYFIN_LIBRARY_SCAN=auto
```

This enhanced cloud mount solution provides enterprise-grade cloud storage capabilities while maintaining the simplicity and reliability HomelabARR users expect.