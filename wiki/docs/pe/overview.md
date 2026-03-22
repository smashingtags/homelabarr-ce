# HomelabARR Professional Edition

HomelabARR PE is a single-binary NAS management platform built in Go with a React dashboard. It includes everything in the Community Edition plus enterprise storage management, native file sharing, and a modern web UI.

## What's Different from CE

| Feature | CE (Free) | PE ($39+) |
|---------|-----------|-----------|
| Docker container management | Yes | Yes |
| 137+ app templates | Yes | Yes |
| Traefik/Authelia scaffolding | Yes | Yes |
| CLI interface | Bash scripts | Native Go binary |
| Web dashboard | No | React 19 + shadcn/ui |
| Storage management | No | SnapRAID + MergerFS + Cache Mover |
| Mixed drive support | No | Yes — any combination of drive sizes |
| Native file sharing | No | Go SMB/NFS (no Docker overhead) |
| Single binary install | No | Yes — one file, everything embedded |
| App Store | Basic | Full UI with search, categories, one-click install |
| Real-time monitoring | No | WebSocket dashboard with live stats |

## Architecture

```
┌──────────────────────────────────────────┐
│           HomelabARR PE Binary            │
│                                          │
│  ┌─────────────┐  ┌──────────────────┐   │
│  │  Go Backend  │  │  React Frontend  │   │
│  │  (Gin API)   │  │  (embedded via   │   │
│  │  50+ routes  │  │   go:embed)      │   │
│  └──────┬──────┘  └──────────────────┘   │
│         │                                │
│  ┌──────┴──────────────────────────────┐ │
│  │  Storage Engine                     │ │
│  │  SnapRAID · MergerFS · Cache Mover  │ │
│  └──────┬──────────────────────────────┘ │
│         │                                │
│  ┌──────┴──────┐  ┌──────────────────┐   │
│  │  Docker SDK  │  │  File Sharing    │   │
│  │  Container   │  │  Native Go       │   │
│  │  Management  │  │  SMB/NFS         │   │
│  └─────────────┘  └──────────────────┘   │
└──────────────────────────────────────────┘
```

## Getting Started

- [Installation](installation.md) — Download and run a single binary
- [Storage Setup](storage.md) — Configure SnapRAID, MergerFS, and cache tiers
- [Dashboard](dashboard.md) — The React web UI
- [File Sharing](file-sharing.md) — Native SMB/NFS without Docker overhead
- [Licensing](licensing.md) — Activation and pricing
