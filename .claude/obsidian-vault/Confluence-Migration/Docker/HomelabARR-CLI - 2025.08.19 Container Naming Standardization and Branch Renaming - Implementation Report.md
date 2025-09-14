---
title: "HomelabARR-CLI : 2025.08.19 Container Naming Standardization and Branch Renaming - Implementation Report"
confluence_id: "6553602"
confluence_url: "https://mjashley.atlassian.net/wiki/spaces/DO/pages/6553602"
confluence_space: "DO"
category: "Docker"
created_date: ""
updated_date: ""
migrated_date: "2025-09-14"
tags: ['frontend', 'epic', 'docker']
---

# Container Naming Standardization and Branch Renaming - Implementation Report

## [[HL-117]])**: Migrated all Docker container references from`docker-*`to[[HL-124]])**: Renamed default branch from`master`to`main`
## Container Naming Standardization (HL-117)

### Overview

Standardized all container image references across the HomelabARR CLI ecosystem to use the`homelabarr-`prefix instead of the legacy`docker-`prefix.
### Changes Implemented

#### HomelabARR CLI Repository

- **34 files updated**with new container naming
- **Key containers migrated:**
- `docker-mount`→`homelabarr-mount`
- `docker-restic`→`homelabarr-restic`
- `docker-vnstat`→`homelabarr-vnstat`
- `docker-mod-healthcheck`→`homelabarr-mod-healthcheck`
- `docker-mod-qbittorrent`→`homelabarr-mod-qbittorrent`
- `docker-mod-tautulli`→`homelabarr-mod-tautulli`
- `docker-mod-nzbget`→`homelabarr-mod-nzbget`
- `docker-mod-sabnzbd`→`homelabarr-mod-sabnzbd`
#### HomelabARR Containers Repository

- **Removed 17 duplicate docker-* containers**
- **244 files changed**with 12,655 deletions
- **Renamed`docker-gui-noble`to`homelabarr-gui-noble`**
### GitHub Workflows Updated

- `build-containers.yml`: Updated image names in metadata
- `docker-build-push.yml`: Updated frontend/backend image names
- All container references now use`ghcr.io/smashingtags/homelabarr-*`format
### Pull Request

- **PR #25**:[Container Naming Standardization](https://github.com/smashingtags/homelabarr-cli/pull/25)
- Successfully merged to main branch
## Branch Renaming (HL-124)

### Overview

Renamed the default branch from`master`to`main`to align with modern Git standards and improve consistency.
### Implementation Steps

- 

**Workflow Updates**- Updated 6 GitHub workflow files:
  - `build-containers.yml`
  - `docker-build-push.yml`
  - `renovate.yaml`
  - `newrelease.yml`
  - `changelog.yml`
  - `pages.yml.disabled`
- 

**Branch Operations**- Renamed local branch from`master`to`main`- Pushed`main`branch to GitHub - Updated GitHub repository default branch setting - Deleted old`master`branch
### Files Modified

```
# Example changes in workflows
# Before:
branches: [ master, main, develop ]
# After:
branches: [ main, develop ]

# Before:
if: github.ref == 'refs/heads/master'
# After:
if: github.ref == 'refs/heads/main'
```