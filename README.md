# HomelabARR CE

<p align="center">
    <a href="https://github.com/smashingtags/homelabarr-ce">
      <img src="https://raw.githubusercontent.com/smashingtags/homelabarr-assets/main/homelabber-wiki/homelabarr-header.png" alt="HomelabARR CE" width="600">
    </a>
</p>

<p align="center">
    <a href="https://discord.gg/Pc7mXX786x">
        <img src="https://img.shields.io/discord/1334411584927301682?label=Discord&logo=discord&color=5865F2" alt="Discord">
    </a>
    <a href="https://github.com/smashingtags/homelabarr-ce/releases/latest">
        <img src="https://img.shields.io/github/v/release/smashingtags/homelabarr-ce?label=Release&logo=github" alt="Release">
    </a>
    <a href="https://github.com/smashingtags/homelabarr-ce/blob/main/LICENSE">
        <img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="MIT License">
    </a>
    <a href="https://ko-fi.com/homelabarr">
        <img src="https://img.shields.io/badge/Ko--fi-Support-FF5E5B?logo=kofi&logoColor=white" alt="Ko-fi">
    </a>
</p>

**GUI-driven Docker container management for homelabbers.** Deploy and manage 157 self-hosted apps from a single dashboard — no more copy-pasting Docker Compose files.

---

## What is HomelabARR?

HomelabARR CE is a free, open-source web UI for deploying and managing Docker containers on your homelab. Pick an app from the catalog, click deploy, and it's running. Supports Plex, Sonarr, Radarr, Jellyfin, Home Assistant, Immich, and 100+ more.

Two deployment modes:
- **Docker Compose** (recommended) — pull pre-built images and run
- **Local Mode** — clone the repo and deploy individual app templates via shell scripts

---

## Quick Start

### Option 1: Pre-built Images (fastest)

Pull the official images from GitHub Container Registry — no build step needed.

```bash
# Download the compose file
curl -o docker-compose.yml https://raw.githubusercontent.com/smashingtags/homelabarr-ce/main/homelabarr.yml

# Set required environment
export JWT_SECRET=$(openssl rand -base64 32)
export DOCKER_GID=$(getent group docker | cut -d: -f3)

# Deploy
docker compose up -d
```

The UI is at `http://your-server:8084`. The backend API is at `:8092`.

### Option 2: Build From Source

Clone the repo and build the Docker images yourself. This lets you modify the code, customize templates, or contribute changes.

```bash
git clone https://github.com/smashingtags/homelabarr-ce.git
cd homelabarr-ce
cp .env.example .env    # Edit with your settings

# Build both images locally
docker build -t homelabarr-frontend:local -f Dockerfile .
docker build -t homelabarr-backend:local -f Dockerfile.backend .

# Update homelabarr.yml to use your local images instead of GHCR
# Change image: ghcr.io/smashingtags/homelabarr-frontend:latest → homelabarr-frontend:local
# Change image: ghcr.io/smashingtags/homelabarr-backend:latest  → homelabarr-backend:local

# Deploy
export JWT_SECRET=$(openssl rand -base64 32)
export DOCKER_GID=$(getent group docker | cut -d: -f3)
docker compose -f homelabarr.yml up -d
```

> **Tip:** Building from source takes 2-3 minutes. The pre-built images are identical to what the CI builds from `main`.

---

## Requirements

- Docker + Docker Compose v2
- Linux (Debian/Ubuntu recommended — also works on Proxmox, Unraid, Synology, TrueNAS)
- 2 CPU cores, 4GB RAM, 20GB disk minimum

---

## Features

- **157 app templates across 12 categories** — Plex, Sonarr, Radarr, Jellyfin, qBittorrent, Overseerr, Grafana, and more
- **One-click deployment** — select an app, hit deploy
- **Container management** — start, stop, restart, remove from the UI
- **Health monitoring** — see container status at a glance
- **Template-based** — Docker Compose generation from YAML templates
- **Two modes** — Full Mode (Traefik + domain + SSL) or Local Mode (direct IP:PORT)
- **JWT authentication** — secure your dashboard
- **Dark theme** — easy on the eyes

---

## Architecture

| Component | Tech | Port |
|-----------|------|------|
| Frontend | React 18 + TypeScript + Vite + TailwindCSS | 8084 (nginx) |
| Backend | Express (Node.js) + Dockerode | 8092 |
| Auth | JWT (bcrypt) | — |

The frontend is a static React SPA served by nginx. It proxies `/api` requests to the backend. The backend talks to the Docker socket to manage containers.

---

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `JWT_SECRET` | (required) | Secret for signing auth tokens |
| `DEFAULT_ADMIN_PASSWORD` | `admin` | Initial admin password — **change this** |
| `AUTH_ENABLED` | `true` | Enable/disable authentication |
| `CORS_ORIGIN` | `*` | Allowed CORS origins |
| `DOCKER_GID` | `999` | Your host's docker group ID |
| `FRONTEND_PORT` | `8084` | Frontend port mapping |
| `BACKEND_PORT` | `8092` | Backend port mapping |
| `LOG_LEVEL` | `info` | Logging verbosity |
| `TZ` | `America/New_York` | Timezone |

See `.env.example` for the full list.

### Volumes

The backend needs access to the Docker socket:
```yaml
volumes:
  - /var/run/docker.sock:/var/run/docker.sock:rw
```

---

## App Templates

Templates live in `server/templates/`. Each is a YAML file defining a Docker Compose stack.

