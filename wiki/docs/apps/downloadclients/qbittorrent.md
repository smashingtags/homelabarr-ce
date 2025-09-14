# qBittorrent - Modern BitTorrent Client

## Overview
qBittorrent is a cross-platform free and open-source BitTorrent client. It provides an integrated search engine, bandwidth scheduler, and Web UI for remote access. Updated from PTS/MHA documentation for HomelabARR with modern Traefik v3.5.0 configuration.

## Container Information

### Image
- **Registry**: `lscr.io/linuxserver/qbittorrent`
- **Current Version**: `4.6.7`
- **Alternative**: `ghcr.io/hotio/qbittorrent` (includes VueTorrent UI)

### Ports
- **8080/tcp**: Web UI
- **6881/tcp**: BitTorrent port
- **6881/udp**: BitTorrent port

## Environment Variables

```yaml
environment:
  - PUID=1000
  - PGID=1000
  - TZ=${TZ}
  - WEBUI_PORT=8080
  - TORRENTING_PORT=6881
```

## Volume Mounts

```yaml
volumes:
  - ${APPDATA_PATH}/qbittorrent:/config
  - ${DOWNLOADS_PATH}:/downloads
  - ${DOWNLOADS_PATH}/incomplete:/incomplete  # Optional: incomplete downloads
  - ${MEDIA_PATH}:/media                      # Optional: direct media access
```

## Docker Compose Configuration

### Modern HomelabARR Configuration (Traefik v3.5.0)

```yaml
services:
  qbittorrent:
    image: lscr.io/linuxserver/qbittorrent:4.6.7
    container_name: qbittorrent
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=${TZ}
      - WEBUI_PORT=8080
      - TORRENTING_PORT=6881
    volumes:
      - ${APPDATA_PATH}/qbittorrent:/config
      - ${DOWNLOADS_PATH}:/downloads
      - ${MEDIA_PATH}:/media
    networks:
      - proxy
    ports:
      - "8080:8080"
      - "6881:6881"
      - "6881:6881/udp"
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080"]
      interval: 30s
      timeout: 5s
      retries: 3
      start_period: 30s
    labels:
      - "traefik.enable=true"
      - "traefik.docker.network=proxy"
      
      # HTTP Router
      - "traefik.http.routers.qbittorrent.entrypoints=websecure"
      - "traefik.http.routers.qbittorrent.rule=Host(`qbittorrent.${DOMAIN}`)"
      - "traefik.http.routers.qbittorrent.tls.certresolver=cloudflare"
      - "traefik.http.services.qbittorrent.loadbalancer.server.port=8080"
      
      # Middlewares
      - "traefik.http.routers.qbittorrent.middlewares=authelia@docker,default-headers@file"
      
      # Special headers for qBittorrent
      - "traefik.http.routers.qbittorrent.middlewares=qbit-headers@docker"
      - "traefik.http.middlewares.qbit-headers.headers.customRequestHeaders.X-Frame-Options=SAMEORIGIN"
      - "traefik.http.middlewares.qbit-headers.headers.customRequestHeaders.Referer="
      - "traefik.http.middlewares.qbit-headers.headers.customRequestHeaders.Origin="
      
      # Container updates
      - "dockupdater.enable=true"
```

### VPN Configuration (Recommended)

```yaml
services:
  qbittorrent-vpn:
    image: ghcr.io/hotio/qbittorrent:latest
    container_name: qbittorrent
    cap_add:
      - NET_ADMIN
    devices:
      - /dev/net/tun
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=${TZ}
      - VPN_ENABLED=true
      - VPN_TYPE=wireguard
      - VPN_CONF=wg0
      - VPN_LAN_NETWORK=192.168.1.0/24
      - VPN_ADDITIONAL_PORTS=8080/tcp,6881/tcp,6881/udp
      - PRIVOXY_ENABLED=false
    volumes:
      - ${APPDATA_PATH}/qbittorrent:/config
      - ${DOWNLOADS_PATH}:/downloads
      - ${APPDATA_PATH}/wireguard:/config/wireguard
    networks:
      - proxy
    ports:
      - "8080:8080"
      - "6881:6881"
      - "6881:6881/udp"
    restart: unless-stopped
```

## Initial Setup

### 1. Default Credentials
- **Username**: `admin`
- **Password**: `adminadmin`
- **IMPORTANT**: Change immediately after first login

