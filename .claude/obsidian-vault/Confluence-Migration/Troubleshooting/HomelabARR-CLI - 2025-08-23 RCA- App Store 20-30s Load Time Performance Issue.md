---
title: "HomelabARR-CLI : 2025-08-23 RCA: App Store 20-30s Load Time Performance Issue"
confluence_id: "8978514"
confluence_url: "https://your-instance.atlassian.net/wiki/spaces/DO/pages/8978514"
confluence_space: "DO"
category: "Troubleshooting"
created_date: "2025-08-23"
updated_date: "2025-08-23"
migrated_date: "2025-09-14"
tags: ['august-2025', 'media-server', 'storage', 'docker']
---

# Root Cause Analysis: App Store Performance Issue

## Executive Summary

The HomelabARR v2.0 App Store was experiencing severe performance degradation with load times of 20-30 seconds, causing user confusion and false bug reports. This RCA documents the root cause, immediate fix, and long-term optimization strategies.
## Issue Timeline

- **Detection**: User reported thinking the app was broken due to long load times
- **Impact**: False bug reports were being created while waiting for response
- **Resolution**: Performance improved from 20-30s to 100ms (200-300x improvement)
## Root Cause Analysis

### Primary Causes

#### 1. App Store Performance (20-30 seconds)

- **Issue**: Reading 121 YAML template files from disk on every API request
- **Issue**: Making 121 individual`docker ps`calls to check container status
- **Impact**: O(n) disk I/O and process spawning on every request
#### 2. Storage API Performance (1.6+ seconds)

- **Issue**: Complex PowerShell queries with`Get-PhysicalDisk`running sequentially
- **Issue**: No caching of expensive WMI/CIM queries
- **Issue**: Character type mismatch in partition-to-disk mapping preventing SSD detection
### Contributing Factors

- No caching layer between API and file system
- Synchronous execution of all operations
- PowerShell 5.x lacking parallel execution capabilities
## Solution Implemented

### App Store Optimization

```
// Added global caching with thread-safe initialization
var (
appTemplatesCache []AppTemplate
cacheOnce sync.Once
cacheMutex sync.RWMutex
cacheTTL = 5 * time.Minute
)
// Batch Docker operations
runningContainers := getRunningContainers() // Single docker ps call
```