# API Reference

The HomelabARR CE backend exposes a REST API. There are two ways to reach it:

- **Via the frontend proxy (recommended):** `http://your-server:8084/api/<endpoint>` — the nginx frontend strips the `/api` prefix and forwards to the backend
- **Direct backend access:** `http://your-server:8092/<endpoint>` — bypasses the frontend entirely

All endpoints return JSON unless noted otherwise (e.g., SSE streams). Protected endpoints require a JWT token in the `Authorization` header:

```
Authorization: Bearer <jwt-token>
```

Tokens are obtained from the login endpoint and expire after 24 hours by default (configurable via `JWT_EXPIRES_IN`).

---

## Authentication

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| `POST` | `/auth/login` | None | Log in and receive a JWT token |
| `POST` | `/auth/logout` | Required | Invalidate the current session |
| `GET` | `/auth/me` | Required | Get the authenticated user's profile |
| `POST` | `/auth/change-password` | Required | Change your password |
| `GET` | `/auth/sessions` | Required | List your active sessions |
| `DELETE` | `/auth/sessions/:sessionId` | Required | Revoke a specific session |
| `POST` | `/auth/register` | Admin | Create a new user account |
| `GET` | `/auth/users` | Admin | List all users |

### POST /auth/login

```json
// Request
{ "username": "admin", "password": "admin" }

// Response
{
  "success": true,
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "user": {
    "id": "admin",
    "username": "admin",
    "email": "admin@homelabarr.local",
    "role": "admin",
    "lastLogin": "2024-01-15T10:30:00Z"
  }
}
```

### POST /auth/change-password

```json
// Request
{ "currentPassword": "admin", "newPassword": "my-new-password" }
// Response
{ "success": true, "message": "Password changed successfully" }
```

### POST /auth/register (Admin only)

```json
// Request
{ "username": "viewer", "password": "secret", "email": "user@example.com", "role": "user" }
// Response
{ "success": true, "user": { "id": "user_abc123", "username": "viewer", "role": "user" } }
```

---

## Applications

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| `GET` | `/applications` | None | List all apps from the CLI Bridge or template fallback |
| `POST` | `/applications/:appId/stop` | Conditional | Stop an application's containers |
| `DELETE` | `/applications/:appId` | Conditional | Remove an application (`?removeVolumes=true` to delete data) |
| `GET` | `/applications/:appId/logs` | Conditional | Get application logs (`?lines=100`) |

!!! note "Conditional auth"
    When `AUTH_ENABLED=true` (default), these endpoints require a valid token. When auth is disabled, they accept unauthenticated requests.

### GET /applications

```json
{
  "success": true,
  "source": "cli",
  "applications": {
    "mediaserver": [ { "id": "mediaserver-plex", "name": "plex", "displayName": "Plex", ... } ],
    "downloadclients": [ ... ],
    "mediamanager": [ ... ]
  },
  "totalApps": 112,
  "categories": ["addons", "ai-tools", "backup", "coding", "downloadclients", ...]
}
```

---

## Deployment

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| `POST` | `/deploy` | Conditional | Deploy an application |
| `GET` | `/deployment-modes` | None | List available deployment modes |
| `GET` | `/deployments/active` | Conditional | List in-progress deployments |
| `GET` | `/deployments/:deploymentId/status` | Conditional | Get status of a specific deployment |

### POST /deploy

```json
// Request
{
  "appId": "mediaserver-plex",
  "config": {
    "TZ": "America/New_York",
    "ID": "1000",
    "DOMAIN": "plex.example.com",
    "APPFOLDER": "/opt/appdata"
  },
  "mode": { "type": "traefik" }
}

// Response (streaming mode)
{
  "success": true,
  "message": "mediaserver-plex deployment started with real-time progress tracking",
  "deploymentId": "550e8400-e29b-41d4-a716-446655440000",
  "source": "cli-streaming",
  "appId": "mediaserver-plex",
  "streamEndpoint": "/stream/progress",
  "statusEndpoint": "/deployments/550e8400-e29b-41d4-a716-446655440000/status"
}
```

The `mode.type` field accepts: `standard`, `traefik`, or `authelia`.

### GET /deployment-modes

