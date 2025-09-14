---
title: "HomelabARR-CLI : 2025.08.19 Docker Image Migration Plan - HomelabARR to HomelabARR"
confluence_id: "5865475"
confluence_url: "https://your-instance.atlassian.net/wiki/spaces/DO/pages/5865475"
confluence_space: "DO"
category: "Docker"
created_date: ""
updated_date: ""
migrated_date: "2025-09-14"
tags: ['frontend', 'docker', 'golang', 'security', 'project-management']
---

## Docker Image Migration Strategy

### Overview

Strategic plan to migrate from HomelabARR container images to HomelabARR's own GitHub Container Registry (GHCR).
### Current State

- **60 configuration files**currently reference ghcr.io/homelabarr/ images
- Primary dependencies:
- ghcr.io/homelabarr/docker-mod-healthcheck:v1.0.0
- ghcr.io/homelabarr/docker-mod-qbittorrent:v1.0.0
### Migration Phases

#### Phase 1: Current Development (Active)

- Keep existing HomelabARR references
- Document all dependencies
- Prepare migration tooling
#### Phase 2: Container Registry Setup (Pending)

- Build HomelabARR Docker mods
- Publish to ghcr.io/smashingtags/
- Set up GitHub Actions CI/CD
#### Phase 3: Reference Migration (Planned)

Migration pattern: - Before: ghcr.io/homelabarr/docker-mod-healthcheck:v1.0.0 - After: ghcr.io/smashingtags/homelabarr-mod-healthcheck:latest
#### Phase 4: Pre-Public Cleanup (Future)

- Remove .claude/homelabarr-other-git-repositories/
- Clean git history
- Final security audit
### Technical Implementation

#### Currently Published HomelabARR Images

- ghcr.io/smashingtags/homelabarr-frontend ✅
- ghcr.io/smashingtags/homelabarr-backend ✅
- ghcr.io/smashingtags/homelabarr-site ✅
- ghcr.io/smashingtags/local-persist ✅
#### Required Docker Mods

- homelabarr-mod-healthcheck
- homelabarr-mod-qbittorrent
- homelabarr-mod-sabnzbd
- homelabarr-mod-nzbget
- homelabarr-mod-tautulli
### Risk Management

- Test thoroughly in development
- Staged rollout approach
- Maintain backward compatibility
- Document all changes
### Success Criteria

- All 60 files successfully migrated
- All applications start without errors
- No regression in functionality
- Clean repository for public release
### Timeline

- Phase 1: Ongoing
- Phase 2: When container build pipeline ready
- Phase 3: After Phase 2 testing
- Phase 4: Before public release
### Related Documents

- Local notes: .claude/local-notes/docker-image-migration-plan.md
- Jira ticket: To be created