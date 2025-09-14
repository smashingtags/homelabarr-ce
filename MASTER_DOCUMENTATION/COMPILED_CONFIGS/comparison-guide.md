# HomelabARR CLI Local vs Proxy Mode Comparison Guide

This guide demonstrates the practical differences between Local Mode and Proxy Mode configurations for HomelabARR CLI applications.

## Overview

### Proxy Mode (Default)
- **Access Method**: HTTPS via domain names (e.g., `https://plex.yourdomain.com`)
- **Authentication**: Centralized via Authelia
- **SSL**: Automatic via Let's Encrypt and Cloudflare
- **Dependencies**: Requires Traefik, Authelia, domain ownership, Cloudflare
- **Network**: External `proxy` network for service communication

### Local Mode
- **Access Method**: HTTP via IP:PORT (e.g., `http://192.168.1.100:32400`)
- **Authentication**: Individual service authentication
- **SSL**: None (unless manually configured)
- **Dependencies**: Only Docker and Docker Compose
- **Network**: Default `bridge` network for direct access

## Key Configuration Differences

### 1. Network Configuration

**Proxy Mode:**
```yaml
networks:
  - proxy

networks:
  proxy:
    driver: bridge
    external: true
```

**Local Mode:**
```yaml
networks:
  - bridge

networks:
  bridge:
    driver: bridge
```

### 2. Port Exposure

**Proxy Mode:**
```yaml
ports:
  - "32400:32400"  # Only for container-to-container communication
```

**Local Mode:**
```yaml
ports:
  - "32400:32400/tcp"    # Main web interface
  - "3005:3005/tcp"      # Additional Plex ports
  - "8324:8324/tcp"      # All necessary ports exposed
  - "32469:32469/tcp"
  - "1900:1900/udp"
  - "32410:32410/udp"
  - "32412:32412/udp"
  - "32413:32413/udp"
  - "32414:32414/udp"
```

### 3. Traefik Labels

**Proxy Mode:**
```yaml
labels:
  - "traefik.enable=true"
  - "traefik.docker.network=proxy"
  - "traefik.http.routers.plex-rtr.entrypoints=https"
  - "traefik.http.routers.plex-rtr.rule=Host(`plex.${DOMAIN}`)"
  - "traefik.http.routers.plex-rtr.tls=true"
  - "traefik.http.routers.plex-rtr.tls.certresolver=dns-cloudflare"
  - "traefik.http.routers.plex-rtr.middlewares=chain-authelia@file"
  - "traefik.http.routers.plex-rtr.service=plex-svc"
  - "traefik.http.services.plex-svc.loadbalancer.server.port=32400"
```

**Local Mode:**
```yaml
labels:
  - "dockupdater.enable=true"  # Only maintenance labels
```

### 4. Environment Variables

**Proxy Mode:**
```yaml
environment:
  - "ADVERTISE_IP=http://plex.${DOMAIN}:443"
```

**Local Mode:**
```yaml
environment:
  - "ADVERTISE_IP=http://192.168.1.100:32400"
```

## Service Examples by Category

### Media Servers

| Service | Local Mode Port | Proxy Mode URL | Notes |
|---------|----------------|----------------|-------|
| Plex | `192.168.1.100:32400` | `https://plex.domain.com` | Full port range required for local |
| Jellyfin | `192.168.1.100:8096` | `https://jellyfin.domain.com` | Single port sufficient |
| Emby | `192.168.1.100:8920` | `https://emby.domain.com` | Similar to Jellyfin |

### Download Clients

| Service | Local Mode Port | Proxy Mode URL | Notes |
|---------|----------------|----------------|-------|
| qBittorrent | `192.168.1.100:8080` | `https://qbittorrent.domain.com` | Requires torrent ports 6881 |
| SABnzbd | `192.168.1.100:8081` | `https://sabnzbd.domain.com` | Single web port |
| NZBGet | `192.168.1.100:8082` | `https://nzbget.domain.com` | Single web port |

### Media Management

| Service | Local Mode Port | Proxy Mode URL | Notes |
|---------|----------------|----------------|-------|
| Radarr | `192.168.1.100:7878` | `https://radarr.domain.com` | API access important |
| Sonarr | `192.168.1.100:8989` | `https://sonarr.domain.com` | API access important |
| Prowlarr | `192.168.1.100:9696` | `https://prowlarr.domain.com` | Indexer management |

## Port Assignment Strategy

