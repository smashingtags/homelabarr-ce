# Mount Enhanced - Technical Implementation Details

## 📦 Component Files Overview

### Core Configuration Files
- **docker-compose.yml** - Docker orchestration configuration
- **Dockerfile** - Container build instructions
- **package.json** - Node.js dependencies and scripts
- **.env.template** - Environment variable template

### Documentation Files
- **README.md** - Main project documentation
- **installation-guide.md** - Detailed setup instructions
- **evolution-strategy.md** - Development roadmap
- **CHERRY_PICK_SUMMARY.md** - Integration tracking

### Server Templates (90 files)
Complete Docker compose templates for HomelabARR applications in `server/templates/`

## 🐳 Docker Implementation

### docker-compose.yml Structure
```yaml
services:
  homelabarr-mount-enhanced:
    build:
      context: .
      dockerfile: Dockerfile
      args:
        BUILD_DATE: ${BUILD_DATE:-}
        VERSION: ${VERSION:-2.0.0-mvp}
    
    container_name: homelabarr-mount-enhanced
    hostname: mount-enhanced
    restart: unless-stopped
    
    environment:
      # Standard HomelabARR variables
      - PUID=${ID:-1000}
      - PGID=${ID:-1000}
      - TZ=${TZ:-UTC}
      - UMASK=${UMASK:-002}
      
      # Enhanced features
      - ENHANCED_MODE=${ENHANCED_MODE:-true}
      - MULTI_PROVIDER=${MULTI_PROVIDER:-true}
      - COST_TRACKING=${COST_TRACKING:-true}
      
      # Provider configuration
      - GDRIVE_ENABLED=${GDRIVE_ENABLED:-true}
      - BACKBLAZE_ENABLED=${BACKBLAZE_ENABLED:-false}
      - ONEDRIVE_ENABLED=${ONEDRIVE_ENABLED:-false}
      - PCLOUD_ENABLED=${PCLOUD_ENABLED:-false}
    
    volumes:
      - ./config:/config
      - ./data:/data
      - ./logs:/logs
      - /mnt/cloud:/mnt/cloud
      - /var/run/docker.sock:/var/run/docker.sock:ro
    
    ports:
      - "${WEB_PORT:-8190}:8190"
      - "${API_PORT:-3000}:3000"
    
    networks:
      - homelabarr
```

### Dockerfile Configuration
```dockerfile
FROM node:18-alpine
WORKDIR /app

# Install system dependencies
RUN apk add --no-cache \
    rclone \
    fuse \
    ca-certificates \
    curl

# Copy application files
COPY package*.json ./
RUN npm ci --only=production

COPY . .

# Set up user
RUN addgroup -g 1000 homelabarr && \
    adduser -D -u 1000 -G homelabarr homelabarr

USER homelabarr

EXPOSE 8190 3000
CMD ["npm", "start"]
```

## 📋 Package.json Structure

### Dependencies
```json
{
  "name": "homelabarr-mount-enhanced",
  "version": "2.0.0",
  "description": "Enhanced cloud storage mounting with multi-provider support",
  "main": "server.js",
  
  "dependencies": {
    "express": "^4.18.2",
    "socket.io": "^4.5.4",
    "redis": "^4.5.1",
    "winston": "^3.8.2",
    "dotenv": "^16.0.3",
    "axios": "^1.3.4",
    "bcryptjs": "^2.4.3",
    "jsonwebtoken": "^9.0.0",
    "multer": "^1.4.5-lts.1",
    "node-cron": "^3.0.2",
    "prom-client": "^14.1.1"
  },
  
  "scripts": {
    "start": "node server.js",
    "dev": "nodemon server.js",
    "test": "jest",
    "migrate:legacy": "node scripts/migrate-legacy.js",
    "costs:reset": "node scripts/reset-costs.js",
    "cache:clear": "node scripts/clear-cache.js"
  }
}
```

## 📁 Server Templates Collection

