---
title: "HomelabARR-CLI : 2025.08.25 Linux-Only Migration Complete - HL-252"
confluence_id: "10158081"
confluence_url: "https://your-instance.atlassian.net/wiki/spaces/DO/pages/10158081"
confluence_space: "DO"
category: "Epics"
created_date: ""
updated_date: ""
migrated_date: "2025-09-14"
tags: ['golang', 'monitoring', 'storage', 'docker']
---

# Linux-Only Migration Complete

## Overview

HomelabARR CLI has been fully migrated from cross-platform (Windows/Linux) to Linux-only, targeting UGREEN NAS devices with SnapRAID/MergerFS storage stack.
## Migration Scope

### Files Modified (9 Go files)

- **v2-poc/simple-server.go**- Removed 83 Windows references
- **v2-poc/cmd/homelabarr/main_improved.go**- Docker command detection
- **v2-poc/cmd/homelabarr/main.go**- Docker command initialization
- **v2-poc/internal/docker/compose.go**- Docker Compose detection
- **v2-poc/pkg/docker/exec_client.go**- Docker client initialization
- **websocket-temp/docker-integration.go**- Docker integration
- **v2-poc/pkg/compose/compose.go**- Compose manager
- **v2-poc/config/config.go**- Configuration management
- **v2-poc/test-compose.go**- Test utilities
## Technical Changes

### System Monitoring

- **Before**: PowerShell commands for CPU/RAM/disk metrics
- **After**: Linux /proc filesystem (/proc/stat, /proc/meminfo, /proc/uptime)
### Docker Integration

- **Before**: docker.exe detection for Windows
- **After**: Always uses "docker" command
### Storage Management

- **Before**: Windows drive letters (C:\, D:)
- **After**: Linux mount points (/mnt, /storage)
### Task Scheduling

- **Before**: Windows Task Scheduler integration
- **After**: Cron jobs for SnapRAID sync
## Verification Results

```
# Windows code check
grep -r "runtime.GOOS == \"windows\"" --include="*.go" . | wc -l
# Result: 0 (excluding backups)

# Docker.exe references
grep -r "docker\.exe" --include="*.go" . | wc -l  
# Result: 0 (excluding backups)

# PowerShell references
grep -r "powershell" --include="*.go" . | wc -l
# Result: 0 (excluding backups)
```