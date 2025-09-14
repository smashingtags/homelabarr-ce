# HomelabARR Ecosystem - Complete Deployment Guide

## 🏗️ System Architecture Overview

HomelabARR is a comprehensive Docker-based infrastructure ecosystem consisting of multiple components:

```
┌─────────────────────────────────────────────────────────────┐
│                   HomelabARR Ecosystem                       │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌─────────────────────┐      ┌──────────────────────┐      │
│  │  HomelabARR CLI      │      │  HomelabARR Web      │      │
│  │  (Infrastructure)    │◄────►│  (Management UI)      │      │
│  └─────────────────────┘      └──────────────────────┘      │
│           │                            │                      │
│           ▼                            ▼                      │
│  ┌─────────────────────────────────────────────────────┐    │
│  │              Docker Engine + Compose                 │    │
│  └─────────────────────────────────────────────────────┘    │
│           │                            │                      │
│     ┌─────▼──────┐              ┌─────▼──────┐              │
│     │  Traefik   │              │Local-Persist│              │
│     │  + Authelia│              │  (Go Volume │              │
│     │   (Prod)   │              │   Driver)   │              │
│     └────────────┘              └─────────────┘              │
│                                                               │
│  ┌─────────────────────────────────────────────────────┐    │
│  │         179+ Containerized Applications              │    │
│  │  (Media Servers, Download Clients, Management Tools) │    │
│  └─────────────────────────────────────────────────────┘    │
└───────────────────────────────────────────────────────────────┘
```

## 📋 Prerequisites

### System Requirements
- **OS**: Ubuntu 20.04+ or Debian 11+ (Linux only, no ARM support)
- **CPU**: Minimum 2 cores, recommended 4+ cores
- **RAM**: Minimum 4GB, recommended 8GB+ for production
- **Storage**: Minimum 20GB for system, 100GB+ recommended for media
- **Network**: Static IP recommended for production deployments

### Required Software
```bash
# Check Docker installation
docker --version  # Required: 20.10.0+
docker compose version  # Required: 2.0.0+

# Check Git
git --version  # Required: 2.0+

# For production deployments
# - Valid domain name with DNS control
# - Cloudflare account (for DNS-based SSL)
```

## 🚀 Installation Methods

HomelabARR supports multiple deployment modes depending on your needs:

1. **Local Mode** - Quick testing with the colored CLI menu
2. **Traefik Production Mode** - Full production with reverse proxy + authentication
3. **HomelabARR Web** - Web-based management interface
4. **Hybrid Mode** - Combine all components

---

## 1️⃣ Method 1: Local Mode Installation (Quick Start)

The Local Mode provides a beautiful colored CLI interface for quick deployment without reverse proxy.

### Step 1: Clone and Prepare Repository
```bash
# Clone the repository
git clone https://github.com/smashingtags/homelabarr-cli.git
cd homelabarr-cli

# Make all scripts executable
chmod +x install.sh homelabarr-cli.sh
find scripts/ apps/ traefik/ -name "*.sh" -exec chmod +x {} \;

# Create required symlink for compatibility
sudo ln -sf "$(pwd)" /opt/homelabarr
```

### Step 2: Install Docker (if not already installed)
```bash
# Run the preinstaller
sudo ./install.sh
# Select option 0 for preinstall if Docker is not installed
```

### Step 3: Launch Local Mode CLI
```bash
# Run the beautiful colored CLI
./homelabarr-cli.sh
```

You'll see the enhanced 256-color menu:
```
    __  __                     __      __    ___    ____  ____  
   / / / /___  ____ ___  ___  / /___ _/ /_  /   |  / __ \/ __ \ 
  / /_/ / __ \/ __ `__ \/ _ \/ / __ `/ __ \/ /| | / /_/ / /_/ / 
 / __  / /_/ / / / / / /  __/ / /_/ / /_/ / ___ |/ _, _/ _, _/  
/_/ /_/\____/_/ /_/ /_/\___/_/\__,_/_.___/_/  |_/_/ |_/_/ |_|   

🎯 Quick Deploy Options
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  1) Deploy Popular Stack (Plex + Radarr + Sonarr + qBittorrent)
  2) Deploy Media Server Stack (All media applications)
  3) Deploy Monitoring Stack (Grafana + Prometheus + Loki)

📁 Application Library (179 apps)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  50) Browse All Applications
  51) Search Applications
  52) Deploy by Category
```

