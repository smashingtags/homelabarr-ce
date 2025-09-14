---
title: "HomelabARR-CLI : 2025-08-24 HomelabARR Storage Architecture - SnapRAID + MergerFS Implementation"
confluence_id: "9011291"
confluence_url: "https://mjashley.atlassian.net/wiki/spaces/DO/pages/9011291"
confluence_space: "DO"
category: "Storage"
created_date: "2025-08-24"
updated_date: "2025-08-24"
migrated_date: "2025-09-14"
tags: ['frontend', 'august-2025', 'storage']
---

# homelabarr-storage-architectureHomelabARR Storage Architecture

==============================================================
## overviewOverview

HomelabARR follows the proven storage patterns from**Perfect Media Server**(SnapRAID + MergerFS) and**Trash Guides**(folder structure) to create a robust, scalable media server infrastructure.
## core-technologiesCore Technologies

### snapraid-parity-protectionSnapRAID (Parity Protection)

- **Purpose**: Snapshot-based parity protection for drive failures
- **Best For**: Large, static media files that rarely change
- **Protection**: Up to 6 disk failures with sufficient parity drives
- **Operation**: Manual or scheduled parity sync (not real-time)
### mergerfs-drive-poolingMergerFS (Drive Pooling)

- **Purpose**: Combines multiple drives into single mount point
- **JBOD**: Each drive remains independently readable
- **No Striping**: Files stored whole on single drives
- **Policies**: Configurable file placement strategies
### why-this-combinationWhy This Combination?

Per Perfect Media Server: - ✅ Fault tolerance against drive failure - ✅ Checksums guard against bitrot - ✅ Support mismatched drive sizes - ✅ Incremental drive upgrades - ✅ No data striping across drives
## folder-structure-trash-guides-standardFolder Structure (Trash Guides Standard)

```
/data
├── torrents
│ ├── books
│ ├── movies
│ ├── music
│ └── tv
├── usenet
│ ├── incomplete
│ └── complete
│ ├── books
│ ├── movies
│ ├── music
│ └── tv
└── media
├── books
├── movies
├── music
└── tv
```