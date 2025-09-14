---
title: "HomelabARR-CLI : 2025-09-05 - Native Go SnapRAID + MergerFS Architecture: Complete Technical Documentation"
confluence_id: "14090251"
confluence_url: "https://mjashley.atlassian.net/wiki/spaces/DO/pages/14090251"
confluence_space: "DO"
category: "Storage"
created_date: "2025-09-05"
updated_date: "2025-09-05"
migrated_date: "2025-09-14"
tags: ['frontend', 'epic', 'golang', 'september-2025', 'monitoring', 'storage']
---

# Native Go SnapRAID + MergerFS Architecture: Complete Technical Documentation

**Date**: 2025-01-05
**Status**[[HL-280]](CORRECTION: v2-poc Contains Production SnapRAID + MergerFS Implementation)
**Discovery**[[HL-280]], we have confirmed that HomelabARR v2-poc contains a**complete, production-ready native Go implementation**of SnapRAID + MergerFS storage management. This implementation includes native Go operations controllers, comprehensive React frontend components, real-time monitoring, and API-first architecture.

**Previous Documentation Status**: INCORRECT - Listed as "planned" or "mock implementation"
**Actual Implementation Status**: 92% COMPLETE - Production-ready with native Go performance
## Architecture Overview

### Core Implementation Files

#### Native Go Backend

```
pkg/storage/
├── snapraid.go     (465 lines) - Native Go SnapRAID operations controller
├── storage.go      (596 lines) - Complete storage management system  
└── handlers.go     - API endpoint handlers for storage operations
```