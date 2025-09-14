---
title: "HomelabARR-CLI : 2025-09-12 - HomelabARR PE Repository Validation & Push Plan"
confluence_id: "18186272"
confluence_url: "https://mjashley.atlassian.net/wiki/spaces/DO/pages/18186272"
confluence_space: "DO"
category: "General"
created_date: "2025-09-12"
updated_date: "2025-09-12"
migrated_date: "2025-09-14"
tags: ['golang', 'september-2025', 'docker']
---

# HomelabARR PE Repository Validation & Push Plan

## Current Status

Repository cleaned and organized at**F:\Coding Projects\homelabarr-pe**
## Pre-Reboot Checklist

### ✅ Completed Cleanup

- Archived old Dockerfiles to`archive/2025-09-12-broken-dockerfiles-pre-modularization/`
- Cleaned web/homelabarr-dashboard folder
- Fixed docker-compose.yml with proxy network
- Updated Confluence documentation
- Removed duplicate/conflicting documentation
### ⚠️ Final Repository Review (Do Before Push)

Check for any remaining cleanup needed: - [ ] Any .exe files that shouldn't be committed? - [ ] Any .log files in root? - [ ] Any test/temp files? - [ ] Check if`.gitignore`is properly configured - [ ] Verify`CLAUDE.md`is present and accurate - [ ] Check for any sensitive data (API keys, passwords)
## Post-Reboot Validation Plan

### Step 1: Kill All Existing Processes

```
taskkill /F /IM node.exe
taskkill /F /IM server-with-cache-mover.exe
taskkill /F /IM go.exe
```