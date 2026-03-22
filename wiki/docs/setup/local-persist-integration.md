# Native Bind Mount Integration with HomelabARR

HomelabARR uses a modernized, containerized version of the native bind mount Docker volume plugin to ensure application data persists in specific host directories rather than Docker's managed volume locations.

## Overview

The native Docker bind mounts provides several advantages:

- **Predictable Data Location**: Application data is stored in `/opt/appdata/[service]` 
- **Easy Backup**: All application data is in a known, accessible location
- **Migration Friendly**: Data can be easily moved between hosts
- **Volume Management**: Docker manages volume lifecycle while you control the location

## Installation

### Automatic Installation

The recommended way is to use the included installation script:

```bash
sudo /opt/homelabarr/scripts/install-native bind mount-container.sh
```

This script will:
- Create required directories with proper permissions
- Create the `homelabarr-local` Docker network
- Deploy the native bind mount container from GHCR
- Verify the installation is working

### Manual Installation

If you prefer manual installation:

```bash
# 1. Create required directories
sudo mkdir -p /run/docker/plugins /var/lib/docker/plugin-data /opt/appdata
sudo chmod 755 /run/docker/plugins /var/lib/docker/plugin-data /opt/appdata

# 2. Create the network
docker network create homelabarr-local

# 3. Deploy the container
docker run -d \
  --name homelabarr-native bind mount \
  --restart unless-stopped \
  --privileged \
  --user root \
  -v /var/run/docker.sock:/var/run/docker.sock:rw \
  -v /run/docker/plugins:/run/docker/plugins:rw \
  -v /var/lib/docker/plugin-data:/var/lib/docker/plugin-data:rw \
  -v /opt/appdata:/opt/appdata:shared \
  --network homelabarr-local \
  ghcr.io/smashingtags/native bind mount:latest
```

### Using Docker Compose

Deploy using the included compose file:

```bash
cd /opt/homelabarr/apps/local-mode-apps
docker compose -f native bind mount-fixed.yml up -d
```

## Verification

After installation, verify native bind mount is working:

```bash
# Check container status
docker ps | grep native bind mount

# Check plugin socket
ls -la /run/docker/plugins/native bind mount.sock

# Test volume creation
docker volume create -d native bind mount -o mountpoint=/opt/appdata/test --name test-volume

# Verify volume
docker volume ls | grep test-volume
ls -la /opt/appdata/test

# Clean up test
docker volume rm test-volume
rm -rf /opt/appdata/test
```

## Usage in Applications

### Standard Volume Definition

Most HomelabARR applications use this pattern:

```yaml
services:
  plex:
    image: plexinc/pms-docker:latest
    volumes:
      - plex-data:/config
    networks:
      - homelabarr-local

volumes:
  plex-data:
    driver: native bind mount
    driver_opts:
      mountpoint: /opt/appdata/plex

networks:
  homelabarr-local:
    external: true
```

### Application Data Locations

By default, HomelabARR applications store data in:

- **Plex**: `/opt/appdata/plex`
- **Radarr**: `/opt/appdata/radarr`
- **Sonarr**: `/opt/appdata/sonarr`
- **qBittorrent**: `/opt/appdata/qbittorrent`
- **Overseerr**: `/opt/appdata/overseerr`

### Custom Mount Points

You can customize where data is stored:

```yaml
volumes:
  custom-app-data:
    driver: native bind mount
    driver_opts:
      mountpoint: /mnt/storage/myapp  # Custom location
```

## Troubleshooting

### Container Restarting

If the native bind mount container keeps restarting:

```bash
# Check logs
docker logs homelabarr-native bind mount

# Common fix: Ensure proper permissions
sudo chmod 755 /run/docker/plugins
sudo chmod 755 /var/lib/docker/plugin-data
```

### Plugin Socket Not Found

```bash
# Check if socket exists
ls -la /run/docker/plugins/native bind mount.sock

# If missing, restart the container
docker restart homelabarr-native bind mount
```

### Permission Denied Errors

```bash
# Fix directory permissions
sudo chown -R root:root /run/docker/plugins
sudo chmod 755 /run/docker/plugins
```

### Volume Creation Fails

```bash
# Ensure native bind mount is running and healthy
docker ps | grep native bind mount

# Check container health
docker inspect homelabarr-native bind mount | grep Health -A 10
```

## Backup and Migration

### Backing Up Application Data

Since all application data is in `/opt/appdata`, backup is simple:

```bash
# Backup all application data
sudo tar -czf homelabarr-backup-$(date +%Y%m%d).tar.gz -C /opt appdata

# Backup specific application
sudo tar -czf plex-backup-$(date +%Y%m%d).tar.gz -C /opt/appdata plex
```

### Migrating to New Host

1. **Stop applications** on the old host
2. **Backup data**: `tar -czf backup.tar.gz -C /opt appdata`
3. **Transfer** backup to new host
4. **Install HomelabARR** and native bind mount on new host
5. **Restore data**: `tar -xzf backup.tar.gz -C /opt`
6. **Fix permissions**: `sudo chown -R 1000:1000 /opt/appdata`
7. **Start applications** on new host

## Advanced Configuration

### Custom Network

If you need a custom network configuration:

```yaml
networks:
  custom-network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16
```

### Multiple Mount Points

Support for multiple storage locations:

```yaml
services:
  native bind mount:
    volumes:
      - /opt/appdata:/opt/appdata:shared
      - /mnt/storage1:/mnt/storage1:shared
      - /mnt/storage2:/mnt/storage2:shared
```

### Resource Limits

For resource-constrained systems:

```yaml
services:
  native bind mount:
    deploy:
      resources:
        limits:
          memory: 128M
          cpus: '0.5'
```

## Security Considerations

⚠️ **Important Security Notes**:

- Local-persist runs as root and has privileged access
- Only deploy on trusted Docker hosts
- Ensure proper firewall rules for the Docker network
- Regular security updates for the container image

## Container Image Information

- **Registry**: `ghcr.io/smashingtags/native bind mount`
- **Source**: [GitHub Repository](https://github.com/smashingtags/native bind mount)
- **Architecture**: Multi-arch (amd64, arm64)
- **Base**: Minimal Alpine Linux
- **Updates**: Automatically built from source
