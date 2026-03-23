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

!!! warning "Back up your .env first"
    The migrator rewrites your `.env` from a template. It preserves the standard variables listed below, but **any custom variables you added manually will be dropped**. Back up your original `.env` before running.

This reads `/opt/appdata/compose/.env` and rewrites it with CE-compatible defaults while preserving these standard values:

- Cloudflare credentials (email, API key, Zone ID)
- Domain configuration
- Plex claim tokens
- VPN settings (Gluetun/WireGuard)
- Container image preferences
- Port configurations
- API keys (IMDB, TVDB, TMDB)

If you have custom environment variables not in this list, copy them from your backup after running the migrator.

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

!!! tip "Put CE behind Traefik too"
    If you already have Traefik running, add a route for the CE dashboard so it's accessible at `https://homelabarr.yourdomain.com` with Authelia protection. Create a file at `/opt/appdata/traefik/rules/homelabarr-ce.yml`:
    ```yaml
    http:
      routers:
        homelabarr-ce:
          rule: "Host(`homelabarr.yourdomain.com`)"
          entryPoints:
            - https
          middlewares:
            - chain-authelia@file
          tls:
            certResolver: dns-cloudflare
          service: homelabarr-ce
      services:
        homelabarr-ce:
          loadBalancer:
            servers:
              - url: "http://homelabarr-ce-frontend:8080"
    ```
    Add a CNAME record in Cloudflare for `homelabarr` pointing to your domain. The CE frontend container must be on the `proxy` network.

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

!!! warning "Fix Traefik's Docker network setting"
    Your existing Traefik may be configured to discover containers on the wrong Docker network. CE deploys containers with labels on the `proxy` network. If Traefik is set to `--providers.docker.network=traefik` (common in older setups), it will ignore all CE-deployed container labels.

    Check your Traefik config:
    ```bash
    docker inspect traefik --format '{{json .Args}}' | grep docker.network
    ```

    If it says `docker.network=traefik`, you need to recreate Traefik with `--providers.docker.network=proxy` instead. This is a one-time fix — after this, every container CE deploys with Traefik mode will be discovered automatically via Docker labels. No manual file-based routes needed.

!!! tip "Keep Authelia"
    Your existing Authelia works with CE out of the box. Don't redeploy it.

---

## Migrating from PGBlitz / PTS / PlexGuide

If you're running PGBlitz, PTS (MHA-Team fork), or the original PlexGuide — your setup is older but the migration is straightforward. Your Plex libraries, Sonarr configs, and all your app data will survive the move.

!!! tip "Your data is safe"
    PGBlitz/PTS stores everything in `/opt/appdata/` — the same path HomelabARR CE uses. Your Plex database, Sonarr series, Radarr movies — all of it carries over untouched.

### What's Different

| | PGBlitz/PTS | HomelabARR CE |
|---|---|---|
| **Deployment** | Ansible playbooks | Docker Compose or Web GUI |
| **Docker network** | `plexguide` | `proxy` |
| **Traefik** | v1 (frontend/backend rules) | v2/v3 (routers/services) |
| **Media storage** | Cloud (Google Drive + rclone + mergerfs) | Local NAS (recommended) or cloud |
| **App data** | `/opt/appdata/` | `/opt/appdata/` (same) |
| **Volume driver** | None (Ansible direct mounts) | Docker native bind mounts |
| **Maintenance** | Abandoned (last updated 2021) | Actively maintained |

### Step-by-Step Migration

#### 1. Backup your configs

```bash
# Backup your rclone config (you may need this later)
cp ~/.config/rclone/rclone.conf ~/rclone.conf.backup

# Backup all app data
sudo tar czf ~/pgblitz-appdata-backup-$(date +%Y%m%d).tar.gz /opt/appdata/
```

#### 2. Document your current setup

Before changing anything, note what you're running:

```bash
# List all running containers
docker ps --format "{{.Names}}\t{{.Image}}\t{{.Ports}}" > ~/my-containers.txt
cat ~/my-containers.txt
```

Save this list — you'll use it to know what to redeploy.

#### 3. Decide: keep cloud storage or go local?

**If you're keeping cloud storage (Google Drive + rclone):**
Your rclone mounts at `/mnt/unionfs` or `/mnt` will continue working. CE's app templates mount `/mnt` the same way. Skip to Step 4.