### 2. Security Configuration
```bash
# Generate secure password
docker exec qbittorrent qbittorrent-nox --webui-port=8080 --profile=/config
```

### 3. Web UI Configuration
- Tools → Options → Web UI
- Enable "Bypass authentication for clients on localhost"
- Set alternative Web UI (optional): VueTorrent, Flood

## qBittorrent Configuration

### Connection Settings
```ini
[Preferences]
Connection\PortRangeMin=6881
Connection\UPnP=false
Connection\GlobalDLLimit=0
Connection\GlobalUPLimit=0
Connection\GlobalDLLimitAlt=10240
Connection\GlobalUPLimitAlt=10240
Connection\MaxConnections=200
Connection\MaxConnectionsPerTorrent=100
Connection\MaxUploads=20
Connection\MaxUploadsPerTorrent=4
```

### Downloads Configuration
```ini
[Preferences]
Downloads\SavePath=/downloads/complete/
Downloads\TempPath=/downloads/incomplete/
Downloads\TempPathEnabled=true
Downloads\PreAllocation=true
Downloads\UseIncompleteExtension=true
Downloads\ScanDirsV2=@Variant(\0\0\0\x1c\0\0\0\x1\0\0\0\x14\0/\0\x64\0o\0w\0n\0l\0o\0\x61\0\x64\0s\0/\0w\0\x61\0t\0\x63\0h\0\0\0\x2\0\0\0\0)
```

### Categories Setup

```bash
# Movies category
Category: movies
Save Path: /downloads/movies

# TV Shows category
Category: tv
Save Path: /downloads/tv

# Music category
Category: music
Save Path: /downloads/music
```

## Integration with Arr Stack

### Sonarr Configuration
```json
{
  "name": "qBittorrent",
  "enable": true,
  "protocol": "torrent",
  "host": "qbittorrent",
  "port": 8080,
  "username": "admin",
  "password": "your_password",
  "category": "tv",
  "priority": 0,
  "initialState": "start",
  "removeCompletedDownloads": false,
  "removeFailedDownloads": true
}
```

### Radarr Configuration
```json
{
  "name": "qBittorrent",
  "enable": true,
  "protocol": "torrent",
  "host": "qbittorrent",
  "port": 8080,
  "username": "admin",
  "password": "your_password",
  "category": "movies",
  "priority": 0,
  "initialState": "start",
  "removeCompletedDownloads": false,
  "removeFailedDownloads": true
}
```

## Advanced Features

### RSS Feeds
```ini
# Auto-download from RSS
[RSS]
AutoDownloader\Enable=true
AutoDownloader\SmartEpisodeFilter=s(\\d+)e(\\d+)
AutoDownloader\DownloadRepacks=true
```

### Sequential Download
- Useful for streaming while downloading
- Right-click torrent → "Download in sequential order"

### IP Filtering
```bash
# Block malicious IPs
wget -O ${APPDATA_PATH}/qbittorrent/ipfilter.dat https://github.com/DavidMoore/ipfilter/releases/download/lists/ipfilter.dat
```

### Search Plugins
```bash
# Install search plugins
docker exec -it qbittorrent python3 /usr/bin/nova3/nova2dl.py
```

## VueTorrent UI Installation

```bash
# Download VueTorrent
cd ${APPDATA_PATH}/qbittorrent
wget -O vuetorrent.zip https://github.com/WDaan/VueTorrent/releases/latest/download/vuetorrent.zip
unzip vuetorrent.zip
rm vuetorrent.zip

# Configure in qBittorrent
# Tools → Options → Web UI → Use Alternative WebUI
# Path: /config/vuetorrent
```

## Performance Optimization

### Cache Settings
```ini
[Preferences]
Advanced\DiskCache=256
Advanced\DiskCacheTTL=60
Advanced\EnableOSCache=true
Advanced\OutgoingPortsMin=0
Advanced\OutgoingPortsMax=0
```

### Connection Limits
```ini
# For high-performance systems
Connection\MaxConnections=500
Connection\MaxConnectionsPerTorrent=100
Connection\MaxUploads=50
Connection\MaxUploadsPerTorrent=10
```

### File System
```ini
# Enable preallocation for better performance
Downloads\PreAllocation=true
Advanced\EnableOSCache=false  # Disable if using ZFS
```

