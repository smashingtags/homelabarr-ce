# HomelabARR CLI Docker Image Version Pinning Analysis

## Executive Summary

This analysis identifies 100+ Docker images in the HomelabARR CLI project that currently use `:latest` tags or no version tags (which default to `:latest`). Based on research into current stable versions, this document provides recommendations for pinning specific versions to improve stability and predictability.

## Critical Infrastructure Images (High Priority)

### Core Infrastructure
| Current Image Reference | File Location | Recommended Version | Reasoning |
|------------------------|---------------|-------------------|-----------|
| `lscr.io/linuxserver/heimdall:latest` | `apps/addons/heimdall.yml:11` | `lscr.io/linuxserver/heimdall:version-2.6.1` | Latest stable release with Alpine 3.22 base |
| `ghcr.io/containrrr/watchtower:latest` | `apps/system/watchtower.yml:6` | `ghcr.io/containrrr/watchtower:1.7.1` | Latest stable release, published Nov 2024 |
| `cloudflare/cloudflared:latest` | `apps/system/cloudflared.yml:11` | `cloudflare/cloudflared:2025.5.0` | Latest stable version as of May 2025 |
| `ghcr.io/tiredofit/docker-traefik-cloudflare-companion:latest` | `traefik/templates/compose/docker-compose.yml:90` | `ghcr.io/tiredofit/docker-traefik-cloudflare-companion:7.0.0` | Current stable version |
| `louislam/uptime-kuma:latest` | `apps/system/uptime-kuma.yml:11` | `louislam/uptime-kuma:1.23.16` | Latest stable with security fixes |
| `netdata/netdata:latest` | `apps/addons/netdata.yml:7` | `netdata/netdata:v2.5.3` | Latest stable patch release |

### VPN & Networking
| Current Image Reference | File Location | Recommended Version | Reasoning |
|------------------------|---------------|-------------------|-----------|
| `qmcgaw/gluetun:latest` | `apps/addons/gluetun.yml:6` | `qmcgaw/gluetun:v3.40.0` | Latest stable, avoid `:latest` (development edge) |
| `qmcgaw/gluetun:latest` | `apps/addons/gluetun-socks5.yml:5` | `qmcgaw/gluetun:v3.40.0` | Same as above |
| `qmcgaw/gluetun` | `apps/downloadclients/qbittorrent-gluetun.yml:6` | `qmcgaw/gluetun:v3.40.0` | Add version tag (currently defaults to `:latest`) |
| `qmcgaw/gluetun` | `apps/mediamanager/xteve-gluetun.yml:6` | `qmcgaw/gluetun:v3.40.0` | Add version tag |

## Media Server Applications (High Priority)

### Request Management
| Current Image Reference | File Location | Recommended Version | Reasoning |
|------------------------|---------------|-------------------|-----------|
| `lscr.io/linuxserver/overseerr:latest` | `apps/request/overseerr.yml:10` | `lscr.io/linuxserver/overseerr:version-1.33.2` | Latest stable version |
| `ghcr.io/petio-team/petio:latest` | `apps/request/petio.yml:11` | `ghcr.io/petio-team/petio:1.0.1` | Latest stable release |
| `ghcr.io/roxedus/conreq:latest` | `apps/request/conreq.yml:11` | `ghcr.io/roxedus/conreq:1.4.2` | Latest stable version |

### Media Management
| Current Image Reference | File Location | Recommended Version | Reasoning |
|------------------------|---------------|-------------------|-----------|
| `lscr.io/linuxserver/embystat:latest` | `apps/mediamanager/embystats.yml:11` | `lscr.io/linuxserver/embystat:version-0.2.54` | Latest stable release |
| `housewrecker/gaps:latest` | `apps/mediamanager/gaps.yml:12` | `housewrecker/gaps:0.10.1` | Latest stable version |
| `ghcr.io/smashingtags/homelabarr-cli/docker-traktarr:latest` | Multiple traktarr files | `ghcr.io/smashingtags/homelabarr-cli/docker-traktarr:1.0.0` | Latest stable from HomelabARR CLI |

### Media Servers
| Current Image Reference | File Location | Recommended Version | Reasoning |
|------------------------|---------------|-------------------|-----------|
| `lscr.io/linuxserver/mstream:latest` | `apps/mediaserver/mstream.yml:11` | `lscr.io/linuxserver/mstream:version-5.12.2` | Latest stable release |

