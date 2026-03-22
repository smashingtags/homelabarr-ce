# Backup

HomelabARR CE includes `backup.sh` for backing up all container application data. Regular backups are the difference between a minor inconvenience and starting from scratch.

## What Gets Backed Up

The backup script targets `/opt/appdata` — the directory where all container configs, databases, and application state are stored. Each app gets its own compressed archive.

!!! note
    The script skips Traefik (`trae`), Authelia (`auth`), and Cloudflare (`cf`) containers during backup. Back those up separately (see below).

## Running a Backup

```bash
sudo ./backup.sh
```

The script:

1. Prunes unused Docker images to free space
2. Pulls the latest `ghcr.io/smashingtags/homelabarr-backup` image
3. Iterates through all running containers (except Traefik/Authelia/cf-companion)
4. Creates a `.tar.gz` archive per container in `/mnt/downloads/appbackups/local/`
5. Sets ownership to `1000:1000` on each archive
6. Prunes Docker images again after completion

### Backup Output

Each container gets its own archive:

```
/mnt/downloads/appbackups/local/sonarr.tar.gz
/mnt/downloads/appbackups/local/radarr.tar.gz
/mnt/downloads/appbackups/local/plex.tar.gz
...
```

## What to Back Up Manually

The backup script covers appdata, but you should also preserve:

### Environment Config

```bash
cp .env .env.backup
cp apps/.config/.env apps/.config/.env.backup
```

These contain your domain, Cloudflare credentials, and all deployment variables. Losing these means reconfiguring everything.

### Traefik Config

```bash
tar czf traefik-backup.tar.gz /opt/appdata/traefik/
```

Key files:
- `/opt/appdata/traefik/rules/` — middleware definitions
- `/opt/appdata/traefik/acme/acme.json` — SSL certificates
- `/opt/appdata/traefik/traefik.log` — logs (optional)

### Authelia Config

```bash
tar czf authelia-backup.tar.gz /opt/appdata/authelia/
```

Key files:
- `/opt/appdata/authelia/configuration.yml` — Authelia settings
- `/opt/appdata/authelia/users_database.yml` — user accounts and hashed passwords

!!! warning
    If you lose `users_database.yml`, you'll need to recreate all user accounts and passwords.

### Docker Volumes

Some containers use named Docker volumes instead of bind mounts. List them:

```bash
docker volume ls
```

Back up a specific volume:

```bash
docker run --rm -v volume_name:/data -v /opt/backup:/backup alpine \
  tar czf /backup/volume_name.tar.gz -C /data .
```

## Recommended Strategy

| Frequency | What | How |
|-----------|------|-----|
| Daily | Appdata (`backup.sh`) | Cron job or manual |
| Weekly | Full system snapshot | Proxmox PBS, VM snapshot, or disk image |
| After changes | `.env` files, Traefik/Authelia configs | Manual copy |
| Monthly | Off-site copy | rsync to remote server or cloud storage |

### Automating with Cron

```bash
# Run backup daily at 3 AM
sudo crontab -e
# Add:
0 3 * * * /path/to/homelabarr-ce/backup.sh >> /var/log/homelabarr-backup.log 2>&1
```

!!! tip "Proxmox Users"
    If HomelabARR CE runs in a Proxmox VM or LXC, use Proxmox Backup Server (PBS) for automated VM-level snapshots. This gives you bare-metal recovery in addition to app-level backups.

## Verifying Backups

Periodically verify your backups are usable:

```bash
# List contents of a backup archive
tar tzf /mnt/downloads/appbackups/local/sonarr.tar.gz | head -20

# Test extraction to a temp directory
mkdir /tmp/backup-test
tar xzf /mnt/downloads/appbackups/local/sonarr.tar.gz -C /tmp/backup-test
ls /tmp/backup-test
rm -rf /tmp/backup-test
```

## Support

Kindly report any issues/broken-parts/bugs on [github](https://github.com/smashingtags/homelabarr-ce/issues) or [discord](https://discord.gg/Pc7mXX786x)

- Join our [![Discord: https://discord.gg/Pc7mXX786x](https://img.shields.io/badge/Discord-gray.svg?style=for-the-badge)](https://discord.gg/Pc7mXX786x) for Support
