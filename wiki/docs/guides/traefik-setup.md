# Traefik & Domain Setup

This guide covers setting up Traefik reverse proxy with automatic SSL, so you can access your apps via `https://app.yourdomain.com` instead of `http://server-ip:port`.

---

## Prerequisites

- A registered domain name
- DNS managed by Cloudflare (or another supported provider)
- A public IP address (or Cloudflare tunnel)
- Docker and Docker Compose installed

---

## Overview

```
Internet → Cloudflare DNS → Your Server:443 → Traefik → App Container
```

Traefik:

- Automatically discovers Docker containers via labels
- Requests and renews SSL certificates from Let's Encrypt
- Routes traffic based on hostname rules
- Integrates with Authelia for authentication

---

## Step 1: Create the Docker Network

```bash
docker network create proxy
```

All Traefik-routed containers join this network.

## Step 2: Set Up Traefik

Create a directory for Traefik configuration:

```bash
mkdir -p /opt/appdata/traefik
touch /opt/appdata/traefik/acme.json
chmod 600 /opt/appdata/traefik/acme.json
```

Create `docker-compose.yml` for Traefik:

```yaml
services:
  traefik:
    image: traefik:v3.0
    container_name: traefik
    restart: unless-stopped
    security_opt:
      - no-new-privileges:true
    ports:
      - 80:80
      - 443:443
    environment:
      - CF_API_EMAIL=your@email.com
      - CF_DNS_API_TOKEN=your-cloudflare-api-token
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - /opt/appdata/traefik/acme.json:/acme.json
    command:
      - --api.dashboard=true
      - --providers.docker=true
      - --providers.docker.exposedbydefault=false
      - --entrypoints.web.address=:80
      - --entrypoints.websecure.address=:443
      - --entrypoints.web.http.redirections.entrypoint.to=websecure
      - --certificatesresolvers.letsencrypt.acme.dnschallenge=true
      - --certificatesresolvers.letsencrypt.acme.dnschallenge.provider=cloudflare
      - --certificatesresolvers.letsencrypt.acme.email=your@email.com
      - --certificatesresolvers.letsencrypt.acme.storage=/acme.json
    networks:
      - proxy
    labels:
      - traefik.enable=true
      - traefik.http.routers.traefik.rule=Host(`traefik.yourdomain.com`)
      - traefik.http.routers.traefik.tls.certresolver=letsencrypt
      - traefik.http.services.traefik.loadbalancer.server.port=8080

networks:
  proxy:
    external: true
```

```bash
docker compose up -d
```

## Step 3: Configure DNS

In your Cloudflare dashboard, create DNS records for each app:

| Type | Name | Content | Proxy |
|------|------|---------|-------|
| A | `traefik` | Your server's public IP | ✅ Proxied |
| A | `plex` | Your server's public IP | ✅ Proxied |
| A | `radarr` | Your server's public IP | ✅ Proxied |

Or use a wildcard: `*.yourdomain.com → Your IP`

## Step 4: Deploy Apps with Traefik Mode

In the HomelabARR dashboard, select **Traefik** as the deployment mode. The app's Docker labels handle the rest — Traefik discovers the container, requests a certificate, and starts routing traffic.

---

## Adding Authelia (Optional)

Authelia adds a login page with optional multi-factor authentication in front of your apps.

See the [Authelia documentation](https://www.authelia.com/integration/proxies/traefik/) for setup instructions. Once running, deploy apps with **Traefik + Authelia** mode — templates that include `chain-authelia` middleware labels will automatically require authentication.

---

## Cloudflare Companion

HomelabARR includes a **CF Companion** app in the catalog that automatically creates Cloudflare DNS records when you deploy new containers with Traefik labels. Deploy it from the **System & Utilities** category to eliminate manual DNS management.