### Local Mode Port Ranges
- **Media Servers**: 8300-8399
- **Download Clients**: 8080-8199  
- **Media Management**: 6000-6999, 7000-7999
- **Request Apps**: 5000-5099
- **Addons**: 8200-8299, 19000-19999
- **Self-hosted**: 8400-8499
- **Backup**: 8500-8599
- **System**: 8600-8699

### Conflict Resolution
```bash
# Check for port conflicts
./port-manager.sh check

# Automatically resolve conflicts
./port-manager.sh resolve

# Manually assign specific port
./port-manager.sh assign plex 32400
```

## Access Information Examples

### Local Mode Access
```
HomelabARR CLI Services - Local Mode Access
Server IP: 192.168.1.100

Media Servers:
- Plex: http://192.168.1.100:32400/web
- Jellyfin: http://192.168.1.100:8096

Download Clients:
- qBittorrent: http://192.168.1.100:8080
- SABnzbd: http://192.168.1.100:8081

Media Management:
- Radarr: http://192.168.1.100:7878
- Sonarr: http://192.168.1.100:8989
- Prowlarr: http://192.168.1.100:9696
```

### Proxy Mode Access
```
HomelabARR CLI Services - Proxy Mode Access
Domain: yourdomain.com

Media Servers:
- Plex: https://plex.yourdomain.com
- Jellyfin: https://jellyfin.yourdomain.com

Download Clients:
- qBittorrent: https://qbittorrent.yourdomain.com
- SABnzbd: https://sabnzbd.yourdomain.com

Media Management:
- Radarr: https://radarr.yourdomain.com
- Sonarr: https://sonarr.yourdomain.com
- Prowlarr: https://prowlarr.yourdomain.com
```

## Migration Examples

### Converting from Proxy to Local Mode

1. **Stop Services**:
```bash
./mode-switch.sh switch local
```

2. **Automatic Changes**:
   - Traefik labels removed
   - Port mappings added
   - Network changed to bridge
   - Environment variables updated

3. **Manual Steps**:
   - Update client applications to use IP:PORT
   - Configure firewall rules if needed
   - Update bookmarks and integrations

### Converting from Local to Proxy Mode

1. **Prerequisites**:
   - Traefik must be running
   - Domain configured in DNS
   - Cloudflare credentials set

2. **Switch Mode**:
```bash
./mode-switch.sh switch proxy
```

3. **Automatic Changes**:
   - Traefik labels added
   - External ports removed
   - Network changed to proxy
   - Environment variables updated

## Troubleshooting

### Common Local Mode Issues

1. **Port Conflicts**:
```bash
# Check what's using a port
netstat -tuln | grep :8080
ss -tuln | grep :8080

# Resolve automatically
./port-manager.sh resolve
```

2. **Service Not Accessible**:
- Check if port is exposed: `docker ps`
- Verify firewall settings
- Confirm service is running: `docker logs servicename`

3. **Mobile App Connection**:
- Use server IP address in app settings
- Ensure port is accessible from mobile network
- Check NAT/router configuration

### Common Proxy Mode Issues

1. **Domain Not Resolving**:
- Verify DNS configuration
- Check Cloudflare settings
- Confirm Traefik is running

2. **SSL Certificate Issues**:
- Check Cloudflare API credentials
- Verify domain ownership
- Review Traefik logs: `docker logs traefik`

3. **Authelia Authentication**:
- Check Authelia configuration
- Verify user database
- Review Authelia logs: `docker logs authelia`

## Performance Considerations

### Local Mode Advantages
- **Lower Latency**: Direct connection eliminates proxy overhead
- **Faster Startup**: No dependency on external services
- **Simpler Debugging**: Direct logs and access
- **Resource Efficiency**: No reverse proxy overhead

### Proxy Mode Advantages
- **Security**: Centralized authentication and SSL
- **Management**: Single point of access configuration
- **Scalability**: Better for multiple users
- **Professional**: Clean URLs and certificates

## Best Practices

### Local Mode
- Use strong individual service passwords
- Consider VPN for remote access
- Monitor port usage to avoid conflicts
- Keep service documentation for port references

### Proxy Mode  
- Regular SSL certificate monitoring
- Backup Traefik and Authelia configurations
- Monitor domain expiration
- Test authentication flows regularly

### Both Modes
- Regular configuration backups
- Monitor service health
- Keep environment variables secure
- Document custom configurations
