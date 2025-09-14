---
title: "HomelabARR-CLI : 2025-08-25 - Native Linux File Sharing Architecture for HomelabARR NAS"
confluence_id: "9928817"
confluence_url: "https://mjashley.atlassian.net/wiki/spaces/DO/pages/9928817"
confluence_space: "DO"
category: "Architecture"
created_date: "2025-08-25"
updated_date: "2025-08-25"
migrated_date: "2025-09-14"
tags: ['frontend', 'august-2025', 'storage', 'golang']
---

# Native Linux File Sharing Architecture for HomelabARR NAS

## Executive Summary

HomelabARR CLI requires network file sharing capabilities to function as a complete NAS solution. This document outlines the architecture for implementing native Linux SMB/NFS file sharing using system services rather than containers or embedded implementations.
## Problem Statement

**Current State**: HomelabARR provides storage management via SnapRAID but lacks network sharing**Issue**: Without file sharing, it's just local storage - not a NAS**Solution**: Leverage native Linux kernel-level SMB/NFS services with Go management layer
## Technical Discovery

### Key Insight: Native Linux Capabilities

Linux distributions already include enterprise-grade file sharing in the kernel:

**SMB/CIFS (via Samba)**: - Kernel module:`cifs`- Userspace:`samba`,`samba-common-bin`- Performance: Kernel-level, fastest possible - Compatibility: Windows, Mac, Linux, Android, iOS

**NFS (Native Kernel Support)**: - Kernel module:`nfs`,`nfsd`- Userspace:`nfs-kernel-server`,`nfs-utils`- Performance: Zero-copy, kernel-level - Compatibility: Linux, Mac, Unix, ESXi
## Architecture Design

### Three-Layer Architecture

```
┌─────────────────────────────────────┐
│         Web UI (Dashboard)          │ ← User Interface
├─────────────────────────────────────┤
│      Go API Management Layer        │ ← Our Code
├─────────────────────────────────────┤
│    Native Linux Services (Kernel)   │ ← System Services
└─────────────────────────────────────┘
```