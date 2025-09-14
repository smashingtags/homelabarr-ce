# Sonarr - TV Show Management

## Overview
Sonarr is a PVR for Usenet and BitTorrent users. It monitors multiple RSS feeds for new episodes and will grab, sort, and rename them. Originally part of the PTS/MHA stack, this documentation has been updated for HomelabARR with Traefik v3.5.0.

## Container Information

### Image
- **Registry**: `lscr.io/linuxserver/sonarr`
- **Current Version**: `4.0.11`
- **Branch Options**: 
  - `latest`: Stable v4 releases
  - `develop`: Development builds
  - `nightly`: Nightly builds (unstable)

### Ports
- **8989/tcp**: Web UI

## Environment Variables

```yaml
environment:
  - PUID=1000
  - PGID=1000
  - TZ=${TZ}
```

## Volume Mounts

```yaml
volumes:
  - ${APPDATA_PATH}/sonarr:/config
  - ${MEDIA_PATH}/tv:/tv                    # TV library
  - ${DOWNLOADS_PATH}:/downloads            # Download client downloads
  - ${DOWNLOADS_PATH}/complete:/complete    # Optional: completed downloads
```

## Docker Compose Configuration

### Modern HomelabARR Configuration (Traefik v3.5.0)

```yaml
services:
  sonarr:
    image: lscr.io/linuxserver/sonarr:4.0.11
    container_name: sonarr
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=${TZ}
    volumes:
      - ${APPDATA_PATH}/sonarr:/config
      - ${MEDIA_PATH}:/media
      - ${DOWNLOADS_PATH}:/downloads
    networks:
      - proxy
    ports:
      - "8989:8989"
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:8989/ping"]
      interval: 30s
      timeout: 5s
      retries: 3
      start_period: 30s
    labels:
      - "traefik.enable=true"
      - "traefik.docker.network=proxy"
      
      # HTTP Router
      - "traefik.http.routers.sonarr.entrypoints=websecure"
      - "traefik.http.routers.sonarr.rule=Host(`sonarr.${DOMAIN}`)"
      - "traefik.http.routers.sonarr.tls.certresolver=cloudflare"
      - "traefik.http.services.sonarr.loadbalancer.server.port=8989"
      
      # Middlewares
      - "traefik.http.routers.sonarr.middlewares=authelia@docker,default-headers@file"
      
      # API bypass for external access (optional)
      - "traefik.http.routers.sonarr-api.entrypoints=websecure"
      - "traefik.http.routers.sonarr-api.rule=Host(`sonarr.${DOMAIN}`) && (PathPrefix(`/api`) || PathPrefix(`/feed`) || PathPrefix(`/ping`))"
      - "traefik.http.routers.sonarr-api.tls.certresolver=cloudflare"
      - "traefik.http.routers.sonarr-api.service=sonarr"
      - "traefik.http.routers.sonarr-api.priority=100"
      
      # Container updates
      - "dockupdater.enable=true"
```

### Legacy PTS/MHA Configuration (Reference Only)

```yaml
# DO NOT USE - Outdated Traefik v1.x syntax
sonarr:
  labels:
    - "traefik.enable=true"
    - "traefik.frontend.rule=Host:sonarr.domain.com"
    - "traefik.port=8989"
    - "traefik.frontend.auth.basic=user:password"
```

## Initial Setup

### 1. First Access
- Local: http://localhost:8989
- Remote: https://sonarr.yourdomain.com

### 2. Authentication Setup
```xml
<!-- config.xml -->
<Config>
  <AuthenticationMethod>Forms</AuthenticationMethod>
  <AuthenticationRequired>DisabledForLocalAddresses</AuthenticationRequired>
</Config>
```

### 3. Download Client Configuration

#### SABnzbd
```json
{
  "name": "SABnzbd",
  "host": "sabnzbd",
  "port": 8080,
  "apiKey": "YOUR_API_KEY",
  "category": "tv",
  "priority": 0
}
```

#### qBittorrent
```json
{
  "name": "qBittorrent",
  "host": "qbittorrent",
  "port": 8080,
  "username": "admin",
  "password": "adminadmin",
  "category": "tv"
}
```

### 4. Indexer Setup

#### Jackett/Prowlarr
```json
{
  "name": "Jackett",
  "url": "http://jackett:9117/api/v2.0/indexers/all/results/torznab",
  "apiKey": "YOUR_JACKETT_API_KEY",
  "categories": [5030, 5040]
}
```

## Root Folder Configuration

### Standard Setup
```bash
/media/
├── tv/
│   ├── Show Name (Year)/
│   │   ├── Season 01/
│   │   ├── Season 02/
│   │   └── Specials/
```

### Multiple Libraries
```yaml
volumes:
  - ${MEDIA_PATH}/tv:/tv
  - ${MEDIA_PATH}/anime:/anime
  - ${MEDIA_PATH}/documentaries:/documentaries
  - ${MEDIA_PATH}/kids:/kids
```

## Quality Profiles

### Recommended Profiles

#### HD-1080p
- Upgrades: WEB-DL → Bluray
- Cutoff: Bluray-1080p
- Preferred: x265, HEVC

