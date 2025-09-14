---
title: "HomelabARR-CLI : 2025.08.25 HomelabARR V2 Cross-Platform Compatibility Audit Report"
confluence_id: "8978970"
confluence_url: "https://your-instance.atlassian.net/wiki/spaces/DO/pages/8978970"
confluence_space: "DO"
category: "General"
created_date: ""
updated_date: ""
migrated_date: "2025-09-14"
tags: ['frontend', 'epic', 'docker', 'golang', 'project-management', 'monitoring', 'storage']
---

# HomelabARR V2 Cross-Platform Compatibility Audit Report

## Executive Summary

This comprehensive audit identified**10 critical categories**of cross-platform compatibility issues in the HomelabARR V2 codebase (v2-poc directory). The analysis focused on Windows vs Linux compatibility and revealed significant barriers to true cross-platform deployment.

**Key Findings:**- 🚨**9 Jira tickets created**for high-priority compatibility issues - ❌**Current deployment only supports Linux**with limited Windows functionality - ⚠️**Critical infrastructure components**(SnapRAID, local-persist, monitoring) have platform dependencies - 🔧**Extensive refactoring required**for true cross-platform support
## Detailed Findings by Category

### 1. 🗂️ File Path Issues (HL-241)

**Priority: HIGH**

**Issues Found:**-**simple-server.go:3244-3246**: Hardcoded Windows paths for SnapRAID logs`go   "C:\\ProgramData\\SnapRAID\\logs\\snapraid.log",   "C:\\SnapRAID\\snapraid.log",   os.ExpandEnv("${APPDATA}\\SnapRAID\\snapraid.log"),`-**simple-server.go:4752,4818**: Hardcoded "C:\SnapRAID\snapraid.conf" -**template-processor.go:159**: String contains checks for "C:" and backslashes -**verify-network-config.ps1:7**: Hardcoded "F:\Coding Projects\homelabarr-cli\v2-poc\templates"

**Impact:**Application fails to locate configuration files on non-Windows systems, preventing proper initialization.

**Recommended Solution:**- Use`filepath.Join()`and`os.PathSeparator`throughout - Implement platform-specific config directory resolution - Create abstraction layer for system-specific paths
### 2. ⚙️ OS-Specific Command Execution (HL-242)

**Priority: HIGH**

**Issues Found:**-**51+ instances**of PowerShell command execution across multiple files -**Windows-specific commands**:`wmic`,`powershell`, Windows services -**No Linux alternatives**provided for system monitoring commands

**Critical Files:**- simple-server.go: Lines 1012, 1021, 1035, 1044, 1064, 1614, 2108, 2119, 2270 - system-metrics.go: Lines 121, 172, 181 - monitoring-integrated-server.go: Lines 183, 207, 258, 267

**Impact:**System monitoring, VPN detection, and hardware information gathering completely fail on Linux systems.

**Recommended Solution:**- Implement command abstraction layer with OS detection - Provide Linux equivalents for all Windows commands - Use cross-platform system information libraries
### 3. 🔨 Build System Issues (HL-243)

**Priority: MEDIUM**

**Issues Found:**-**Makefile uses Unix-only commands**:`cp`,`rm`,`chmod`,`sudo`,`du -h`-**Date command format**: Linux-specific`date -u +%Y%m%d-%H%M%S`-**Installation paths**: Hardcoded`/usr/local/bin/`

**Impact:**Windows developers cannot build the project without WSL or alternative tools.

**Recommended Solution:**- Create Windows-compatible build scripts (.bat/.ps1) - Use Go-based build tools instead of Unix commands - Implement cross-platform installation logic
### 4. 🐳 Docker Integration Issues (HL-244)

**Priority: MEDIUM**

**Issues Found:**- Platform-specific Docker socket handling - Windows Docker Desktop vs Linux Docker daemon differences - Container execution context varies by platform

**Files Affected:**- docker-cli.go: Windows-specific platform detection - docker-integration.go: OS-specific Docker handling - pkg/docker/exec_client.go: Platform-specific execution

**Impact:**Docker integration may behave differently across platforms, affecting container management.
### 5. 📁 File Permissions Issues (HL-245)

**Priority: MEDIUM**

**Issues Found:**-**chmod/chown commands**don't exist on Windows -**sudo requirements**on Linux not handled on Windows -**File permission models**differ significantly between platforms

**Critical Scripts:**- All shell scripts in v2-poc/scripts/ directory - local-persist setup and configuration - Monitoring configuration scripts

**Impact:**Automated setup and configuration fails on Windows systems.
### 6. 📜 Shell Script Compatibility (HL-246)

**Priority: MEDIUM**

**Issues Found:**-**All scripts use bash shebang**:`#!/bin/bash`-**Linux-specific utilities**: grep, awk, sed, tar, curl -**No Windows equivalents**provided

**Affected Scripts:**- snapraid-config.sh, setup-automation.sh, install-mergerfs.sh - build-snapraid.sh, deploy-local-persist.sh - All automation and setup scripts

**Impact:**Critical setup and maintenance automation unavailable on Windows.
### 7. 🔧 Binary Compilation Issues (HL-247)

**Priority: LOW**

**Issues Found:**-**Hardcoded .exe extensions**in main.go -**Inconsistent binary naming**across platforms -**Build output expectations**differ by platform

**Impact:**Binary execution and inter-process communication may fail due to incorrect executable names.
### 8. 🌍 Environment Variable Handling (HL-248)

**Priority: MEDIUM**

**Issues Found:**-**Windows APPDATA vs Linux home directory**confusion -**PATH separator differences**(; vs :) -**OS-specific environment variable names**

**Files Affected:**- settings-handler.go: Multiple runtime.GOOS checks - encryption.go: Config directory resolution

**Impact:**Configuration files stored in incorrect locations, breaking application state.
### 9. 💾 Volume Mount and Storage Issues (HL-249)

**Priority: HIGH**

**Issues Found:**-**Drive letter handling**(C:, D:, etc.) vs Linux mount points -**local-persist plugin**designed for Linux only -**Mount point differences**between platforms

**Critical Components:**- SnapRAID configuration and data protection - Docker volume management - Media library mounting

**[[HL-249]]HighVolume MountingTo Do