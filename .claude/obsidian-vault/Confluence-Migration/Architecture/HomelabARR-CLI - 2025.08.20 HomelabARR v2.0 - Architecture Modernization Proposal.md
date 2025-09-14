---
title: "HomelabARR-CLI : 2025.08.20 HomelabARR v2.0 - Architecture Modernization Proposal"
confluence_id: "6914081"
confluence_url: "https://your-instance.atlassian.net/wiki/spaces/DO/pages/6914081"
confluence_space: "DO"
category: "Architecture"
created_date: "2025-08-20"
updated_date: "2025-08-20"
migrated_date: "2025-09-14"
tags: ['frontend', 'media-server', 'docker', 'traefik', 'golang']
---

# HomelabARR v2.0 - Architecture Modernization Proposal

## Executive Summary

Proposal to modernize HomelabARR CLI from shell-script based architecture to a Go-based solution with Terraform/OpenTofu infrastructure management, addressing current pain points and enabling future scalability.
## Current Architecture Pain Points

### Technical Debt

- **Shell Script Proliferation**: 50+ bash scripts with no testing framework
- **Platform Dependencies**: WSL requirements on Windows, path resolution issues
- **Docker Compose Sprawl**: 100+ individual YAML files with manual management
- **No State Management**: Cannot track deployments or rollback changes
- **Configuration Drift**: Manual edits lead to inconsistent environments
- **Build Complexity**: Manual dependency ordering (as seen with base → mods → containers)
### Operational Challenges

- **No Rollback Capability**: Failed deployments require manual intervention
- **Fragile Error Handling**: Shell scripts fail silently or cascade failures
- **Limited Extensibility**: Community contributions require forking entire project
- **Testing Nightmare**: Cannot unit test bash scripts effectively
- **Cross-platform Issues**: Different behavior on Linux/Mac/Windows(WSL)
## Proposed Architecture: Go + Terraform/OpenTofu

### Core Technology Stack

#### Backend: Go (Golang)

**Rationale:**- Single binary deployment (no runtime dependencies) - Native Docker SDK support - True cross-platform without WSL - Built-in concurrency for container orchestration - Strong typing prevents runtime errors - Can embed resources (templates, configs) in binary - Excellent CLI libraries (Cobra, Viper)
#### Infrastructure: Terraform/OpenTofu

**Rationale:**- Declarative infrastructure as code - Dependency graph resolution (solves build ordering) - State management with backends (S3, local, etc.) - Rollback and drift detection - Existing providers for Docker, Cloudflare, GitHub - Module system for reusability
### Proposed Architecture Design

```
┌─────────────────────────────────────────┐
│         HomelabARR CLI (Go Binary)      │
├─────────────────────────────────────────┤
│  Commands Layer (Cobra)                 │
│  - deploy, destroy, backup, update      │
├─────────────────────────────────────────┤
│  Business Logic Layer                   │
│  - Stack Management                     │
│  - Configuration Validation             │
│  - State Management                     │
├─────────────────────────────────────────┤
│  Infrastructure Layer                   │
│  - Terraform Executor                   │
│  - Docker SDK Client                    │
│  - Template Engine                      │
├─────────────────────────────────────────┤
│  Provider Layer                         │
│  - Docker Provider                      │
│  - Cloudflare Provider                  │
│  - Traefik Provider                     │
└─────────────────────────────────────────┘
```