# DockServer to HomelabARR Migration Guide

## Overview

This guide provides comprehensive instructions for migrating from DockServer to HomelabARR. The migration process has been designed to be as seamless as possible while preserving your data and configurations.

## What's Changing?

### Container Naming Updates
- `dockserver/dockserver` → `ghcr.io/smashingtags/homelabarr-legacy-base`
- `dockserver/dockserver-ui` → `ghcr.io/smashingtags/homelabarr-ui-legacy`
- `dockserver/autoscan` → `ghcr.io/smashingtags/homelabarr-autoscan`
- `dockserver/mount` → `ghcr.io/smashingtags/homelabarr-mount`

### Path Updates
- `/opt/dockserver` → `/opt/homelabarr`
- `/opt/appdata/dockserver` → `/opt/appdata/homelabarr`

### Environment Variables
- `DOCKSERVER_*` → `HOMELABARR_*`
- `DS_*` → `HL_*`

## Prerequisites

Before starting the migration:

1. **Backup Your Data**: Ensure you have a complete backup of your DockServer installation
2. **Check Disk Space**: Ensure you have at least 10GB free space for the migration process
3. **Stop Active Transfers**: Pause any active downloads or transfers
4. **Document Custom Configurations**: Note any custom modifications you've made

## Migration Methods

### Method 1: Automated Migration (Recommended)

We provide an automated migration script that handles the entire process:

```bash
# Download the migration script
wget https://raw.githubusercontent.com/smashingtags/homelabarr-cli/main/scripts/migration/dockserver-to-homelabarr.sh

# Make it executable
chmod +x dockserver-to-homelabarr.sh

# Run the migration
sudo ./dockserver-to-homelabarr.sh
```

The script will:
- Create a backup of your current configuration
- Stop DockServer containers
- Update image references
- Update environment variables
- Migrate data paths
- Update systemd services
- Clean up old images
- Verify the migration

### Method 2: Manual Migration

If you prefer to migrate manually or need more control:

#### Step 1: Create Backup

```bash
# Create backup directory
sudo mkdir -p /opt/backups/dockserver-manual-$(date +%Y%m%d)

# Backup docker-compose files
sudo cp -r /opt/dockserver /opt/backups/dockserver-manual-$(date +%Y%m%d)/

# List appdata for reference
ls -la /opt/appdata > /opt/backups/dockserver-manual-$(date +%Y%m%d)/appdata-list.txt
```

#### Step 2: Stop DockServer Containers

```bash
# Stop all DockServer containers
docker stop dockserver dockserver-ui dockserver-autoscan dockserver-mount

# Remove containers
docker rm dockserver dockserver-ui dockserver-autoscan dockserver-mount
```

#### Step 3: Update Docker Compose Files

Edit your docker-compose files to update image references:

```yaml
# Old
image: dockserver/dockserver:latest

# New
image: ghcr.io/smashingtags/homelabarr-legacy-base:latest
```

#### Step 4: Update Environment Variables

Update your `.env` files:

```bash
# Find and replace in .env files
sed -i 's/DOCKSERVER_/HOMELABARR_/g' /opt/dockserver/.env
sed -i 's/DS_/HL_/g' /opt/dockserver/.env
```

#### Step 5: Migrate Paths

```bash
# Move main directory
sudo mv /opt/dockserver /opt/homelabarr

# Move appdata if exists
if [ -d "/opt/appdata/dockserver" ]; then
    sudo mv /opt/appdata/dockserver /opt/appdata/homelabarr
fi
```

#### Step 6: Update Systemd Services

```bash
# Update service files
sudo sed -i 's/dockserver/homelabarr/g' /etc/systemd/system/dockserver*.service

# Rename service files
sudo mv /etc/systemd/system/dockserver.service /etc/systemd/system/homelabarr.service

# Reload systemd
sudo systemctl daemon-reload
```

#### Step 7: Start HomelabARR

```bash
# Navigate to new directory
cd /opt/homelabarr

# Start containers
docker-compose up -d
```

## Rollback Process

If you encounter issues and need to rollback:

### Automated Rollback

```bash
# Download the rollback script
wget https://raw.githubusercontent.com/smashingtags/homelabarr-cli/main/scripts/migration/homelabarr-rollback.sh

# Make it executable
chmod +x homelabarr-rollback.sh

# Run the rollback
sudo ./homelabarr-rollback.sh
```

### Manual Rollback

1. Stop HomelabARR containers
2. Restore backup files (`.bak` files)
3. Move directories back to original locations
4. Restore systemd services
5. Pull DockServer images
6. Start DockServer containers

## Post-Migration Steps

### 1. Verify Services

Check that all services are running:

```bash
# Check container status
docker ps

# Check service logs
docker logs homelabarr-legacy-base
docker logs homelabarr-ui-legacy
```

### 2. Test Functionality

- Access the web UI
- Verify media server connections
- Test download clients
- Check automation tools (Radarr, Sonarr, etc.)

### 3. Update Bookmarks

Update any bookmarks or shortcuts to reflect new URLs if changed.

### 4. Monitor Performance

Monitor the system for the first 24-48 hours to ensure stability.

## Important Notes

### Legacy Containers

The containers with `-legacy` suffix are transitional:
- `homelabarr-legacy-base`: DockServer compatibility layer
- `homelabarr-ui-legacy`: Legacy web UI

These will be deprecated in future releases. Plan to migrate to native HomelabARR solutions when available.

### Breaking Changes

- Custom scripts referencing DockServer paths need updating
- API endpoints may have changed
- Some DockServer-specific features may not be available

### Data Preservation

Your media files and application data remain untouched during migration. Only configuration files and container references are updated.

## Troubleshooting

### Container Won't Start

```bash
# Check logs
docker logs <container-name>

# Verify image pull
docker pull ghcr.io/smashingtags/homelabarr-legacy-base:latest
```

### Permission Issues

```bash
# Fix permissions
sudo chown -R 1000:1000 /opt/appdata/homelabarr
sudo chmod -R 755 /opt/homelabarr
```

### Network Issues

```bash
# Recreate network
docker network rm proxy
docker network create proxy
```

### Service Discovery Problems

```bash
# Restart Traefik
docker restart traefik
```

## Getting Help

If you encounter issues during migration:

1. Check the [HomelabARR Documentation](https://github.com/smashingtags/homelabarr-cli/wiki)
2. Review [Common Issues](https://github.com/smashingtags/homelabarr-cli/issues)
3. Join our [Discord Community](https://discord.gg/homelabarr)
4. Open a [GitHub Issue](https://github.com/smashingtags/homelabarr-cli/issues/new)

## Migration Timeline

### Phase 1: Current (Compatibility Mode)
- Legacy containers available with `-legacy` suffix
- Full DockServer compatibility maintained
- Automated migration tools provided

### Phase 2: Transition (Q1 2025)
- Native HomelabARR replacements introduced
- Feature parity achieved
- Migration tools for legacy → native

### Phase 3: Deprecation (Q2 2025)
- Legacy containers marked deprecated
- Final migration deadline announced
- Extended support period begins

### Phase 4: End of Life (Q3 2025)
- Legacy containers removed from registry
- DockServer compatibility ends
- Full HomelabARR ecosystem only

## Conclusion

The migration from DockServer to HomelabARR represents a significant improvement in:
- **Security**: Enhanced authentication and encryption
- **Performance**: Optimized container builds and caching
- **Maintainability**: Active development and community support
- **Features**: Modern UI, better integration, expanded functionality

We're committed to making this transition as smooth as possible. Thank you for being part of the HomelabARR community!