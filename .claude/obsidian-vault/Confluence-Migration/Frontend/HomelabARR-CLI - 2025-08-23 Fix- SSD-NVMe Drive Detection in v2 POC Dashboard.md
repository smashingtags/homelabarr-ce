---
title: "HomelabARR-CLI : 2025-08-23 Fix: SSD/NVMe Drive Detection in v2 POC Dashboard"
confluence_id: "8978458"
confluence_url: "https://mjashley.atlassian.net/wiki/spaces/DO/pages/8978458"
confluence_space: "DO"
category: "Frontend"
created_date: "2025-08-23"
updated_date: "2025-08-23"
migrated_date: "2025-09-14"
tags: ['golang', 'epic', 'august-2025', 'storage']
---

# 2025-08-23 Fix: SSD/NVMe Drive Detection in v2 POC Dashboard

## Issue Summary[[HL-198]]
- **Date Fixed**: August 23, 2025
- **Status**: ✅ Completed and Deployed
## Problem Description

The v2 POC dashboard was incorrectly identifying SSD drives as HDDs. The C: drive (930GB SSD) was showing as "HDD" instead of "SSD" due to flawed detection logic.
## Root Cause

The drive type detection in`storage-monitor.go`was using incorrect logic: - Only checking for "Fixed" media type - Not detecting NVMe drives - Missing SSD-specific identifiers
## Solution Implemented

### Before (Broken)

```
if disk.MediaType == "Fixed" {
    driveType = "HDD"  // Wrong assumption
}
```