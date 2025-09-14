---
title: "HomelabARR-CLI : 2025-09-05 - HomelabARR Purple Gradient Theme System Documentation"
confluence_id: "14778402"
confluence_url: "https://your-instance.atlassian.net/wiki/spaces/DO/pages/14778402"
confluence_space: "DO"
category: "Documentation"
created_date: "2025-09-05"
updated_date: "2025-09-05"
migrated_date: "2025-09-14"
tags: ['frontend', 'september-2025', 'golang']
---

# HomelabARR Purple Gradient Theme System Documentation

## 🎨**Overview**

During the QuickStart modal development, we created a beautiful purple gradient theme system that provides a premium, modern aesthetic that can compete with solutions like HexOS. The theme combines elegant gradients with glass morphism effects for a cohesive, professional appearance.
## 🌈**Core Gradient System**

### **Primary Background Gradient**

The main background uses a 4-stop diagonal gradient (135deg) that flows from pure white in the top-left to vibrant purple in the bottom-right:
```
background: linear-gradient(135deg, 
  rgb(255, 255, 255) 0%,        /* Pure white top-left */
  rgb(245, 243, 255) 25%,       /* Subtle purple hint */
  rgb(224, 215, 255) 60%,       /* Clear purple midpoint */
  rgb(168, 145, 255) 100%       /* Vibrant purple bottom-right */
);
```