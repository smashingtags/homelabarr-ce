# Plex Media Server

## Overview
Plex organizes your video, music, and photo collections and streams them to all your devices. Originally documented in the MHA-Team PTS wiki, this guide has been updated for HomelabARR with Traefik v3.5.0 and modern best practices.

## Container Information

### Image
- **Registry**: `lscr.io/linuxserver/plex`
- **Current Version**: `1.41.3`
- **Legacy Image**: `plexinc/pms-docker` (deprecated)

### Ports
- **32400/tcp**: Web UI and primary access port
- **1900/udp**: DLNA discovery
- **3005/tcp**: Plex Companion
- **5353/udp**: Bonjour/Avahi discovery
- **8324/tcp**: Roku companion
- **32410/udp**: GDM network discovery
- **32412-32414/udp**: GDM network discovery
- **32469/tcp**: Plex DLNA server

## Environment Variables

```yaml
environment:
  - PUID=1000
  - PGID=1000
  - TZ=${TZ}
  - VERSION=docker  # or specific version like 1.41.3.9314-a0bfb8370
  - PLEX_CLAIM=${PLEX_CLAIM}  # Optional: claim token from https://plex.tv/claim
```

## Volume Mounts

```yaml
volumes:
  - ${APPDATA_PATH}/plex:/config
  - ${MEDIA_PATH}/movies:/movies
  - ${MEDIA_PATH}/tv:/tv
  - ${MEDIA_PATH}/music:/music
  - ${MEDIA_PATH}/photos:/photos
  - /dev/shm:/transcode  # RAM disk for transcoding (optional but recommended)
```

## Docker Compose Configuration

### Modern HomelabARR Configuration (Traefik v3.5.0)

```yaml
services:
  plex:
    image: lscr.io/linuxserver/plex:1.41.3
    container_name: plex
    network_mode: host  # Required for DLNA and discovery
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=${TZ}
      - VERSION=docker
      - PLEX_CLAIM=${PLEX_CLAIM}
    volumes:
      - ${APPDATA_PATH}/plex:/config
      - ${MEDIA_PATH}:/media
      - /dev/shm:/transcode
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:32400/identity"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s
    labels:
      - "traefik.enable=true"
      - "traefik.docker.network=proxy"
      
      # HTTP Router
      - "traefik.http.routers.plex.entrypoints=websecure"
      - "traefik.http.routers.plex.rule=Host(`plex.${DOMAIN}`)"
      - "traefik.http.routers.plex.tls.certresolver=cloudflare"
      - "traefik.http.services.plex.loadbalancer.server.port=32400"
      
      # Middlewares
      - "traefik.http.routers.plex.middlewares=plex-headers@docker"
      - "traefik.http.middlewares.plex-headers.headers.customResponseHeaders.X-Robots-Tag=noindex,nofollow,nosnippet,noarchive,notranslate,noimageindex"
      - "traefik.http.middlewares.plex-headers.headers.SSLRedirect=true"
      - "traefik.http.middlewares.plex-headers.headers.SSLHost=plex.${DOMAIN}"
      - "traefik.http.middlewares.plex-headers.headers.SSLForceHost=true"
      - "traefik.http.middlewares.plex-headers.headers.STSSeconds=315360000"
      - "traefik.http.middlewares.plex-headers.headers.STSIncludeSubdomains=true"
      - "traefik.http.middlewares.plex-headers.headers.STSPreload=true"
      - "traefik.http.middlewares.plex-headers.headers.forceSTSHeader=true"
      - "traefik.http.middlewares.plex-headers.headers.contentTypeNosniff=true"
      - "traefik.http.middlewares.plex-headers.headers.browserXSSFilter=true"
      
      # Container updates
      - "dockupdater.enable=true"
```

### Legacy PTS/MHA Configuration (Traefik v1.x/v2.x) - DO NOT USE

```yaml
# This configuration is outdated and provided only for reference
plex:
  labels:
    - "traefik.enable=true"
    - "traefik.frontend.rule=Host:plex.domain.com"  # OLD SYNTAX
    - "traefik.port=32400"                          # OLD SYNTAX
    - "traefik.docker.network=proxy"
```

## Network Configuration

### Network Mode Options

1. **Host Mode** (Recommended for full functionality):
   ```yaml
   network_mode: host
   ```
   - Enables all discovery protocols
   - Required for DLNA
   - Simplifies remote access

