# Traefik & Domain Setup

This guide is for when you're ready to level up from `http://server-ip:PORT` to `https://plex.yourdomain.com` with free SSL certificates.

!!! info "You don't need this to get started"
    Traefik is optional. If you just want to deploy apps and access them by IP and port number, skip this entirely. Come back when you're ready for custom domains.

---

## What You Need

- **A domain name** — you can buy one from Cloudflare, Namecheap, Google Domains, etc. (around $10/year)
- **Cloudflare account** — free, manages your DNS (other providers work too, but Cloudflare is easiest)
- **Your server's public IP** — or use a Cloudflare tunnel if your ISP blocks ports

---

## How It Works

Here's the flow in plain English:

```
Someone types plex.yourdomain.com
→ Cloudflare looks up the DNS record and points to your server
→ Traefik (running on your server) catches the request
→ Traefik routes it to the right container
→ Free SSL certificate is handled automatically
```

You set it up once, and every new app you deploy with Traefik mode gets its own URL automatically.

---

## Step 1: Create the Docker Network

Traefik and your apps need to be on the same network so they can talk to each other:

```bash
docker network create proxy
```

One command, done. This only needs to happen once.

## Step 2: Set Up Cloudflare DNS

1. Log in to [Cloudflare](https://dash.cloudflare.com)
2. Add your domain (or select it if it's already there)
3. Create an **API token**: Go to My Profile → API Tokens → Create Token → Use the "Edit zone DNS" template
4. Save this token — you'll need it in the next step

For DNS records, you have two options:

**Option A: Wildcard (recommended)** — one record covers everything:

| Type | Name | Content | Proxy |
|------|------|---------|-------|
| A | `*` | Your server's public IP | ✅ Proxied |

**Option B: Individual records** — one per app:

| Type | Name | Content | Proxy |
|------|------|---------|-------|
| A | `plex` | Your server's public IP | ✅ Proxied |
| A | `radarr` | Your server's public IP | ✅ Proxied |
| A | `sonarr` | Your server's public IP | ✅ Proxied |

The wildcard is easier — you won't have to add a new DNS record every time you deploy an app.

## Step 3: Install Traefik

Create a folder for Traefik's config:

```bash
mkdir -p /opt/appdata/traefik
touch /opt/appdata/traefik/acme.json
chmod 600 /opt/appdata/traefik/acme.json
```

Create a file called `traefik-compose.yml`:

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

networks:
  proxy:
    external: true
```

!!! warning "Replace the placeholders"
    Change `your@email.com` to your real email and `your-cloudflare-api-token` to the API token you created in Step 2.

Start Traefik:

```bash
docker compose -f traefik-compose.yml up -d
```

## Step 4: Deploy Apps with Traefik Mode

Now the fun part. In the HomelabARR dashboard:

1. Click **Deploy** on any app
2. Choose **Traefik** as the deployment mode
3. Set your domain name in the config (e.g., `yourdomain.com`)
4. Click Deploy

Traefik automatically:
- Detects the new container
- Requests an SSL certificate from Let's Encrypt
- Starts routing `https://appname.yourdomain.com` to it

No manual config. No certificate juggling. It just works.

---

## Adding Authelia (Extra Security)

Authelia puts a login page in front of your apps. Instead of anyone being able to access `https://radarr.yourdomain.com`, they'll have to log in first. You can even add two-factor authentication.

This is optional, but great for apps you expose to the internet.

Check out the [Authelia docs](https://www.authelia.com/integration/proxies/traefik/) for setup. Once it's running, deploy apps with **Traefik + Authelia** mode and they're automatically protected.

---

## CF Companion (Auto DNS)

Tired of manually adding DNS records in Cloudflare every time you deploy an app? HomelabARR includes **CF Companion** in the app catalog. Deploy it from **System & Utilities** and it will automatically create Cloudflare DNS records whenever a new container with Traefik labels starts up.

Set it and forget it.

---

## Don't have a public IP?

If your ISP blocks incoming connections (or you use CGNAT), you have options:

- **Cloudflare Tunnel** — HomelabARR includes `Cloudflared` in the catalog. Deploy it and it creates a secure tunnel to Cloudflare without opening any ports.
- **Tailscale / WireGuard** — access your server over a VPN from anywhere.
