# HomelabARR Professional Edition

!!! info "Coming Soon"
    HomelabARR PE is in active development. Pricing and features are subject to change. Sign up for updates at [homelabarr.com](https://homelabarr.com).

HomelabARR PE is a single-binary NAS management platform built in Go with a React dashboard. It includes everything in the Community Edition plus enterprise storage management and native file sharing.

---

## What's Different from CE

| Feature | CE (Free) | PE |
|---------|-----------|-----|
| Docker container management | ✅ | ✅ |
| 100+ app templates | ✅ | ✅ |
| Traefik/Authelia scaffolding | ✅ | ✅ |
| Web dashboard | ✅ | ✅ (enhanced) |
| Storage management (SnapRAID + MergerFS) | ❌ | ✅ |
| Mixed drive support (any sizes) | ❌ | ✅ |
| Native file sharing (SMB/NFS) | ❌ | ✅ |
| Single binary install | ❌ | ✅ |
| Cache mover | ❌ | ✅ |
| Source code | Open (MIT) | Proprietary |
| Support | Community | Priority |

---

## Pricing

| Tier | Price | Includes |
|------|-------|----------|
| **Early Adopter** | $19 | Pre-release access, lifetime updates |
| **Starter** | $39 | PE binary, dashboard, container management (8 drives max) |
| **Pro** | $79 | Unlimited drives, all features, 1 year updates |
| **Lifetime** | $149 | Everything, lifetime updates |

All tiers are **one-time purchases** — no subscription.

→ [Purchase at homelabarr.com](https://homelabarr.com)

---

## Architecture

```
┌──────────────────────────────────────────┐
│           HomelabARR PE Binary            │
│                                          │
│  ┌─────────────┐  ┌──────────────────┐   │
│  │  Go Backend  │  │  React Frontend  │   │
│  │  (Gin API)   │  │  (embedded via   │   │
│  │              │  │   go:embed)      │   │
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

---

## CE to PE Migration

PE reads your existing Docker configurations. Containers, networks, and volumes carry over — PE adds the dashboard, storage management, and native file sharing on top.

---

## Stay Updated

- [homelabarr.com](https://homelabarr.com) — product page and purchase
- [Discord](https://discord.gg/Pc7mXX786x) — announcements channel
- [GitHub](https://github.com/smashingtags/homelabarr-ce) — star the repo for notifications
