# HomelabARR CLI - Local Mode Deployment

Local mode allows you to deploy HomelabARR applications without Traefik reverse proxy or Authelia authentication. Apps run directly on their native ports for easy local access.

## Quick Start

### 1. Clone the Repository
```bash
git clone https://github.com/smashingtags/homelabarr-cli.git /opt/homelabarr
cd /opt/homelabarr
```

### 2. Run Setup Script
```bash
chmod +x setup-local-mode.sh
./setup-local-mode.sh
```

This will:
- Check Docker/Docker Compose installation
- Verify 150+ pre-converted apps are present
- Fix script paths for your system
- Create default .env file

### 3. Launch Local Mode Menu
```bash
./deploy-local.sh
```

## Menu Options

- **1** - Deploy Popular Stack (Plex, Radarr, Sonarr, qBittorrent, Overseerr)
- **2** - Deploy Media Server Stack (All media apps)
- **50** - Browse All Apps (150+ applications)
- **51** - Search Apps by name
- **90** - Show Running Containers
- **91** - View Container Logs
- **92** - Bulk Operations
- **99** - Remove All Containers
- **0** - Exit

## Direct Access URLs

Apps are accessible directly without authentication:
- Plex: http://localhost:32400
- Radarr: http://localhost:7878
- Sonarr: http://localhost:8989
- qBittorrent: http://localhost:8082
- Overseerr: http://localhost:5055
- Jellyfin: http://localhost:8096

## Manual Setup (if setup script fails)

### Step 1: Install Docker
```bash
curl -fsSL https://get.docker.com | bash
```

### Step 2: Fix Script Permissions
```bash
cd /opt/homelabarr
chmod +x *.sh
chmod +x dev_scripts_backup_1755412048/*.sh
```

### Step 3: Run Menu
```bash
./deploy-local.sh
```

## Troubleshooting

### "0 apps available"
This means the script can't find the apps directory. Check that:
```bash
ls -la /opt/homelabarr/apps/local-mode-apps/
# Should show 150+ .yml files
```
If missing, you may need to re-clone the repository.

### "Permission denied"
Make scripts executable:
```bash
chmod +x *.sh
chmod +x .claude/development-scripts/*.sh
chmod +x dev_scripts_backup_1755412048/*.sh
```

### Docker not found
Install Docker:
```bash
curl -fsSL https://get.docker.com | bash
sudo usermod -aG docker $USER
# Log out and back in
```

## Differences from Proxy Mode

| Feature | Local Mode | Proxy Mode (Traefik) |
|---------|------------|---------------------|
| Authentication | None | Authelia |
| SSL/HTTPS | No | Yes |
| Subdomains | No | Yes |
| Port Access | Direct | Through proxy |
| Setup Complexity | Simple | Complex |
| Best For | Local testing | Production |

## Support

- GitHub Issues: https://github.com/smashingtags/homelabarr-cli/issues
- Documentation: https://github.com/smashingtags/homelabarr-cli/wiki