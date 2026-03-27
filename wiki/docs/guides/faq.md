# FAQ & Troubleshooting

---

## Common Questions

### What is HomelabARR CE?

HomelabARR CE (Community Edition) is a free, open-source app that makes it easy to install and manage Docker containers on your server. It comes with 100+ pre-configured apps — media servers, download clients, AI tools, and more. Just click Deploy.

### I'm brand new to Docker. Can I use this?

Yes — that's the whole point. HomelabARR was built so you don't have to learn Docker Compose files and YAML syntax just to run Plex or Nextcloud. The dashboard handles all of that for you. Just follow the [Quick Start](quick-start.md) guide.

### How is this different from Portainer?

Portainer is a general Docker management tool — it lets you manage containers, but you have to know what you're doing. HomelabARR gives you a curated catalog of 100+ homelab apps with one-click deployment. Think of it as an app store for your server. You can always use Portainer alongside it for advanced Docker management (it's even in the catalog).

### Does it work on Raspberry Pi / ARM?

Yes. Docker images are built for both **x86_64** and **ARM64**. Works on Raspberry Pi 4/5, Apple Silicon Macs, AWS Graviton, and standard x86 servers.

### Can I use it without Docker?

No. HomelabARR runs as Docker containers and deploys Docker containers. You need Docker installed. The [Quick Start](quick-start.md) guide shows you how to install Docker if you don't have it yet.

### Is it free?

CE (Community Edition) is 100% free and open source under the MIT license. There's also a [Professional Edition](../pe/overview.md) with additional features for power users — that one's paid.

---

## Installation Problems

### "Failed to load applications" — the dashboard loads but no apps show up

This means the backend can't find the app templates. Make sure you cloned the repository in the Quick Start:

```bash
git clone https://github.com/smashingtags/homelabarr-ce.git /opt/homelabarr
```

The `apps/` folder inside the repo is what contains all 100+ app templates. Without it, the dashboard has nothing to show.

### CORS error or API calls failing after login

The `CORS_ORIGIN` variable needs to match **exactly** how you access the dashboard in your browser. Common mistake: you set it to `http://192.168.1.100:8084` but you're accessing it at `http://my-server:8084`.

```bash
# Check what URL is in your browser address bar, then set it:
export CORS_ORIGIN=http://192.168.1.100:8084

# Restart
docker compose -f homelabarr.yml up -d
```

### "Port already in use"

Something else on your server is already using port 8084 or 8092. Find out what:

```bash
sudo ss -tlnp | grep 8084
```

Fix it by changing the port in your `.env` file:

```bash
FRONTEND_PORT=8085
```

### Docker socket permission denied

The `DOCKER_GID` variable needs to match your server's Docker group ID:

```bash
# Find your Docker group ID
getent group docker | cut -d: -f3

# Set it and restart
export DOCKER_GID=YOUR_NUMBER
docker compose -f homelabarr.yml up -d
```

### Running in a Proxmox LXC container

Docker inside a Proxmox LXC needs AppArmor disabled. This is a Proxmox thing, not a HomelabARR thing.

On your **Proxmox host** (not inside the container):

```bash
echo 'lxc.apparmor.profile: unconfined' >> /etc/pve/lxc/YOUR-VMID.conf
```

Replace `YOUR-VMID` with your container's ID (like `100`). Then restart the LXC from the Proxmox UI.

---

## Deployment Problems

### What are the three deployment modes?

1. **Standard** — the simple one. Your app gets a port number, you access it at `http://your-server:PORT`. No extra setup needed. **Pick this if you're not sure.**
2. **Traefik** — your app gets a real URL like `https://plex.yourdomain.com` with free SSL. Requires a domain name and Traefik running on your server. ([Setup guide](traefik-setup.md))
3. **Traefik + Authelia** — same as Traefik but adds a login page in front of the app so only authorized users can access it.

### My deployed app isn't accessible

Check these in order:

1. **Is it running?** `docker ps | grep app-name`
2. **Any errors?** `docker logs app-name`
3. **What port?** `docker port app-name` — then try that port in your browser
4. **Firewall?** Make sure the port isn't blocked: `sudo ufw allow PORT/tcp`

### Can I deploy apps without the web UI?

Yes. The templates in the `apps/` folder are standard Docker Compose files. Deploy them directly:

```bash
docker compose -f apps/media-servers/plex.yml --env-file .env up -d
```

---

## Data & Backups

### Where's my data?

- **App data**: `/opt/appdata/` — each app gets its own subfolder
- **HomelabARR settings**: `homelabarr-data` Docker volume

### How do I back up everything?

```bash
# Back up all your app data
sudo tar -czf homelabarr-backup-$(date +%Y%m%d).tar.gz /opt/appdata/
```

### How do I update to the latest version?

```bash
docker compose -f homelabarr.yml pull
docker compose -f homelabarr.yml up -d
```

That's it. Your data and settings are untouched — only the app itself updates.

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

## Still Stuck?

- **Discord**: [discord.gg/Pc7mXX786x](https://discord.gg/Pc7mXX786x) — fastest way to get help
- **GitHub Issues**: [Report a bug](https://github.com/smashingtags/homelabarr-ce/issues)
- **GitHub Discussions**: [Ask a question](https://github.com/smashingtags/homelabarr-ce/discussions)
- **Website**: [homelabarr.com](https://homelabarr.com)
