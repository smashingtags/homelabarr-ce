# Frequently Asked Questions (FAQ)

## General Questions

### What is HomelabARR CE?
HomelabARR CE is a comprehensive Docker-based media server stack that provides automated deployment and management of 162+ self-hosted applications including Plex, Radarr, Sonarr, and many others.

### What happened to HomelabARR CE?
HomelabARR CE has been rebranded to HomelabARR CE as part of a major restructuring effort. All functionality remains the same, but with improved documentation, better organization, and modernized tooling.

### Is this free to use?
Yes! HomelabARR CE is completely free and open-source under the MIT license. There are no premium features or paid tiers.

### What's the difference between Full Mode and Local Mode?
- **Full Mode**: Production-ready deployment with Traefik reverse proxy, Authelia authentication, and Cloudflare integration for external access
- **Local Mode**: Simplified deployment for home labs with direct IP:PORT access, no domain required

### Which mode should I choose?
- Choose **Local Mode** if you're new to Docker, want quick setup, or only need local network access
- Choose **Full Mode** if you want external access, need authentication, or are deploying for multiple users

## Installation Questions

### What are the system requirements?
**Minimum Requirements:**
- CPU: 2 cores or 2 vCores (x86/x64 only, no ARM)
- RAM: 4GB
- Storage: 20GB available space
- OS: Ubuntu 22.04 LTS (recommended) or Debian
- Docker: Latest version with Compose V2

### Do I need a domain name?
- **Full Mode**: Yes, you need a domain and Cloudflare account
- **Local Mode**: No domain required, works with localhost

### Can I run this on Windows or macOS?
Currently, HomelabARR CE is designed for Linux systems only. Windows and macOS support may be added in the future.

### Can I run this on a Raspberry Pi?
No, ARM processors are not currently supported. The stack requires x86/x64 architecture.

### How long does installation take?
- **Local Mode**: 5-10 minutes
- **Full Mode**: 15-30 minutes (depending on DNS propagation)

## Local Mode Questions

### How do I access applications in Local Mode?
Applications are accessible via direct IP and port:
- Plex: `http://localhost:32400`
- Radarr: `http://localhost:7878`
- qBittorrent: `http://localhost:8082`

### Can I access Local Mode from other devices?
Yes, replace `localhost` with your server's IP address:
- Example: `http://192.168.1.100:32400`

### How do I add external access to Local Mode?
You would need to:
1. Configure port forwarding on your router
2. Set up dynamic DNS (optional)
3. Consider security implications (no authentication by default)

For proper external access, consider upgrading to Full Mode.

### What's the local-persist plugin?
Local-persist is a Docker volume plugin that stores container data in specific host directories (`/opt/appdata`) rather than Docker's managed volumes. This makes backup and migration easier.

## Full Mode Questions

### What Cloudflare features do I need?
The free Cloudflare tier is sufficient. You need:
- DNS management for your domain
- API key for certificate management
- Basic DDoS protection (included)

### Why can't I access my applications after Full Mode installation?
Common issues:
1. **DNS not propagated**: Wait 15-30 minutes for DNS changes
2. **Cloudflare SSL setting**: Must be set to "Full" (not "Full Strict")
3. **Authelia not configured**: Check authentication setup
4. **Firewall blocking**: Ensure ports 80 and 443 are open

### How do I reset Authelia password?
```bash
# Access Authelia container
docker exec -it authelia bash

# Reset user password
authelia crypto hash generate pbkdf2 --password "newpassword"

# Update configuration with new hash
```

### Can I use a subdomain instead of main domain?
Yes, you can use any subdomain. Update your DNS and configuration accordingly.

## Application Questions

### How many applications are available?
- **Local Mode**: 179+ applications (includes bulk-converted apps)
- **Full Mode**: 162+ applications (fully tested and documented)

### How do I request a new application?
1. Check if it already exists in the apps directory
2. Create a GitHub issue using the "Application Request" template
3. Join Discord and ask in #app-requests channel

### Why won't my application start?
Common issues:
1. **Port conflicts**: Check if port is already in use
2. **Image not found**: Verify image name and tag
3. **Permission issues**: Check file/folder permissions
4. **Missing dependencies**: Some apps require local-persist plugin

### How do I update applications?
```bash
# Update single application
docker-compose -f apps/category/app.yml pull
docker-compose -f apps/category/app.yml up -d

# Update all containers
docker images | grep -v REPOSITORY | awk '{print $1":"$2}' | xargs -L1 docker pull
```

### Where is my application data stored?
- **Local Mode**: `/opt/appdata/<application-name>`
- **Full Mode**: Same location, managed by local-persist volumes

## Troubleshooting Questions

### Docker says "permission denied"
```bash
# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker

# Or run with sudo (not recommended)
sudo docker ps
```

### "Port already in use" error
```bash
# Find what's using the port
sudo netstat -tulpn | grep :8080

# Kill the process
sudo kill -9 <PID>

# Or change the port in docker-compose file
```

