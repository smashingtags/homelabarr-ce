# Maintenance Scripts

HomelabARR CLI includes various maintenance scripts to keep your system running smoothly and efficiently.

## Docker Maintenance

### Docker System Cleanup

#### `scripts/docker/dockerprune.sh`
**Purpose**: Clean up unused Docker resources to free disk space

```bash
# Run Docker cleanup
sudo ./scripts/docker/dockerprune.sh
```

**What it cleans:**
- Stopped containers
- Unused networks
- Dangling images
- Build cache
- Unused volumes (with confirmation)

**Output example:**
```
Deleted Containers:
af1234567890
bc2345678901

Deleted Networks:
network1
network2

Total reclaimed space: 2.5GB
```

**Safety features:**
- Confirms before removing volumes
- Preserves running containers
- Maintains active networks
- Shows space reclaimed

#### Manual Docker Cleanup
```bash
# Remove stopped containers
docker container prune -f

# Remove unused images
docker image prune -a -f

# Remove unused networks
docker network prune -f

# Remove unused volumes (CAUTION!)
docker volume prune -f

# Complete system cleanup
docker system prune -a --volumes -f
```

## Disk Space Management

### Disk Cleanup Script

#### `scripts/disk_cleanup.sh`
**Purpose**: Free up disk space by cleaning various system areas

```bash
# Run disk cleanup
sudo ./scripts/disk_cleanup.sh
```

**Cleanup areas:**
- Package manager cache (apt/yum)
- Log files older than 30 days
- Temporary files
- Docker resources
- Old kernels (Ubuntu/Debian)
- Trash/recycle bin

**Before cleanup check:**
```bash
# Check disk usage before cleanup
df -h
du -sh /opt/appdata/*
du -sh /var/log/*
```

**Safe cleanup commands:**
```bash
# Clean package cache
sudo apt clean
sudo apt autoremove

# Clean log files (older than 30 days)
sudo find /var/log -name "*.log" -type f -mtime +30 -delete
sudo journalctl --vacuum-time=30d

# Clean temporary files
sudo rm -rf /tmp/*
sudo rm -rf /var/tmp/*
```

## Application Data Maintenance

### Application Data Cleanup

#### Plex Maintenance Scripts

##### `scripts/plex/plex-empty-trash.sh`
**Purpose**: Empty Plex Media Server trash to free space

```bash
# Empty Plex trash
sudo ./scripts/plex/plex-empty-trash.sh
```

**What it does:**
- Connects to Plex API
- Empties trash for all libraries
- Reports space freed
- Logs cleanup activity

##### `scripts/plex/plex-optimize-db.sh`
**Purpose**: Optimize Plex database for better performance

```bash
# Optimize Plex database
sudo ./scripts/plex/plex-optimize-db.sh
```

**Database optimization:**
- Vacuum SQLite databases
- Reindex database tables
- Check database integrity
- Backup database before optimization

**Manual Plex maintenance:**
```bash
# Stop Plex
docker stop plex

# Backup database
cp /opt/appdata/plex/Library/Application\ Support/Plex\ Media\ Server/Plug-in\ Support/Databases/com.plexapp.plugins.library.db /opt/appdata/plex/backup/

# Optimize database
sqlite3 /opt/appdata/plex/Library/Application\ Support/Plex\ Media\ Server/Plug-in\ Support/Databases/com.plexapp.plugins.library.db "VACUUM;"

# Start Plex
docker start plex
```

### Application Log Management

#### Log Rotation
```bash
# Configure log rotation for containers
sudo tee /etc/logrotate.d/docker > /dev/null <<EOF
/var/lib/docker/containers/*/*.log {
    rotate 7
    daily
    compress
    size=1M
    missingok
    delaycompress
    copytruncate
}
EOF
```

#### Manual Log Cleanup
```bash
# View container log sizes
sudo du -sh /var/lib/docker/containers/*/*-json.log | sort -h

# Truncate large log files
sudo truncate -s 0 /var/lib/docker/containers/*/×-json.log

# Clean application logs
sudo find /opt/appdata/*/logs -name "*.log" -type f -mtime +30 -delete
```

## System Updates

### Container Updates

#### Update All Containers
```bash
#!/bin/bash
# Update all HomelabARR containers

echo "Updating all containers..."

# Pull latest images
cd /opt/homelabarr
find apps/ -name "*.yml" -exec docker-compose -f {} pull \;

# Restart containers with new images
find apps/ -name "*.yml" -exec docker-compose -f {} up -d \;

# Clean up old images
docker image prune -f

echo "Container update complete!"
```

#### Update Specific Application
```bash
#!/bin/bash
# Update specific application

APP_PATH="$1"
if [ -z "$APP_PATH" ]; then
    echo "Usage: $0 <app-path>"
    echo "Example: $0 apps/mediaserver/plex.yml"
    exit 1
fi

echo "Updating $APP_PATH..."
docker-compose -f "$APP_PATH" pull
docker-compose -f "$APP_PATH" up -d
echo "Update complete!"
```

### System Updates

