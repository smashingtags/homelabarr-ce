---
title: "HomelabARR-CLI : 2025.08.19 Container Naming Standardization Plan"
confluence_id: "6455326"
confluence_url: "https://your-instance.atlassian.net/wiki/spaces/DO/pages/6455326"
confluence_space: "DO"
category: "Docker"
created_date: ""
updated_date: ""
migrated_date: "2025-09-14"
tags: ['frontend', 'docker']
---

# Container Naming Standardization Plan

## Overview

Standardize all HomelabARR container names to use the`homelabarr-`prefix for brand cohesion and eliminate redundant containers.
## Current State Analysis

### Redundant Containers Identified

- **docker-crunchy**vs**homelabarr-crunchy**: Identical functionality, same entrypoint scripts
- **docker-crunchydl**vs**homelabarr-crunchydl**: Both are Crunchyroll downloaders
- **docker-***vs**homelabarr-*** for all 15 application containers
### Critical CI Pipeline Dependencies

- **Version Update Scripts**:`.templates/apps/docker-*.sh`generate latest versions
- **Template System**: Only`docker-`prefixed containers get version updates
- **GitHub Actions**: Already supports both naming conventions in matrix
## Migration Strategy

### Phase 1: Template Script Migration

- Rename all`.templates/apps/docker-*.sh`→`homelabarr-*.sh`
- Update template scripts to reference`homelabarr-`paths
- Update version.sh to process`homelabarr-`containers
### Phase 2: Container Consolidation

- Remove redundant`docker-*`application containers
- Keep only`homelabarr-*`versions
- Update GitHub Actions workflow matrix
### Phase 3: Base Image Strategy

**Keep base images with descriptive names**: -`docker-ubuntu-focal`,`docker-ubuntu-jammy`,`docker-ubuntu-noble`-`docker-alpine-v3`,`docker-config`,`docker-ui`- These are foundational and don't need HomelabARR branding
## Implementation Plan

### Pre-requisites

- [ ] Backup current repository state
- [ ] Test CI pipeline with sample container
- [ ] Verify no external dependencies on`docker-*`names
### Execution Steps

- 

**Template Migration**(Low Risk)`bash    cd .templates/apps    for file in docker-*.sh; do      mv "$file" "homelabarr-${file#docker-}.sh"    done`
- 

**Update Template Content**(Medium Risk) - Fix APPFOLDER paths in template scripts - Update COPY commands in Dockerfile generation - Test version script with new naming
- 

**Remove Redundant Containers**(High Impact) - Delete`apps/docker-*`directories (except base dependencies) - Keep only`apps/homelabarr-*`versions - Update GitHub Actions matrix
- 

**Validation**(Critical) - Test version update script - Verify container builds succeed - Confirm no broken dependencies
## Risk Assessment

### Low Risk ✅

- Template script renaming
- GitHub Actions matrix already supports both
- No external API dependencies
### Medium Risk ⚠️

- COPY path updates in Dockerfiles
- Version script processing logic
- Container image tagging consistency
### High Risk 🔴

- Removing existing`docker-*`containers
- Potential downstream YAML references
- User confusion during transition
## Success Criteria

- [ ] All containers use`homelabarr-`prefix
- [ ] Version updates work for all containers
- [ ] CI pipeline builds successfully
- [ ] No functional regressions
- [ ] Brand consistency achieved
## Rollback Plan

- Restore`.templates/apps/docker-*.sh`files
- Re-add removed`apps/docker-*`directories
- Revert GitHub Actions workflow matrix
- Git reset to pre-migration commit
## Timeline

- **Planning**: 1 day (feasibility confirmed)
- **Implementation**: 2 days (template migration + testing)
- **Validation**: 1 day (full CI pipeline test)
- **Documentation**: 1 day (update documentation)

**Total Effort**: 5 days