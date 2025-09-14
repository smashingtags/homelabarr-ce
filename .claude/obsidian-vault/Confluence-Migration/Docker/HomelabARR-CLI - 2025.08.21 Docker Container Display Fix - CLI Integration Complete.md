---
title: "HomelabARR-CLI : 2025.08.21 Docker Container Display Fix - CLI Integration Complete"
confluence_id: "7504031"
confluence_url: "https://mjashley.atlassian.net/wiki/spaces/DO/pages/7504031"
confluence_space: "DO"
category: "Docker"
created_date: "2025-08-21"
updated_date: "2025-08-21"
migrated_date: "2025-09-14"
tags: ['frontend', 'august-2025', 'docker']
---

# Docker Container Display Fix - CLI Integration Complete

**Date**: 2025-08-21
**Status**: ✅**FIXED - Container Display Issue Resolved**
**Duration**: ~30 minutes
## Issue Analysis

Based on the Confluence documentation and live debugging, identified the root cause of Docker container display problems in the HomelabARR web UI.
### Root Cause Identified

From the logs, the error was clear:
```
⚠️  Error fetching basic info for container 77add82688b6: dockerManager.getDocker is not a function
```