#### 4K
- Upgrades: WEB-DL → Bluray
- Cutoff: Bluray-2160p
- Preferred: HDR, DV, x265

## Naming Conventions

### Standard Format
```
{Series Title} - S{season:00}E{episode:00} - {Episode Title} {Quality Full}
```

### Anime Format
```
{Series Title} - S{season:00}E{episode:00} - {absolute:000} - {Episode Title} {Quality Full}
```

## API Integration

### API Key Location
Settings → General → Security → API Key

### Common API Endpoints
```bash
# Test connection
curl "http://sonarr:8989/api/v3/system/status?apikey=YOUR_API_KEY"

# Get all series
curl "http://sonarr:8989/api/v3/series?apikey=YOUR_API_KEY"

# Trigger search
curl -X POST "http://sonarr:8989/api/v3/command?apikey=YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"name":"SeriesSearch","seriesId":1}'
```

## Integration with Other Services

### Plex
- Settings → Connect → Add → Plex Media Server
- Automatic library updates on import

### Tautulli
- Notifications on grab/import
- Statistics tracking

### Overseerr/Petio
- Automatic request approval
- Quality profile management

### Bazarr (Subtitles)
```yaml
environment:
  - SONARR_URL=http://sonarr:8989
  - SONARR_API_KEY=${SONARR_API_KEY}
```

## Performance Optimization

### Database Maintenance
```bash
# Backup database
docker exec sonarr cp /config/sonarr.db /config/sonarr.db.backup

# Vacuum database (monthly)
docker exec sonarr sqlite3 /config/sonarr.db "VACUUM;"
docker exec sonarr sqlite3 /config/sonarr.db "REINDEX;"
```

### Resource Limits
```yaml
deploy:
  resources:
    limits:
      cpus: '2.0'
      memory: 2G
    reservations:
      memory: 512M
```

## Backup Strategy

### Critical Files
```
/config/
├── sonarr.db          # Main database
├── sonarr.db-wal      # Write-ahead log
├── sonarr.db-shm      # Shared memory
├── config.xml         # Configuration
└── Backups/           # Automatic backups
```

### Backup Script
```bash
#!/bin/bash
BACKUP_PATH="/backup/sonarr"
mkdir -p "$BACKUP_PATH"
docker exec sonarr tar czf - -C /config . | cat > "$BACKUP_PATH/sonarr-$(date +%Y%m%d).tar.gz"
```

## Common Issues & Solutions

### No Results from Indexers
- Verify indexer API keys
- Check indexer categories (TV = 5000-5999)
- Test indexer connection manually

### Import Failures
- Check file permissions (PUID/PGID)
- Verify path mappings between Sonarr and download client
- Enable "Use Hardlinks" for same filesystem

### Database Locked
```bash
# Stop container
docker stop sonarr

# Check database integrity
docker run --rm -v ${APPDATA_PATH}/sonarr:/config \
  lscr.io/linuxserver/sonarr sqlite3 /config/sonarr.db "PRAGMA integrity_check;"

# Restart
docker start sonarr
```

## Migration from v3 to v4

### Automatic Migration
- v4 automatically migrates v3 database on first start
- Backup created in `/config/Backups/`

### Manual Backup Before Upgrade
```bash
docker exec sonarr cp /config/sonarr.db /config/sonarr.db.v3backup
docker-compose down
# Update image tag to v4
docker-compose up -d
```

## Custom Scripts

### Post-Processing Script Example
```bash
#!/bin/bash
# /config/scripts/post-process.sh

# Variables from Sonarr
seriesTitle="${sonarr_series_title}"
episodeFile="${sonarr_episodefile_path}"
eventType="${sonarr_eventtype}"

# Log the event
echo "$(date): $eventType - $seriesTitle - $episodeFile" >> /config/scripts/activity.log

# Custom actions based on event type
if [ "$eventType" = "Download" ]; then
    # Notify external service
    curl -X POST "https://webhook.site/your-webhook" \
      -H "Content-Type: application/json" \
      -d "{\"series\":\"$seriesTitle\",\"file\":\"$episodeFile\"}"
fi
```

## Advanced Configuration

### Custom Formats
- Settings → Profiles → Custom Formats
- Score based on release groups, quality, codecs

### Release Profiles (Deprecated in v4)
- Replaced by Custom Formats in v4
- Better scoring system

### Import Lists
- Trakt lists
- IMDB lists
- Plex watchlist
- Custom lists via API

## Monitoring

### Health Checks
- System → Status → Health
- Monitor indexer failures
- Check download client status

### Logs
```bash
# View logs
docker logs sonarr

# Follow logs
docker logs -f sonarr

# Log files location
/config/logs/sonarr.txt
```

## Resources

- [Official Sonarr Documentation](https://wiki.servarr.com/sonarr)
- [TRaSH Guides](https://trash-guides.info/Sonarr/)
- [LinuxServer.io Documentation](https://docs.linuxserver.io/images/docker-sonarr)
- [Original MHA-Team PTS Wiki](https://github.com/MHA-Team/PTS-Team/wiki)
- [HomelabARR Traefik Guide](../../traefik/README.md)

---

*Last Updated: January 2025*  
*Adapted from MHA-Team PTS Wiki for HomelabARR with Traefik v3.5.0*