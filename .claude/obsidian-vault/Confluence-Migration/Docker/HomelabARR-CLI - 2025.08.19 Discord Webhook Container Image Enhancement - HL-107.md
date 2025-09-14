---
title: "HomelabARR-CLI : 2025.08.19 Discord Webhook Container Image Enhancement - HL-107"
confluence_id: "6455298"
confluence_url: "https://your-instance.atlassian.net/wiki/spaces/DO/pages/6455298"
confluence_space: "DO"
category: "Docker"
created_date: ""
updated_date: ""
migrated_date: "2025-09-14"
tags: ['frontend', 'epic']
---

# Discord Webhook Container Image Enhancement

## Executive Summary

[[HL-107]]- Enhance Discord webhook notifications with container-specific images
**Effort**: 3 Story Points (24 hours)
**Priority**: Medium - Quality of Life Enhancement
**Impact**: All container build notifications across 100+ containers
## Current State vs Desired State

### Current Implementation

```
# Current Discord notification (generic avatar)
json='{
  "username": "HomelabARR Container Bot",
  "avatar_url": "https://raw.githubusercontent.com/smashingtags/homelabarr-cli/master/wiki/overrides/img/profile.png",
  "embeds": [{
    "title": "'"${CONTAINER}"'",
    ...
  }]
}'
```