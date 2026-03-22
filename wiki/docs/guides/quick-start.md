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

# Generate a JWT secret and detect your Docker group ID
export JWT_SECRET=$(openssl rand -base64 32)
export DOCKER_GID=$(getent group docker | cut -d: -f3)

# Start HomelabARR CE
docker compose -f homelabarr.yml up -d
```

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

## Method 3: CLI Installation (Full Mode)

For users who want the full stack: **Traefik reverse proxy + domain-based routing + SSL certificates + Authelia 2FA**.

### Requirements (in addition to prerequisites above)

- A domain name with [Cloudflare](https://dash.cloudflare.com/sign-up) DNS management
- Cloudflare API token with Zone:Edit permissions

### Installation

```bash
git clone https://github.com/smashingtags/homelabarr-ce.git
cd homelabarr-ce
chmod +x install.sh
sudo ln -sf "$(pwd)" /opt/homelabarr
sudo ./install.sh
```

The interactive menu will guide you through:

1. **Option 1: Traefik + Authelia** — Sets up reverse proxy, SSL, and authentication (run this first)
2. **Option 2: Applications** — Deploys media servers, managers, and download clients

After installation, access your services at:

- `https://your-domain.com` — Main dashboard
- `https://traefik.your-domain.com` — Traefik dashboard
- `https://auth.your-domain.com` — Authelia login

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
