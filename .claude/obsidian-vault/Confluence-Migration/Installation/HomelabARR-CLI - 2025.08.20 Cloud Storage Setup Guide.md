---
title: "HomelabARR-CLI : 2025.08.20 Cloud Storage Setup Guide"
confluence_id: "7569460"
confluence_url: "https://mjashley.atlassian.net/wiki/spaces/DO/pages/7569460"
confluence_space: "DO"
category: "Installation"
created_date: ""
updated_date: ""
migrated_date: "2025-09-14"
tags: ['frontend', 'docker', 'traefik', 'golang', 'security', 'authelia', 'storage']
---

# Cloud Storage Setup Guide

## Overview

HomelabARR supports optional cloud storage integration for users who want to extend their storage capacity beyond local drives. This guide walks through setting up cloud storage providers with the modern web-based interfaces.
> 

**Note**: Cloud storage is completely optional. Most users post-2022 use local storage only, as Google's unlimited storage era has ended.
## Prerequisites

- HomelabARR CLI installed with Traefik/Authelia stack
- Domain configured with SSL certificates
- Basic understanding of cloud storage providers (Google Drive, Backblaze, OneDrive, etc.)
## Components Overview

### 1. Mount-Enhanced

- Modern multi-cloud storage mount service
- Web UI at`https://mount.yourdomain.com`
- Features cost tracking and automatic provider selection
- Supports Google Drive, Backblaze B2, OneDrive, pCloud
### 2. Rclone-GUI

- Web-based configuration interface for cloud providers
- Available at`https://rclone-gui.yourdomain.com`
- Default credentials:`rclone/rclone`
- User-friendly alternative to command-line rclone config
### 3. HomelabARR-Uploader

- Automated upload management service
- Web UI at`https://uploader.yourdomain.com`
- Monitors download folders and uploads to cloud
- Includes bandwidth limiting and scheduling
## Step-by-Step Setup

### Step 1: Deploy the Required Containers

```
# Navigate to HomelabARR directory
cd /opt/homelabarr/apps/system

# Deploy rclone-gui for configuration
docker-compose -f rclone-gui.yml up -d

# Deploy mount-enhanced for cloud mounting
docker-compose -f mount-enhanced.yml up -d

# Optional: Deploy uploader for automated uploads
docker-compose -f homelabarr-uploader.yml up -d
```