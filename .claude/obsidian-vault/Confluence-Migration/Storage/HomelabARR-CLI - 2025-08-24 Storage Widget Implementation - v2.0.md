---
title: "HomelabARR-CLI : 2025-08-24 Storage Widget Implementation - v2.0"
confluence_id: "8945760"
confluence_url: "https://mjashley.atlassian.net/wiki/spaces/DO/pages/8945760"
confluence_space: "DO"
category: "Storage"
created_date: "2025-08-24"
updated_date: "2025-08-24"
migrated_date: "2025-09-14"
tags: ['frontend', 'august-2025', 'golang', 'monitoring', 'storage']
---

# 2025-08-24 Storage Widget Implementation - v2.0

## Overview

The HomelabARR v2.0 Storage Widget provides a comprehensive storage management interface with real-time monitoring, SnapRAID integration, and automated scheduling capabilities.
## Architecture

### Frontend

- **File**: v2-poc/web/storage-array-widget.html
- **Technology**: Vanilla JavaScript with dynamic DOM manipulation
- **Features**:
- Real-time storage monitoring
- Drive categorization (Cache/Array/System)
- SnapRAID status indicators
- MergerFS pool visualization
### Backend

- **File**: v2-poc/storage-monitor.go
- **API Endpoint**: /api/storage
- **Update Frequency**: 30 seconds
- **Platform Support**: Windows & Linux
## Key Features

### 1. Drive Categorization

```
categorizeStorage(data) {
    const categories = {
        cache: [],    // SSDs for downloads
        array: [],    // HDDs for storage
        system: []    // OS drives
    };

    data.drives.forEach(drive => {
        if (drive.type === 'SSD' || drive.type === 'NVMe') {
            categories.cache.push(drive);
        } else if (drive.total > 2 * 1024 * 1024 * 1024 * 1024) {
            categories.array.push(drive);
        } else {
            categories.system.push(drive);
        }
    });

    return categories;
}
```