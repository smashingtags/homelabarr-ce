# HomelabARR CLI Docker Version Pinning Implementation Guide

## Overview

This guide provides step-by-step instructions for implementing Docker image version pinning in the HomelabARR CLI project to replace `:latest` tags with specific stable versions.

## Prerequisites

- Python 3.6+ installed
- Access to HomelabARR CLI repository
- Backup of current configuration (recommended)
- Testing environment (highly recommended)

## Quick Start

### 1. Review the Analysis
First, examine the comprehensive analysis:
```bash
cat docker-version-pinning-analysis.md
```

### 2. Test the Update Script (Dry Run)
```bash
python update_docker_versions.py --dry-run
```

### 3. Apply Updates by Priority

#### Critical Infrastructure First (Recommended)
```bash
python update_docker_versions.py --priority=high --backup
```

#### Medium Priority Applications
```bash
python update_docker_versions.py --priority=medium --backup
```

#### Low Priority Applications
```bash
python update_docker_versions.py --priority=low --backup
```

#### All at Once (Advanced Users)
```bash
python update_docker_versions.py --backup
```

## Detailed Implementation Steps

### Phase 1: Critical Infrastructure (High Priority)
These components are essential for HomelabARR CLI operation:

```bash
# Dry run to see what will change
python update_docker_versions.py --priority=high --dry-run

# Apply changes with backup
python update_docker_versions.py --priority=high --backup
```

**Affected Components:**
- Heimdall (Dashboard)
- Watchtower (Container Updates)
- Cloudflared (Cloudflare Tunnel)
- Uptime Kuma (Monitoring)
- Netdata (System Monitoring)
- Gluetun (VPN)
- Overseerr (Media Requests)
- Duplicati (Backup)
- Core Databases (MongoDB, MariaDB)

**Testing After Phase 1:**
1. Verify Traefik dashboard access
2. Check Heimdall dashboard
3. Test Overseerr functionality
4. Verify VPN connectivity (if using Gluetun)
5. Confirm backup services are running

### Phase 2: Media & Download Applications (Medium Priority)

```bash
python update_docker_versions.py --priority=medium --backup
```

**Affected Components:**
- Download Clients (qBittorrent VPN, Tubesync, etc.)
- Encoder Applications (Unmanic, HandBrake, MakeMKV)
- Monitoring Tools (Dozzle, FlareSolverr)
- UI Dashboards (Dashy, Flame)

**Testing After Phase 2:**
1. Test download clients functionality
2. Verify encoder applications work
3. Check monitoring dashboards
4. Test media request workflows

### Phase 3: Self-hosted & Utilities (Low Priority)

```bash
python update_docker_versions.py --priority=low --backup
```

**Affected Components:**
- Development tools (Code Server, Cloud9)
- File managers and sharing tools
- Communication tools (Ferdi, etc.)
- Various utilities and add-ons

## Environment Variable Controlled Images

Some images are controlled by environment variables and need to be updated in the configuration system:

### Critical Images Using Environment Variables:
- `${PLEXIMAGE}` - Plex Media Server
- `${RADARRIMAGE}` - Radarr (Movies)
- `${SONARRIMAGE}` - Sonarr (TV Shows)
- `${LIDARRIMAGE}` - Lidarr (Music)
- `${BAZARRIMAGE}` - Bazarr (Subtitles)
- `${PROWLARRIMAGE}` - Prowlarr (Indexer)
- `${TAUTULLIIMAGE}` - Tautulli (Plex Stats)
- `${JACKETTIMAGE}` - Jackett
- `${QBITORRENTIMAGE}` - qBittorrent
- `${SABNZBDIMAGE}` - SABnzbd
- `${NZBGETIMAGE}` - NZBGet
- `${DELUGEIMAGE}` - Deluge

