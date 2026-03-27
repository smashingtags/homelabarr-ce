<p align="center">
  <img src="img/homelabarr-octopus-v2b.jpg" alt="HomelabARR" width="600">
</p>

# HomelabARR CE

**Free, open-source Docker container management for homelabs.**

HomelabARR CE gives you a web dashboard to browse, deploy, and manage 100+ self-hosted applications — media servers, download clients, AI tools, monitoring, and more. One Docker Compose command to install. No subscription, no lock-in.

![Dashboard](img/screenshots/dark-dashboard.png)

## Quick Start

```bash
# 1. Clone the repo
git clone https://github.com/smashingtags/homelabarr-ce.git /opt/homelabarr
cd /opt/homelabarr

# 2. Set required variables
export JWT_SECRET=$(openssl rand -hex 32)
export DOCKER_GID=$(getent group docker | cut -d: -f3)
export CORS_ORIGIN=http://your-server-ip:8084

# 3. Start HomelabARR
docker compose -f homelabarr.yml up -d
```

Open **http://your-server:8084** and log in with `admin` / `admin`.

→ [Full Quick Start Guide](guides/quick-start.md)

## What You Get

- **100+ app templates** across 10 categories — ready to deploy in one click
- **Three deployment modes** — Local (direct ports), Traefik (reverse proxy + SSL), Traefik + Authelia (SSO/MFA)
- **Real-time deployment** — watch container pulls and startup via Server-Sent Events
- **Container management** — start, stop, restart, remove, and view logs from the dashboard
- **Port Manager** — see what ports are in use, find available ones
- **Dark mode** — automatic or manual toggle
- **API key authentication** — generate `hlr_` prefixed keys for programmatic access
- **Mobile-responsive** — works on phones and tablets

## App Categories

| Category | Examples |
|----------|----------|
| **Media & Entertainment** | Plex, Jellyfin, Emby, Mstream |
| **Downloads & Automation** | qBittorrent, SABnzbd, NZBGet, Prowlarr, Jackett |
| **Media Management** | Radarr, Sonarr, Lidarr, Bazarr, Readarr, Tautulli |
| **Monitoring & Analytics** | Netdata, Grafana/Prometheus, Speedtest, Notifiarr |
| **Virtual Desktops** | Chrome, Firefox, Discord, Steam, Signal (via Kasm) |
| **Backup & Storage** | Duplicati, Restic, Rsnapshot |
| **System & Utilities** | Portainer, Dozzle, Uptime Kuma, Watchtower, Gluetun |
| **Self-hosted** | Nextcloud, Bitwarden, Pi-hole, Home Assistant, n8n |
| **AI & Machine Learning** | Ollama, Open WebUI, ComfyUI, Stable Diffusion, LocalAI |
| **My Apps** | Your own custom Docker Compose templates |

## Requirements

| Component | Minimum |
|-----------|---------|
| OS | Ubuntu 22.04+ / Debian 12+ / any Docker-capable Linux |
| CPU | 2 cores |
| RAM | 4 GB |
| Disk | 20 GB |
| Docker | 24.0+ with Compose v2 |

!!! success "Multi-architecture support"
    HomelabARR CE images are built for both **x86_64 (amd64)** and **ARM64 (aarch64)** — runs on Raspberry Pi 4/5, Apple Silicon, AWS Graviton, and standard x86 servers.

## Links

- [GitHub](https://github.com/smashingtags/homelabarr-ce)
- [Discord](https://discord.gg/Pc7mXX786x)
- [Demo](https://ce-demo.homelabarr.com) (login: admin/admin)
- [Professional Edition](pe/overview.md)
