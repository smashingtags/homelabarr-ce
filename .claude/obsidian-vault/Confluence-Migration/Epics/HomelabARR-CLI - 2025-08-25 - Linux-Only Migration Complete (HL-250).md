---
title: "HomelabARR-CLI : 2025-08-25 - Linux-Only Migration Complete (HL-250)"
confluence_id: "9928792"
confluence_url: "https://your-instance.atlassian.net/wiki/spaces/DO/pages/9928792"
confluence_space: "DO"
category: "Epics"
created_date: "2025-08-25"
updated_date: "2025-08-25"
migrated_date: "2025-09-14"
tags: ['frontend', 'august-2025', 'media-server', 'docker', 'golang', 'storage']
---

# Linux-Only Architecture Migration Complete

## Overview

Successfully completed the migration to Linux-only architecture for HomelabARR v2.0, removing all Windows and cross-platform code to focus on NAS market monetization.
## Business Context

- **Urgent Need**: Job loss with 15-year-old dependent requires immediate monetization
- **Target Market**: UGREEN DXP8800 Plus and similar NAS devices (Linux-only)
- **Strategy**: Unraid alternative using SnapRAID + MergerFS on Linux
## Technical Scope

### Files Modified

- 

**simple-server.go**(83+ Windows references removed) - Removed all`runtime.GOOS == "windows"`checks - Replaced PowerShell commands with Linux /proc filesystem - Eliminated Windows Docker socket handling - Removed Windows-specific VPN detection
- 

**pkg/storage/**(New hybrid Pure Go implementation) - storage.go: Core storage management - snapraid.go: SnapRAID integration - handlers.go: HTTP handlers maintaining API compatibility
- 

**v2-poc/README.md**(Documentation updated) - Removed Windows/macOS references - Added SnapRAID/MergerFS focus - Updated for UGREEN NAS deployment
## Code Changes

### System Uptime (Before)

```
// Windows-specific PowerShell command
if runtime.GOOS == "windows" {
    cmd := exec.Command("powershell", "-Command", 
        "(Get-Date) - (gcim Win32_OperatingSystem).LastBootUpTime")
    // Complex PowerShell parsing...
}
```