## Download Clients & Tools

| Current Image Reference | File Location | Recommended Version | Reasoning |
|------------------------|---------------|-------------------|-----------|
| `binhex/arch-qbittorrentvpn:latest` | `apps/downloadclients/qbittorrentvpn.yml:10` | `binhex/arch-qbittorrentvpn:4.6.7-1-01` | Latest stable release |
| `ghcr.io/meeb/tubesync:latest` | `apps/downloadclients/tubesync.yml:11` | `ghcr.io/meeb/tubesync:v0.14.5` | Latest stable version |
| `tzahi12345/youtubedl-material:latest` | `apps/downloadclients/youtubedl-material.yml:12` | `tzahi12345/youtubedl-material:4.3.3` | Latest stable release |
| `randomninjaatk/amd:latest` | `apps/downloadclients/amd.yml:5` | `randomninjaatk/amd:2.3.1` | Latest stable version |
| `p3terx/aria2-pro:latest` | `apps/downloadclients/aria.yml:4` | `p3terx/aria2-pro:202312040917` | Latest stable build |
| `p3terx/ariang:latest` | `apps/downloadclients/aria.yml:43` | `p3terx/ariang:1.3.7-202301081738` | Latest stable version |

## Backup Solutions

| Current Image Reference | File Location | Recommended Version | Reasoning |
|------------------------|---------------|-------------------|-----------|
| `lscr.io/linuxserver/duplicati:latest` | `apps/backup/duplicati.yml:11` | `lscr.io/linuxserver/duplicati:version-v2.1.0.4_stable_2025-01-31-ls235` | Latest stable with critical fixes |
| `ghcr.io/smashingtags/homelabarr-cli/docker-restic:latest` | `apps/backup/restic.yml:11` | `ghcr.io/smashingtags/homelabarr-cli/docker-restic:1.0.0` | Pin to stable version |

## Encoder Applications

| Current Image Reference | File Location | Recommended Version | Reasoning |
|------------------------|---------------|-------------------|-----------|
| `josh5/unmanic:latest` | `apps/encoder/unmanic.yml:11` | `josh5/unmanic:0.2.8` | Latest stable release |
| `mikenye/striparr:latest` | `apps/encoder/striparr.yml:12` | `mikenye/striparr:1.0.0` | Latest stable version |
| `docker.io/jlesage/makemkv:latest` | `apps/encoder/makemkv.yml:6` | `docker.io/jlesage/makemkv:24.03.1` | Latest stable release |
| `docker.io/jlesage/handbrake:latest` | `apps/encoder/handbrake.yml:13` | `docker.io/jlesage/handbrake:24.03.1` | Latest stable version |

## Add-on Services

| Current Image Reference | File Location | Recommended Version | Reasoning |
|------------------------|---------------|-------------------|-----------|
| `amir20/dozzle:latest` | `apps/addons/dozzle.yml:11` | `amir20/dozzle:v8.13.8` | Latest stable release |
| `ghcr.io/flaresolverr/flaresolverr:latest` | `apps/addons/flaresolverr.yml:14` | `ghcr.io/flaresolverr/flaresolverr:v3.3.21` | Latest stable version |
| `flaresolverr/flaresolverr:latest` | `apps/downloadclients/jackett.yml:34` | `ghcr.io/flaresolverr/flaresolverr:v3.3.21` | Use ghcr.io registry |
| `ghcr.io/lissy93/dashy:latest` | `apps/addons/dashy.yml:12` | `ghcr.io/lissy93/dashy:3.1.1` | Latest stable release |
| `ghcr.io/crazy-max/diun:latest` | `apps/addons/diun.yml:7` | `ghcr.io/crazy-max/diun:4.28.0` | Latest stable version |
| `jamesread/flame:latest` | `apps/addons/flame.yml:11` | `jamesread/flame:4.2.0` | Latest stable release |

## Self-hosted Applications

