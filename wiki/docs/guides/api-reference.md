# API Reference

The HomelabARR CE backend exposes a REST API on port 8092.

**Access methods:**

- Via the frontend proxy: `http://your-server:8084/api/<endpoint>` (nginx strips `/api` prefix)
- Direct: `http://your-server:8092/<endpoint>`

All endpoints return JSON unless noted. Protected endpoints require a JWT token or API key in the `Authorization` header:

```
Authorization: Bearer <jwt-token-or-hlr_api-key>
```

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
| `POST` | `/auth/users` | Admin | Create a new user account |
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
    "role": "admin"
  }
}
```

---

## API Keys

API keys provide persistent authentication for scripts, mobile apps, and automation. Keys are prefixed with `hlr_` and don't expire unless revoked.

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| `POST` | `/auth/api-keys` | Required | Generate a new API key |
| `GET` | `/auth/api-keys` | Required | List your API keys |
| `DELETE` | `/auth/api-keys/:keyId` | Required | Revoke an API key |

### POST /auth/api-keys

```json
// Request
{ "name": "my-script" }

// Response
{
  "success": true,
  "key": "hlr_a1b2c3d4e5f6...",
  "id": "key_abc123",
  "name": "my-script"
}
```

!!! warning "Save the key"
    The full API key is only shown once at creation. Store it securely.

### Using an API Key

```bash
curl -H "Authorization: Bearer hlr_a1b2c3d4e5f6..." \
  http://your-server:8092/applications
```

---

## Applications

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| `GET` | `/applications` | None | List all apps from the catalog |
| `POST` | `/applications/:appId/stop` | Conditional | Stop an application's containers |
| `DELETE` | `/applications/:appId` | Conditional | Remove an application |
| `GET` | `/applications/:appId/logs` | Conditional | Get application logs |

!!! note "Conditional auth"
    When `AUTH_ENABLED=true` (default), these endpoints require a valid token. When auth is disabled, they accept unauthenticated requests.

### GET /applications

Returns the full app catalog organized by category:

```json
{
  "success": true,
  "applications": {
    "media-servers": [...],
    "downloads": [...],
    "ai": [...],
    "monitoring": [...],
    "self-hosted": [...]
  },
  "totalApps": 123,
  "categories": [
    "ai", "backup", "downloads", "media-management",
    "media-servers", "monitoring", "self-hosted",
    "system", "transcoding", "virtual-desktops"
  ]
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
  "appId": "media-servers-plex",
  "config": {
    "TZ": "America/New_York",
    "ID": "1000",
    "DOMAIN": "plex.example.com",
    "APPFOLDER": "/opt/appdata"
  },
  "mode": { "type": "traefik" }
}

// Response
{
  "success": true,
  "deploymentId": "550e8400-e29b-41d4-a716-446655440000",
  "streamEndpoint": "/stream/progress",
  "statusEndpoint": "/deployments/550e8400-.../status"
}
```

`mode.type` accepts: `standard`, `traefik`, or `authelia`.

### GET /deployment-modes

```json
{
  "success": true,
  "modes": [
    { "type": "standard", "name": "Standard", "description": "Basic Docker deployment without reverse proxy" },
    { "type": "traefik", "name": "Traefik", "description": "Deployment with Traefik reverse proxy and SSL" },
    { "type": "authelia", "name": "Traefik + Authelia", "description": "Full deployment with authentication" }
  ]
}
```

---

## Progress Streaming (SSE)

| Method | Path | Auth | Response | Description |
|--------|------|------|----------|-------------|
| `GET` | `/stream/progress` | None | `text/event-stream` | SSE connection for deployment events |
| `POST` | `/stream/deployments/:id/subscribe` | Conditional | JSON | Subscribe to a specific deployment |

!!! warning "Not JSON"
    `/stream/progress` returns `text/event-stream`. Use `EventSource` or a streaming HTTP client.

---

## Containers

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| `GET` | `/containers` | Conditional | List all Docker containers |
| `GET` | `/containers/:id/stats` | None | Live stats for a container |
| `GET` | `/containers/:id/logs` | None | Container logs |
| `POST` | `/containers/:id/start` | Conditional | Start a stopped container |
| `POST` | `/containers/:id/stop` | Conditional | Stop a running container |
| `POST` | `/containers/:id/restart` | Conditional | Restart a container |
| `DELETE` | `/containers/:id` | Conditional | Remove a container |

Add `?stats=true` to `GET /containers` for CPU and memory usage.

---

## Ports

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| `GET` | `/ports/check` | None | List all host ports in use by Docker |
| `GET` | `/ports/available` | None | Find next available port |

### GET /ports/available

```bash
# Find next available port starting from 8000
curl http://your-server:8092/ports/available?start=8000&end=9000

# Response
{ "success": true, "availablePort": 8085 }
```

---

## Health

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| `GET` | `/health` | None | Health check with Docker, platform, and config status |

Returns `200` when healthy, `503` when degraded.

---

## Error Format

All errors follow this structure:

```json
{
  "error": "Description of what went wrong",
  "details": "Additional context"
}
```

Status codes: `400` bad request, `401` not authenticated, `403` forbidden, `404` not found, `500` server error, `503` Docker unavailable.
