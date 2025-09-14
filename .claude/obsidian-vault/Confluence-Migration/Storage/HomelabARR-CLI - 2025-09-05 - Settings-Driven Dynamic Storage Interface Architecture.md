---
title: "HomelabARR-CLI : 2025-09-05 - Settings-Driven Dynamic Storage Interface Architecture"
confluence_id: "14450736"
confluence_url: "https://your-instance.atlassian.net/wiki/spaces/DO/pages/14450736"
confluence_space: "DO"
category: "Storage"
created_date: "2025-09-05"
updated_date: "2025-09-05"
migrated_date: "2025-09-14"
tags: ['frontend', 'media-server', 'september-2025', 'storage']
---

# Settings-Driven Dynamic Storage Interface Architecture

## 🎯 Executive Summary

HomelabARR v2.0 will implement a**settings-driven dynamic storage interface**that eliminates user confusion by showing only relevant storage tools and information based on their chosen architecture. This puts us ahead of competitors like OpenMediaVault (poor UI) and provides a more intelligent experience than Unraid's static approach.
## 📋 Problem Statement

**Current Issue**: The Storage page shows ALL system tools (local-persist, MergerFS, SnapRAID) as universally required, confusing users who don't need certain tools based on their storage strategy.

**User Feedback**:
> 

"They don't need those tools if they're using ZFS right? They would then just be using MergerFS. So I feel like we might be getting a little confused or maybe confusing the consumer."

**Strategic Impact**: This confusion creates poor user experience and positions HomelabARR as "complex" rather than "intelligent."
## 🏗️ Solution Architecture

### Settings → Storage Workflow

### Storage Strategy Requirements Matrix
Storage StrategyRequired ToolsInterface ComponentsUse Cases**Media Server Storage**
(SnapRAID + MergerFS)• local-persist
• MergerFS
• SnapRAID• SnapRAID Status
• MergerFS Pools
• Parity Check
• System Tools Installer• Large media collections
• Mixed drive sizes
• Cost-effective expansion**Professional Storage**
(ZFS Enterprise)• local-persist• ZFS Pool Overview
• ZFS Tools
• Minimal system requirements• Mission-critical data
• High-performance workloads
• Enterprise requirements**Hybrid Configuration**Variable based on setup• Mixed components
• Advanced configuration• ZFS for critical + SnapRAID for media
• Complex multi-tier setups