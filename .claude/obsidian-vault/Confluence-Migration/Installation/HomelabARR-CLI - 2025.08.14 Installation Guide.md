---
title: "HomelabARR-CLI : 2025.08.14 Installation Guide"
confluence_id: "3866629"
confluence_url: "https://mjashley.atlassian.net/wiki/spaces/DO/pages/3866629"
confluence_space: "DO"
category: "Installation"
created_date: "2025-08-16"
updated_date: "2025-08-16"
migrated_date: "2025-09-14"
tags: ['frontend', 'august-2025', 'docker', 'traefik', 'project-management', 'security', 'authelia', 'monitoring', 'storage']
---

[[Confluence Space (hlcli)]]-**Related Issues**: Installation improvements tracked in Jira
### Current Project Status

Repository modernization has been completed successfully: -**✅ Repository Cleanup v2.2**: Professional organization completed (August 16, 2025) -**✅ YAML Standardization**: 489 files updated and validated -**✅ Health Check Implementation**: Standardized across all applications -**✅ Traefik Infrastructure**: v3.5.0 confirmed operational and optimized -**✅ Branding Update**: Complete migration to HomelabARR CLI

For the latest project status, check the[Project Management](./Project-Management)page.
## Prerequisites

### System Requirements

- **Operating System**: Ubuntu 18.04+ or Debian 10+
- **Architecture**: x86_64 (AMD64) - ARM not supported
- **CPU**: Minimum 2 cores, recommended 4+ cores
- **RAM**: Minimum 4GB, recommended 8GB+
- **Storage**: Minimum 20GB free space, recommended 100GB+
- **Network**: Stable internet connection
### Required Software

- **Docker**: Version 20.10 or later
- **Docker Compose**: Version 2.0 or later
- **Git**: For cloning the repository
- **Curl**: For downloading scripts
### Domain Requirements

- Valid domain name registered
- Cloudflare account with domain configured
- Cloudflare API token with Zone:Read, DNS:Edit permissions
## Pre-Installation Setup

### 1. System Updates

```
`# Update system packages
sudo apt update && sudo apt upgrade -y

# Install required packages
sudo apt install curl git wget -y
`
```

### 2. Docker Installation

```
`# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add user to docker group
sudo usermod -aG docker $USER

# Start and enable Docker
sudo systemctl start docker
sudo systemctl enable docker
`
```

### 3. Docker Compose Installation

```
`# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# Make executable
sudo chmod +x /usr/local/bin/docker-compose

# Verify installation
docker-compose --version
`
```

## HomelabARR CLI Installation

### 1. Clone Repository

```
`# Clone the HomelabARR CLI repository
git clone https://github.com/homelabarr/homelabarr-cli.git
cd homelabarr-cli
`
```

### 2. Configure Environment

```
`# Copy environment template
cp .env.example .env

# Edit environment variables
nano .env
`
```

### Required Environment Variables

```
`# Domain Configuration
DOMAIN=yourdomain.com
CLOUDFLARE_EMAIL=your-email@domain.com
CLOUDFLARE_API_KEY=your-cloudflare-api-key

# User Configuration
PUID=1000
PGID=1000
TZ=America/New_York

# Paths
DOCKERDIR=/opt/homelabarr
CONFIGDIR=/opt/appdata
`
```

### 3. Run Main Installation

```
`# Make installation script executable
chmod +x install.sh

# Run installation
sudo ./install.sh
`
```

### 4. Install Traefik Stack

```
`# Navigate to Traefik directory
cd traefik

# Make installation script executable
chmod +x install.sh

# Install Traefik
sudo ./install.sh
`
```

### 5. Install Applications

```
`# Navigate to apps directory
cd ../apps

# Install application stack
sudo ./apps/install.sh
`
```

## Post-Installation Configuration

### 1. Verify Installation

```
`# Check running containers
docker ps

# Check Traefik dashboard
curl -I https://traefik.yourdomain.com
`
```

### 2. Configure Authelia

```
`# Generate user password
docker run --rm -it authelia/authelia:latest authelia hash-password 'yourpassword'

# Update Authelia configuration
sudo nano /opt/appdata/authelia/configuration.yml
`
```

### 3. Initial Application Setup

- Access applications via[https://app.yourdomain.com](https://app.yourdomain.com)
- Complete initial setup wizards
- Configure application-specific settings
## Troubleshooting

### Common Issues

#### Permission Issues

```
`# Fix ownership
sudo chown -R $USER:$USER /opt/homelabarr
sudo chown -R $USER:$USER /opt/appdata
`
```

#### SSL Certificate Issues

```
`# Check Traefik logs
docker logs traefik

# Verify Cloudflare API connectivity
curl -X GET "https://api.cloudflare.com/client/v4/zones" \
     -H "Authorization: Bearer YOUR_API_TOKEN" \
     -H "Content-Type: application/json"
`
```

#### Container Startup Failures

```
`# Check specific container logs
docker logs container_name

# Restart container
docker restart container_name
`
```

#### Health Check Status

```
`# Check container health status
docker ps --format "table {{.Names}}\t{{.Status}}"

# All containers include standardized health checks as of v2.2
`
```

## Security Recommendations

### 1. Firewall Configuration

```
`# Enable UFW
sudo ufw enable

# Allow SSH
sudo ufw allow ssh

# Allow HTTP/HTTPS
sudo ufw allow 80
sudo ufw allow 443
`
```

### 2. Fail2Ban Setup

```
`# Install Fail2Ban
sudo apt install fail2ban -y

# Configure for SSH protection
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
`
```

### 3. Regular Updates

```
`# Update containers
docker-compose pull
docker-compose up -d

# Update system
sudo apt update && sudo apt upgrade -y
`
```

## Installation Support

### Getting Help

If you encounter issues during installation:
- **Join Discord Community**[[Jira Board]]
### Reporting Installation Issues

When creating Jira issues for installation problems:
- **Include system information**: OS version, Docker version, hardware specs
- **Provide error logs**: Include relevant error messages and logs
- **Describe environment**: Network setup, domain configuration, etc.
- **Reference this guide**: Mention which step failed and any modifications made
## Next Steps

After successful installation: 1. Configure individual applications via their web interfaces 2. Set up backup procedures using built-in backup tools 3. Configure monitoring and alerting 4. Review security settings and apply additional hardening 5. Join the community: -**Discord**:[discord.gg/Pc7mXX786x](https://discord.gg/Pc7mXX786x)- Get help and connect with users -**Support Development[[Confluence]]- Project documentation -[[Jira]]- Issue tracking
## Version Information

- **Last Updated**: 2025-08-16
- **Installation Guide Version**: 4.0
- **Compatible HomelabARR CLI Version**: Latest (main branch)
- [[Jira HL Project]].*