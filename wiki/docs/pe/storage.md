# Storage Management

The #1 problem in homelabs: **mixed drive sizes**. You bought a 2TB drive two years ago, an 8TB last year, and a 12TB last week. Traditional RAID wastes space by sizing everything to the smallest drive. HomelabARR PE solves this with SnapRAID + MergerFS + an intelligent Cache Mover.

## Architecture

```
Storage Tier Architecture
├── Cache Tier (NVMe/SSD) — Fast storage for active data
│   ├── /mnt/cache/appdata/      # Docker databases (PERMANENT)
│   ├── /mnt/cache/downloads/    # Active downloads (temporary)
│   ├── /mnt/cache/media/        # New media files (ages to array)
│   └── /mnt/cache/system/       # OS and binaries (PERMANENT)
│
├── Array Storage (SnapRAID + MergerFS) — Bulk media storage
│   ├── Mixed drive sizes supported (2TB + 4TB + 8TB + 12TB)
│   ├── Dual parity protection (up to 2 drive failures)
│   └── Unified namespace via MergerFS at /mnt/storage
│
└── Cache Mover — Intelligent file aging
    ├── Moves aged files from cache to array automatically
    ├── Protects Docker databases (never moved)
    └── Configurable age thresholds per directory
```

## How Mixed Drives Work

Traditional RAID with 2TB + 4TB + 8TB + 12TB = 8TB usable (everything sized to smallest).

HomelabARR PE with the same drives:

| Drive | Size | Role |
|-------|------|------|
| Drive 1 | 2TB | Data |
| Drive 2 | 4TB | Data |
| Drive 3 | 8TB | Data |
| Drive 4 | 12TB | Data |
| Parity 1 | 12TB+ | Parity (must be >= largest data drive) |

**Usable space: 26TB** (all data drives combined). Parity protects against any single drive failure.

With dual parity, add a second parity drive for protection against two simultaneous failures.

## SnapRAID Configuration

SnapRAID provides parity-based protection for your data drives. Unlike real-time RAID, SnapRAID syncs on a schedule — perfect for media libraries that change infrequently.

```yaml
# Managed via the PE dashboard or CLI
storage:
  snapraid:
    parity:
      - /mnt/parity1
      - /mnt/parity2    # Optional dual parity
    data:
      d1: /mnt/disk1
      d2: /mnt/disk2
      d3: /mnt/disk3
      d4: /mnt/disk4
    content:
      - /mnt/disk1/.snapraid.content
      - /mnt/disk2/.snapraid.content
    exclude:
      - "*.unrecoverable"
      - "/tmp/"
      - "/lost+found/"
    schedule:
      sync: "0 4 * * *"     # Daily at 4 AM
      scrub: "0 5 * * 0"    # Weekly Sunday at 5 AM
```

### Operations

| Operation | What It Does | When |
|-----------|-------------|------|
| **Sync** | Updates parity to match current data | Daily (scheduled) |
| **Scrub** | Verifies data integrity against parity | Weekly (scheduled) |
| **Check** | Reports any data corruption | On demand |
| **Fix** | Rebuilds corrupted files from parity | On demand |

## MergerFS Pool

MergerFS creates a unified view of all your data drives at `/mnt/storage`. To your applications, it looks like one massive drive.

```yaml
storage:
  mergerfs:
    mount: /mnt/storage
    drives:
      - /mnt/disk1
      - /mnt/disk2
      - /mnt/disk3
      - /mnt/disk4
    policy: epmfs    # Existing path, most free space
    options:
      - cache.files=partial
      - dropcacheonclose=true
      - category.create=epmfs
```

### Placement Policies

| Policy | Behavior | Best For |
|--------|----------|----------|
| `epmfs` | Existing path, most free space | General use (default) |
| `mfs` | Most free space | Even distribution |
| `lfs` | Least free space | Fill drives sequentially |
| `rand` | Random | Testing |

## Cache Mover

The Cache Mover automatically ages files from fast NVMe/SSD cache to the slower array based on configurable rules.

```yaml
storage:
  cache_mover:
    cache_path: /mnt/cache
    array_path: /mnt/storage
    schedule: "*/30 * * * *"    # Check every 30 minutes
    rules:
      - path: /mnt/cache/media/
        max_age: 24h             # Move media after 24 hours
      - path: /mnt/cache/downloads/
        max_age: 1h              # Move completed downloads after 1 hour
      - path: /mnt/cache/backup/
        max_age: 7d              # Move backups after 7 days
    exclude:
      - /mnt/cache/appdata/      # Docker databases stay on cache FOREVER
      - /mnt/cache/system/       # System files stay on cache
      - "*.part"                 # Incomplete downloads protected
```

### Why Cache Matters

| Operation | NVMe Cache | HDD Array |
|-----------|-----------|-----------|
| Database access | 3.5 GB/s | 150 MB/s |
| Active downloads | 1.8 GB/s | 100 MB/s |
| New media ingest | 1.8 GB/s | 100 MB/s |
| Aged media playback | — | 400 MB/s (sufficient for 4K) |

Plex metadata, Sonarr/Radarr databases, and qBittorrent temp files live on NVMe permanently. Media files start on NVMe for fast processing, then age to the array where they stream just fine.

## Dashboard Integration

The PE dashboard provides real-time visibility into your storage:

- **Pool overview** — Total capacity, used space, drive health
- **Drive status** — Individual drive temperatures, SMART data, I/O
- **Cache utilization** — What's on cache, what's aging out, age thresholds
- **SnapRAID status** — Last sync time, scrub results, any errors
- **MergerFS view** — Unified pool with per-drive breakdown

## Next Steps

- [File Sharing](file-sharing.md) — Share your storage over the network
- [Dashboard](dashboard.md) — Monitor storage from the web UI
- [App Deployment](../apps/apps.md) — Point your containers at `/mnt/storage`
