# Architecture

HomelabARR CE is a two-container application: an nginx frontend serving a React SPA, and a Node.js backend that manages Docker containers via the Docker socket.

---

## System Overview

```
┌─────────────────────────────────────────────────┐
│                  Docker Host                     │
│                                                  │
│  ┌──────────────────┐  ┌──────────────────────┐  │
│  │  Frontend (8084)  │  │  Backend (8092)       │  │
│  │  nginx + React    │──│  Node.js + Express    │  │
│  │  SPA (shadcn/ui)  │  │  CLI Bridge           │  │
│  └──────────────────┘  │  Docker SDK            │  │
│                         │  JWT Auth              │  │
│                         │  SSE Streaming         │  │
│                         └──────────┬─────────────┘  │
│                                    │                 │
│                         ┌──────────▼─────────────┐  │
│                         │  Docker Socket          │  │
│                         │  /var/run/docker.sock   │  │
│                         └────────────────────────┘  │
│                                                      │
│  ┌──────────────────────────────────────────────┐   │
│  │  App Templates (apps/)                        │   │
│  │  100+ Docker Compose YAML files              │   │
│  └──────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────┘
```

---

## Components

### Frontend

- **React 19** with **shadcn/ui** components
- **Vite** build toolchain
- Dark/light mode
- Responsive layout (mobile-friendly)
- Served by nginx in production (GHCR image: `homelabarr-frontend`)

### Backend

- **Node.js** with **Express**
- **CLI Bridge** — reads and parses Docker Compose templates from `apps/`
- **Docker SDK** — manages containers via the Docker socket
- **JWT authentication** with session management
- **API key auth** (`hlr_` prefix) for programmatic access
- **SSE streaming** for real-time deployment progress
- Production image: `homelabarr-backend` (GHCR)

### App Templates

- 100+ Docker Compose YAML files organized by category
- Standard Docker Compose format with variable placeholders
- The CLI Bridge parses templates and injects user configuration at deploy time

---

## Network Modes

### Standard (Local)

```
User → http://server:PORT → Container
```

Containers bind directly to host ports. Simple, no dependencies.

### Traefik

```
User → https://app.domain.com → Traefik → Container
```

Containers join the `proxy` network. Traefik reads Docker labels for routing, handles SSL via Let's Encrypt.

### Traefik + Authelia

```
User → https://app.domain.com → Traefik → Authelia → Container
```

Adds an authentication layer with SSO and optional MFA before reaching the app.

---

## Data Flow

### Deployment

```
1. User clicks Deploy in dashboard
2. Frontend → POST /deploy { appId, config, mode }
3. Backend loads YAML template from apps/<category>/<app>.yml
4. Applies deployment mode transformations (strip labels, rewrite networks)
5. Injects environment variables
6. Runs: docker compose up -d
7. Streams stdout/stderr to client via SSE
8. Returns deployment result
```

### Container Management

```
1. Frontend → POST /containers/:id/start (or stop/restart)
2. Backend → Docker SDK → docker start/stop/restart
3. Returns result
```

---

## Storage

```
/opt/appdata/          # Application data (persistent)
├── plex/
├── radarr/
├── sonarr/
└── ...

homelabarr-data/       # Docker volume for backend state (users, sessions)
```

---

## CI/CD

- **GitHub Container Registry** — pre-built images for frontend and backend
- **GitHub Actions** — automated builds on push to main
- **Watchtower** — optional auto-updates for running containers
- **3-tier flow** — `dev` → `staging` (1-week soak) → `main` (production)
