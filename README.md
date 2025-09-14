# **HomelabARR CLI**

<p align="center">
    <a href="https://github.com/smashingtags/homelabarr-cli">
      <img src="https://raw.githubusercontent.com/smashingtags/homelabarr-assets/main/homelabber-wiki/homelabarr-header.png" alt="HomelabARR CLI">
    </a>
</p>

----- 

<p align="center">
    </br>
    <a href="https://discord.gg/Pc7mXX786x">
        <img src="https://img.shields.io/discord/1334411584927301682?label=Discord%20Server&logo=discord&color=5865F2" alt="Join HomelabARR on Discord">
    </a>
    </br>
    <a href="https://github.com/smashingtags/homelabarr-cli/releases/latest">
        <img src="https://img.shields.io/github/v/release/smashingtags/homelabarr-cli?include_prereleases&label=Latest%20Release&logo=github" alt="Latest Official Release on GitHub">
    </a>
    </br>
    <a href="https://github.com/smashingtags/homelabarr-cli/blob/master/LICENSE">
        <img src="https://img.shields.io/github/license/smashingtags/homelabarr-cli?label=License&logo=mit" alt="MIT License">
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

### 🔧 Technical Improvements
- **Enhanced Volume Management** - Custom Go-based local-persist driver for improved performance
- **Validation Framework** - Automated configuration testing and validation scripts
- **Agent-Based Architecture** - Specialized agents for infrastructure management and troubleshooting
- **GitHub-Jira Integration** - Streamlined project management and development workflow

---

## 🚀 Quick Deploy

Get started with HomelabARR CLI in minutes:

### Full Mode (Domain Required)
```bash
# Clone and deploy with full features
git clone https://github.com/smashingtags/homelabarr-cli.git
cd homelabarr-cli
chmod +x install.sh
sudo ./install.sh
```

### 🎯 One-Line Deploy (Local Mode)
```bash
cd ~ && sudo rm -rf homelabarr-cli 2>/dev/null; git clone https://github.com/smashingtags/homelabarr-cli.git && cd homelabarr-cli && chmod +x setup-local-mode.sh && ./setup-local-mode.sh
```
*Changes to home directory, removes any existing directory, clones fresh repo, and launches local mode setup*

### Manual Local Mode Setup
```bash
# Clone repository
git clone https://github.com/smashingtags/homelabarr-cli.git
cd homelabarr-cli

# Set permissions and configure  
chmod +x deploy-local.sh
cp .env.example .env  # Edit with your settings

# Interactive deployment
./deploy-local.sh
```

