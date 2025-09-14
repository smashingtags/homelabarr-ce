---
title: "HomelabARR-CLI : 2025-08-24 HL-233: Docker Socket Path Platform Detection Fix"
confluence_id: "8913136"
confluence_url: "https://mjashley.atlassian.net/wiki/spaces/DO/pages/8913136"
confluence_space: "DO"
category: "Docker"
created_date: "2025-08-24"
updated_date: "2025-08-24"
migrated_date: "2025-09-14"
tags: ['golang', 'epic', 'august-2025', 'docker']
---

# 2025-08-24 HL-233: Docker Socket Path Platform Detection Fix

## Overview

Fixed critical bug where Settings page was overwriting user configurations with Linux-specific Docker socket paths on Windows systems.
## Problem Statement

When users saved settings on Windows, the backend was returning Linux Docker socket paths (`/var/run/docker.sock`) instead of Windows paths (`//./pipe/docker_engine`), causing Docker connectivity failures.
## Root Cause

The settings handler in`settings-handler.go`was not detecting the runtime platform and always returning Linux paths, regardless of the actual operating system.
## Solution Implemented

### Platform Detection Logic

```
func getDockerSocketPath() string {
    if runtime.GOOS == "windows" {
        return "//./pipe/docker_engine"
    }
    return "/var/run/docker.sock"
}
```