### Step 4: Deploy Applications
```bash
# Option 1: Deploy popular stack (recommended for first-time users)
Select: 1

# Apps will deploy on these ports:
# Plex: http://localhost:32400
# Radarr: http://localhost:7878
# Sonarr: http://localhost:8989
# qBittorrent: http://localhost:8082
# Overseerr: http://localhost:5055
```

### Local Mode Environment Variables
Create `.env` file in the root directory:
```bash
# Basic configuration
PUID=1000
PGID=1000
TZ=America/New_York

# Media paths
MEDIA_PATH=/path/to/media
DOWNLOADS_PATH=/path/to/downloads
CONFIG_PATH=./config
```

---

## 2️⃣ Method 2: Traefik Production Mode (Full Stack)

Production deployment with Traefik reverse proxy, SSL certificates, and Authelia authentication.

### Step 1: Initial Setup
```bash
# Clone repository
git clone https://github.com/smashingtags/homelabarr-cli.git
cd homelabarr-cli

# Make scripts executable
chmod +x install.sh
find . -name "*.sh" -exec chmod +x {} \;

# Create symlink
sudo ln -sf "$(pwd)" /opt/homelabarr
```

### Step 2: Configure Domain and Cloudflare
```bash
# Create production environment file
cp .env.example .env
nano .env
```

Add your configuration:
```bash
# Domain Configuration
DOMAIN=yourdomain.com
CLOUDFLARE_EMAIL=your-email@example.com
CLOUDFLARE_API_KEY=your-cloudflare-api-key

# Traefik Configuration
TRAEFIK_DASHBOARD=true
TRAEFIK_DASHBOARD_SUBDOMAIN=traefik

# Authelia Configuration
AUTHELIA_SUBDOMAIN=auth
AUTHELIA_JWT_SECRET=$(openssl rand -hex 32)
AUTHELIA_SESSION_SECRET=$(openssl rand -hex 32)
AUTHELIA_STORAGE_ENCRYPTION_KEY=$(openssl rand -hex 32)

# Database Passwords
AUTHELIA_MYSQL_PASSWORD=$(openssl rand -hex 16)
AUTHELIA_REDIS_PASSWORD=$(openssl rand -hex 16)

# SMTP Configuration (for 2FA)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=your-email@gmail.com
SMTP_PASSWORD=your-app-password
```

### Step 3: Run Production Installer
```bash
# Run main installer
sudo ./install.sh

# Select Option 1: HomelabARR CLI - Traefik + Authelia
# This installs the complete infrastructure stack
```

### Step 4: Install Traefik Stack
```bash
# Navigate to traefik directory
cd traefik

# Run Traefik installer
sudo ./install.sh

# Follow prompts for:
# 1. Domain configuration
# 2. Cloudflare API setup
# 3. Authelia configuration
# 4. SSL certificate generation
```

### Step 5: Deploy Applications with Traefik Labels
```bash
# Go back to main directory
cd /opt/homelabarr

# Install applications
cd apps
sudo ./install.sh

# Select categories:
# 1) Media Servers
# 2) Download Clients
# 3) Media Management
# 4) Request Systems
# 5) Monitoring
```

### Step 6: Verify Traefik Routes
```bash
# Check Traefik dashboard
https://traefik.yourdomain.com

# Check deployed services
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# View Traefik logs
docker logs traefik
```

### Production Network Architecture
```yaml
networks:
  proxy:
    external: true  # Created by Traefik installer
    
services:
  app:
    networks:
      - proxy
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.app.rule=Host(`app.${DOMAIN}`)"
      - "traefik.http.routers.app.tls.certresolver=cloudflare"
      - "traefik.http.routers.app.middlewares=authelia@docker"
```

---

