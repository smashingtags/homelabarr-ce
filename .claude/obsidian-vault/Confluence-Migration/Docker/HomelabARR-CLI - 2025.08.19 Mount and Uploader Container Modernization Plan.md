---
title: "HomelabARR-CLI : 2025.08.19 Mount and Uploader Container Modernization Plan"
confluence_id: "6848514"
confluence_url: "https://your-instance.atlassian.net/wiki/spaces/DO/pages/6848514"
confluence_space: "DO"
category: "Docker"
created_date: ""
updated_date: ""
migrated_date: "2025-09-14"
tags: ['storage', 'docker']
---

# Mount and Uploader Container Modernization Plan

## Executive Summary

Comprehensive modernization plan for HomelabARR's mount and uploader containers, incorporating best practices from Perfect Media Server and modern cloud storage technologies.
## Perfect Media Server Integration

### Key Recommendations Adopted

- **MergerFS**for flexible storage pooling
- **SnapRAID**for distributed redundancy
- **ZFS**consideration for advanced filesystem features
- **Modular storage approach**combining local and cloud
### Architecture Principles

- Freedom-respecting NAS approach
- Open-source first philosophy
- Container-level isolation with Docker
- Infrastructure as Code methodology
## Mount Container Modernization

### Current State

- **Technology**: Alpine Linux, Rclone, MergerFS, FUSE
- **Purpose**: Cloud storage mounting and pooling
- **Issues**: Performance bottlenecks, limited caching, single provider focus
### Proposed Improvements

#### Performance Optimizations
FeatureCurrentProposedImpactRclone Version1.591.65+20% speed improvementVFS CacheBasicFull mode with 100GB50% less API callsChunk SizeFixed 5MDynamic optimizationBetter streamingRead-aheadNoneIntelligent prefetchSmoother playback