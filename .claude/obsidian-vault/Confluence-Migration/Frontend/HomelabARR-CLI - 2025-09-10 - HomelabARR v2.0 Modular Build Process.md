---
title: "HomelabARR-CLI : 2025-09-10 - HomelabARR v2.0 Modular Build Process"
confluence_id: "16678938"
confluence_url: "https://mjashley.atlassian.net/wiki/spaces/DO/pages/16678938"
confluence_space: "DO"
category: "Frontend"
created_date: "2025-09-10"
updated_date: "2025-09-10"
migrated_date: "2025-09-14"
tags: ['frontend', 'docker', 'traefik', 'golang', 'security', 'september-2025', 'epic', 'storage']
---

# HomelabARR v2.0 Modular Build Process[[HL-344]]completion, HomelabARR v2.0 now uses a**modular architecture**with business logic separated into domain-specific packages. This document covers the new build process and file structure.
## ⚠️**CRITICAL: Production Readiness Notes**

### **Stub Functions & TODO Items**

The current build**includes stub functions**that need implementation for full production deployment:
#### **Core Service Stubs (service-manager.go)**

- `deployNginxProxy()`- Nginx Proxy Manager deployment
- `deploySWAG()`- SWAG reverse proxy deployment
- `deployAuthentik()`- Authentik authentication service
- `deployKeycloak()`- Keycloak authentication service
#### **Storage System TODOs (pkg/storage/storage.go)**

- Linux syscalls for disk usage calculation (currently uses mock data)
- SnapRAID status parsing without shell commands
- Cross-platform storage detection improvements
#### **Configuration Security (settings-handler.go)**

- Cloudflare API key encryption (currently stored in plaintext)
- Enhanced security for sensitive configuration data
#### **State Management TODOs (pkg/state/manager.go)**

- Container deployment integration with Docker Compose
- Rollback logic using state snapshots
- Docker container timestamp parsing
- Environment variable parsing improvements

**Impact**: Server**compiles and runs successfully**with these stubs, but some advanced features require implementation for production use.
## 🏗️ Build Process

### Current Production Build Command

```
cd "F:\Coding Projects\homelabarr-cli\v2-poc"
go build -o server-with-cache-mover.exe simple-server.go settings-handler.go encryption.go template-processor.go cloudflare-handler.go service-manager.go
```