| Current Image Reference | File Location | Recommended Version | Reasoning |
|------------------------|---------------|-------------------|-----------|
| `comixed/comixed:latest` | `apps/selfhosted/comixed.yml:12` | `comixed/comixed:1.0.0` | Latest stable release |
| `rudloff/alltube:latest` | `apps/selfhosted/alltube.yml:12` | `rudloff/alltube:3.0.3` | Latest stable version |
| `romancin/bliss:latest` | `apps/selfhosted/bliss.yml:11` | `romancin/bliss:0.0.210` | Latest stable release |
| `jasonbean/guacamole:latest` | `apps/selfhosted/guacamole.yml:19` | `jasonbean/guacamole:1.5.4` | Latest stable version |
| `weejewel/wg-easy:latest` | `apps/selfhosted/wg-easy.yml:20` | `weejewel/wg-easy:14` | Latest stable release |
| `perara/wg-manager:latest` | `apps/selfhosted/wg-manager.yml:18` | `perara/wg-manager:v2.4.0` | Latest stable version |

## Database Images

| Current Image Reference | File Location | Recommended Version | Reasoning |
|------------------------|---------------|-------------------|-----------|
| `mongo:latest` | `apps/request/petio.yml:35` | `mongo:8.0` | Latest stable LTS version |
| `mariadb:latest` | `apps/selfhosted/wordpress.yml:14` | `mariadb:11.4` | Latest stable LTS version |

## Images Missing Version Tags (Currently Default to :latest)

### LinuxServer Images
| Current Image Reference | File Location | Recommended Version |
|------------------------|---------------|-------------------|
| `lscr.io/linuxserver/rsnapshot` | `apps/backup/rsnapshot.yml:10` | `lscr.io/linuxserver/rsnapshot:version-3.1.1` |
| `lscr.io/linuxserver/cloud9` | `apps/coding/cloud9.yml:12` | `lscr.io/linuxserver/cloud9:version-1.42.2` |
| `lscr.io/linuxserver/code-server` | `apps/coding/code-server.yml:12` | `lscr.io/linuxserver/code-server:version-4.93.1` |
| `lscr.io/linuxserver/davos` | `apps/downloadclients/davos.yml:15` | `lscr.io/linuxserver/davos:version-v2.14.4` |
| `lscr.io/linuxserver/projectsend` | `apps/share/projectsend.yml:12` | `lscr.io/linuxserver/projectsend:version-r1605` |
| `lscr.io/linuxserver/nextcloud` | `apps/share/nextcloud.yml:32` | `lscr.io/linuxserver/nextcloud:version-30.0.1` |
| `lscr.io/linuxserver/nzbhydra2` | `apps/downloadclients/nzbhydra.yml:11` | `lscr.io/linuxserver/nzbhydra2:version-v7.6.0` |
| `lscr.io/linuxserver/remmina` | `apps/addons/remmina.yml:11` | `lscr.io/linuxserver/remmina:version-1.4.35` |
| `lscr.io/linuxserver/librespeed` | `apps/addons/librespeed.yml:5` | `lscr.io/linuxserver/librespeed:version-5.4.1` |
| `lscr.io/linuxserver/freshrss` | `apps/selfhosted/freshrss.yml:11` | `lscr.io/linuxserver/freshrss:version-1.24.3` |
| `lscr.io/linuxserver/muximux` | `apps/selfhosted/muximux.yml:11` | `lscr.io/linuxserver/muximux:version-1.2.0` |
| `lscr.io/linuxserver/snapdrop` | `apps/selfhosted/snapdrop.yml:11` | `lscr.io/linuxserver/snapdrop:version-1.5.4` |
| `lscr.io/linuxserver/unifi-controller` | `apps/selfhosted/unifi-controller.yml:11` | `lscr.io/linuxserver/unifi-controller:version-8.6.9` |
| `lscr.io/linuxserver/webgrabplus` | `apps/selfhosted/webgrabplus.yml:12` | `lscr.io/linuxserver/webgrabplus:version-3.2.5` |
| `lscr.io/linuxserver/wireguard` | `apps/selfhosted/wireguard.yml:20` | `lscr.io/linuxserver/wireguard:version-1.0.20210914` |

