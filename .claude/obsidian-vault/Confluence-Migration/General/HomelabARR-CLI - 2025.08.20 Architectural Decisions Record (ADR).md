---
title: "HomelabARR-CLI : 2025.08.20 Architectural Decisions Record (ADR)"
confluence_id: "7503955"
confluence_url: "https://mjashley.atlassian.net/wiki/spaces/DO/pages/7503955"
confluence_space: "DO"
category: "General"
created_date: ""
updated_date: ""
migrated_date: "2025-09-14"
tags: ['frontend', 'media-server', 'docker', 'golang', 'storage']
---

# Architectural Decisions Record (ADR)

## Project Origin & History

### The Evolution: PGBlitz → Dockserver → HomelabARR

**The Complete Timeline:**1.**PGBlitz Era (2018-2020)**: The original unlimited Google Drive media server solution 2.**Dockserver Fork (2020-2023)**: PGBlitz fork that continued after the original ceased development
3.**HomelabARR (2023-Present)**: Original platform that strategically integrated Dockserver's CLI components
### The Real Story:

As a Software Development Project Manager by trade (not a coder initially), I was deeply involved in the PGBlitz community during the Google unlimited storage era. When PGBlitz development ceased, Dockserver emerged as its spiritual successor. However, I envisioned something better - a modern web-based platform that would be accessible to non-technical users.

I began building HomelabARR as an original project with: - Modern web application frontend - RESTful API backend with JSON storage - User-friendly interfaces replacing complex shell scripts - Simplified installation and management

To accelerate the MVP, I made the strategic decision to integrate Dockserver's proven Docker Compose templates rather than recreate them from scratch. This saved 6+ months of development time while allowing focus on the superior user experience.
### What's Original HomelabARR:

- Web application frontend (built from scratch)
- API backend with JSON storage (built from scratch)
- Container architecture and naming convention
- GitHub Actions workflows
- Modern web UIs replacing shell scripts
- Simplified installation process
- All homelabarr-* branded containers
- Post-unlimited-storage architecture
### What Was Adapted from Dockserver:

- CLI repository structure (heavily modified)
- Docker Compose YAML templates (rebranded and modernized)
- Some utility scripts (updated and improved)
### Git History Preservation:

Despite Dockserver blocking direct forking from the`smashingtags`account, the git history was preserved through a workaround using the`eidanyosoy`account to maintain proper attribution. This extra effort was taken instead of simply uploading a zip file, demonstrating commitment to open source ethics and proper attribution.
### Why This Matters:

This project represents a PM's journey into coding, bringing a unique perspective: -**User-first design**from years of gathering requirements -**Systematic approach**to architecture decisions -**Documentation focus**from PM experience -**Community-driven**development from understanding stakeholder needs
## Introduction

This document records all significant architectural decisions made during the development of HomelabARR and the integration of Dockserver's CLI components. Each decision was carefully considered to create a sustainable, user-friendly, and maintainable self-hosted media server platform for the post-unlimited-storage era.
> 

**Note**: This is not a fork - it's an original platform that integrated useful components from Dockserver while discarding its technical debt and outdated architecture.
## Decision Log

### 1. Integrate Dockserver CLI Rather Than Build From Scratch

**Context:**- HomelabARR webapp and API were already built - Needed Docker Compose management system - Dockserver had working YAML templates - Time to market was important for MVP

**Decision:**Adapt Dockserver's CLI repository while maintaining HomelabARR's architecture.

**Rationale:**- Faster MVP delivery (saved 6+ months) - Proven Docker Compose templates - Could focus on improving rather than recreating - Maintain our superior webapp/API architecture

**Consequences:**- ✅ Accelerated development significantly - ✅ Inherited working configurations - ⚠️ Had to clean up technical debt - ✅ Opportunity to modernize legacy code
### 2. Remove Google Drive Service Account (GDSA) Dependency

**Context:**- PGBlitz/Dockserver were built for unlimited Google Drive - Complex GDSA rotation to bypass 750GB/day upload limits - Google ended unlimited storage in 2022 - Most users now prefer local storage

**Decision:**Remove all GDSA integration and make cloud storage optional.

**Rationale:**- 99% of new users don't have unlimited Google Drive - GDSA setup was complex and error-prone - Simplifies installation and maintenance - Cloud storage remains available for those who want it

**Consequences:**- ✅ Simpler setup process - ✅ Faster container startup - ✅ Works out-of-box with local storage - ⚠️ Users migrating from PGBlitz/Dockserver need to adjust configs
### 3. Eliminate Mount Service Dependencies

**Context:**- Dockserver required mount service to start before any media containers - Created cascading startup failures if mount had issues - Forced cloud storage on users who only wanted local storage

**Decision:**Remove all`depends_on: mount`declarations from container configurations.

**Rationale:**- Containers should be independent and resilient - Local storage users shouldn't need mount services - Follows microservices best practices - Prevents single point of failure

**Consequences:**- ✅ Containers start independently - ✅ No cascading failures - ✅ Works with or without cloud storage - ✅ Faster overall stack startup
### 4. Use :latest Tags with Environment Variable Override

**Context:**- Version pinning vs auto-updates debate - Dockupdater needs :latest tags to function - Users want both stability and updates

**Decision:**Use`:latest`tags by default, configurable via environment variables.

**Implementation:**
```
# docker-compose.yml
image: "${PLEXIMAGE}"

# .env
PLEXIMAGE=linuxserver/plex:latest

# User can override:
PLEXIMAGE=linuxserver/plex:1.32.5
```