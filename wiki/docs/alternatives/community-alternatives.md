# Community Alternatives to HomelabARR CE

## Overview

While HomelabARR CE provides a comprehensive Docker-based media server stack with Traefik and Authelia, there are several excellent alternatives in the community. Each project has its own philosophy, strengths, and target audience. This guide helps you explore options to find the best fit for your needs.

## Active Projects

### 1. Saltbox (Cloudbox Successor)
**GitHub:** [github.com/saltyorg/Saltbox](https://github.com/saltyorg/Saltbox)  
**Documentation:** [docs.saltbox.dev](https://docs.saltbox.dev)  
**Status:** ✅ Actively Maintained

**Philosophy:** Ansible-based solution for rapidly deploying Docker containerized cloud media servers, heavily based on Cloudbox but with active development.

**Key Features:**
- Ansible automation for deployment
- Cloud storage integration via Rclone VFS
- Union filesystem with mergerfs
- Built-in backup system
- IPv6 support in Docker network
- Support for Ubuntu 22.04/24.04 LTS

**Pros:**
- Comprehensive automation
- Strong cloud storage focus
- Active development and community
- Well-documented migration from Cloudbox

**Cons:**
- Command-line only (no GUI)
- Requires comfort with Ansible
- Limited to Ubuntu LTS releases
- No ARM support

**Best For:** Users wanting automated cloud-based media servers with minimal manual configuration.

---

### 2. Sudobox.io
**Website:** [sudobox.io](https://sudobox.io)  
**GitHub:** [github.com/sudobox-io](https://github.com/sudobox-io)  
**Documentation:** [docs.sudobox.io](https://docs.sudobox.io)  
**Status:** ✅ Actively Maintained

**Philosophy:** Effortless, fully automated media box installation with a focus on eliminating backend command-line interaction.

**Key Features:**
- Clean, intuitive web UI
- Fully dockerized tools
- Cloudflare integration
- Weekly feature additions
- Unified management system

**Pros:**
- User-friendly web interface
- No command-line required
- Active development
- Strong security focus

**Cons:**
- Still in active development (subject to change)
- Less mature than other solutions
- Limited documentation compared to alternatives

**Best For:** Users who prefer GUI-based management and want to avoid command-line configuration.

---

### 3. DockSTARTer
**Website:** [dockstarter.com](https://dockstarter.com)  
**GitHub:** [github.com/GhostWriters/DockSTARTer](https://github.com/GhostWriters/DockSTARTer)  
**Status:** ✅ Actively Maintained

**Philosophy:** Make it quick and easy to get up and running with Docker while maintaining transparency in the setup process.

**Key Features:**
- Menu-driven interface
- LinuxServer.io image integration
- Step-by-step guided setup
- App configuration helper
- Multi-platform support

**Pros:**
- Beginner-friendly menu system
- Well-maintained Docker images
- Active Discord community
- Good documentation
- Transparent setup process

**Cons:**
- Less automation than Ansible-based solutions
- Manual configuration still required for advanced setups
- Limited to supported applications

**Best For:** Docker beginners who want guidance without complete automation black-boxing.

---

### 4. Perfect Media Server
**Website:** [perfectmediaserver.com](https://perfectmediaserver.com)  
**Creator:** Alex Kretzschmar  
**Status:** ✅ Actively Maintained

**Philosophy:** Not a rigid solution but principles and guidelines for building your own DIY NAS with freedom-respecting open-source technologies.

**Key Features:**
- Detailed documentation and guides
- Flexible approach (not prescriptive)
- Focus on understanding, not just deploying
- Community-contributed content

**Recommended Stack:**
- Proxmox virtualization
- NixOS
- mergerfs + SnapRAID or ZFS
- Docker/Podman containers

**Pros:**
- Educational approach
- Maximum flexibility
- Strong documentation
- Active community via Self-Hosted podcast

**Cons:**
- Not a turnkey solution
- Requires more technical knowledge
- More time investment upfront

**Best For:** Users who want to understand and build their own custom solution from scratch.

---

### 5. YAMS (Yet Another Media Server)
**Website:** [yams.media](https://yams.media)  
**GitHub:** [github.com/rogsme/yams](https://github.com/rogsme/yams)  
**GitLab:** [gitlab.com/rogs/yams](https://gitlab.com/rogs/yams)  
**Status:** ✅ Actively Maintained

**Philosophy:** An opinionated media server that just works with minimal configuration in minutes.

**Key Features:**
- One-script installation
- Docker-based architecture
- *arr stack integration
- VPN integration (ProtonVPN recommended)
- CLI management tools

**Stack Includes:**
- Radarr/Sonarr/Prowlarr
- qBittorrent/SABnzbd
- Jellyfin
- Portainer

**Pros:**
- Quick installation (minutes)
- Opinionated defaults that work
- Good VPN integration
- Simple CLI tools

**Cons:**
- Less flexible due to opinionated nature
- Limited to Debian 12/Ubuntu 24.04
- Newer project with smaller community

**Best For:** Users wanting a working media server quickly without extensive customization.

---

### 6. Ansible-NAS
**GitHub:** [github.com/davestephens/ansible-nas](https://github.com/davestephens/ansible-nas)  
**Website:** [ansible-nas.io](https://ansible-nas.io)  
**Status:** ✅ Actively Maintained

**Philosophy:** Build a full-featured home server or NAS replacement with an Ubuntu box and Ansible playbooks.

**Key Features:**
- Ansible automation
- Wide application support
- External access configuration
- Monitoring stack included
- Customizable playbooks

**Supported Services:**
- Media servers (Plex, Jellyfin, Emby)
- *arr stack applications
- Document management (Paperless, Calibre)
- Monitoring (Prometheus, Loki)
- 100+ Docker applications

**Pros:**
- Highly customizable
- Well-documented
- Active community
- Comprehensive feature set

**Cons:**
- Requires Ansible knowledge
- Manual disk partition setup
- Ubuntu-focused

**Best For:** Users comfortable with Ansible who want maximum customization.

---

### 7. Swizzin
**Website:** [swizzin.ltd](https://swizzin.ltd)  
**GitHub:** [github.com/swizzin/swizzin](https://github.com/swizzin/swizzin)  
**Status:** ✅ Actively Maintained

**Philosophy:** Light, modular seedbox solution running applications close to the metal without Docker overhead.

**Key Features:**
- Bash script based
- Custom web dashboard
- Box management tool
- Seedbox optimization tuner
- Non-Docker approach

**Pros:**
- Optimized for seedbox use
- Better performance (no Docker overhead)
- Unattended installation options
- Active community

**Cons:**
- No Docker (less isolation)
- Limited to Debian/Ubuntu
- Seedbox-focused (less general purpose)

**Best For:** Users focused on torrenting/seeding with performance priorities.

---

## Legacy/Inactive Projects

### Cloudbox (Original)
**GitHub:** [github.com/Cloudbox/Cloudbox](https://github.com/Cloudbox/Cloudbox)  
**Status:** ⚠️ Maintenance Mode/Abandoned  
**Successor:** Saltbox (recommended migration path)

Original maintainers became disinterested. Users should migrate to Saltbox for continued support and updates.

---

## Quick Comparison Table

| Project | GUI | Docker | Automation | Cloud Focus | Difficulty | Best For |
|---------|-----|--------|------------|-------------|------------|----------|
| **HomelabARR CE** | ❌ | ✅ | High | Medium | Medium | Traefik/Authelia users |
| **Saltbox** | ❌ | ✅ | Very High | Very High | Medium | Cloud storage enthusiasts |
| **Sudobox.io** | ✅ | ✅ | High | Medium | Easy | GUI lovers |
| **DockSTARTer** | Menu | ✅ | Medium | Low | Easy | Docker beginners |
| **Perfect Media Server** | ❌ | ✅ | Low | Low | Hard | DIY enthusiasts |
| **YAMS** | ❌ | ✅ | High | Low | Very Easy | Quick setup seekers |
| **Ansible-NAS** | ❌ | ✅ | High | Low | Medium | Ansible users |
| **Swizzin** | ✅ | ❌ | High | Low | Medium | Seedbox users |

---

## Additional Tools & Platforms

### Container Management
- **Portainer:** Web-based Docker management
- **Yacht:** Docker management UI with template support
- **CasaOS:** Personal cloud OS with app store
- **Cosmos Cloud:** Self-hosted cloud platform

### Dashboard/Organization
- **Organizr:** Unified dashboard for services
- **Heimdall:** Application dashboard
- **Homer:** Static dashboard generator
- **Homarr:** Modern, customizable dashboard

### Specialized Solutions
- **QuickBox:** Seedbox management suite
- **TrueNAS:** Storage-focused with apps
- **Unraid:** Commercial NAS with Docker support
- **OpenMediaVault:** Debian-based NAS solution

---

## How to Choose

### Choose HomelabARR CE if you want:
- Traefik reverse proxy with Authelia
- Cloudflare integration
- 100+ pre-configured applications
- Active development and community

### Choose Saltbox if you want:
- Strong cloud storage integration
- Automated Ansible deployment
- Migration from Cloudbox

### Choose Sudobox.io if you want:
- Web UI management
- No command-line interaction
- Unified management system

### Choose DockSTARTer if you want:
- Guided setup process
- Learning Docker basics
- Menu-driven configuration

### Choose Perfect Media Server if you want:
- Complete understanding and control
- Custom-built solution
- Educational journey

### Choose YAMS if you want:
- Working setup in minutes
- Opinionated defaults
- Minimal configuration

### Choose Ansible-NAS if you want:
- Maximum flexibility
- Ansible automation
- Comprehensive home server

### Choose Swizzin if you want:
- Seedbox optimization
- Better performance
- Non-Docker deployment

---

## Community Resources

### Forums & Discussion
- [r/selfhosted](https://reddit.com/r/selfhosted) - Reddit community
- [Self-Hosted Podcast Discord](https://discord.gg/selfhosted) - Active Discord
- [LinuxServer.io Discord](https://discord.gg/linuxserver) - Docker image support

### Learning Resources
- [Awesome-Selfhosted](https://github.com/awesome-selfhosted/awesome-selfhosted) - Comprehensive list
- [TechnoTim YouTube](https://youtube.com/technotim) - Video tutorials
- [Noted.lol](https://noted.lol) - Self-hosting guides

### Docker Images
- [LinuxServer.io](https://linuxserver.io) - Maintained Docker images
- [Hotio](https://hotio.dev) - Alternative Docker images

---

## Final Thoughts

There's no "best" solution - only the best solution for your specific needs. Consider:

1. **Technical skill level** - Some require more Linux/Docker knowledge
2. **Time investment** - Quick setup vs. learning opportunity
3. **Hardware** - ARM support, resource requirements
4. **Use case** - Media focus, general NAS, seedbox
5. **Philosophy** - Automation vs. understanding, Docker vs. native

The self-hosting community is collaborative and helpful. Don't hesitate to try multiple solutions or combine approaches. Many users run hybrid setups taking the best from each project.

Remember: The journey is as important as the destination in self-hosting. Whether you choose a turnkey solution or build from scratch, you're taking control of your data and learning valuable skills.

---

*Last Updated: August 2024*  
*Contributing: Found an error or want to add another alternative? Submit a PR to the HomelabARR CE wiki!*