## 3️⃣ Method 3: HomelabARR Web Installation

The web interface provides a modern React frontend with Go backend for managing your infrastructure.

### Step 1: Clone HomelabARR Web Repository
```bash
# Clone the web repository
git clone https://github.com/smashingtags/homelabarr-web.git
cd homelabarr-web
```

### Step 2: Build and Deploy with Docker Compose
```bash
# Create docker-compose.yml
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  homelabarr-frontend:
    image: ghcr.io/smashingtags/homelabarr-frontend:latest
    container_name: homelabarr-frontend
    ports:
      - "3000:80"
    environment:
      - REACT_APP_API_URL=http://localhost:8080
    restart: unless-stopped

  homelabarr-backend:
    image: ghcr.io/smashingtags/homelabarr-backend:latest
    container_name: homelabarr-backend
    ports:
      - "8080:8080"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - ./config:/config
      - ./data:/data
    environment:
      - DB_PATH=/data/homelabarr.db
      - DOCKER_HOST=unix:///var/run/docker.sock
    restart: unless-stopped
EOF

# Deploy
docker compose up -d
```

### Step 3: Access Web Interface
```bash
# Frontend
http://localhost:3000

# Backend API
http://localhost:8080/api

# Default credentials (first run)
# Username: admin
# Password: changeme
```

### Step 4: Configure Web Interface
1. Navigate to Settings
2. Configure Docker connection
3. Set up application paths
4. Configure monitoring preferences

---

## 4️⃣ Method 4: Local-Persist Volume Driver Installation

The Go rewrite of local-persist provides persistent Docker volumes with custom mount points.

### Step 1: Download and Install Binary
```bash
# Download latest release
wget https://github.com/smashingtags/local-persist/releases/latest/download/local-persist-linux-amd64
chmod +x local-persist-linux-amd64
sudo mv local-persist-linux-amd64 /usr/local/bin/local-persist

# Or build from source
git clone https://github.com/smashingtags/local-persist.git
cd local-persist
go build -o local-persist cmd/local-persist/main.go
sudo mv local-persist /usr/local/bin/
```

### Step 2: Create Systemd Service
```bash
sudo cat > /etc/systemd/system/local-persist.service << 'EOF'
[Unit]
Description=Local Persist Volume Driver for Docker
After=docker.service
Requires=docker.service

[Service]
Type=simple
ExecStart=/usr/local/bin/local-persist
Restart=always
RestartSec=5
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

# Enable and start service
sudo systemctl daemon-reload
sudo systemctl enable local-persist
sudo systemctl start local-persist
```

### Step 3: Create Volumes with Special Mounts
```bash
# Create a persistent volume with custom mount point
docker volume create -d local-persist \
  -o mountpoint=/mnt/storage/media \
  --name=media-volume

# Create config volume
docker volume create -d local-persist \
  -o mountpoint=/opt/homelabarr/config \
  --name=config-volume

# Verify volumes
docker volume ls
docker volume inspect media-volume
```

### Step 4: Use in Docker Compose
```yaml
version: '3.8'

volumes:
  media:
    driver: local-persist
    driver_opts:
      mountpoint: /mnt/storage/media
  
  config:
    driver: local-persist
    driver_opts:
      mountpoint: /opt/homelabarr/config

services:
  plex:
    image: lscr.io/linuxserver/plex:latest
    volumes:
      - config:/config
      - media:/media
```

---

## 5️⃣ Method 5: Complete Monitoring Stack

The HomelabARR monitoring stack provides comprehensive observability with Netdata, Grafana, Prometheus, Loki, and Uptime Kuma.

### Step 1: Deploy Core Monitoring Components
```bash
# Create monitoring network
docker network create monitoring

# Deploy Prometheus for metrics collection
cat > docker-compose-prometheus.yml << 'EOF'
version: '3.8'

networks:
  monitoring:
    external: true
  proxy:
    external: true

services:
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    restart: unless-stopped
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--storage.tsdb.retention.time=90d'
      - '--web.enable-lifecycle'
    volumes:
      - ./prometheus:/etc/prometheus
      - prometheus-data:/prometheus
    networks:
      - monitoring
      - proxy
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.prometheus.rule=Host(`prometheus.${DOMAIN}`)"
      - "traefik.http.services.prometheus.loadbalancer.server.port=9090"
EOF

docker compose -f docker-compose-prometheus.yml up -d
```