#### OS Update Script
```bash
#!/bin/bash
# System update script

echo "Starting system update..."

# Update package lists
sudo apt update

# Show available updates
sudo apt list --upgradable

# Perform updates
sudo apt upgrade -y

# Clean up
sudo apt autoremove -y
sudo apt autoclean

# Update Docker if needed
curl -fsSL https://get.docker.com | sh

echo "System update complete!"
```

## Backup Maintenance

### Automated Backup Script

#### `scripts/backup/auto-backup.sh`
```bash
#!/bin/bash
# Automated backup script

BACKUP_DIR="/mnt/backup"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="homelabarr_backup_$DATE.tar.gz"

echo "Starting backup at $(date)"

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Stop containers for consistent backup
echo "Stopping containers..."
docker stop $(docker ps -q)

# Create backup
echo "Creating backup..."
tar -czf "$BACKUP_DIR/$BACKUP_FILE" \
    -C /opt appdata \
    -C /opt/homelabarr .

# Start containers
echo "Starting containers..."
docker start $(docker ps -aq)

# Verify backup
if [ -f "$BACKUP_DIR/$BACKUP_FILE" ]; then
    echo "Backup completed: $BACKUP_DIR/$BACKUP_FILE"
    echo "Backup size: $(du -h $BACKUP_DIR/$BACKUP_FILE | cut -f1)"
else
    echo "Backup failed!"
    exit 1
fi

# Clean old backups (keep last 7)
find "$BACKUP_DIR" -name "homelabarr_backup_*.tar.gz" -type f -mtime +7 -delete

echo "Backup maintenance complete at $(date)"
```

## Performance Monitoring

### System Health Check

#### `scripts/health-check.sh`
```bash
#!/bin/bash
# System health check script

echo "=== HomelabARR System Health Check ==="
echo "Date: $(date)"
echo

# Disk space
echo "--- Disk Usage ---"
df -h | grep -E '(Filesystem|/dev/)'
echo

# Memory usage
echo "--- Memory Usage ---"
free -h
echo

# Docker status
echo "--- Docker Status ---"
sudo systemctl status docker --no-pager -l
echo

# Container status
echo "--- Container Status ---"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo

# Failed containers
echo "--- Failed Containers ---"
FAILED=$(docker ps -a --filter "status=exited" --filter "status=dead" --format "{{.Names}}")
if [ -n "$FAILED" ]; then
    echo "$FAILED"
else
    echo "No failed containers"
fi
echo

# Network connectivity
echo "--- Network Connectivity ---"
ping -c 1 google.com > /dev/null && echo "Internet: OK" || echo "Internet: FAILED"
ping -c 1 8.8.8.8 > /dev/null && echo "DNS: OK" || echo "DNS: FAILED"
echo

# Load average
echo "--- System Load ---"
uptime
echo

echo "=== Health Check Complete ==="
```

## Automated Maintenance

### Cron Job Setup

#### Daily Maintenance
```bash
# Add to crontab: crontab -e

# Daily cleanup at 2 AM
0 2 * * * /opt/homelabarr/scripts/docker/dockerprune.sh >> /var/log/homelabarr-maintenance.log 2>&1

# Weekly disk cleanup on Sunday at 3 AM
0 3 * * 0 /opt/homelabarr/scripts/disk_cleanup.sh >> /var/log/homelabarr-maintenance.log 2>&1

# Weekly backup on Sunday at 4 AM
0 4 * * 0 /opt/homelabarr/scripts/backup/auto-backup.sh >> /var/log/homelabarr-backup.log 2>&1

# Daily health check at 6 AM
0 6 * * * /opt/homelabarr/scripts/health-check.sh >> /var/log/homelabarr-health.log 2>&1
```

#### Systemd Timer (Alternative)
```bash
# Create systemd service
sudo tee /etc/systemd/system/homelabarr-maintenance.service > /dev/null <<EOF
[Unit]
Description=HomelabARR Maintenance
After=docker.service

[Service]
Type=oneshot
ExecStart=/opt/homelabarr/scripts/docker/dockerprune.sh
User=root
EOF

# Create systemd timer
sudo tee /etc/systemd/system/homelabarr-maintenance.timer > /dev/null <<EOF
[Unit]
Description=Run HomelabARR maintenance daily
Requires=homelabarr-maintenance.service

[Timer]
OnCalendar=daily
Persistent=true

[Install]
WantedBy=timers.target
EOF

# Enable and start timer
sudo systemctl enable homelabarr-maintenance.timer
sudo systemctl start homelabarr-maintenance.timer
```

## Maintenance Best Practices

### Regular Schedule
- **Daily**: Docker cleanup, log rotation
- **Weekly**: System updates, full backup
- **Monthly**: Database optimization, security updates
- **Quarterly**: Major version updates, security audit

### Monitoring
- Check disk space regularly
- Monitor container health
- Review application logs
- Verify backup integrity

### Safety
- Always backup before major changes
- Test maintenance scripts in development
- Keep multiple backup copies
- Document any custom modifications

---

**Regular maintenance ensures optimal performance and reliability of your HomelabARR CLI deployment.**
