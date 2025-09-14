# HomelabARR Mount Enhanced - Complete Documentation

## 🎯 Overview

HomelabARR Mount Enhanced is a sophisticated cloud storage mounting solution that replaces the original homelabarr-mount with advanced features including multi-provider support, cost tracking, and a modern web interface.

## 📁 Documentation Structure

### Core Documentation
1. **README.md** - Main project overview and quick start
2. **installation-guide.md** - Detailed installation instructions
3. **evolution-strategy.md** - Development roadmap and strategy
4. **CHERRY_PICK_SUMMARY.md** - Integration tracking from main repository

## 🚀 Key Features

### Multi-Provider Support
- **Google Drive** - Unlimited workspace storage
- **Backblaze B2** - $5/TB/month cost-effective storage
- **OneDrive** - Microsoft ecosystem integration
- **pCloud** - Lifetime storage options

### Cost Management System
- Real-time spending tracking
- Budget alerts via email
- Intelligent provider selection
- Detailed analytics dashboard

### Modern Architecture
- **Frontend**: Bootstrap 5 responsive design
- **Backend**: Node.js with Express
- **API**: RESTful with WebSocket support
- **Monitoring**: Prometheus metrics integration

## 🔧 Installation Methods

### 1. HomelabARR CLI Integration (Recommended)

#### Traefik Mode (Production)
```bash
sudo ./apps/install.sh
# Select: System Apps > Enhanced Cloud Mount
# Access: https://mount.yourdomain.com
```

#### Local Mode (Development)
```bash
sudo ./apps/install.sh  
# Select: Local Mode Apps > Enhanced Cloud Mount
# Access: http://localhost:8190
```

### 2. Standalone Docker Deployment
```bash
# Clone repository
git clone https://github.com/smashingtags/homelabarr-mount-enhanced
cd homelabarr-mount-enhanced

# Configure environment
cp .env.template .env
nano .env

# Deploy with Docker Compose
docker-compose up -d
```

### 3. Direct Installation
```bash
# Install dependencies
npm install

# Configure
cp .env.template .env
# Edit .env with your settings

# Run
npm start
```

## 📊 Configuration

### Environment Variables
```env
# Core Settings
NODE_ENV=production
PORT=8190
SECRET_KEY=your-secret-key

# Provider Credentials
GOOGLE_CLIENT_ID=your-google-client-id
GOOGLE_CLIENT_SECRET=your-google-client-secret
BACKBLAZE_KEY_ID=your-b2-key-id
BACKBLAZE_APPLICATION_KEY=your-b2-app-key
ONEDRIVE_CLIENT_ID=your-onedrive-client-id
ONEDRIVE_CLIENT_SECRET=your-onedrive-client-secret

# Cost Management
ENABLE_COST_TRACKING=true
BUDGET_MONTHLY_LIMIT=100
BUDGET_ALERT_EMAIL=admin@yourdomain.com
BUDGET_ALERT_THRESHOLDS=50,75,90

# Performance
CACHE_ENABLED=true
CACHE_TTL=3600
MAX_CONCURRENT_UPLOADS=5
```

## 🐳 Docker Compose Integration

### Production with Traefik
```yaml
version: '3.9'
services:
  mount-enhanced:
    image: ghcr.io/smashingtags/homelabarr-mount-enhanced:latest
    container_name: mount-enhanced
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=America/New_York
    volumes:
      - ./config:/config
      - ./data:/data
      - /mnt/cloud:/mnt/cloud
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.mount.rule=Host(`mount.${DOMAIN}`)"
      - "traefik.http.routers.mount.entrypoints=websecure"
      - "traefik.http.routers.mount.tls.certresolver=letsencrypt"
      - "traefik.http.services.mount.loadbalancer.server.port=8190"
    networks:
      - proxy
    restart: unless-stopped
```

### Local Development
```yaml
version: '3.9'
services:
  mount-enhanced:
    image: ghcr.io/smashingtags/homelabarr-mount-enhanced:latest
    container_name: mount-enhanced
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=America/New_York
    volumes:
      - ./config:/config
      - ./data:/data
      - /mnt/cloud:/mnt/cloud
    ports:
      - "8190:8190"
    restart: unless-stopped
```

## 📈 Monitoring & Metrics

### Prometheus Endpoints
- `/metrics` - Application metrics
- `/health` - Health check endpoint
- `/ready` - Readiness probe

### Key Metrics
- `mount_enhanced_uploads_total` - Total uploads
- `mount_enhanced_storage_bytes` - Storage usage by provider
- `mount_enhanced_cost_dollars` - Cost tracking
- `mount_enhanced_api_requests` - API usage
- `mount_enhanced_errors_total` - Error tracking

