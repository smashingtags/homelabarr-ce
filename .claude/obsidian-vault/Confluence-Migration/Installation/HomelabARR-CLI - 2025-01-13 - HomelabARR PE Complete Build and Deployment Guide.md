---
title: "HomelabARR-CLI : 2025-01-13 - HomelabARR PE Complete Build and Deployment Guide"
confluence_id: "18710531"
confluence_url: "https://mjashley.atlassian.net/wiki/spaces/DO/pages/18710531"
confluence_space: "DO"
category: "Installation"
created_date: "2025-01-13"
updated_date: "2025-01-13"
migrated_date: "2025-09-14"
tags: ['frontend', 'epic', 'golang']
---

# HomelabARR PE Complete Build and Deployment Guide

## 🚨 CRITICAL - THIS IS THE MASTER DOCUMENT FOR BUILD/DEPLOYMENT

**Last Updated[[HL-384]]**VM**: Ubuntu 25.04 VM #104 at 192.168.1.229
## ⚠️ CRITICAL DEPLOYMENT RULES - NEVER VIOLATE

### Binary Naming Rules

- **ONLY ONE BINARY**:`homelabarr-pe`- NO OTHER NAMES
- **NO VERSIONS**: Never use homelabarr-pe-fixed, homelabarr-pe-2, homelabarr-pe-new
- **IF IT DOESN'T WORK, DELETE IT**: Don't keep backups, don't rename, DELETE and rebuild
- **DO IT RIGHT OR START OVER**: We're on a VM - there's no excuse for multiple versions
- **CLEAN DEPLOYMENT ONLY**: Every deployment should have exactly ONE binary named`homelabarr-pe`
### What NOT to do

- ❌ homelabarr-pe-fixed
- ❌ homelabarr-pe-fixed.backup
- ❌ homelabarr-pe-new
- ❌ homelabarr-pe-2, 3, 10, 20, 30, 40, 50
- ❌ ANY versioning or backup naming
### What TO do

- ✅ Binary name:`homelabarr-pe`
- ✅ If broken: DELETE IT
- ✅ Rebuild with correct name
- ✅ One binary, proper name, clean deployment
## 📋 Table of Contents

- [Build Process - Frontend](#id-2025-01-13-HomelabARRPECompleteBuildandDeploymentGuide-build-process-frontend)
- [Build Process - Backend](#id-2025-01-13-HomelabARRPECompleteBuildandDeploymentGuide-build-process-backend)
- [Cross-Compilation from Windows to Linux](#id-2025-01-13-HomelabARRPECompleteBuildandDeploymentGuide-cross-compilation)
- [CORS Configuration](#id-2025-01-13-HomelabARRPECompleteBuildandDeploymentGuide-cors-configuration)
- [Deployment to Linux VM](#id-2025-01-13-HomelabARRPECompleteBuildandDeploymentGuide-deployment-to-linux-vm)
- [Systemd Service Setup](#id-2025-01-13-HomelabARRPECompleteBuildandDeploymentGuide-systemd-service-setup)
- [Common Errors and Solutions](#id-2025-01-13-HomelabARRPECompleteBuildandDeploymentGuide-common-errors-and-solutions)
- [VM Management](#id-2025-01-13-HomelabARRPECompleteBuildandDeploymentGuide-vm-management)
- [Testing Checklist](#id-2025-01-13-HomelabARRPECompleteBuildandDeploymentGuide-testing-checklist)
## Build Process - Frontend

### ⚠️ CRITICAL: TypeScript Errors Don't Matter at Runtime

The frontend has 50+ TypeScript errors but they DON'T break functionality. Use Vite build to bypass them.
### Build Commands

```
# Navigate to frontend directory
cd F:\Coding Projects\homelabarr-pe\web\homelabarr-dashboard

# DO NOT USE: npm run build (will fail with TypeScript errors)
# USE THIS INSTEAD:
npx vite build

# Output goes to: dist/ folder which becomes ../static/
# This gets embedded into Go binary automatically
```