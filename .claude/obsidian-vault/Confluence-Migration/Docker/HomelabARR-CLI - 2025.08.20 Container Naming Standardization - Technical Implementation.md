---
title: "HomelabARR-CLI : 2025.08.20 Container Naming Standardization - Technical Implementation"
confluence_id: "6914051"
confluence_url: "https://mjashley.atlassian.net/wiki/spaces/DO/pages/6914051"
confluence_space: "DO"
category: "Docker"
created_date: ""
updated_date: ""
migrated_date: "2025-09-14"
tags: ['frontend', 'storage', 'docker']
---

# Container Naming Standardization - Technical Implementation

## Overview

Completed full migration of container naming from`docker-*`prefix to`homelabarr-*`prefix across the HomelabARR ecosystem on January 20, 2025.
## Implementation Details

### Repositories Affected

- **homelabarr-cli**: Main CLI repository with Docker Compose configurations
- **homelabarr-containers**: Container build repository with GitHub Actions workflows
## Changes Made

### 1. GitHub Actions Workflow Optimization

**File**:`.github/workflows/build-all-containers.yml`
#### Before

- 52 total containers in build matrix
- Duplicate entries for docker-*and homelabarr-*versions
- Unnecessary build time and resource usage
#### After

- 25 total containers (52% reduction)
- Only homelabarr-* prefixed containers
- Significant reduction in build times
### 2. Container Fixes Applied

#### Docker Mods (7 containers)

Removed duplicates: - docker-mod-healthcheck → homelabarr-mod-healthcheck - docker-mod-nzbget → homelabarr-mod-nzbget - docker-mod-qbittorrent → homelabarr-mod-qbittorrent - docker-mod-rclone → homelabarr-mod-rclone - docker-mod-sabnzbd → homelabarr-mod-sabnzbd - docker-mod-storagecheck → homelabarr-mod-storagecheck - docker-mod-tautulli → homelabarr-mod-tautulli
#### Nightly Builds

- Removed duplicate docker-whisparr-nightly
- Kept only homelabarr-whisparr-nightly
### 3. Build Issues Resolved

#### Ubuntu Noble Base Container

**Problem**: COPY path failure in GitHub Actions
```
# Before (failed)
COPY root/ /

# After (working)
COPY base/docker-ubuntu-noble/root/ /
```