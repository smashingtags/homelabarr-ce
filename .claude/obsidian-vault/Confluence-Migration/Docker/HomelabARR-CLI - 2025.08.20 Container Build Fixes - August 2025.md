---
title: "HomelabARR-CLI : 2025.08.20 Container Build Fixes - August 2025"
confluence_id: "7405571"
confluence_url: "https://your-instance.atlassian.net/wiki/spaces/DO/pages/7405571"
confluence_space: "DO"
category: "Docker"
created_date: ""
updated_date: ""
migrated_date: "2025-09-14"
tags: ['frontend', 'epic', 'media-server', 'docker', 'golang', 'security', 'monitoring']
---

# Container Build Fixes - August 2025

## Overview

Multiple container build failures were identified and resolved in the HomelabARR containers CI/CD pipeline.
## Issues Identified

### 1. homelabarr-crunchydl

**Problem**: Download URL returning 404 error - Original repository`homelabarr/multi-downloader-nx`no longer exists - Incorrect filename in download URL

**Solution**: - Updated to`anidl/multi-downloader-nx`repository - Changed VERSION from v1.17.6 to v5.5.1 - Fixed download URL to use`multi-downloader-nx-linux-cli.7z`
### 2. homelabarr-gdsa

**Problem**: ARM64 build failures with QEMU emulation errors - Google Cloud SDK doesn't properly support ARM64 architecture - QEMU emulator failing with "Invalid ELF image for this architecture"

**Solution**: - Modified GitHub Actions workflow to conditionally set platforms - GDSA now builds only for`linux/amd64`- All other containers continue multi-arch builds
### 3. homelabarr-gui

**Problem**: Missing Alpine packages -`ossp-uuid-dev`and`ossp-uuid`packages removed from Alpine repositories

**Solution**: - Replaced`ossp-uuid-dev`with`util-linux-dev`in build stage - Replaced`ossp-uuid`with`libuuid`in runtime stage - Removed deprecated edge/testing repository references
### 4. GitHub Actions Authentication

**Problem**: 403 Forbidden errors when pushing to GHCR - GitHub Actions masking "smashingtags" as secret (shown as ***) - Authentication failures with`${{ github.actor }}`

**Solution**: - Hardcoded`username: smashingtags`in all GHCR login sections - Ensures consistent authentication regardless of workflow trigger
## Technical Details

### Modified Files

- 

`.github/workflows/build-all-containers.yml`- Added platform detection for GDSA - Fixed GHCR authentication
- 

`apps/homelabarr-crunchydl/Dockerfile`- Updated repository and version - Fixed download URL
- 

`apps/homelabarr-gui/Dockerfile`- Replaced UUID packages - Removed deprecated repositories
## Verification

- All changes pushed to main branch
- GitHub Actions builds triggered automatically
- Monitoring build progress at:[https://github.com/smashingtags/homelabarr-containers/actions](https://github.com/smashingtags/homelabarr-containers/actions)
## Related Items[[HL-146]]
- **GitHub Commit**: dc19108
- **Build Status**: In Progress
## Lessons Learned

- External dependencies (like multi-downloader-nx) need monitoring for repository changes
- Alpine package deprecations require proactive updates
- ARM64 compatibility should be tested separately for complex dependencies
- GitHub Actions secret masking can cause authentication issues with hardcoded values
## Next Steps

- Monitor build completion[[HL-145]])