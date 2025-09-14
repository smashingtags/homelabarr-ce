# Troubleshooting Guide

**Comprehensive solutions for common HomelabARR CLI issues**

## 🔍 Quick Diagnostics

### System Check Commands
```bash
# Check Docker
docker --version
docker-compose --version
docker ps

# Check ports
sudo netstat -tulpn | grep LISTEN

# Check disk space
df -h

# Check memory
free -h

# Check logs
docker logs <container-name> --tail 50
```

---

## 🚨 Critical Issues

### Issue: "Failed to fetch containers" Error
**Symptoms**: Web interface shows connection error
**Cause**: CORS blocking or Docker socket issues

**Solution**:
```bash
# Check Docker socket
ls -la /var/run/docker.sock

# Fix permissions
sudo chmod 666 /var/run/docker.sock

# Restart Docker
sudo systemctl restart docker

# Check backend
docker logs homelabarr_backend
```

### Issue: Authentication Failures (admin/admin not working)
**Symptoms**: Can't login to web interface
**Cause**: AUTH_ENABLED misconfiguration

**Solution**:
```bash
# For development (temporary)
export AUTH_ENABLED=false

# Check environment
docker exec homelabarr_backend env | grep AUTH

# Restart with correct config
docker-compose down
AUTH_ENABLED=false docker-compose up -d
```

### Issue: Hardcoded localhost:35002
**Symptoms**: Remote access not working
**Cause**: Frontend hardcoded to localhost

**Temporary Solution**:
```bash
# SSH tunnel for remote access
ssh -L 35002:localhost:35002 user@server

# Or use nginx proxy
sudo nano /etc/nginx/sites-available/homelabarr
```

---

## 🐳 Docker Issues

### Issue: Docker not found
**Solution**:
```bash
# Install Docker
curl -fsSL https://get.docker.com | bash

# Add user to docker group
sudo usermod -aG docker $USER

# Logout and login again
exit
```

### Issue: Docker Compose not found
**Solution**:
```bash
# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify
docker-compose --version
```

### Issue: Container won't start
**Diagnosis**:
```bash
# Check logs
docker logs <container-name>

# Check port conflicts
docker ps | grep <port>
netstat -tulpn | grep <port>

# Check resources
docker system df
docker stats
```

---

## 🌐 Network Issues

### Issue: Port conflicts
**Symptoms**: "bind: address already in use"

**Solution**:
```bash
# Find what's using the port
sudo lsof -i :32400

# Kill the process
sudo kill -9 <PID>

# Or change port in docker-compose
ports:
  - "32401:32400"  # Use different external port
```

### Issue: Can't access services
**Symptoms**: Connection refused or timeout

**Solution**:
```bash
# Check firewall
sudo ufw status

# Allow ports
sudo ufw allow 32400  # Plex
sudo ufw allow 7878   # Radarr
sudo ufw allow 8989   # Sonarr

# Check Docker network
docker network ls
docker network inspect homelabarr_default
```

### Issue: Traefik not routing
**Symptoms**: 404 errors on subdomains

**Solution**:
```bash
# Check Traefik logs
docker logs traefik

# Verify labels
docker inspect <container> | grep -A 20 Labels

# Check certificates
docker exec traefik cat /letsencrypt/acme.json | jq
```

---

## 📁 Storage Issues

### Issue: Permission denied
**Symptoms**: Containers can't write to volumes

**Solution**:
```bash
# Fix ownership
sudo chown -R 1000:1000 /opt/appdata

# Fix permissions
sudo chmod -R 755 /opt/appdata

# For specific container
docker exec <container> id
# Note the UID/GID and update .env
```

### Issue: Volume not persisting
**Symptoms**: Settings lost after restart

**Solution**:
```bash
# Check volume mounts
docker inspect <container> | grep -A 10 Mounts

# Create volume explicitly
docker volume create <volume-name>

# Update docker-compose
volumes:
  - volume-name:/config
```

### Issue: Disk space full
**Solution**:
```bash
# Clean Docker
docker system prune -a --volumes

# Check large containers
docker ps -s

# Find large files
du -sh /var/lib/docker/*
```

---

## 🔐 Authentication Issues

### Issue: Authelia not working
**Symptoms**: No authentication prompt

**Solution**:
```bash
# Check Authelia logs
docker logs authelia

# Verify configuration
docker exec authelia cat /config/configuration.yml

# Test LDAP/file backend
docker exec authelia authelia validate-config
```

### Issue: SSL certificate errors
**Symptoms**: Browser security warnings

