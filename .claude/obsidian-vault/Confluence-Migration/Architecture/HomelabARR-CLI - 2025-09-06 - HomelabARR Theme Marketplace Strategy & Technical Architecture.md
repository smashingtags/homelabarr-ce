---
title: "HomelabARR-CLI : 2025-09-06 - HomelabARR Theme Marketplace Strategy & Technical Architecture"
confluence_id: "15138818"
confluence_url: "https://your-instance.atlassian.net/wiki/spaces/DO/pages/15138818"
confluence_space: "DO"
category: "Architecture"
created_date: "2025-09-06"
updated_date: "2025-09-06"
migrated_date: "2025-09-14"
tags: ['frontend', 'media-server', 'september-2025']
---

# HomelabARR Theme Marketplace Strategy & Technical Architecture

**Document Date:**September 6, 2025
**Context:**UI Development Session - File Sharing Page Theming
**Strategic Focus:**Theme Marketplace Revenue Model & Technical Foundation
## Executive Summary

HomelabARR's hybrid shadcn/ui + CSS variable theming architecture creates a natural monetization ladder for our planned Theme Marketplace, enabling tiered pricing based on complexity while maintaining broad accessibility for theme developers.
## Theme Marketplace Revenue Strategy

### Three-Tier Pricing Model

#### 🟢**Tier 1: Basic Themes**($5-15)

**Target Audience:**Beginner developers, color customization enthusiasts
**Technical Requirements:**shadcn/ui color variables only
**Revenue Share:**70/30 split (Developer/HomelabARR)

**Features:**- Simple color palette changes - Basic shadcn/ui variable overrides - Automatic compatibility with all components - Low barrier to entry for creators

**Technical Implementation:**
```
:root {
  --primary: #your-color;
  --secondary: #your-color;
  --accent: #your-color;
  --background: #your-color;
  --foreground: #your-color;
}
```