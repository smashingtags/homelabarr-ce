---
title: "HomelabARR-CLI : 2025-08-23 Performance Optimization: App Store 300x Speed Improvement"
confluence_id: "8978486"
confluence_url: "https://mjashley.atlassian.net/wiki/spaces/DO/pages/8978486"
confluence_space: "DO"
category: "General"
created_date: "2025-08-23"
updated_date: "2025-08-23"
migrated_date: "2025-09-14"
tags: ['golang', 'august-2025', 'docker']
---

# Performance Optimization: App Store 300x Speed Improvement

## Executive Summary

Successfully resolved critical performance issue where HomelabARR v2.0 App Store took 20-30 seconds to load, reducing load time to ~100ms - a 300x improvement.
## Problem Statement

Users reported the App Store appeared broken due to extremely slow loading times (20-30 seconds), causing confusion and poor user experience. Users would repeatedly refresh or report bugs thinking the application had crashed.
## Root Cause Analysis

### Performance Profiling Results

- **Total Load Time**: 20,000-30,000ms
- **Template Loading**: 2.7ms (not the issue)
- **Docker Status Checks**: ~12,100ms (121 apps × 100ms each)
- **Additional Overhead**: 8-18 seconds (network, serialization)
### Identified Bottlenecks

#### 1. File I/O on Every Request

- Server reading all 121 YAML template files from disk
- No caching mechanism
- Redundant disk operations for static content
#### 2. Docker Command Explosion

- Executing`docker ps`command 121 times per request
- One command per app to check installation status
- Sequential execution causing massive delays
## Solution Architecture

### 1. Template Caching System

Implemented in-memory caching using Go's concurrency primitives:
```
// Global cache variables
var (
appTemplatesCache []AppTemplate
cacheOnce sync.Once
cacheMutex sync.RWMutex
lastCacheUpdate time.Time
cacheTTL = 5 * time.Minute
)
// Thread-safe cache initialization
func getCachedAppTemplates() []AppTemplate {
cacheOnce.Do(func() {
appTemplatesCache = loadAppTemplates()
lastCacheUpdate = time.Now()
})
// Refresh cache if expired
if time.Since(lastCacheUpdate) > cacheTTL {
// Refresh logic with proper locking
}
return appTemplatesCache
}
```