### Step 2: Deploy Grafana Visualization
```bash
# Deploy Grafana with pre-configured dashboards
cat > docker-compose-grafana.yml << 'EOF'
version: '3.8'

networks:
  monitoring:
    external: true
  proxy:
    external: true

services:
  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    restart: unless-stopped
    environment:
      - GF_SECURITY_ADMIN_USER=${GRAFANA_USER:-admin}
      - GF_SECURITY_ADMIN_PASSWORD=${GRAFANA_PASSWORD:-admin}
      - GF_INSTALL_PLUGINS=grafana-clock-panel,grafana-simple-json-datasource
    volumes:
      - grafana-data:/var/lib/grafana
      - ./grafana/provisioning:/etc/grafana/provisioning
    networks:
      - monitoring
      - proxy
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.grafana.rule=Host(`grafana.${DOMAIN}`)"
      - "traefik.http.services.grafana.loadbalancer.server.port=3000"

volumes:
  grafana-data:
EOF

docker compose -f docker-compose-grafana.yml up -d
```

### Step 3: Deploy Netdata for Real-Time Monitoring
```bash
# Deploy Netdata with container monitoring
cat > docker-compose-netdata.yml << 'EOF'
version: '3.8'

services:
  netdata:
    image: netdata/netdata:latest
    container_name: netdata
    hostname: netdata
    restart: unless-stopped
    cap_add:
      - SYS_PTRACE
    security_opt:
      - apparmor:unconfined
    volumes:
      - netdata-config:/etc/netdata
      - netdata-lib:/var/lib/netdata
      - netdata-cache:/var/cache/netdata
      - /etc/passwd:/host/etc/passwd:ro
      - /etc/group:/host/etc/group:ro
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /var/run/docker.sock:/var/run/docker.sock:ro
    environment:
      - NETDATA_CLAIM_TOKEN=${NETDATA_CLAIM_TOKEN}
      - NETDATA_CLAIM_URL=https://app.netdata.cloud
      - DOCKER_USR=root
    networks:
      - monitoring
      - proxy
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.netdata.rule=Host(`netdata.${DOMAIN}`)"
      - "traefik.http.services.netdata.loadbalancer.server.port=19999"

volumes:
  netdata-config:
  netdata-lib:
  netdata-cache:
EOF

docker compose -f docker-compose-netdata.yml up -d
```

### Step 4: Deploy Uptime Kuma for Service Monitoring
```bash
# Deploy Uptime Kuma
cat > docker-compose-uptime-kuma.yml << 'EOF'
version: '3.8'

services:
  uptime-kuma:
    image: louislam/uptime-kuma:latest
    container_name: uptime-kuma
    restart: unless-stopped
    volumes:
      - uptime-kuma-data:/app/data
    networks:
      - monitoring
      - proxy
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.uptime.rule=Host(`status.${DOMAIN}`)"
      - "traefik.http.services.uptime.loadbalancer.server.port=3001"

volumes:
  uptime-kuma-data:
EOF

docker compose -f docker-compose-uptime-kuma.yml up -d
```

### Step 5: Deploy Loki for Log Aggregation
```bash
# Deploy Loki and Promtail
cat > docker-compose-loki.yml << 'EOF'
version: '3.8'

services:
  loki:
    image: grafana/loki:latest
    container_name: loki
    restart: unless-stopped
    command: -config.file=/etc/loki/local-config.yaml
    volumes:
      - loki-data:/loki
    networks:
      - monitoring
    ports:
      - "3100:3100"

  promtail:
    image: grafana/promtail:latest
    container_name: promtail
    restart: unless-stopped
    volumes:
      - /var/log:/var/log:ro
      - /var/lib/docker/containers:/var/lib/docker/containers:ro
      - ./promtail/config.yml:/etc/promtail/config.yml
    command: -config.file=/etc/promtail/config.yml
    networks:
      - monitoring

volumes:
  loki-data:
EOF

docker compose -f docker-compose-loki.yml up -d
```