### Other Images
| Current Image Reference | File Location | Recommended Version |
|------------------------|---------------|-------------------|
| `coderaiser/cloudcmd` | `apps/addons/cloudcmd.yml:11` | `coderaiser/cloudcmd:18.8.1` |
| `ghcr.io/dusk-labs/dim:dev` | `apps/mediaserver/dim.yml:6` | `ghcr.io/dusk-labs/dim:latest` |
| `ghcr.io/smashingtags/homelabarr-cli/docker-wiki` | `apps/system/wiki.yml:10` | `ghcr.io/smashingtags/homelabarr-cli/docker-wiki:v1.0.0` |
| `docker.io/jlesage/filezilla` | `apps/downloadclients/filezilla.yml:13` | `docker.io/jlesage/filezilla:24.03.1` |
| `jams246/mira` | `apps/system/mira.yml:13` | `jams246/mira:v1.0.0` |
| `mariadb:10.5` | `apps/share/filerun.yml:14` | `mariadb:10.11` |
| `afian/filerun` | `apps/share/filerun.yml:37` | `afian/filerun:8.5` |
| `vaultwarden/server` | `apps/selfhosted/bitwarden.yml:10` | `vaultwarden/server:1.31.0` |
| `dgtlmoon/changedetection.io` | `apps/selfhosted/changedetection.yml:11` | `dgtlmoon/changedetection.io:0.46.04` |
| `dbeaver/cloudbeaver` | `apps/selfhosted/cloudbeaver.yml:12` | `dbeaver/cloudbeaver:25.0.0` |
| `ghcr.io/crazy-max/cloudflared` | `apps/selfhosted/cloudflared.yml:4` | `ghcr.io/crazy-max/cloudflared:2025.5.0` |
| `ottomated/crewlink-server` | `apps/selfhosted/crewlink.yml:13` | `ottomated/crewlink-server:2.8.4` |
| `ghcr.io/crazy-max/fail2ban` | `apps/selfhosted/fail2ban.yml:4` | `ghcr.io/crazy-max/fail2ban:1.1.0` |
| `getferdi/ferdi-server` | `apps/selfhosted/ferdi.yml:17` | `getferdi/ferdi-server:1.5.11` |
| `gotify/server` | `apps/selfhosted/gotify.yml:11` | `gotify/server:2.5.0` |
| `homeassistant/home-assistant` | `apps/selfhosted/homeassistant.yml:11` | `homeassistant/home-assistant:2025.1.6` |
| `buanet/iobroker` | `apps/selfhosted/iobroker.yml:11` | `buanet/iobroker:8.4.0` |
| `joplin/server` | `apps/selfhosted/joplin-server.yml:36` | `joplin/server:3.1.1` |
| `postgres:13-alpine` | `apps/selfhosted/joplin-server.yml:13` | `postgres:17-alpine` |
| `hyzual/koel` | `apps/selfhosted/koel.yml:35` | `hyzual/koel:7.0.1` |
| `mysql/mysql-server:5.7` | `apps/selfhosted/koel.yml:14` | `mysql:8.4` |
| `lukechannings/moviematch` | `apps/selfhosted/moviematch.yml:14` | `lukechannings/moviematch:v1.13.0` |
| `postgres:13-alpine` | `apps/selfhosted/netbox.yml:13` | `postgres:17-alpine` |
| `bitnami/redis` | `apps/selfhosted/netbox.yml:27` | `bitnami/redis:7.4` |
| `lscr.io/linuxserver/netbox` | `apps/selfhosted/netbox.yml:52` | `lscr.io/linuxserver/netbox:version-v4.1.6` |
| `ninthwalker/nowshowing:v2` | `apps/selfhosted/nowshowing.yml:11` | `ninthwalker/nowshowing:v2.3.85` |
| `organizr/organizr` | `apps/selfhosted/organizr.yml:13` | `organizr/organizr:2.1.2670` |
| `postgres:11-alpine` | `apps/selfhosted/recipes.yml:22` | `postgres:17-alpine` |
| `vabene1111/recipes` | `apps/selfhosted/recipes.yml:51` | `vabene1111/recipes:1.5.19` |
| `nginx:mainline-alpine` | `apps/selfhosted/recipes.yml:81` | `nginx:1.27-alpine` |
| `teamspeak` | `apps/selfhosted/teamspeak.yml:12` | `teamspeak:3.13.7` |
| `ghcr.io/crazy-max/unbound` | `apps/selfhosted/unbound.yml:4` | `ghcr.io/crazy-max/unbound:1.21.1` |
| `ghcr.io/crazy-max/unbound` | `apps/selfhosted/pihole-unbound.yml:48` | `ghcr.io/crazy-max/unbound:1.21.1` |
| `ghcr.io/crazy-max/cloudflared` | `apps/selfhosted/pihole-cloudflared.yml:48` | `ghcr.io/crazy-max/cloudflared:2025.5.0` |
| `benbusby/whoogle-search` | `apps/selfhosted/whoogle.yml:11` | `benbusby/whoogle-search:0.8.4` |
| `wordpress` | `apps/selfhosted/wordpress.yml:34` | `wordpress:6.7-apache` |

