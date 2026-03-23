# Quick Start Guide

## Prerequisites

| Requirement | Details |
|-------------|---------|
| **Docker** | Docker Engine 24+ |
| **Docker Compose** | v2 (included with Docker Engine) |
| **OS** | Ubuntu 18.04+, Debian 10+, or any Linux with Docker (x86_64) |
| **RAM** | 4GB minimum, 8GB+ recommended |
| **Storage** | 20GB+ free space |
| **Git** | Only required for Method 2 (CLI installation) |

!!! note "No domain required"
    Methods 1 and 3 work without a domain or Cloudflare account. You only need a domain for Method 2 (Traefik + SSL).

---

## Method 1: Docker Compose (Recommended)

The fastest way to get HomelabARR CE running. Four commands, no domain required.

```bash
# Download the compose file
curl -o homelabarr.yml https://raw.githubusercontent.com/smashingtags/homelabarr-ce/main/homelabarr.yml

# Set required environment variables
export JWT_SECRET=$(openssl rand -base64 32)
export DOCKER_GID=$(getent group docker | cut -d: -f3)
export CORS_ORIGIN=http://$(hostname -I | awk '{print $1}'):8084

# Start HomelabARR CE
docker compose -f homelabarr.yml up -d
```

!!! warning "CORS_ORIGIN is required"
    The backend rejects browser requests unless `CORS_ORIGIN` matches the URL you use to access the dashboard. If you access it at `http://192.168.1.50:8084`, set `CORS_ORIGIN=http://192.168.1.50:8084`. Without this, login and all API calls will fail with a 500 error.

Once the containers are up:

1. Open **http://your-server-ip:8084** in your browser
2. Log in with **admin / admin**
3. Browse the app catalog (157+ apps)
4. Click **Deploy** on any app to launch it

!!! warning "Change the default password"
    After first login, change the admin password immediately from the dashboard settings.

!!! tip "Persisting your JWT secret"
    If you plan to restart the stack later, save `JWT_SECRET` in a `.env` file next to `homelabarr.yml` so sessions survive restarts:
    ```bash
    echo "JWT_SECRET=$(openssl rand -base64 32)" > .env
    echo "DOCKER_GID=$(getent group docker | cut -d: -f3)" >> .env
    echo "CORS_ORIGIN=http://$(hostname -I | awk '{print $1}'):8084" >> .env
    ```

!!! note "Running in a Proxmox LXC?"
    Docker inside an LXC container requires AppArmor to be disabled. Add these lines to your LXC config on the Proxmox host (`/etc/pve/lxc/<VMID>.conf`):
    ```
    lxc.apparmor.profile: unconfined
    lxc.cap.drop:
    ```
    Then restart the container: `pct stop <VMID> && pct start <VMID>`. Without this, containers will fail to start with an AppArmor policy error.

---

## Method 2: Build From Source

Clone the repo and build the Docker images yourself. Use this if you want to modify the code, customize templates, or contribute changes.

```bash
git clone https://github.com/smashingtags/homelabarr-ce.git
cd homelabarr-ce
cp .env.example .env    # Edit with your settings
```

Build both images locally:

```bash
docker build -t homelabarr-frontend:local -f Dockerfile .
docker build -t homelabarr-backend:local -f Dockerfile.backend .
```

Update `homelabarr.yml` to use your local images:

```yaml
# Change these lines:
image: ghcr.io/smashingtags/homelabarr-frontend:latest  # → homelabarr-frontend:local
image: ghcr.io/smashingtags/homelabarr-backend:latest   # → homelabarr-backend:local
```

Then deploy:

```bash
export JWT_SECRET=$(openssl rand -base64 32)
export DOCKER_GID=$(getent group docker | cut -d: -f3)
docker compose -f homelabarr.yml up -d
```

!!! tip "Why build from source?"
    - Customize app templates in `apps/` before building
    - Modify the backend API in `server/`
    - Change the frontend UI in `src/`
    - Test changes before submitting a pull request

---

## Method 3: CLI Installation

An interactive terminal-based installer with a menu system. You choose what to install — nothing is forced.