### Step 6: Configure Prometheus Scraping
Create `prometheus/prometheus.yml`:
```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  # Docker containers
  - job_name: 'docker'
    static_configs:
      - targets: ['172.17.0.1:9323']

  # Node exporter
  - job_name: 'node'
    static_configs:
      - targets: ['node-exporter:9100']

  # Traefik metrics
  - job_name: 'traefik'
    static_configs:
      - targets: ['traefik:8080']

  # Container metrics via cAdvisor
  - job_name: 'cadvisor'
    static_configs:
      - targets: ['cadvisor:8080']

  # HomelabARR services
  - job_name: 'homelabarr-services'
    static_configs:
      - targets:
        - 'plex:32400'
        - 'sonarr:8989'
        - 'radarr:7878'
        - 'qbittorrent:8082'
```

### Step 7: Import Grafana Dashboards
```bash
# Create dashboard provisioning
mkdir -p grafana/provisioning/dashboards
mkdir -p grafana/provisioning/datasources

# Configure Prometheus datasource
cat > grafana/provisioning/datasources/prometheus.yml << 'EOF'
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    
  - name: Loki
    type: loki
    access: proxy
    url: http://loki:3100
EOF

# Download HomelabARR dashboard
wget -O grafana/provisioning/dashboards/homelabarr.json \
  https://raw.githubusercontent.com/smashingtags/homelabarr-cli/main/monitoring/dashboards/homelabarr.json
```

### Step 8: Set Up Alerts
```bash
# Create alert rules for Prometheus
cat > prometheus/alerts.yml << 'EOF'
groups:
  - name: homelabarr
    rules:
      - alert: ContainerDown
        expr: up{job="docker"} == 0
        for: 2m
        annotations:
          summary: "Container {{ $labels.name }} is down"
          
      - alert: HighCPU
        expr: rate(container_cpu_usage_seconds_total[5m]) > 0.8
        for: 5m
        annotations:
          summary: "High CPU usage in {{ $labels.name }}"
          
      - alert: LowDiskSpace
        expr: node_filesystem_avail_bytes{mountpoint="/"} < 10737418240
        for: 5m
        annotations:
          summary: "Less than 10GB disk space remaining"
EOF
```

### Step 9: Configure Discord Notifications
```bash
# Set up webhook notifications in Uptime Kuma
# 1. Access Uptime Kuma at http://localhost:3001
# 2. Go to Settings > Notifications
# 3. Add Discord webhook:
#    - Friendly Name: HomelabARR Alerts
#    - Webhook URL: Your Discord webhook URL
#    - Bot Username: HomelabARR Monitor
```

### Monitoring Stack Access URLs
- **Grafana**: http://localhost:3000 (admin/admin)
- **Prometheus**: http://localhost:9090
- **Netdata**: http://localhost:19999
- **Uptime Kuma**: http://localhost:3001
- **Loki**: http://localhost:3100

### Pre-configured Monitoring for HomelabARR Services
The monitoring stack automatically tracks:
- Container health and resource usage
- Service availability and response times
- Download speeds and queue sizes
- Media server transcoding metrics
- Storage utilization
- Network performance
- SSL certificate expiration
- Authentication service status

---

## 6️⃣ Combined Deployment (All Components)

For the complete HomelabARR experience with all components:

### Step 1: Install Infrastructure (HomelabARR CLI)
```bash
# Clone and setup CLI
git clone https://github.com/smashingtags/homelabarr-cli.git
cd homelabarr-cli
sudo ./install.sh

# Choose installation mode:
# - Option 1 for Traefik (production)
# - Option 2 for applications
```

### Step 2: Install Volume Driver
```bash
# Install local-persist
wget https://github.com/smashingtags/local-persist/releases/latest/download/local-persist-linux-amd64
sudo mv local-persist-linux-amd64 /usr/local/bin/local-persist
sudo chmod +x /usr/local/bin/local-persist

# Create systemd service (see above)
sudo systemctl enable --now local-persist
```

