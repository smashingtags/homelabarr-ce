---
title: "HomelabARR-CLI : 2025-08-24 HL-230: PR #29 Cleanup - Duplicate Templates Removal"
confluence_id: "8978676"
confluence_url: "https://mjashley.atlassian.net/wiki/spaces/DO/pages/8978676"
confluence_space: "DO"
category: "Epics"
created_date: "2025-08-24"
updated_date: "2025-08-24"
migrated_date: "2025-09-14"
tags: ['august-2025', 'epic', 'monitoring']
---

# 2025-08-24 HL-230: PR #29 Cleanup - Duplicate Templates Removal

## Issue Summary

PR #29 was accidentally merged with obsolete prototype code that created duplicate template files in the wrong directory structure.
## Problem Identification

- PR #29 added templates to v2-poc/templates/ directory
- Correct location is v2-poc/apps/ where 100+ templates already exist
- PR contained early prototype work that was superseded
## Resolution Steps

- Identified duplicate templates in wrong location
- Removed obsolete v2-poc/templates/ directory
- Verified all templates exist in correct v2-poc/apps/ location
- Updated references to point to correct location
## Impact

- No functional impact
- Cleaned up repository structure
- Reduced confusion for future development
## Verification

```
# Correct structure
v2-poc/apps/
├── mediaserver/
├── downloadclients/
├── monitoring/
└── [100+ working templates]
```