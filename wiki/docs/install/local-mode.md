# HomelabARR CE Local Mode

**Local Mode** provides a simplified deployment option for HomelabARR CE applications, allowing direct IP:PORT access without the complexity of Traefik reverse proxy, Authelia authentication, or Cloudflare configuration.

Perfect for local networks, testing environments, or users who prefer direct container access.

---

## Overview

### What is Local Mode?

Local Mode deploys HomelabARR CE applications as standalone Docker containers with direct port mappings to your host system. Each service is accessible via `http://localhost:PORT` or `http://YOUR_SERVER_IP:PORT`.

### Key Differences from Full Mode

| Feature | Full Mode | Local Mode |
|---------|-----------|------------|
| **Access Method** | Domain-based (`https://plex.yourdomain.com`) | Direct IP:PORT (`http://localhost:32400`) |
| **Reverse Proxy** | Traefik required | None |
| **Authentication** | Authelia multi-factor | Application-native only |
| **SSL/HTTPS** | Automatic via Let's Encrypt | HTTP only (or manual SSL) |
| **Domain Required** | Yes + Cloudflare | No |
| **Setup Complexity** | Advanced | Simple |
| **Network Access** | Internet + Local | Local network only |

### Available Local Mode Templates

Currently supported applications with working local mode templates:

- **Plex Media Server** - Port 32400
- **Radarr Movie Manager** - Port 7878  
- **qBittorrent Download Client** - Port 8082

---

## Quick Start

### Prerequisites

- Ubuntu 22.04 LTS (or compatible Linux distribution)
- Docker and Docker Compose installed
- 4GB RAM minimum
- Git installed

### 1. Clone Repository

```bash
git clone https://github.com/smashingtags/homelabarr-ce.git
cd homelabarr-ce
```

### 2. Set Permissions

```bash
chmod +x install.sh
chmod +x apps/.config/*.yml
```

### 3. Prepare Environment

```bash
cd apps/.config
cp .env.example .env
```

Edit the `.env` file with your preferences:

```bash
# Core Settings
ID=1000
TZ=America/New_York
UMASK=002
RESTARTAPP=unless-stopped
SECURITYOPS=no-new-privileges
SECURITYOPSSET=true

# Application Data Path
APPFOLDER=/opt/appdata

# Container Images
PLEXIMAGE=lscr.io/linuxserver/plex:latest
RADARRIMAGE=lscr.io/linuxserver/radarr:latest
QBITORRENTIMAGE=lscr.io/linuxserver/qbittorrent:latest

# Theme Settings (Optional)
PLEXTHEME=dark
RADARRTHEME=dark
QBITORRENTTHEME=dark
```

### 4. Deploy Applications

#### Option A: Interactive Deployment Script (Recommended)

Use the included deployment script for an easy interactive experience:

```bash
# Make script executable
chmod +x deploy-local.sh

# Run interactive deployment
./deploy-local.sh
```

The script provides:
- ✨ Interactive menu for deploying applications
- 🔄 Health checks and port conflict detection
- 📊 Container status monitoring
- 📄 Log viewing capabilities
- 📯 Bulk deployment/management options

#### Option B: Manual Deployment

**Deploy Plex Media Server:**

```bash
docker compose -f plex-local-template.yml --env-file .env up -d
```

Access Plex at: **http://localhost:32400**

#### Deploy Radarr (Movie Management)

```bash
docker compose -f radarr-local-template.yml --env-file .env up -d
```

Access Radarr at: **http://localhost:7878**

#### Deploy qBittorrent (Download Client)

```bash
docker compose -f qbittorrent-local-template.yml --env-file .env up -d
```

Access qBittorrent at: **http://localhost:8082**

#### Deploy Multiple Services

```bash
# Deploy all three services
docker compose -f plex-local-template.yml --env-file .env up -d
docker compose -f radarr-local-template.yml --env-file .env up -d
docker compose -f qbittorrent-local-template.yml --env-file .env up -d

# Or use multiple compose files
docker compose -f plex-local-template.yml -f radarr-local-template.yml --env-file .env up -d
```

---

## Port Assignments

Local Mode uses the following port allocation strategy to avoid conflicts:

| Service Category | Port Range | Example Services |
|------------------|------------|------------------|
| **Media Servers** | 32400, 8096-8099 | Plex (32400), Jellyfin (8096) |
| **Media Managers** | 7800-7899 | Radarr (7878), Sonarr (8989), Lidarr (8686) |
| **Download Clients** | 8080-8199 | qBittorrent (8082), SABnzbd (8080) |
| **Request Management** | 5050-5099 | Overseerr (5055), Petio (7777) |
| **Monitoring** | 8180-8199 | Tautulli (8181), Grafana (3000) |

### Current Port Mappings

