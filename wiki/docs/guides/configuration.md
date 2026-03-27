# Configuration

HomelabARR CE is configured through environment variables, either set directly or in a `.env` file alongside your compose file.

---

## Required Variables

These must be set for a working deployment:

| Variable | Example | Description |
|----------|---------|-------------|
| `JWT_SECRET` | `$(openssl rand -hex 32)` | Secret key for JWT token signing. **Must be unique.** |
| `DOCKER_GID` | `999` | Your host's Docker group ID. Find it: `getent group docker \| cut -d: -f3` |

---

## Common Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `CORS_ORIGIN` | `https://your-domain.com` | URL you use to access the dashboard. Must match exactly. |
| `FRONTEND_PORT` | `8084` | Host port for the web dashboard |
| `BACKEND_PORT` | `8092` | Host port for the API server |
| `AUTH_ENABLED` | `true` | Enable/disable authentication |
| `JWT_EXPIRES_IN` | `24h` | JWT token expiration time |
| `DEFAULT_ADMIN_PASSWORD` | `admin` | Initial admin password (change after first login) |
| `CLI_BRIDGE_HOST_PATH` | `/opt/homelabarr` | Path to HomelabARR repo on host (for CLI Bridge) |

---

## App Deployment Variables

These are injected into every app template at deploy time:

| Variable | Default | Description |
|----------|---------|-------------|
| `ID` | `1000` | UID/GID for container processes |
| `TZ` | `UTC` | Timezone (e.g., `America/New_York`) |
| `UMASK` | `002` | File permission mask |
| `RESTARTAPP` | `unless-stopped` | Container restart policy |
| `DOCKERNETWORK` | `proxy` or `bridge` | Network based on deployment mode |
| `DOMAIN` | `localhost` | Base domain for Traefik routing |
| `APPFOLDER` | `/opt/appdata` | Root path for persistent app data |
| `SECURITYOPS` | `no-new-privileges` | Docker security option |

---

## Using a .env File

Create a `.env` file next to your `homelabarr.yml`:

```bash
# Required
JWT_SECRET=your-very-long-random-secret-here
DOCKER_GID=999

# Recommended
CORS_ORIGIN=http://192.168.1.100:8084
TZ=America/New_York

# Optional
FRONTEND_PORT=8084
BACKEND_PORT=8092
CLI_BRIDGE_HOST_PATH=/opt/homelabarr
```

Then start with:

```bash
docker compose -f homelabarr.yml --env-file .env up -d
```

---

## Docker Socket Access

The backend container needs access to Docker to manage containers. The default `homelabarr.yml` mounts `/var/run/docker.sock`.

!!! warning "Security note"
    Docker socket access gives the backend full control over Docker on your host. In production, consider using a Docker socket proxy like [Tecnativa/docker-socket-proxy](https://github.com/Tecnativa/docker-socket-proxy) to limit API access.

If the Docker socket is unavailable, the backend starts in degraded mode — the app catalog still works, but container management and deployments are disabled.

---

## Data Persistence

Application data is stored in the `homelabarr-data` Docker volume by default. App configurations (JWT keys, user database) persist across container restarts.

Deployed apps store their data under `${APPFOLDER}` (default: `/opt/appdata/`):

```
/opt/appdata/
├── plex/          # Plex configuration
├── radarr/        # Radarr configuration
├── sonarr/        # Sonarr configuration
├── qbittorrent/   # Download client data
└── ...
```

---

## Network Configuration

### Standard Mode

Containers use Docker's default bridge network with direct port mappings.

### Traefik Mode

Containers join the `proxy` network. Ensure it exists:

```bash
docker network create proxy
```

See [Traefik & Domain Setup](traefik-setup.md) for full reverse proxy configuration.

---

[homelabarr.com](https://homelabarr.com) · [Imogen Labs](https://imogenlabs.ai) · [Michael Ashley](https://mjashley.com)
