---
title: "HomelabARR-CLI : 2025-08-24 MergerFS + SnapRAID Storage Architecture Plan"
confluence_id: "8978598"
confluence_url: "https://your-instance.atlassian.net/wiki/spaces/DO/pages/8978598"
confluence_space: "DO"
category: "Storage"
created_date: "2025-08-24"
updated_date: "2025-08-24"
migrated_date: "2025-09-14"
tags: ['frontend', 'august-2025', 'golang', 'monitoring', 'storage']
---

# 2025-08-24 MergerFS + SnapRAID Storage Architecture Plan

## Executive Summary

This document outlines the implementation plan for integrating mergerfs drive pooling and SnapRAID parity protection into HomelabARR v2.0, following the proven architecture patterns from Perfect Media Server.
## Background Research

### Perfect Media Server Architecture

Perfect Media Server (PMS) has established best practices for home media servers using: -**MergerFS**: Combines multiple drives into a single storage pool -**SnapRAID**: Provides snapshot-based parity protection -**Folder Structure**: Following Trash Guides recommendations
### Why This Architecture?

- **Flexibility**: Add drives of any size at any time
- **Protection**: Survive 1-6 drive failures (configurable)
- **Performance**: No RAID overhead for reads/writes
- **Recovery**: Files remain readable even without parity
## Implementation Plan

### Phase 1: Drive Categorization (COMPLETED)

✅ Implemented intelligent drive detection ✅ Separate cache drives from array drives ✅ SSD/HDD/NVMe identification
### Phase 2: MergerFS Integration

- Create unified mount point at /mnt/storage
- Pool all array drives together
- Exclude cache/SSD drives
- Configure allocation policies
### Phase 3: SnapRAID Configuration

- Auto-generate snapraid.conf
- Configure parity drives (10% rule)
- Set up content files
- Implement exclusion rules
### Phase 4: Automation

- SnapRAID Runner for scheduled syncs
- Smart scrubbing intervals
- Email notifications
- Health monitoring
## Technical Details

### MergerFS Configuration

```
# Create pool from array drives
mergerfs -o defaults,allow_other,use_ino,category.create=mfs \
  /mnt/disk1:/mnt/disk2:/mnt/disk3 \
  /mnt/storage
```