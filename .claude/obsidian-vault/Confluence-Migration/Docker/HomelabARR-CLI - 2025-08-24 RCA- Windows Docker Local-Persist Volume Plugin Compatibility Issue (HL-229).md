---
title: "HomelabARR-CLI : 2025-08-24 RCA: Windows Docker Local-Persist Volume Plugin Compatibility Issue (HL-229)"
confluence_id: "8945813"
confluence_url: "https://your-instance.atlassian.net/wiki/spaces/DO/pages/8945813"
confluence_space: "DO"
category: "Docker"
created_date: "2025-08-24"
updated_date: "2025-08-24"
migrated_date: "2025-09-14"
tags: ['august-2025', 'epic', 'docker']
---

# 2025-08-24 RCA: Windows Docker Local-Persist Volume Plugin Compatibility Issue[[HL-229]]
**Date**: August 24, 2025
**Severity**: High
**Impact**: All HomelabARR applications failed to install on Windows development environments
**Resolution**: Implemented automatic OS detection with volume driver fallback
## Tags for Search

`#windows-docker``#local-persist``#volume-plugin[[HL-229]]`
## Executive Summary

Windows Docker Desktop does not support the local-persist volume plugin, causing all HomelabARR Docker Compose templates to fail during deployment. This affected 100% of Windows development environments.
## Timeline

- **08:00**- User reported app installation failures on Windows
- **08:15**- Identified volume driver error in Docker logs
- **08:30**- Confirmed local-persist incompatibility with Windows
- **09:00**- Implemented OS detection solution
- **09:30**- Tested and deployed fix
## Root Cause Analysis

### The Problem

All HomelabARR Docker Compose templates contained:
```
volumes:
  config:
    driver: local-persist
    driver_opts:
      mountpoint: ${DOCKERCONFDIR}/app_name
```