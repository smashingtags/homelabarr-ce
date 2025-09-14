# Container Registry Status - HomelabARR CLI

## ✅ Current Container Registry: ghcr.io/smashingtags

All HomelabARR containers are published under the `smashingtags` GitHub Container Registry.

## 📦 Published Containers

### Production Containers
| Container | Registry URL | Status | Downloads |
|-----------|-------------|--------|-----------|
| **container-port-manager** | `ghcr.io/smashingtags/container-port-manager` | ✅ Published | 1.76k |
| **homelabarr-frontend** | `ghcr.io/smashingtags/homelabarr-frontend` | ✅ Published | Active |
| **homelabarr-backend** | `ghcr.io/smashingtags/homelabarr-backend` | ✅ Published | Active |
| **homelabarr-site** | `ghcr.io/smashingtags/homelabarr-site` | ✅ Published | Active |
| **local-persist** | `ghcr.io/smashingtags/local-persist` | ✅ Published | Active |

### Additional Published Containers
- `ghcr.io/smashingtags/bolt.diy`
- `ghcr.io/smashingtags/n8n-mcp`
- `ghcr.io/smashingtags/n8n-mcp-railway`

## 🔄 Migration Status

### Phase 1: Reference Updates ✅ COMPLETE
- **94 references updated** from `ghcr.io/homelabarr` to `ghcr.io/smashingtags`
- All production YAML files updated
- Documentation references updated
- Template files migrated

### Phase 2: Docker Mods Migration 🔄 IN PROGRESS
Current docker mods that need publishing under smashingtags:
- `homelabarr-mod-healthcheck` → `ghcr.io/smashingtags/homelabarr-mod-healthcheck`
- `docker-mod-qbittorrent` → `ghcr.io/smashingtags/homelabarr-mod-qbittorrent`
- `docker-mod-sabnzbd` → `ghcr.io/smashingtags/homelabarr-mod-sabnzbd`
- `docker-mod-nzbget` → `ghcr.io/smashingtags/homelabarr-mod-nzbget`
- `docker-mod-tautulli` → `ghcr.io/smashingtags/homelabarr-mod-tautulli`

### Phase 3: Third-Party Images
These remain unchanged as they're external:
- LinuxServer.io images (`lscr.io/linuxserver/*`)
- Theme.Park mods (`ghcr.io/themepark-dev/theme.park`)
- Official Docker Hub images

## 📝 Container Reference Standards

### HomelabARR Containers
```yaml
# Pattern for HomelabARR containers
image: ghcr.io/smashingtags/[container-name]:latest

# Example
image: ghcr.io/smashingtags/homelabarr-frontend:latest
```

### Docker Mods
```yaml
# Pattern for HomelabARR docker mods
DOCKER_MODS: ghcr.io/smashingtags/homelabarr-mod-[name]:latest

# Example with multiple mods
DOCKER_MODS: ghcr.io/themepark-dev/theme.park:plex|ghcr.io/smashingtags/homelabarr-mod-healthcheck:latest
```

## 🚀 Deployment Examples

### Local Mode
```yaml
services:
  homelabarr-frontend:
    image: ghcr.io/smashingtags/homelabarr-frontend:latest
    container_name: homelabarr-frontend
    ports:
      - "3000:3000"
    restart: unless-stopped
```

### Production Mode with Traefik
```yaml
services:
  homelabarr-backend:
    image: ghcr.io/smashingtags/homelabarr-backend:latest
    container_name: homelabarr-backend
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.backend.rule=Host(`api.${DOMAIN}`)"
    networks:
      - proxy
    restart: unless-stopped
```

## 📊 Statistics

| Metric | Count |
|--------|-------|
| Total files updated | 94 |
| References migrated | 231 → 137 (94 updated) |
| Published containers | 8 |
| Pending docker mods | 5 |
| Third-party images | 50+ |

## ⚠️ Important Notes

1. **GitHub Username**: `smashingtags` is the official GitHub username
2. **Registry**: All containers use GitHub Container Registry (ghcr.io)
3. **Namespace**: All HomelabARR containers are under `ghcr.io/smashingtags/`
4. **Legacy References**: Some backup files retain old references (intentional)
5. **Third-Party**: LinuxServer and Theme.Park images remain unchanged

## 🔧 Remaining Tasks

1. **Publish Docker Mods** under smashingtags namespace
2. **Update CI/CD** to push to correct registry
3. **Test all containers** with new references
4. **Update documentation** with new container URLs
5. **Create migration guide** for existing users

## 📚 Related Documentation

- [Docker Image Migration Plan](./6_PROJECT_MANAGEMENT/DOCKER_IMAGE_MIGRATION_PLAN.md)
- [Container Standards](./3_ARCHITECTURE/CONTAINER_STANDARDS.md)
- [Deployment Guide](./2_DEPLOYMENT/COMPLETE_GUIDE.md)

---

**Last Updated**: August 19, 2025
**Registry**: ghcr.io/smashingtags
**Status**: Migration 60% Complete