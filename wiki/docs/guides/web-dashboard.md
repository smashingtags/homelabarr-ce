# Web Dashboard

The HomelabARR CE dashboard is a React web application for browsing, deploying, and managing Docker containers.

**Default URL:** `http://your-server:8084`  
**Default credentials:** `admin` / `admin`

![Dashboard Overview](../img/screenshots/dark-dashboard.png)

---

## Navigation

### Header

The top bar shows:

- **HomelabARR** title and connection status ("Connected · 123 apps" or similar)
- **Port Manager** — view used ports and find available ones
- **Help** — quick reference for getting started
- **Theme toggle** — switch between dark and light mode
- **Sign In / User menu** — authentication controls

### Category Tabs

Apps are organized into 10 categories plus two special views:

| Tab | What's in it |
|-----|-------------|
| **Deployed Apps** | Containers currently running on your server |
| **Media & Entertainment** | Plex, Jellyfin, Emby, Mstream |
| **Downloads & Automation** | qBittorrent, SABnzbd, NZBGet, Jackett, Prowlarr, Flaresolverr |
| **Monitoring & Analytics** | Netdata, Grafana/Prometheus, Speedtest, Tauticord, Notifiarr, Vnstat |
| **Virtual Desktops** | Chrome, Firefox, Discord, Steam, Signal, Telegram (Kasm-powered) |
| **Backup & Storage** | Duplicati, Restic, Rsnapshot |
| **System & Utilities** | Portainer, Dozzle, Uptime Kuma, Watchtower, Gluetun, MariaDB |
| **Self-hosted** | Nextcloud, Bitwarden, Pi-hole, Home Assistant, n8n, Code Server, Dashy |
| **AI & Machine Learning** | Ollama, Open WebUI, ComfyUI, Stable Diffusion, LocalAI, Flowise, GPT4All |
| **My Apps** | Your custom Docker Compose templates (from `apps/myapps/`) |
| **All Apps** | Complete alphabetical list of every available application |

### Search

Use the search bar at the top to filter apps by name. Works across all categories.

---

## Deploying an App

1. **Find the app** — browse categories or search by name
2. **Click Deploy** — opens the deployment configuration modal
3. **Choose a deployment mode:**
    - **Standard / Local** — direct port mapping, no reverse proxy needed
    - **Traefik** — reverse proxy with automatic SSL via Let's Encrypt
    - **Traefik + Authelia** — adds SSO and multi-factor authentication
4. **Configure settings** — timezone, data paths, domain, ports
5. **Click Deploy** — deployment starts immediately

### Real-time Progress

Deployments stream progress in real-time via Server-Sent Events (SSE). You'll see:

- Image pull progress
- Container creation status
- Startup confirmation or error details

### Deployment Modes Explained

**Standard (Local Mode):**

- Container binds directly to a host port
- Access via `http://your-server:PORT`
- No external dependencies
- Best for: local networks, testing, simple setups

**Traefik:**

- Container joins the `proxy` Docker network
- Traefik automatically routes traffic based on hostname labels
- SSL certificates via Let's Encrypt
- Access via `https://app.yourdomain.com`
- Requires: [Traefik setup](traefik-setup.md), a domain, DNS pointing to your server

**Traefik + Authelia:**

- Everything from Traefik mode, plus authentication middleware
- Adds SSO login page before accessing the app
- Supports multi-factor authentication (TOTP, WebAuthn)
- Requires: Traefik + Authelia running

---

## Container Management

Once apps are deployed, the **Deployed Apps** tab shows all running containers with controls to:

- **Start** — start a stopped container
- **Stop** — gracefully stop a running container
- **Restart** — stop and start
- **Remove** — delete the container (optionally including volumes)
- **Logs** — view container stdout/stderr output

---

## Port Manager

Click the **Port Manager** button in the header to:

- See all host ports currently in use by Docker containers
- Find the next available port in a given range
- Avoid port conflicts when deploying new apps

---

## Authentication

### Default Login

Username: `admin`, Password: `admin`

!!! danger "Change the default password"
    Change your password immediately after first login via the user menu.

### API Keys

For programmatic access (scripts, mobile apps, monitoring), generate API keys:

1. Sign in to the dashboard
2. Open user settings
3. Generate a new API key (prefixed with `hlr_`)
4. Use the key in the `Authorization: Bearer hlr_...` header

API keys provide the same access as your user account and don't expire unless revoked.

### User Management

Admins can create additional user accounts via the API:

```bash
curl -X POST http://your-server:8092/auth/users \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"username": "viewer", "password": "secret", "role": "user"}'
```

---

## Custom App Templates

Add your own Docker Compose templates to the **My Apps** category:

1. Create a YAML file in `apps/myapps/your-app.yml`
2. Use standard Docker Compose format with at least one service
3. Use environment variable placeholders (`${APPFOLDER}`, `${TZ}`, `${ID}`, etc.)
4. The app appears automatically in the dashboard

See the [CLI Bridge](cli-bridge.md) guide for template format details.

---

## Theme

The dashboard supports light and dark mode:

- **Automatic** — follows your system preference
- **Manual toggle** — click the theme button in the header

All screenshots in this wiki show dark mode. Light mode uses the same layout with inverted colors.

---

[homelabarr.com](https://homelabarr.com) · [Imogen Labs](https://imogenlabs.ai) · [Michael Ashley](https://mjashley.com)
