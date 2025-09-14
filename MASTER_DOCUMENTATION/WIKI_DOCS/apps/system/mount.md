![Image of HomelabARR CLI](/img/container_images/docker-mount.png)

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
    <a href="https://github.com/smashingtags/homelabarr-cli/blob/master/LICENSE">
        <img src="https://img.shields.io/github/license/smashingtags/homelabarr-cli?label=License&logo=gnu" alt="GNU General Public License">
    </a>
</p>

# Mount System - Local NAS Integration

The HomelabARR CLI mount system provides advanced filesystem management for local NAS storage using UnionFS and MergerFS capabilities.

## Overview

The mount system is designed for modern NAS setups including:
- **UnRAID** - Unified storage array management
- **TrueNAS** - Enterprise-grade storage platform  
- **Local disk arrays** - Multiple drive setups
- **Network attached storage** - SMB/NFS shares

## Features

### Core Capabilities
- **UnionFS/MergerFS Integration** - Combine multiple drives into unified storage
- **FUSE Filesystem Support** - Advanced filesystem operations
- **Container Volume Management** - Shared storage across applications
- **Web Management Interface** - Access via https://mount.yourdomain.com
- **Real-time Monitoring** - Storage status and performance tracking

### Storage Architecture
- **Privileged Access** - Full system-level filesystem operations
- **Shared Volumes** - `/mnt` directory accessible to all containers
- **Device Mapping** - Direct FUSE device access (`/dev/fuse`)
- **Permission Management** - Proper UID/GID handling for containers

## Configuration

### Environment Variables
```bash
PGID=${ID}          # Group ID for file permissions
PUID=${ID}          # User ID for file permissions  
TZ=${TZ}            # Timezone configuration
RESTARTAPP=unless-stopped  # Container restart policy
```

### Volume Mappings
```yaml
volumes:
  - "/etc/localtime:/etc/localtime:ro"          # System time sync
  - "${APPFOLDER}/system:/system:rshared"       # Configuration storage
  - "/mnt:/mnt:shared"                          # Main storage mount point
```

## Local NAS Setup Examples

### UnRAID Integration
```bash
# UnRAID array mounts
/mnt/user/media     -> Media files (movies, tv, music)
/mnt/user/downloads -> Download staging area  
/mnt/user/appdata   -> Application configurations
```

### TrueNAS Integration  
```bash
# TrueNAS dataset mounts
/mnt/tank/media     -> ZFS dataset for media
/mnt/tank/downloads -> ZFS dataset for downloads
/mnt/tank/backups   -> ZFS dataset for backups
```

### Network Share Integration
```bash
# SMB/CIFS shares
//nas.local/media   -> Network media share
//nas.local/backup  -> Network backup share

# NFS shares  
nas.local:/volume1/media -> NFS media export
nas.local:/volume1/downloads -> NFS downloads export
```

## UnionFS/MergerFS Configuration

### Multiple Drive Pooling
The mount system can combine multiple drives into a single unified namespace:

```bash
# Example: Combine multiple drives
Drive1: /mnt/disk1 (1TB)
Drive2: /mnt/disk2 (2TB)  
Drive3: /mnt/disk3 (4TB)
Unified: /mnt/unionfs (7TB total)
```

### Benefits
- **Single access point** - Applications see one large drive
- **Automatic balancing** - Files distributed across drives
- **Redundancy options** - Duplicate important files across drives
- **Easy expansion** - Add drives without reconfiguring applications

## Security & Permissions

### Container Privileges
The mount container requires elevated privileges for filesystem operations:
- `privileged: true` - Full system access
- `SYS_ADMIN` capability - Mount/unmount operations
- Device access to `/dev/fuse` - FUSE filesystem support

### File Permissions
All mounted storage respects the configured PUID/PGID:
- Media files readable by Plex, Jellyfin, Emby
- Downloads accessible by download clients  
- Backups writable by backup applications

## Web Interface

Access the mount management interface at `https://mount.yourdomain.com`

### Features
- **Mount Status** - View all active mounts
- **Storage Usage** - Disk space and utilization  
- **Performance Metrics** - I/O statistics and health
- **Configuration** - Adjust mount parameters

## Monitoring & Notifications

### Health Checks
- Storage availability monitoring
- Mount point validation
- Performance threshold alerts

### Notifications
Integration with notification services via Apprise:
- Mount failures
- Storage capacity warnings  
- Performance degradation alerts

## Best Practices

### Storage Layout
```
/mnt/
├── media/          # Media library files
│   ├── movies/
│   ├── tv/
│   └── music/
├── downloads/      # Download staging
│   ├── complete/
│   └── incomplete/
├── appdata/        # Application data
└── backups/        # Backup storage
```

### Performance Optimization
- Use SSD for frequently accessed data
- Configure appropriate caching strategies
- Monitor I/O patterns and optimize accordingly
- Regular filesystem maintenance and cleanup

### Backup Strategy
- Regular snapshots (ZFS/Btrfs)
- Offsite backup of critical data  
- Configuration backup automation
- Disaster recovery testing

## Troubleshooting

### Common Issues
- **Permission denied**: Check PUID/PGID configuration
- **Mount failures**: Verify FUSE device access
- **Performance issues**: Check storage health and I/O bottlenecks

### Log Analysis
```bash
# View mount system logs
docker logs mount

# Check system mount points  
docker exec mount mount | grep fuse
```

## Migration from Cloud Storage

If migrating from previous cloud storage setups:

1. **Data Migration** - Copy existing data to local NAS
2. **Path Updates** - Update application configs for new mount points  
3. **Permission Fixes** - Ensure proper ownership on all files
4. **Backup Verification** - Confirm all data transferred correctly

The mount system provides enterprise-grade local storage management without dependency on external cloud services.
