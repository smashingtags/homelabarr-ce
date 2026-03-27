# API Reference

HomelabARR has a REST API you can use to deploy apps, manage containers, and do everything the dashboard does — but from scripts, cron jobs, or other tools.

**Base URL:** `http://your-server:8092`
(or through the frontend proxy: `http://your-server:8084/api/`)

---

## Authentication

Most endpoints require a login token or API key. Get one by logging in:

```bash
# Log in and get a token
curl -X POST http://your-server:8092/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "admin"}'
```

You'll get back a JWT token. Use it in all your other requests:

```bash
curl -H "Authorization: Bearer YOUR_TOKEN_HERE" http://your-server:8092/applications
```

### API Keys (Easier for Scripts)

Tokens expire. If you want something permanent for scripts or automation, use an API key instead:

```bash
# Create an API key
curl -X POST http://your-server:8092/auth/api-keys \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name": "my-script"}'
```

You'll get back a key starting with `hlr_`. Use it the same way as a token:

```bash
curl -H "Authorization: Bearer hlr_your_key_here" http://your-server:8092/applications
```

!!! warning "Save your API key"
    The full key is only shown once when you create it. If you lose it, delete it and make a new one.

---

## Browse the App Catalog

```bash
# Get all available apps
curl http://your-server:8092/applications
```

Returns all 100+ apps organized by category, with total count.

---

## Deploy an App

```bash
curl -X POST http://your-server:8092/deploy \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "appId": "media-servers-plex",
    "config": {
      "TZ": "America/New_York",
      "ID": "1000",
      "APPFOLDER": "/opt/appdata"
    },
    "mode": { "type": "standard" }
  }'
```

**Mode options:** `standard`, `traefik`, or `authelia`

The response includes a `deploymentId` and a streaming endpoint so you can watch the progress.

---

## Manage Containers

```bash
# List all containers
curl -H "Authorization: Bearer YOUR_TOKEN" http://your-server:8092/containers

# With CPU/memory stats
curl -H "Authorization: Bearer YOUR_TOKEN" "http://your-server:8092/containers?stats=true"

# Start a container
curl -X POST -H "Authorization: Bearer YOUR_TOKEN" http://your-server:8092/containers/CONTAINER_ID/start

# Stop a container
curl -X POST -H "Authorization: Bearer YOUR_TOKEN" http://your-server:8092/containers/CONTAINER_ID/stop

# Restart a container
curl -X POST -H "Authorization: Bearer YOUR_TOKEN" http://your-server:8092/containers/CONTAINER_ID/restart

# Remove a container
curl -X DELETE -H "Authorization: Bearer YOUR_TOKEN" http://your-server:8092/containers/CONTAINER_ID

# View container logs
curl http://your-server:8092/containers/CONTAINER_ID/logs
```

---

## Check Ports

```bash
# See all ports in use
curl http://your-server:8092/ports/check

# Find the next available port
curl "http://your-server:8092/ports/available?start=8000&end=9000"
```

---

## Health Check

```bash
curl http://your-server:8092/health
```

Returns `200` if everything's good, `503` if Docker isn't accessible.

---

## User Management (Admin Only)

```bash
# Create a new user
curl -X POST http://your-server:8092/auth/users \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"username": "viewer", "password": "a-good-password", "role": "user"}'

# List all users
curl -H "Authorization: Bearer YOUR_TOKEN" http://your-server:8092/auth/users
```

---

## Full Endpoint List

| Method | Endpoint | Auth | What it does |
|--------|----------|------|-------------|
| `POST` | `/auth/login` | No | Log in |
| `POST` | `/auth/logout` | Yes | Log out |
| `GET` | `/auth/me` | Yes | Get your profile |
| `POST` | `/auth/change-password` | Yes | Change password |
| `POST` | `/auth/users` | Admin | Create user |
| `GET` | `/auth/users` | Admin | List users |
| `POST` | `/auth/api-keys` | Yes | Create API key |
| `GET` | `/auth/api-keys` | Yes | List your API keys |
| `DELETE` | `/auth/api-keys/:id` | Yes | Delete an API key |
| `GET` | `/applications` | No* | App catalog |
| `POST` | `/deploy` | Yes* | Deploy an app |
| `GET` | `/containers` | Yes* | List containers |
| `POST` | `/containers/:id/start` | Yes* | Start container |
| `POST` | `/containers/:id/stop` | Yes* | Stop container |
| `POST` | `/containers/:id/restart` | Yes* | Restart container |
| `DELETE` | `/containers/:id` | Yes* | Remove container |
| `GET` | `/containers/:id/logs` | No | Container logs |
| `GET` | `/ports/check` | No | Ports in use |
| `GET` | `/ports/available` | No | Find open port |
| `GET` | `/health` | No | Health check |
| `GET` | `/stream/progress` | No | Deployment events (SSE) |

*\* When `AUTH_ENABLED=true` (the default). If you disable auth, these become open.*

---

## Errors

When something goes wrong, you'll get a clear message:

```json
{
  "error": "What went wrong",
  "details": "More info about why"
}
```

Common status codes: `400` (bad request), `401` (not logged in), `403` (not allowed), `404` (not found), `500` (server error).
