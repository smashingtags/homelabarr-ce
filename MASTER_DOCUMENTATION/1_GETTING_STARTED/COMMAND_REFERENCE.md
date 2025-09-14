# HomelabARR Command Reference Card
*Quick reference for all HomelabARR installation and management commands*

## 🚀 Installation Commands

### Local Mode (No Domain Required)
```bash
# Quick start - test locally
git clone https://github.com/smashingtags/homelabarr-cli.git
cd homelabarr-cli
./setup-local-mode.sh
./deploy-local.sh
```

### Production Mode (Domain Required)
```bash
# Full installation with SSL + Authentication
git clone https://github.com/smashingtags/homelabarr-cli.git
cd homelabarr-cli
sudo ./install.sh
```

### Complete Ecosystem
```bash
# All services integrated
git clone https://github.com/smashingtags/homelabarr-cli.git
cd homelabarr-cli
sudo ./install-ecosystem.sh
```

## 📦 Deployment Commands

### Deploy Individual Apps
```bash
# Local mode
./deploy-local.sh
# Choose from menu: 1-152 apps available

# Production mode
docker-compose -f apps/mediaserver/plex.yml up -d
docker-compose -f apps/downloadclients/qbittorrent.yml up -d
```

### Deploy Stacks
```bash
# Popular stack (Plex + Radarr + Sonarr + qBittorrent + Overseerr)
./deploy-local.sh
# Select option 1

# Media server stack
./deploy-local.sh
# Select option 2

# Complete ecosystem
docker-compose -f ecosystem-integration.yml up -d
```

## 🛠️ Management Commands

### Container Management
```bash
# View running containers
docker ps

# Stop all containers
docker stop $(docker ps -q)

# Remove all containers
docker rm -f $(docker ps -aq)

# View logs
docker logs [container-name]
docker logs -f [container-name]  # Follow logs
```

### System Management
```bash
# Update all containers
docker-compose pull && docker-compose up -d

# Prune unused resources
docker system prune -a

# Check resource usage
docker stats
```

## 🧪 Testing Commands

### Test Local Installation
```bash
# Test local mode
./test-ecosystem.sh --mode local

# Verify apps are accessible
curl -I localhost:32400  # Plex
curl -I localhost:7878   # Radarr
curl -I localhost:8989   # Sonarr
```

### Test Production Installation
```bash
# Test full stack
./test-ecosystem.sh --mode proxy

# Verify SSL and routing
curl -I https://plex.yourdomain.com
curl -I https://radarr.yourdomain.com
```

### Integration Testing
```bash
# Test complete ecosystem
./test-ecosystem.sh

# Verify all services
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

## 🌐 Web Interface Commands

### Access Web Installer
```bash
# Start web interface
docker-compose -f apps/system/homelabarr-web-interface.yml up -d

# Access at:
# http://localhost:3000 (local)
# https://homelabarr.yourdomain.com (production)
```

### Web API Commands
```bash
# Check API status
curl http://localhost:5000/api/health

# List containers via API
curl http://localhost:5000/api/containers

# Deploy via API
curl -X POST http://localhost:5000/api/deploy/plex
```

## 🔧 Configuration Commands

### Environment Setup
```bash
# Copy environment template
cp .env.example .env
cp .env.ecosystem .env  # For ecosystem

# Edit configuration
nano .env
```

### Network Commands
```bash
# Create networks
docker network create proxy
docker network create homelabarr

# List networks
docker network ls

# Inspect network
docker network inspect proxy
```

## 📊 Monitoring Commands

### Check Status
```bash
# System health
docker system df
df -h
free -m

# Container health
docker ps --format "table {{.Names}}\t{{.Status}}"
docker inspect [container] | grep -i health
```

### Logs and Debugging
```bash
# Check specific service logs
docker logs traefik
docker logs authelia
docker logs plex

# Debug compose file
docker-compose -f [file.yml] config
docker-compose -f [file.yml] ps
```

## 🚨 Troubleshooting Commands

### Common Fixes
```bash
# Permission issues
sudo chown -R 1000:1000 /opt/homelabarr
chmod +x *.sh

# Port conflicts
sudo netstat -tulpn | grep [PORT]
sudo lsof -i :[PORT]

# Reset everything
docker stop $(docker ps -q)
docker rm $(docker ps -aq)
docker system prune -a
```

### Validation Commands
```bash
# Validate YAML
docker-compose -f [file.yml] config --quiet

# Check Docker
docker version
docker-compose version

# Test connectivity
ping google.com
nslookup yourdomain.com
```

## 🎯 Quick Deployment Scenarios

### "I just want Plex"
```bash
cd homelabarr-cli
./deploy-local.sh
# Choose Plex from menu
# Access: http://localhost:32400
```

### "I want everything"
```bash
cd homelabarr-cli
sudo ./install-ecosystem.sh
# Access: https://homelabarr.yourdomain.com
```

### "Production media server"
```bash
cd homelabarr-cli
sudo ./install.sh
# Configure domain in .env
# Access: https://plex.yourdomain.com
```

## 📝 Notes

- **Local Mode**: No domain required, direct port access
- **Production Mode**: Requires domain + Cloudflare
- **Ecosystem Mode**: Includes web UI + automation
- **All modes**: Can be combined as needed

---
*Last Updated: August 18, 2025*
*Repository: https://github.com/smashingtags/homelabarr-cli*