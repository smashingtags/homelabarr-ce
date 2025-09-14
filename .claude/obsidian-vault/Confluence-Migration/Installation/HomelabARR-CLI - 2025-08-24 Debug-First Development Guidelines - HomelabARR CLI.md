---
title: "HomelabARR-CLI : 2025-08-24 Debug-First Development Guidelines - HomelabARR CLI"
confluence_id: "8421377"
confluence_url: "https://mjashley.atlassian.net/wiki/spaces/DO/pages/8421377"
confluence_space: "DO"
category: "Installation"
created_date: "2025-08-24"
updated_date: "2025-08-24"
migrated_date: "2025-09-14"
tags: ['frontend', 'august-2025']
---

# 2025-08-24 Debug-First Development Guidelines - HomelabARR CLI

## Debug-First Philosophy

### Core Principles

- **Visibility First**: Every action should be observable
- **Fail Fast**: Errors should surface immediately
- **Clear Messages**: Descriptive error outputs
- **Trace Everything**: Comprehensive logging
### Implementation Guidelines

#### Logging Standards

```
log.Printf("[DEBUG] Component: %s, Action: %s, Status: %s", 
    component, action, status)
```