**If you're moving to local NAS (recommended):**
See the [Cloud to Local Migration](#migrating-from-cloud-based-setups) section below for how to download your media and set up NAS mounts. Do this BEFORE proceeding.

#### 4. Install HomelabARR CE

```bash
# One-line install
sudo wget -qO- https://raw.githubusercontent.com/smashingtags/homelabarr-ce/main/install-remote.sh | sudo bash

# Or Docker Compose for the web GUI
curl -o homelabarr.yml https://raw.githubusercontent.com/smashingtags/homelabarr-ce/main/homelabarr.yml
export JWT_SECRET=$(openssl rand -base64 32)
export DOCKER_GID=$(getent group docker | cut -d: -f3)
export CORS_ORIGIN=http://$(hostname -I | awk '{print $1}'):8084
docker compose -f homelabarr.yml up -d
```

#### 5. Create the proxy network

PGBlitz uses `plexguide` network. CE uses `proxy`. Create it:

```bash
docker network create proxy 2>/dev/null || true
```

#### 6. Redeploy apps one at a time

For each app in your `my-containers.txt` list, stop the old container and redeploy through CE:

```bash
# Example: migrate Sonarr
docker stop sonarr && docker rm sonarr

# Redeploy via CE web GUI (http://your-ip:8084) or CLI
sudo homelabarr-cli -i
# → Option 2 → Install Apps → mediamanager → sonarr
```

The new Sonarr container will:
- Mount your existing `/opt/appdata/sonarr` config (series, settings, history — all preserved)
- Mount `/mnt` for media access
- Use Traefik v2/v3 labels (if you set up Traefik)
- Work with the `proxy` network

!!! warning "Do one app at a time"
    Don't stop everything at once. Migrate one container, verify it works, then move to the next. Start with something non-critical like Tautulli or NZBGet.

#### 7. Handle Traefik

PGBlitz uses Traefik v1. CE uses Traefik v2/v3. You have two options:

**Option A: Fresh Traefik (recommended)**
Stop the old Traefik and let CE deploy a new one:
```bash
docker stop traefik && docker rm traefik
# Via CLI: Option 1 → Traefik + Authelia
```

**Option B: Keep existing Traefik**
If you've customized your Traefik v1 setup and don't want to change it, you can keep it — but CE's app templates use v2 labels which won't work with Traefik v1. You'd need to add v1 labels manually to each container.

#### 8. Verify Plex

This is the one everyone worries about. After redeploying Plex through CE:

1. Open Plex Web (your existing URL or `http://your-ip:32400/web`)
2. Check Settings → Libraries — all libraries should be listed
3. Play something — verify transcoding works
4. Check Settings → Server → General — your Plex claim token and server name should be intact

Your Plex database, watch history, posters, metadata — everything lives in `/opt/appdata/plex` and was never touched during the migration.

#### 9. Clean up PGBlitz/PTS

Once everything is verified through CE:

```bash
# Remove old PGBlitz/PTS installation
sudo rm -rf /opt/plexguide 2>/dev/null
sudo rm -rf /opt/pgblitz 2>/dev/null
sudo rm -rf /opt/pts 2>/dev/null
sudo rm -rf /opt/coreapps 2>/dev/null
sudo rm -rf /opt/communityapps 2>/dev/null

# Remove old plexguide network (after all containers are on proxy)
docker network rm plexguide 2>/dev/null

# Remove old cron jobs
crontab -l | grep -v "plexguide\|pgblitz\|pts" | crontab -

# Clean up old images
docker image prune -a
```

!!! tip "Keep your rclone config"
    Even if you moved to local NAS, keep `~/rclone.conf.backup` — you might need it to download remaining files from Google Drive later.

---

## Migrating from Saltbox

[Saltbox](https://github.com/saltyorg/Saltbox) is the actively maintained successor to Cloudbox. It's a solid platform, but it's Ansible-based with no GUI — every change requires editing YAML files and running playbooks. If you want a web dashboard to manage your containers or you're tired of Ansible complexity, CE is a straightforward alternative.

!!! info "Saltbox is still maintained"
    Unlike Cloudbox and PGBlitz, Saltbox is actively developed. This migration is for users who **want** to switch to a simpler, GUI-based approach — not because Saltbox is abandoned.

### What's Different

| | Saltbox | HomelabARR CE |
|---|---|---|
| **Deployment** | Ansible playbooks | Docker Compose or Web GUI |
| **Configuration** | YAML files + CLI commands | Web GUI or interactive CLI menu |
| **Docker network** | `saltbox` | `proxy` |
| **App data path** | `/opt/<app>/` | `/opt/appdata/<app>/` |
| **Media path** | `/mnt/unionfs/` | `/mnt/` (configurable) |
| **Traefik** | v3.6 | v2/v3 |
| **Cloud storage** | rclone + Google Drive (default) | Local NAS (recommended), cloud optional |
| **GUI** | None — CLI and text editors only | Web dashboard with 157+ apps |
| **Multiple instances** | Built-in (sonarr, sonarr4k, etc.) | Deploy multiple containers manually |

### Step-by-Step Migration

#### 1. Backup your Saltbox

```bash
# Use Saltbox's own backup
cd ~/saltbox && sudo ansible-playbook backup.yml

# Also backup manually
cp ~/saltbox/accounts.yml ~/accounts.yml.backup
cp -r /opt/saltbox ~/saltbox-opt-backup
sudo tar czf ~/saltbox-appdata-$(date +%Y%m%d).tar.gz /opt/
```

#### 2. Move app data to CE's path

Saltbox stores configs at `/opt/<app>/`. CE expects `/opt/appdata/<app>/`:

```bash
sudo mkdir -p /opt/appdata

# Move each app's config
for app in sonarr radarr lidarr readarr prowlarr bazarr plex jellyfin tautulli nzbget sabnzbd qbittorrent overseerr; do
  if [ -d "/opt/$app" ]; then
    sudo mv /opt/$app /opt/appdata/$app
    echo "Moved $app"
  fi
done

sudo chown -R 1000:1000 /opt/appdata
```

!!! warning "Multiple instances"
    If you run multiple Sonarr/Radarr instances (e.g., `sonarr`, `sonarr4k`), move each one separately. CE treats them as independent containers.

#### 3. Handle media paths

Saltbox uses `/mnt/unionfs/` for combined local + cloud media. If you're keeping this mount structure, create a symlink:

```bash
# If /mnt/unionfs already exists and has your media
sudo ln -sf /mnt/unionfs /mnt/media 2>/dev/null || true
```

If moving to local NAS, see the [Cloud to Local Migration](#migrating-from-cloud-based-setups) section.

#### 4. Create the proxy network

```bash
docker network create proxy 2>/dev/null || true
```

#### 5. Install HomelabARR CE

```bash
# One-line CLI install
sudo wget -qO- https://raw.githubusercontent.com/smashingtags/homelabarr-ce/main/install-remote.sh | sudo bash
sudo homelabarr-cli -i

# Or Docker Compose for web GUI
curl -o homelabarr.yml https://raw.githubusercontent.com/smashingtags/homelabarr-ce/main/homelabarr.yml
export JWT_SECRET=$(openssl rand -base64 32)
export DOCKER_GID=$(getent group docker | cut -d: -f3)
export CORS_ORIGIN=http://$(hostname -I | awk '{print $1}'):8084
docker compose -f homelabarr.yml up -d
```

#### 6. Redeploy apps one at a time

For each app, stop the Saltbox container and redeploy through CE:

```bash
# Example: migrate Sonarr
docker stop sonarr && docker rm sonarr

# Redeploy via CE web GUI or CLI
# Your existing /opt/appdata/sonarr config is picked up automatically
```

!!! tip "Keep Traefik if it's working"
    Saltbox uses Traefik v3.6 which is modern and compatible. If your Traefik and Authelia are working, leave them running. CE's app templates use v2/v3 labels that work with your existing Traefik.

#### 7. Update root folders in media apps

After redeploying, check the media root folders in each app. Saltbox maps internal paths differently:

| App | Saltbox internal path | Check in app settings |
|-----|----------------------|----------------------|
| Sonarr | `/tv/` | Settings → Media Management → Root Folders |
| Radarr | `/movies/` | Settings → Media Management → Root Folders |
| Plex | `/data/TV/`, `/data/Movies/` | Settings → Libraries |

The paths inside the container may differ from Saltbox's mapping. Update them to match CE's volume mounts if needed.

#### 8. Clean up Saltbox (optional)

If you're fully committed to CE:

```bash
# Remove Saltbox installation
sudo rm -rf ~/saltbox 2>/dev/null
sudo rm -rf /opt/saltbox 2>/dev/null
sudo rm -rf /srv/git/saltbox 2>/dev/null

# Remove Ansible (if nothing else uses it)
sudo apt remove ansible -y 2>/dev/null

# Remove old network (after all containers are on proxy)
docker network rm saltbox 2>/dev/null

# Clean up
docker image prune -a
```

!!! tip "Keep your rclone config"
    Saltbox's rclone configuration lives at `~/.config/rclone/rclone.conf`. Keep a backup even if you're moving to local storage.

---

## Migrating from Cloudbox

[Cloudbox](https://github.com/Cloudbox/Cloudbox) was one of the most popular Ansible-based media server solutions. The project was **archived in March 2025** and is no longer maintained. If you're still running it, migrating to HomelabARR CE gives you a modern, actively maintained platform with a web GUI.

!!! tip "Your Plex database and app configs carry over"
    Cloudbox stores app data in `/opt/` (e.g., `/opt/sonarr`, `/opt/plex`). HomelabARR CE uses `/opt/appdata/`. You'll move your configs once and everything works.

### What's Different

| | Cloudbox | HomelabARR CE |
|---|---|---|
| **Status** | Archived, unmaintained since 2025 | Actively maintained |
| **Deployment** | Ansible playbooks | Docker Compose or Web GUI |
| **Docker network** | `cloudbox` | `proxy` |
| **App data path** | `/opt/<app>/` | `/opt/appdata/<app>/` |
| **Media path** | `/mnt/unionfs/Media/` | `/mnt/` (configurable) |
| **Cloud storage** | rclone + mergerfs (required) | Local NAS (recommended), cloud optional |
| **Traefik** | v1 | v2/v3 |
| **Install types** | Cloudbox / Mediabox / Feederbox | One install, choose what to deploy |

### Step-by-Step Migration

#### 1. Backup everything

```bash
# Backup rclone config
cp ~/.config/rclone/rclone.conf ~/rclone.conf.backup

# Backup Cloudbox settings
cp ~/cloudbox/accounts.yml ~/accounts.yml.backup

# Backup all app data
sudo tar czf ~/cloudbox-backup-$(date +%Y%m%d).tar.gz /opt/
```

#### 2. Move app data to CE's expected path

Cloudbox stores configs at `/opt/<app>/` (e.g., `/opt/sonarr/`). CE expects `/opt/appdata/<app>/`. Create the new structure and move:

```bash
sudo mkdir -p /opt/appdata

# Move each app's config
for app in plex sonarr radarr lidarr tautulli jackett nzbget sabnzbd ombi; do
  if [ -d "/opt/$app" ]; then
    sudo mv /opt/$app /opt/appdata/$app
    echo "Moved $app"
  fi
done

sudo chown -R 1000:1000 /opt/appdata
```

!!! warning "Plex path"
    Cloudbox stores Plex at `/opt/plex/`. After moving to `/opt/appdata/plex/`, the Plex database, metadata, and libraries are all intact. The container mounts this as `/config` regardless of where it lives on the host.

#### 3. Handle media paths

Cloudbox uses a specific media structure:
```
/mnt/unionfs/Media/Movies/
/mnt/unionfs/Media/TV/
/mnt/unionfs/Media/Music/
```

CE mounts `/mnt` directly. If your media is at `/mnt/unionfs/Media/`, you have two options:

**Option A: Symlink (quickest)**
```bash
# If your media is still at /mnt/unionfs/Media
sudo ln -sf /mnt/unionfs/Media /mnt/Media
```

**Option B: Move to local NAS (recommended)**
See the [Cloud to Local Migration](#migrating-from-cloud-based-setups) section below. Point your NAS mount at `/mnt` and organize as you like.

#### 4. Create the proxy network

```bash
docker network create proxy 2>/dev/null || true
```

#### 5. Install HomelabARR CE

```bash
# One-line CLI install
sudo wget -qO- https://raw.githubusercontent.com/smashingtags/homelabarr-ce/main/install-remote.sh | sudo bash
sudo homelabarr-cli -i

# Or Docker Compose for web GUI
curl -o homelabarr.yml https://raw.githubusercontent.com/smashingtags/homelabarr-ce/main/homelabarr.yml
export JWT_SECRET=$(openssl rand -base64 32)
export DOCKER_GID=$(getent group docker | cut -d: -f3)
export CORS_ORIGIN=http://$(hostname -I | awk '{print $1}'):8084
docker compose -f homelabarr.yml up -d
```

#### 6. Redeploy apps one at a time

```bash
# Stop old Cloudbox container
docker stop sonarr && docker rm sonarr

# Redeploy through CE (web GUI or CLI)
# The new container mounts /opt/appdata/sonarr:/config — your existing data
```

After redeploying each media app, update the media root folders:

| App | Cloudbox path | CE path |
|-----|--------------|---------|
| Sonarr | `/tv/` → `/mnt/unionfs/Media/TV/` | `/mnt/Media/TV/` (or wherever your media lives) |
| Radarr | `/movies/` → `/mnt/unionfs/Media/Movies/` | `/mnt/Media/Movies/` |
| Plex | `/data/Movies/`, `/data/TV/` | Libraries point to `/mnt/Media/` subdirectories |

#### 7. Clean up Cloudbox

```bash
# Remove Cloudbox installation
sudo rm -rf ~/cloudbox 2>/dev/null
sudo rm -rf /opt/cloudbox 2>/dev/null

# Remove old network
docker network rm cloudbox 2>/dev/null

# Remove old Ansible
sudo apt remove ansible -y 2>/dev/null

# Clean up old images
docker image prune -a
```

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
