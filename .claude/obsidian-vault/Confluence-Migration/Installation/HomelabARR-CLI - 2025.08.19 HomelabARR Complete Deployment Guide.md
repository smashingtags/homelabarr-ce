---
title: "HomelabARR-CLI : 2025.08.19 HomelabARR Complete Deployment Guide"
confluence_id: "6029314"
confluence_url: "https://mjashley.atlassian.net/wiki/spaces/DO/pages/6029314"
confluence_space: "DO"
category: "Installation"
created_date: "2025-08-19"
updated_date: "2025-08-19"
migrated_date: "2025-09-14"
tags: ['frontend', 'docker', 'traefik', 'golang', 'monitoring', 'storage']
---

# HomelabARR Ecosystem - Complete Deployment Guide

## System Architecture Overview

HomelabARR is a comprehensive Docker-based infrastructure ecosystem with multiple deployment modes:
- **HomelabARR CLI**- Core infrastructure management (Traefik or Local mode)
- **HomelabARR Web**- React frontend + Go backend management UI
- **Local-Persist**- Go-based Docker volume driver for persistent storage
- **Monitoring Stack**- Netdata, Grafana, Prometheus, Loki, Uptime Kuma
- **179+ Applications**- Pre-configured containerized services
## Prerequisites

### System Requirements

- **OS**: Ubuntu 20.04+ or Debian 11+ (Linux only, no ARM)
- **CPU**: Minimum 2 cores, recommended 4+ cores
- **RAM**: Minimum 4GB, recommended 8GB+ for production
- **Storage**: Minimum 20GB system, 100GB+ for media
- **Docker**: Version 20.10.0+
- **Docker Compose**: Version 2.0.0+
## Installation Methods

### Method 1: Local Mode (Quick Start with Colored CLI)

Perfect for testing and home use without reverse proxy.
```
# Clone repository
git clone https://github.com/smashingtags/homelabarr-cli.git
cd homelabarr-cli

# Make scripts executable
chmod +x install.sh homelabarr-cli.sh
find scripts/ apps/ traefik/ -name "*.sh" -exec chmod +x {} \;

# Create compatibility symlink
sudo ln -sf "$(pwd)" /opt/homelabarr

# Install Docker if needed
sudo ./install.sh  # Select option 0 for preinstall

# Launch beautiful colored CLI
./homelabarr-cli.sh
```