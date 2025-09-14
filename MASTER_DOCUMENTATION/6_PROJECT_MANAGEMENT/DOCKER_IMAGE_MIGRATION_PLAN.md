# Docker Image Migration Plan - HomelabARR CLI

## Overview
Strategic plan to migrate from HomelabARR docker images to HomelabARR's own GHCR registry.

## Current State Analysis

### Docker Image Dependencies
- **60 files** currently reference `ghcr.io/smashingtags/` images
- Primary dependencies:
  - `ghcr.io/smashingtags/homelabarr-mod-healthcheck:v1.0.0`
  - `ghcr.io/smashingtags/docker-mod-qbittorrent:v1.0.0`

### Affected Files Categories
- Production apps: `apps/mediaserver/*.yml`, `apps/downloadclients/*.yml`, `apps/mediamanager/*.yml`
- Local mode apps: `apps/local-mode-apps/*.yml`
- Templates: `apps/.templates/**/*.yml`
- Config examples: `apps/.config/*.yml`, `apps/.examples/*.yml`

### Currently Published HomelabARR Images
- ✅ `ghcr.io/smashingtags/homelabarr-frontend`
- ✅ `ghcr.io/smashingtags/homelabarr-backend`
- ✅ `ghcr.io/smashingtags/homelabarr-site`
- ✅ `ghcr.io/smashingtags/local-persist`
- ✅ `ghcr.io/smashingtags/container-port-manager`

## Migration Strategy

### Phase 1: Current State (Private Development)
**Status: ACTIVE**
- Keep all `ghcr.io/smashingtags/` references unchanged
- Maintain `.claude/homelabarr-other-git-repositories/` in tracking for reference
- Continue development with existing docker mods
- Document all dependencies and prepare migration scripts

### Phase 2: Container Registry Setup
**Status: PENDING**
1. Build and publish HomelabARR docker mods from `homelabarr-containers-master`:
   - `homelabarr-mod-healthcheck`
   - `homelabarr-mod-qbittorrent`
   - `homelabarr-mod-sabnzbd`
   - `homelabarr-mod-nzbget`
   - `homelabarr-mod-tautulli`
   - `homelabarr-mod-rclone`
   - `homelabarr-mod-storagecheck`

2. Set up GitHub Actions for automated builds
3. Test each mod thoroughly

### Phase 3: Image Reference Migration
**Status: PLANNED**
1. Create migration script to update all YAML files
2. Update pattern:
   ```yaml
   # Before:
   - "DOCKER_MODS=ghcr.io/themepark-dev/theme.park:plex|ghcr.io/smashingtags/homelabarr-mod-healthcheck:v1.0.0"
   
   # After:
   - "DOCKER_MODS=ghcr.io/themepark-dev/theme.park:plex|ghcr.io/smashingtags/homelabarr-mod-healthcheck:latest"
   ```
3. Test all applications with new images
4. Create rollback plan

### Phase 4: Repository Cleanup (Pre-Public)
**Status: FUTURE**
1. Remove `.claude/homelabarr-other-git-repositories/` from repository
2. Add to `.gitignore` permanently
3. Clean git history if needed
4. Final security audit

## Technical Implementation Details

### Docker Mod Functionality
- **healthcheck**: Adds health check endpoints to containers
- **qbittorrent**: Enhances qBittorrent with additional features
- **sabnzbd**: SABnzbd specific enhancements
- **tautulli**: Tautulli integration improvements

### Migration Script Requirements
- Preserve theme.park mods (they stay as-is)
- Only replace homelabarr references
- Maintain version tags where applicable
- Create backup before changes

## Risk Assessment

### Risks
1. Breaking changes in mod functionality
2. Version incompatibilities
3. Missing features in HomelabARR mods vs HomelabARR mods

### Mitigation
1. Thorough testing in development environment
2. Staged rollout (test with few apps first)
3. Maintain compatibility layer if needed
4. Document all changes for users

## Success Criteria
- [ ] All 60 files successfully migrated
- [ ] All applications start without errors
- [ ] Health checks functioning properly
- [ ] No regression in functionality
- [ ] Clean git history
- [ ] Documentation updated

## Timeline
- Phase 1: Ongoing
- Phase 2: When container build pipeline ready
- Phase 3: After Phase 2 testing complete
- Phase 4: Before public release

## Dependencies
- HomelabARR containers repository setup
- GitHub Actions for container builds
- GHCR registry configuration
- Testing environment

## Notes
- Keep backward compatibility during transition
- Consider supporting both image sources temporarily
- Document migration for any existing users

---
*Created: 2025-08-19*
*Status: In Planning*
*Owner: HomelabARR Team*