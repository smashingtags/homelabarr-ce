---
title: "HomelabARR-CLI : 2025.08.24Dashboard Settings Integration - Registry Config & Timezone Selector"
confluence_id: "8946084"
confluence_url: "https://your-instance.atlassian.net/wiki/spaces/DO/pages/8946084"
confluence_space: "DO"
category: "Frontend"
created_date: "2024-12-24"
updated_date: "2024-12-24"
migrated_date: "2025-09-14"
tags: ['frontend', 'golang', 'docker']
---

# Dashboard Settings Integration - Registry Config & Timezone Selector

## Overview

Successfully implemented comprehensive settings management features for the HomelabARR v2.0 dashboard, including container registry configuration, searchable timezone selector, and real system uptime display.
## Features Implemented

### 1. Container Registry Settings

- **Full UI Integration**: Added complete Registries tab to settings page
- **Backend Persistence**: Registry settings saved to`config/settings.json`
- **Registry Detection**: Automatically detects and categorizes container registries:
- LinuxServer.io
- Hotio.dev
- HomelabARR
- Docker Hub
- GitHub Container Registry
- **Drag-and-Drop Reordering**: Users can drag to reorder registry preferences
- **Enable/Disable Toggles**: Control which registries are checked for updates
- **Update Frequency Settings**: Configure how often to check for container updates
- **Auto-update Toggle**: Enable/disable automatic container updates
### 2. Searchable Timezone Selector

- **100+ Timezones**: Comprehensive list covering all major timezones globally
- **Regional Grouping**: Organized by Americas, Europe, Asia, Africa, Oceania, UTC
- **Live Search**: Real-time filtering as user types
- **Current Time Display**: Shows current time and UTC offset for each timezone
- **shadcn/ui Pattern**: Implements combobox best practices for superior UX
- **Backend Integration**: Fully wired to save/load from settings
### 3. System Uptime Display

- **Real Windows Uptime**: Fetches actual system uptime via PowerShell
- **Accurate Format**: Displays as "Xd Yh Zm" (e.g., "1d 17h 37m")
- **Auto-refresh**: Updates every 10 seconds with dashboard data
- **Fixed Widget Bug**: Corrected selector that was incorrectly updating uptime instead of CPU
## Technical Implementation

### Backend Changes (Go)

```
// Added to settings-handler.go
type RegistriesSettings struct {
    Enabled              map[string]bool
    UpdateCheckFrequency string
    AutoUpdateContainers bool
    PreferredOrder       []string
    CustomRegistry       string
    RegistryAuth         RegistryAuth
}

// Added to simple-server.go
// System uptime fetching via PowerShell
uptimeCmd := exec.Command("powershell", "-Command", 
    "(Get-CimInstance Win32_OperatingSystem).LastBootUpTime")
```