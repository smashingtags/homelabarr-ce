# CLI Command Reference

HomelabARR CE provides two interfaces for deploying containers: the **CLI** (`homelabarr-cli.sh`) and the **Web GUI**. Both use the same YAML templates and environment config.

## Running the CLI

```bash
cd homelabarr-ce
./homelabarr-cli.sh
```

This opens an interactive menu with categorized app lists. Select a category, then pick an app to deploy.

!!! note
    The CLI must be run from the repo root directory so it can find the `apps/` templates and `.env` config.

## Menu Categories

The CLI organizes 179+ apps into categories:

| Category | Examples |
|----------|----------|
| Media Servers | Plex, Jellyfin, Emby |
| Download Clients | qBittorrent, SABnzbd, Deluge, NZBGet, ruTorrent |
| Media Managers | Sonarr, Radarr, Lidarr, Bazarr, Prowlarr, Readarr |
| Addons | Overseerr, Heimdall, Dashy, Portainer, Dozzle, Notifiarr |
| Monitoring | Netdata, Tautulli, Uptime Kuma |
| Encoding | Tdarr, Handbrake, Unmanic |
| Backup | Duplicati, Restic, rsnapshot |
| Coding | Code-Server, Cloud9, Coder |
| Kasm Workspace | Chrome, Firefox, Discord, Steam, VLC |
| System | Mount Enhanced, Cloudflare DDNS |

## How Deployment Works

When you select an app, the CLI:

1. Reads the YAML template from `apps/<category>/<app>.yml`
2. Substitutes environment variables from `apps/.config/.env` (or `.env` in the repo root for Full Mode)
3. Deploys the container via `docker compose`

### Template Structure

Each app template is a standard Docker Compose YAML with variable substitution:

```yaml
services:
  sonarr:
    container_name: "sonarr"
    image: "lscr.io/linuxserver/sonarr:latest"
    environment:
      - "PGID=${ID}"
      - "PUID=${ID}"
      - "TZ=${TZ}"
    volumes:
      - "${APPFOLDER}/sonarr:/config:rw"
      - "unionfs:/mnt"
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.sonarr-rtr.rule=Host(`sonarr.${DOMAIN}`)"
      # ... more Traefik labels
```

## Environment Variables

The CLI uses these variables from your `.env` file:

| Variable | Default | Purpose |
|----------|---------|---------|
| `APPFOLDER` | `/opt/appdata` | Where container configs are stored |
| `DOMAIN` | — | Your domain (Full Mode only) |
| `TZ` | `America/New_York` | Timezone |
| `ID` | `1000` | UID/GID for file permissions |
| `UMASK` | `002` | File creation mask |
| `DOCKERNETWORK` | `proxy` | Docker network name |
| `RESTARTAPP` | `unless-stopped` | Container restart policy |
| `SECURITYOPS` | `no-new-privileges` | Security option |
| `CLOUDFLARE_EMAIL` | — | Cloudflare email (Full Mode) |
| `CLOUDFLARE_API_KEY` | — | Cloudflare API key (Full Mode) |

Copy `apps/.config/.env.example` to `apps/.config/.env` and edit for your setup.

## install.sh Menu

The top-level `install.sh` provides two options:

| Option | What It Does |
|--------|-------------|
| **1** | Installs Traefik + Authelia + cf-companion (Full Mode infrastructure) |
| **2** | Opens the application deployment menu (same as `homelabarr-cli.sh`) |

!!! tip
    If you just want Local Mode (direct port access, no domain needed), skip Option 1 and go straight to Option 2. Or use the web GUI.

## Local Mode vs Full Mode

| Feature | Local Mode | Full Mode |
|---------|-----------|-----------|
| Access method | `http://server-ip:port` | `https://app.yourdomain.com` |
| SSL | No | Yes (Let's Encrypt via Traefik) |
| Authentication | Per-app | Authelia SSO |
| Cloudflare | Not needed | Required |
| Templates used | `*-local-template.yml` | Standard `*.yml` |

## Web GUI

The web GUI provides the same deployment functionality with a visual interface. It reads the same YAML templates and environment config. See the [Quick Start Guide](../guides/quick-start.md) for setup.

## Support

Kindly report any issues/broken-parts/bugs on [github](https://github.com/smashingtags/homelabarr-ce/issues) or [discord](https://discord.gg/Pc7mXX786x)

- Join our [![Discord: https://discord.gg/Pc7mXX786x](https://img.shields.io/badge/Discord-gray.svg?style=for-the-badge)](https://discord.gg/Pc7mXX786x) for Support