2. **Bridge Mode** (For network isolation):
   ```yaml
   networks:
     - proxy
   ports:
     - "32400:32400/tcp"
     - "1900:1900/udp"
     - "3005:3005/tcp"
     - "5353:5353/udp"
     - "8324:8324/tcp"
     - "32410:32410/udp"
     - "32412:32412/udp"
     - "32413:32413/udp"
     - "32414:32414/udp"
     - "32469:32469/tcp"
   ```

## Initial Setup

1. **Claim Your Server**:
   - Visit https://plex.tv/claim
   - Copy the claim token
   - Add to environment: `PLEX_CLAIM=claim-xxxxxxxxxxxxx`
   - Start the container

2. **First Access**:
   - Local: http://localhost:32400/web
   - Remote: https://plex.yourdomain.com

3. **Library Setup**:
   - Add library folders from `/media`
   - Set up automatic scanning
   - Configure transcoding settings

## Hardware Acceleration

### Intel Quick Sync (QSV)
```yaml
devices:
  - /dev/dri:/dev/dri
```

### NVIDIA GPU
```yaml
runtime: nvidia
environment:
  - NVIDIA_VISIBLE_DEVICES=all
```

## Performance Optimization

### Transcoding
- Use RAM disk: `/dev/shm` for transcoding
- Allocate sufficient RAM (4GB minimum)
- Enable hardware acceleration when available

### Database Optimization
```bash
# Optimize database (run monthly)
docker exec plex sqlite3 /config/Library/Application\ Support/Plex\ Media\ Server/Plug-in\ Support/Databases/com.plexapp.plugins.library.db "VACUUM;"
docker exec plex sqlite3 /config/Library/Application\ Support/Plex\ Media\ Server/Plug-in\ Support/Databases/com.plexapp.plugins.library.db "REINDEX;"
```

### Empty Trash
```bash
# Empty all library trash
./scripts/plex/plex-empty-trash.sh
```

## Backup Considerations

### Critical Paths
- `/config/Library/Application Support/Plex Media Server/Preferences.xml`
- `/config/Library/Application Support/Plex Media Server/Plug-in Support/Databases/`

### Exclude from Backups
- `/config/Library/Application Support/Plex Media Server/Cache/`
- `/config/Library/Application Support/Plex Media Server/Metadata/`
- `/config/Library/Application Support/Plex Media Server/Media/`

## Common Issues

### Cannot Access Outside Network
- Ensure port 32400 is forwarded
- Check "Remote Access" settings in Plex
- Verify Cloudflare proxy settings (disable for Plex subdomain)

### DLNA Not Working
- Must use `network_mode: host`
- Check firewall rules for UDP ports

### Transcoding Failures
- Verify `/dev/shm` has sufficient space
- Check permissions on transcode directory
- Monitor CPU/GPU usage during transcoding

## Integration with Other Services

### Tautulli (Statistics)
- Monitor Plex activity
- Generate usage reports
- Send notifications

### Overseerr/Petio (Requests)
- User request management
- Automatic Sonarr/Radarr integration

### Sonarr/Radarr
- Automatic media management
- Quality upgrades
- Metadata management

## Migration from PTS/MHA

Key changes from legacy setup:

1. **Traefik Labels**: Complete syntax change
   - Old: `traefik.frontend.rule`
   - New: `traefik.http.routers.plex.rule`

2. **SSL Certificates**: 
   - Old: Let's Encrypt HTTP challenge
   - New: Cloudflare DNS challenge

3. **Authentication**:
   - Old: Plex authentication only
   - New: Optional Authelia SSO integration

4. **Health Checks**: Now included by default

5. **Container Updates**: 
   - Old: Watchtower
   - New: dockupdater

## Additional Scripts

Located in `/scripts/plex/`:
- `plex-empty-trash.sh`: Empty all library trash
- `plex-optimize-db.sh`: Optimize Plex database
- `plex-backup.sh`: Backup Plex configuration

## Resources

- [Official Plex Documentation](https://support.plex.tv/)
- [LinuxServer.io Plex Documentation](https://docs.linuxserver.io/images/docker-plex)
- [HomelabARR Traefik Guide](../../traefik/README.md)
- [Original MHA-Team PTS Wiki](https://github.com/MHA-Team/PTS-Team/wiki)

---

*Last Updated: January 2025*  
*Adapted from MHA-Team PTS Wiki for HomelabARR with modern standards*