---
title: "HomelabARR-CLI : 2025.08.18 Emergency Fix: CORS and Docker Integration Recovery"
confluence_id: "5898241"
confluence_url: "https://mjashley.atlassian.net/wiki/spaces/DO/pages/5898241"
confluence_space: "DO"
category: "Docker"
created_date: "2025-08-19"
updated_date: "2025-08-19"
migrated_date: "2025-09-14"
tags: ['frontend', 'august-2025', 'docker', 'security', 'epic']
---

# Emergency Fix Session Summary

**Date**: 2025-08-19
**Duration**: ~4 hours[[HL-76]]
**Status**: ✅**COMPLETED**
## Critical Issue Resolved

### Problem

Complete system failure - "Failed to fetch containers" error blocking all Docker functionality. System was previously working (showed 252 applications at 11AM on 2025-08-18).
### Impact

- No containers visible in UI
- Authentication headers not reaching backend
- Windows Docker Desktop completely non-functional
- 65 YAML files with syntax errors
## Root Cause Analysis

- 

**CORS Configuration Issue**- Backend configured with`credentials: false`and wildcard origin - This combination blocks Authorization headers - Frontend unable to send JWT tokens for authentication
- 

**Windows Docker Compatibility**- Dockerode library incompatible with Windows Docker Desktop - Named pipe connection not working on Windows - Required CLI-based approach for Windows support
- 

**Frontend Date Parsing**- Container Created timestamps being multiplied by 1000 - Backend already returning ISO strings - Causing NaN errors in date display
- 

**YAML Syntax Errors**- 65 files in local-mode-apps with malformed YAML - Duplicate port definitions - Incorrect indentation
## Solutions Implemented

### CORS Fix

```
// server/environment-manager.js
if (config.environment === 'development') {
  corsOptions.origin = ['http://localhost:5173', 'http://localhost:8097', 'http://localhost:8101'];
  corsOptions.credentials = true; // Enable credentials for auth headers
}
```