# System Requirements

## 📋 Minimum Requirements

### Hardware
- **CPU**: 2 cores (x86_64 architecture)
- **RAM**: 4GB minimum
- **Storage**: 20GB for system and containers
- **Network**: Stable internet connection

### Operating System
- **Ubuntu**: 20.04 LTS, 22.04 LTS (recommended)
- **Debian**: 10 (Buster), 11 (Bullseye), 12 (Bookworm)
- **Other Linux**: May work but not officially supported
- **Windows**: WSL2 with Ubuntu (experimental)
- **macOS**: Docker Desktop (experimental)
- **ARM**: Currently not supported (planned for future)

### Software Prerequisites
```bash
# Required
docker --version      # 20.10.0 or higher
docker-compose --version  # 2.0.0 or higher
git --version        # 2.0 or higher

# Optional but recommended
curl --version       # For downloading scripts
wget --version       # Alternative to curl
nano --version       # For editing config files
```

## 💪 Recommended Requirements

### Hardware
- **CPU**: 4+ cores
- **RAM**: 8GB or more
- **Storage**: 
  - 50GB for system and containers
  - 1TB+ for media storage
- **Network**: Gigabit ethernet

### For Production Deployment
- **Static IP**: Required for reliable access
- **Domain Name**: Required for SSL/HTTPS
- **Cloudflare Account**: Free tier sufficient
- **Open Ports**: 80, 443 (for web access)

## 🚀 Performance Tiers

### Basic Home Lab (5-10 containers)
- **CPU**: 2 cores
- **RAM**: 4GB
- **Storage**: 100GB SSD
- **Example Apps**: Plex, Radarr, Sonarr

### Standard Setup (10-30 containers)
- **CPU**: 4 cores
- **RAM**: 8GB
- **Storage**: 250GB SSD + 2TB HDD
- **Example Stack**: Full media suite + monitoring

### Power User (30-100 containers)
- **CPU**: 8+ cores
- **RAM**: 16GB+
- **Storage**: 500GB SSD + 8TB+ HDD
- **Example**: Complete ecosystem with all features

### Enterprise (100+ containers)
- **CPU**: 16+ cores
- **RAM**: 32GB+
- **Storage**: 1TB NVMe + 20TB+ storage array
- **Network**: 10Gbit networking recommended

## 🐳 Docker Installation

### Ubuntu/Debian Quick Install
```bash
# Official Docker installation script
curl -fsSL https://get.docker.com | sudo bash

# Add user to docker group
sudo usermod -aG docker $USER

# Install Docker Compose v2
sudo apt update
sudo apt install docker-compose-plugin

# Verify installation
docker --version
docker compose version
```

### Manual Installation
```bash
# Update package index
sudo apt update
sudo apt install ca-certificates curl gnupg

# Add Docker's official GPG key
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Set up repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

## 🌐 Network Requirements

### Local Mode
- **Ports**: Various (32400, 7878, 8989, etc.)
- **Firewall**: Allow Docker network
- **DNS**: Local DNS resolution

### Production Mode
- **Domain**: Valid domain with DNS control
- **Cloudflare**: Account with API access
- **Ports**: 80, 443 (HTTP/HTTPS)
- **SSL**: Automatic via Let's Encrypt

### Cloudflare Configuration
1. Create Cloudflare account
2. Add your domain
3. Update nameservers at registrar
4. Configure DNS settings:
   - SSL/TLS: Full (not Full Strict)
   - Always Use HTTPS: On
   - Automatic HTTPS Rewrites: On
   - Minimum TLS Version: 1.2

## 💾 Storage Planning

### Directory Structure
```
/opt/homelabarr/          # Application root
├── config/               # Container configurations
├── data/                 # Application data
├── logs/                 # Application logs
└── media/                # Media storage
    ├── movies/
    ├── tv/
    ├── music/
    └── downloads/
```

### Recommended Filesystems
- **ext4**: Standard, reliable
- **btrfs**: Snapshots, compression
- **zfs**: Advanced features, high RAM usage
- **mergerfs**: Combine multiple drives

### Permissions
```bash
# Standard permissions
sudo chown -R 1000:1000 /opt/homelabarr
sudo chmod -R 755 /opt/homelabarr
```

## 🔒 Security Considerations

### Firewall Setup
```bash
# Ubuntu/Debian with UFW
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 80/tcp    # HTTP
sudo ufw allow 443/tcp   # HTTPS
sudo ufw allow 32400/tcp # Plex (if needed externally)
sudo ufw enable
```

### User Permissions
```bash
# Create dedicated user
sudo useradd -m -s /bin/bash homelabarr
sudo usermod -aG docker homelabarr

# Set PUID/PGID in .env
id homelabarr  # Note the uid and gid
```

## 🔍 Pre-Installation Checks

### System Check Script
```bash
#!/bin/bash
echo "=== System Requirements Check ==="

# Check OS
echo -n "OS: "
cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2

# Check CPU
echo -n "CPU Cores: "
nproc

# Check RAM
echo -n "RAM: "
free -h | grep Mem | awk '{print $2}'

# Check Disk
echo -n "Disk Space: "
df -h / | tail -1 | awk '{print $4}'

# Check Docker
echo -n "Docker: "
docker --version 2>/dev/null || echo "Not installed"

# Check Docker Compose
echo -n "Docker Compose: "
docker compose version 2>/dev/null || echo "Not installed"

# Check Git
echo -n "Git: "
git --version 2>/dev/null || echo "Not installed"

echo "=== End of Check ==="
```

## ⚠️ Known Limitations

### Not Supported
- ARM processors (Raspberry Pi, Apple Silicon native)
- 32-bit systems
- Windows native (use WSL2)
- FreeBSD, OpenBSD
- Container orchestrators (Kubernetes, Swarm)

### Experimental Support
- WSL2 on Windows
- Docker Desktop on macOS
- Podman as Docker alternative

## 📚 Next Steps

Once requirements are met:
1. Follow [Quick Start Guide](./QUICKSTART.md)
2. Choose deployment method
3. Configure environment
4. Deploy applications

---

**Need Help?** Join our [Discord](https://discord.gg/Pc7mXX786x) for support!