## Security Hardening

### Web UI Security
```nginx
# Additional Traefik headers
- "traefik.http.middlewares.qbit-security.headers.customResponseHeaders.X-Robots-Tag=noindex,nofollow,nosnippet,noarchive,notranslate,noimageindex"
- "traefik.http.middlewares.qbit-security.headers.SSLRedirect=true"
- "traefik.http.middlewares.qbit-security.headers.STSSeconds=315360000"
- "traefik.http.middlewares.qbit-security.headers.STSIncludeSubdomains=true"
- "traefik.http.middlewares.qbit-security.headers.STSPreload=true"
```

### Anonymous Mode
```ini
[Preferences]
Bittorrent\AnonymousMode=true
Bittorrent\EnableDHT=false
Bittorrent\EnableLPD=false
Bittorrent\EnablePeX=false
```

## Backup Strategy

### Configuration Files
```bash
#!/bin/bash
# Backup qBittorrent config
BACKUP_DIR="/backup/qbittorrent"
mkdir -p "$BACKUP_DIR"

# Stop container for consistent backup
docker stop qbittorrent

# Backup configuration
tar czf "$BACKUP_DIR/qbittorrent-$(date +%Y%m%d).tar.gz" \
  -C "${APPDATA_PATH}" \
  qbittorrent/qBittorrent.conf \
  qbittorrent/categories.json \
  qbittorrent/feeds.json

# Restart container
docker start qbittorrent
```

## Monitoring

### API Access
```bash
# Get torrent list
curl -i --header "Referer: http://localhost:8080" \
  --cookie "SID=YOUR_SESSION_ID" \
  http://localhost:8080/api/v2/torrents/info

# Get statistics
curl -i --header "Referer: http://localhost:8080" \
  --cookie "SID=YOUR_SESSION_ID" \
  http://localhost:8080/api/v2/transfer/info
```

### Prometheus Exporter
```yaml
qbittorrent-exporter:
  image: caseyscarborough/qbittorrent-exporter:latest
  container_name: qbittorrent-exporter
  environment:
    - QBITTORRENT_URL=http://qbittorrent:8080
    - QBITTORRENT_USERNAME=admin
    - QBITTORRENT_PASSWORD=${QB_PASSWORD}
  ports:
    - "9561:9561"
  networks:
    - proxy
```

## Common Issues

### WebUI Not Accessible
```bash
# Reset WebUI settings
docker exec qbittorrent rm /config/qBittorrent/qBittorrent.conf
docker restart qbittorrent
```

### Permission Issues
```bash
# Fix permissions
docker exec qbittorrent chown -R 1000:1000 /downloads
docker exec qbittorrent chmod -R 755 /downloads
```

### Port Already in Use
```bash
# Check what's using the port
sudo lsof -i :6881
sudo netstat -tulpn | grep 6881
```

## Migration from Legacy Clients

### From Deluge
```bash
# Export torrents from Deluge
# Import .torrent files to qBittorrent watched folder
```

### From Transmission
```bash
# Use transmission-to-qbittorrent script
python3 transmission_to_qbittorrent.py \
  --transmission-dir /old/transmission/config \
  --qbittorrent-dir ${APPDATA_PATH}/qbittorrent
```

## Alternative Configurations

### Flood UI
```yaml
flood:
  image: jesec/flood:latest
  container_name: flood
  environment:
    - HOME=/config
  volumes:
    - ${APPDATA_PATH}/flood:/config
    - ${DOWNLOADS_PATH}:/downloads
  ports:
    - "3001:3000"
  command: --auth none --qburl http://qbittorrent:8080
```

## Resources

- [Official qBittorrent Documentation](https://github.com/qbittorrent/qBittorrent/wiki)
- [LinuxServer.io Documentation](https://docs.linuxserver.io/images/docker-qbittorrent)
- [VueTorrent GitHub](https://github.com/WDaan/VueTorrent)
- [TRaSH Guides - qBittorrent](https://trash-guides.info/Downloaders/qBittorrent/)
- [Original MHA-Team PTS Wiki](https://github.com/MHA-Team/PTS-Team/wiki)
- [HomelabARR Download Clients](../downloadclients/)

---

*Last Updated: January 2025*  
*Adapted from MHA-Team PTS Wiki for HomelabARR with modern security practices*