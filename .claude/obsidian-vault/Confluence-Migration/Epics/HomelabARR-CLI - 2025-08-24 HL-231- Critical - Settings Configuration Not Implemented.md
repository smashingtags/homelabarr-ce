---
title: "HomelabARR-CLI : 2025-08-24 HL-231: Critical - Settings Configuration Not Implemented"
confluence_id: "8913081"
confluence_url: "https://your-instance.atlassian.net/wiki/spaces/DO/pages/8913081"
confluence_space: "DO"
category: "Epics"
created_date: "2025-08-24"
updated_date: "2025-08-24"
migrated_date: "2025-09-14"
tags: ['frontend', 'august-2025', 'docker', 'traefik', 'security', 'authelia', 'epic']
---

# 2025-08-24 HL-231: Critical - Settings Configuration Not Implemented

## Problem Statement

The HomelabARR v2.0 dashboard displays a Settings card with configuration options for reverse proxy, authentication, and SSL certificates, but these settings are completely non-functional. All Docker Compose templates have hardcoded Traefik and Authelia configurations that cannot be disabled or changed.
## Impact

- **User Expectation**: Settings page implies configurability
- **Reality**: All settings are hardcoded in templates
- **User Frustration**: Changes in UI have no effect
- **Security Risk**: Can't disable authentication when not needed
## Root Cause

- POC was built with placeholder UI
- Templates were created with fixed configurations
- No backend processing of settings was implemented
- Settings page is purely cosmetic
## Current State

### What's Shown

```
<!-- Settings UI shows these options -->
☑ Enable Traefik Reverse Proxy
☑ Enable Authelia Authentication  
☑ Enable SSL Certificates
Docker Socket Path: [input field]
```