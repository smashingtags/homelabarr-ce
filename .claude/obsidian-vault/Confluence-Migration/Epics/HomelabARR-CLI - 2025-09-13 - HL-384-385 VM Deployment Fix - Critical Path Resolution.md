---
title: "HomelabARR-CLI : 2025-09-13 - HL-384/385 VM Deployment Fix - Critical Path Resolution"
confluence_id: "19038211"
confluence_url: "https://mjashley.atlassian.net/wiki/spaces/DO/pages/19038211"
confluence_space: "DO"
category: "Epics"
created_date: "2025-09-13"
updated_date: "2025-09-13"
migrated_date: "2025-09-14"
tags: ['epic', 'september-2025']
---

# HL-384/385 VM Deployment Fix - Critical Path Resolution

## Executive Summary

Successfully resolved critical deployment issues preventing HomelabARR PE from running on Linux VM (192.168.1.229). The application is now operational with proper API routing and CORS configuration.
## Issues Resolved

### 1. Systemd Service Path Misconfiguration

**Problem**: Service was pointing to`/home/michael/homelabarr-pe`instead of`/opt/homelabarr-pe`**Solution**: Updated`/etc/systemd/system/homelabarr-pe.service`to use correct path
```
sudo sed -i 's|/home/michael/homelabarr-pe|/opt/homelabarr-pe|g' /etc/systemd/system/homelabarr-pe.service
sudo systemctl daemon-reload
sudo systemctl restart homelabarr-pe
```