- **Plex**: 32400
- **Radarr**: 7878
- **qBittorrent**: 8082 (WebUI) + 7889 (DHT)

---

## Network Configuration

### Docker Network

Local Mode creates a dedicated bridge network for inter-container communication:

```yaml
networks:
  homelabarr-local:
    driver: bridge
```

All local mode containers join this network while also exposing ports to the host system.

### Accessing from Other Devices

To access services from other devices on your network, replace `localhost` with your server's IP address:

```bash
# Find your server IP
ip addr show | grep "inet " | grep -v 127.0.0.1

# Access from other devices
http://192.168.1.100:32400  # Replace with your actual IP
```

### Firewall Considerations

Ensure your firewall allows traffic on the required ports:

```bash
# Ubuntu/Debian UFW firewall
sudo ufw allow 32400  # Plex
sudo ufw allow 7878   # Radarr
sudo ufw allow 8082   # qBittorrent

# Or allow range
sudo ufw allow 7800:8200/tcp
```

---

## Volume Management

### Storage Structure

Local Mode maintains the same volume structure as Full Mode:

```
/opt/appdata/           # Application configurations
├── plex/
│   └── database/       # Plex configuration and database
├── radarr/             # Radarr configuration
└── qbittorrent/        # qBittorrent configuration

/mnt/                   # Media storage (unionfs mount)
├── downloads/          # Download client storage
├── movies/             # Movie library
├── tv/                 # TV show library
└── music/              # Music library
```

### UnionFS Integration

Local Mode templates include UnionFS volume support:

```yaml
volumes:
  unionfs:
    driver: local-persist
    driver_opts:
      mountpoint: /mnt
```

This provides the same unified storage experience as Full Mode.

---

## Management Commands

### Service Management

```bash
# View running containers
docker compose -f plex-local-template.yml ps

# Stop service
docker compose -f plex-local-template.yml down

# Restart service
docker compose -f plex-local-template.yml restart

# Update service
docker compose -f plex-local-template.yml pull
docker compose -f plex-local-template.yml up -d
```

### Logs and Monitoring

```bash
# View logs
docker compose -f plex-local-template.yml logs -f

# Check container stats
docker stats

# Health check status
docker compose -f plex-local-template.yml ps
```

### Backup and Maintenance

```bash
# Backup application data
sudo tar -czf appdata-backup.tar.gz /opt/appdata/

# Clean up unused images
docker system prune -f

# Update all containers
docker compose -f plex-local-template.yml pull
docker compose -f radarr-local-template.yml pull
docker compose -f qbittorrent-local-template.yml pull
```

---

## Configuration Details

### Environment Variables

Local Mode templates support all standard HomelabARR CE environment variables:

| Variable | Description | Example |
|----------|-------------|---------|
| `ID` | User/Group ID for file permissions | `1000` |
| `TZ` | Timezone | `America/New_York` |
| `UMASK` | File creation permissions mask | `002` |
| `APPFOLDER` | Application data directory | `/opt/appdata` |
| `RESTARTAPP` | Container restart policy | `unless-stopped` |

### Theme Support

Local Mode maintains full Theme Park integration:

```yaml
environment:
  - "DOCKER_MODS=ghcr.io/themepark-dev/theme.park:plex"
  - "TP_THEME=${PLEXTHEME}"
  - "TP_ADDON=${PLEXADDON}"
```

Available themes: `dark`, `plex`, `space-gray`, `aquamarine`, and many more.

### Security Options

Security settings are preserved from Full Mode:

```yaml
security_opt:
  - "no-new-privileges:true"
deploy:
  resources:
    limits:
      memory: 4G
    reservations:
      memory: 1G
```

---

## Troubleshooting

### Common Issues

#### Port Already in Use
```bash
# Check what's using a port
sudo lsof -i :32400

# Change port in compose file if needed
ports:
  - "32401:32400"  # Use different host port
```

#### Permission Issues
```bash
# Fix ownership of app data
sudo chown -R 1000:1000 /opt/appdata/

# Check container user
docker exec plex id
```

#### Network Access Issues
```bash
# Verify network creation
docker network ls | grep homelabarr-local

# Test container connectivity
docker exec plex ping radarr
```

#### Container Won't Start
```bash
# Check logs for errors
docker compose -f plex-local-template.yml logs

# Validate compose file
docker compose -f plex-local-template.yml config
```

### Health Checks

Plex includes built-in health monitoring:

```bash
# Check health status
docker inspect plex | grep -A 10 "Health"

# Manual health check
docker exec plex curl -f http://localhost:32400/identity
```

### Performance Tuning

#### Memory Limits
```yaml
deploy:
  resources:
    limits:
      memory: 4G      # Adjust based on available RAM
    reservations:
      memory: 1G      # Minimum guaranteed memory
```