### Template Categories (90 total)
The `server/templates/` directory contains Docker compose templates for:

#### Media Servers
- `plex.yml` - Plex Media Server
- `jellyfin.yml` - Jellyfin Media Server
- `emby.yml` - Emby Media Server
- `audiobookshelf.yml` - Audiobook server

#### Download Clients
- `qbittorrent.yml` - qBittorrent
- `sabnzbd.yml` - SABnzbd
- `nzbget.yml` - NZBGet
- `deluge.yml` - Deluge

#### Media Management (*arr stack)
- `sonarr.yml` - TV show management
- `radarr.yml` - Movie management
- `lidarr.yml` - Music management
- `bazarr.yml` - Subtitle management
- `prowlarr.yml` - Indexer management
- `readarr.yml` - Book management

#### Request Management
- `overseerr.yml` - Media requests
- `petio.yml` - Request management
- `ombi.yml` - Request system

#### Monitoring & Management
- `grafana.yml` - Metrics visualization
- `prometheus.yml` - Metrics collection
- `alertmanager.yml` - Alert management
- `netdata.yml` - Real-time monitoring
- `uptime-kuma.yml` - Uptime monitoring
- `dozzle.yml` - Log viewer

#### Security & Authentication
- `authelia.yml` - Authentication middleware
- `authentik.yml` - Identity provider
- `vaultwarden.yml` - Password manager
- `adguard.yml` - Ad blocking

#### Utilities
- `filebrowser.yml` - Web file manager
- `code-server.yml` - VS Code in browser
- `duplicati.yml` - Backup solution
- `homepage.yml` - Dashboard
- `homer.yml` - Static dashboard

### Template Structure Example
```yaml
# Example: plex.yml template
services:
  plex:
    image: lscr.io/linuxserver/plex:latest
    container_name: plex
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=${TZ}
      - VERSION=docker
    volumes:
      - ./config/plex:/config
      - /mnt/cloud/media:/media
    ports:
      - 32400:32400
    restart: unless-stopped
```

## 🔧 Environment Configuration

### .env.template Structure
```env
# Core Settings
NODE_ENV=production
PORT=8190
SECRET_KEY=your-secret-key-here

# Database
REDIS_URL=redis://localhost:6379

# Provider Credentials
GDRIVE_CLIENT_ID=
GDRIVE_CLIENT_SECRET=
GDRIVE_REFRESH_TOKEN=

BACKBLAZE_KEY_ID=
BACKBLAZE_APPLICATION_KEY=
BACKBLAZE_BUCKET=

ONEDRIVE_CLIENT_ID=
ONEDRIVE_CLIENT_SECRET=
ONEDRIVE_REFRESH_TOKEN=

PCLOUD_USERNAME=
PCLOUD_PASSWORD=

# Cost Management
ENABLE_COST_TRACKING=true
BUDGET_MONTHLY_LIMIT=100
BUDGET_ALERT_EMAIL=admin@yourdomain.com
BUDGET_ALERT_THRESHOLDS=50,75,90

# Performance
CACHE_ENABLED=true
CACHE_TTL=3600
MAX_CONCURRENT_UPLOADS=5

# Monitoring
PROMETHEUS_ENABLED=true
METRICS_PORT=9090

# Legacy Compatibility
LEGACY_MODE=false
LEGACY_CONFIG_PATH=/config/mount.conf
```

## 🚀 Deployment Methods

### 1. Standalone Deployment
```bash
# Clone and configure
git clone https://github.com/smashingtags/homelabarr-mount-enhanced
cd homelabarr-mount-enhanced
cp .env.template .env
nano .env

# Deploy with Docker Compose
docker-compose up -d
```

### 2. HomelabARR Integration
```bash
# Copy to HomelabARR apps directory
cp docker-compose.yml /opt/homelabarr/apps/system/mount-enhanced.yml

# Deploy via HomelabARR CLI
sudo ./apps/install.sh
# Select: System Apps > Mount Enhanced
```

