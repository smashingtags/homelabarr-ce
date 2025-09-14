---
title: "HomelabARR-CLI : 2025.08.19 HomelabARR Container Registry - Complete Documentation"
confluence_id: "6815747"
confluence_url: "https://your-instance.atlassian.net/wiki/spaces/DO/pages/6815747"
confluence_space: "DO"
category: "Docker"
created_date: ""
updated_date: ""
migrated_date: "2025-09-14"
tags: ['frontend', 'golang', 'docker']
---

# HomelabARR Container Registry Documentation

## Overview

The HomelabARR Container Registry provides 60+ purpose-built Docker containers optimized for the HomelabARR CLI ecosystem. All containers are automatically built and published to GitHub Container Registry (GHCR) at`ghcr.io/smashingtags/`.
## Repository Information

- **GitHub Repository**:[https://github.com/smashingtags/homelabarr-containers](https://github.com/smashingtags/homelabarr-containers)
- **Registry**: GitHub Container Registry (ghcr.io)
- **Namespace**: smashingtags
- **Architecture Support**: linux/amd64, linux/arm64
- **Build System**: GitHub Actions with self-hosted runners
- **Default Branch**: main (recently migrated from master)
## Container Categories

### 1. Base Images (20 containers)

Foundation images that other containers build upon.
#### Alpine-based Base Images
ContainerBasePurposeVersion`alpine`Alpine 3.22.1Minimal Alpine base3.22.1`docker-alpine`Alpine 3.22.1Alpine with Docker tools3.22.1`docker-alpine-v3`Alpine 3.22.1Alpine v3 specific base3.22.1`homelabarr-alpine`Alpine 3.22.1HomelabARR-optimized Alpine3.22.1`homelabarr-alpine-v3`Alpine 3.22.1HomelabARR Alpine v33.22.1