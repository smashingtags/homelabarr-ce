# Getting Support

## Community Support Channels

### 💬 Discord Community (Primary)
**Join our active Discord server for real-time help:**

[![Discord](https://discord.com/api/guilds/830478558995415100/widget.png?style=banner2)](https://discord.gg/Pc7mXX786x)

**Channels:**
- `#general` - General discussion
- `#support` - Technical support
- `#local-mode` - Local Mode specific help
- `#full-mode` - Full Mode specific help
- `#app-requests` - Request new applications
- `#showcase` - Show off your setup

### 🐛 GitHub Issues (Bug Reports)
**For bug reports and feature requests:**
[https://github.com/smashingtags/homelabarr-ce/issues](https://github.com/smashingtags/homelabarr-ce/issues)

**Issue Templates:**
- Bug Report
- Feature Request
- Documentation Issue
- Application Request

### 💬 GitHub Discussions (Q&A)
**For questions and community discussions:**
[https://github.com/smashingtags/homelabarr-ce/discussions](https://github.com/smashingtags/homelabarr-ce/discussions)

## Before Asking for Help

### 🔍 Check Documentation First
1. **Quick Start Guide** - [guides/quick-start.md](quick-start.md)
2. **Installation Guides** - [install/install.md](../install/install.md) or [install/local-mode.md](../install/local-mode.md)
3. **FAQ Section** - [guides/faq.md](faq.md)
4. **Application Docs** - [apps/apps.md](../apps/apps.md)

### 🔧 Basic Troubleshooting
```bash
# Check Docker status
sudo systemctl status docker

# Check container status
docker ps -a

# Check container logs
docker logs <container-name>

# Check disk space
df -h

# Check network connectivity
ping google.com
```

## What Information to Provide

### 📝 Essential Information
When asking for help, always include:

**System Information:**
```bash
# Operating System
lsb_release -a

# Docker version
docker --version
docker compose version

# Available resources
free -h
df -h
```

**HomelabARR Information:**
```bash
# Installation mode
echo "Mode: [Full/Local]"

# Container status
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Recent logs (if applicable)
docker logs <problematic-container> --tail 50
```

### 💬 How to Ask Good Questions

1. **Be Specific**
   - What exactly are you trying to do?
   - What did you expect to happen?
   - What actually happened?

2. **Provide Context**
   - What installation mode are you using?
   - What steps led to the issue?
   - Has this ever worked before?

3. **Include Error Messages**
   - Copy/paste exact error messages
   - Include relevant log output
   - Use code blocks for formatting

4. **Show What You've Tried**
   - What troubleshooting steps have you attempted?
   - What documentation have you consulted?

## Common Support Categories

### 📦 Installation Issues
**Common Problems:**
- Docker not installed or running
- Permission denied errors
- Network connectivity issues
- Domain/DNS configuration problems

**Quick Fixes:**
```bash
# Fix Docker permissions
sudo usermod -aG docker $USER
newgrp docker

# Restart Docker service
sudo systemctl restart docker

# Check firewall
sudo ufw status
```

### 📦 Container Issues
**Common Problems:**
- Containers not starting
- Port conflicts
- Permission errors
- Image pull failures

**Diagnostic Commands:**
```bash
# Check container status
docker ps -a

# View container logs
docker logs <container-name>

# Check port usage
sudo netstat -tulpn | grep :<port>

# Restart container
docker restart <container-name>
```

### 🌐 Network Issues
**Common Problems:**
- Can't access applications
- Traefik routing issues
- SSL certificate problems
- Cloudflare configuration

**Network Diagnostics:**
```bash
# Check Docker networks
docker network ls

# Inspect network
docker network inspect <network-name>

# Test connectivity
curl -I http://localhost:<port>
```

### 🔐 Authentication Issues
**Common Problems:**
- Authelia login problems
- 2FA setup issues
- Password reset needs
- Permission denied errors

**Auth Troubleshooting:**
```bash
# Check Authelia logs
docker logs authelia

# Verify configuration
docker exec authelia cat /config/configuration.yml
```

## Self-Help Resources

### 📚 Documentation
- **Installation Guides** - Step-by-step setup instructions
- **Application Docs** - Individual app configuration
- **Troubleshooting Guides** - Common issue solutions
- **Architecture Docs** - System design and networking

### 🌐 Community Resources
- **Discord Chat History** - Search previous discussions
- **GitHub Issues** - Review closed issues for solutions
- **Reddit Communities** - r/selfhosted, r/homelab
- **YouTube Tutorials** - Community-created guides

### 🛠️ Diagnostic Tools
```bash
# System health check script
./scripts/health-check.sh

# Container validation
./scripts/validate-containers.sh

# Network connectivity test
./scripts/network-test.sh
```

## Response Time Expectations

### Discord Support
- **Active Hours**: Typically 6-24 hours
- **Community Response**: Often immediate during peak hours
- **Maintainer Response**: 1-3 days for complex issues

### GitHub Issues
- **Bug Reports**: 1-7 days depending on severity
- **Feature Requests**: 1-4 weeks for evaluation
- **Documentation**: 1-3 days for corrections

## Escalation Process

### Level 1: Community Support
1. Discord #support channel
2. GitHub Discussions
3. Community troubleshooting

### Level 2: Maintainer Support
1. GitHub Issues with detailed information
2. Direct maintainer involvement
3. Code-level debugging

### Level 3: Critical Issues
1. Security vulnerabilities
2. Data loss scenarios
3. System-breaking bugs

## Contributing Back

### 📝 Documentation Improvements
If you solve an issue, consider:
- Updating the FAQ
- Writing a troubleshooting guide
- Improving existing documentation
- Recording a tutorial video

### 🐛 Bug Reports
Help improve the project by:
- Reporting reproducible bugs
- Providing detailed diagnostics
- Testing proposed fixes
- Confirming issue resolution

### 💬 Community Support
Become a community helper by:
- Answering questions in Discord
- Sharing your experience
- Mentoring new users
- Contributing to discussions

## Support Guidelines

### What We Support
- ✅ Official installation methods
- ✅ Documented configurations
- ✅ Current stable releases
- ✅ Ubuntu/Debian Linux systems
- ✅ Standard Docker environments

### What We Don't Support
- ❌ Modified/custom installations
- ❌ Unsupported operating systems
- ❌ Third-party modifications
- ❌ Commercial support requests
- ❌ Illegal content/activities

## Professional Support

For organizations requiring:
- **Commercial Support**: Contact maintainers for enterprise options
- **Custom Development**: Paid development services available
- **Training/Consulting**: Professional services for large deployments
- **Priority Support**: Faster response times for critical systems

## Emergency Contacts

### Security Issues
For security vulnerabilities, email:
- **Security Team**: security@homelabarr.dev (planned)
- **Current Contact**: GitHub private security advisory

### Critical System Issues
For immediate help with critical problems:
1. Discord #support with @Admin ping
2. GitHub issue with "Critical" label
3. Direct maintainer contact (in extreme cases)

---

## Support Team

### Maintainers
- **@smashingtags** - Project Lead & Maintainer

---

**Remember: Our community thrives on mutual help and respect. Be patient, be helpful, and be kind!**

## Support Development

If HomelabARR CE has helped you build your perfect media server setup, consider supporting ongoing development:

**☕ [Support on Ko-fi](https://ko-fi.com/homelabarr)** - Help keep HomelabARR CE growing!

Your support helps with:
- 🔧 New feature development
- 🐛 Bug fixes and maintenance
- 📚 Documentation improvements
- 🚀 Infrastructure costs

---

🚀 **[Join our Discord](https://discord.gg/Pc7mXX786x)** | 🐛 **[Report Issues](https://github.com/smashingtags/homelabarr-ce/issues)** | 💬 **[Discussions](https://github.com/smashingtags/homelabarr-ce/discussions)** | ☕ **[Support Development](https://ko-fi.com/homelabarr)**
