---
title: "HomelabARR-CLI : 2025-09-03 - local-persist + Cache Mover Integration Architecture"
confluence_id: "12091630"
confluence_url: "https://mjashley.atlassian.net/wiki/spaces/DO/pages/12091630"
confluence_space: "DO"
category: "Architecture"
created_date: "2025-09-03"
updated_date: "2025-09-03"
migrated_date: "2025-09-14"
tags: ['media-server', 'docker', 'golang', 'servarr', 'september-2025', 'storage']
---

# local-persist + Cache Mover Integration Architecture

**Date**: 2025-09-03
**Status**: DESIGN COMPLETE - Integration Strategy Validated
**Impact**: Critical - Production-ready hybrid architecture defined
## Executive Summary

**Perfect Hybrid Solution Discovered**: local-persist Docker volume plugin + Cache Mover daemon =**Best of both worlds**
- **local-persist**: Guarantees Docker volume persistence and consistent mount points
- **Cache Mover**: Optimizes storage tiers with NVMe cache + Array storage
- **Integration**: Two complementary layers working in perfect harmony
## Two-Layer Architecture Design

### Layer 1: Docker Volume Management (local-persist)

- **Volume Persistence**: Container data survives restarts/crashes
- **Consistent Paths**: Predictable host mount points for all containers
- **Mount Management**: Maps container paths to`/mnt/cache/*`and`/mnt/data/*`
### Layer 2: Storage Tier Optimization (Cache Mover)

- **NVMe Cache**: Ultra-fast storage for active databases and downloads
- **Array Storage**: Cost-effective long-term storage via MergerFS + SnapRAID
- **Transparent Migration**: Containers completely unaware of storage tier changes
## Smart Path Categorization Strategy

### 🔒 PERMANENT CACHE (local-persist maps, mover EXCLUDES)

**Critical Rule**: These paths NEVER moved by cache mover to protect Docker database integrity
```
/mnt/cache/appdata/plex/          # Plex media database - NEVER move
/mnt/cache/appdata/jellyfin/      # Jellyfin database - NEVER move  
/mnt/cache/appdata/radarr/        # Radarr application database - NEVER move
/mnt/cache/appdata/sonarr/        # Sonarr application database - NEVER move
/mnt/cache/appdata/lidarr/        # Lidarr application database - NEVER move
/mnt/cache/appdata/bazarr/        # Bazarr application database - NEVER move
/mnt/cache/appdata/nzbget/        # NZBGet configuration - NEVER move
/mnt/cache/system/                # System binaries and configs - NEVER move
```