```json
{
  "success": true,
  "modes": [
    { "type": "standard", "name": "Standard", "description": "Basic Docker deployment without reverse proxy" },
    { "type": "traefik", "name": "Traefik", "description": "Deployment with Traefik reverse proxy and SSL" },
    { "type": "authelia", "name": "Traefik + Authelia", "description": "Full production deployment with authentication" }
  ],
  "cliAvailable": true
}
```

---

## Progress Streaming (SSE)

| Method | Path | Auth | Response | Description |
|--------|------|------|----------|-------------|
| `GET` | `/stream/progress` | None | `text/event-stream` | Open an SSE connection for real-time deployment events |
| `POST` | `/stream/deployments/:deploymentId/subscribe` | Conditional | JSON | Subscribe an SSE client to a specific deployment |

!!! warning "GET /stream/progress is not JSON"
    The progress endpoint returns `text/event-stream`, not JSON. Use `EventSource` or a streaming HTTP client — standard `fetch().then(r => r.json())` will fail. The subscribe endpoint returns normal JSON.

Connect to `/stream/progress` with an `EventSource`. The server assigns a `clientId` and pushes events as deployments progress. To filter events for a single deployment, call the subscribe endpoint with your `clientId` and the target `deploymentId`.

---

## Containers

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| `GET` | `/containers` | Conditional | List all Docker containers (`?stats=true` for CPU/memory) |
| `GET` | `/containers/:id/stats` | None | Get live stats for a single container |
| `GET` | `/containers/:id/logs` | None | Get container logs (`?tail=100&timestamps=true`) |
| `POST` | `/containers/:id/start` | Conditional | Start a stopped container |
| `POST` | `/containers/:id/stop` | Conditional | Stop a running container |
| `POST` | `/containers/:id/restart` | Conditional | Restart a container |
| `DELETE` | `/containers/:id` | Conditional | Remove a container |

### GET /containers

```json
{
  "success": true,
  "containers": [
    {
      "Id": "abc123...",
      "Names": ["/plex"],
      "Image": "lscr.io/linuxserver/plex:latest",
      "State": "running",
      "Status": "Up 3 days",
      "Ports": "32400/tcp"
    }
  ],
  "docker": { "status": "connected", "message": "CLI-based Docker access" }
}
```

---

## Ports

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| `GET` | `/ports/check` | None | List all host ports currently in use by Docker |
| `GET` | `/ports/available` | None | Find next available port (`?start=8000&end=9000`) |

### GET /ports/check

```json
{ "success": true, "usedPorts": [8080, 8084, 32400, 8096], "source": "cli" }
```

### GET /ports/available

```json
{ "success": true, "availablePort": 8085 }
```

---

## Health

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| `GET` | `/health` | None | Comprehensive health check with Docker, platform, and config status |

Returns `200` when healthy, `503` when degraded or in error state. The response includes Docker connection status, platform info, environment validation, CORS config, and troubleshooting guidance.

---

## Enhanced Mount Manager

These endpoints manage cloud storage providers for containers (experimental).

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| `GET` | `/enhanced-mount/:containerId/status` | Conditional | Mount status for a container |
| `GET` | `/enhanced-mount/:containerId/providers` | Conditional | List available storage providers |
| `GET` | `/enhanced-mount/:containerId/costs` | Conditional | Estimated storage costs |
| `GET` | `/enhanced-mount/:containerId/performance` | Conditional | Provider performance metrics |
| `POST` | `/enhanced-mount/:containerId/providers/:provider/enable` | Conditional | Enable a storage provider |
| `POST` | `/enhanced-mount/:containerId/providers/:provider/disable` | Conditional | Disable a storage provider |
| `POST` | `/enhanced-mount/:containerId/auth/start` | Conditional | Start OAuth flow for a provider |
| `POST` | `/enhanced-mount/:containerId/auth/complete` | Conditional | Complete OAuth flow |
| `POST` | `/enhanced-mount/:containerId/auth/api-key` | Conditional | Authenticate via API key |
| `POST` | `/enhanced-mount/:containerId/auth/test` | Conditional | Test provider authentication |

---

## Error Format

All errors return `{ "error": "...", "details": "..." }`. Status codes: `400` bad request, `401` not authenticated, `403` forbidden, `404` not found, `500` server error, `503` Docker unavailable.
