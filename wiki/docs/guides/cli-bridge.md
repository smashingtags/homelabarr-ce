# CLI Bridge

The CLI Bridge connects the web dashboard to the Docker Compose template library. It reads YAML templates from the `apps/` directory and serves them as a browsable, deployable catalog.

---

## How It Works

On startup, the backend:

1. Scans the `apps/` directory for YAML templates
2. Parses each template (image, ports, environment variables, volumes, labels)
3. Serves the catalog via the `/applications` API
4. At deploy time: loads the template, applies user config, runs `docker compose up -d`

---

## Directory Structure

```
apps/
├── ai/                    # AI & Machine Learning (Ollama, ComfyUI, etc.)
├── backup/                # Backup & Storage (Duplicati, Restic, Rsnapshot)
├── downloads/             # Downloads & Automation (qBittorrent, SABnzbd, etc.)
├── legacy/                # Deprecated apps (not shown in dashboard)
├── media-management/      # Media Management (Radarr, Sonarr, etc.)
├── media-servers/         # Media Servers (Plex, Jellyfin, Emby)
├── monitoring/            # Monitoring & Analytics (Netdata, Grafana, etc.)
├── myapps/                # Your custom templates
├── self-hosted/           # Self-hosted apps (Nextcloud, Bitwarden, etc.)
├── system/                # System & Utilities (Portainer, Dozzle, etc.)
├── transcoding/           # Transcoding (Tdarr, Handbrake, etc.)
└── virtual-desktops/      # Virtual Desktops (Kasm-powered browsers, apps)
```

Only these directories are scanned. The `legacy/` directory is excluded from the catalog. Other directories are ignored.

---

## Template Format

Each YAML file is a standard Docker Compose file. The CLI Bridge parses the first service to extract metadata:

```yaml
version: "3"
services:
  radarr:
    image: ${RADARRIMAGE}
    container_name: radarr
    restart: ${RESTARTAPP}
    networks:
      - ${DOCKERNETWORK}
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

The bridge extracts:

- **id**: `media-management-radarr` (category + filename)
- **image**: value of the `image` field
- **ports**: from the `ports` array
- **requiresTraefik**: `true` if labels contain `traefik.enable=true`
- **requiresAuthelia**: `true` if labels reference `authelia` or `chain-authelia`

---

## Deployment Modes

### Standard / Local Mode

The bridge rewrites the template before deploying:

1. Removes external networks
2. Strips Traefik labels
3. Removes security_opt referencing unavailable configs
4. Sets `DOCKERNETWORK=bridge`

The rewritten file is saved temporarily, deployed, then deleted.

### Traefik Mode

Deploys the template as-is with `DOCKERNETWORK=proxy`. Traefik labels handle routing and SSL.

### Authelia Mode

Same as Traefik, plus ensures Authelia middleware is active. Templates with `chain-authelia` labels get automatic SSO protection.

---

## Adding Custom Templates

Drop a YAML file in `apps/myapps/` and it appears in the **My Apps** category:

1. Create `apps/myapps/my-app.yml`
2. Follow standard Docker Compose format
3. Use placeholder variables (`${APPFOLDER}`, `${TZ}`, `${ID}`, etc.)
4. Add Traefik labels if you want reverse proxy support
5. Restart the server or refresh the dashboard

!!! tip "Test in Standard mode first"
    Deploy your template in Standard mode before adding Traefik labels. Confirm the container runs correctly before introducing proxy complexity.

---

## CLI Bridge Host Path

In Docker deployments, the bridge needs to know where the HomelabARR repo lives on the host:

```yaml
environment:
  - CLI_BRIDGE_HOST_PATH=/opt/homelabarr
volumes:
  - /opt/homelabarr:/homelabarr:rw
```

This path points to the root of the cloned repository containing the `apps/` directory.

---

[homelabarr.com](https://homelabarr.com) · [Imogen Labs](https://imogenlabs.ai) · [Michael Ashley](https://mjashley.com)
