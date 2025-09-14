---
title: "HomelabARR-CLI : 2025.08.20 HomelabARR to HomelabARR Migration - Complete Implementation"
confluence_id: "6946819"
confluence_url: "https://your-instance.atlassian.net/wiki/spaces/DO/pages/6946819"
confluence_space: "DO"
category: "Architecture"
created_date: ""
updated_date: ""
migrated_date: "2025-09-14"
tags: ['frontend', 'epic', 'security']
---

[[HL-129]]
**Status:**Production Ready with Automated Migration Tools
## 📋 Executive Summary

Successfully completed the migration strategy from HomelabARR to HomelabARR branding, including: - Container image renaming with legacy support - Automated migration scripts for users - Security vulnerability remediation - Complete documentation and rollback procedures
## 🔄 Container Name Mappings

### Production Containers
Old NameNew NameStatus`homelabarr/homelabarr``ghcr.io/smashingtags/homelabarr-legacy-base`✅ Live`homelabarr/homelabarr-ui``ghcr.io/smashingtags/homelabarr-ui-legacy`✅ Live`homelabarr/autoscan``ghcr.io/smashingtags/homelabarr-autoscan`✅ Live`homelabarr/mount``ghcr.io/smashingtags/homelabarr-mount`✅ Live