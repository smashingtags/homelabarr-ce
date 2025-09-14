# Complete Deployment Guide

**All 6 deployment methods for HomelabARR CLI**

## 📋 Deployment Methods Overview

| Method | Complexity | Domain Required | SSL | Auth | Best For |
|--------|------------|-----------------|-----|------|----------|
| [Local Mode](#method-1-local-mode) | ⭐ Easy | No | No | No | Testing, Home Labs |
| [Production Mode](#method-2-production-mode) | ⭐⭐⭐ Complex | Yes | Yes | Yes | External Access |
| [Web Interface](#method-3-web-interface) | ⭐⭐ Medium | Optional | Optional | Optional | Visual Management |
| [Docker Compose](#method-4-docker-compose) | ⭐⭐ Medium | No | No | No | Custom Deployments |
| [Monitoring Stack](#method-5-monitoring-stack) | ⭐⭐ Medium | Optional | Optional | Optional | Observability |
| [Complete Ecosystem](#method-6-complete-ecosystem) | ⭐⭐⭐ Complex | Yes | Yes | Yes | Full Integration |

---

## Method 1: Local Mode

### Overview
Direct port access without reverse proxy or authentication. Perfect for local networks.

### Installation
```bash
# One-line installation
cd ~ && sudo rm -rf homelabarr-cli 2>/dev/null; \
git clone https://github.com/smashingtags/homelabarr-cli.git && \
cd homelabarr-cli && chmod +x setup-local-mode.sh && ./setup-local-mode.sh
```

### Features
- ✅ No domain required
- ✅ Direct IP:PORT access
- ✅ 150+ pre-converted applications
- ✅ Interactive deployment menu
- ✅ 5-minute setup

### Access Pattern
```
http://localhost:32400  # Plex
http://localhost:7878   # Radarr
http://localhost:8989   # Sonarr
http://192.168.1.x:PORT # LAN access
```

### Menu System
```bash
./deploy-local.sh

# Options:
# 1 - Deploy Popular Stack
# 2 - Deploy Media Server Stack
# 50 - Browse All Apps
# 90 - Show Running Containers
# 99 - Remove All Containers
```

---

## Method 2: Production Mode (Traefik + Authelia)

### Overview
Enterprise-grade deployment with SSL, authentication, and reverse proxy.

### Prerequisites
- Ubuntu 22.04 LTS
- Domain name
- Cloudflare account
- 4GB RAM minimum
- Ports 80/443 open

### Installation
```bash
# Clone and prepare
git clone https://github.com/smashingtags/homelabarr-cli.git
cd homelabarr-cli
chmod +x install.sh

# Run installer
sudo ./install.sh

# Configure environment
sudo nano .env
```

### Environment Variables
```bash
DOMAIN=yourdomain.com
CLOUDFLARE_EMAIL=your-email@domain.com
CLOUDFLARE_API_KEY=your-api-key
CLOUDFLARE_ZONE_ID=your-zone-id
AUTH_ENABLED=true
PUID=1000
PGID=1000
TZ=America/New_York
```

### Cloudflare Settings
1. SSL = FULL (not FULL/STRICT)
2. Always Use HTTPS = ON
3. Automatic HTTPS Rewrites = ON
4. Minimum TLS Version = 1.2
5. Create A Record → Server IP

### Deploy Stack
```bash
# Install Traefik first
sudo ./traefik/install.sh

# Access CLI menu
sudo homelabarr-cli -i

# Deploy applications
sudo ./apps/install.sh
```

### Access Pattern
```
https://plex.yourdomain.com
https://radarr.yourdomain.com
https://auth.yourdomain.com
```

---

## Method 3: Web Interface Deployment

### Overview
Modern React-based web interface for visual container management.

### Installation

#### Standalone Deployment
```bash
# Deploy web interface
cd homelabarr-cli
sudo docker-compose -f apps/system/homelabarr-web-interface.yml up -d
```

#### Integrated Deployment
```bash
# Navigate to integration workspace
cd .integration-work/homelabarr-main/

# Install dependencies
npm install

# Configure environment
cp .env.example .env
# Edit CLI_PATH in .env

# Start development
npm run dev

# Production build
npm run build
npm run preview
```

### Configuration
```javascript
// .env configuration
CLI_PATH=../../  // Path to HomelabARR CLI
API_BASE_URL=http://localhost:3001
AUTH_ENABLED=false  // For development
```

### Features
- 338+ application templates
- Real-time deployment progress
- Container status monitoring
- Cross-platform compatibility
- No Docker socket dependency

### Access URLs
- **Development**: http://localhost:5173
- **Production**: http://localhost:3000
- **Traefik**: https://homelabarr.yourdomain.com

---

## Method 4: Docker Compose Direct

### Overview
Manual deployment using Docker Compose files directly.

### Local Mode Apps
```bash
cd homelabarr-cli/apps/local-mode-apps/

# Deploy individual apps
docker-compose -f plex.yml up -d
docker-compose -f radarr.yml up -d
docker-compose -f sonarr.yml up -d
```

### Production Apps
```bash
cd homelabarr-cli/apps/

# Media servers
docker-compose -f mediaserver/plex.yml up -d
docker-compose -f mediaserver/jellyfin.yml up -d

# Media management
docker-compose -f mediamanager/radarr.yml up -d
docker-compose -f mediamanager/sonarr.yml up -d

# Download clients
docker-compose -f downloadclients/qbittorrent.yml up -d
```

### Custom Configuration
```yaml
# Example custom override
version: '3.9'
services:
  plex:
    ports:
      - "32401:32400"  # Custom port
    environment:
      - PLEX_CLAIM=claim-token
    volumes:
      - /custom/path:/data
```

---

## Method 5: Monitoring Stack

### Overview
Complete observability with Grafana, Prometheus, Loki, and Netdata.

### Components
- **Grafana**: Dashboards and visualization
- **Prometheus**: Metrics collection
- **Loki**: Log aggregation
- **Alertmanager**: Alert routing
- **Netdata**: Real-time monitoring
- **Uptime Kuma**: Service monitoring

### Installation
```bash
# Deploy monitoring stack
cd homelabarr-cli/apps/monitoring/
sudo docker-compose -f grafana-loki-prometheus.yml up -d

# Deploy Netdata
sudo docker-compose -f netdata.yml up -d

# Deploy Uptime Kuma
sudo docker-compose -f uptime-kuma.yml up -d
```

### Configuration
```yaml
# prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'containers'
    static_configs:
      - targets: ['cadvisor:8080']
  
  - job_name: 'node'
    static_configs:
      - targets: ['node-exporter:9100']
```

### Access URLs
- **Grafana**: http://localhost:3000 (admin/admin)
- **Prometheus**: http://localhost:9090
- **Alertmanager**: http://localhost:9093
- **Netdata**: http://localhost:19999
- **Uptime Kuma**: http://localhost:3001

### Pre-built Dashboards
```bash
# Import dashboards
cd scripts/monitoring/
./import-dashboards.sh

# Available dashboards:
# - Docker Host Monitoring
# - Container Metrics
# - Traefik Analytics
# - Media Server Stats
```

---

## Method 6: Complete Ecosystem

### Overview
Full integration of all HomelabARR components with enhanced features.

### Components
- HomelabARR CLI (core)
- Web Interface (React UI)
- Mount Enhanced (cloud storage)
- Uploader Service (automated uploads)
- Local Persist (volume driver)
- Monitoring Stack (observability)

### Installation
```bash
# Clone all repositories
git clone https://github.com/smashingtags/homelabarr-cli.git
git clone https://github.com/smashingtags/homelabarr-web.git

# Install ecosystem
cd homelabarr-cli
chmod +x install-ecosystem.sh
sudo ./install-ecosystem.sh

# Configure environment
sudo nano .env

# Deploy complete stack
sudo docker-compose -f ecosystem-integration.yml up -d
```

### Ecosystem Docker Compose
```yaml
version: '3.9'

networks:
  homelabarr:
    driver: bridge

services:
  # Local Persist Plugin
  local-persist:
    image: ghcr.io/smashingtags/local-persist:latest
    container_name: homelabarr_local_persist
    privileged: true
    volumes:
      - /run/docker/plugins:/run/docker/plugins
      - /var/lib/docker/plugin-data:/var/lib/docker/plugin-data
    networks:
      - homelabarr

  # Mount Enhanced Service
  mount-enhanced:
    image: ghcr.io/smashingtags/homelabarr-mount:latest
    container_name: homelabarr_mount_enhanced
    privileged: true
    devices:
      - /dev/fuse
    cap_add:
      - SYS_ADMIN
    volumes:
      - /mnt:/mnt:shared
      - ./config/rclone:/config
    networks:
      - homelabarr

  # Web Interface Backend
  homelabarr-backend:
    image: ghcr.io/smashingtags/homelabarr-backend:latest
    container_name: homelabarr_backend
    ports:
      - "3001:3001"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ../homelabarr-cli:/cli
    environment:
      - CLI_PATH=/cli
      - AUTH_ENABLED=true
    networks:
      - homelabarr

  # Web Interface Frontend
  homelabarr-frontend:
    image: ghcr.io/smashingtags/homelabarr-frontend:latest
    container_name: homelabarr_frontend
    ports:
      - "3000:80"
    depends_on:
      - homelabarr-backend
    networks:
      - homelabarr
```

### Integration Features
- Unified volume management
- Cross-service authentication
- Centralized monitoring
- Automated backups
- Cloud storage integration
- Upload automation

---

## 🔍 Choosing the Right Method

### Decision Tree

1. **Do you need external access?**
   - Yes → Production Mode or Complete Ecosystem
   - No → Local Mode or Docker Compose

2. **Do you have a domain?**
   - Yes → Production Mode with Traefik
   - No → Local Mode or Web Interface

3. **Do you want visual management?**
   - Yes → Web Interface
   - No → CLI methods

4. **Do you need monitoring?**
   - Yes → Monitoring Stack or Complete Ecosystem
   - No → Any other method

5. **Do you want everything?**
   - Yes → Complete Ecosystem
   - No → Choose specific method

---

## 📊 Resource Requirements

| Method | CPU Cores | RAM | Storage | Network |
|--------|-----------|-----|---------|---------|
| Local Mode | 2+ | 4GB | 20GB | LAN |
| Production | 2+ | 4GB | 20GB | Internet |
| Web Interface | 2+ | 4GB | 20GB | Any |
| Docker Compose | 2+ | 4GB | 20GB | Any |
| Monitoring | 4+ | 8GB | 50GB | Any |
| Ecosystem | 4+ | 8GB | 100GB | Internet |

---

## 🚀 Post-Deployment

### Verify Installation
```bash
# Check containers
docker ps

# Check logs
docker logs <container-name>

# Test connectivity
curl -I http://localhost:PORT
```

### Common Tasks
```bash
# Update containers
docker-compose pull
docker-compose up -d

# Backup configuration
tar -czf homelabarr-backup.tar.gz /opt/appdata/

# Clean up
docker system prune -a
```

---

## 📚 Additional Resources

- [Troubleshooting Guide](../5_OPERATIONS/TROUBLESHOOTING.md)
- [Security Hardening](../5_OPERATIONS/SECURITY.md)
- [Monitoring Setup](./MONITORING_STACK.md)
- [API Documentation](../4_DEVELOPMENT/API_DOCS.md)

---

**Support**: [Discord](https://discord.gg/Pc7mXX786x) | [GitHub](https://github.com/smashingtags/homelabarr-cli)