### Recommended Environment Variable Values:
```bash
# Core Media Management (Servarr Stack)
PLEXIMAGE="lscr.io/linuxserver/plex:version-1.40.5.8854"
RADARRIMAGE="lscr.io/linuxserver/radarr:version-5.14.0.9283"
SONARRIMAGE="lscr.io/linuxserver/sonarr:version-4.0.11.2680"
LIDARRIMAGE="lscr.io/linuxserver/lidarr:version-2.8.2.4493"
BAZARRIMAGE="lscr.io/linuxserver/bazarr:version-1.4.5"
PROWLARRIMAGE="lscr.io/linuxserver/prowlarr:version-1.28.2.4885"
TAUTULLIIMAGE="lscr.io/linuxserver/tautulli:version-2.15.0"

# Download Clients
JACKETTIMAGE="lscr.io/linuxserver/jackett:version-0.22.1073"
QBITORRENTIMAGE="lscr.io/linuxserver/qbittorrent:version-5.0.2"
SABNZBDIMAGE="lscr.io/linuxserver/sabnzbd:version-4.3.3"
NZBGETIMAGE="lscr.io/linuxserver/nzbget:version-24.5"
DELUGEIMAGE="lscr.io/linuxserver/deluge:version-2.1.1"

# Media Servers
JELLYFINIMAGE="lscr.io/linuxserver/jellyfin:version-10.10.3"
EMBYIMAGE="lscr.io/linuxserver/emby:version-4.8.10.0"

# Other Applications
CALIBREIMAGE="lscr.io/linuxserver/calibre-web:version-0.6.23"
KOMGAIMAGE="lscr.io/linuxserver/komga:version-1.14.0"
FENRUSIMAGE="lscr.io/linuxserver/fenrus:version-0.1.20"
LAZYLIBRARIANIMAGE="lscr.io/linuxserver/lazylibrarian:version-1.7.21"
READARRIMAGE="lscr.io/linuxserver/readarr:version-0.4.4.2697"
WEBTOP_IMAGE="lscr.io/linuxserver/webtop:ubuntu-mate-version-24.04-20241205"
PIHOLEIMAGE="pihole/pihole:2025.01.0"
```

## Testing Checklist

### Before Implementation:
- [ ] Create full backup of configuration
- [ ] Document current working state
- [ ] Prepare rollback plan
- [ ] Test in staging environment (if available)

### During Implementation:
- [ ] Monitor application logs for errors
- [ ] Check container health status
- [ ] Verify network connectivity
- [ ] Test core functionality of each updated service

### After Implementation:
- [ ] Verify all services are running
- [ ] Test media streaming functionality
- [ ] Check download client operations
- [ ] Validate backup processes
- [ ] Test web interfaces and dashboards
- [ ] Verify VPN functionality (if used)
- [ ] Check notification systems
- [ ] Test media request workflows

## Troubleshooting

### Common Issues and Solutions:

#### Container Won't Start After Update
```bash
# Check logs
docker logs [container_name]

# Revert to previous version
# Restore from backup or manually edit YAML file
```

#### Version Not Found
```bash
# Check available tags on Docker Hub or GHCR
docker search [image_name]

# Or use a slightly older stable version
```

#### Performance Issues
```bash
# Monitor system resources
docker stats

# Check for resource constraints in docker-compose files
```

### Rollback Procedure:
1. Stop affected containers: `docker-compose down`
2. Restore backup files: `mv file.yml.backup_[timestamp] file.yml`
3. Restart services: `docker-compose up -d`

## Best Practices

### Version Management:
1. **Pin to specific versions** rather than using `:latest`
2. **Test updates in staging** before production
3. **Update incrementally** by priority level
4. **Monitor for security updates** regularly
5. **Document version choices** and upgrade paths

### Maintenance Schedule:
- **Monthly**: Check for security updates on critical components
- **Quarterly**: Review and update media management applications
- **Semi-annually**: Full review of all container versions
- **As needed**: Update when new features are required

### Version Selection Criteria:
1. **Stability**: Choose stable/LTS releases over bleeding edge
2. **Security**: Prioritize versions with security fixes
3. **Compatibility**: Ensure versions work with your data/configs
4. **Community**: Use versions with good community support
5. **Documentation**: Choose well-documented releases

## Monitoring and Maintenance

### Automated Monitoring:
Consider using tools to monitor for updates:
- **Watchtower**: For automatic updates (use cautiously)
- **Diun**: For update notifications only
- **Security scanners**: For vulnerability detection

### Manual Checks:
- Review release notes before updating
- Check GitHub issues for known problems
- Test in staging before production updates

## Special Considerations

### Deprecated Images:
- `lscr.io/linuxserver/endlessh:latest` has been deprecated
- Consider switching to `shizunge/endlessh-go:latest` or removing

### Development Images:
- `ghcr.io/dusk-labs/dim:dev` is using a development tag
- Evaluate if ready for production use

### Custom HomelabARR CLI Images:
Some images are maintained by the HomelabARR CLI project:
- `ghcr.io/smashingtags/homelabarr-cli/docker-*` images
- Check HomelabARR CLI releases for version information

## Support and Resources

### Documentation:
- [Docker Version Pinning Analysis](./docker-version-pinning-analysis.md)
- [LinuxServer.io Documentation](https://docs.linuxserver.io/)
- [Docker Hub](https://hub.docker.com/)
- [GitHub Container Registry](https://ghcr.io/)

### Community:
- HomelabARR CLI Discord/GitHub for project-specific issues
- LinuxServer.io Discord for LinuxServer image issues
- Application-specific communities for software problems

## Conclusion

Version pinning improves stability and predictability but requires ongoing maintenance. Start with critical infrastructure, test thoroughly, and maintain a regular update schedule for optimal results.
