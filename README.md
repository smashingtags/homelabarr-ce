# **HomelabARR CE**

<p align="center">
    <a href="https://github.com/smashingtags/homelabarr-ce">
      <img src="https://raw.githubusercontent.com/smashingtags/homelabarr-assets/main/homelabber-wiki/homelabarr-header.png" alt="HomelabARR CE">
    </a>
</p>

-----

<p align="center">
    </br>
    <a href="https://discord.gg/Pc7mXX786x">
        <img src="https://img.shields.io/discord/1334411584927301682?label=Discord%20Server&logo=discord&color=5865F2" alt="Join HomelabARR on Discord">
    </a>
    </br>
    <a href="https://github.com/smashingtags/homelabarr-ce/releases/latest">
        <img src="https://img.shields.io/github/v/release/smashingtags/homelabarr-ce?include_prereleases&label=Latest%20Release&logo=github" alt="Latest Official Release on GitHub">
    </a>
    </br>
    <a href="https://github.com/smashingtags/homelabarr-ce/blob/master/LICENSE">
        <img src="https://img.shields.io/github/license/smashingtags/homelabarr-ce?label=License&logo=mit" alt="MIT License">
    </a>
    </br>
    <a href="https://ko-fi.com/homelabarr">
        <img src="https://img.shields.io/badge/Ko--fi-Support%20Development-FF5E5B?logo=kofi&logoColor=white" alt="Support Development on Ko-fi">
    </a>
    </br>
</p>

