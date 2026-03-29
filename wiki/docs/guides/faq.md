# FAQ & Troubleshooting

---

## Common Questions

### What is HomelabARR CE?

HomelabARR CE (Community Edition) is a free, open-source dashboard for deploying and managing Docker containers on your own server. It comes with 100+ pre-configured apps — media servers, download clients, AI tools, and more. Just click Deploy.

### I'm brand new to Docker. Can I use this?

Yes — that's the point. HomelabARR was built so you don't have to learn Docker Compose syntax just to run Plex or Nextcloud. The dashboard handles the Docker files. You do need to run a few shell commands during setup (git clone, docker compose up), but the [Quick Start guide](quick-start.md) walks through every step.

### How is this different from Portainer?

Portainer is a general Docker management tool — powerful, but it assumes you already know what you want to run. HomelabARR gives you a curated catalog of 100+ homelab apps with one-click deployment. Think of it as an app store for your server. They work great together — Portainer is even in the catalog.

### Does it work on Raspberry Pi / ARM?

Yes. Docker images are built for both **x86_64** and **ARM64**. Works on Raspberry Pi 4/5, Apple Silicon Macs (in a VM or Docker Desktop), AWS Graviton, and standard x86 servers.

### Can I use it without Docker?

No. HomelabARR runs as Docker containers and deploys Docker containers. Docker is required. The [Quick Start](quick-start.md) shows you how to install it if you don't have it yet.

### Is it free?

CE (Community Edition) is 100% free and open source under the MIT license. There's also a [Professional Edition](../pe/overview.md) with additional NAS management features — that one's paid.

---

## Installation Problems

### "Failed to load applications" — the dashboard loads but no apps show up

The app templates are missing. Make sure you ran the `git clone` step in Quick Start:

```bash
git clone https://github.com/smashingtags/homelabarr-ce.git /opt/homelabarr
```

The 100+ app templates live in the `apps/` folder inside the repo. Without it, the dashboard has nothing to show. This is the most common setup mistake.

### CORS error or API calls fail after login

`CORS_ORIGIN` must match **exactly** how you access the dashboard in your browser — same protocol, same IP or hostname, same port.

```bash
# Example: if you access it at http://192.168.1.100:8084, set:
export CORS_ORIGIN=http://192.168.1.100:8084

# Restart
docker compose -f homelabarr.yml up -d
```

Common mistake: set `CORS_ORIGIN=http://server-hostname:8084` but browse to `http://192.168.1.100:8084`. They have to match.

### "Port already in use"

Something else on your server is using port 8084 or 8092. Find out what:

```bash
sudo ss -tlnp | grep 8084
```

Change the port in your `.env` file:

```bash
FRONTEND_PORT=8085
```

### Docker socket permission denied

`DOCKER_GID` must match your server's Docker group ID:

```bash
# Find it
getent group docker | cut -d: -f3

# Set it and restart
export DOCKER_GID=YOUR_NUMBER
docker compose -f homelabarr.yml up -d
```

### Running in a Proxmox LXC container

Docker inside Proxmox LXC needs AppArmor disabled at the Proxmox host level — this is a Proxmox constraint, not a HomelabARR issue.

On your **Proxmox host** (not inside the container):

```bash
echo 'lxc.apparmor.profile: unconfined' >> /etc/pve/lxc/YOUR-VMID.conf
```

Replace `YOUR-VMID` with your container ID (like `100`). Then restart the LXC from the Proxmox UI.

---

## Deployment Modes

### What are the three deployment modes?

1. **Standard** — simplest. Your app gets a port number, you access it at `http://your-server:PORT`. No extra setup needed. **Choose this if you're not sure.**
2. **Traefik** — your app gets a real URL like `https://plex.yourdomain.com` with automatic free SSL. Requires a domain name and Traefik running on your server. ([Setup guide](traefik-setup.md))
3. **Traefik + Authelia** — same as Traefik, but adds a login page in front of the app. Recommended for any app you expose to the internet.

### My deployed app isn't accessible

Check in order:

```bash
# 1. Is it running?
docker ps | grep app-name

# 2. Any errors?
docker logs app-name --tail 30

# 3. What port?
docker port app-name

# 4. Is the port blocked by firewall?
sudo ufw allow PORT/tcp
```

### Can I deploy without the web UI?

Yes. The templates in `apps/` are standard Docker Compose files:

```bash
docker compose -f apps/media-servers/plex.yml --env-file .env up -d
```

---

## Security

### The default login is admin/admin — is that safe?

Not by default. Change your password immediately after setup. The dashboard is accessible to anyone on your local network until you do. The Quick Start and Web Dashboard guides both have warnings about this.

### Should I expose HomelabARR to the internet?

If you do, use Traefik + Authelia (or another authentication layer) in front of it. Don't expose an unauthenticated dashboard to the public internet.

---

## Data & Backups

### Where's my data?

- **App data**: `/opt/appdata/` — each app gets its own subfolder
- **HomelabARR settings** (users, sessions): `homelabarr-data` Docker volume

### How do I back up everything?

```bash
# Back up all app data
sudo tar -czf homelabarr-backup-$(date +%Y%m%d).tar.gz /opt/appdata/
```

### How do I update to the latest version?

```bash
docker compose -f homelabarr.yml pull
docker compose -f homelabarr.yml up -d
```

Data and settings are untouched — only the app itself updates.

---

## Custom Apps

### Can I add my own apps?

Yes. Create a Docker Compose file in `apps/myapps/`:

```yaml
# apps/myapps/my-app.yml
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

Refresh the dashboard and your app shows up in the **My Apps** tab.

---

## Getting Help

- **Discord**: [discord.gg/Pc7mXX786x](https://discord.gg/Pc7mXX786x) — fastest way to get help, someone's usually around
- **GitHub Issues**: [Report a bug](https://github.com/smashingtags/homelabarr-ce/issues)
- **GitHub Discussions**: [Ask a question](https://github.com/smashingtags/homelabarr-ce/discussions)
- **Website**: [homelabarr.com](https://homelabarr.com)
