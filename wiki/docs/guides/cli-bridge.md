# CLI Bridge

The CLI Bridge is how the dashboard knows about all those apps. It reads Docker Compose files from the `apps/` folder and turns them into the browsable, deployable catalog you see in the UI.

You don't need to understand this to use HomelabARR — but if you want to add your own apps or know how things work under the hood, keep reading.

---

## How It Works

When the backend starts, it:

1. Scans every subfolder in `apps/` for YAML files
2. Reads each file to figure out the app's name, image, ports, and features
3. Makes them available in the dashboard catalog
4. When you click Deploy, it takes the YAML template, fills in your settings, and runs `docker compose up -d`

---

## App Folder Structure

Here's how apps are organized on disk:

```
apps/
├── ai/                  # Ollama, ComfyUI, Stable Diffusion, etc.
├── backup/              # Duplicati, Restic, Rsnapshot
├── downloads/           # qBittorrent, SABnzbd, NZBGet, Prowlarr
├── media-management/    # Radarr, Sonarr, Lidarr, Bazarr
├── media-servers/       # Plex, Jellyfin, Emby
├── monitoring/          # Netdata, Grafana, Speedtest
├── myapps/              # Your custom templates go here
├── self-hosted/         # Nextcloud, Bitwarden, Pi-hole, n8n
├── system/              # Portainer, Dozzle, Uptime Kuma
├── transcoding/         # Tdarr, Handbrake, MakeMKV
└── virtual-desktops/    # Chrome, Firefox, Steam (Kasm-powered)
```

The folder name = the category in the dashboard. Drop a YAML file in the right folder and it shows up automatically.

---

## Template Format

Each app is a standard Docker Compose file with placeholder variables. Here's what a typical one looks like:

```yaml
version: "3"
services:
  radarr:
    image: lscr.io/linuxserver/radarr:latest
    container_name: radarr
    restart: unless-stopped
    ports:
      - 7878:7878
    environment:
      - PUID=${ID}
      - PGID=${ID}
      - TZ=${TZ}
    volumes:
      - ${APPFOLDER}/radarr:/config
    labels:
      - traefik.enable=true
      - traefik.http.routers.radarr.rule=Host(`radarr.${DOMAIN}`)
      - traefik.http.services.radarr.loadbalancer.server.port=7878
```

The `${VARIABLE}` placeholders get filled in when you deploy — things like your timezone, data folder, and domain name.

### Available Variables

| Variable | Default | What it does |
|----------|---------|-------------|
| `${TZ}` | `UTC` | Timezone |
| `${ID}` | `1000` | User/group ID for file permissions |
| `${APPFOLDER}` | `/opt/appdata` | Where app data gets stored |
| `${DOMAIN}` | `localhost` | Your domain for Traefik routing |
| `${DOCKERNETWORK}` | `bridge` | Docker network (set automatically by deploy mode) |

---

## What Happens During Deployment

Depends on which mode you pick:

**Standard mode:** The bridge strips out Traefik labels and external networks, sets the network to `bridge`, and deploys. The app gets a direct port.

**Traefik mode:** Deploys the template as-is with the `proxy` network. Traefik picks it up via Docker labels and starts routing.

**Traefik + Authelia mode:** Same as Traefik, plus ensures Authelia middleware is active for authentication.

---

## Adding Your Own Apps

1. Create a YAML file in `apps/myapps/` (e.g., `apps/myapps/my-cool-app.yml`)
2. Use the template format above — standard Docker Compose with `${VARIABLE}` placeholders
3. Refresh the dashboard — your app appears in the **My Apps** tab

!!! tip "Test in Standard mode first"
    Get your custom app working in Standard mode before adding Traefik labels. Easier to debug that way.
