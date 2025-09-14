---
title: "HomelabARR-CLI : 2025-08-26 - HomelabARR React Migration Architecture"
confluence_id: "10158149"
confluence_url: "https://your-instance.atlassian.net/wiki/spaces/DO/pages/10158149"
confluence_space: "DO"
category: "Frontend"
created_date: "2025-08-26"
updated_date: "2025-08-26"
migrated_date: "2025-09-14"
tags: ['frontend', 'august-2025', 'epic', 'docker', 'golang', 'security', 'monitoring', 'storage']
---

# HomelabARR React Migration Epic - Technical Architecture

## Overview

This document outlines the comprehensive migration of HomelabARR NAS OS from static HTML to React framework for real-time updates and enhanced user experience.
## Epic Details[[HL-256]]- HL-React: Migrate NAS Dashboard to React Framework
- **Total Story Points**: 12 SP (96 hours)
- **Target**: Convert 12 static HTML files to React components
- **Goal**: Enable real-time updates via WebSocket integration
## Current Architecture

### Static HTML Structure (v2-poc/web/)

```
dashboard.html           - System overview and metrics
containers.html          - Docker container management  
storage.html            - Storage and disk management
apps.html               - Application store and installer
file-manager.html       - File browser interface
settings.html           - System configuration
logs.html              - System and application logs
network.html           - Network configuration
users.html             - User management
backup.html            - Backup and restore
monitoring.html        - System monitoring
security.html          - Security settings
file-sharing-components.html - React component (already converted)
```