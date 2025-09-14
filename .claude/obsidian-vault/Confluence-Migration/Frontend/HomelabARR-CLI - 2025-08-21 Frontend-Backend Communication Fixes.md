---
title: "HomelabARR-CLI : 2025-08-21 Frontend-Backend Communication Fixes"
confluence_id: "7962627"
confluence_url: "https://your-instance.atlassian.net/wiki/spaces/DO/pages/7962627"
confluence_space: "DO"
category: "Frontend"
created_date: "2025-08-21"
updated_date: "2025-08-21"
migrated_date: "2025-09-14"
tags: ['frontend', 'august-2025']
---

# 2025-08-21 Frontend-Backend Communication Fixes

## Table of Contents

{toc:minLevel=2|maxLevel=3}
## 2025-08-21 - SSE Deployment Progress Fix

### Problem

Server-Sent Events (SSE) for deployment progress were failing with 404 errors. Frontend trying to connect to relative path /stream/progress.
### Solution Applied

Updated all SSE endpoints to use absolute URLs with proper backend configuration.
### Code Changes

```
// Before (broken)
const eventSource = new EventSource('/stream/progress');

// After (working)
const eventSource = new EventSource('http://localhost:8082/stream/progress');
```