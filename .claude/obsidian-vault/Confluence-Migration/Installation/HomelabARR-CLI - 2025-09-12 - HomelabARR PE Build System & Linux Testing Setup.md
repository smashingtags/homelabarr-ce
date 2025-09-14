---
title: "HomelabARR-CLI : 2025-09-12 - HomelabARR PE Build System & Linux Testing Setup"
confluence_id: "18284550"
confluence_url: "https://your-instance.atlassian.net/wiki/spaces/DO/pages/18284550"
confluence_space: "DO"
category: "Installation"
created_date: "2025-09-12"
updated_date: "2025-09-12"
migrated_date: "2025-09-14"
tags: ['frontend', 'docker', 'golang', 'september-2025', 'storage']
---

# 🚀 HomelabARR PE Build System & Linux Testing Setup

## Session Summary

**Date**: September 12, 2025**Focus**: Complete CI/CD pipeline creation and Linux testing environment setup
## 🎯 Major Accomplishments

### 1. Complete Build System Created

- ✅**GitHub Actions Workflow**(`build-release.yml`)
- Multi-platform builds (Linux AMD64/ARM64)
- Manual triggers with build options
- Self-hosted runner support
- 

Docker image creation
- 

✅**Build Files Created**:
- `.air.toml`- Hot reload development
- `.goreleaser.yml`- Automated releases
- Updated`Dockerfile`and`Makefile`
### 2. Platform Decision: Linux-Only

**Removed Windows Support**- Executive decision for NAS stability: - Windows Updates = Random reboots (unacceptable for NAS) - Storage Spaces unreliable vs SnapRAID - Too much platform conditional logic -**Linux = Rock-solid NAS platform**
### 3. Linux Testing Environment Ready

**VM 104 (192.168.1.229)**- homelabarr-cli:
```
- Ubuntu 25.04
- Docker 27.5.1
- Go 1.21.5 ✅ Installed
- SnapRAID 12.4 ✅ Installed  
- MergerFS 2.33.5 ✅ Installed
- 6 cores, 17GB RAM
- 108GB available disk
```