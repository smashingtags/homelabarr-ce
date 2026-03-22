<p align="left">
    <a href="https://discord.gg/Pc7mXX786x">
        <img src="https://discord.com/api/guilds/1334411584927301682/widget.png?label=Discord%20Server&logo=discord" alt="Join HomelabARR CE on Discord">
    </a>
        <a href="https://github.com/smashingtags/homelabarr-ce/releases">
        <img src="https://img.shields.io/github/downloads/smashingtags/homelabarr-ce/total?label=Total%20Downloads&logo=github" alt="Total Releases Downloaded from GitHub">
    </a>
    <a href="https://github.com/smashingtags/homelabarr-ce/releases/latest">
        <img src="https://img.shields.io/github/v/release/smashingtags/homelabarr-ce?include_prereleases&label=Latest%20Release&logo=github" alt="Latest Official Release on GitHub">
    </a>
    <a href="https://github.com/smashingtags/homelabarr-ce/blob/main/LICENSE">
        <img src="https://img.shields.io/github/license/smashingtags/homelabarr-ce?label=License&logo=mit" alt="MIT License">
    </a>
</p>

# Migration Guide

This guide covers migrating to HomelabARR CE from other Docker management platforms.

---

## Migrating from Similar Docker Platforms

If your existing setup uses `/opt/appdata/` for container data and a `proxy` Docker network with Traefik, the migration is straightforward — HomelabARR CE uses the same structure.

!!! tip "Same appdata? You're 90% done."
    If your containers store data in `/opt/appdata/`, HomelabARR CE picks it up automatically. Your Plex databases, Sonarr configs, Radarr settings — all preserved.

### Step 1: Backup Everything

Before making any changes:

```bash
# Backup your current .env file
cp /opt/appdata/compose/.env /opt/appdata/compose/.env.backup

# Backup your appdata (compress, this may take a while)
sudo tar czf /opt/homelabarr-backup-$(date +%Y%m%d).tar.gz /opt/appdata/

# Note your running containers
docker ps --format "{{.Names}}" > /opt/running-containers.txt
```

### Step 2: Stop Existing Containers

```bash
# Stop all running containers (your data in /opt/appdata is safe)
docker stop $(docker ps -q)
```

!!! warning "Don't remove containers yet"
    Stopping is enough. Don't `docker rm` anything until you've verified CE works.

### Step 3: Migrate Environment Variables

HomelabARR CE includes a migration tool that converts your existing `.env`:

```bash
git clone https://github.com/smashingtags/homelabarr-ce.git
cd homelabarr-ce
sudo ln -sf "$(pwd)" /opt/homelabarr

# Run the environment migrator
bash apps/.subactions/envmigrate.sh
```

This reads `/opt/appdata/compose/.env` and rewrites it with CE-compatible defaults while **preserving all your existing values**:

- Cloudflare credentials (email, API key, Zone ID)
- Domain configuration
- Plex claim tokens
- VPN settings (Gluetun/WireGuard)
- Container image preferences
- Port configurations
- API keys (IMDB, TVDB, TMDB)
- All custom environment variables

### Step 4: Install HomelabARR CE

You have two options:

**Option A: Web GUI (Docker Compose)**

```bash
curl -o homelabarr.yml https://raw.githubusercontent.com/smashingtags/homelabarr-ce/main/homelabarr.yml
export JWT_SECRET=$(openssl rand -base64 32)
export DOCKER_GID=$(getent group docker | cut -d: -f3)
export CORS_ORIGIN=http://$(hostname -I | awk '{print $1}'):8084
docker compose -f homelabarr.yml up -d
```

Open `http://your-server-ip:8084` — you'll see the CE dashboard with 157+ apps ready to deploy. Your existing `/opt/appdata` data is already there.

**Option B: CLI Menu**

```bash
chmod +x install.sh
find . -name "*.sh" -exec chmod +x {} \;
sudo ./install.sh
```

The interactive menu lets you:

- **Option 1:** Set up Traefik + Authelia (if not already running)
- **Option 2:** Install/Remove/Backup/Restore apps via the terminal menu

### Step 5: Redeploy Your Apps (One at a Time)

Your app **data** is already in `/opt/appdata`. You need to stop each old container and redeploy it through CE. Do this **one app at a time** — not all at once.

!!! warning "Why one at a time?"
    If you stop everything and something goes wrong during redeployment, you've lost all your services. Doing it one at a time means you can roll back a single container if needed.

For each app (e.g., Sonarr):

```bash
# 1. Stop and remove the OLD container
docker stop sonarr && docker rm sonarr

# 2. Redeploy through CE
#    Via Web GUI: Browse catalog → find Sonarr → Deploy (Standard mode)
#    Via CLI: Option 2 → Install Apps → mediamanager → sonarr

# 3. Verify it starts and loads your existing config
docker logs sonarr --tail 20
```

