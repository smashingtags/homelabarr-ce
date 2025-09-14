---
title: "HomelabARR-CLI : 2025-08-23 HomelabARR v2.0 SnapRAID Implementation - Next Steps"
confluence_id: "9011251"
confluence_url: "https://mjashley.atlassian.net/wiki/spaces/DO/pages/9011251"
confluence_space: "DO"
category: "Storage"
created_date: "2025-08-23"
updated_date: "2025-08-23"
migrated_date: "2025-09-14"
tags: ['frontend', 'august-2025', 'golang', 'monitoring', 'storage']
---

# 2025-08-23 HomelabARR v2.0 SnapRAID Implementation - Next Steps

**Date:**2025-08-23
**Time:**06:28 AM EST
**Author:**Michael Ashley (AI Code Whisperer)
## Overview

This document outlines the planned next steps for implementing SnapRAID integration into HomelabARR v2.0, following our successful storage categorization and performance optimization work.
## Completed Work (Session of 2025-08-22/23)

- ✅ Storage categorization system implemented
- ✅ Drive type detection (SSD/HDD/NVMe)
- ✅ App Store performance optimization (300x improvement)
- ✅ Storage monitoring with real-time updates
- ✅ Windows/Linux cross-platform support
## Next Steps for SnapRAID Integration

### Phase 1: Core SnapRAID Components (2 SP)

- 

**SnapRAID Configuration Generator**- Auto-detect array drives vs cache drives - Generate snapraid.conf based on storage layout - Handle Windows vs Linux path differences
- 

**Parity Drive Management**- Designate parity drives (1-6 based on array size) - Calculate optimal parity configuration - Storage efficiency calculator
### Phase 2: MergerFS Integration (3 SP)

- 

**Drive Pooling Setup**- Create unified storage pool from array drives - Exclude cache/SSD drives from pool - Configure mount points
- 

**Policy Configuration**- Most-free-space (mfs) for downloads - Existing-path (ep) for media libraries - Custom policies per share
### Phase 3: Automation & Scheduling (2 SP)

- 

**SnapRAID Runner Integration**- Automated sync scheduling - Smart scrub intervals - Email notifications
- 

**Health Monitoring**- SMART data integration - Parity check status - Array health dashboard
### Phase 4: UI Integration (1 SP)

- 

**Storage Array Widget Updates**- SnapRAID status indicators - Sync/scrub progress bars - Quick action buttons
- 

**Settings Page**- SnapRAID configuration options - Schedule management - Notification preferences
## Technical Architecture

### Storage Categories (Already Implemented)

```
// Current categorization logic
const categories = {
  cache: [], // SSDs for downloads/transcoding
  array: [], // HDDs for long-term storage
  system: [] // OS drives
};
```