---
title: "HomelabARR-CLI : 2025-08-24 RCA: Settings Page Data Overwrite Bug"
confluence_id: "8913114"
confluence_url: "https://mjashley.atlassian.net/wiki/spaces/DO/pages/8913114"
confluence_space: "DO"
category: "Troubleshooting"
created_date: "2025-08-24"
updated_date: "2025-08-24"
migrated_date: "2025-09-14"
tags: ['august-2025', 'docker', 'traefik', 'authelia', 'epic']
---

# 2025-08-24 RCA: Settings Page Data Overwrite Bug

**Date**: 2025-08-24
**Time**[[HL-232]]
**Severity**: High
**Status**: Resolved
## Executive Summary

Critical bug discovered where the Settings page in dashboard-unified.html silently overwrites user configuration with hardcoded defaults when saving, causing data loss and platform-specific misconfiguration.
## Incident Timeline

- **21:00**- User reported settings not persisting
- **21:15**- Confirmed data overwrite on save
- **21:30**- Root cause identified
- **22:00**- Fix implemented and tested
- **22:30**- Deployed to production
## Root Cause Analysis

### The Problem

Settings page was using hardcoded default values instead of fetching current configuration from the backend before displaying or saving.
### Code Issue

```
// BROKEN CODE
function saveSettings() {
    const settings = {
        dockerSocket: '/var/run/docker.sock',  // Hardcoded!
        traefikEnabled: true,                  // Hardcoded!
        autheliaEnabled: true                  // Hardcoded!
    };
    // Overwrites user's actual settings
    fetch('/api/settings', {
        method: 'POST',
        body: JSON.stringify(settings)
    });
}
```