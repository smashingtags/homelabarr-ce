---
title: "HomelabARR-CLI : 2025.08.21 Docker Integration & Application Deduplication Fix - 2025-08-21"
confluence_id: "7536684"
confluence_url: "https://your-instance.atlassian.net/wiki/spaces/DO/pages/7536684"
confluence_space: "DO"
category: "Docker"
created_date: "2025-08-21"
updated_date: "2025-08-21"
migrated_date: "2025-09-14"
tags: ['frontend', 'august-2025', 'golang', 'docker']
---

# Docker Integration & Application Deduplication Fix

**Date**: 2025-08-21
**Duration**: ~1 hour
**Status**: ✅**COMPLETED**
## Issues Resolved

### 1. Docker Container Display Issue

**Problem**: Containers not showing in HomelabARR web UI despite being visible in Portainer
**Root Cause**:`dockerManager.getDocker is not a function`error - dockerode incompatibility with Windows
**Solution**: Implemented CLI-based Docker integration using PowerShell docker commands
### 2. Duplicate Applications Issue

**Problem**: 324 applications showing instead of correct 252
**Root Cause**: CLI Bridge scanning ALL directories including`local-mode-apps`and test directories with duplicates
**Solution**: Limited scanning to specific application category directories only
## Technical Implementation

### Docker CLI Integration (server/index.js)

```
// Windows-compatible Docker container fetching
const { execSync } = await import('child_process');
const result = execSync('powershell.exe -Command "docker ps -a --format json"', {
  encoding: 'utf8',
  maxBuffer: 10 * 1024 * 1024
});
```