# Traefik Reverse Proxy

Traefik is the reverse proxy that makes your apps accessible at `https://app.yourdomain.com` with automatic SSL certificates. It's the core of HomelabARR CE **Full Mode**.

## What Traefik Does

- Routes incoming traffic to the right container based on hostname
- Handles SSL/TLS certificates via Let's Encrypt (ACME DNS challenge through Cloudflare)
- Applies security middleware (rate limiting, secure headers, authentication via Authelia)
- Redirects HTTP to HTTPS automatically

HomelabARR CE deploys Traefik 3.5 alongside **Authelia** (2FA authentication) and **[CF Companion](https://github.com/smashingtags/cf-companion)** (automatic Cloudflare DNS).

!!! success "Automatic DNS — never touch Cloudflare again"
    CF Companion watches Docker events. When you deploy a container with a Traefik `Host()` label, it automatically creates the Cloudflare CNAME record. Deploy 40 containers, get 40 DNS records. Zero manual work.

    This is built into the Traefik stack — no extra setup. Just make sure your `DOMAIN1_ZONE_ID` and Cloudflare credentials are set in `.env`.

## Installation

### Via install.sh (Recommended)

```bash
cd homelabarr-ce
./install.sh
# Select Option 1 — installs Traefik + Authelia + cf-companion
```

This runs `traefik/install.sh`, which detects your OS (Ubuntu/Debian) and calls the appropriate installer script.

### Prerequisites

Before installing, make sure your `.env` file has:

```bash
DOMAIN=yourdomain.com
CLOUDFLARE_EMAIL=your-email@example.com
CLOUDFLARE_API_KEY=your-global-api-key
DOMAIN1_ZONE_ID=your-zone-id
APPFOLDER=/opt/appdata
DOCKERNETWORK=proxy
ID=1000
TZ=America/New_York
```

See [Cloudflare Setup](cloudflare.md) for getting the Cloudflare credentials.

### The Proxy Network

All containers that Traefik routes to must be on the `proxy` Docker network:

```bash
docker network create proxy
```

The installer handles this, but if you're troubleshooting, verify it exists with `docker network ls`.

## How Routing Works

Traefik discovers containers via Docker labels. When you deploy an app through HomelabARR CE, the YAML template includes labels like:

```yaml
labels:
  - "traefik.enable=true"
  - "traefik.docker.network=proxy"
  - "traefik.http.routers.sonarr-rtr.entrypoints=https"
  - "traefik.http.routers.sonarr-rtr.rule=Host(`sonarr.${DOMAIN}`)"
  - "traefik.http.routers.sonarr-rtr.tls=true"
  - "traefik.http.routers.sonarr-rtr.tls.certresolver=dns-cloudflare"
  - "traefik.http.routers.sonarr-rtr.middlewares=chain-authelia@file"
  - "traefik.http.routers.sonarr-rtr.service=sonarr-svc"
  - "traefik.http.services.sonarr-svc.loadbalancer.server.port=8989"
```

Breaking this down:

| Label | Purpose |
|-------|---------|
| `traefik.enable=true` | Tells Traefik to route this container |
| `traefik.docker.network=proxy` | Which Docker network to use |
| `routers.APP-rtr.rule=Host(...)` | Match requests for this hostname |
| `routers.APP-rtr.tls.certresolver=dns-cloudflare` | Use Cloudflare DNS for SSL cert |
| `routers.APP-rtr.middlewares=chain-authelia@file` | Apply authentication middleware |
| `services.APP-svc.loadbalancer.server.port` | Container's internal port |

## Middleware Chains

Middleware chains are defined in `/opt/appdata/traefik/rules/middlewares-chains.yml`:

### chain-no-auth

No authentication required. Applies rate limiting and secure headers only.

```yaml
chain-no-auth:
  chain:
    middlewares:
      - middlewares-rate-limit
      - middlewares-secure-headers
```

Use for apps that handle their own authentication (Plex, Overseerr) or public-facing services.

### chain-authelia

Full authentication via Authelia. Rate limiting + secure headers + Authelia forward auth.

```yaml
chain-authelia:
  chain:
    middlewares:
      - middlewares-rate-limit
      - middlewares-secure-headers
      - middlewares-authelia
```

This is the default for most apps. Users hit Authelia's login page before reaching the app.

!!! tip
    To switch an app from `chain-authelia` to `chain-no-auth`, change the middleware label in the app's YAML template and redeploy.

## SSL Certificates

Traefik gets wildcard certificates from Let's Encrypt using the Cloudflare DNS challenge:

- Certificate covers `yourdomain.com` and `*.yourdomain.com`
- Stored in `/opt/appdata/traefik/acme/acme.json`
- Auto-renews before expiry
- DNS challenge means ports 80/443 don't need to be open for validation (but they do need to be open for serving traffic)

## Traefik Dashboard

Access at `https://traefik.yourdomain.com` (protected by Authelia).

The dashboard shows:

- Active routers and their rules
- Services and their health
- Middleware chains in use
- Entrypoints (HTTP/HTTPS)

## File Locations

| File | Purpose |
|------|---------|
| `/opt/appdata/traefik/rules/` | Middleware configs (TOML and YAML) |
| `/opt/appdata/traefik/acme/acme.json` | SSL certificates |
| `/opt/appdata/traefik/traefik.log` | Access and error logs |

## Troubleshooting

### 404 Not Found

**Traefik received the request but no router matched.**

- Check the container is running: `docker ps | grep appname`
- Check the container is on the `proxy` network: `docker inspect appname | grep -A5 Networks`
- Check the Host rule matches the URL you're visiting
- Check `traefik.enable=true` is set in the container's labels

### 502 Bad Gateway

**Traefik matched a route but can't reach the backend container.**

- The container's internal port in the label doesn't match the actual port the app listens on
- The container crashed — check `docker logs appname`
- The container is not on the `proxy` network

### 503 Service Unavailable

**Middleware error, usually Authelia.**

- Check Authelia is running: `docker ps | grep authelia`
- Check Authelia logs: `docker logs authelia`
- Verify `/opt/appdata/authelia/configuration.yml` is valid

### Certificate Errors

- Check Cloudflare credentials in `.env`
- Check `acme.json` permissions: `chmod 600 /opt/appdata/traefik/acme/acme.json`
- Check Traefik logs: `docker logs traefik 2>&1 | grep -i acme`

## Support

Kindly report any issues/broken-parts/bugs on [github](https://github.com/smashingtags/homelabarr-ce/issues) or [discord](https://discord.gg/Pc7mXX786x)

- Join our [![Discord: https://discord.gg/Pc7mXX786x](https://img.shields.io/badge/Discord-gray.svg?style=for-the-badge)](https://discord.gg/Pc7mXX786x) for Support
