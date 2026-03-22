# Restore

This guide covers restoring HomelabARR CE containers from backups created by `backup.sh` or manual archives.

## Before You Start

Make sure you have:

- A working Docker installation
- The HomelabARR CE repo cloned
- Your `.env` file (or a backup copy of it)
- Your backup archives from `/mnt/downloads/appbackups/local/`

!!! warning
    Stop any running containers for the apps you're restoring before overwriting their data. Running containers with changing data underneath them can cause corruption.

## Restoring Appdata

### Step 1: Stop Containers

```bash
# Stop all containers
docker stop $(docker ps -q)

# Or stop a specific app
docker stop sonarr
```

### Step 2: Extract Backup Archives

The backup archives contain appdata directories. Extract them back to `/opt/appdata`:

```bash
# Restore a single app
tar xzf /mnt/downloads/appbackups/local/sonarr.tar.gz -C /opt/appdata

# Restore all apps
for archive in /mnt/downloads/appbackups/local/*.tar.gz; do
  tar xzf "$archive" -C /opt/appdata
done
```

### Step 3: Fix Permissions

```bash
chown -R 1000:1000 /opt/appdata
```

This matches the default `ID=1000` in the `.env` file. If you use a different UID/GID, adjust accordingly.

!!! tip
    Some apps (like Plex) create internal files with specific ownership. If an app won't start after restore, check its logs for permission errors and adjust with `chown -R 1000:1000 /opt/appdata/appname`.

## Restoring Environment Config

Copy your backed-up `.env` files into place:

```bash
cp .env.backup .env
cp apps/.config/.env.backup apps/.config/.env
```

If you don't have a backup of your `.env`, copy the example and reconfigure:

```bash
cp apps/.config/.env.example apps/.config/.env
# Edit with your settings: DOMAIN, CLOUDFLARE_EMAIL, TZ, etc.
```

## Restoring Traefik and Authelia

### Traefik

```bash
# If you have a Traefik backup archive
tar xzf traefik-backup.tar.gz -C /

# Fix acme.json permissions (required by Traefik)
chmod 600 /opt/appdata/traefik/acme/acme.json
```

!!! note
    If you don't have a Traefik backup, re-run `./install.sh` (Option 1) to redeploy Traefik. It will request new SSL certificates automatically.

### Authelia

```bash
tar xzf authelia-backup.tar.gz -C /
```

Key files to verify after restore:

- `/opt/appdata/authelia/configuration.yml` — must reference your domain
- `/opt/appdata/authelia/users_database.yml` — contains user accounts

If `users_database.yml` is missing, Authelia won't have any users. You'll need to recreate it from the template in `traefik/templates/authelia/users_database.yml` and set new passwords.

## Restoring Docker Volumes

If you backed up named Docker volumes:

```bash
# Recreate the volume
docker volume create volume_name

# Restore data into it
docker run --rm -v volume_name:/data -v /opt/backup:/backup alpine \
  sh -c "tar xzf /backup/volume_name.tar.gz -C /data"
```

## Re-deploying Containers

After restoring data, redeploy your containers. They'll pick up the existing configs from `/opt/appdata`.

### Full Mode (Traefik)

```bash
# Redeploy infrastructure first
./install.sh
# Select Option 1 (Traefik + Authelia)

# Then redeploy apps
./homelabarr-cli.sh
# Select each app to redeploy
```

### Local Mode

```bash
./homelabarr-cli.sh
# Select apps to redeploy — they'll find their existing data in /opt/appdata
```

!!! tip
    Containers are stateless by design. The app data lives in `/opt/appdata`. Redeploying a container with the same volume mounts picks up right where you left off.

## Post-Restore Checklist

After restoring, verify everything works:

```bash
# Check all containers are running
docker ps

# Check for containers in restart loops
docker ps -a --filter "status=restarting"

# Check logs for errors
docker logs sonarr 2>&1 | tail -20
docker logs radarr 2>&1 | tail -20
docker logs traefik 2>&1 | tail -20
```

### Things to Verify

- [ ] All containers are running (`docker ps`)
- [ ] No containers in crash loops (`docker ps -a --filter "status=restarting"`)
- [ ] Apps are accessible (via IP:port for Local Mode, via domain for Full Mode)
- [ ] Traefik dashboard loads at `https://traefik.yourdomain.com` (Full Mode)
- [ ] Authelia login works (Full Mode)
- [ ] Media libraries are intact in Plex/Jellyfin
- [ ] Download clients have their configs (categories, paths, connections)
- [ ] *arr apps have their indexers, download client connections, and media libraries

!!! warning
    If an app shows a blank setup wizard after restore, its config directory wasn't restored correctly. Check that the files exist in `/opt/appdata/appname/` and permissions are `1000:1000`.

## Support

Kindly report any issues/broken-parts/bugs on [github](https://github.com/smashingtags/homelabarr-ce/issues) or [discord](https://discord.gg/Pc7mXX786x)

- Join our [![Discord: https://discord.gg/Pc7mXX786x](https://img.shields.io/badge/Discord-gray.svg?style=for-the-badge)](https://discord.gg/Pc7mXX786x) for Support