#### Storage Optimization
```bash
# Enable Docker BuildKit for better caching
export DOCKER_BUILDKIT=1

# Use faster Docker storage driver
# Edit /etc/docker/daemon.json
{
  "storage-driver": "overlay2"
}
```

---

## Expanding Local Mode

### Adding New Services

To create additional local mode templates:

1. **Copy existing template**:
   ```bash
   cp plex-local-template.yml myapp-local-template.yml
   ```

2. **Modify configuration**:
   - Change service name and container name
   - Update image reference
   - Assign unique port
   - Adjust environment variables
   - Remove Traefik-specific labels

3. **Add network definition**:
   ```yaml
   networks:
     homelabarr-local:
       driver: bridge
   ```

4. **Test deployment**:
   ```bash
   docker compose -f myapp-local-template.yml config
   docker compose -f myapp-local-template.yml up -d
   ```

### Integration with Full Mode

Local Mode and Full Mode can coexist:

- Use different container names
- Assign different ports
- Use separate networks
- Deploy in different directories

This allows testing Local Mode while maintaining Full Mode production services.

---

## Migration

### From Full Mode to Local Mode

1. **Backup configurations**:
   ```bash
   sudo tar -czf homelabarr-backup.tar.gz /opt/appdata/
   ```

2. **Stop Full Mode services**:
   ```bash
   sudo homelabarr
   # Use interface to stop services
   ```

3. **Deploy Local Mode**:
   ```bash
   cd /path/to/homelabarr-ce/apps/.config
   docker compose -f plex-local-template.yml --env-file .env up -d
   ```

4. **Restore configurations**:
   Existing `/opt/appdata/` configurations should work directly.

### From Local Mode to Full Mode

1. **Stop Local Mode containers**:
   ```bash
   docker compose -f plex-local-template.yml down
   ```

2. **Install HomelabARR CE Full Mode**:
   ```bash
   sudo wget -qO- https://git.io/J3GDc | sudo bash
   ```

3. **Deploy through HomelabARR CE interface**:
   ```bash
   sudo homelabarr -i
   ```

Existing application data remains compatible between modes.

---

## Support and Community

### Getting Help

- **GitHub Issues**: [Report bugs and request features](https://github.com/smashingtags/homelabarr-ce/issues)
- **Discord Community**: [Join our Discord server](https://discord.gg/Pc7mXX786x)
- **Documentation**: [Full HomelabARR CE Wiki](https://github.com/smashingtags/homelabarr-ce/tree/main/wiki)

### Contributing

Local Mode templates follow standard HomelabARR CE contribution guidelines:

1. Fork the repository
2. Create local mode templates in `apps/.config/`
3. Test thoroughly with validation
4. Submit pull request with documentation
5. Follow existing naming conventions

---

## What's Next?

Local Mode is actively being expanded with additional service templates. Planned additions include:

- **Sonarr** (TV show management)
- **Jellyfin** (alternative media server)  
- **Overseerr** (media requests)
- **SABnzbd** (usenet downloader)
- **Tautulli** (Plex monitoring)

Stay tuned for updates and contribute your own templates!

---

---

## Quick Reference

### Essential Commands

```bash
# Interactive deployment (recommended)
./deploy-local.sh

# Manual deployments
docker compose -f plex-local-template.yml --env-file .env up -d
docker compose -f radarr-local-template.yml --env-file .env up -d
docker compose -f qbittorrent-local-template.yml --env-file .env up -d

# Stop services
docker compose -f plex-local-template.yml down

# View logs
docker compose -f plex-local-template.yml logs -f

# Check status
docker ps
```

### Default Access URLs

- **Plex Media Server**: http://localhost:32400
- **Radarr Movie Manager**: http://localhost:7878
- **qBittorrent Download Client**: http://localhost:8082

### File Locations

- **Templates**: `/path/to/homelabarr-ce/apps/.config/`
- **Environment**: `/path/to/homelabarr-ce/apps/.config/.env`
- **App Data**: `/opt/appdata/` (or as configured in .env)
- **Media**: `/mnt/` (UnionFS mount)

## 🎉 Local Mode Setup Complete!

**Congratulations!** You've successfully set up HomelabARR CE in Local Mode. Your simplified media server stack is now running and accessible on your local network.

### What's Next?
- Start adding your media files to the configured directories
- Explore additional [applications](../apps/apps.md) from our collection
- Consider upgrading to [Full Mode](../guides/quick-start.md) when you're ready for external access
- Join our [Discord community](https://discord.gg/Pc7mXX786x) for tips and support

### Support Development
If Local Mode helped you get started with self-hosting, consider supporting the project:

**☕ [Support on Ko-fi](https://ko-fi.com/homelabarr)** - Help us maintain Local Mode and develop new features for the community!

---

*Local Mode provides a bridge between complexity and functionality, making HomelabARR CE accessible to users of all technical levels.*