### How do I check container logs?
```bash
# View logs
docker logs <container-name>

# Follow logs in real-time
docker logs -f <container-name>

# View last 50 lines
docker logs --tail 50 <container-name>
```

### Application is running but not accessible
1. **Check container status**: `docker ps`
2. **Verify port mapping**: Look for port in `docker ps` output
3. **Test connectivity**: `curl -I http://localhost:<port>`
4. **Check firewall**: `sudo ufw status`
5. **Review logs**: `docker logs <container-name>`

### How do I completely uninstall?
```bash
# Stop all containers
docker stop $(docker ps -aq)

# Remove all containers
docker rm $(docker ps -aq)

# Remove all images (optional)
docker rmi $(docker images -q)

# Remove application data (WARNING: This deletes all data!)
sudo rm -rf /opt/appdata

# Remove HomelabARR directory
rm -rf homelabarr-ce
```

## Backup & Migration Questions

### How do I backup my setup?
```bash
# Backup application data
sudo tar -czf homelabarr-backup-$(date +%Y%m%d).tar.gz -C /opt appdata

# Backup configuration
tar -czf config-backup-$(date +%Y%m%d).tar.gz homelabarr-ce/
```

### How do I migrate to a new server?
1. **Stop services** on old server
2. **Backup data**: `/opt/appdata` and configuration files
3. **Install HomelabARR** on new server
4. **Restore data** to `/opt/appdata`
5. **Update configurations** (IP addresses, domains)
6. **Start services** on new server

### Can I move from Local Mode to Full Mode?
Yes, but it requires:
1. Backing up application data
2. Setting up domain and Cloudflare
3. Installing Full Mode
4. Restoring data and reconfiguring applications

## Performance Questions

### How much resources does this use?
**Local Mode** (minimal setup):
- RAM: 2-4GB
- CPU: Low usage during normal operation
- Storage: Depends on media collection

**Full Mode** (with proxy stack):
- RAM: 4-6GB
- CPU: Slightly higher due to Traefik/Authelia
- Storage: Same as Local Mode

### Can I limit container resources?
Yes, add resource limits to docker-compose files:
```yaml
services:
  app:
    deploy:
      resources:
        limits:
          memory: 512M
          cpus: '0.5'
```

### How do I optimize performance?
1. **Use SSD storage** for application data
2. **Ensure adequate RAM** for all containers
3. **Monitor resource usage** with Netdata/Glances
4. **Optimize container resource limits**
5. **Use hardware transcoding** for media servers

## Security Questions

### Is Local Mode secure?
Local Mode assumes a trusted local network. It provides:
- Container isolation via Docker
- No external exposure by default
- Standard Linux file permissions

For enhanced security, use Full Mode with Authelia.

### How secure is Full Mode?
Full Mode provides enterprise-grade security:
- Multi-factor authentication via Authelia
- TLS encryption for all traffic
- Cloudflare DDoS protection
- Regular security updates

### How do I enable 2FA?
1. Access Authelia configuration
2. Configure TOTP or WebAuthn
3. Scan QR code with authenticator app
4. Test login with 2FA code

### Should I expose Docker daemon?
No, never expose Docker daemon to the internet. HomelabARR CE doesn't require this.

## Update Questions

### How do I update HomelabARR CE?
```bash
# Update repository
cd homelabarr-ce
git pull origin master

# Update containers
docker-compose pull
docker-compose up -d
```

### How often should I update?
- **Security updates**: Immediately
- **Application updates**: Monthly or as needed
- **HomelabARR updates**: Check releases monthly

### Will updates break my setup?
We strive for backward compatibility, but:
- Always backup before updating
- Read release notes for breaking changes
- Test updates in development environment first

## Community Questions

### How can I contribute?
- Report bugs and request features
- Improve documentation
- Add new application support
- Help other users in Discord
- Submit code improvements

See our [Contributing Guide](contributing.md) for details.

### Where can I get help?
1. **Discord** (fastest): [https://discord.gg/Pc7mXX786x](https://discord.gg/Pc7mXX786x)
2. **GitHub Issues**: [https://github.com/smashingtags/homelabarr-ce/issues](https://github.com/smashingtags/homelabarr-ce/issues)
3. **Documentation**: Check relevant guides first
4. **Community Forums**: Reddit r/selfhosted, r/homelab

### Is there a mobile app?
No mobile app currently exists. Access is via web browsers on mobile devices.

---

## Still Have Questions?

If your question isn't answered here:

1. **Search the documentation** - Use the search function
2. **Check Discord history** - Previous discussions may have answers
3. **Ask in Discord** - Our community is helpful and active
4. **Create GitHub issue** - For bugs or feature requests

**Remember to provide system information and error messages when asking for help!**

## Support Development

If this FAQ helped you solve your issue, consider supporting HomelabARR CE development:

**☕ [Support on Ko-fi](https://ko-fi.com/homelabarr)** - Help us maintain and improve documentation, fix bugs, and add new features!

---

**This FAQ is continuously updated based on community questions. Last updated: August 2025**
