---
title: "HomelabARR-CLI : 2025-09-14 - HomelabARR Strategic Repository Architecture & Convergence Plan"
confluence_id: "19038242"
confluence_url: "https://your-instance.atlassian.net/wiki/spaces/DO/pages/19038242"
confluence_space: "DO"
category: "Architecture"
created_date: "2025-09-14"
updated_date: "2025-09-14"
migrated_date: "2025-09-14"
tags: ['frontend', 'september-2025', 'storage', 'golang']
---

# HomelabARR Strategic Repository Architecture & Convergence Plan

**Date**: September 14, 2025 - 4:57 AM EST
**Author**: Technical Strategy Team
**Status**: APPROVED - Active Strategy
**Labels**: architecture, strategy, product-roadmap, repository-management, critical-documentation
## Executive Summary

HomelabARR is executing a strategic three-phase repository architecture that will ultimately converge into a single, maintainable codebase while preserving community engagement and enabling monetization. This document outlines the definitive strategy for repository management and product evolution.
## Current Repository Structure (Phase 1 - Active)

### Repository Breakdown

- 

**homelabarr-cli**(Original Monorepo) -**Status**: TO BE ARCHIVED -**Purpose**: Historical reference and Git history preservation -**Action**: Will become read-only archive after sanitization complete -**Maintenance**: NONE - reference only
- 

**homelabarr-ce**(Community Edition) -**Status**: ACTIVE PRODUCTION -**Current Stack**: Node.js/Express + React + Tailwind CSS -**Purpose**: Immediate community delivery while PE development continues -**Users**: Discord community, existing deployments -**Maintenance**: Minimal - critical fixes only
- 

**homelabarr-pe**(Professional Edition) -**Status**: ACTIVE DEVELOPMENT -**Stack**: Go + React + shadcn-ui + SnapRAID/MergerFS -**Purpose**: Next-generation architecture with NAS capabilities -**Target**: Q4 2025 production release -**Maintenance**: Primary development focus
## The Convergence Strategy (Phase 2 - Planned)

### Architectural Unification

**Target State**: Single codebase, two products
```
Future Architecture (Post-PE Release):
├── HomelabARR-CE
│   └── PE Codebase with NAS features disabled
│       ├── Go backend (same as PE)
│       ├── React frontend (same as PE)
│       └── Feature flags: NAS_ENABLED=false
│
└── HomelabARR-PE
    └── Full PE Codebase
        ├── Go backend with all features
        ├── React frontend with all features
        └── Feature flags: NAS_ENABLED=true
```