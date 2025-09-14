# HomelabARR CLI Local Mode v1.0 - Release Notes

## 🎉 New Feature: Local Mode Deployment

HomelabARR CLI now supports **Local Mode** - a simplified deployment option that provides direct IP:PORT access to services without requiring Traefik reverse proxy, Authelia authentication, or Cloudflare configuration.

## 🚀 One-Line Installation

Get HomelabARR CLI Local Mode running instantly:

```bash
cd ~ && sudo rm -rf homelabarr-cli 2>/dev/null; git clone https://github.com/smashingtags/homelabarr-cli.git && cd homelabarr-cli && chmod +x install-local.sh && ./install-local.sh
```

## 🎉 **MASSIVE SERVICE LIBRARY: 179+ Applications!**

### ✅ **Curated Templates (Production Ready)**
These 8 services are fully tested and guaranteed to work perfectly:

#### Media Servers
- **Plex Media Server** - http://localhost:32400
- **Jellyfin Media Server** - http://localhost:8096

#### Media Management  
- **Radarr** - http://localhost:7878 (Movies)
- **Sonarr** - http://localhost:8989 (TV Shows)

#### Download Clients
- **qBittorrent** - http://localhost:8082 (Torrents)
- **SABnzbd** - http://localhost:8085 (Usenet)

#### Request & Monitoring
- **Overseerr** - http://localhost:5055 (Media Requests)
- **Tautulli** - http://localhost:8181 (Plex Analytics)

### 🚀 **Bulk Converted Applications (171+ Services)**

**In addition to the curated templates, HomelabARR CLI Local Mode includes 171+ pre-converted applications covering every category:**

#### **📁 Major Categories Available:**
- **🎬 Media**: Plex, Jellyfin, Emby, Koel, Mstream (+15 more)
- **📚 Management**: Radarr, Sonarr, Lidarr, Bazarr, Prowlarr (+20 more)  
- **⬇️ Downloads**: qBittorrent, SABnzbd, Deluge, Transmission (+15 more)
- **🎫 Requests**: Overseerr, Petio, Ombi, Jellyseerr (+5 more)
- **📊 Monitoring**: Tautulli, Netdata, Glances, Uptime-Kuma (+10 more)
- **🛡️ Security**: Fail2Ban, Bitwarden, Authelia (+8 more)
- **🌐 Networking**: Pi-hole, WireGuard, Cloudflared (+12 more)
- **💾 Storage**: NextCloud, Duplicati, Syncthing (+15 more)
- **🔧 Development**: Code-Server, GitLab, VS Code (+20 more)
- **🎨 Dashboards**: Heimdall, Organizr, Dashy, Flame (+10 more)
- **📱 Self-Hosted**: HomeAssistant, Bookstack, Recipes (+25 more)
- **🎮 Communication**: Discord, TeamSpeak, Signal (+8 more)

#### **🚀 Deploy Any Service Instantly:**
```bash
# Use curated templates (recommended)
./install-local.sh

# Or deploy any bulk converted app
cd apps/local-mode-apps
docker-compose -f SERVICE.yml --env-file ../.config/.env up -d

# Popular examples:
docker-compose -f nextcloud.yml --env-file ../.config/.env up -d      # Cloud storage
docker-compose -f pihole.yml --env-file ../.config/.env up -d         # Ad blocking
docker-compose -f heimdall.yml --env-file ../.config/.env up -d       # Dashboard
docker-compose -f code-server.yml --env-file ../.config/.env up -d    # VS Code
```

## 🎯 Deployment Options

The installer provides flexible deployment choices:

1. **Single Service** - Deploy just Plex Media Server
2. **Popular Stack** - Deploy Plex + Radarr + qBittorrent together
3. **Interactive Menu** - Choose from all available services
4. **Setup Only** - Configure environment for manual deployment

## 🔧 Technical Features

### Smart Installation
- Automatic Docker Compose detection and installation
- Environment configuration with sensible defaults
- Data directory setup with proper permissions
- Graceful error handling and fallbacks

### Network Architecture
- Bridge networking for inter-container communication
- Direct port mapping for external access
- No reverse proxy complexity
- Secure container isolation

### Data Management
- Persistent Docker volumes for application data
- Configurable data directory location
- Theme and configuration persistence
- Easy backup and migration

