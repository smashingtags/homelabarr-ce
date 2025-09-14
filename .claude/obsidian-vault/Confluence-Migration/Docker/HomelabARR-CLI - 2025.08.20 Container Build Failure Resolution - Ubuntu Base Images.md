---
title: "HomelabARR-CLI : 2025.08.20 Container Build Failure Resolution - Ubuntu Base Images"
confluence_id: "6815843"
confluence_url: "https://mjashley.atlassian.net/wiki/spaces/DO/pages/6815843"
confluence_space: "DO"
category: "Docker"
created_date: ""
updated_date: ""
migrated_date: "2025-09-14"
tags: ['frontend', 'media-server', 'epic', 'docker']
---

# Container Build Failure Resolution - Ubuntu Base Images

## Date: August 20, 2025[[HL-143]]
## Executive Summary

Resolved critical build failures for three base image containers that were blocking the entire HomelabARR v2.0 container pipeline. The fixes involved transitioning from complex rootfs-based builds to official Ubuntu Docker images and cleaning up legacy directory structures.
## Affected Containers

- `homelabarr-ubuntu-focal`(Ubuntu 20.04)
- `homelabarr-ubuntu-jammy`(Ubuntu 22.04)
- `homelabarr-ui`(Alpine-based UI)
## Root Cause Analysis

### 1. Path Reference Issues

- **Problem**: Dockerfiles contained hardcoded paths referencing old`docker-ubuntu-*`directories
- **Impact**: Build failures with "file not found" errors
- **Fix**: Updated all COPY paths to use`homelabarr-ubuntu-*`
### 2. Missing Dependencies

- **Problem**: xz-utils package missing for s6-overlay extraction
- **Impact**: "xz: Cannot exec: No such file or directory" errors
- **Fix**: Added`apt-get install xz-utils`before extraction
### 3. PyYAML Build Failures

- **Problem**: docker-compose==1.29.2 causing Cython dependency conflicts
- **Impact**: AttributeError: cython_sources during pip install
- **Fix**: Replaced with docker==6.1.3 package
### 4. Architecture Support

- **Problem**: Dockerfiles hardcoded to AMD64 only
- **Impact**: QEMU emulation errors for ARM64 builds
- **Fix**: Added TARGETPLATFORM ARG for dynamic architecture selection
### 5. Missing Directories

- **Problem**: patch/ and root/ directories missing after rename
- **Impact**: Build failures due to missing required files
- **Fix**: Copied directories from docker-ubuntu-focal
### 6. Version Tagging

- **Problem**: All containers stuck at v1.0.0
- **Impact**: No version differentiation between builds
- **Fix**: Implemented SHA-based versioning (type=sha,prefix=v-)
### 7. Build Order

- **Problem**: Problematic containers buried in build matrix
- **Impact**: Slow debugging cycles
- **Fix**: Reordered matrix to build problematic containers first
### 8. Base Image Architecture

- **Problem**: Building FROM scratch with rootfs tarballs
- **Impact**: Missing dpkg infrastructure, exit code 100 errors
- **Fix**: Switched to official Ubuntu Docker images
### 9. Legacy Directory Conflicts

- **Problem**: Old docker-* directories still present
- **Impact**: Build picking wrong Dockerfiles
- **Fix**: Removed all 412 legacy docker-* files
## Implementation Details

### Ubuntu Dockerfile Simplification

```
# Before: Complex rootfs build
FROM alpine:3.15 as rootfs-stage
RUN curl -o /rootfs.tar.gz -L https://partner-images.canonical.com/core/...
FROM scratch
COPY --from=rootfs-stage /root-out/ /

# After: Official Ubuntu base
FROM ubuntu:22.04
```