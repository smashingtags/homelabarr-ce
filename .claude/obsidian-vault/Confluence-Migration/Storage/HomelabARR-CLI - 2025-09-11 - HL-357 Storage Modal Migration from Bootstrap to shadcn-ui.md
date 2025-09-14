---
title: "HomelabARR-CLI : 2025-09-11 - HL-357 Storage Modal Migration from Bootstrap to shadcn/ui"
confluence_id: "17858562"
confluence_url: "https://mjashley.atlassian.net/wiki/spaces/DO/pages/17858562"
confluence_space: "DO"
category: "Storage"
created_date: "2025-09-11"
updated_date: "2025-09-11"
migrated_date: "2025-09-14"
tags: ['frontend', 'epic', 'september-2025', 'storage']
---

# HL-357: Storage Modal Migration from Bootstrap to shadcn/ui

## Problem Overview

After the Bootstrap to shadcn/ui migration, two critical modals on the Storage page are not functioning correctly:
- **StorageSetupWizard**- Renders at the bottom of the page instead of as a modal overlay
- **SystemToolsInstaller**- Dialog fails to open when triggered
## Root Cause Analysis

### Technical Investigation

The StorageSetupWizard component (`v2-poc/web/homelabarr-dashboard/src/components/Storage/StorageSetupWizard.tsx`) is still using Bootstrap modal HTML structure:
```
// Current Bootstrap implementation (Lines 86-93)
<div className="modal-backdrop show" style={{ backgroundColor: 'rgba(0,0,0,0.8)' }}/>
<div className="modal show d-block" tabIndex={-1}>
  <div className="modal-dialog modal-lg modal-dialog-centered">
    <div className="modal-content">
      // Modal content
    </div>
  </div>
</div>
```