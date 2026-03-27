# Configuration

HomelabARR uses environment variables to control how it runs. You set them before starting the containers, and they tell the app things like "what port to use" and "where to store data."

---

## The Two You Actually Need

These are required. Without them, things break:

| Variable | What it does | How to set it |
|----------|-------------|---------------|
| `JWT_SECRET` | A random secret key that keeps your login secure | `export JWT_SECRET=$(openssl rand -hex 32)` |
| `DOCKER_GID` | Tells the container which group can talk to Docker | `export DOCKER_GID=$(getent group docker \| cut -d: -f3)` |

That's it. Everything else has sensible defaults.

---

## Common Settings

These are optional but useful:

| Variable | Default | What it does |
|----------|---------|-------------|
| `CORS_ORIGIN` | — | The URL you use to open the dashboard (e.g., `http://192.168.1.100:8084`). Set this if you get CORS errors after logging in. |
| `FRONTEND_PORT` | `8084` | The port for the web dashboard |
| `BACKEND_PORT` | `8092` | The port for the API server |
| `TZ` | `UTC` | Your timezone (e.g., `America/New_York`, `Europe/London`) |
| `APPFOLDER` | `/opt/appdata` | Where deployed apps store their data |
| `AUTH_ENABLED` | `true` | Turn off if you don't want a login screen (not recommended) |

---

## App Settings

When you deploy an app, these variables get injected into its Docker Compose template:

| Variable | Default | What it does |
|----------|---------|-------------|
| `ID` | `1000` | The user/group ID the container runs as |
| `TZ` | `UTC` | Timezone for the app |
| `APPFOLDER` | `/opt/appdata` | Where the app stores its config and data |
| `DOMAIN` | `localhost` | Your domain name (only matters if you use Traefik) |
| `DOCKERNETWORK` | `bridge` or `proxy` | Which Docker network to use (set automatically based on deploy mode) |

You don't usually need to change these — the deploy modal lets you customize them per app.

---

## Using a .env File (Recommended)

Instead of typing `export` commands every time, save your settings in a file called `.env` next to your `homelabarr.yml`:

```bash
# Required
JWT_SECRET=paste-a-long-random-string-here
DOCKER_GID=999

# Recommended
CORS_ORIGIN=http://192.168.1.100:8084
TZ=America/New_York
```

!!! tip "How to get your DOCKER_GID"
    Run `getent group docker | cut -d: -f3` on your server. It'll print a number like `999` or `998`. Use that number.

Then start HomelabARR like this:

```bash
docker compose -f homelabarr.yml --env-file .env up -d
```

The `.env` file is the cleanest way to manage your settings. It survives reboots and you only set things up once.

---

## Where Does My Data Go?

Two places:

**App data** goes in `/opt/appdata/` (or wherever `APPFOLDER` points):

```
/opt/appdata/
├── plex/           # Plex libraries and settings
├── radarr/         # Radarr config and database
├── sonarr/         # Sonarr config and database
├── qbittorrent/    # Download client settings
└── ...
```

Each app gets its own folder. This is what you want to back up.

**HomelabARR's own data** (user accounts, sessions) lives in a Docker volume called `homelabarr-data`. This persists across container restarts automatically.

---

## Docker Socket

The backend needs to talk to Docker to deploy and manage containers. The default `homelabarr.yml` handles this by mounting `/var/run/docker.sock` into the container.

If the Docker socket isn't available (maybe you're testing without Docker), the backend still starts — you can browse the app catalog, but deploying and managing containers won't work.

!!! info "Security note"
    Docker socket access gives the backend control over Docker on your server. For most homelabs, this is fine. If you want to limit what it can do, look into [Docker socket proxy](https://github.com/Tecnativa/docker-socket-proxy).

---

## Network Setup

**Standard mode** (the default): containers use Docker's built-in bridge network. Each app gets a port number and you access it directly.

**Traefik mode**: containers join a network called `proxy` so Traefik can route traffic to them. If you're using Traefik, create this network first:

```bash
docker network create proxy
```

See the [Traefik & Domain Setup](traefik-setup.md) guide for the full walkthrough.