The new container will mount `/opt/appdata/sonarr` (your existing config) and `/mnt` (your media) using Docker's native bind mounts — no plugins needed.

!!! info "What changed under the hood"
    Your old containers used a `local-persist` Docker volume plugin to map `/mnt`. HomelabARR CE uses Docker's built-in `local` driver with bind mounts instead. Same result, zero plugin dependencies. Your data and paths are unchanged.

**Suggested order:**

1. Non-critical apps first (Tautulli, Heimdall, Dozzle)
2. Download clients (NZBGet, qBittorrent, SABnzbd)
3. Media managers (Sonarr, Radarr, Lidarr, Prowlarr)
4. Media servers (Jellyfin, Plex — these have the biggest configs)

After each app, verify:

- **Sonarr/Radarr:** Series/movies listed in Mass Editor
- **qBittorrent:** Torrents resume, download path is correct
- **Jellyfin/Plex:** Libraries intact, playback works
- **Authelia:** Users and 2FA preserved (`/opt/appdata/authelia/`)

### Step 6: Clean Up Legacy Components

Once all apps are redeployed through CE:

```bash
# Stop the old mount container (it's been failing anyway if you're not using cloud storage)
docker stop mount && docker rm mount

# Stop restic and vnstat if you no longer need them
docker stop restic vnstat && docker rm restic vnstat

# Remove the old local-persist volume (data is safe — it just pointed at /mnt)
docker volume rm compose_unionfs 2>/dev/null

# Remove the local-persist plugin/binary
sudo rm /usr/bin/docker-volume-local-persist 2>/dev/null
sudo rm /run/docker/plugins/local-persist.sock 2>/dev/null

# Clean up old images
docker image prune -a

# Remove your backup if everything works (or keep it!)
# rm /opt/homelabarr-backup-*.tar.gz
```

!!! tip "Keep Traefik and Authelia"
    If your Traefik and Authelia are working, **don't redeploy them**. They don't use `local-persist` and CE doesn't need to manage them. Leave them running.

---

## Migrating from Cloud-Based Setups

If you're moving from a cloud-dependent system (Google Drive mounts, rclone cloud storage) to local NAS storage:

### Prerequisites

- **NAS System**: UnRAID, TrueNAS, Synology, or local drives
- **Network Share**: SMB or NFS configured
- **Storage**: Enough space for your media library

### Download Media from Cloud

Before switching, get your media local:

```bash
# Example: rclone sync from Google Drive to local NAS
rclone sync gdrive:media /mnt/nas/media --progress --transfers 8
```

### Set Up Local Storage

```bash
# Create mount points for NAS shares
sudo mkdir -p /mnt/nas/{media,downloads,appdata}

# Mount via SMB
sudo mount -t cifs //nas.local/media /mnt/nas/media -o uid=1000,gid=1000,username=user,password=pass

# Or mount via NFS
sudo mount -t nfs nas.local:/volume1/media /mnt/nas/media
```

Add to `/etc/fstab` for persistence:

```
//nas.local/media  /mnt/nas/media  cifs  uid=1000,gid=1000,username=user,password=pass,_netdev  0  0
```

### Update Application Paths

After installing CE and redeploying apps, update media paths:

| App | Setting | Old Path | New Path |
|-----|---------|----------|----------|
| Plex | Library locations | `/mnt/unionfs/media/movies` | `/mnt/nas/media/movies` |
| Sonarr | Root folder | `/mnt/unionfs/media/tv` | `/mnt/nas/media/tv` |
| Radarr | Root folder | `/mnt/unionfs/media/movies` | `/mnt/nas/media/movies` |
| qBittorrent | Save path | `/mnt/unionfs/downloads` | `/mnt/nas/downloads` |
| SABnzbd | Complete folder | `/mnt/unionfs/downloads/complete` | `/mnt/nas/downloads/complete` |

### Benefits of Local Storage

- **No API rate limits** — process unlimited files simultaneously
- **No cloud subscription costs** — your storage, your hardware
- **Better performance** — local I/O is faster than cloud transfers
- **Privacy** — data stays on your network
- **Simpler setup** — no rclone configs, mount scripts, or cloud auth

---

## Compatibility Reference

HomelabARR CE is compatible with setups that use:

| Component | Expected Path/Value |
|-----------|-------------------|
| App data | `/opt/appdata/` |
| Compose .env | `/opt/appdata/compose/.env` |
| Docker network | `proxy` |
| Reverse proxy | Traefik v2/v3 |
| Authentication | Authelia |
| SSL | Let's Encrypt via Cloudflare DNS challenge |
| User/Group ID | 1000:1000 |

If your existing setup matches these conventions, the migration is essentially a drop-in replacement.

---

## Support

Having trouble migrating?

- **[Discord](https://discord.gg/Pc7mXX786x)** — Ask in the #support channel
- **[GitHub Issues](https://github.com/smashingtags/homelabarr-ce/issues)** — Report migration bugs
- **Email** — michael@mjashley.com
