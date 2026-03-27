# Web Dashboard

This is your home base. Everything you need to deploy and manage apps lives here.

**How to get there:** Open `http://YOUR-SERVER-IP:8084` in any browser.

**Default login:** Username `admin`, Password `admin` — change this right away.

![Dashboard Overview](../img/screenshots/dark-dashboard.png)

---

## What You're Looking At

When you first open the dashboard, here's what you'll see:

- **Top left** — "HomelabARR" and your connection status (e.g., "Connected · 123 apps")
- **Top right** — Port Manager, Help, dark/light mode toggle, and Sign In
- **Middle** — Category tabs to browse apps
- **Below that** — The app catalog with search and sorting

---

## Browsing Apps

Apps are sorted into 10 categories. Click any tab to filter:

| Tab | What's in it |
|-----|-------------|
| **Media & Entertainment** | Plex, Jellyfin, Emby — your streaming servers |
| **Downloads & Automation** | qBittorrent, SABnzbd, NZBGet, Prowlarr, Jackett |
| **Monitoring & Analytics** | Netdata, Grafana, Speedtest, Uptime Kuma |
| **Virtual Desktops** | Chrome, Firefox, Discord, Steam — full desktops in your browser |
| **Backup & Storage** | Duplicati, Restic, Rsnapshot |
| **System & Utilities** | Portainer, Dozzle, Watchtower, Gluetun (VPN) |
| **Self-hosted** | Nextcloud, Bitwarden, Pi-hole, Home Assistant, n8n |
| **AI & Machine Learning** | Ollama, Open WebUI, ComfyUI, Stable Diffusion, LocalAI |
| **My Apps** | Your own custom templates (more on this below) |
| **All Apps** | Everything in one alphabetical list |

There are also two special views:

- **Deployed Apps** — shows only the apps currently running on your server
- **All Apps** — the full catalog, A to Z

Use the **search bar** at the top to find apps by name. It searches across all categories.

---

## Deploying an App

This is the fun part.

1. **Find the app you want** — browse or search
2. **Click the blue Deploy button** on the app card
3. **Pick a deployment mode:**
    - **Standard** — the simple one. The app gets a port number, you access it at `http://your-server:PORT`. No extra setup needed.
    - **Traefik** — if you have a domain name and Traefik set up, the app gets its own URL like `https://plex.yourdomain.com` with free SSL. ([Traefik setup guide](traefik-setup.md))
    - **Traefik + Authelia** — same as Traefik but adds a login page in front of the app for extra security
4. **Configure settings** — timezone, data paths, etc. The defaults usually work fine.
5. **Click Deploy** — watch it install in real time

![Deploy Modal](../img/screenshots/dark-deploy-modal-auth.png)

!!! tip "Start with Standard mode"
    If you're new, always pick **Standard**. It just works. You can add Traefik and domains later when you're ready.

### What happens when you click Deploy

You'll see a real-time progress feed showing:

- Docker images being downloaded
- The container being created
- Whether it started successfully (or what went wrong)

This isn't a spinner that leaves you guessing — you see exactly what's happening.

---

## Managing Running Apps

Click the **Deployed Apps** tab to see everything that's running. For each app you can:

- **Start** — start an app that's stopped
- **Stop** — shut it down gracefully
- **Restart** — stop and start again (good for applying config changes)
- **Remove** — delete the container entirely
- **Logs** — see what the app is printing to the console (useful for troubleshooting)

---

## Port Manager

Click **Port Manager** in the header to see which ports are taken on your server. This helps you avoid conflicts when deploying new apps. It shows:

- Every port currently used by a Docker container
- Which container is using it
- Where to find the next available port

---

## Signing In

Click **Sign In** in the top right.

![Login Modal](../img/screenshots/dark-login-modal.png)

The default username is `admin` and the password is `admin`.

!!! danger "Change your password"
    Seriously, change this. Click your username in the top right after logging in to update it.

### API Keys

If you want to access HomelabARR from a script, the mobile app, or another tool, you can generate API keys:

1. Log in to the dashboard
2. Open your user settings
3. Click "Generate API Key"
4. You'll get a key that starts with `hlr_` — save it somewhere safe, it's only shown once

Use it in API calls like this:

```bash
curl -H "Authorization: Bearer hlr_your_key_here" http://your-server:8092/applications
```

---

## Adding Your Own Apps

Got a Docker app that's not in the catalog? Add it yourself:

1. Create a file called `my-app.yml` in the `apps/myapps/` folder
2. Use standard Docker Compose format:

```yaml
version: "3"
services:
  my-app:
    image: my-image:latest
    container_name: my-app
    restart: unless-stopped
    ports:
      - 9000:9000
    environment:
      - TZ=${TZ}
    volumes:
      - ${APPFOLDER}/my-app:/config
```

3. Refresh the dashboard — your app shows up in the **My Apps** tab

That's it. You can use the same `${TZ}`, `${APPFOLDER}`, and other variables that the built-in apps use. See the [CLI Bridge guide](cli-bridge.md) for all the available variables.

---

## Dark Mode

The dashboard supports dark and light mode. Click the sun/moon icon in the header to switch, or it'll follow your system preference automatically.
