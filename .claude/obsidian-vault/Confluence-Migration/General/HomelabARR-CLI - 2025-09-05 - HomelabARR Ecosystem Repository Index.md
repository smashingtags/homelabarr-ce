---
title: "HomelabARR-CLI : 2025-09-05 - HomelabARR Ecosystem Repository Index"
confluence_id: "14385190"
confluence_url: "https://your-instance.atlassian.net/wiki/spaces/DO/pages/14385190"
confluence_space: "DO"
category: "General"
created_date: "2025-09-05"
updated_date: "2025-09-05"
migrated_date: "2025-09-14"
tags: ['frontend', 'docker', 'traefik', 'golang', 'security', 'september-2025', 'authelia', 'epic', 'storage']
---

# HomelabARR Ecosystem Repository Index

**Created**: 2025-09-05
**Purpose**: Quick reference index for all HomelabARR repositories accessible through MCP ref system
## 🏗️**Core Repository Structure**

### **1. homelabarr-cli**(Main Repository)

**Location**:`github.com/smashingtags/homelabarr-cli`
**Current Branch**:`feature/HL-257-react-build-pipeline`

**Purpose**: Primary CLI deployment tool and application catalog
**Key Features**: - 100+ pre-configured Docker Compose applications - Traefik reverse proxy integration
- Authelia authentication system - Local and production deployment modes - v2-poc Go implementation with React dashboard

**Critical Directories**: -`apps/`: Production Docker Compose templates -`v2-poc/`: Go backend + React frontend (current development) -`templates/`: Template processing system -`MASTER_DOCUMENTATION/`: Consolidated documentation hub -`traefik/`: Reverse proxy configurations
### **2. homelabarr-containers**(Container Build System)

**Location**:`github.com/smashingtags/homelabarr-containers`

**Purpose**: Custom Docker images and mods for HomelabARR ecosystem
**Registry**:`ghcr.io/smashingtags/`

**Key Components**: -**Docker Mods**:`homelabarr-mod-healthcheck`,`homelabarr-mod-qbittorrent`, etc. -**Base Images**: Alpine, Ubuntu, specialized bases -**Applications**: Custom app containers (uploader, gui, etc.) -**Build Pipeline**: GitHub Actions for automated builds
### **3. homelabarr**(Legacy Web Interface)

**Location**:`github.com/smashingtags/homelabarr`

**Purpose**: Original React web interface (pre v2-poc)
**Status**: Legacy - superseded by v2-poc implementation - Frontend: React application - Backend: Node.js with CLI Bridge integration - Docker images:`ghcr.io/smashingtags/homelabarr-frontend/backend`
### **4. homelabarr-web-interface**(React Web UI)

**Status**: Referenced in documentation but may be integrated into main CLI

**Purpose**: Modern web interface for container management - CLI-based Docker deployment - Cross-platform compatibility
- 90+ application templates - Real-time deployment progress tracking
### **5. homelabarr-uploader**(Automated Upload Service)

**Location**: Within homelabarr-containers

**Purpose**: Cloud upload automation for completed downloads - Multi-cloud provider support (Google Drive, Backblaze, OneDrive, pCloud) - Autoscan integration for media library updates - Bandwidth limiting and scheduling - Apprise notification support
### **6. homelabarr-assets**(Shared Resources)

**Purpose**: Common assets, documentation, and branding materials - Icons, templates, and shared configuration files
### **7. local-persist**(Volume Persistence Plugin)

**Purpose**: Docker volume persistence in custom host locations - Static Go binary for maximum compatibility - Essential for HomelabARR volume management
## 🚀**v2-POC Architecture (Current Development)**

### **Backend Implementation**(90 Go Files)

```
v2-poc/
├── cmd/homelabarr/           # CLI entry points
├── pkg/storage/             # SnapRAID + MergerFS + Cache Mover (7 files)
├── pkg/docker/              # Docker API integration  
├── pkg/state/               # LevelDB state management
├── pkg/stack/               # Template processing engine
├── simple-server.go         # Monolithic API server (159KB)
└── templates/               # 128 Docker Compose templates
```