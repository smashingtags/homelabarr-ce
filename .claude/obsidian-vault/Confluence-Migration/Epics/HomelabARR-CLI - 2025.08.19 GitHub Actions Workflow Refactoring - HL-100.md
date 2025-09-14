---
title: "HomelabARR-CLI : 2025.08.19 GitHub Actions Workflow Refactoring - HL-100"
confluence_id: "6422531"
confluence_url: "https://mjashley.atlassian.net/wiki/spaces/DO/pages/6422531"
confluence_space: "DO"
category: "Epics"
created_date: ""
updated_date: ""
migrated_date: "2025-09-14"
tags: ['frontend', 'epic', 'media-server', 'docker', 'golang', 'servarr', 'monitoring', 'storage']
---

# GitHub Actions Workflow Refactoring - Sequential Build Pipeline

## Executive Summary

[[HL-100]]- Refactor GitHub Actions Container Build Workflow
**Total Effort**: 3 Story Points (24 hours)
**Priority**: High - Critical for build stability
**Impact**: 100+ container builds across 4 job categories
## Problem Statement

### Current Issues

- **❌ Naming Inconsistency**: Base image "dockserver-ui" should be "homelabarr-ui"
- **❌ Massive Parallel Matrix**: 100+ containers build simultaneously causing: - Resource contention on self-hosted runners - Difficult failure diagnosis - Race conditions for dependent images
- **❌ No Dependency Chain**: Base images and containers needing them build in parallel
- **❌ Poor Debugging**: Failures bounce around in 100+ parallel job logs
- **❌ No Granular Control**: Must build entire matrix or nothing
### Impact on Development

- **Build Failures**: 18+ containers failing due to dependency issues
- **Debug Time**: 3-4x longer to identify failure root cause
- **Resource Waste**: Failed builds continue running unnecessarily
- **Developer Frustration**: Cannot trigger specific category builds
## Solution Architecture

### Three-Stage Sequential Pipeline

### Stage 1: Base Images (Foundation)

**Purpose**: Build all base images that other containers depend on
**Strategy**: Sequential with fail-fast
**Images**: - homelabarr-alpine, homelabarr-alpine-v3 - homelabarr-ubuntu-focal, homelabarr-ubuntu-jammy, homelabarr-ubuntu-noble - homelabarr-ui (renamed from dockserver-ui) - homelabarr-config, homelabarr-create
### Stage 2: Docker Mods (Enhancements)

**Purpose**: Build modification layers that extend base functionality
**Dependency**: Requires Stage 1 completion
**Mods**: - homelabarr-mod-healthcheck - homelabarr-mod-qbittorrent, homelabarr-mod-sabnzbd, homelabarr-mod-nzbget - homelabarr-mod-rclone, homelabarr-mod-storagecheck - homelabarr-mod-tautulli
### Stage 3: Application Containers (By Category)

**Purpose**: Build actual application containers organized by function
**Dependency**: Requires Stage 2 completion
**Categories**:CategoryContainersCountMedia ServersPlex, Jellyfin, Emby, Kavita4+Download ClientsqBittorrent, SABnzbd, NZBGet, Deluge4+Media ManagersSonarr, Radarr, Lidarr, Bazarr, Prowlarr5+Request SystemsOverseerr, Ombi, Petio3+MonitoringNetdata, Grafana, Prometheus, Uptime-Kuma4+Backup ToolsDuplicati, Restic, Local-persist3+System UtilsMount, Wiki, GUI, VNstat4+