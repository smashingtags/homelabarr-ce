# HomelabARR CLI Container Standards

**Document Version**: 2.3.0  
**HL-2**: Container Configuration Modernization and Port Conflict Resolution  
**Last Updated**: 2025-01-17

## Overview

This document defines the mandatory standards and best practices for all Docker Compose configurations in the HomelabARR CLI ecosystem. These standards ensure consistency, security, and maintainability across 100+ containerized applications.

## Table of Contents

1. [Container Architecture Standards](#container-architecture-standards)
2. [YAML Structure Requirements](#yaml-structure-requirements)
3. [Network Configuration](#network-configuration)
4. [Port Management](#port-management)
5. [Resource Management](#resource-management)
6. [Security Standards](#security-standards)
7. [Health Check Implementation](#health-check-implementation)
8. [Traefik Integration](#traefik-integration)
9. [Volume Management](#volume-management)
10. [Environment Variables](#environment-variables)
11. [Labeling Conventions](#labeling-conventions)
12. [Validation and Testing](#validation-and-testing)

## Container Architecture Standards

### Core Principles

1. **Single Responsibility**: Each container should serve a single purpose
2. **Stateless Design**: Application state should be externalized to volumes
3. **12-Factor Compliance**: Follow 12-factor app methodology where applicable
4. **Security First**: Implement defense-in-depth security practices
5. **Observability**: All containers must be monitorable and debuggable

### Supported Base Images

**Preferred Base Images** (in order of preference):
- LinuxServer.io images (`lscr.io/linuxserver/*`)
- Official application images from Docker Hub
- Community-maintained images with good security track record

**Requirements for Base Images**:
- Regular security updates
- Multi-architecture support (amd64, arm64)
- Proper user/group handling
- Health check support

## YAML Structure Requirements

### Mandatory Top-Level Fields

```yaml
---
services:
  # Service definitions (required)
networks:
  # Network definitions (required)
volumes:
  # Volume definitions (conditional)
```

### Service Definition Template

```yaml
services:
  service-name:
    hostname: "service-name"                    # REQUIRED
    container_name: "service-name"              # REQUIRED
    image: "${IMAGE_VAR}:${VERSION_VAR}"        # REQUIRED
    restart: "${RESTARTAPP}"                    # REQUIRED
    
    # Health Check (REQUIRED for all services)
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:PORT/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s
    
    # Resource Management (REQUIRED)
    deploy:
      resources:
        limits:
          memory: 1G
          cpus: '0.5'
        reservations:
          memory: 512M
          cpus: '0.25'
    
    # Network Configuration (REQUIRED)
    networks:
      - ${DOCKERNETWORK}
    
    # Security Context (REQUIRED)
    security_opt:
      - "${SECURITYOPS}:${SECURITYOPSSET}"
    
    # Environment Variables (REQUIRED)
    environment:
      - "PGID=${ID}"
      - "PUID=${ID}"
      - "TZ=${TZ}"
      - "UMASK=${UMASK}"
    
    # Volume Management
    volumes:
      - "/etc/localtime:/etc/localtime:ro"
      - "${APPFOLDER}/service:/config:rw"
    
    # Traefik Labels (REQUIRED for web services)
    labels:
      - "traefik.enable=true"
      - "traefik.docker.network=proxy"
      - "dockupdater.enable=true"
      # Additional Traefik configuration...
```

### Field Validation Rules

| Field | Requirement | Format | Notes |
|-------|-------------|--------|-------|
| `hostname` | REQUIRED | Lowercase, hyphen-separated | Must match container name |
| `container_name` | REQUIRED | Lowercase, hyphen-separated | Must be unique across stack |
| `image` | REQUIRED | `${VAR}:${VERSION}` or pinned version | No `:latest` tags |
| `restart` | REQUIRED | `${RESTARTAPP}` | Use variable for consistency |
| `healthcheck` | REQUIRED | Valid health check definition | See Health Check section |
| `deploy.resources` | REQUIRED | Memory and CPU limits | See Resource Management |
| `networks` | REQUIRED | `${DOCKERNETWORK}` | Must use proxy network |
| `security_opt` | REQUIRED | Security options array | AppArmor/SELinux configuration |
| `environment` | REQUIRED | Include PUID, PGID, TZ, UMASK | See Environment Variables |

## Network Configuration

### Standard Network Architecture

All containers **MUST** use the `proxy` bridge network:

```yaml
networks:
  proxy:
    driver: bridge
    external: true
```

### Service Network Configuration

```yaml
services:
  service-name:
    networks:
      - ${DOCKERNETWORK}  # Always use variable
```

### Network Security Rules

1. **No Host Networking**: Never use `network_mode: host`
2. **Bridge Only**: Use bridge networks exclusively
3. **Proxy Network**: All web services must be on proxy network
4. **Internal Communication**: Services communicate via container names
5. **Port Exposure**: Minimize exposed ports to host

## Port Management

### Port Assignment Strategy

**Port Ranges**:
- **1-1023**: Reserved system ports (never use)
- **1024-9999**: Standard application ports (preserve where possible)
- **10000-19999**: User-assigned ports (automatic assignment)
- **20000-29999**: Extended range (overflow)
- **30000+**: Reserved for special services

### Standard Application Ports

| Application | Standard Port | Category |
|-------------|---------------|----------|
| Plex | 32400 | Media Server |
| Jellyfin | 8096 | Media Server |
| Emby | 8096 | Media Server |
| Radarr | 7878 | Media Manager |
| Sonarr | 8989 | Media Manager |
| Lidarr | 8686 | Media Manager |
| Bazarr | 6767 | Media Manager |
| Prowlarr | 9696 | Media Manager |
| qBittorrent | 8080 | Download Client |
| SABnzbd | 8080 | Download Client |
| Jackett | 9117 | Indexer |
| Tautulli | 8181 | Monitoring |
| Overseerr | 5055 | Request System |
| Grafana | 3000 | Monitoring |
| Prometheus | 9090 | Monitoring |

### Port Conflict Resolution

**Automatic Resolution Strategy**:
1. Preserve standard ports for primary applications
2. Assign new ports from user range (10000+) for conflicts
3. Update both exposed ports and Traefik service ports
4. Maintain port registry for conflict tracking

**Port Configuration Examples**:

```yaml
# Exposed port (host:container)
ports:
  - "8080:8080/tcp"

# Traefik service port
labels:
  - "traefik.http.services.app-svc.loadbalancer.server.port=8080"

# Container environment port
environment:
  - "WEBUI_PORT=8080"
```

## Resource Management

### Memory Allocation Guidelines

| Application Category | Memory Limit | Memory Reservation | Notes |
|---------------------|--------------|-------------------|-------|
| Media Servers | 2-4GB | 1-2GB | Transcoding workloads |
| Media Managers | 512MB-1GB | 256-512MB | API processing |
| Download Clients | 1-2GB | 512MB-1GB | Variable based on activity |
| Monitoring | 256-512MB | 128-256MB | Lightweight services |
| Utilities | 128-256MB | 64-128MB | Basic functionality |

### CPU Allocation Guidelines

| Application Category | CPU Limit | CPU Reservation | Notes |
|---------------------|-----------|-----------------|-------|
| Media Servers | 2.0 cores | 1.0 core | Transcoding capability |
| Media Managers | 0.5 cores | 0.25 cores | API processing |
| Download Clients | 1.0 core | 0.5 cores | Network intensive |
| Monitoring | 0.2 cores | 0.1 cores | Background processing |
| Utilities | 0.1 cores | 0.05 cores | Minimal CPU usage |

### Resource Configuration Template

```yaml
deploy:
  resources:
    limits:
      memory: 1G          # Maximum memory usage
      cpus: '0.5'         # Maximum CPU cores (string format)
    reservations:
      memory: 512M        # Guaranteed memory
      cpus: '0.25'        # Guaranteed CPU cores
  restart_policy:
    condition: on-failure
    delay: 5s
    max_attempts: 3
    window: 120s
```

## Security Standards

### User and Group Mapping

**REQUIRED Environment Variables**:
```yaml
environment:
  - "PUID=${ID}"      # User ID (typically 1000)
  - "PGID=${ID}"      # Group ID (typically 1000)
  - "UMASK=${UMASK}"  # File creation mask (typically 002)
```

### Security Options

**REQUIRED Security Configuration**:
```yaml
security_opt:
  - "${SECURITYOPS}:${SECURITYOPSSET}"  # AppArmor/SELinux
  - "no-new-privileges:true"             # Prevent privilege escalation
```

### Capability Management

**For containers requiring minimal privileges**:
```yaml
cap_drop:
  - ALL
cap_add:
  - CHOWN      # File ownership changes
  - SETUID     # User ID changes
  - SETGID     # Group ID changes
```

### Read-Only Filesystem

**Where applicable**:
```yaml
read_only: true
tmpfs:
  - /tmp:rw,noexec,nosuid,size=100m
  - /var/tmp:rw,noexec,nosuid,size=50m
```

### Network Security

1. **No Privileged Mode**: Never use `privileged: true`
2. **No Host Network**: Avoid `network_mode: host`
3. **Minimal Port Exposure**: Only expose necessary ports
4. **Internal Communication**: Use container names for service communication

## Health Check Implementation

### Health Check Requirements

**ALL services MUST implement health checks**:

```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
  interval: 30s      # Check every 30 seconds
  timeout: 10s       # Timeout after 10 seconds
  retries: 3         # Retry 3 times before marking unhealthy
  start_period: 60s  # Grace period for startup
```

### Health Check Patterns by Service Type

**Web Applications**:
```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:8080/api/health"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 60s
```

**Database Services**:
```yaml
healthcheck:
  test: ["CMD", "pg_isready", "-U", "user", "-d", "database"]
  interval: 30s
  timeout: 5s
  retries: 3
  start_period: 30s
```

**File-based Services**:
```yaml
healthcheck:
  test: ["CMD", "test", "-f", "/app/ready"]
  interval: 30s
  timeout: 5s
  retries: 3
  start_period: 10s
```

**Custom Health Checks**:
```yaml
healthcheck:
  test: ["CMD", "/scripts/health-check.sh"]
  interval: 30s
  timeout: 15s
  retries: 3
  start_period: 45s
```

### Health Check Best Practices

1. **Lightweight Checks**: Keep health checks simple and fast
2. **Dependency Awareness**: Check critical dependencies
3. **Appropriate Timeouts**: Balance responsiveness with reliability
4. **Graceful Startup**: Allow sufficient startup time
5. **Meaningful Tests**: Verify actual service functionality

## Traefik Integration

### Required Traefik Labels

**ALL web services MUST include**:

```yaml
labels:
  # Basic Traefik configuration
  - "traefik.enable=true"
  - "traefik.docker.network=proxy"
  - "dockupdater.enable=true"
  
  # Router configuration
  - "traefik.http.routers.service-rtr.entrypoints=https"
  - "traefik.http.routers.service-rtr.rule=Host(`service.${DOMAIN}`)"
  - "traefik.http.routers.service-rtr.tls=true"
  - "traefik.http.routers.service-rtr.tls.certresolver=dns-cloudflare"
  
  # Authentication (required for most services)
  - "traefik.http.routers.service-rtr.middlewares=chain-authelia@file"
  
  # Service configuration
  - "traefik.http.routers.service-rtr.service=service-svc"
  - "traefik.http.services.service-svc.loadbalancer.server.port=8080"
```

### Public Services (No Authentication)

**For services that should be publicly accessible**:
```yaml
labels:
  # Remove authentication middleware
  - "traefik.http.routers.service-rtr.middlewares=chain-no-auth@file"
```

### Multiple Port Services

**For services exposing multiple ports**:
```yaml
labels:
  # Web interface
  - "traefik.http.routers.service-web-rtr.rule=Host(`service.${DOMAIN}`)"
  - "traefik.http.routers.service-web-rtr.service=service-web-svc"
  - "traefik.http.services.service-web-svc.loadbalancer.server.port=8080"
  
  # API interface
  - "traefik.http.routers.service-api-rtr.rule=Host(`api.${DOMAIN}`)"
  - "traefik.http.routers.service-api-rtr.service=service-api-svc"
  - "traefik.http.services.service-api-svc.loadbalancer.server.port=8081"
```

### TCP Services (Non-HTTP)

**For TCP services**:
```yaml
labels:
  - "traefik.tcp.routers.service-tcp.rule=HostSNI(`service.${DOMAIN}`)"
  - "traefik.tcp.routers.service-tcp.service=service-tcp-svc"
  - "traefik.tcp.services.service-tcp-svc.loadbalancer.server.port=5432"
```

## Volume Management

### Volume Types and Usage

**Configuration Volumes** (Read-Write):
```yaml
volumes:
  - "${APPFOLDER}/service:/config:rw"
```

**Data Volumes** (Persistent Storage):
```yaml
volumes:
  - "service-data:/data:rw"

volumes:
  service-data:
    driver: local-persist
    driver_opts:
      mountpoint: /opt/appdata/service/data
```

**Media Volumes** (Read-Only):
```yaml
volumes:
  - "unionfs:/mnt:ro"

volumes:
  unionfs:
    driver: local-persist
    driver_opts:
      mountpoint: /mnt
```

**Temporary/Cache Volumes**:
```yaml
volumes:
  - "/tmp/service-cache:/cache:rw"
```

### Volume Security

1. **Minimal Permissions**: Use `:ro` where possible
2. **Proper Ownership**: Ensure correct PUID/PGID mapping
3. **No Host Mounts**: Avoid mounting sensitive host directories
4. **Backup Considerations**: Ensure volumes are included in backup strategy

### Standard Volume Mapping

| Purpose | Host Path | Container Path | Mode | Notes |
|---------|-----------|----------------|------|-------|
| Configuration | `${APPFOLDER}/service` | `/config` | rw | Service configuration |
| Application Data | Named volume | `/data` | rw | Persistent data |
| Media Library | `unionfs` | `/mnt` | ro | Media content |
| Logs | `${APPFOLDER}/service/logs` | `/logs` | rw | Application logs |
| Cache | `/tmp/service` | `/cache` | rw | Temporary files |
| Timezone | `/etc/localtime` | `/etc/localtime` | ro | System timezone |

## Environment Variables

### Required Environment Variables

**ALL services MUST include**:
```yaml
environment:
  - "PUID=${ID}"          # User ID for file ownership
  - "PGID=${ID}"          # Group ID for file ownership  
  - "TZ=${TZ}"            # Timezone configuration
  - "UMASK=${UMASK}"      # File creation mask
```

### Standard Environment Variables

| Variable | Purpose | Example Value | Required |
|----------|---------|---------------|----------|
| `PUID` | User ID | `1000` | Yes |
| `PGID` | Group ID | `1000` | Yes |
| `TZ` | Timezone | `America/New_York` | Yes |
| `UMASK` | File mask | `002` | Yes |
| `WEBUI_PORT` | Web interface port | `8080` | Conditional |
| `VERSION` | Application version | `latest` | Recommended |

### Application-Specific Variables

**Media Servers**:
```yaml
environment:
  - "PLEX_CLAIM=${PLEX_CLAIM}"
  - "ADVERTISE_IP=http://plex.${DOMAIN}:443"
  - "VERSION=${PLEXVERSION}"
```

**Servarr Applications**:
```yaml
environment:
  - "DOCKER_MODS=ghcr.io/themepark-dev/theme.park:radarr"
  - "TP_THEME=${RADARRTHEME}"
```

### Environment Variable Best Practices

1. **Use Variables**: Reference shell variables where possible
2. **Default Values**: Provide sensible defaults
3. **Security**: Never hardcode sensitive values
4. **Documentation**: Document custom variables
5. **Validation**: Validate required variables at startup

## Labeling Conventions

### Required Labels

**ALL containers MUST include**:
```yaml
labels:
  - "traefik.enable=true"               # Enable Traefik routing
  - "traefik.docker.network=proxy"      # Specify network
  - "dockupdater.enable=true"           # Enable auto-updates
```

### Optional but Recommended Labels

**Monitoring and Management**:
```yaml
labels:
  - "backup.enable=true"                # Enable backup
  - "backup.schedule=0 2 * * *"         # Backup schedule
  - "backup.retention=7d"               # Backup retention
  - "monitoring.enable=true"            # Enable monitoring
  - "logging.driver=json-file"          # Logging configuration
```

**Categorization**:
```yaml
labels:
  - "homelabarr.category=mediaserver"   # Application category
  - "homelabarr.version=2.3.0"         # Configuration version
  - "homelabarr.maintainer=team"       # Maintainer information
```

### Label Naming Convention

- Use lowercase with dots as separators
- Follow pattern: `service.category.property`
- Keep labels concise and meaningful
- Use consistent values across similar services

## Validation and Testing

### Configuration Validation

**Use the validation script**:
```bash
./apps/.config/validate-configs.sh
```

**Validation includes**:
- YAML syntax validation
- Required field verification
- Security configuration check
- Resource limit validation
- Health check presence
- Port conflict detection

### Port Conflict Resolution

**Use the port resolution tool**:
```bash
./apps/.config/fix-port-conflicts.sh auto
```

**Resolution modes**:
- `auto`: Automatic conflict resolution
- `interactive`: Manual conflict resolution
- `detect-only`: Detection without changes

### Testing Checklist

**Before Deployment**:
- [ ] YAML syntax is valid
- [ ] All required fields are present
- [ ] Health checks are implemented
- [ ] Resource limits are configured
- [ ] Security options are set
- [ ] Traefik labels are correct
- [ ] No port conflicts exist
- [ ] Environment variables are set

**After Deployment**:
- [ ] Container starts successfully
- [ ] Health checks pass
- [ ] Service is accessible via Traefik
- [ ] Authentication works correctly
- [ ] Resource usage is within limits
- [ ] Logs are clean
- [ ] Backup processes work
- [ ] Monitoring metrics are collected

### Continuous Validation

**Automated Checks**:
1. Run validation script in CI/CD pipeline
2. Monitor container health status
3. Track resource usage metrics
4. Validate Traefik routing
5. Check security compliance

## Migration Guide

### Upgrading Existing Configurations

**Step 1: Backup Existing Configurations**
```bash
mkdir -p /tmp/config-backup
cp -r apps/ /tmp/config-backup/
```

**Step 2: Run Validation**
```bash
./apps/.config/validate-configs.sh
```

**Step 3: Fix Issues**
```bash
# Fix port conflicts
./apps/.config/fix-port-conflicts.sh auto

# Clean up temporary files
./apps/.config/cleanup-temp-files.sh
```

**Step 4: Test Changes**
```bash
# Test individual services
docker-compose -f apps/mediaserver/plex.yml config

# Test full stack
docker-compose config
```

### Common Migration Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| Port conflicts | Multiple services using same port | Use port resolution tool |
| Missing health checks | Legacy configurations | Add appropriate health check |
| Resource limits | Missing deploy section | Add resource configuration |
| Security options | Missing security_opt | Add security configuration |
| Traefik labels | Outdated or missing labels | Update to current standard |

## Best Practices Summary

### Configuration Management
1. Use variables for all configurable values
2. Implement comprehensive health checks
3. Configure appropriate resource limits
4. Follow security best practices
5. Use consistent labeling

### Security
1. Never run containers as root
2. Use proper user/group mapping
3. Implement security options
4. Minimize exposed ports
5. Use read-only volumes where possible

### Monitoring
1. Implement health checks for all services
2. Configure proper logging
3. Set up resource monitoring
4. Enable backup automation
5. Track security compliance

### Maintenance
1. Regularly validate configurations
2. Monitor for port conflicts
3. Update to latest standards
4. Test changes before deployment
5. Maintain documentation

## Support and Resources

### Tools and Scripts
- Configuration validation: `./apps/.config/validate-configs.sh`
- Port conflict resolution: `./apps/.config/fix-port-conflicts.sh`
- Cleanup utilities: `./apps/.config/cleanup-temp-files.sh`

### Documentation
- [HomelabARR CLI Documentation](../wiki/docs/)
- [Docker Compose Reference](https://docs.docker.com/compose/)
- [Traefik Documentation](https://doc.traefik.io/traefik/)

### Community
- [GitHub Issues](https://github.com/HomelabarrCli/HomelabarrCli/issues)
- [Community Forums](https://homelabarr-cli.io/discord)
- [Development Guidelines](CONTRIBUTING.md)

---

**Note**: This document is part of HL-2: Container Configuration Modernization and Port Conflict Resolution. All configurations must comply with these standards to ensure proper functionality within the HomelabARR CLI ecosystem.
