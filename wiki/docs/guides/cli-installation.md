# CLI Installation

For users who prefer a terminal-based setup, HomelabARR CE includes an interactive CLI installer.

---

## Install

```bash
# Download the installer
sudo wget -qO /usr/local/bin/homelabarr-cli \
  https://raw.githubusercontent.com/smashingtags/homelabarr-ce/main/install-remote.sh
sudo chmod +x /usr/local/bin/homelabarr-cli

# Run the interactive installer
homelabarr-cli -i
```

The installer will:

1. Check for Docker and Docker Compose
2. Clone the HomelabARR CE repository to `/opt/homelabarr`
3. Set up environment variables (timezone, UID/GID, appdata path)
4. Configure Docker networks
5. Present an interactive menu for deploying applications

---

## CLI vs Web Dashboard

The CLI and web dashboard are complementary approaches to the same template library:

| Feature | CLI | Web Dashboard |
|---------|-----|---------------|
| App catalog | Terminal menu | Visual grid with icons |
| Deploy apps | `docker compose up -d` | One-click with progress UI |
| Container management | `docker ps`, `docker stop` | Dashboard controls |
| Port conflicts | Manual checking | Port Manager tool |
| Configuration | Edit `.env` files | Modal with form fields |
| Best for | Headless servers, SSH-only access | Visual management, new users |

Both methods use the same Docker Compose templates from the `apps/` directory.

---

## Post-Install

After CLI installation, you can optionally start the web dashboard:

```bash
cd /opt/homelabarr

# Set required variables
export JWT_SECRET=$(openssl rand -hex 32)
export DOCKER_GID=$(getent group docker | cut -d: -f3)

# Start the dashboard
docker compose -f homelabarr.yml up -d
```

The dashboard will detect containers deployed by the CLI and show them in the **Deployed Apps** tab.

---

[homelabarr.com](https://homelabarr.com) · [Imogen Labs](https://imogenlabs.ai) · [Michael Ashley](https://mjashley.com)