### 3. Development Mode
```bash
# Install dependencies locally
npm install

# Run in development mode
npm run dev
```

## 📈 Performance Optimizations

### Caching Strategy
- Redis for session management
- File metadata caching (1 hour TTL)
- Provider response caching
- CDN integration for static assets

### Upload Optimization
- Chunked uploads for files > 100MB
- Parallel upload streams (max 5)
- Automatic retry with exponential backoff
- Intelligent provider selection based on:
  - Current cost
  - Available quota
  - Network latency
  - Historical reliability

## 🔒 Security Implementation

### Authentication Flow
1. OAuth2 for provider authentication
2. JWT tokens for API access (24h expiry)
3. Redis session management
4. Rate limiting (100 req/min per IP)

### Data Protection
- AES-256 encryption for stored credentials
- TLS 1.3 for all external connections
- Input validation with joi schemas
- CORS restricted to configured domains

## 📊 Monitoring Integration

### Prometheus Metrics
```javascript
// Custom metrics exposed
mount_enhanced_uploads_total
mount_enhanced_downloads_total
mount_enhanced_storage_bytes
mount_enhanced_cost_dollars
mount_enhanced_api_requests
mount_enhanced_errors_total
mount_enhanced_cache_hits
mount_enhanced_cache_misses
```

### Health Endpoints
- `/health` - Basic health check
- `/ready` - Readiness probe
- `/metrics` - Prometheus metrics
- `/status` - Detailed status

## 🔄 Migration from Legacy Mount

### Compatibility Features
- Reads existing mount.conf
- Supports legacy environment variables
- Maintains same mount points
- Preserves rclone configurations

### Migration Process
```bash
# 1. Backup existing configuration
docker exec homelabarr-mount rclone config show > backup.conf

# 2. Stop old container
docker stop homelabarr-mount

# 3. Deploy enhanced version
docker-compose up -d homelabarr-mount-enhanced

# 4. Run migration
docker exec homelabarr-mount-enhanced npm run migrate:legacy

# 5. Verify
docker exec homelabarr-mount-enhanced npm run verify:migration
```

## 📝 API Implementation

### RESTful Endpoints
```javascript
// Provider endpoints
app.get('/api/providers', getProviders);
app.post('/api/providers', addProvider);
app.delete('/api/providers/:id', removeProvider);

// File operations
app.get('/api/files', listFiles);
app.post('/api/files/upload', uploadFile);
app.post('/api/files/move', moveFile);
app.delete('/api/files/:id', deleteFile);

// Cost management
app.get('/api/costs', getCostSummary);
app.get('/api/costs/history', getCostHistory);
app.post('/api/costs/budget', setBudget);

// System
app.get('/api/status', getSystemStatus);
app.post('/api/cache/clear', clearCache);
```

### WebSocket Events
```javascript
io.on('connection', (socket) => {
  // Real-time updates
  socket.emit('provider:status', providerStatus);
  socket.emit('upload:progress', uploadProgress);
  socket.emit('cost:update', currentCost);
  
  // Client events
  socket.on('file:upload', handleUpload);
  socket.on('provider:switch', switchProvider);
});
```

## 🐛 Debugging

### Log Locations
- Application logs: `/logs/app.log`
- Error logs: `/logs/error.log`
- Access logs: `/logs/access.log`
- Provider logs: `/logs/providers/`

### Debug Commands
```bash
# View logs
docker logs homelabarr-mount-enhanced

# Interactive shell
docker exec -it homelabarr-mount-enhanced sh

# Check provider status
docker exec homelabarr-mount-enhanced npm run test:providers

# Reset costs
docker exec homelabarr-mount-enhanced npm run costs:reset
```

---

**Technical Documentation Version**: 2.0.0
**Last Updated**: August 2025
**Repository**: homelabarr-mount-enhanced-standalone