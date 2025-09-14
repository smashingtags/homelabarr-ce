---
title: "HomelabARR-CLI : 2025-08-21 Docker & Container Fixes - Consolidated Guide"
confluence_id: "7929985"
confluence_url: "https://your-instance.atlassian.net/wiki/spaces/DO/pages/7929985"
confluence_space: "DO"
category: "Installation"
created_date: "2025-08-21"
updated_date: "2025-08-21"
migrated_date: "2025-09-14"
tags: ['frontend', 'august-2025', 'docker']
---

# 2025-08-21 Docker & Container Fixes - Consolidated Guide

{toc:minLevel=2|maxLevel=3}
## 2025-08-21 - CLI Docker Integration Restored

### Problem

WSL Claude reverted our working CLI-based Docker integration back to dockerode, breaking all container operations with "dockerManager.getDocker is not a function" errors.
### Solution Applied

- Restored CLI-based Docker commands using PowerShell for Windows
- Fixed all container control endpoints (start/stop/restart/remove)
- Implemented proper container inspection via CLI
### Key Code Changes

```
// Helper function for CLI-based container control
async function getContainerInfoCLI(containerId) {
    const platform = process.platform;
    let inspectCommand;
    if (platform === 'win32') {
        inspectCommand = `powershell.exe -Command "docker inspect ${containerId}"`;
    } else {
        inspectCommand = `docker inspect ${containerId}`;
    }
    // Execute and parse result
}
```