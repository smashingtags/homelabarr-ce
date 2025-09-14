---
title: "HomelabARR-CLI : 2025-09-12 - HomelabARR PE Linux Deployment Session"
confluence_id: "18481154"
confluence_url: "https://your-instance.atlassian.net/wiki/spaces/DO/pages/18481154"
confluence_space: "DO"
category: "General"
created_date: "2025-09-12"
updated_date: "2025-09-12"
migrated_date: "2025-09-14"
tags: ['frontend', 'docker', 'golang', 'security', 'september-2025', 'epic', 'storage']
---

# HomelabARR PE Linux VM Deployment - Session Summary

## Date: September 12, 2025

## Duration: ~4 hours (3:00 AM - 7:30 AM)

## Objective

Deploy and test HomelabARR PE on Linux VM (192.168.1.229) to verify cross-platform functionality and resolve Windows-specific issues.
## Successes ✅

### 1. Successfully Built Native Linux Binary

- Installed Go 1.24.2 on Ubuntu VM
- Built native Linux binary directly on VM (24MB)
- Avoided cross-compilation issues from Windows
### 2. Fixed Static File Serving Issue

- **Problem**: Server was serving from`./web/`instead of`./web/static/`
- **Solution**: Modified Go source to correct path
- **Result**: React dashboard now loads successfully
### 3. Basic Functionality Working

- Server runs on port 8080
- React dashboard loads at[http://192.168.1.229:8080](http://192.168.1.229:8080)
- Container management API endpoints work
- Docker containers display correctly in UI
### 4. VM Environment Cleaned

- Removed old test directories
- Cleaned up duplicate binaries
- Removed Windows path artifacts from failed attempts
## Failures/Issues ❌

### 1. API Path Duplication Bug (HL-384)

- Frontend calling`/api/api/system`instead of`/api/system`
- Causes 404 errors for system and storage endpoints
- Root cause: API path concatenation bug in React app
### 2. CORS Configuration Issues (HL-384)

- Server hardcoded to allow`http://localhost:5173`
- Blocks requests from`http://192.168.1.229:8080`
- Multiple endpoints fail due to CORS policy
### 3. Hardcoded localhost URLs (HL-384)

- Some frontend code still uses`localhost:8080`
- Should use relative URLs or configurable backend
### 4. Initial Cross-Compilation Failures

- Multiple attempts to cross-compile from Windows failed
- Produced Windows executables (MZ header) instead of Linux
- Solution: Build directly on Linux VM
## Technical Details

### VM Environment

- **VM**: Proxmox VM #104 "homelabarr-cli"
- **OS**: Ubuntu 25.04
- **IP**: 192.168.1.229
- **Go Version**: 1.24.2 (installed via apt)
### Code Changes Made

- **On VM**: Modified`simple-server.go`line 710
- From:`http.FileServer(http.Dir("./web/"))`
- To:`http.FileServer(http.Dir("./web/static/"))`
- **Binary**:`homelabarr-pe-fixed`(24MB)
### Current Status

- Server running: ✅
- Dashboard loads: ✅
- Containers work: ✅
- System/Storage broken: ❌ (API bugs)
- Authentication broken: ❌ (CORS)
- Notifications broken: ❌ (CORS)
## Next Steps

- **Fix API Path Bug**- Resolve double`/api/api/`concatenation in React app
- **Fix CORS Configuration**- Make CORS dynamic or allow multiple origins
- **Fix URL Configuration**- Use relative URLs or environment-based config
- **Apply Static Path Fix**- Update Windows source code with the fix
- **[[HL-384]]**: API path duplication and CORS issues (New - Open)
## Lessons Learned

- Cross-compilation from Windows to Linux is unreliable - build natively when possible
- CORS configuration needs to be dynamic for production deployments
- Frontend should use relative URLs to avoid hardcoded host issues
- Always verify file paths match between build output and server expectations
## Session Notes

- User exhausted after 4+ hour debugging session
- Multiple background processes created during troubleshooting
- VM had old test artifacts from previous sessions
- Despite issues, core functionality demonstrates PE can run on Linux