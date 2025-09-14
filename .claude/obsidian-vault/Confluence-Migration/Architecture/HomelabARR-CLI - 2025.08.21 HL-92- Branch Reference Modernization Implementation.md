---
title: "HomelabARR-CLI : 2025.08.21 HL-92: Branch Reference Modernization Implementation"
confluence_id: "7602265"
confluence_url: "https://your-instance.atlassian.net/wiki/spaces/DO/pages/7602265"
confluence_space: "DO"
category: "Architecture"
created_date: "2025-08-21"
updated_date: "2025-08-21"
migrated_date: "2025-09-14"
tags: ['frontend', 'epic', 'august-2025', 'docker']
---

# HL-92: Branch Reference Modernization Implementation

## Overview

Successfully updated all documentation and installation scripts to use 'main' branch references instead of 'master', modernizing the HomelabARR CLI repository to align with current Git best practices.
## Implementation Details

### Files Updated

- 

**quick-deploy.sh**- Line 4: Updated curl one-liner comment to reference 'main' branch - Line 20: Changed`git pull origin master`to`git pull origin main`
- 

**wgetfile.sh**- Line 66: Updated LinuxServer docker-compose reference from master to main
- 

**.installer/homelabber**- Line 96: Updated apt-fast installation script reference from master to main
- 

**wiki/docs/install/local-mode.md**- Line 518: Updated wiki documentation link from master to main
- 

**wiki/docs/scripts/yaml-cleanup.md**- Line 355: Updated wiki documentation link from master to main
- 

**wiki/docs/tunnel/cf_tunnel.md**- Line 69: Updated cloudflared config.yaml download URL from master to main - Line 141: Updated cloudflared docker-compose.yml download URL from master to main
- 

**.github/readmove.sh**- Line 10: Updated README.md curl download URL from master to main
## Validation

- All critical 'master' branch references identified and updated
- Installation scripts now consistently reference 'main' branch
- Documentation links updated across wiki pages
- GitHub workflow scripts modernized
## Impact

- Improved consistency with modern Git practices
- Eliminated deprecated 'master' branch references
- Enhanced user experience with correct branch references
- Future-proofed installation and documentation processes
## Status

- **Completed**: 2025-08-21[[HL-92]]
- **Files Modified**: 8 total files across repository