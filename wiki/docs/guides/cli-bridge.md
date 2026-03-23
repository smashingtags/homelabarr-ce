# CLI Bridge Architecture

The CLI Bridge is the layer that connects the HomelabARR CE web dashboard to the library of Docker Compose templates. Understanding it helps when troubleshooting deployments or adding custom applications.

## What the CLI Bridge Does

The backend server starts a `CLIBridge` instance on boot. It:

1. Reads YAML templates from the `apps/` directory
2. Parses each template into a structured catalog (name, ports, env vars, volumes, labels)
3. Serves the catalog to the web frontend via the `/applications` API
4. At deploy time, loads the chosen template, injects user config, and runs `docker compose up -d`

If the CLI Bridge fails to initialize (missing `apps/` directory), the server falls back to a basic template mode with limited functionality.

## The `CLI_BRIDGE_HOST_PATH` Variable

The bridge needs to know where the HomelabARR repository lives on disk.

| Variable | Default | Purpose |
|----------|---------|---------|
| `CLI_BRIDGE_HOST_PATH` | Current working directory | Path to the root of the HomelabARR CLI repo |

In Docker deployments, mount the CLI repo and set this variable:

```yaml
volumes:
  - /opt/homelabarr:/opt/homelabarr
environment:
  - CLI_BRIDGE_HOST_PATH=/opt/homelabarr
```

## Directory Structure

```
/opt/homelabarr/
  apps/
    addons/
      organizr.yml
      heimdall.yml
    ai-tools/
      ollama.yml
    backup/
      duplicati.yml
    coding/
      code-server.yml
    downloadclients/
      qbittorrent.yml
      sabnzbd.yml
      deluge.yml
      nzbget.yml
    encoder/
      tdarr.yml
    kasmworkspace/
      kasm.yml
    mediamanager/
      radarr.yml
      sonarr.yml
      prowlarr.yml
      bazarr.yml
      lidarr.yml
      readarr.yml
    mediaserver/
      plex.yml
      jellyfin.yml
      emby.yml
    monitoring/
      tautulli.yml
    myapps/
      # Your custom application templates
    request/
      overseerr.yml
    selfhosted/
      ...
    share/
      ...
    system/
      portainer.yml
      pihole.yml
  traefik/
    docker-compose.yml
    install.sh
  scripts/
    ...
```

Only these category directories are scanned: `addons`, `ai-tools`, `backup`, `coding`, `downloadclients`, `encoder`, `kasmworkspace`, `mediamanager`, `mediaserver`, `monitoring`, `myapps`, `request`, `selfhosted`, `share`, `system`. Other directories are ignored to prevent duplicates.

## Template Format

Each YAML file is a standard Docker Compose file. The CLI Bridge parses the first service definition to extract metadata. Here is an annotated example:

```yaml
version: "3"
services:
  radarr:
    image: ${RADARRIMAGE}
    container_name: radarr
    restart: ${RESTARTAPP}
    networks:
      - ${DOCKERNETWORK}
    security_opt:
      - ${SECURITYOPS}:${SECURITYOPSSET}
    ports:
      - 7878:7878
    environment:
      - PUID=${ID}
      - PGID=${ID}
      - TZ=${TZ}
      - UMASK=${UMASK}
      - DOCKER_MODS=ghcr.io/themepark-dev/theme.park:radarr
      - TP_THEME=${RADARRTHEME}
    volumes:
      - ${APPFOLDER}/radarr:/config
      - /mnt/unionfs:/mnt/unionfs
    labels:
      - traefik.enable=true
      - traefik.http.routers.radarr.rule=Host(`radarr.${DOMAIN}`)
      - traefik.http.routers.radarr.tls=true
      - traefik.http.routers.radarr.tls.certresolver=letsencrypt
      - traefik.http.services.radarr.loadbalancer.server.port=7878
      - dockupdater.enable=true

networks:
  proxy:
    external: true
```

The bridge extracts:

- **id**: `mediamanager-radarr` (category + filename)
- **image**: value of `image` field
- **ports**: parsed from the `ports` array
- **environment**: parsed from the `environment` array
- **volumes**: the `volumes` array
- **labels**: the `labels` array
- **requiresTraefik**: `true` if any label contains `traefik.enable=true`
- **requiresAuthelia**: `true` if any label references `authelia` or `chain-authelia`

## How Deployment Works

```
User clicks Deploy
       |
       v
POST /deploy { appId, config, mode }
       |
       v
Backend loads YAML template from apps/<category>/<app>.yml
       |
       v
Applies deployment mode transformations
       |
       v
Injects environment variables (user config + defaults)
       |
       v
Writes temporary compose file (for local mode)
       |
       v
Runs: docker compose -f <file> up -d
       |
       v
Streams stdout/stderr to client via SSE
       |
       v
Returns deployment result
```

## Deployment Modes in Detail

### Standard / Local Mode

The bridge rewrites the compose file before deploying:

1. **Removes external networks** -- deletes any `networks` block with `external: true`
2. **Strips Traefik labels** -- removes all labels containing `traefik` or `dockupdater`
3. **Removes security_opt** -- strips security options that may reference unavailable configs
4. **Sets `DOCKERNETWORK=bridge`** -- uses the default Docker bridge network

The rewritten file is saved as `<app>-local.yml`, deployed, then deleted.

### Traefik Mode

Deploys the original template as-is with:

- `DOCKERNETWORK=proxy` -- connects the container to the Traefik proxy network
- Ensures Traefik is running (starts it if not)
- Traefik labels in the template handle routing, SSL, and domain configuration

### Authelia Mode

Same as Traefik mode, plus:

- Ensures Authelia is running alongside Traefik
- Templates with `chain-authelia` labels get automatic SSO/MFA protection

## Environment Variables

The bridge injects these defaults before every deployment. User-provided values override them.

| Variable | Default | Purpose |
|----------|---------|---------|
| `ID` | `1000` | UID/GID for container processes |
| `TZ` | `UTC` | Timezone |
| `UMASK` | `002` | File permission mask |
| `RESTARTAPP` | `unless-stopped` | Container restart policy |
| `DOCKERNETWORK` | `proxy` or `bridge` | Network based on deployment mode |
| `DOMAIN` | `localhost` | Base domain for Traefik routing |
| `APPFOLDER` | `/opt/appdata` | Root path for persistent app data |
| `SECURITYOPS` | `no-new-privileges` | Docker security option |
| `PORTBLOCK` | (empty) | Optional port restriction |

Image variables like `PLEXIMAGE`, `RADARRIMAGE`, etc. default to the latest LinuxServer.io images. Theme variables like `RADARRTHEME` default to `dark`.

## Adding Custom Templates

The `myapps/` directory is specifically for your custom application templates. Drop a YAML file in there and it shows up in the dashboard under **My Apps**.

1. Create a YAML file in the `myapps/` directory:
   ```
   apps/myapps/my-app.yml
   ```

2. Follow the standard Docker Compose format with at least one service defined under `services:`.

3. Use the environment variable placeholders (`${APPFOLDER}`, `${TZ}`, `${ID}`, etc.) so the bridge can inject user configuration.

4. Add Traefik labels if you want reverse proxy support. Without them, the app will only work in Local mode.

5. Restart the server or click the refresh button in the dashboard. The new app appears automatically in the catalog.

!!! tip "Test in Local mode first"
    Deploy your custom template in Local/Standard mode before adding Traefik labels. This confirms the container runs correctly before introducing proxy complexity.

!!! warning "Category must be in the allow-list"
    The bridge only scans 15 known category directories. If you create a new category folder, it will be ignored. Place custom apps in `myapps/` — that's what it's there for.
