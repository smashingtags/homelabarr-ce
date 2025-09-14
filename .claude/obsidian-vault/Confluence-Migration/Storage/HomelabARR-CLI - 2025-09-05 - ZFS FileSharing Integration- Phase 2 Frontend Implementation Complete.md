---
title: "HomelabARR-CLI : 2025-09-05 - ZFS FileSharing Integration: Phase 2 Frontend Implementation Complete"
confluence_id: "14188580"
confluence_url: "https://your-instance.atlassian.net/wiki/spaces/DO/pages/14188580"
confluence_space: "DO"
category: "Storage"
created_date: "2025-09-05"
updated_date: "2025-09-05"
migrated_date: "2025-09-14"
tags: ['frontend', 'monitoring', 'september-2025', 'epic', 'storage']
---

# ZFS FileSharing Integration: Phase 2 Frontend Implementation Complete

**Date**: 2025-09-05
**Status**[[HL-276]][[HL-282]])
## Executive Summary

Successfully integrated ZFS storage management into the HomelabARR FileSharing interface. This Phase 2 implementation connects the existing ZFS backend APIs with the React frontend, providing users with real-time ZFS dataset visibility and storage status monitoring directly in the file sharing interface.
## Technical Implementation Details

### Frontend Architecture Enhancement

**FileSharing Component Updates**(`FileSharing.tsx`): -**New TypeScript Interfaces**: Added`ZFSDataset`and`ZFSHealthStatus`types -**API Integration**: Real-time polling of`/api/zfs/datasets`and`/api/zfs/health`endpoints
-**State Management**: Added`zfsDatasets`and`zfsHealth`React state -**UI Components**: Enhanced Quick Stats grid with ZFS storage status card
### Code Changes Applied

```
// Added ZFS Type Definitions
interface ZFSDataset {
  id: string;
  name: string;
  type: string;
  used: string;
  available: string;
  mountpoint: string;
  properties: { [key: string]: string };
}

interface ZFSHealthStatus {
  available: boolean;
  pools: any[];
  status: string;
}

// Added API Polling (30-second intervals for storage data)
const { data: zfsData } = useApiPolling<any>({
  url: 'http://localhost:8080/api/zfs/datasets',
  interval: 30000
});

const { data: zfsHealthData } = useApiPolling<any>({
  url: 'http://localhost:8080/api/zfs/health',
  interval: 30000
});
```