_Advanced Docker-based media server stack with two deployment modes: Full mode with Traefik reverse proxy + Authelia authentication, or Local mode for direct IP:PORT access. Now includes comprehensive monitoring and observability stack. Part of the HomelabARR ecosystem - visit [homelabarr.com](https://homelabarr.com) for the web interface._

## 🆕 Latest Updates

### 📊 Monitoring & Observability Stack
- **Grafana** - Comprehensive dashboards for infrastructure, media servers, and proxy monitoring
- **Prometheus** - Metrics collection with auto-discovery for 100+ containerized applications
- **Loki** - Centralized log aggregation with 90-day retention
- **Portainer** - Docker container management with web UI
- **cAdvisor** - Container resource monitoring and performance metrics
- **Pre-built Dashboards** - Ready-to-use monitoring for Plex, Sonarr, Radarr, Traefik, and system metrics
---

## 🚀 Quick Deploy

Get started with HomelabARR CE in minutes:

### Full Mode (Domain Required)
```bash
# Clone and deploy with full features
git clone https://github.com/smashingtags/homelabarr-ce.git
cd homelabarr-ce
chmod +x install.sh
sudo ./install.sh
```

### 🎯 One-Line Deploy (Local Mode)
```bash
cd ~ && sudo rm -rf homelabarr-ce 2>/dev/null; git clone https://github.com/smashingtags/homelabarr-ce.git && cd homelabarr-ce && chmod +x setup-local-mode.sh && ./setup-local-mode.sh
```
*Changes to home directory, removes any existing directory, clones fresh repo, and launches local mode setup*

### Manual Local Mode Setup
```bash
# Clone repository
git clone https://github.com/smashingtags/homelabarr-ce.git
cd homelabarr-ce

# Set permissions and configure  
chmod +x deploy-local.sh
cp .env.example .env  # Edit with your settings

# Interactive deployment
./deploy-local.sh
```
---

## Deployment Modes

### 🌐 Full Mode (Default)
- **Traefik** reverse proxy with automatic SSL
- **Authelia** multi-factor authentication
- **Cloudflare** integration for DNS and protection
- Domain-based access (e.g., `https://plex.yourdomain.com`)
- Requires valid domain and Cloudflare account

### 🏠 Local Mode (New)
- Direct IP:PORT access (e.g., `http://localhost:32400`)
- No domain or Cloudflare setup required
- Perfect for local networks and testing
- Simplified deployment without reverse proxy

## 🎯 Which Deployment Mode Should You Choose?

### **Choose Full Mode If:**
- ✅ You have a **domain name** and **Cloudflare account**
- ✅ You want **external access** from anywhere on the internet
- ✅ You need **enterprise-grade authentication** with 2FA
- ✅ You want **automatic SSL/TLS** certificate management
- ✅ You prefer **clean URLs** like `https://plex.yourdomain.com`

### **Choose Local Mode If:**
- ✅ You want **simple home lab** setup
- ✅ **No domain required** - works immediately
- ✅ **Local network access** is sufficient
- ✅ You want the **fastest possible setup** (5 minutes)
- ✅ You're **testing** or **learning** HomelabARR CE

## 🚀 How to Launch Each Mode

### **Full Mode Installation:**
```bash
git clone https://github.com/smashingtags/homelabarr-ce.git
cd homelabarr-ce
sudo ./install.sh
```
*Launches the original HomelabARR CE installer with Traefik, Authelia, and domain setup*

### **Local Mode Installation:**
```bash
cd ~ && sudo rm -rf homelabarr-ce 2>/dev/null; git clone https://github.com/smashingtags/homelabarr-ce.git && cd homelabarr-ce && chmod +x install-local.sh && ./install-local.sh
```
*One-line deploy for immediate local network access*

### **Switching Between Modes:**
Both modes can coexist on the same system. You can:
- Test with **Local Mode** first
- Upgrade to **Full Mode** when ready for production
- Run both simultaneously on different ports
---

## Minimum Specs and Requirements

### System Requirements
- **OS**: Ubuntu 22.04 LTS (Stable)
- **CPU**: 2 Cores or 2 vCores (x86/x64) - **No ARM Support**
- **RAM**: 4GB minimum
- **Storage**: 20GB minimum disk space
- **Server**: VPS/VM or Dedicated Server

### Full Mode Additional Requirements
- Valid domain name ([Cloudflare](https://www.cloudflare.com/products/registrar/) recommended)
- [Cloudflare](https://dash.cloudflare.com/sign-up) account (free tier sufficient)

### Local Mode Requirements
- None! Just Docker and the system requirements above

---

## For Testing

- [Hetzner Cloud](https://www.hetzner.com/de/cloud)
- [Digital Ocean](https://www.digitalocean.com/)
---

## Pre-Install

1. Login to your Cloudflare Account & goto DNS click on Add record.
1. Add 1 **A-Record** pointed to your server's ip.
1. Copy your [CloudFlare-Global-Key](https://support.cloudflare.com/hc/en-us/articles/200167836-Managing-API-Tokens-and-Keys) and [CloudFlare-Zone-ID](https://support.cloudflare.com/hc/en-us/articles/200167836-Managing-API-Tokens-and-Keys).

---

## Set the following on Cloudflare

1. `SSL = FULL` **( not FULL/STRICT )**
1. `Always on = YES`
1. `HTTP to HTTPS = YES`
1. `RocketLoader and Broli / Onion Routing = NO`
1. `TLS min = 1.2`
1. `TLS = v1.3`

---

## Installation Options

### 🌐 Full Mode Installation
Complete setup with Traefik, Authelia, and Cloudflare integration:

```bash
# Easy installation command
git clone https://github.com/smashingtags/homelabarr-ce.git
cd homelabarr-ce
sudo ./install.sh

# Open HomelabARR CE interface
sudo homelabarr-ce -i
```
### 🏠 Local Mode Installation
Quick setup for local network access without domains:

```bash
# Clone and enter directory
git clone https://github.com/smashingtags/homelabarr-ce.git
cd homelabarr-ce/apps/.config

# Deploy Plex locally
docker compose -f plex-local-template.yml --env-file .env up -d

# Access at http://localhost:32400
```
---

## Available Applications

HomelabARR CE supports 100+ self-hosted applications across categories:

- **Media Servers**: Plex, Jellyfin, Emby
- **Media Management**: Radarr, Sonarr, Lidarr, Bazarr
- **Download Clients**: qBittorrent, SABnzbd, NZBGet, Deluge
- **Request Management**: Overseerr, Petio
- **Monitoring**: Tautulli, Netdata, Grafana
- **Self-hosted Apps**: Nextcloud, Bitwarden, Home Assistant
---

## Support

Kindly report any issues/broken-parts/bugs on [github](https://github.com/smashingtags/homelabarr-ce/issues) or [discord](https://discord.gg/Pc7mXX786x)

**☕ [Support Development](https://ko-fi.com/homelabarr)** - Help keep HomelabARR CE growing!

---

## Code and Permissions

```sh
Copyright 2021 @smashingtags
Code owner @smashingtags
Dev Code @smashingtags
Co-Dev -APPS- @CONTRIBUTORS-LIST
```

---

## Contributors ✨

Thanks goes to these wonderful people ([emoji key](https://allcontributors.org/docs/en/emoji-key)):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->

### Contributors

<table>
<tr>
    <td align="center" style="word-wrap: break-word; width: 75.0; height: 75.0">
        <a href=https://github.com/smashingtags>
            <img src=https://avatars.githubusercontent.com/u/48292010?v=4 width="50;"  style="border-radius:50%;align-items:center;justify-content:center;overflow:hidden;padding-top:10px" alt=smashingtags/>
            <br />
            <sub style="font-size:14px"><b>smashingtags</b></sub>
        </a>
    </td>
</tr>
</table>
<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->
