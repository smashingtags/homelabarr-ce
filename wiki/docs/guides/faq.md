# FAQ & Troubleshooting

---

## General

### What is HomelabARR CE?

HomelabARR CE (Community Edition) is a free, open-source web dashboard for deploying and managing Docker containers. It comes with 100+ pre-configured app templates for media servers, download clients, monitoring tools, AI platforms, and more.

### How is it different from Portainer?

Portainer is a general-purpose Docker management UI. HomelabARR CE is purpose-built for homelabs — it includes a curated catalog of 100+ self-hosted apps with pre-configured Docker Compose templates. Click Deploy, and it handles the compose file, environment variables, and network setup for you.

### Is ARM supported?

Yes! Docker images are built for both **x86_64 (amd64)** and **ARM64 (aarch64)**. Runs on Raspberry Pi 4/5, Apple Silicon, AWS Graviton, and standard x86 servers.

### Can I use it without Docker?

No. HomelabARR CE runs as Docker containers and manages other Docker containers. Docker is required.

---

## Installation

### CORS errors after login

The `CORS_ORIGIN` environment variable must match exactly how you access the dashboard:

```bash
# For IP access
export CORS_ORIGIN=http://192.168.1.100:8084

# For domain access
export CORS_ORIGIN=https://homelabarr.yourdomain.com
```

Restart after changing:

```bash
docker compose -f homelabarr.yml up -d
```

### Docker socket permission denied

Ensure `DOCKER_GID` matches your host's Docker group:

```bash
# Find your Docker GID
getent group docker | cut -d: -f3

# Set it in your .env or export
export DOCKER_GID=999
```

### Containers won't start — "port already in use"

Check what's using the port:

```bash
sudo lsof -i :8084
# or
sudo ss -tlnp | grep 8084
```

Change the port in your `.env`:

```bash
FRONTEND_PORT=8085
```

### Running in Proxmox LXC

If Docker fails inside an LXC container, disable AppArmor on the Proxmox host:

```
# /etc/pve/lxc/<VMID>.conf
lxc.apparmor.profile: unconfined
```

Restart the LXC after editing.

---

## Deployment

### What deployment modes are available?

1. **Standard** — direct port access (`http://server:port`), no reverse proxy
2. **Traefik** — reverse proxy with automatic SSL via Let's Encrypt
3. **Traefik + Authelia** — adds single sign-on and optional MFA

### Can I deploy apps without the web UI?

Yes. The underlying templates are standard Docker Compose files in the `apps/` directory. You can deploy them directly:

```bash
docker compose -f apps/media-servers/plex.yml --env-file .env up -d
```

### My deployed app isn't accessible

1. Check the container is running: `docker ps | grep app-name`
2. Check logs: `docker logs app-name`
3. Verify the port mapping: `docker port app-name`
4. If using Traefik: ensure the container is on the `proxy` network and DNS is configured

---

## Data & Backup

### Where is my data stored?

- **App configurations**: `/opt/appdata/` (configurable via `APPFOLDER`)
- **HomelabARR state**: `homelabarr-data` Docker volume

### How do I back up?

```bash
# Back up all app data
sudo tar -czf homelabarr-backup-$(date +%Y%m%d).tar.gz /opt/appdata/

# Back up the HomelabARR state volume
docker run --rm -v homelabarr-data:/data -v $(pwd):/backup \
  alpine tar czf /backup/homelabarr-state.tar.gz /data
```

### How do I update HomelabARR?

```bash
# Pull latest images
docker compose -f homelabarr.yml pull

# Restart with new images
docker compose -f homelabarr.yml up -d
```

Your data and configuration persist across updates.

---

## Custom Apps

### How do I add my own app templates?

Create a Docker Compose YAML file in `apps/myapps/`:

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

The app appears in the **My Apps** category after a dashboard refresh.

---

## Getting Help

- **Discord**: [discord.gg/Pc7mXX786x](https://discord.gg/Pc7mXX786x)
- **GitHub Issues**: [Report a bug](https://github.com/smashingtags/homelabarr-ce/issues)
- **GitHub Discussions**: [Ask a question](https://github.com/smashingtags/homelabarr-ce/discussions)