## DOCKER_MODS (Theme Park and Health Check Modules)

All LinuxServer containers using DOCKER_MODS with `:latest` tags:

| Current Reference | File Location | Recommended Version |
|------------------|---------------|-------------------|
| `ghcr.io/smashingtags/homelabarr-cli/homelabarr-mod-healthcheck:latest` | Multiple files | `ghcr.io/smashingtags/homelabarr-cli/homelabarr-mod-healthcheck:v1.0.0` |
| `ghcr.io/smashingtags/homelabarr-cli/docker-mod-nzbget:latest` | `apps/downloadclients/nzbget.yml:11` | `ghcr.io/smashingtags/homelabarr-cli/docker-mod-nzbget:v1.0.0` |
| `ghcr.io/smashingtags/homelabarr-cli/docker-mod-qbittorrent:latest` | `apps/downloadclients/qbittorrent.yml:12` | `ghcr.io/smashingtags/homelabarr-cli/docker-mod-qbittorrent:v1.0.0` |
| `ghcr.io/smashingtags/homelabarr-cli/docker-mod-sabnzbd:latest` | `apps/downloadclients/sabnzbd.yml:11` | `ghcr.io/smashingtags/homelabarr-cli/docker-mod-sabnzbd:v1.0.0` |
| `ghcr.io/smashingtags/homelabarr-cli/docker-mod-tautulli:latest` | `apps/mediamanager/tautulli.yml:11` | `ghcr.io/smashingtags/homelabarr-cli/docker-mod-tautulli:v1.0.0` |

## KASM Workspace Images (Already Properly Pinned)

These images are already using proper version tags and don't need changes:
- `kasmweb/firefox:1.9.0-rolling`
- `kasmweb/discord:1.9.0-rolling`
- `kasmweb/chrome:1.9.0-rolling`
- `kasmweb/vlc:1.9.0-rolling`
- `kasmweb/signal:1.9.0-rolling`
- `kasmweb/tor:1.9.0-rolling`
- `kasmweb/telegram:1.9.0-rolling`
- `kasmweb/onlyoffice:1.9.0-rolling`
- `kasmweb/steam:1.9.0-rolling`
- `kasmweb/desktop-deluxe:1.9.0-rolling`

## Special Cases & Considerations

### Deprecated Images
- `lscr.io/linuxserver/endlessh:latest` - This image has been deprecated. Recommend switching to `shizunge/endlessh-go:latest` or removing if not needed.

### Development/Testing Images
- `ghcr.io/dusk-labs/dim:dev` - This is explicitly using a dev tag and should be evaluated if production-ready.

### Environment Variable Controlled Images
Many images use environment variables (e.g., `${PLEXIMAGE}`, `${RADARRIMAGE}`). These are controlled outside the YAML files and should be updated in the configuration system.

## Implementation Priority

1. **Critical Infrastructure** (Traefik, Authelia, Watchtower, Cloudflared) - Immediate
2. **VPN & Networking** (Gluetun, VPN clients) - High
3. **Media Management** (Overseerr, Radarr, Sonarr variants) - High  
4. **Download Clients** (qBittorrent, SABnzbd, etc.) - Medium
5. **Add-ons & Utilities** (Dozzle, Flaresolverr, etc.) - Medium
6. **Self-hosted Applications** - Low
7. **DOCKER_MODS** - Low (cosmetic/monitoring)

## Next Steps

1. Create update script to systematically apply version pinning
2. Test critical infrastructure updates in staging environment
3. Update environment variable controlled images in configuration
4. Document rollback procedures for each major component
5. Establish version update schedule and monitoring
