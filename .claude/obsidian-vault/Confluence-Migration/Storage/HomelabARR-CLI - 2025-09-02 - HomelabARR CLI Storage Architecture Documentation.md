---
title: "HomelabARR-CLI : 2025-09-02 - HomelabARR CLI Storage Architecture Documentation"
confluence_id: "11763972"
confluence_url: "https://your-instance.atlassian.net/wiki/spaces/DO/pages/11763972"
confluence_space: "DO"
category: "Storage"
created_date: "2025-09-02"
updated_date: "2025-09-03"
migrated_date: "2025-09-14"
tags: ['frontend', 'media-server', 'docker', 'golang', 'servarr', 'september-2025', 'monitoring', 'storage']
---

# HomelabARR CLI Storage Architecture Documentation

**Date**: 2025-09-02
**Status**: CORRECTED - Cache Mover Research Complete
**Impact**: Critical - Missing functionality identified and solution researched
## Critical Update: Cache Mover Research Complete

### Research Summary: Docker Database Persistence Strategy

#### Unraid appdata Strategy

Research reveals Unraid keeps Docker databases permanently on cache through:
- **appdata share**configured with`Cache -> Array`mover action
- **Critical exclusion**: Docker databases (Plex, Jellyfin, Radarr, Sonarr) NEVER moved to spinning disks
- **Performance protection**: Application working sets stay on NVMe permanently
- **Selective moving**: Only user data/media files transferred to array storage
#### Trash Guides Atomic Moves Implementation

**Single Mount Point Strategy**: - All containers use`/data`mount pointing to same filesystem - Download clients:`/data/torrents/`or`/data/usenet/`
- Starr apps:`/data`(full access required for hardlinks) - Media servers:`/data/media/`(read-only access sufficient)

**Hardlink Requirements for Atomic Operations**: - Must be same filesystem for instant moves (no copy+delete) - Downloads path:`/data/usenet/complete/movies/`→`/data/media/movies/`- Creates hardlinks instead of slow file copying - Prevents corruption during transfer operations
## Storage Implementation Status - CORRECTED

### ✅**Implemented (Native Go)**

- **SnapRAID Operations**: Complete controller in`pkg/storage/snapraid.go`(466 lines)
- **MergerFS Pool Management**: Full implementation in`pkg/storage/storage.go`(597 lines)
- **btrfs Cache Support**: Native filesystem support for NVMe cache drives
- **Storage Monitoring**: Real-time status tracking and concurrent access management
- **Cross-platform Support**: Windows development / Linux production compatibility
### ❌**Missing - Critical Infrastructure Gap**

- **Cache Mover Daemon**: Automated NVMe-to-Array file transfers
- **Download Client Cache Routing**: Proper download-to-cache configuration
- **Age-based File Management**: Automatic file aging and migration logic
- **Docker Database Protection**: Ensuring critical databases never move to array
## Discovered Implementation Evidence

### Previous Working Cache Mover (Archived)

**File**:`v2-poc/archived-implementations/simple-server-integrated-snapraid.go`

**Evidence of previous functionality**: -**Line 3359**:`{"step": "Syncing cache to array", "status": "complete"}`-**Line 3406**:`balanceCmd := exec.Command("btrfs", "balance", "start", "/mnt/cache")`-**Lines 3388-3401**: Complete cache drive detection for`/mnt/cache`,`/mnt/cache1`,`/mnt/cache2`

**Analysis**: Functionality existed but was lost during code reorganization/refactoring.
### Current Infrastructure Available

**In current`simple-server.go`(5,178 lines)**: -**Cache Balance Handler**: Basic btrfs operations (may be incomplete) -**HTTP API Structure**: Routes available for cache management -**Storage Integration**: Hooks for SnapRAID + MergerFS operations
## Architecture Diagrams - Status CORRECTED

**Previous Documentation Error**: Diagrams showed storage as "planned" when comprehensive implementation already exists.

**Correction Applied**: All documentation updated to reflect actual implementation status with missing cache mover component clearly identified.
## Configuration Evidence

### btrfs Cache Drive Support (Confirmed)

**File**:`v2-poc/storage-config.go`lines 137-139
```
// Cache Pools - BTRFS for NVMe cache drives  
{Device: "/dev/nvme0n1", Label: "cache", Size: "1TB", FileSystem: "btrfs", Health: "healthy"},
{Device: "/dev/nvme1n1", Label: "cache_mirror", Size: "1TB", FileSystem: "btrfs", Health: "healthy"}, 
{Device: "/dev/nvme2n1", Label: "cache2", Size: "1TB", FileSystem: "btrfs", Health: "healthy"},
```