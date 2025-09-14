# homelabarr-mount-enhanced

Enhanced cloud storage mounting solution with multi-provider support, cost tracking, and modern web interface. A compatible drop-in replacement for homelabarr-mount with advanced features.

## 🚀 Features

### Multi-Provider Cloud Storage
- **Google Drive**: Unlimited storage with workspace accounts
- **Backblaze B2**: Cost-effective at $5/TB/month
- **OneDrive**: Microsoft ecosystem integration
- **pCloud**: Lifetime storage options

### Cost Management
- **Real-time Tracking**: Monitor spending as it happens
- **Budget Alerts**: Email notifications at thresholds
- **Intelligent Selection**: Auto-switch to cheapest provider
- **Analytics**: Detailed breakdown by provider and operation

### Modern Interface
- **Bootstrap 5**: Responsive web dashboard
- **RESTful API**: Automation and integration ready
- **Real-time Updates**: WebSocket-powered live data
- **Mobile Friendly**: Works on all devices

### Enhanced Features
- **User Controls**: Configurable upload/move settings (previously locked)
- **Service Rotation**: Google Drive quota management
- **Performance Monitoring**: Prometheus metrics integration
- **Health Checks**: Comprehensive system validation

## 📦 Quick Start

### Option 1: HomelabARR CLI Integration

```bash
# Traefik Mode (SSL + Authentication)
sudo ./apps/install.sh
# Select: System Apps > Enhanced Cloud Mount
# Access: https://mount.yourdomain.com

# Local Mode (Direct Access)
sudo ./apps/install.sh  
# Select: Local Mode Apps > Enhanced Cloud Mount
# Access: http://localhost:8190
```

### Option 2: Standalone Docker

```bash
# Clone repository
git clone https://github.com/smashingtags/homelabarr-mount-enhanced.git
cd homelabarr-mount-enhanced

# Configure environment
cp .env.template .env
nano .env

# Deploy
docker-compose up -d

# Access web interface
http://localhost:8080
```

## ⚙️ Configuration

### Environment Variables

```bash
# Provider Settings
GDRIVE_ENABLED=true
BACKBLAZE_ENABLED=false
ONEDRIVE_ENABLED=false
PCLOUD_ENABLED=false

# Performance
UPLOAD_CONCURRENCY=4
VFS_CACHE_MODE=writes
VFS_CACHE_SIZE=100GB

# Cost Management
COST_LIMIT_MONTHLY=50
PROVIDER_SELECTION=auto
COST_ALERTS=enabled
```

### Provider Setup

#### Google Drive
1. Create Google Cloud Project
2. Enable Google Drive API
3. Create service account credentials

```bash
docker exec -it homelabarr-mount-enhanced bash
/app/enhanced/providers/setup-gdrive.sh
```

#### Backblaze B2
1. Create B2 account at backblaze.com
2. Generate application keys

```bash
docker exec -it homelabarr-mount-enhanced bash
/app/enhanced/providers/setup-b2.sh
```

## 📊 Cost Comparison

| Provider | Cost/TB/Month | Transfer | Best For |
|----------|--------------|----------|----------|
| Backblaze B2 | $5 | $0.01/GB | Archives |
| Google Workspace | $30/user | Free | Active media |
| OneDrive Business | $5/user | Free | Microsoft users |
| pCloud Lifetime | $350 once | Free | Personal use |

## 🔧 Advanced Features

### Service Account Rotation
Bypass Google Drive daily quotas with multiple service accounts:

```bash
GDRIVE_ROTATION=enabled
GDRIVE_ACCOUNTS=3
```

### Intelligent Provider Selection
```bash
# Cost optimization
PROVIDER_SELECTION=cheapest

# Performance optimization  
PROVIDER_SELECTION=fastest

# Balanced approach
PROVIDER_SELECTION=auto
```

### Monitoring Integration
```bash
# Prometheus metrics
http://localhost:9090/metrics

# Health checks
docker exec homelabarr-mount-enhanced /app/enhanced/health-check.sh
```

## 📈 Web Interface

Access the modern web dashboard for:

- **Real-time Status**: Mount health and performance
- **Provider Management**: Enable/disable cloud providers
- **Cost Dashboard**: Budget tracking and alerts
- **Performance Monitor**: Upload/download speeds
- **Configuration**: Adjust settings without restart
- **Log Viewer**: Recent activity and diagnostics

## 🔒 Security

### Best Practices
- Use service accounts instead of personal credentials
- Enable Authelia authentication for external access
- Rotate credentials regularly
- Monitor access logs for suspicious activity

### Authelia Integration
For HomelabARR CLI installations:
- Multi-factor authentication
- Session management  
- Access control policies
- Audit logging

## 🚨 Migration

### From homelabarr-mount

Seamless migration with zero downtime:

```bash
# Backup current configuration
sudo cp -r /opt/appdata/mount /opt/appdata/mount-backup

# Install enhanced version
sudo ./apps/install.sh

# Migrate settings
sudo cp -r /opt/appdata/mount-backup/* /opt/appdata/mount-enhanced/

# Validate
docker logs homelabarr-mount-enhanced
```

### Rollback Plan
```bash
# Easy rollback if needed
docker stop homelabarr-mount-enhanced
sudo cp -r /opt/appdata/mount-backup/* /opt/appdata/mount/
docker-compose -f /opt/homelabarr/apps/system/mount.yml up -d
```

## 🛠️ Troubleshooting

### Common Issues

**Mount Failures**
```bash
# Check FUSE support
modprobe fuse

# Verify permissions
ls -la /dev/fuse

# Check logs
docker logs homelabarr-mount-enhanced
```

**Provider Authentication**
```bash
# Re-authenticate
docker exec -it homelabarr-mount-enhanced rclone config reconnect gdrive

# Test connectivity
docker exec -it homelabarr-mount-enhanced rclone ls gdrive:
```

**Performance Issues**
```bash
# Check cache usage
docker exec -it homelabarr-mount-enhanced df -h /config/cache

# Monitor resources
docker stats homelabarr-mount-enhanced
```

## 📚 Documentation

- **Setup Guide**: Comprehensive installation documentation
- **API Reference**: RESTful API endpoints and examples
- **Provider Guides**: Step-by-step provider configuration
- **Best Practices**: Performance and security recommendations

## 🙏 Attribution

This enhanced version builds upon the excellent work of **PhysK**, creator of the original `rclone-unionfs-mount`. We've preserved the core concepts while adding modern features for today's cloud storage landscape.

### Original Features (PhysK)
- rclone + mergerfs integration
- Basic Google Drive support
- Web interface foundation
- Upload automation

### Enhanced Features (HomelabARR)
- Multi-provider support (4+ clouds)
- Real-time cost tracking
- Modern Bootstrap 5 interface
- Intelligent provider selection
- Enhanced monitoring and metrics
- User-configurable controls

## 📄 License

This project maintains the original licensing while adding enhancements. See LICENSE file for details.

## 🤝 Contributing

Contributions welcome! Please:
- Follow existing code patterns
- Test thoroughly before submitting PRs
- Update documentation for new features
- Maintain backward compatibility

## 📞 Support

- **GitHub Issues**: Bug reports and feature requests
- **HomelabARR Community**: Discord/Forums for general help
- **Documentation**: Comprehensive guides and troubleshooting

---

**homelabarr-mount-enhanced** - Professional cloud storage for the modern homelab