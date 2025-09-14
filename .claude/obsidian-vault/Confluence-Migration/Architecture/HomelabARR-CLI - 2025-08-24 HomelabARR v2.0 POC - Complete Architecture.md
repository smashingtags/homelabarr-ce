---
title: "HomelabARR-CLI : 2025-08-24 HomelabARR v2.0 POC - Complete Architecture"
confluence_id: "8978572"
confluence_url: "https://your-instance.atlassian.net/wiki/spaces/DO/pages/8978572"
confluence_space: "DO"
category: "Architecture"
created_date: "2025-08-24"
updated_date: "2025-08-24"
migrated_date: "2025-09-14"
tags: ['frontend', 'august-2025', 'docker', 'golang', 'security', 'monitoring', 'storage']
---

# 2025-08-24 HomelabARR v2.0 POC - Complete Architecture

## Overview

HomelabARR v2.0 is a complete rewrite focusing on simplicity, performance, and maintainability. All resources are now consolidated in the v2-poc directory for unified development.
## Core Components

### 1. Go Backend Server (simple-server.go)

- **Port**: 8082
- **Purpose**: API server for container management and app installation
- **Features**:
- Real Docker integration
- SSE for real-time updates
- Cross-platform support (Windows/Linux)
- Dynamic path detection
### 2. Web Dashboard (dashboard-unified.html)

- **Location**: v2-poc/web/
- **Features**:
- Unified navigation
- Iframe-based page loading
- Black theme consistency
- Real-time container status
### 3. Storage System

- **Backend**: storage-monitor.go
- **Frontend**: storage-array-widget.html
- **Features**:
- Real-time disk monitoring
- SSD/HDD detection
- SnapRAID preparation
- Cross-platform support
### 4. App Store

- **Templates**: 128 Docker applications
- **Location**: v2-poc/apps/
- **Categories**:
- Media Servers
- Download Clients
- Monitoring
- Security
- AI/ML Tools
## Architecture Decisions

### Why Go?

- Single binary deployment
- No runtime dependencies
- Excellent Docker support
- Fast compilation
- Cross-platform
### Why Not Node.js?

- Avoided npm dependency hell
- Simpler deployment
- Better performance
- Cleaner architecture
### Storage Architecture

- Following Perfect Media Server patterns
- SnapRAID + MergerFS ready
- Intelligent drive categorization
- Real-time monitoring
## API Endpoints

```
GET  /api/containers     - List all containers
GET  /api/storage        - Storage information
POST /api/install        - Install application
GET  /api/apps           - List available apps
GET  /stream/progress    - SSE deployment progress
GET  /api/settings       - Get settings
POST /api/settings       - Save settings
```