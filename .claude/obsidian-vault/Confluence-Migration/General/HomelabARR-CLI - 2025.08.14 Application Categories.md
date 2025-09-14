---
title: "HomelabARR-CLI : 2025.08.14 Application Categories"
confluence_id: "3866648"
confluence_url: "https://mjashley.atlassian.net/wiki/spaces/DO/pages/3866648"
confluence_space: "DO"
category: "General"
created_date: ""
updated_date: ""
migrated_date: "2025-09-14"
tags: ['frontend', 'media-server', 'docker', 'traefik', 'golang', 'servarr', 'security', 'authelia', 'monitoring', 'storage']
---

# Application Categories

HomelabARR CLI supports 100+ self-hosted applications organized into logical categories. Each application is containerized and integrated with Traefik for automatic SSL and routing.
## Media Servers

### Primary Media Servers

- **Plex**: Premium media server with transcoding and remote access
- **Jellyfin**: Open-source alternative to Plex with no licensing restrictions
- **Emby**: Feature-rich media server with premium and free tiers
### Media Server Utilities

- **Tautulli**: Analytics and monitoring for Plex
- **Kitana**: Web interface for Plex plugins
- **Plex-Meta-Manager**: Automated metadata and collection management
## Media Management (Servarr Stack)

### Core Automation

- **Sonarr**: TV show management and automation
- **Radarr**: Movie management and automation
- **Lidarr**: Music management and automation
- **Readarr**: Book and audiobook management
- **Bazarr**: Subtitle management for movies and TV shows
### Specialized Variants

- **Sonarr4K/Radarr4K**: 4K quality variants
- **SonarrHDR/RadarrHDR**: HDR content variants
- **Prowlarr**: Indexer management for all *arr applications
## Download Clients

### BitTorrent Clients

- **qBittorrent**: Feature-rich web-based BitTorrent client
- **qBittorrentVPN**: qBittorrent with VPN integration
- **Deluge**: Lightweight BitTorrent client
- **Transmission**: Simple and efficient BitTorrent client
### Usenet Clients

- **SABnzbd**: Popular Usenet binary newsreader
- **NZBGet**: Efficient Usenet downloader
- **NZBHydra2**: Usenet meta search
### VPN Integration

- **Gluetun**: VPN client for Docker containers
- **OpenVPN**: OpenVPN client container
## Request Management

### User Request Systems

- **Overseerr**: Modern request management for Plex users
- **Petio**: Alternative request management system
- **Ombi**: Request platform for shared media libraries
## Dashboards & Monitoring

### System Dashboards

- **Heimdall**: Application dashboard and launcher
- **Homer**: Static application dashboard
- **Dashy**: Modern, customizable dashboard
- **Organizr**: Tabbed dashboard with authentication
- **Flame**: Self-hosted dashboard
### Monitoring Tools

- **Netdata**: Real-time system monitoring
- **Glances**: System monitoring tool
- **Scrutiny**: Hard drive health monitoring
- **Uptime Kuma**: Service uptime monitoring
- **Grafana**: Data visualization and monitoring
## Backup Solutions

### Backup Applications

- **Duplicati**: Cross-platform backup solution
- **Restic**: Fast, secure backup program
- **rsnapshot**: File system snapshot utility
## Utilities & Tools

### File Management

- **FileBrowser**: Web-based file manager
- **Cloud Commander**: Dual-panel file manager
- **Krusader**: Advanced file manager
### Download Tools

- **YouTube-DL Material**: YouTube and media downloader
- **Tubesync**: YouTube channel synchronization
- **aria2**: Download utility
### Development Tools

- **Code Server**: VS Code in the browser
- **Cloud9**: Cloud-based IDE
- **Gitea**: Self-hosted Git service
### Communication

- **Gotify**: Push notification server
- **Discord**: Discord client
- **Telegram**: Telegram client
## Security & Network

### Security Tools

- **Authelia**: Authentication and authorization server
- **Fail2Ban**: Intrusion prevention system
- **Cloudflare DDNS**: Dynamic DNS updater
### Network Tools

- **Traefik**: Reverse proxy and load balancer
- **Cloudflared**: Cloudflare tunnel client
- **WireGuard**: VPN server
## Database & Storage

### Database Systems

- **PostgreSQL**: Advanced relational database
- **MySQL/MariaDB**: Popular database systems
- **Redis**: In-memory data store
### Storage Solutions

- **MinIO**: S3-compatible object storage
- **Nextcloud**: Personal cloud storage
- **Syncthing**: Continuous file synchronization
## Productivity

### Office & Documents

- **OnlyOffice**: Office suite
- **Bookstack**: Wiki platform
- **TiddlyWiki**: Non-linear documentation
### Note Taking

- **Joplin**: Note-taking application
- **Standard Notes**: Simple and private notes
## Entertainment

### Gaming

- **Minecraft**: Minecraft server
- **Pterodactyl**: Game server management panel
### Media Processing

- **Handbrake**: Video transcoding
- **MakeMKV**: DVD/Blu-ray ripping
- **FFmpeg**: Media processing
## Installation Instructions

Each application category can be installed individually:
```
# Install all applications
sudo ./apps/install.sh

# Install specific category
sudo ./apps/install.sh --category mediaserver
sudo ./apps/install.sh --category downloadclients
sudo ./apps/install.sh --category monitoring
```