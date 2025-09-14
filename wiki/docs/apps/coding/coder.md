# Coder Platform - Advanced Cloud Development Environment

## Overview

Coder is a platform for creating and managing cloud development environments (CDEs) with support for various development stacks, remote access, and workspace templates. This implementation provides a complete development environment platform with PostgreSQL database backend and Docker workspace support.

## Features

- **Cloud Development Environments**: Create and manage development workspaces in containers
- **Template System**: Pre-configured workspace templates for various development stacks
- **Web-based IDE Integration**: Support for VS Code, JetBrains IDEs, and terminal access
- **Resource Management**: CPU, memory, and storage allocation per workspace
- **Team Collaboration**: Multi-user support with authentication and authorization
- **Docker Integration**: Direct Docker socket access for container-based workspaces
- **Persistent Storage**: Workspace data persistence across sessions

## Architecture

### Components

- **Coder Server**: Main application server providing the web interface and API
- **PostgreSQL Database**: Stores workspace configurations, user data, and templates
- **Docker Socket**: Access to host Docker daemon for workspace management
- **Traefik Integration**: Reverse proxy with SSL termination and WebSocket support

### Network Configuration

- **Full Mode**: Traefik reverse proxy with SSL (https://coder.${DOMAIN})
- **Local Mode**: Direct port access (http://localhost:7080)
- **Workspace Access**: Dynamic subdomain routing (*.coder.${DOMAIN})

## Installation

### Prerequisites

- Docker and Docker Compose installed
- PostgreSQL database support
- Domain with Cloudflare DNS (for Full Mode)
- Sufficient disk space for workspace storage

### Environment Variables

Add the following to your environment configuration:

```bash
# Database Configuration
CODER_DB_PASSWORD=your_secure_password_here

# Optional: Custom session timeout (default: 24h)
CODER_MAX_SESSION_TTL=24h
```

### Deployment Modes

#### Full Mode (Traefik + SSL)
```bash
# Deploy with Traefik integration
docker compose -f apps/coding/coder.yml up -d
```

#### Local Mode (Direct Access)
```bash
# Deploy for local development
docker compose -f apps/.config/coder-local-template.yml up -d
```

## Configuration

### Initial Setup

1. **Access the Interface**:
   - Full Mode: https://coder.${DOMAIN}
   - Local Mode: http://localhost:7080

2. **Create Initial Admin User**:
   - Follow the setup wizard on first access
   - Configure authentication settings
   - Set organization details

3. **Database Migration**:
   - Database schema is automatically created on first startup
   - Health checks ensure database connectivity

### Workspace Templates

Basic workspace templates are supported through the mounted templates directory:

```
${APPFOLDER}/coder/templates/
├── docker-workspace/     # Docker-based development environment
├── ubuntu-workspace/     # Basic Ubuntu environment
└── custom-templates/     # Custom workspace definitions
```

#### Example Docker Workspace Template

Create a basic Docker workspace template:

```yaml
# Template: docker-workspace
name: "Docker Development Environment"
description: "Ubuntu environment with Docker support"
icon: "/icon/docker.svg"

parameters:
  - name: "cpu"
    description: "CPU allocation"
    default: "2"
  - name: "memory"
    description: "Memory allocation (GB)"
    default: "4"

resources:
  - type: "docker_container"
    name: "workspace"
    image: "ubuntu:22.04"
    cpu: "${data.coder_parameter.cpu.value}"
    memory: "${data.coder_parameter.memory.value}G"
    
    volumes:
      - "/home/coder"
    
    startup_script: |
      #!/bin/bash
      apt-get update
      apt-get install -y curl git wget nano vim
      # Install Docker
      curl -fsSL https://get.docker.com -o get-docker.sh
      sh get-docker.sh
      usermod -aG docker coder
```

## Security Considerations

### Docker Socket Access

The Coder container requires access to the Docker socket for workspace management:

```yaml
volumes:
  - "/var/run/docker.sock:/var/run/docker.sock:rw"
```

**Security Implications**:
- Full Docker daemon access
- Potential container escape risks
- Recommended for isolated environments only

### Network Security

- **Authentication**: Integrated with Authelia in Full Mode
- **SSL/TLS**: Automatic certificate management via Cloudflare
- **WebSocket Security**: Secure workspace connections
- **Database Security**: Isolated PostgreSQL with encrypted connections

### Access Control

```yaml
environment:
  # Disable password authentication (use external auth)
  - "CODER_DISABLE_PASSWORD_AUTH=false"
  
  # Disable workspace exec for security
  - "CODER_DISABLE_OWNER_WORKSPACE_EXEC=false"
  
  # Session timeout for security
  - "CODER_MAX_SESSION_TTL=24h"
```

## Resource Management

### Container Resources

```yaml
# Database resources
deploy:
  resources:
    limits:
      memory: 512M
      cpus: '0.5'
    reservations:
      memory: 256M
      cpus: '0.25'

# Coder server resources
deploy:
  resources:
    limits:
      memory: 1G
      cpus: '1.0'
    reservations:
      memory: 512M
      cpus: '0.5'
```

### Storage Management

```
${APPFOLDER}/coder/
├── config/           # Coder server configuration
├── database/         # PostgreSQL data
├── templates/        # Workspace templates
└── workspaces/       # Workspace persistent data
```

## Health Monitoring

### Health Checks

```yaml
# Database health check
healthcheck:
  test: ["CMD-SHELL", "pg_isready -U coder -d coder"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 60s

# Coder server health check
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:7080/api/v2/buildinfo"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 120s
```

### Monitoring Integration

- **Metrics Endpoint**: `/metrics` (Prometheus compatible)
- **Health Endpoint**: `/api/v2/buildinfo`
- **Log Integration**: Standard Docker logging with JSON format

## API Integration

### REST API

Coder provides a comprehensive REST API for automation:

```bash
# API Base URL
API_BASE="https://coder.${DOMAIN}/api/v2"

# Authentication
curl -X POST "${API_BASE}/users/login" \
  -H "Content-Type: application/json" \
  -d '{"email": "user@domain.com", "password": "password"}'

# List workspaces
curl -H "Authorization: Bearer ${TOKEN}" \
  "${API_BASE}/workspaces"

# Create workspace
curl -X POST -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  "${API_BASE}/organizations/${ORG_ID}/workspaces" \
  -d '{"name": "my-workspace", "template_id": "template-uuid"}'
```

### CLI Integration

```bash
# Install Coder CLI
curl -fsSL https://coder.com/install.sh | sh

# Login to Coder instance
coder login https://coder.${DOMAIN}

# List available templates
coder templates list

# Create workspace from template
coder create my-workspace --template docker-workspace

# SSH into workspace
coder ssh my-workspace
```

## Troubleshooting

### Common Issues

#### Database Connection Errors
```bash
# Check database health
docker exec coder-db pg_isready -U coder -d coder

# View database logs
docker logs coder-db

# Reset database (WARNING: destroys data)
docker volume rm $(docker volume ls -q | grep coder-database)
```

#### Docker Socket Permission Issues
```bash
# Check Docker socket permissions
ls -la /var/run/docker.sock

# Verify container can access Docker
docker exec coder docker ps
```

#### WebSocket Connection Issues
```bash
# Check Traefik logs for WebSocket routing
docker logs traefik | grep coder

# Verify workspace connectivity
curl -H "Upgrade: websocket" \
  -H "Connection: Upgrade" \
  https://workspace-name.coder.${DOMAIN}
```

### Log Analysis

```bash
# Coder server logs
docker logs coder

# Database logs
docker logs coder-db

# Real-time log monitoring
docker logs -f coder
```

### Performance Optimization

#### Database Tuning
```bash
# PostgreSQL configuration optimization
echo "shared_buffers = 128MB" >> ${APPFOLDER}/coder/database/postgresql.conf
echo "effective_cache_size = 512MB" >> ${APPFOLDER}/coder/database/postgresql.conf
echo "max_connections = 100" >> ${APPFOLDER}/coder/database/postgresql.conf
```

#### Resource Allocation
```yaml
# Adjust based on expected workspace count
environment:
  - "CODER_WORKSPACE_SHUTDOWN_TIMEOUT=30m"
  - "CODER_MAX_WORKSPACE_ACTIVITY_BUMP=8h"
```

## Integration Examples

### CI/CD Integration

```yaml
# GitHub Actions example
name: Deploy to Coder Workspace
on: [push]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Deploy to Coder
        run: |
          coder login ${{ secrets.CODER_URL }} --token ${{ secrets.CODER_TOKEN }}
          coder create ci-workspace --template docker-workspace
          coder ssh ci-workspace -- "git clone ${{ github.event.repository.clone_url }}"
```

### Backup Strategy

```bash
#!/bin/bash
# Backup Coder data
docker exec coder-db pg_dump -U coder coder > coder-backup-$(date +%Y%m%d).sql

# Backup workspace data
tar -czf coder-workspaces-$(date +%Y%m%d).tar.gz ${APPFOLDER}/coder/workspaces/

# Backup templates
tar -czf coder-templates-$(date +%Y%m%d).tar.gz ${APPFOLDER}/coder/templates/
```

## Advanced Configuration

### External Authentication

```yaml
environment:
  # OIDC configuration
  - "CODER_OIDC_ISSUER_URL=https://auth.domain.com"
  - "CODER_OIDC_CLIENT_ID=coder-client"
  - "CODER_OIDC_CLIENT_SECRET=${OIDC_CLIENT_SECRET}"
  
  # SAML configuration  
  - "CODER_SAML_ENTITY_ID=coder"
  - "CODER_SAML_SSO_URL=https://saml.domain.com/sso"
```

### High Availability

```yaml
# Multiple Coder instances (requires external load balancer)
services:
  coder-1:
    # ... standard config
  coder-2:
    # ... standard config
    
  coder-lb:
    image: "haproxy:latest"
    # Load balancer configuration
```

## Support and Updates

- **Version**: v2.16.1 (latest stable)
- **Update Strategy**: Rolling updates with database migration support
- **Documentation**: [Official Coder Docs](https://coder.com/docs)
- **Community**: [Coder GitHub](https://github.com/coder/coder)

## Phase 1 Implementation Status

✅ **Completed**:
- PostgreSQL database configuration with persistent storage
- Core Coder platform deployment with proper dependencies
- Traefik integration with SSL and WebSocket support
- Health checks for both database and application
- Full Mode and Local Mode configurations
- Basic security configurations
- Comprehensive documentation

🔄 **Phase 2 Roadmap**:
- Advanced workspace templates (Node.js, Python, Go, etc.)
- GPU support for ML/AI workspaces
- Advanced monitoring and metrics
- Backup automation
- Multi-tenancy configuration
- Performance optimization
