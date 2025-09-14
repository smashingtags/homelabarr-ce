---
title: "HomelabARR-CLI : 2025-01-11 - Container Modal State Management Fix - API Polling Issue Resolution"
confluence_id: "17498115"
confluence_url: "https://your-instance.atlassian.net/wiki/spaces/DO/pages/17498115"
confluence_space: "DO"
category: "Docker"
created_date: "2025-01-11"
updated_date: "2025-01-11"
migrated_date: "2025-09-14"
tags: ['frontend', 'golang']
---

# Container Modal State Management Fix - API Polling Issue Resolution

## Executive Summary

Fixed critical UI bug where container modals (View Stats, View Logs, Terminal) would disappear after 2-3 seconds. Root cause was state loss during API polling re-renders after modularizing the Go backend from a 6500-line monolith.
## Problem Statement

### Symptoms

- Clicking "View Stats" or "View Logs" buttons in container management interface
- Modal appears correctly for 1-3 seconds
- Modal suddenly disappears without user interaction
- Console shows WebSocket connections closing immediately
- Issue emerged after modularizing`simple-server.go`from 6500 lines into separate handler files
### Impact

- **User Experience**: Completely broken container management functionality
- **Severity**: Critical - Core feature unusable
- **Affected Components**: ContainerActions, ContainerDetailsModal, ContainerTerminal
- **Discovered**: During testing of modularized backend architecture
## Root Cause Analysis

### Technical Investigation

#### 1. API Polling Mechanism

```
// v2-poc/web/homelabarr-dashboard/src/pages/Containers/Containers.tsx
const { data: containerData, loading, refetch } = useApiPolling<Container[]>({
  url: '/containers',
  interval: 3000 // Updates every 3 seconds
});
```