---
title: "HomelabARR-CLI : 2025.08.20 Container Build Troubleshooting - Base Images"
confluence_id: "6848614"
confluence_url: "https://mjashley.atlassian.net/wiki/spaces/DO/pages/6848614"
confluence_space: "DO"
category: "Docker"
created_date: ""
updated_date: ""
migrated_date: "2025-09-14"
tags: ['frontend']
---

# Container Build Troubleshooting - Base Images

## Overview

Documentation of base image build failures and resolutions during HomelabARR container migration.
## Ubuntu Focal & Jammy Build Failures

### Issue 1: QEMU Emulation Errors

**Error Message:**
```
.buildkit_qemu_emulator: /bin/sh: Invalid ELF image for this architecture
```