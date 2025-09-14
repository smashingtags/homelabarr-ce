---
title: "HomelabARR-CLI : 2025.08.25 Linux-Only Architecture Decision - August 2025"
confluence_id: "9928708"
confluence_url: "https://your-instance.atlassian.net/wiki/spaces/DO/pages/9928708"
confluence_space: "DO"
category: "Architecture"
created_date: ""
updated_date: ""
migrated_date: "2025-09-14"
tags: ['golang', 'epic', 'storage']
---

# Linux-Only Architecture Decision

**Decision Date**: August 25, 2025
**Author**: Michael Ashley
**Status**[[HL-250]]
## Executive Summary

HomelabARR CLI is migrating to Linux-only architecture, removing all Windows compatibility code. This decision accelerates development by 11+ days and aligns with industry standards (Unraid, TrueNAS, OpenMediaVault are all Linux-only).
## Current Situation

### Architecture Disconnect

- **Linux Implementation**: Complete SnapRAID/MergerFS installers in bash scripts (~70% done)[[HL-249]]) all Windows-related
### Code Analysis

```
// simple-server.go lines 1863-1869
// Return mock data if no real storage found
if len(storage) == 0 {
    storage = []StorageInfo{
        {Type: "mock", Mount: "C:", Label: "System"}
    }
}
```