### Step 3: Deploy Web Interface
```bash
# Clone web interface
cd /opt
git clone https://github.com/smashingtags/homelabarr-web.git
cd homelabarr-web

# Deploy with Traefik labels (if using Traefik)
cat > docker-compose.yml << 'EOF'
version: '3.8'

networks:
  proxy:
    external: true

services:
  homelabarr-frontend:
    image: ghcr.io/smashingtags/homelabarr-frontend:latest
    container_name: homelabarr-frontend
    networks:
      - proxy
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.homelabarr.rule=Host(`homelabarr.${DOMAIN}`)"
      - "traefik.http.routers.homelabarr.tls.certresolver=cloudflare"
      - "traefik.http.services.homelabarr.loadbalancer.server.port=80"
    environment:
      - REACT_APP_API_URL=https://api.${DOMAIN}
    restart: unless-stopped

  homelabarr-backend:
    image: ghcr.io/smashingtags/homelabarr-backend:latest
    container_name: homelabarr-backend
    networks:
      - proxy
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.homelabarr-api.rule=Host(`api.${DOMAIN}`)"
      - "traefik.http.routers.homelabarr-api.tls.certresolver=cloudflare"
      - "traefik.http.services.homelabarr-api.loadbalancer.server.port=8080"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - ./config:/config
      - ./data:/data
    environment:
      - DB_PATH=/data/homelabarr.db
    restart: unless-stopped
EOF

docker compose up -d
```

### Step 4: Access Everything
```bash
# Local CLI Menu
/opt/homelabarr-cli/homelabarr-cli.sh

# Web Interface (if Traefik)
https://homelabarr.yourdomain.com

# Web Interface (if local)
http://localhost:3000

# Traefik Dashboard
https://traefik.yourdomain.com

# Authelia Portal
https://auth.yourdomain.com
```

---

## 🔧 Troubleshooting Guide

### Common Issues and Solutions

#### 1. Docker Permission Errors
```bash
# Fix docker permissions
sudo usermod -aG docker $USER
newgrp docker

# Verify
docker ps
```

#### 2. Port Conflicts
```bash
# Check port usage
sudo netstat -tulpn | grep :8080

# Stop conflicting service
sudo systemctl stop conflicting-service

# Or change port in docker-compose.yml
```

#### 3. Traefik SSL Certificate Issues
```bash
# Check Traefik logs
docker logs traefik

# Verify Cloudflare API credentials
curl -X GET "https://api.cloudflare.com/client/v4/user/tokens/verify" \
  -H "Authorization: Bearer YOUR_API_TOKEN"

# Force certificate renewal
docker exec traefik rm -rf /letsencrypt/acme.json
docker restart traefik
```

#### 4. Authelia Authentication Problems
```bash
# Check Authelia logs
docker logs authelia

# Verify configuration
docker exec authelia authelia validate-config

# Reset user password
docker exec authelia authelia users reset-password username
```

#### 5. Local-Persist Volume Issues
```bash
# Check service status
sudo systemctl status local-persist

# View logs
sudo journalctl -u local-persist -f

# Restart service
sudo systemctl restart local-persist
```

#### 6. Container Won't Start
```bash
# Check logs
docker logs container-name

# Inspect container
docker inspect container-name

# Remove and recreate
docker rm -f container-name
docker compose up -d container-name
```

#### 7. Web Interface Connection Issues
```bash
# Verify backend is running
curl http://localhost:8080/health

# Check Docker socket permissions
ls -la /var/run/docker.sock

# Test Docker API access
docker exec homelabarr-backend docker ps
```

---

## 📊 Performance Tuning

### Docker Configuration
```bash
# Edit Docker daemon config
sudo nano /etc/docker/daemon.json

{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}

# Restart Docker
sudo systemctl restart docker
```

### System Optimization
```bash
# Increase file limits
echo "fs.file-max = 100000" | sudo tee -a /etc/sysctl.conf
echo "* soft nofile 100000" | sudo tee -a /etc/security/limits.conf
echo "* hard nofile 100000" | sudo tee -a /etc/security/limits.conf

# Apply changes
sudo sysctl -p
```

