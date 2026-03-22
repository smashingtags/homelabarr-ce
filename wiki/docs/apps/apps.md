# HomelabARR CE Applications

![Image of HomelabARR CE](/img/container_images/docker-homelabarr-ce.png)

HomelabARR CE supports 100+ self-hosted applications across multiple categories. Applications can be deployed in two modes:

## Deployment Modes

### 🌐 Full Mode (Default)
- Deploy through HomelabARR CE interface: `sudo homelabarr -i`
- Traefik reverse proxy with automatic SSL
- Authelia multi-factor authentication
- Domain-based access (e.g., `https://plex.yourdomain.com`)
- Complete integration with all HomelabARR CE features

### 🏠 Local Mode (New)
- Direct container deployment with IP:PORT access
- No domain or Cloudflare configuration required
- Perfect for local networks and testing
- Available templates: **Plex**, **Radarr**, **qBittorrent**
- **[Local Mode Guide](../install/local-mode.md)**

---

## Application Categories

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

### Media Servers
| Application | Full Mode | Local Mode | Description |
|-------------|-----------|------------|-------------|
| **Plex** | ✅ | ✅ | Premium media server with transcoding |
| **Jellyfin** | ✅ | 🔄 | Open-source media server |
| **Emby** | ✅ | ❌ | Feature-rich media server |

### Media Management
| Application | Full Mode | Local Mode | Description |
|-------------|-----------|------------|-------------|
| **Radarr** | ✅ | ✅ | Automated movie downloading |
| **Sonarr** | ✅ | 🔄 | Automated TV show downloading |
| **Lidarr** | ✅ | ❌ | Automated music downloading |
| **Bazarr** | ✅ | ❌ | Subtitle management |
| **Prowlarr** | ✅ | ❌ | Indexer management |

### Download Clients
| Application | Full Mode | Local Mode | Description |
|-------------|-----------|------------|-------------|
| **qBittorrent** | ✅ | ✅ | Feature-rich BitTorrent client |
| **SABnzbd** | ✅ | 🔄 | Usenet downloader |
| **NZBGet** | ✅ | ❌ | Lightweight usenet downloader |
| **Deluge** | ✅ | ❌ | Alternative BitTorrent client |

### Request Management
| Application | Full Mode | Local Mode | Description |
|-------------|-----------|------------|-------------|
| **Overseerr** | ✅ | 🔄 | Media request management |
| **Petio** | ✅ | ❌ | Alternative request manager |

### Monitoring & Management
| Application | Full Mode | Local Mode | Description |
|-------------|-----------|------------|-------------|
| **Tautulli** | ✅ | 🔄 | Plex monitoring and statistics |
| **Netdata** | ✅ | ❌ | System monitoring |
| **Grafana** | ✅ | ❌ | Analytics and monitoring |

**Legend:** ✅ Available | 🔄 Coming Soon | ❌ Not Available

---

## Quick Deploy Commands

### Local Mode Examples

```bash
# Deploy Plex Media Server
cd homelabarr-ce/apps/.config
docker compose -f plex-local-template.yml --env-file .env up -d
# Access: http://localhost:32400

# Deploy Radarr Movie Manager
docker compose -f radarr-local-template.yml --env-file .env up -d
# Access: http://localhost:7878

# Deploy qBittorrent Download Client
docker compose -f qbittorrent-local-template.yml --env-file .env up -d
# Access: http://localhost:8082
```

### Full Mode Deployment

```bash
# Install HomelabARR CE
sudo wget -qO- https://git.io/J3GDc | sudo bash

# Launch interface
sudo homelabarr -i
```

---

## Support

Kindly report any issues/broken-parts/bugs on [github](https://github.com/smashingtags/homelabarr-ce/issues) or [discord](https://discord.gg/Pc7mXX786x)

- Join our <a href="https://discord.gg/Pc7mXX786x">
  <img src="https://discord.com/api/guilds/1334411584927301682/widget.png?label=Discord%20Server&logo=discord" alt="Join HomelabARR CE on Discord">
  </a> for Support

**☕ [Support Development](https://ko-fi.com/homelabarr)** - Love our 100+ app collection? Help us add more and keep improving the platform!