## 📋 System Requirements

- **Operating System**: Linux (Ubuntu/Debian tested)
- **Docker**: Version 20.0+ with Compose V2
- **Memory**: 2GB+ RAM recommended
- **Storage**: 10GB+ available disk space
- **Network**: No domain or external DNS required

## 🆚 Local Mode vs Full Mode

| Feature | Local Mode | Full Mode |
|---------|------------|-----------|
| **Access Method** | http://localhost:PORT | https://service.domain.com |
| **Setup Complexity** | Minimal (one command) | Advanced (domain + Cloudflare) |
| **Authentication** | None (local network) | Authelia multi-factor |
| **SSL/TLS** | Not required | Automatic Let's Encrypt |
| **External Access** | Manual port forwarding | Automatic via Cloudflare |
| **Use Case** | Home lab, testing, simple setups | Production, remote access |

## 🎯 Which Mode Should You Use?

### **Choose Full Mode (`sudo ./install.sh`) If:**
- ✅ You have a domain name and Cloudflare account
- ✅ You want external access from anywhere
- ✅ You need enterprise-grade authentication with 2FA
- ✅ You want automatic SSL/TLS certificate management
- ✅ You prefer URLs like `https://plex.yourdomain.com`

### **Choose Local Mode (`./install-local.sh`) If:**
- ✅ You want simple home lab setup
- ✅ No domain required - works immediately
- ✅ Local network access is sufficient
- ✅ You want the fastest possible setup (5 minutes)
- ✅ You're testing or learning HomelabARR CLI

## 🚀 How to Launch Each Mode

### **Full Mode (Traefik + Authelia):**
```bash
git clone https://github.com/smashingtags/homelabarr-cli.git
cd homelabarr-cli
sudo ./install.sh
```
*This launches the original HomelabARR CLI installer with:*
- Traefik reverse proxy setup
- Authelia authentication configuration  
- Domain and Cloudflare integration
- SSL certificate management

### **Local Mode (Direct Access):**
```bash
cd ~ && sudo rm -rf homelabarr-cli 2>/dev/null; git clone https://github.com/smashingtags/homelabarr-cli.git && cd homelabarr-cli && chmod +x install-local.sh && ./install-local.sh
```
*One-line deploy for immediate local access with:*
- No domain required
- Direct IP:PORT access
- 179+ applications available
- Simplified configuration

## 🛠️ Configuration

### Environment Variables
Key settings in `.env` file:
- `APPFOLDER` - Data storage location
- `TZ` - Timezone configuration  
- `*IMAGE` - Container image versions
- `*THEME` - Theme Park customization

### Port Assignments
- **Plex**: 32400 (standard Plex port)
- **Radarr**: 7878 (standard Radarr port)
- **qBittorrent**: 8082 (changed from 8080 to avoid conflicts)

## 🔍 Troubleshooting

### Common Issues
- **Port conflicts**: Check `netstat -tulpn` for port usage
- **Permission errors**: Ensure user is in docker group
- **Volume issues**: Check data directory permissions

### Getting Help
- Check the comprehensive guide: `wiki/docs/install/local-mode.md`
- View container logs: `docker logs <container-name>`
- Restart services: `docker compose restart`

## 🚀 What's Next

### Coming Soon
- **Sonarr** - TV series management
- **Jellyfin** - Alternative media server
- **Overseerr** - Media request management
- **SABnzbd** - Usenet downloading
- **Tautulli** - Plex monitoring and analytics

### Future Enhancements
- Local-persist plugin integration for advanced volume management
- Automated backup and restore functionality
- Web-based configuration interface
- Update management system

## 📞 Support

- **Documentation**: [Local Mode Guide](./wiki/docs/install/local-mode.md)
- **Issues**: [GitHub Issues](https://github.com/smashingtags/homelabarr-cli/issues)
- **Community**: [HomelabARR Discord](https://discord.gg/Pc7mXX786x)

## 🙏 Credits

Local Mode implementation by the HomelabARR community with special thanks to all contributors who made this simplified deployment option possible.

---

**Version**: 1.0.0  
**Release Date**: August 2025  
**Compatibility**: HomelabARR CLI Master Branch
