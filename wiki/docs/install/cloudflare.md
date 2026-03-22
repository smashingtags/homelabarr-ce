# Cloudflare Setup

Cloudflare provides DNS management and SSL certificates for HomelabARR CE **Full Mode** (Traefik + custom domain). If you're using Local Mode or Docker Compose mode, you can skip this entirely.

!!! note "Full Mode Only"
    Cloudflare is only required when running Traefik with a public domain. Local Mode deploys containers with direct port access and doesn't need DNS or SSL.

## Create a Cloudflare Account

1. Sign up at [dash.cloudflare.com](https://dash.cloudflare.com)
2. Add your domain — Cloudflare will scan existing DNS records
3. Update your domain registrar's nameservers to the ones Cloudflare provides
4. Wait for nameserver propagation (usually 5-30 minutes, can take up to 24 hours)

## Add a DNS Record

Create an **A record** pointing to your server's public IP:

| Type | Name | Content | Proxy | TTL |
|------|------|---------|-------|-----|
| A | `@` | Your server's public IP | Proxied (orange cloud) | Auto |

!!! tip
    If you don't know your public IP, run `curl -s ifconfig.me` on your server.

The **cf-companion** container (deployed with Traefik) automatically creates CNAME records for each app you deploy, so you only need this one A record.

## Get Your API Credentials

### Global API Key

1. Go to [dash.cloudflare.com/profile/api-tokens](https://dash.cloudflare.com/profile/api-tokens)
2. Under **API Keys**, click **View** next to **Global API Key**
3. Enter your password and complete the CAPTCHA
4. Copy the key

### Zone ID

1. Go to your domain's overview page in Cloudflare
2. Scroll to the bottom-right sidebar
3. Copy the **Zone ID**

## Environment Variables

Add these to your `.env` file (in the repo root):

```bash
DOMAIN=yourdomain.com
CLOUDFLARE_EMAIL=your-email@example.com
CLOUDFLARE_API_KEY=your-global-api-key
DOMAIN1_ZONE_ID=your-zone-id
```

These are used by both Traefik (for ACME DNS challenge) and cf-companion (for automatic DNS record creation).

## SSL/TLS Settings

In Cloudflare dashboard, go to **SSL/TLS** for your domain and configure:

### SSL Mode

**SSL/TLS > Overview**: Set encryption mode to **Full (Strict)**

This tells Cloudflare to encrypt traffic end-to-end and validate Traefik's certificate. Since Traefik gets a real Let's Encrypt cert via DNS challenge, Full (Strict) works correctly.

!!! warning
    Do not use "Flexible" mode. It creates a redirect loop because Traefik forces HTTPS.

### Edge Certificates

Go to **SSL/TLS > Edge Certificates** and set:

| Setting | Value |
|---------|-------|
| Always Use HTTPS | On |
| Minimum TLS Version | 1.2 |
| TLS 1.3 | On |

### Settings to Disable

Go to **Speed > Optimization** and disable:

- **Rocket Loader** — Off (interferes with websockets used by apps like Sonarr/Radarr)
- **Brotli** — Off (can cause issues with websocket connections)

!!! tip
    If you experience random disconnects or blank pages in *arr apps, check that Rocket Loader is disabled first.

## Verifying It Works

After deploying Traefik (see [Traefik docs](traefik.md)):

1. Check that `https://traefik.yourdomain.com` loads the Traefik dashboard
2. Check that your app subdomains resolve: `dig app.yourdomain.com`
3. Verify SSL: `curl -vI https://app.yourdomain.com 2>&1 | grep "issuer"`

You should see a Let's Encrypt certificate, not a Cloudflare origin cert.

## Troubleshooting

| Problem | Cause | Fix |
|---------|-------|-----|
| ERR_TOO_MANY_REDIRECTS | SSL mode set to Flexible | Change to Full (Strict) |
| 502 Bad Gateway | Cloudflare can't reach your server | Check A record IP, check Traefik is running, check firewall ports 80/443 |
| SSL certificate error | ACME challenge failed | Check `CLOUDFLARE_EMAIL` and `CLOUDFLARE_API_KEY` are correct |
| Apps not getting subdomains | cf-companion not running | Check `docker logs cf-companion` |

## Support

Kindly report any issues/broken-parts/bugs on [github](https://github.com/smashingtags/homelabarr-ce/issues) or [discord](https://discord.gg/Pc7mXX786x)

- Join our [![Discord: https://discord.gg/Pc7mXX786x](https://img.shields.io/badge/Discord-gray.svg?style=for-the-badge)](https://discord.gg/Pc7mXX786x) for Support
