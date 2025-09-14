---
title: "HomelabARR-CLI : 2025-08-26 - TRaSH Guides Folder Structure Compliance Analysis"
confluence_id: "9994266"
confluence_url: "https://your-instance.atlassian.net/wiki/spaces/DO/pages/9994266"
confluence_space: "DO"
category: "Installation"
created_date: "2025-08-26"
updated_date: "2025-08-26"
migrated_date: "2025-09-14"
tags: ['frontend', 'media-server', 'august-2025', 'servarr']
---

# TRaSH Guides Folder Structure Compliance Analysis

## Executive Summary

**Compliance Status: ⚠️ PARTIAL COMPLIANCE**

HomelabARR CLI currently uses a**hybrid approach**that deviates from TRaSH Guides standards. While our current structure works, implementing the standardized`/data`approach would improve: -**Hardlink Support**: Enable atomic moves and space-efficient file operations -**Cross-Platform Consistency**: Standardized paths across all applications -**Community Compatibility**: Align with established best practices
## Current HomelabARR CLI Structure

### Current Implementation

```
Host System:
/opt/appdata/                    # Application configurations
├── plex/database/              # Plex config
├── radarr/                     # Radarr config
├── sonarr/                     # Sonarr config
└── qbittorrent/               # Download client config

Container Mounts:
- unionfs:/mnt:ro              # Media library (read-only)
- /mnt/downloads               # Download directory
- /mnt/unionfs                 # Union filesystem
- /mnt/move                    # Move directory
```