---
title: "HomelabARR-CLI : 2025.08.19 Ubuntu 24.04 Noble Container Migration Plan - HL-81"
confluence_id: "6389761"
confluence_url: "https://mjashley.atlassian.net/wiki/spaces/DO/pages/6389761"
confluence_space: "DO"
category: "Docker"
created_date: ""
updated_date: ""
migrated_date: "2025-09-14"
tags: ['frontend', 'epic', 'security', 'docker']
---

# Ubuntu 24.04 Noble Container Migration Plan

## Executive Summary

**CRITICAL**: Ubuntu 20.04 LTS (Focal Fossa) reached End of Life in April 2025 and is no longer receiving security updates as of August 19, 2025. This migration is now a critical security requirement.[[HL-81]]- Migrate HomelabARR Containers from DockServer to HomelabARR Registry
## Current State Analysis

### Affected Base Images

The HomelabARR container ecosystem currently uses outdated Ubuntu versions: -**docker-ubuntu-focal**- Ubuntu 20.04 LTS (EOL as of April 2025) ⚠️**CRITICAL SECURITY RISK**-**docker-ubuntu-jammy**- Ubuntu 22.04 LTS (EOL April 2027) -**homelabarr-ubuntu-focal**- Ubuntu 20.04 LTS (EOL as of April 2025) ⚠️**CRITICAL SECURITY RISK**-**homelabarr-ubuntu-jammy**- Ubuntu 22.04 LTS (EOL April 2027)
### Immediate Security Implications

- **Zero-day vulnerabilities**: No patches available for Focal-based containers
- **Compliance issues**: Running EOL operating systems violates most security policies
- **Supply chain risk**: Dependencies may drop support for EOL Ubuntu versions
## Migration Strategy

### Phase 1: Parallel Noble Images (Immediate - Week 1)

Create Ubuntu 24.04 Noble base images alongside existing ones: -**docker-ubuntu-noble**- New Ubuntu 24.04 LTS base -**homelabarr-ubuntu-noble**- New HomelabARR Ubuntu 24.04 base
### Phase 2: Testing & Validation (Week 1-2)

- Build Noble base images with s6-overlay v3.1.5.0
- Test with critical containers: - docker-gui / homelabarr-gui - docker-wiki / homelabarr-wiki - docker-restic / homelabarr-restic
- Validate functionality: - Multi-architecture support (amd64/arm64) - S6 process supervision - User/permission management - Package availability
### Phase 3: Container Migration (Week 2-3)

Migrate containers from Focal to Noble: 1. Update Dockerfile FROM statements 2. Resolve package name changes 3. Update any Ubuntu version-specific configurations 4. Test each migrated container
### Phase 4: Deprecation (Week 4)

- Mark Focal images as deprecated
- Update documentation
- Notify users via Discord
- Plan removal timeline (30 days)
## Technical Implementation Details

### Noble Base Image Structure

```
FROM ubuntu:24.04
ARG OVERLAY_VERSION="v3.1.5.0"
ARG TARGETPLATFORM

# Install base packages
RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    tzdata \
    locales \
    && rm -rf /var/lib/apt/lists/*

# Install s6-overlay
ADD https://github.com/just-containers/s6-overlay/releases/download/${OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp/
ADD https://github.com/just-containers/s6-overlay/releases/download/${OVERLAY_VERSION}/s6-overlay-${TARGETPLATFORM}.tar.xz /tmp/
RUN tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz \
    && tar -C / -Jxpf /tmp/s6-overlay-${TARGETPLATFORM}.tar.xz \
    && rm /tmp/*.tar.xz

# Standard HomelabARR configuration
ENV DEBIAN_FRONTEND="noninteractive" \
    PUID=1000 \
    PGID=1000 \
    TZ="UTC"

ENTRYPOINT ["/init"]
```