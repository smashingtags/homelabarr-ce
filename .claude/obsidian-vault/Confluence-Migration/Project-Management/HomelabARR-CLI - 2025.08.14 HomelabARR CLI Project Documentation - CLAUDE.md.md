---
title: "HomelabARR-CLI : 2025.08.14 HomelabARR CLI Project Documentation - CLAUDE.md"
confluence_id: "3932161"
confluence_url: "https://your-instance.atlassian.net/wiki/spaces/DO/pages/3932161"
confluence_space: "DO"
category: "Project-Management"
created_date: "2025-08-18"
updated_date: "2025-08-18"
migrated_date: "2025-09-14"
tags: ['media-server', 'docker', 'traefik', 'golang', 'servarr', 'security', 'authelia', 'monitoring']
---

# CLAUDE.md - Project Instructions

## Project Overview

HomelabARR CLI is a comprehensive Docker-based media server stack with Traefik reverse proxy, Authelia authentication, and Cloudflare protection. It provides automated deployment and management of media server applications like Plex, Radarr, Sonarr, and 100+ other self-hosted applications.
## Architecture

### Core Components

- **Docker Compose Stack**: All applications are containerized using Docker
- **Traefik**: Reverse proxy with automatic SSL certificate management via Let's Encrypt and Cloudflare DNS
- **Authelia**: Authentication and authorization middleware for secure access
- **Cloudflare Integration**: DNS management and DDoS protection
### Directory Structure

- `apps/`: Docker compose files organized by category (mediaserver, downloadclients, addons, etc.)
- `apps/localapps/`:**LOCAL-ONLY**YAML installer versions for use with the new homelabarr-cli (NOT for Traefik/Authelia deployments)
- `traefik/`: Traefik configuration templates and installation scripts
- `scripts/`: Utility scripts for maintenance, backup, and security
- `wiki/`: MkDocs-based documentation site
- `preinstall/`: System preparation and dependency installation
### Application Categories

- `mediaserver/`: Plex, Jellyfin, Emby media servers
- `mediamanager/`: Radarr, Sonarr, Lidarr, Bazarr for media automation
- `downloadclients/`: qBittorrent, SABnzbd, NZBGet, Deluge
- `request/`: Overseerr, Petio for media requests
- `addons/`: Monitoring, dashboards, utilities
- `backup/`: Duplicati, Restic backup solutions
- `selfhosted/`: Various self-hosted applications
- `localapps/`:**Local-only standalone deployments**(no reverse proxy, no authentication layer)
## Common Development Commands

### Installation and Setup

```
# Main installation (Ubuntu/Debian only)
sudo ./install.sh

# Install Traefik stack
sudo ./traefik/install.sh

# Install specific app category
sudo ./apps/install.sh
```