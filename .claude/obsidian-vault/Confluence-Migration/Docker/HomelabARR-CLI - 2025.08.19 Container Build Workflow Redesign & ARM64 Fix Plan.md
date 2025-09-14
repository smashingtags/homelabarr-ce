---
title: "HomelabARR-CLI : 2025.08.19 Container Build Workflow Redesign & ARM64 Fix Plan"
confluence_id: "6455348"
confluence_url: "https://your-instance.atlassian.net/wiki/spaces/DO/pages/6455348"
confluence_space: "DO"
category: "Docker"
created_date: ""
updated_date: ""
migrated_date: "2025-09-14"
tags: ['frontend', 'docker']
---

# Container Build Workflow Redesign & ARM64 Fix Plan

## Current Issues Analysis

### Problems with Current Workflow

- **Massive Parallel Matrix**: 70 containers building simultaneously causing resource exhaustion
- **Poor Debugging Experience**: When builds fail, hard to identify specific issues
- **ARM64 Build Failures**: Multiple containers failing on ARM64 architecture
- **No Build Dependencies**: Base images should be built before dependent containers
- **Inconsistent Naming**: Still building both`homelabarr-ui`and`homelabarr-ui`variants
- **Resource Contention**: Self-hosted runners overwhelmed by parallel builds
### Current ARM64 Failures

Based on previous analysis, these containers are failing on ARM64: -**docker-gdsa**: ARM64 emulation issues with build tools -**docker-crunchydl**: Download URL architecture-specific issues
-**docker-vnstat**: Debian repository ARM64 package availability -**docker-local-persist**: Build context and cross-compilation issues
## Redesigned Workflow Strategy

### Build Pipeline Architecture

```
Stage 1: Base Images (Sequential)
├── docker-ubuntu-focal
├── docker-ubuntu-jammy  
├── docker-ubuntu-noble
├── docker-alpine-v3
└── docker-ui

Stage 2: Application Dependencies (Parallel Groups)
├── Group A: homelabarr-* containers (Batch 1-15)
├── Group B: homelabarr-* containers (Batch 16-30)
└── Group C: Mod containers (All mods)

Stage 3: Specialized Builds (Sequential)
├── Nightly builds
└── Problem containers (ARM64 fixes)
```