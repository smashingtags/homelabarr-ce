---
title: "HomelabARR-CLI : 2025-09-01 - shadcn/ui Component Migration Complete"
confluence_id: "12091544"
confluence_url: "https://mjashley.atlassian.net/wiki/spaces/DO/pages/12091544"
confluence_space: "DO"
category: "Frontend"
created_date: "2025-09-01"
updated_date: "2025-09-01"
migrated_date: "2025-09-14"
tags: ['frontend', 'september-2025', 'storage']
---

# shadcn/ui Component Migration Documentation

## Overview

This document details the complete migration from Bootstrap to shadcn/ui components in the HomelabARR React dashboard, completed on September 1, 2025.
## Migration Scope

### Components Migrated

#### Settings Page (`/src/pages/Settings/Settings.tsx`)

- **Modals**: All Bootstrap modals converted to shadcn Dialog components
- Add User Modal
- Edit User Modal
- Reset Password Modal
- SnapRAID Configuration Editor Modal
- **Form Controls**: Complete replacement of Bootstrap form elements
- Input fields → shadcn Input
- Labels → shadcn Label
- Dropdowns → shadcn Select with SelectTrigger/SelectContent
- Checkboxes → shadcn Switch
- Buttons → shadcn Button with variants
- **Alerts**: Migrated to shadcn Alert components
#### AppStore Page (`/src/pages/AppStore/AppStore.tsx`)

- Search input migrated to shadcn Input
- All buttons converted to shadcn Button
- Removed Bootstrap CSS classes
#### Theme System (`/src/lib/themes.ts`)

- Created comprehensive theme marketplace
- 7 pre-configured themes:
- Unraid Orange (default)
- Neumorphic Dark
- High Contrast
- Minimal Clean
- Cyberpunk 2077
- Nord
- Dracula
- Fixed CSS variable mapping for backward compatibility
## Critical Configuration Issues Resolved

### Tailwind CSS Version Compatibility

**CRITICAL**: shadcn/ui requires Tailwind CSS v3, NOT v4!
#### Correct PostCSS Configuration

```
// postcss.config.js - MUST use this format
export default {
  plugins: {
    'tailwindcss/nesting': {},
    tailwindcss: {},
    autoprefixer: {},
  },
}
```