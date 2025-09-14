---
title: "HomelabARR-CLI : HomelabARR CLI Home"
confluence_id: "3899503"
confluence_url: "https://mjashley.atlassian.net/wiki/spaces/DO/pages/3899503"
confluence_space: "DO"
category: "General"
created_date: "2025-08-16"
updated_date: "2025-08-16"
migrated_date: "2025-09-14"
tags: ['frontend', 'media-server', 'docker', 'traefik', 'golang', 'servarr', 'project-management', 'security', 'authelia', 'monitoring']
---

# HomelabARR CLI Project Hub

Welcome to the HomelabARR CLI project space! This is your central hub for all HomelabARR CLI-related documentation, guides, and project information.
## 🎯 Project Overview

HomelabARR CLI is a comprehensive Docker-based media server stack with Traefik reverse proxy, Authelia authentication, and Cloudflare protection. It provides automated deployment and management of**100+ self-hosted applications**including Plex, Radarr, Sonarr, and many more.
## 🏗️ Core Architecture

### Primary Components

- **🐳 Docker Compose Stack**: All applications containerized with Docker
- **🔀 Traefik**: Reverse proxy with automatic SSL via Let's Encrypt & Cloudflare DNS
- **🔐 Authelia**: Multi-factor authentication and authorization middleware
- **☁️ Cloudflare Integration**: DNS management, DDoS protection, and WAF
- **📊 Monitoring Stack**: Comprehensive observability with Grafana, Prometheus, and Loki
### Supported Platforms

- **OS Support**: Ubuntu/Debian Linux only
- **Architecture**: x86_64 (no ARM support)
- **Minimum Requirements**: 2 CPU cores, 4GB RAM, 20GB disk
## 📋 Quick Navigation

### 📚 Documentation Sections

- [Installation Guide](./Installation-Guide)- Complete setup instructions
- [Application Categories](./Application-Categories)- Media servers, download clients, utilities
- **[Monitoring Stack](./HomelabARR-CLI-Monitoring-Stack)- Comprehensive observability with Grafana, Prometheus & Loki**
- [Configuration Management](./Configuration-Management)- Environment variables and templates
- [Security Features](./Security-Features)- Authelia, Cloudflare, and security scripts
- [Maintenance Guide](./Maintenance-Guide)- Backup, cleanup, and optimization
- [Development Guidelines](./Development-Guidelines)[[HomelabARR CLI (hlcli)]]
- **Wiki Documentation**:[GitHub Pages Wiki](https://homelabarr.github.io/homelabarr-cli/)
#### **💻 Development Resources**

- **GitHub Repository**:[HomelabARR CLI Project](https://github.com/homelabarr/homelabarr-cli)
- **Issue Templates**: Available in Jira project for consistent reporting
- **Development Workflow**: See[Project Management](./Project-Management)documentation
#### **🤝 Community & Support**

- **Discord Server**:[Join HomelabARR Community](https://discord.gg/Pc7mXX786x)
- **Donations**:[Support Development](https://ko-fi.com/homelabarr)
- **Project Team**: Michael Ashley (Project Lead)
- **Contribution Guidelines**: See[Development Guidelines](./Development-Guidelines)
## 🚀 Quick Start

### Installation Commands

```
`# Main installation (Ubuntu/Debian only)
sudo ./install.sh

# Install Traefik stack
sudo ./traefik/install.sh

# Install applications
sudo ./apps/install.sh

# Install monitoring stack
sudo ./apps/install.sh
# Select: monitoring -> grafana-loki-prometheus
`
```

### Prerequisites Checklist

- [ ] Ubuntu/Debian Linux system
- [ ] Docker and Docker Compose installed
- [ ] Valid domain with Cloudflare DNS management
- [ ] Cloudflare API credentials
- [ ] Minimum system requirements met
## 📊 Project Status & Current Work

### 🔄 Recent Achievements

**Repository Modernization v2.2**- ✅**Complete (August 16, 2025)**-**Goal**: Professional repository organization and branding update -**Status**: ✅ Complete - 863 files organized, 29,785 lines cleaned, 489 YAML files standardized -**Results**: Professional structure ready for community growth and wider adoption

**Monitoring Stack Implementation**- ✅**Complete (August 16, 2025)**-**Goal**: Comprehensive observability solution with Grafana, Prometheus, and Loki -**Status**: ✅ Complete - Full monitoring stack with pre-built dashboards and automated service discovery -**Results**: Production-ready monitoring with infrastructure, media server, and security dashboards
### Recent Major Accomplishments

- ✅**Comprehensive Monitoring Stack**: Grafana, Prometheus, Loki with pre-built dashboards
- ✅ Major repository cleanup and organization (v2.2)
- ✅ Comprehensive branding update from DockServer to HomelabARR CLI
- ✅ YAML standardization across 489 application files
- ✅ Professional documentation structure established
- ✅ Jira project board migrated and organized (HL project)
- ✅ Health check standardization across all applications
- ✅ Traefik v3.5.0 infrastructure confirmed and optimized
### Current Focus Areas

- **Enhanced Documentation**- Community onboarding improvements and comprehensive guides
- **Performance Optimization**- Resource efficiency improvements and monitoring enhancements
- **Security Hardening**- Advanced authentication and protection measures
- **Community Growth**- Discord engagement and contributor onboarding
### Project Metrics

- **Total Applications**: 100+ supported containers
- **Monitoring Coverage**: Complete infrastructure and application observability
- **Repository Organization**: Professional structure with 863 files organized
- **Documentation Coverage**: Comprehensive setup and maintenance guides
- **Platform Support**: Ubuntu/Debian x86_64
- **Community**: Growing Discord community with active support
## 🛠️ Maintenance

### Regular Tasks

- **Docker Cleanup**:`sudo ./scripts/docker/dockerprune.sh`
- **System Backup**:`sudo ./backup.sh`
- **Plex Optimization**:`sudo ./scripts/plex/plex-optimize-db.sh`
- **Monitoring Health[[Jira Board]]
- **Documentation Updates**: Version controlled in Confluence
- **Container Health**: Standardized health checks across all applications
- **System Monitoring**: Real-time observability via[Monitoring Stack](./HomelabARR-CLI-Monitoring-Stack)
- **Security Updates**: Tracked and documented
## 🤝 Contributing

We welcome contributions! Here's how to get involved:
### Getting Started

- **Join Discord[[Jira Board]]for current tasks
- **Read Guidelines**: See[Development Guidelines](./Development-Guidelines)for standards
- **Create Issues**: Use Jira for bug reports and feature requests
### Support the Project

- **💰 Donate**:[Support development via Ko-fi](https://ko-fi.com/homelabarr)
- **[[Confluence hlcli Space]]*