### One-Line Install

```bash
sudo wget -qO- https://raw.githubusercontent.com/smashingtags/homelabarr-ce/main/install-remote.sh | sudo bash
```

Then open the menu:

```bash
sudo homelabarr-cli -i
```

That's it. The script clones the repo to `/opt/homelabarr`, sets permissions, and installs the `homelabarr-cli` command.

### Manual Install (alternative)

```bash
git clone https://github.com/smashingtags/homelabarr-ce.git
cd homelabarr-ce
chmod +x install.sh
find . -name "*.sh" -exec chmod +x {} \;
sudo ln -sf "$(pwd)" /opt/homelabarr
sudo ./install.sh
```

If Docker isn't installed, the installer runs the preinstall setup first (installs Docker, creates directories, configures networking).

Once Docker is detected, you'll see the **main menu**:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    🚀 HomelabARR CLI
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    [ 1 ] HomelabARR CLI - Traefik + Authelia
    [ 2 ] HomelabARR CLI - Applications

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    [ EXIT or Z ] - Exit
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Option 1: Traefik + Authelia + Auto DNS** — Sets up a reverse proxy with SSL certificates, 2FA authentication, and automatic Cloudflare DNS. Requires a domain name and Cloudflare account. Only install this if you want domain-based access (e.g., `https://plex.yourdomain.com`).

!!! tip "Install this first if you have a domain"
    The Traefik stack includes [CF Companion](https://github.com/smashingtags/cf-companion) — every container you deploy after this automatically gets a Cloudflare DNS record. No more logging into Cloudflare to manually create CNAMEs. Deploy an app, the DNS record appears within seconds.

**Option 2: Applications** — Opens the app management menu:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    🚀  HomelabARR CLI Applications Section Menu
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    [ 1 ] Install  Apps
    [ 2 ] Remove   Apps
    [ 3 ] Backup   Apps
    [ 4 ] Restore  Apps

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Selecting **Install Apps** shows all available categories (mediaserver, downloadclients, mediamanager, addons, etc.). Pick a category, then pick an app — it deploys via Docker Compose using the template YAML.

!!! tip "You don't need Traefik to use the CLI"
    Option 1 (Traefik + Authelia) is completely optional. You can skip straight to Option 2 and install apps directly. Without Traefik, apps are accessed by IP and port number (e.g., `http://192.168.1.100:32400` for Plex).

---

## Method 4: Local Mode

No domain, no Traefik, no SSL. Containers are accessed directly by port number. Ideal for testing or LAN-only setups.

```bash
git clone https://github.com/smashingtags/homelabarr-ce.git
cd homelabarr-ce
chmod +x install.sh deploy-local.sh
./deploy-local.sh
```

The local deploy script walks you through deploying apps with direct port access. Apps are accessible at `http://your-server-ip:<port>` (e.g., Plex at `:32400`, Radarr at `:7878`).

See the [Local Mode Setup](../install/local-mode.md) guide for details.

---

## Next Steps

- **[Web Dashboard](web-dashboard.md)** — Navigate the GUI, deploy apps, manage containers
- **[CLI Bridge](cli-bridge.md)** — How templates flow from `apps/` to the web GUI
- **[API Reference](api-reference.md)** — REST API endpoints for automation
- **[Traefik + Domain Setup](../install/traefik.md)** — Reverse proxy with SSL
- **[Contributing](contributing.md)** — Help improve HomelabARR CE

---

## Quick Troubleshooting

| Problem | Fix |
|---------|-----|
| `Permission denied` on scripts | `chmod +x install.sh && find . -name "*.sh" -exec chmod +x {} \;` |
| Path errors mentioning `/opt/homelabarr` | `sudo ln -sf "$(pwd)" /opt/homelabarr` |
| Docker not found | `curl -fsSL https://get.docker.com \| sh` |
| Can't reach dashboard on :8084 | Check `docker ps` — containers may still be starting |

For detailed troubleshooting, see the [Linux Installation Guide](../install/linux-installation.md#troubleshooting).