### Grafana Dashboard
Import dashboard ID: `14785` for pre-configured monitoring

## 🔒 Security Features

### Authentication
- OAuth2 for cloud providers
- JWT tokens for API access
- Session management with Redis
- Rate limiting on API endpoints

### Data Protection
- Encrypted credentials storage
- TLS/SSL for all connections
- Input validation and sanitization
- CORS configuration

## 🛠️ API Documentation

### REST Endpoints

#### Provider Management
```
GET    /api/providers           - List configured providers
POST   /api/providers           - Add new provider
DELETE /api/providers/:id       - Remove provider
GET    /api/providers/:id/stats - Provider statistics
```

#### File Operations
```
GET    /api/files               - List files
POST   /api/files/upload        - Upload file
POST   /api/files/move          - Move file between providers
DELETE /api/files/:id           - Delete file
```

#### Cost Management
```
GET    /api/costs               - Cost summary
GET    /api/costs/history       - Historical data
POST   /api/costs/budget        - Set budget
GET    /api/costs/alerts        - Alert configuration
```

### WebSocket Events
```javascript
// Connection
socket.on('connect', () => {
  console.log('Connected to Mount Enhanced');
});

// Real-time updates
socket.on('upload:progress', (data) => {
  console.log(`Upload progress: ${data.percent}%`);
});

socket.on('cost:update', (data) => {
  console.log(`Current spend: $${data.amount}`);
});

socket.on('provider:status', (data) => {
  console.log(`Provider ${data.name}: ${data.status}`);
});
```

## 🔧 Troubleshooting

### Common Issues

#### Provider Connection Failed
```bash
# Check credentials
docker exec mount-enhanced cat /config/providers.json

# Test connectivity
docker exec mount-enhanced npm run test:providers

# Check logs
docker logs mount-enhanced
```

#### High Memory Usage
```bash
# Adjust Node.js memory
docker exec mount-enhanced node --max-old-space-size=2048 server.js

# Clear cache
docker exec mount-enhanced npm run cache:clear
```

#### Cost Tracking Issues
```bash
# Reset cost database
docker exec mount-enhanced npm run costs:reset

# Recalculate costs
docker exec mount-enhanced npm run costs:recalculate
```

## 📚 Migration from Original Mount

### Compatibility Mode
Enable in `.env`:
```env
LEGACY_COMPATIBILITY=true
LEGACY_CONFIG_PATH=/config/mount.conf
```

### Data Migration
```bash
# Backup original config
cp /opt/homelabarr/mount/config/* ./backup/

# Run migration script
docker exec mount-enhanced npm run migrate:legacy

# Verify migration
docker exec mount-enhanced npm run verify:migration
```

## 🚀 Performance Optimization

### Caching Strategy
- Redis for session management
- File metadata caching
- Provider response caching
- CDN integration for static assets

### Upload Optimization
- Chunked uploads for large files
- Parallel upload streams
- Automatic retry with exponential backoff
- Intelligent provider selection

## 📊 Cost Analysis Features

### Budget Management
- Monthly/yearly budget limits
- Per-provider spending caps
- Alert thresholds
- Spending forecasts

### Cost Optimization
- Automatic provider switching
- Storage tiering (hot/cold)
- Bandwidth optimization
- Scheduled operations for lower rates

## 🔄 Evolution Strategy

### Current Phase (v2.0)
- ✅ Multi-provider support
- ✅ Cost tracking
- ✅ Modern web interface
- ✅ API implementation

### Planned Features (v3.0)
- 🔄 AI-powered cost optimization
- 🔄 Advanced encryption options
- 🔄 Multi-region support
- 🔄 Enterprise SSO integration

### Future Vision (v4.0)
- 📋 Kubernetes operator
- 📋 Native mobile apps
- 📋 Blockchain storage integration
- 📋 ML-based predictive caching

## 📝 Related Documentation

### In HomelabARR Ecosystem
- `/apps/system/mount-enhanced.yml` - Docker compose configuration
- `/wiki/docs/apps/system/mount-enhanced.md` - User guide
- `/.config/mount-enhanced.env` - Environment template

### External Resources
- [GitHub Repository](https://github.com/smashingtags/homelabarr-mount-enhanced)
- [Docker Hub](https://hub.docker.com/r/smashingtags/homelabarr-mount-enhanced)
- [API Documentation](https://mount-api.homelabarr.com)

## 🤝 Support

### Getting Help
- GitHub Issues: Report bugs and request features
- Discord: Real-time community support
- Documentation: Comprehensive guides

### Contributing
- Fork the repository
- Create feature branch
- Submit pull request
- Follow coding standards

---

**Version**: 2.0.0
**Last Updated**: August 2025
**Maintainer**: HomelabARR Team
**License**: MIT