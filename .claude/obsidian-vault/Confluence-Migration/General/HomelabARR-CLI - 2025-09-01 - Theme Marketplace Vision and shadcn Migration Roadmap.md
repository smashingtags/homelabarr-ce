---
title: "HomelabARR-CLI : 2025-09-01 - Theme Marketplace Vision and shadcn Migration Roadmap"
confluence_id: "11763917"
confluence_url: "https://mjashley.atlassian.net/wiki/spaces/DO/pages/11763917"
confluence_space: "DO"
category: "General"
created_date: "2025-09-01"
updated_date: "2025-09-01"
migrated_date: "2025-09-14"
tags: ['frontend', 'media-server', 'golang', 'servarr', 'september-2025', 'storage']
---

# Theme Marketplace Vision & Complete shadcn/ui Migration Plan

## Executive Summary

Transform HomelabARR Dashboard into the first customizable homelab dashboard with a theme marketplace, leveraging complete shadcn/ui migration to enable infinite customization possibilities and potential revenue streams.
## The Vision: Theme Marketplace

### Concept

A built-in theme store where users can: - Browse and preview themes in real-time - Install themes with one click - Create and share custom themes - Purchase premium themes - Export/import theme configurations
### Theme Categories

#### Free Community Themes

- **Unraid Classic**- Original orange theme (#ff8c1a)
- **Plex Orange**- Match Plex Media Server aesthetic
- **Jellyfin Purple**- For Jellyfin users
- **Sonarr Blue**- Match the *arr suite styling
- **Synology White**- Clean NAS-inspired design
- **TrueNAS Dark**- Enterprise datacenter feel
- **Proxmox Gray**- Professional virtualization look
- **GitHub Dark**- Developer-friendly dark mode
- **Vercel Style**- Modern, minimal, monochrome
- **Linear Style**- Clean project management aesthetic
#### Premium Themes ($5-10)

- **Glass Morphism Pro**- Advanced glass effects with blur
- **Cyberpunk 2077**- Neon glowing UI elements
- **macOS Sonoma**- Apple-inspired design system
- **Steam Deck UI**- Gaming console interface
- **Terminal Green**- Matrix-style hacker theme
- **Nord Theme**- Popular Nordic color palette
- **Dracula Pro**- Enhanced Dracula theme
- **Catppuccin Collection**- All 4 flavors
- **Tokyo Night**- Popular VS Code theme
- **Gruvbox Material**- Retro terminal aesthetic
### Technical Implementation

```
// Theme System Architecture
const themeSystem = {
  // CSS Variables (automatically applied by shadcn components)
  variables: {
    '--primary': 'hsl(25, 95%, 53%)',     // Brand color
    '--secondary': 'hsl(280, 85%, 65%)',   // Accent
    '--background': 'hsl(240, 10%, 3.9%)', // Main bg
    '--foreground': 'hsl(0, 0%, 98%)',     // Text
    '--card': 'hsl(240, 10%, 8%)',         // Card bg
    '--border': 'hsl(240, 3.7%, 15.9%)',   // Borders
    '--ring': 'hsl(25, 95%, 53%)',         // Focus ring
    '--radius': '0.5rem'                    // Border radius
  },

  // Theme Marketplace API
  marketplace: {
    browse: '/api/themes',
    install: '/api/themes/install',
    purchase: '/api/themes/purchase',
    rate: '/api/themes/rate',
    submit: '/api/themes/submit'
  },

  // Storage
  storage: {
    current: localStorage.getItem('theme'),
    custom: localStorage.getItem('customThemes'),
    purchased: localStorage.getItem('purchasedThemes')
  }
}
```