**Solution**:
```bash
# Check Cloudflare settings
# SSL = FULL (not FULL/STRICT)

# Force certificate renewal
docker exec traefik rm -rf /letsencrypt/acme.json
docker restart traefik

# Check DNS
nslookup yourdomain.com
```

---

## 🎯 Local Mode Issues

### Issue: Menu not showing colors
**Symptoms**: Plain text instead of colored menu

**Solution**:
```bash
# Check terminal support
echo $TERM

# Set proper terminal
export TERM=xterm-256color

# For Windows Terminal
# Settings → Profiles → Advanced → Color scheme
```

### Issue: "0 apps available"
**Symptoms**: Empty application list

**Solution**:
```bash
# Check apps directory
ls -la apps/local-mode-apps/

# Re-run setup
./setup-local-mode.sh

# Manual fix
cd apps/.config
./convert-to-local.sh
```

---

## 🖥️ Web Interface Issues

### Issue: Blank page or loading forever
**Symptoms**: Web UI doesn't load

**Solution**:
```bash
# Check frontend logs
docker logs homelabarr_frontend

# Check backend
curl http://localhost:3001/health

# Rebuild frontend
cd .integration-work/homelabarr-main
npm run build
```

### Issue: Can't deploy containers
**Symptoms**: Deploy button doesn't work

**Solution**:
```bash
# Check Docker socket
docker exec homelabarr_backend docker ps

# Check CLI path
docker exec homelabarr_backend ls -la /cli

# Verify permissions
docker exec homelabarr_backend whoami
```

---

## 🔧 Installation Issues

### Issue: Permission denied on scripts
**Solution**:
```bash
# Fix all scripts
chmod +x install.sh
find . -name "*.sh" -exec chmod +x {} \;
```

### Issue: Symlink issues
**Symptoms**: "/opt/homelabarr not found"

**Solution**:
```bash
# Create symlink
sudo ln -sf "$(pwd)" /opt/homelabarr

# Verify
ls -la /opt/homelabarr
```

### Issue: Preinstall loop
**Symptoms**: Installer keeps asking to install Docker

**Solution**:
```bash
# Check Docker
docker --version

# Skip preinstall
sudo ./install.sh --skip-preinstall
```

---

## 📊 Monitoring Issues

### Issue: Grafana not loading
**Solution**:
```bash
# Reset admin password
docker exec -it grafana grafana-cli admin reset-admin-password newpassword

# Check datasources
docker exec grafana cat /etc/grafana/provisioning/datasources/prometheus.yml
```

### Issue: No metrics in Prometheus
**Solution**:
```bash
# Check targets
curl http://localhost:9090/api/v1/targets

# Verify exporters
docker ps | grep exporter

# Check scrape config
docker exec prometheus cat /etc/prometheus/prometheus.yml
```

---

## 🚀 Performance Issues

### Issue: Slow container startup
**Diagnosis**:
```bash
# Check system resources
htop
docker stats

# Check I/O
iotop

# Check Docker daemon
journalctl -u docker -f
```

### Issue: High memory usage
**Solution**:
```bash
# Limit container memory
docker update --memory="1g" <container>

# Or in docker-compose
services:
  plex:
    mem_limit: 2g
```

---

## 📝 Common Error Messages

| Error | Cause | Solution |
|-------|-------|----------|
| "bind: address already in use" | Port conflict | Change port or stop conflicting service |
| "no such file or directory" | Missing mount | Create directory or fix path |
| "permission denied" | Wrong ownership | chown to PUID:PGID |
| "cannot connect to Docker daemon" | Docker not running | Start Docker service |
| "network homelabarr_default not found" | Network missing | docker network create homelabarr_default |
| "invalid compose file" | YAML syntax error | Validate with docker-compose config |

---

## 🆘 Getting Help

### Before Asking for Help
1. Check this guide first
2. Search [GitHub Issues](https://github.com/smashingtags/homelabarr-cli/issues)
3. Review [Confluence Docs](https://mjashley.atlassian.net/wiki/spaces/DO)

### Information to Provide
```bash
# System info
uname -a
docker --version
docker-compose --version

# Error logs
docker logs <container> --tail 100

# Configuration
cat .env
docker-compose config
```

### Support Channels
- **Discord**: [HomelabARR Community](https://discord.gg/Pc7mXX786x)
- **GitHub**: [Issue Tracker](https://github.com/smashingtags/homelabarr-cli/issues)
- **Confluence**: [Knowledge Base](https://mjashley.atlassian.net/wiki/spaces/DO)

---

**Last Updated**: August 19, 2025