---

## 🔐 Security Best Practices

### 1. Secure Environment Variables
```bash
# Never commit .env files
echo ".env" >> .gitignore

# Use Docker secrets for sensitive data
echo "password" | docker secret create db_password -
```

### 2. Network Isolation
```yaml
# Create isolated networks
networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge
    internal: true
```

### 3. Regular Updates
```bash
# Update all containers
docker compose pull
docker compose up -d

# Update system
sudo apt update && sudo apt upgrade -y
```

### 4. Backup Configuration
```bash
# Automated backup script
#!/bin/bash
BACKUP_DIR="/backups/homelabarr/$(date +%Y%m%d)"
mkdir -p "$BACKUP_DIR"

# Backup Docker volumes
docker run --rm -v homelabarr_config:/data -v "$BACKUP_DIR":/backup \
  alpine tar czf /backup/config.tar.gz /data

# Backup database
docker exec homelabarr-backend sqlite3 /data/homelabarr.db ".backup /backup/homelabarr.db"
```

---

## 📚 Additional Resources

### Documentation
- [HomelabARR Wiki](https://github.com/smashingtags/homelabarr-cli/wiki)
- [Docker Documentation](https://docs.docker.com/)
- [Traefik Documentation](https://doc.traefik.io/traefik/)
- [Authelia Documentation](https://www.authelia.com/docs/)

### Support
- GitHub Issues: [homelabarr-cli/issues](https://github.com/smashingtags/homelabarr-cli/issues)
- Discord Community: [Join Discord](#)
- Reddit: [r/homelabarr](#)

### Related Projects
- [LinuxServer.io](https://www.linuxserver.io/)
- [Awesome-Selfhosted](https://github.com/awesome-selfhosted/awesome-selfhosted)
- [Heimdall Application Dashboard](https://heimdall.site/)

---

## 🎯 Quick Reference

### Essential Commands
```bash
# View all containers
docker ps -a

# View logs
docker logs -f container-name

# Restart container
docker restart container-name

# Update single container
docker compose pull service-name
docker compose up -d service-name

# System cleanup
docker system prune -a

# Check resource usage
docker stats
```

### Default Ports Reference
| Service | Local Mode | Traefik Mode |
|---------|------------|--------------|
| **Media Servers** | | |
| Plex | 32400 | plex.domain.com |
| Jellyfin | 8096 | jellyfin.domain.com |
| Emby | 8920 | emby.domain.com |
| **Media Management** | | |
| Radarr | 7878 | radarr.domain.com |
| Sonarr | 8989 | sonarr.domain.com |
| Lidarr | 8686 | lidarr.domain.com |
| Bazarr | 6767 | bazarr.domain.com |
| Prowlarr | 9696 | prowlarr.domain.com |
| **Download Clients** | | |
| qBittorrent | 8082 | qbittorrent.domain.com |
| SABnzbd | 8085 | sabnzbd.domain.com |
| NZBGet | 6789 | nzbget.domain.com |
| **Request Management** | | |
| Overseerr | 5055 | overseerr.domain.com |
| Tautulli | 8181 | tautulli.domain.com |
| **Monitoring Stack** | | |
| Grafana | 3000 | grafana.domain.com |
| Prometheus | 9090 | prometheus.domain.com |
| Netdata | 19999 | netdata.domain.com |
| Uptime Kuma | 3001 | status.domain.com |
| Loki | 3100 | loki.domain.com |
| **Infrastructure** | | |
| Traefik Dashboard | 8080 | traefik.domain.com |
| Authelia | 9091 | auth.domain.com |
| Portainer | 9000 | portainer.domain.com |
| **HomelabARR Components** | | |
| HomelabARR Web | 3000 | homelabarr.domain.com |
| HomelabARR API | 8080 | api.domain.com |

---

*Last Updated: 2025-08-19*
*Version: 1.0.0*
*HomelabARR Ecosystem - Complete Deployment Guide*