**Categories:**
- **Media Servers**: Plex, Jellyfin, Emby
- **Media Management**: Radarr, Sonarr, Lidarr, Bazarr, Readarr, Prowlarr
- **Download Clients**: qBittorrent, SABnzbd, NZBGet, Deluge, Transmission
- **Requests**: Overseerr, Petio, Ombi
- **Monitoring**: Grafana, Prometheus, Tautulli, cAdvisor, Portainer, Dozzle
- **Utilities**: Nginx Proxy Manager, Authelia, Watchtower, Filebrowser, Code Server, Stirling PDF
- **Smart Home**: Home Assistant, Zigbee2MQTT, Mosquitto
- **Analytics**: Umami, Plausible, Metabase, Matomo
- **Automation**: n8n, Huginn, Recyclarr
- **VPN/Networking**: Tailscale, Headscale, WireGuard, Caddy, SearXNG
- **Self-hosted**: Nextcloud, Vaultwarden, Gitea, Bookstack, Immich, Ente, Ghost, PrivateBin

### Adding Custom Templates

Create a YAML file in `server/templates/`:

```yaml
name: my-app
description: My custom application
category: utilities
image: myimage:latest
ports:
  - "8080:8080"
volumes:
  - ./data:/app/data
environment:
  - TZ=${TZ}
```

---

## Deployment Modes

### Full Mode (Traefik + Domain)

For external access with SSL and authentication:

```bash
git clone https://github.com/smashingtags/homelabarr-ce.git
cd homelabarr-ce
chmod +x install.sh
sudo ./install.sh
```

Requires a domain name and Cloudflare account. Sets up Traefik reverse proxy, Authelia 2FA, and automatic SSL certificates.

### Local Mode (IP:PORT)

For local network or testing:

```bash
git clone https://github.com/smashingtags/homelabarr-ce.git
cd homelabarr-ce
chmod +x setup-local-mode.sh
./setup-local-mode.sh
```

No domain required. Apps are accessible at `http://your-ip:port`.

---

## CLI Usage

HomelabARR CE includes a powerful CLI for managing apps directly from the terminal. Power users can deploy, manage, and monitor containers without touching the GUI.

### Interactive CLI

```bash
cd homelabarr-ce
chmod +x homelabarr-cli.sh
./homelabarr-cli.sh
```

This launches an interactive menu with:
- Browse and deploy from 157 app templates across 12 categories organized by category
- Deploy apps in Docker Compose or local mode
- Configure environment variables, ports, and volumes per app
- Start/stop/restart/remove containers
- View logs and health status

### CLI App Categories

| Category | Apps | Examples |
|----------|------|---------|
| `addons` | 33 | Autoscan, Cloudflare DDNS, Dozzle, Flaresolverr, Homepage |
| `backup` | 3 | Duplicati, Restic, Borgmatic |
| `downloadclients` | 14 | qBittorrent, SABnzbd, NZBGet, Transmission, Deluge |
| `mediamanager` | 25 | Sonarr, Radarr, Lidarr, Readarr, Prowlarr, Bazarr, Recyclarr |
| `mediaserver` | 7 | Plex, Jellyfin, Emby, Navidrome, Kavita |
| `monitoring` | — | Netdata, Grafana, Prometheus, Uptime Kuma |
| `request` | 2 | Overseerr, Ombi |
| `selfhosted` | 37 | Nextcloud, Vaultwarden, Immich, Bookstack, Ghost, Gitea |

### Deploy an App via CLI

```bash
# List available apps in a category
ls apps/mediaserver/

# Deploy Plex
./homelabarr-cli.sh
# Select: mediaserver → plex → configure → deploy
```

### App Template Structure

Each app is a YAML file in `apps/<category>/<app>.yml`:

```bash
apps/
├── addons/          # Utility containers
├── backup/          # Backup solutions
├── downloadclients/ # Torrent/Usenet clients
├── mediamanager/    # *arr stack
├── mediaserver/     # Plex, Jellyfin, etc.
├── monitoring/      # Dashboards and metrics
├── request/         # Media request tools
└── selfhosted/      # Everything else
```

### Default Login

- **Username:** `admin`
- **Password:** `admin`

Change this immediately after first login, or set `DEFAULT_ADMIN_PASSWORD` environment variable before deployment.

---

## Development

```bash
# Install dependencies
npm install

# Run frontend + backend in dev mode
npm run dev

# Run tests
npm test

# Build frontend
npm run build
```

The dev server runs Vite on `:5173` and the Express backend on `:8092`.

---

## PE Edition

Looking for storage management, system monitoring, and premium features? Check out [HomelabARR Professional Edition](https://homelabarr.com#pricing).

---

## Contributing

See [CONTRIBUTING.md](.github/CONTRIBUTING.md) for guidelines.

## Support

- [Discord](https://discord.gg/Pc7mXX786x)
- [GitHub Issues](https://github.com/smashingtags/homelabarr-ce/issues)
- [Ko-fi](https://ko-fi.com/homelabarr) — support development

## License

[MIT](LICENSE) — free to use, modify, and distribute.

## Links

- **Website**: [homelabarr.com](https://homelabarr.com)
- **Discord**: [discord.gg/Pc7mXX786x](https://discord.gg/Pc7mXX786x)
- **Company**: [imogenlabs.ai](https://imogenlabs.ai)
- **PE Edition**: [homelabarr.com#pricing](https://homelabarr.com#pricing)
