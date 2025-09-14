# HomelabARR CLI Configuration Management

**HL-2**: Container Configuration Modernization and Port Conflict Resolution  
**Version**: 2.3.0

This directory contains configuration management tools and local mode templates for the HomelabARR CLI ecosystem.

## Configuration Management Tools

### Complete Modernization
```bash
# Complete automatic modernization (all steps)
./modernize-configs.sh auto

# Interactive modernization with choices
./modernize-configs.sh interactive

# Preview changes without applying them
./modernize-configs.sh dry-run
```

### Individual Tool Usage
```bash
# Validate all container configurations
./validate-configs.sh

# Fix port conflicts automatically
./fix-port-conflicts.sh auto

# Clean up temporary files
./cleanup-temp-files.sh auto
```

### Interactive Management
```bash
# Interactive port conflict resolution
./fix-port-conflicts.sh interactive

# Interactive cleanup
./cleanup-temp-files.sh interactive

# Dry run to preview changes
./cleanup-temp-files.sh --dry-run
```

## Local Mode Quick Start

1. **Copy environment file:**
   ```bash
   cp .env.example .env
   ```

2. **Edit configuration:**
   ```bash
   nano .env  # Adjust settings as needed
   ```

3. **Deploy with interactive script:**
   ```bash
   chmod +x deploy-local.sh
   ./deploy-local.sh
   ```

## Available Templates

| Template | Port | Access URL | Description |
|----------|------|------------|-------------|
| `plex-local-template.yml` | 32400 | http://localhost:32400 | Plex Media Server |
| `radarr-local-template.yml` | 7878 | http://localhost:7878 | Radarr Movie Manager |
| `qbittorrent-local-template.yml` | 8082 | http://localhost:8082 | qBittorrent Download Client |

## Manual Deployment

Deploy individual services:

```bash
# Plex Media Server
docker compose -f plex-local-template.yml --env-file .env up -d

# Radarr Movie Manager  
docker compose -f radarr-local-template.yml --env-file .env up -d

# qBittorrent Download Client
docker compose -f qbittorrent-local-template.yml --env-file .env up -d
```

## Management Commands

```bash
# Stop a service
docker compose -f plex-local-template.yml down

# View logs
docker compose -f plex-local-template.yml logs -f

# Check status
docker ps --filter "label=dockupdater.enable=true"

# Update containers
docker compose -f plex-local-template.yml pull
docker compose -f plex-local-template.yml up -d
```

## Environment Variables

Key settings in `.env`:

- `ID=1000` - User/Group ID for file permissions
- `TZ=America/New_York` - Your timezone
- `APPFOLDER=/opt/appdata` - Application data directory
- `PLEXTHEME=dark` - UI theme selection

## Network & Storage

- **Network**: `homelabarr-local` bridge network
- **App Data**: `/opt/appdata/` (or as configured)
- **Media**: `/mnt/` via UnionFS volume
- **Ports**: Exposed directly to host system

## Container Standards Compliance

All configurations are validated against the HomelabARR CLI Container Standards:

### Key Requirements
- Health checks for all services
- Resource limits and reservations
- Security options and user mapping
- Traefik integration labels
- Port conflict prevention

### Validation Tools
- **modernize-configs.sh**: Complete configuration modernization workflow
- **validate-configs.sh**: Comprehensive YAML validation
- **fix-port-conflicts.sh**: Automated port conflict resolution  
- **cleanup-temp-files.sh**: Temporary file cleanup

### Standards Documentation
📋 **[Container Standards](../../docs/CONTAINER_STANDARDS.md)**

## Full Documentation

For complete setup instructions, troubleshooting, and advanced configuration:

📖 **[Local Mode Documentation](../../wiki/docs/install/local-mode.md)**  
🔧 **[Configuration Management Guide](../../docs/CONTAINER_STANDARDS.md)**
