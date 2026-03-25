# Coder Platform - HomelabARR CLI Integration

## Quick Start

### Prerequisites
1. Set required environment variables in your `.env` file:
```bash
# Required: PostgreSQL password for Coder database
CODER_DB_PASSWORD=your_secure_password_here

# Optional: Custom session timeout (default: 24h)
CODER_MAX_SESSION_TTL=24h
```

### Deployment Options

#### Full Mode (Production with Traefik + SSL)
```bash
# Deploy with reverse proxy and SSL
docker compose -f apps/coding/coder.yml up -d

# Access: https://coder.${DOMAIN}
```

#### Local Mode (Development/Testing)
```bash
# Deploy for local access
docker compose -f apps/.config/coder-local-template.yml up -d

# Access: http://localhost:7080
```

### Initial Setup
1. Access the web interface (URL depends on deployment mode)
2. Create your first admin user account
3. Complete the setup wizard
4. Start creating workspaces from available templates

## Available Workspace Templates

### 1. Docker Development Environment (`docker-workspace.tf`)
- **Base**: Ubuntu 22.04
- **Includes**: Docker, Docker Compose, Node.js, Python, Go, VS Code Server
- **Best for**: Full containerized development workflows
- **Resources**: 2-8 CPU cores, 4-16GB RAM configurable

### 2. Ubuntu Workspace (`ubuntu-workspace.tf`)
- **Base**: Ubuntu 22.04
- **Variants**: 
  - Basic (git, vim, basic tools)
  - Python (Python 3, pip, venv, common packages)
  - Node.js (Node.js LTS, npm, yarn, frameworks)
  - Full Stack (Python + Node.js + Go + additional tools)
- **Resources**: 1-4 CPU cores, 2-8GB RAM configurable

## Security Considerations

⚠️ **Important**: This deployment requires Docker socket access (`/var/run/docker.sock`) for workspace management. This provides full Docker daemon access and should only be used in trusted environments.

### Security Features
- PostgreSQL database with persistent storage
- Traefik integration with SSL/TLS encryption
- Authelia authentication (Full Mode)
- Health monitoring and container isolation
- Configurable session timeouts

## Directory Structure
```
${APPFOLDER}/coder/
├── config/           # Coder server configuration
├── database/         # PostgreSQL persistent data
├── templates/        # Workspace templates (Terraform)
└── workspaces/       # Workspace persistent storage
```

## Monitoring & Health Checks

### Health Endpoints
- **Database**: `pg_isready -U coder -d coder`
- **Coder Server**: `http://localhost:7080/api/v2/buildinfo`

### Container Resources
- **Database**: 512M memory limit, 256M reserved
- **Coder Server**: 1G memory limit, 512M reserved

## Troubleshooting

### Common Issues

#### Database Connection Errors
```bash
# Check database health
docker exec coder-db pg_isready -U coder -d coder

# View logs
docker logs coder-db
docker logs coder
```

#### Docker Socket Permission Issues
```bash
# Verify Docker socket access
docker exec coder docker ps

# Check socket permissions
ls -la /var/run/docker.sock
```

#### WebSocket Connection Issues (Full Mode)
```bash
# Check Traefik routing
docker logs traefik | grep coder

# Verify wildcard certificate
curl -I https://test.coder.${DOMAIN}
```

### Performance Tuning

#### For High Workspace Count
```bash
# Increase PostgreSQL connections
echo "max_connections = 200" >> ${APPFOLDER}/coder/database/postgresql.conf
docker restart coder-db
```

#### For Resource-Intensive Workspaces
```yaml
# Adjust container limits in compose file
deploy:
  resources:
    limits:
      memory: 2G
      cpus: '2.0'
```

## API Access

### REST API
```bash
# Login and get token
curl -X POST "https://coder.${DOMAIN}/api/v2/users/login" \
  -H "Content-Type: application/json" \
  -d '{"email": "user@domain.com", "password": "password"}'

# List workspaces
curl -H "Authorization: Bearer ${TOKEN}" \
  "https://coder.${DOMAIN}/api/v2/workspaces"
```

### CLI Installation
```bash
# Install Coder CLI
curl -fsSL https://coder.com/install.sh | sh

# Login to instance
coder login https://coder.${DOMAIN}
```

## Next Steps (Phase 2)

- [ ] Advanced workspace templates (specialized development stacks)
- [ ] GPU support for ML/AI workspaces
- [ ] Advanced monitoring and metrics integration
- [ ] Automated backup and disaster recovery
- [ ] Multi-tenancy and organization management
- [ ] Integration with external authentication providers

## Support

- **Documentation**: See `wiki/docs/apps/coding/coder.md` for comprehensive guide
- **Official Docs**: [Coder Documentation](https://coder.com/docs)
- **GitHub**: [Coder Repository](https://github.com/coder/coder)
- **Version**: v2.16.1 (latest stable)
