---
title: "HomelabARR-CLI : 2025.08.20 HomelabARR HLUpdater Container - HL-149"
confluence_id: "7569410"
confluence_url: "https://mjashley.atlassian.net/wiki/spaces/DO/pages/7569410"
confluence_space: "DO"
category: "Docker"
created_date: "2025-08-20"
updated_date: "2025-08-20"
migrated_date: "2025-09-14"
tags: ['monitoring', 'docker']
---

# HomelabARR HLUpdater Container

## Overview

The**homelabarr-hlupdater**(formerly homelabarr-dockupdate) is a container update monitoring bot that checks Docker Hub for newer versions of running containers and sends Discord notifications when updates are available.
## Container Details

- **New Name**:`homelabarr-hlupdater`
- **Old Name**:`homelabarr-dockupdate`(deprecated)
- **GHCR Location**:`ghcr.io/smashingtags/homelabarr-hlupdater:latest`
- **Purpose**: Monitor Docker containers for available updates
- **Check Interval**: Every 10 minutes
- **Notification Method**: Discord webhook
## Features

- Automatically scans all running Docker containers
- Checks Docker Hub for newer image versions
- Sends Discord notifications for available updates
- Lightweight Alpine-based container
- Simple webhook configuration
## Usage

### Docker Run Command

```
docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  ghcr.io/smashingtags/homelabarr-hlupdater:latest \
  DS=YOUR_DISCORD_WEBHOOK_ID
```