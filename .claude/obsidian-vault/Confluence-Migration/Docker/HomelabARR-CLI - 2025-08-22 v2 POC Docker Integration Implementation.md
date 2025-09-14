---
title: "HomelabARR-CLI : 2025-08-22 v2 POC Docker Integration Implementation"
confluence_id: "8978434"
confluence_url: "https://your-instance.atlassian.net/wiki/spaces/DO/pages/8978434"
confluence_space: "DO"
category: "Docker"
created_date: "2025-08-22"
updated_date: "2025-08-22"
migrated_date: "2025-09-14"
tags: ['frontend', 'august-2025', 'golang', 'docker']
---

# v2 POC Docker Integration Implementation

## Date: August 22, 2025

## Overview

Successfully integrated real Docker container management into the HomelabARR v2 POC backend server, enabling actual container control from the web dashboard.
## Changes Implemented

### Backend Server (simple-server.go)

- **Real Docker Container Fetching**- Added`getRealContainers()`function that executes`docker ps -a`to get actual containers - Parses Docker output into Container structs - Falls back to mock data if Docker is unavailable - Successfully returns 17+ real containers from Docker Desktop
- **Container Action Execution**- Modified`containerActionHandler`to build real Docker commands - Supports start, stop, restart, and logs actions - Uses`exec.Command("docker.exe")`for Windows compatibility - Provides detailed error handling and command output
- **API Endpoints Working**- GET /api/containers - Returns real Docker containers - POST /api/containers/{id}/start - Starts container - POST /api/containers/{id}/stop - Stops container - POST /api/containers/{id}/restart - Restarts container
### Frontend Integration

- container-table-component.html successfully fetches and displays real containers
- Container control buttons send commands to backend API
- Real-time status updates after actions
## Technical Details

### Docker Command Execution

```
cmd := exec.Command("docker.exe", strings.Fields(cmdStr)[1:]...)
output, err := cmd.CombinedOutput()
```