---
title: "HomelabARR-CLI : 2025.08.20 GHCR Package Cleanup - Docker to HomelabARR Migration"
confluence_id: "7372801"
confluence_url: "https://mjashley.atlassian.net/wiki/spaces/DO/pages/7372801"
confluence_space: "DO"
category: "Docker"
created_date: ""
updated_date: ""
migrated_date: "2025-09-14"
tags: ['frontend', 'docker']
---

# GHCR Package Cleanup - Docker to HomelabARR Migration

## Overview

This page documents the complete cleanup of legacy docker-*packages from GitHub Container Registry (GHCR) following the successful migration to homelabarr-*naming convention.
## Migration Summary

### Before Migration

- 25 packages with docker-* naming
- 560 total versions across all packages
- Namespace cluttered with old and new naming
### After Migration

- 0 docker-* packages remaining
- Clean namespace with only homelabarr-* packages
- All containers successfully building
## Final Container Fixes

### homelabarr-gdsa

**Issue**: QEMU emulator errors and duplicate musl package**Fix**: Removed duplicate musl package and simplified apk cleanup
### homelabarr-crunchydl

**Issue**: VERSION set to null causing wget failure**Fix**: Set valid VERSION=v1.17.6
### homelabarr-vnstat

**Issue**: Experimental Debian repos causing exit code 100**Fix**: Removed experimental/sid repos, use stable only
### homelabarr-local-persist

**Issue**: COPY path referencing ./root/ instead of app path**Fix**: Updated to ./apps/homelabarr-local-persist/root/
### homelabarr-gui

**Issue**: Trailing whitespace after libvorbis-dev breaking continuation**Fix**: Removed trailing whitespace
## GHCR Cleanup Process

### Cleanup Scripts Created

#### 1. cleanup-fast.sh

- Performs dry run by default
- Shows package count and version summary
- Requires "delete" parameter for actual deletion
#### 2. delete-packages-completely.sh

- Deletes entire packages (not just versions)
- Uses GitHub API to remove packages completely
### Cleanup Results
Package TypeCountVersionsDocker Mod Packages7242Base Images473App Containers13116Legacy/Other149**Total****25****560**