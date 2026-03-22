<p align="left">
    <a href="https://discord.gg/Pc7mXX786x">
        <img src="https://discord.com/api/guilds/1334411584927301682/widget.png?label=Discord%20Server&logo=discord" alt="Join HomelabARR CE on Discord">
    </a>
        <a href="https://github.com/smashingtags/homelabarr-ce/releases">
        <img src="https://img.shields.io/github/downloads/smashingtags/homelabarr-ce/total?label=Total%20Downloads&logo=github" alt="Total Releases Downloaded from GitHub">
    </a>
    <a href="https://github.com/smashingtags/homelabarr-ce/releases/latest">
        <img src="https://img.shields.io/github/v/release/smashingtags/homelabarr-ce?include_prereleases&label=Latest%20Release&logo=github" alt="Latest Official Release on GitHub">
    </a>
    <a href="https://github.com/smashingtags/homelabarr-ce/blob/main/LICENSE">
        <img src="https://img.shields.io/github/license/smashingtags/homelabarr-ce?label=License&logo=gnu" alt="GNU General Public License">
    </a>
</p>

# Migration to NAS-Focused Storage

HomelabARR CE has transitioned from cloud-dependent to local NAS-focused architecture. This guide helps you migrate from PGBlitz or other cloud-based systems to a modern, local storage solution.

**Benefits of the new NAS-focused approach:**
- No cloud API rate limits or daily quotas
- Better performance with local storage
- Enhanced privacy - data stays on your infrastructure  
- No cloud subscription costs
- Simplified setup without complex API configurations

# Prerequisites

## From PGBlitz/Cloud Systems
If migrating from PGBlitz or similar cloud-based systems:
- Backup all application data locally
- Download media files from cloud storage to your NAS
- Document current application configurations

## Local NAS Requirements
- **NAS System**: UnRAID, TrueNAS, or similar
- **Network Share**: SMB/NFS export properly configured
- **Storage Capacity**: Sufficient space for your media library
- **Network**: Gigabit connection recommended for large libraries

# Migration Steps

## 1. Prepare Local Storage

### UnRAID Setup
```bash
# Configure user shares for media
/mnt/user/media/movies
/mnt/user/media/tv
/mnt/user/downloads
/mnt/user/appdata
```

### TrueNAS Setup  
```bash
# Create ZFS datasets
/mnt/tank/media
/mnt/tank/downloads
/mnt/tank/appdata
```

### Network Mount Configuration
```bash
# Create mount points
sudo mkdir -p /mnt/nas/{media,downloads,appdata}

# Mount NAS shares
sudo mount -t cifs //nas.local/media /mnt/nas/media -o uid=1000,gid=1000
sudo mount -t nfs nas.local:/volume1/downloads /mnt/nas/downloads
```

## 2. Backup Application Data

Create local backups of your application configurations:

```bash
# Run backup script (creates local backup)
sudo ./backup.sh
```

This creates `/appbackups/` directory with all application configurations and databases.

## 3. Install HomelabARR CE

Follow the standard installation on your host system:

1. Order VPS or prepare local server with Ubuntu 22.04
2. Follow installation instructions in the [Install Guide](../guides/quick-start.md)
3. Return here once HomelabARR CE is installed

## 4. Configure Local Storage Integration

### Set Up Mount System
```bash
# Create required directories
sudo mkdir -p /opt/appdata/system
sudo chown -R 1000:1000 /opt/appdata
```

### Configure for NAS Integration
The modern mount system supports:
- UnionFS/MergerFS for combining multiple drives
- Direct NAS share mounting
- Local disk array management

Deploy the mount system through HomelabARR CE CLI under System section.

## 5. Restore Applications

After configuring local storage:

1. Install applications through HomelabARR CE CLI
2. Restore configuration data from backups
3. Update path configurations to point to local NAS
4. Verify application access to shared storage

# Path Migration Examples

## From Cloud Paths to NAS Paths

**Old Cloud Structure:**
```
/mnt/unionfs/cloud/media/movies
/mnt/unionfs/cloud/media/tv
/mnt/unionfs/cloud/downloads
```

**New NAS Structure:**
```
/mnt/nas/media/movies
/mnt/nas/media/tv  
/mnt/nas/downloads
```

## Application Configuration Updates

Update your application paths in:
- Plex library locations
- Sonarr/Radarr root folders
- Download client destination paths
- Backup target locations

# Performance Optimization

## Local Storage Benefits
- **No API Limits**: Process unlimited files simultaneously
- **Better Speed**: Local storage faster than cloud transfers
- **Real-time Access**: No download delays for media playback
- **Reduced Complexity**: Direct filesystem access

## Recommended Settings
- Enable hardware transcoding for media servers
- Configure cache drives for frequently accessed content
- Set up proper backup strategies for critical data
- Monitor storage health and capacity

## Support

Kindly report any issues/broken-parts/bugs on [github](https://github.com/smashingtags/homelabarr-ce/issues) or [discord](https://discord.gg/Pc7mXX786x)

**☕ [Support Development](https://ko-fi.com/homelabarr)** - Migration guides saving you time? Help us maintain and improve migration tools!

- Join our <a href="https://discord.gg/Pc7mXX786x">
