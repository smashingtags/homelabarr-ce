---
title: "HomelabARR-CLI : 2025.08.19 Docker Build Infrastructure Fixes and GHCR Integration"
confluence_id: "6586370"
confluence_url: "https://your-instance.atlassian.net/wiki/spaces/DO/pages/6586370"
confluence_space: "DO"
category: "Docker"
created_date: ""
updated_date: ""
migrated_date: "2025-09-14"
tags: ['frontend', 'security', 'docker']
---

# Docker Build Infrastructure Fixes and GHCR Integration

## Executive Summary

This document details the comprehensive resolution of Docker build infrastructure issues, GitHub Container Registry (GHCR) integration, and TypeScript compilation problems in the HomelabARR CLI project.
## Issues Resolved

### 1. GitHub Container Registry Authentication

**Problem:**GHCR push failures with`permission_denied: write_package`error**Root Cause:**Self-hosted runners + GITHUB_TOKEN insufficient permissions for GHCR**Solution:**Personal Access Token (PAT) with packages:write scope
#### Implementation:

```
# Before (failing)
password: ${{ secrets.GITHUB_TOKEN }}

# After (working)  
password: ${{ secrets.GH_PAT || secrets.GITHUB_TOKEN }}
```