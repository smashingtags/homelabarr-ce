# Configuration

HomelabARR uses environment variables to control how it runs. Set them before starting the containers.

---

## Required Variables

These two are required. Without them, things break:

| Variable | What it does | How to set it |
|----------|-------------|---------------|
| `JWT_SECRET` | Signs your login sessions — keep this private and never commit it to version control | `export JWT_SECRET=$(openssl rand -hex 32)` |
| `DOCKER_GID` | Tells the container which group can talk to Docker | `export DOCKER_GID=$(getent group docker \| cut -d: -f3)` |

---

## Server Settings

Optional, but useful:

| Variable | Default | What it does |
|----------|---------|-------------|
| `CORS_ORIGIN` | — | The URL you use to open the dashboard (e.g., `http://192.168.1.100:8084`). Set this if you get CORS errors after logging in. |
| `FRONTEND_PORT` | `8084` | Port for the web dashboard |
| `BACKEND_PORT` | `8092` | Port for the API server |
| `TZ` | `UTC` | Your timezone (e.g., `America/New_York`, `Europe/London`) |
| `AUTH_ENABLED` | `true` | Set to `false` to disable the login screen |

!!! danger "Don't disable auth on a networked server"
    Setting `AUTH_ENABLED=false` removes the login screen and exposes all API endpoints — including container management and user administration — to anyone who can reach your server. Only use this in isolated local testing environments.

---

## App Settings

These get injected into app templates when you deploy:

| Variable | Default | What it does |
|----------|---------|-------------|
| `APPFOLDER` | `/opt/appdata` | Where deployed apps store their data |
| `ID` | `1000` | The user/group ID containers run as |
| `DOMAIN` | `localhost` | Your domain name (only used in Traefik mode) |
| `DOCKERNETWORK` | `bridge` or `proxy` | Set automatically based on deploy mode |

You don't usually need to change these manually — the deploy modal lets you customise them per app.

---

## Advanced Variables

Rarely needed, but here if you need them:

| Variable | Default | What it does |
|----------|---------|-------------|
| `CLI_BRIDGE_HOST_PATH` | `/opt/homelabarr` | Path to the repo with app templates (must contain `apps/`) |

---

## Using a .env File (Recommended)

Instead of typing `export` commands every time — which only last until you close your terminal — save your settings in a `.env` file next to your `homelabarr.yml`:

```bash
# Required
JWT_SECRET=paste-a-long-random-string-here
DOCKER_GID=999

# Recommended
CORS_ORIGIN=http://192.168.1.100:8084
TZ=America/New_York
APPFOLDER=/opt/appdata
```

!!! tip "Get your DOCKER_GID"
    Run `getent group docker | cut -d: -f3` on your server. It prints a number like `999` or `998`. Use that.

!!! warning "Keep .env out of git"
    Add `.env` to your `.gitignore`. It contains your JWT_SECRET and other sensitive values. Use `.env.example` with placeholder values if you want to template it:
    
    ```bash
    cp .env .env.example
    # Replace real values with placeholders in .env.example
    # Then: git add .env.example (commit this)
    #       git ignore .env (never commit this)
    ```

Start HomelabARR with your .env file:

```bash
docker compose -f homelabarr.yml --env-file .env up -d
```

---

## Where Does My Data Go?

**App data** goes in `/opt/appdata/` (or wherever `APPFOLDER` points):

```
/opt/appdata/
├── plex/           # Plex libraries and settings
├── radarr/         # Radarr config and database
├── sonarr/         # Sonarr config and database
├── qbittorrent/    # Download client settings
└── ...
```

Each app gets its own folder. **This is what you back up.**

**HomelabARR's own data** (user accounts, sessions) lives in a Docker volume called `homelabarr-data`. This persists across restarts automatically.

---

## Docker Socket Security

The backend mounts `/var/run/docker.sock` so it can deploy and manage containers. This gives it control over Docker on your server.

For most homelabs, this is fine and expected. If you want to limit what it can do, consider [Docker Socket Proxy](https://github.com/Tecnativa/docker-socket-proxy) — it sits between HomelabARR and Docker and lets you allow only the API calls you want.

If the Docker socket isn't available (e.g., testing without Docker), the backend still starts in catalog-only mode — you can browse apps but can't deploy or manage containers.

---

## Network Setup

**Standard mode:** containers use Docker's bridge network. Each app gets a port and you access it directly.

**Traefik mode:** containers join a network called `proxy` so Traefik can route traffic to them. Create it once:

```bash
docker network create proxy
```

See the [Traefik & Domain Setup](traefik-setup.md) guide for the full walkthrough.
