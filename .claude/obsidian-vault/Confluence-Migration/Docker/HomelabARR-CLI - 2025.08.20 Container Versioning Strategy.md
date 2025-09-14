---
title: "HomelabARR-CLI : 2025.08.20 Container Versioning Strategy"
confluence_id: "7503898"
confluence_url: "https://mjashley.atlassian.net/wiki/spaces/DO/pages/7503898"
confluence_space: "DO"
category: "Docker"
created_date: ""
updated_date: ""
migrated_date: "2025-09-14"
tags: ['frontend', 'security']
---

# Container Versioning Strategy

## Overview

HomelabARR containers now use semantic versioning (SemVer) with automated release management based on conventional commits. This ensures consistent, predictable version numbers across all containers.
## Version Format

All containers follow semantic versioning:**MAJOR.MINOR.PATCH**-**MAJOR**: Breaking changes requiring migration -**MINOR**: New features, backward compatible -**PATCH**: Bug fixes and minor improvements
## Release Channels

### Production Channels

- **latest**- Stable production releases from main branch
- **v1.2.3**- Specific version tags for pinning
- **v1.2**- Minor version tags (latest patch)
- **v1**- Major version tags (latest minor)
### Development Channels

- **dev**- Development builds from dev branch
- **nightly**- Automated nightly builds (select containers)
- **pr-123**- Pull request preview builds
## Conventional Commits

### Commit Types and Version Impact
Commit TypeVersion ChangeExample`feat:`Minor (1.X.0)`feat: Add health check endpoint``fix:`Patch (1.0.X)`fix: Resolve memory leak in worker``perf:`Patch (1.0.X)`perf: Optimize database queries``refactor:`Patch (1.0.X)`refactor: Simplify authentication logic``docs:`Patch (1.0.X)`docs: Update API documentation``cleanup:`Patch (1.0.X)`cleanup: Remove deprecated code``BREAKING CHANGE:`Major (X.0.0)In commit body or footer`chore:`No release`chore: Update dependencies``test:`No release`test: Add unit tests``ci:`No release`ci: Update GitHub Actions`