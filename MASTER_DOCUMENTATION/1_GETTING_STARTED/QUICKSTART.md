# Quick Start Guide

**Get HomelabARR CLI running in 5 minutes!**

## 🎯 Choose Your Path

### Option 1: Local Mode (Easiest - No Domain Required)

Perfect for testing, home labs, and local network access.

#### One-Line Deploy
```bash
cd ~ && sudo rm -rf homelabarr-cli 2>/dev/null; git clone https://github.com/smashingtags/homelabarr-cli.git && cd homelabarr-cli && chmod +x setup-local-mode.sh && ./setup-local-mode.sh
```

#### What This Does:
1. Clones the repository
2. Sets up local mode automatically
3. Launches the deployment menu
4. No domain or SSL required
5. Access apps at `http://localhost:PORT`

#### Access Your Apps:
- **Plex**: http://localhost:32400
- **Radarr**: http://localhost:7878
- **Sonarr**: http://localhost:8989
- **qBittorrent**: http://localhost:8082
- **Overseerr**: http://localhost:5055

### Option 2: Production Mode (With Domain & SSL)

For external access with enterprise security.

#### Prerequisites:
- Domain name (e.g., yourdomain.com)
- Cloudflare account (free tier works)
- Ubuntu 22.04 LTS server

#### Installation:
```bash
# Clone repository
git clone https://github.com/smashingtags/homelabarr-cli.git
cd homelabarr-cli

# Run installer
sudo ./install.sh

# Follow prompts for:
# - Domain configuration
# - Cloudflare API setup
# - Application selection
```

#### Access Your Apps:
- **Plex**: https://plex.yourdomain.com
- **Radarr**: https://radarr.yourdomain.com
- **Sonarr**: https://sonarr.yourdomain.com
- All with SSL and authentication!

### Option 3: Web Interface (Visual Management)

Deploy using the modern React interface.

```bash
# After installing (either mode)
cd homelabarr-cli

# Deploy web interface
sudo docker-compose -f apps/system/homelabarr-web-interface.yml up -d

# Access at:
# Local: http://localhost:3000
# Production: https://homelabarr.yourdomain.com
```

## 🚀 What's Next?

### After Local Mode:
1. Run `./deploy-local.sh` to access the menu
2. Choose option 1 for popular media stack
3. Or browse all 150+ applications
4. Apps are immediately accessible

### After Production Mode:
1. Run `sudo homelabarr-cli -i` for the CLI menu
2. Deploy applications from categories
3. Configure Authelia authentication
4. Set up monitoring stack

### After Web Interface:
1. Browse application catalog
2. Click to deploy
3. Monitor in real-time
4. Manage containers visually

## 🔧 Common Commands

### Check Status
```bash
# View running containers
docker ps

# Check logs
docker logs <container-name>

# Monitor resources
docker stats
```

### Deploy Specific Apps
```bash
# Local mode
docker-compose -f apps/local-mode-apps/plex.yml up -d

# Production mode
sudo docker-compose -f apps/mediaserver/plex.yml up -d
```

### Stop Everything
```bash
# Stop all containers
docker stop $(docker ps -q)

# Remove all containers (careful!)
docker rm $(docker ps -aq)
```

## ❓ Need Help?

- **Can't access apps?** Check firewall: `sudo ufw status`
- **Port conflicts?** Use `netstat -tulpn | grep :PORT`
- **Docker not found?** Install: `curl -fsSL https://get.docker.com | bash`

## 📚 Next Steps

- [System Requirements](./REQUIREMENTS.md) - Detailed prerequisites
- [Complete Deployment Guide](../2_DEPLOYMENT/COMPLETE_GUIDE.md) - All options
- [Troubleshooting](../5_OPERATIONS/TROUBLESHOOTING.md) - Common issues

---

**Support**: [Discord](https://discord.gg/Pc7mXX786x) | [GitHub Issues](https://github.com/smashingtags/homelabarr-cli/issues)