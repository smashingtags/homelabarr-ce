---
title: "HomelabARR-CLI : 2025-08-24 Working State Documentation"
confluence_id: "8978654"
confluence_url: "https://mjashley.atlassian.net/wiki/spaces/DO/pages/8978654"
confluence_space: "DO"
category: "Documentation"
created_date: "2025-08-24"
updated_date: "2025-08-24"
migrated_date: "2025-09-14"
tags: ['frontend', 'august-2025', 'epic', 'docker', 'golang', 'monitoring', 'storage']
---

# HomelabARR v2 POC - Working State Documentation

**Date**: 2025-08-24 00:40 EST
**Session**: Recovery and stabilization after breaking changes
## Current Working State

### ✅ What's Working

#### Dashboard (dashboard-unified.html)

- All navigation between pages functional
- Iframes loading correctly for:
- App Store (2025.08.23-Correct-App-Structure-apps-store-fixed.html)
- Storage Widget (storage-array-widget.html)
- Container Management (container-table-component.html)
- VPN Status (vpn-status-widget.html)
- Settings (settings-page.html)
#### Storage Widget (storage-array-widget.html)

- **Real API Integration**: All buttons connected to actual endpoints
- **Port Configuration**: Fixed from 8082 to 8080
- **Working Features**:
- Start/Stop Array →`/api/array/start`&`/api/array/stop`
- Parity Sync →`/api/snapraid/sync`
- Scrub →`/api/snapraid/scrub`
- Balance Cache →`/api/cache/balance`
- Spin Down →`/api/disks/spindown`
- SMART Test →`/api/snapraid/status`
- **SnapRAID Wizard**: Installer/configuration wizard intact
- **Real-time Updates**: Storage monitoring with live data
#### Backend Server (simple-server.go)

- All API endpoints responding correctly
- Category mapping function implemented
- Icon integration with 174 PNG files
- Docker compose execution code present
- Port 8080 configured throughout
## 🔧 Known Issues

### App Store Installation

- **Issue**: Category mapping needs testing
- **Files**:
- `apps-store.html`- BROKEN, do not use
- `2025.08.23-Correct-App-Structure-apps-store-fixed.html`[[HL-228]]
### MergerFS Testing

- **Issue**: Cannot test on Windows or LXC containers
- **Requirements**[[HL-227]]
## File Structure

```
v2-poc/
├── web/
│   ├── dashboard-unified.html (main dashboard)
│   ├── storage-array-widget.html (storage functionality)
│   ├── 2025.08.23-Correct-App-Structure-apps-store-fixed.html (WORKING app store)
│   ├── apps-store.html (BROKEN - needs fixing)
│   ├── container-table-component.html
│   ├── vpn-status-widget.html
│   ├── settings-page.html
│   └── backups/
│       └── 2025.08.24-working-003735/ (current backup)
├── simple-server.go (backend server)
└── templates/apps/ (Docker compose templates)
```