---
title: "HomelabARR-CLI : 2025-08-24 Storage Management - SnapRAID and Drive Categorization"
confluence_id: "8913051"
confluence_url: "https://your-instance.atlassian.net/wiki/spaces/DO/pages/8913051"
confluence_space: "DO"
category: "Storage"
created_date: "2025-08-24"
updated_date: "2025-08-24"
migrated_date: "2025-09-14"
tags: ['frontend', 'august-2025', 'docker', 'golang', 'monitoring', 'storage']
---

# 2025-08-24 Storage Management - SnapRAID and Drive Categorization

## Overview

Comprehensive storage management implementation for HomelabARR v2.0 featuring automatic drive categorization and SnapRAID integration.
## Drive Categorization System

- **Automatic Detection**: SSD vs HDD classification
- **Smart Pooling**: Separate pools for performance and capacity
- **Visual Dashboard**: Real-time storage visualization
## SnapRAID Integration

- **Parity Protection**: Configurable parity drives
- **Scheduled Scrubs**: Automated data integrity checks
- **Recovery Options**: Built-in restoration tools
## Implementation Details

- Go backend for cross-platform drive detection
- WebSocket updates for real-time monitoring
- Docker volume integration
- MergerFS for unified filesystem
## Configuration

- Template-based setup
- Environment variable management
- Automatic pool assignment
- Health monitoring integration