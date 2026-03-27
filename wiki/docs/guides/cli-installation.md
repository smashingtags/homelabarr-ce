# CLI Installation

Prefer the terminal over a web browser? The CLI installer sets everything up interactively.

---

## One-Line Install

```bash
curl -fsSL https://raw.githubusercontent.com/smashingtags/homelabarr-ce/main/install-remote.sh | sudo bash
```

That's it. The script will:

1. Check that Docker is installed (and tell you if it's not)
2. Download the HomelabARR repo to `/opt/homelabarr`
3. Walk you through setting up your timezone, user ID, and data paths
4. Configure Docker networks
5. Give you an interactive menu to start deploying apps

---

## CLI vs Web Dashboard

They're two ways to do the same thing — use whichever you prefer, or both:

| | CLI | Web Dashboard |
|--|-----|---------------|
| **Browse apps** | Text menu | Visual catalog with icons |
| **Deploy** | Terminal commands | One-click with progress bar |
| **Manage containers** | `docker ps`, `docker stop` | Buttons in the UI |
| **Best for** | SSH-only servers, scripting, power users | Visual management, beginners |

Both use the exact same app templates from the `apps/` folder. An app deployed from the CLI shows up in the web dashboard, and vice versa.

---

## Adding the Web Dashboard After CLI Install

Already installed via CLI and want the dashboard too?

```bash
cd /opt/homelabarr

export JWT_SECRET=$(openssl rand -hex 32)
export DOCKER_GID=$(getent group docker | cut -d: -f3)

docker compose -f homelabarr.yml up -d
```

Open `http://YOUR-SERVER-IP:8084` and any containers you deployed via CLI will appear in the **Deployed Apps** tab.
