---
title: "HomelabARR-CLI : 2025-08-30 - Settings Type Mismatch Bug Fix Documentation"
confluence_id: "11698240"
confluence_url: "https://your-instance.atlassian.net/wiki/spaces/DO/pages/11698240"
confluence_space: "DO"
category: "Troubleshooting"
created_date: "2025-08-30"
updated_date: "2025-08-30"
migrated_date: "2025-09-14"
tags: ['frontend', 'epic', 'august-2025', 'golang']
---

# Settings Type Mismatch Bug Fix - HL-266

## Overview

Fixed a critical type mismatch bug in the HomelabARR CLI v2.0 settings system that was causing "Failed to unmarshal settings" errors when users attempted to save configuration changes.
## Bug Symptoms

- Settings page would fail to save with "Failed to unmarshal settings" error
- Backend Go service unable to parse frontend JSON payload
- Error occurred specifically when processing rateLimit field
- User experience: Settings changes would not persist
## Root Cause Analysis

The bug was caused by a data type mismatch between frontend and backend:

**Frontend Issue:**- Settings form was sending`rateLimit`as string value:`"100 requests/minute"`- JavaScript code concatenated numeric value with text description

**Backend Expectation:**- Go struct expected`rateLimit`field as boolean type - JSON unmarshaling failed when trying to convert string to boolean

**Code Location:**`v2-poc/web/settings-page.html`
## Technical Fix Implementation

### Before (Problematic Code)

```
// Frontend was sending mixed data types
rateLimit: document.getElementById('rateLimit').value + ' requests/minute'  // String
```