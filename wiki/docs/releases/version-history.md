# Version History

## HomelabARR CE Release Timeline

### v2.0.0 - "HomelabARR Renaissance" (August 2025)
**Major Rebranding and Architecture Update**

#### 🎆 Major Changes
- **Complete rebranding** from HomelabARR CE to HomelabARR CE
- **Dual deployment modes**: Full Mode and Local Mode
- **179+ applications** available in Local Mode
- **162+ applications** fully tested and documented
- **Local-persist containerization** for improved compatibility
- **GitHub organization migration** preparation

#### 🚀 New Features
- **One-line Local Mode installer** for instant deployment
- **Systematic container testing** and validation framework
- **Automated YAML fixing** and standardization
- **Enhanced documentation** with MkDocs Material theme
- **Container registry migration** to GHCR.io

#### 🔧 Technical Improvements
- **Multi-architecture container builds** (AMD64/ARM64 prep)
- **Improved error handling** in installation scripts
- **Network standardization** across all applications
- **Volume management enhancement** with local-persist plugin
- **CI/CD pipeline maturity** at smashingtags/homelabarr-containers

#### 📄 Documentation Overhaul
- **107+ wiki files updated** with new branding
- **Comprehensive deployment guides** created
- **Architecture documentation** added
- **Developer contribution guides** established
- **FAQ and support documentation** expanded

#### 🐛 Bug Fixes
- **Container startup issues** resolved for 90%+ of applications
- **Image version conflicts** fixed across all categories
- **Network configuration** standardized and tested
- **Permission issues** addressed in installation scripts
- **Local-persist compatibility** improved with containerized deployment

---

### v1.5.0 - "Local Mode Launch" (July 2025)
**Introduction of Simplified Deployment**

#### 🌟 New Features
- **Local Mode deployment** option introduced
- **Direct IP:PORT access** without reverse proxy complexity
- **8 curated applications** fully tested for Local Mode
- **Bulk application conversion** (171+ apps) for advanced users
- **Simple one-line installer** development

#### 🔧 Improvements
- **Docker Compose V2** migration completed
- **Environment variable standardization** across applications
- **Installation script robustness** improvements
- **Local-persist plugin** integration planning

#### 📄 Documentation
- **Local Mode guide** creation
- **Deployment comparison** documentation
- **Quick start guides** for both modes
- **Troubleshooting guides** expansion

---

### v1.4.2 - "Stability & Security" (June 2025)
**Focus on Reliability and Security Enhancements**

#### 🔒 Security Updates
- **Container security scanning** implementation
- **Authelia configuration** hardening
- **Traefik security headers** enhancement
- **Cloudflare integration** security improvements

#### 🐛 Bug Fixes
- **Memory leak issues** in certain containers resolved
- **SSL certificate renewal** automation improved
- **DNS propagation** handling enhanced
- **Application startup** dependency ordering fixed

#### 🔧 Performance
- **Container resource optimization** across the stack
- **Startup time reduction** for core services
- **Network latency** improvements
- **Storage I/O** optimization

---

### v1.4.0 - "Application Expansion" (May 2025)
**Major Application Library Growth**

#### 📦 New Applications
- **25+ new applications** added across all categories
- **Gaming servers** category introduction
- **Development tools** expansion
- **Monitoring solutions** enhancement
- **Backup tools** diversification

#### 🔧 Infrastructure
- **Container registry** migration planning
- **Multi-architecture** build preparation
- **Automated testing** framework development
- **Documentation automation** implementation

---

### v1.3.5 - "Traefik v3 Migration" (April 2025)
**Major Reverse Proxy Upgrade**

#### ⬆️ Upgrades
- **Traefik v3.x** migration completed
- **Updated routing syntax** across all applications
- **Performance improvements** from new Traefik version
- **Security enhancements** with latest features

#### 🔧 Compatibility
- **Backward compatibility** maintained for existing setups
- **Migration scripts** provided for existing users
- **Testing framework** for route validation
- **Documentation updates** for new syntax

---

### v1.3.0 - "Authelia Integration" (March 2025)
**Enhanced Authentication and Authorization**

#### 🔐 Authentication
- **Authelia v4.x** integration completed
- **Multi-factor authentication** support
- **LDAP integration** capabilities
- **Session management** improvements
- **Role-based access control** implementation

#### 📄 User Experience
- **Single sign-on** across all applications
- **Password policy** enforcement
- **Brute force protection** implementation
- **User management** interface

---

### v1.2.0 - "Cloudflare Integration" (February 2025)
**Automated DNS and SSL Management**

#### ☁️ Cloud Features
- **Cloudflare API** integration
- **Automatic DNS** record management
- **SSL certificate** automation via Let's Encrypt
- **DDoS protection** through Cloudflare
- **CDN acceleration** for static assets

#### 🔧 Automation
- **Zero-touch deployment** for DNS setup
- **Certificate renewal** automation
- **Health monitoring** integration
- **Backup and restore** capabilities

---

### v1.1.0 - "Docker Foundation" (January 2025)
**Containerization Maturity**

#### 📦 Container Infrastructure
- **Docker Compose** standardization
- **Volume management** improvement
- **Network architecture** optimization
- **Resource management** implementation
- **Health checks** across all services

#### 🔧 Development
- **CI/CD pipeline** establishment
- **Automated building** for containers
- **Quality assurance** processes
- **Version control** improvements

---

### v1.0.0 - "HomelabARR CE Genesis" (December 2024)
**Initial Public Release**

#### 🎉 Launch Features
- **Core media stack** (Plex, Radarr, Sonarr, qBittorrent)
- **Traefik reverse proxy** integration
- **Basic authentication** implementation
- **50+ applications** in initial library
- **Ubuntu/Debian** support

#### 📄 Documentation
- **Installation guides** creation
- **Application documentation** establishment
- **Community resources** setup
- **Support channels** launch

---

## Migration Path

### From HomelabARR CE v1.x to HomelabARR CE v2.x
1. **Backup existing data** and configurations
2. **Review migration guide** for breaking changes
3. **Choose deployment mode** (Full/Local)
4. **Follow installation guide** for chosen mode
5. **Restore data** and reconfigure applications
6. **Test functionality** before decommissioning old setup

### Version Compatibility

Only the latest release is fully supported. See the [Security Policy](https://github.com/smashingtags/homelabarr-ce/security/policy) for details.

For the latest release and changelog, see [GitHub Releases](https://github.com/smashingtags/homelabarr-ce/releases).

---

## Release Schedule

### Major Releases (x.0.0)
- **Frequency**: Every 6-12 months
- **Content**: Major features, architecture changes
- **Notice**: 30+ days advance notice
- **Support**: LTS versions supported for 18 months

### Minor Releases (x.y.0)
- **Frequency**: Every 1-3 months
- **Content**: New features, application additions
- **Notice**: 1-2 weeks advance notice
- **Support**: Supported until next minor release

### Patch Releases (x.y.z)
- **Frequency**: As needed for critical issues
- **Content**: Bug fixes, security updates
- **Notice**: Immediate for security issues
- **Support**: Automatic updates recommended

---

**For detailed release notes, see [RELEASE-NOTES.md](RELEASE-NOTES.md)**

**Download releases: [GitHub Releases](https://github.com/smashingtags/homelabarr-ce/releases)**