**📖 [Complete Documentation](https://github.com/smashingtags/homelabarr-cli/tree/master/wiki)** | **🏠 [Local Mode Guide](https://github.com/smashingtags/homelabarr-cli/blob/master/wiki/docs/install/local-mode.md)** | **🌐 [Full Mode Guide](https://github.com/smashingtags/homelabarr-cli/blob/master/wiki/docs/install/install.md)**

### 📁 Repository Organization

As of August 2025, HomelabARR CLI features a professionally organized repository structure:

- **User-facing components** in main directories (`apps/`, `wiki/`, `scripts/`)
- **Maintenance tools** organized in `.claude/scripts/` (7 active utilities)
- **Development resources** archived in `.claude/development-scripts/` and `.claude/development-backups/`
- **863 files organized**, **862 temporary files removed**, **29,785 lines cleaned**

**📋 [Repository Structure Guide](https://github.com/smashingtags/homelabarr-cli/blob/master/wiki/docs/guides/repository-structure.md)** | **🧹 [Cleanup Details](https://github.com/smashingtags/homelabarr-cli/blob/master/wiki/docs/releases/repository-cleanup-v2.2.md)**

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
- ✅ You're **testing** or **learning** HomelabARR CLI

## 🚀 How to Launch Each Mode

### **Full Mode Installation:**
```bash
git clone https://github.com/smashingtags/homelabarr-cli.git
cd homelabarr-cli
sudo ./install.sh
```
*Launches the original HomelabARR CLI installer with Traefik, Authelia, and domain setup*

### **Local Mode Installation:**
```bash
cd ~ && sudo rm -rf homelabarr-cli 2>/dev/null; git clone https://github.com/smashingtags/homelabarr-cli.git && cd homelabarr-cli && chmod +x install-local.sh && ./install-local.sh
```
*One-line deploy for immediate local network access*

### **Switching Between Modes:**
Both modes can coexist on the same system. You can:
- Test with **Local Mode** first
- Upgrade to **Full Mode** when ready for production
- Run both simultaneously on different ports

---

## Migration

If you currently have a server with PG/MHS/PTS, have a look here before you start the installation: [Migration Guide](https://github.com/smashingtags/homelabarr-cli/blob/master/wiki/docs/install/migration.md)

---

## Minimum Specs and Requirements

### System Requirements
- **OS**: Ubuntu 22.04 LTS (Stable)
- **CPU**: 2 Cores or 2 vCores (x86/x64) - **No ARM Support**
- **RAM**: 4GB minimum
- **Storage**: 20GB minimum disk space
- **Server**: VPS/VM or Dedicated Server

### Full Mode Additional Requirements
- Valid domain name ([Namecheap](https://www.namecheap.com/) recommended)
- [Cloudflare](https://dash.cloudflare.com/sign-up) account (free tier sufficient)

### Local Mode Requirements
- None! Just Docker and the system requirements above

---

## For Testing

- [Hetzner Cloud](https://www.hetzner.com/de/cloud)
- [Digital Ocean](https://www.digitalocean.com/)
- [Vault](https://www.vultr.com/)

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
git clone https://github.com/smashingtags/homelabarr-cli.git
cd homelabarr-cli
sudo ./install.sh

# Open HomelabARR CLI interface
sudo homelabarr-cli -i
```

**📖 [Full Installation Guide](https://github.com/smashingtags/homelabarr-cli/blob/master/wiki/docs/install/install.md)**

### 🏠 Local Mode Installation
Quick setup for local network access without domains:

```bash
# Clone and enter directory
git clone https://github.com/smashingtags/homelabarr-cli.git
cd homelabarr-cli/apps/.config

# Deploy Plex locally
docker compose -f plex-local-template.yml --env-file .env up -d

# Access at http://localhost:32400
```

**📖 [Local Mode Guide](https://github.com/smashingtags/homelabarr-cli/blob/master/wiki/docs/install/local-mode.md)**

---

## Available Applications

HomelabARR CLI supports 100+ self-hosted applications across categories:

- **Media Servers**: Plex, Jellyfin, Emby
- **Media Management**: Radarr, Sonarr, Lidarr, Bazarr
- **Download Clients**: qBittorrent, SABnzbd, NZBGet, Deluge
- **Request Management**: Overseerr, Petio
- **Monitoring**: Tautulli, Netdata, Grafana
- **Self-hosted Apps**: Nextcloud, Bitwarden, Home Assistant

**📖 [Complete Application List](https://github.com/smashingtags/homelabarr-cli/blob/master/wiki/docs/apps/apps.md)**

---

## Development Workflow

HomelabARR CLI follows an enhanced development workflow integrating local development, documentation, and project management:

### Complete Workflow Process
```
Local Notes → Code Changes → Confluence Docs → Jira Updates → GitHub Branch → 
Create Pull Request → QA → {QA Passed} OR {Flopped → Bug/Subtask} → 
Documentation Validation → Done
```

### Key Workflow Features

#### 📋 Enhanced Status Management
- **QA Passed Status**: Preserves progress between QA validation and documentation completion
- **Flopped Workflow**: Systematic QA failure recovery with Bug/Subtask remediation  
- **Documentation Validation**: Mandatory verification before completion

#### 🎯 Task Prioritization Rules
- **Sprint Validation**: Only work on tickets in active sprint (not backlog)
- **Story Points**: 1 SP = 8 hours of head-down coding time
- **In Progress Priority**: Complete "In Progress" tasks before starting "To Do"

#### 🔄 Automation Features
- **Auto-Route Command**: Intelligent task routing to specialized agents
- **Breaking Change Detection**: Automatic identification requiring manual review
- **Validation Pipeline**: Comprehensive YAML, JSON, and configuration checks

### Development Commands

#### Enhanced Workflow Tools
```bash
# Auto-route tasks to specialized agents
/auto-route "Add Jellyfin with Traefik routing and monitoring"

# Complete workflow orchestration
./apps/.config/modernize-configs.sh auto

# Configuration validation
./apps/.config/validate-configs.sh

# Port conflict resolution
./apps/.config/fix-port-conflicts.sh auto
```

#### Agent-Based Development
The auto-router intelligently selects specialists:
- **docker-infrastructure-specialist**: Container and Docker Compose
- **network-architecture-specialist**: Traefik and networking
- **security-authentication-specialist**: Authelia and security
- **media-stack-specialist**: Plex, Sonarr, Radarr automation
- **monitoring-alerting-specialist**: Grafana, Prometheus, dashboards

### Quality Assurance

#### QA Process
1. **Automated Validation**: YAML syntax, configuration compliance
2. **Breaking Change Detection**: Impact assessment and review requirements
3. **Manual Testing**: Functionality verification and acceptance criteria
4. **Documentation Review**: Comprehensive documentation validation

#### Recovery Workflows
- **QA Failures**: Automatic Flopped status with remediation Bug/Subtask
- **Documentation Issues**: Cannot proceed to Done without validation
- **State Preservation**: QA Passed status maintains progress during interruptions

**📖 [Complete Development Workflow Guide](.claude/workflow/enhanced-development-workflow.md)**

---

## Support

Kindly report any issues/broken-parts/bugs on [github](https://github.com/smashingtags/homelabarr-cli/issues) or [discord](https://discord.gg/Pc7mXX786x)

**☕ [Support Development](https://ko-fi.com/homelabarr)** - Help keep HomelabARR CLI growing!

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
        <a href=https://github.com/doob187>
            <img src=https://avatars.githubusercontent.com/u/60312740?v=4 width="50;"  style="border-radius:50%;align-items:center;justify-content:center;overflow:hidden;padding-top:10px" alt=doob187/>
            <br />
            <sub style="font-size:14px"><b>doob187</b></sub>
        </a>
    </td>
    <td align="center" style="word-wrap: break-word; width: 75.0; height: 75.0">
        <a href=https://github.com/fscorrupt>
            <img src=https://avatars.githubusercontent.com/u/45659314?v=4 width="50;"  style="border-radius:50%;align-items:center;justify-content:center;overflow:hidden;padding-top:10px" alt=FSCorrupt/>
            <br />
            <sub style="font-size:14px"><b>FSCorrupt</b></sub>
        </a>
    </td>
    <td align="center" style="word-wrap: break-word; width: 75.0; height: 75.0">
        <a href=https://github.com/drag0n141>
            <img src=https://avatars.githubusercontent.com/u/44865095?v=4 width="50;"  style="border-radius:50%;align-items:center;justify-content:center;overflow:hidden;padding-top:10px" alt=DrAg0n141/>
            <br />
            <sub style="font-size:14px"><b>DrAg0n141</b></sub>
        </a>
    </td>
    <td align="center" style="word-wrap: break-word; width: 75.0; height: 75.0">
        <a href=https://github.com/smashingtags>
            <img src=https://avatars.githubusercontent.com/u/48292010?v=4 width="50;"  style="border-radius:50%;align-items:center;justify-content:center;overflow:hidden;padding-top:10px" alt=smashingtags/>
            <br />
            <sub style="font-size:14px"><b>smashingtags</b></sub>
        </a>
    </td>
</tr>
<tr>
    <td align="center" style="word-wrap: break-word; width: 75.0; height: 75.0">
        <a href=https://github.com/aelfa>
            <img src=https://avatars.githubusercontent.com/u/60222501?v=4 width="50;"  style="border-radius:50%;align-items:center;justify-content:center;overflow:hidden;padding-top:10px" alt=Aelfa/>
            <br />
            <sub style="font-size:14px"><b>Aelfa</b></sub>
        </a>
    </td>
    <td align="center" style="word-wrap: break-word; width: 75.0; height: 75.0">
        <a href=https://github.com/cyb3rgh05t>
            <img src=https://avatars.githubusercontent.com/u/5200101?v=4 width="50;"  style="border-radius:50%;align-items:center;justify-content:center;overflow:hidden;padding-top:10px" alt=cyb3rgh05t/>
            <br />
            <sub style="font-size:14px"><b>cyb3rgh05t</b></sub>
        </a>
    </td>
    <td align="center" style="word-wrap: break-word; width: 75.0; height: 75.0">
        <a href=https://github.com/justinglock40>
            <img src=https://avatars.githubusercontent.com/u/23133649?v=4 width="50;"  style="border-radius:50%;align-items:center;justify-content:center;overflow:hidden;padding-top:10px" alt=justinglock40/>
            <br />
            <sub style="font-size:14px"><b>justinglock40</b></sub>
        </a>
    </td>
    <td align="center" style="word-wrap: break-word; width: 75.0; height: 75.0">
        <a href=https://github.com/mrfret>
            <img src=https://avatars.githubusercontent.com/u/72273384?v=4 width="50;"  style="border-radius:50%;align-items:center;justify-content:center;overflow:hidden;padding-top:10px" alt=mrfret/>
            <br />
            <sub style="font-size:14px"><b>mrfret</b></sub>
        </a>
    </td>
</tr>
<tr>
    <td align="center" style="word-wrap: break-word; width: 75.0; height: 75.0">
        <a href=https://github.com/dan3805>
            <img src=https://avatars.githubusercontent.com/u/35934387?v=4 width="50;"  style="border-radius:50%;align-items:center;justify-content:center;overflow:hidden;padding-top:10px" alt=DoCtEuR3805 | FRENCH-QC/>
            <br />
            <sub style="font-size:14px"><b>DoCtEuR3805 | FRENCH-QC</b></sub>
        </a>
    </td>
    <td align="center" style="word-wrap: break-word; width: 75.0; height: 75.0">
        <a href=https://github.com/brtbach>
            <img src=https://avatars.githubusercontent.com/u/24246495?v=4 width="50;"  style="border-radius:50%;align-items:center;justify-content:center;overflow:hidden;padding-top:10px" alt=brtbach/>
            <br />
            <sub style="font-size:14px"><b>brtbach</b></sub>
        </a>
    </td>
    <td align="center" style="word-wrap: break-word; width: 75.0; height: 75.0">
        <a href=https://github.com/renovate-bot>
            <img src=https://avatars.githubusercontent.com/u/25180681?v=4 width="50;"  style="border-radius:50%;align-items:center;justify-content:center;overflow:hidden;padding-top:10px" alt=Mend Renovate/>
            <br />
            <sub style="font-size:14px"><b>Mend Renovate</b></sub>
        </a>
    </td>
    <td align="center" style="word-wrap: break-word; width: 75.0; height: 75.0">
        <a href=https://github.com/ramsaytc>
            <img src=https://avatars.githubusercontent.com/u/16809662?v=4 width="50;"  style="border-radius:50%;align-items:center;justify-content:center;overflow:hidden;padding-top:10px" alt=ramsaytc/>
            <br />
            <sub style="font-size:14px"><b>ramsaytc</b></sub>
        </a>
    </td>
</tr>
<tr>
    <td align="center" style="word-wrap: break-word; width: 75.0; height: 75.0">
        <a href=https://github.com/Shayne55434>
            <img src=https://avatars.githubusercontent.com/u/37595910?v=4 width="50;"  style="border-radius:50%;align-items:center;justify-content:center;overflow:hidden;padding-top:10px" alt=Shayne/>
            <br />
            <sub style="font-size:14px"><b>Shayne</b></sub>
        </a>
    </td>
    <td align="center" style="word-wrap: break-word; width: 75.0; height: 75.0">
        <a href=https://github.com/Nossersvinet>
            <img src=https://avatars.githubusercontent.com/u/83166809?v=4 width="50;"  style="border-radius:50%;align-items:center;justify-content:center;overflow:hidden;padding-top:10px" alt=Nossersvinet/>
            <br />
            <sub style="font-size:14px"><b>Nossersvinet</b></sub>
        </a>
    </td>
    <td align="center" style="word-wrap: break-word; width: 75.0; height: 75.0">
        <a href=https://github.com/ookla-ariel-ride>
            <img src=https://avatars.githubusercontent.com/u/42082417?v=4 width="50;"  style="border-radius:50%;align-items:center;justify-content:center;overflow:hidden;padding-top:10px" alt=Ookla, Ariel, Ride!/>
            <br />
            <sub style="font-size:14px"><b>Ookla, Ariel, Ride!</b></sub>
        </a>
    </td>
    <td align="center" style="word-wrap: break-word; width: 75.0; height: 75.0">
        <a href=https://github.com/actions-user>
            <img src=https://avatars.githubusercontent.com/u/65916846?v=4 width="50;"  style="border-radius:50%;align-items:center;justify-content:center;overflow:hidden;padding-top:10px" alt=actions-user/>
            <br />
            <sub style="font-size:14px"><b>actions-user</b></sub>
        </a>
    </td>
</tr>
<tr>
    <td align="center" style="word-wrap: break-word; width: 75.0; height: 75.0">
        <a href=https://github.com/ImgBotApp>
            <img src=https://avatars.githubusercontent.com/u/31427850?v=4 width="50;"  style="border-radius:50%;align-items:center;justify-content:center;overflow:hidden;padding-top:10px" alt=Imgbot/>
            <br />
            <sub style="font-size:14px"><b>Imgbot</b></sub>
        </a>
    </td>
    <td align="center" style="word-wrap: break-word; width: 75.0; height: 75.0">
        <a href=https://github.com/townsmcp>
            <img src=https://avatars.githubusercontent.com/u/14061617?v=4 width="50;"  style="border-radius:50%;align-items:center;justify-content:center;overflow:hidden;padding-top:10px" alt=James Townsend/>
            <br />
            <sub style="font-size:14px"><b>James Townsend</b></sub>
        </a>
    </td>
    <td align="center" style="word-wrap: break-word; width: 75.0; height: 75.0">
        <a href=https://github.com/red-daut>
            <img src=https://avatars.githubusercontent.com/u/78737369?v=4 width="50;"  style="border-radius:50%;align-items:center;justify-content:center;overflow:hidden;padding-top:10px" alt=Red Daut/>
            <br />
            <sub style="font-size:14px"><b>Red Daut</b></sub>
        </a>
    </td>
    <td align="center" style="word-wrap: break-word; width: 75.0; height: 75.0">
        <a href=https://github.com/DomesticWarlord>
            <img src=https://avatars.githubusercontent.com/u/57776315?v=4 width="50;"  style="border-radius:50%;align-items:center;justify-content:center;overflow:hidden;padding-top:10px" alt=DomesticWarlord/>
            <br />
            <sub style="font-size:14px"><b>DomesticWarlord</b></sub>
        </a>
    </td>
</tr>
</table>
<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->
