---
title: "HomelabARR-CLI : 2025.08.20 Container Build System Fixes and Naming Standardization"
confluence_id: "6914103"
confluence_url: "https://mjashley.atlassian.net/wiki/spaces/DO/pages/6914103"
confluence_space: "DO"
category: "Docker"
created_date: ""
updated_date: ""
migrated_date: "2025-09-14"
tags: ['frontend', 'docker']
---

# Container Build System Fixes and Naming Standardization

## Executive Summary

Successfully resolved critical container build failures and completed comprehensive naming standardization from`docker-*`to`homelabarr-*`across the entire container ecosystem.
## Issues Resolved

### 1. Ubuntu Base Image Build Failures

**Problem**: Ubuntu Focal and Jammy builds failing with exit code 100 and package dependency conflicts

**Root Causes**: - Wrong sources.list (Bionic sources on Focal/Jammy) - Missing DEBIAN_FRONTEND=noninteractive - Building FROM scratch instead of official images - Missing xz-utils package

**Solution**:
```
# Changed from:
FROM scratch

# To:
FROM ubuntu:20.04  # or ubuntu:22.04

# Added to all apt commands:
DEBIAN_FRONTEND=noninteractive apt-get install...
```