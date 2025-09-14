# HomelabARR CLI Testing & Validation Plan

## 🎯 **Testing Objectives**
Validate all modernization changes work correctly and identify any issues before full deployment.

## 📋 **Pre-Test Checklist**

### Environment Preparation
- [ ] **Backup Current Configuration**
  ```bash
  # Create full system backup
  sudo cp -r /opt/appdata /opt/appdata.backup.$(date +%Y%m%d)
  docker-compose down  # Stop current services if running
  ```

- [ ] **Verify Docker Environment**
  ```bash
  docker --version          # Verify Docker is installed
  docker-compose --version  # Verify Docker Compose is available
  docker network ls         # Check if proxy network exists
  ```

- [ ] **Environment Variables Check**
  ```bash
  # Verify critical environment variables are set
  echo "DOMAIN: ${DOMAIN}"
  echo "CLOUDFLARE_EMAIL: ${CLOUDFLARE_EMAIL}" 
  echo "CLOUDFLARE_API_KEY: ${CLOUDFLARE_API_KEY}"
  ```

## 🧪 **Test Phases**

### **Phase 1: Core Infrastructure Testing** (CRITICAL)

#### 1.1 Traefik Startup Test
```bash
# Test Traefik configuration and startup
cd traefik/
docker-compose config  # Validate YAML syntax
docker-compose up traefik -d
```

**Expected Results:**
- [ ] Traefik starts without errors
- [ ] Health check endpoint responds: `curl -f http://localhost:8080/ping`
- [ ] Dashboard accessible (if configured)
- [ ] Logs show successful SSL certificate generation

**Validation Commands:**
```bash
docker logs traefik                    # Check for errors
docker exec traefik wget -qO- http://localhost:8080/ping  # Test health endpoint
curl -k https://traefik.${DOMAIN}    # Test external access
```

#### 1.2 Authelia Authentication Test
```bash
# Test Authelia startup and health
docker-compose up authelia -d
```

**Expected Results:**
- [ ] Authelia starts without errors
- [ ] Health check passes: `curl -f http://localhost:9091/api/health`
- [ ] Authentication middleware loads correctly
- [ ] Database/config files created

**Validation Commands:**
```bash
docker logs authelia                   # Check startup logs
docker exec authelia wget -qO- http://localhost:9091/api/health
curl -k https://authelia.${DOMAIN}   # Test external access
```

#### 1.3 CF-Companion Integration Test
```bash
# Test Cloudflare DNS automation
docker-compose up cf-companion -d
```

**Expected Results:**
- [ ] CF-Companion starts without errors
- [ ] Connects to Cloudflare API successfully
- [ ] Creates/updates DNS records for services
- [ ] Logs show successful Traefik v3 communication

### **Phase 2: Service Health & Resource Testing** (HIGH PRIORITY)

#### 2.1 Health Check Validation
```bash
# Test health checks for updated services
docker-compose up plex sonarr -d
sleep 60  # Wait for startup period
```

**Expected Results:**
- [ ] Plex health check: `docker inspect plex | grep -A 15 Health`
- [ ] Sonarr health check: `docker inspect sonarr | grep -A 15 Health`
- [ ] Services marked as healthy after start_period

**Validation Commands:**
```bash
# Check health status
docker ps --format "table {{.Names}}\t{{.Status}}"
docker inspect plex | jq '.[0].State.Health'
docker inspect sonarr | jq '.[0].State.Health'
```

#### 2.2 Resource Limit Testing
```bash
# Monitor resource usage with limits
docker stats plex sonarr --no-stream
```

**Expected Results:**
- [ ] Plex memory usage stays under 4GB limit
- [ ] Sonarr memory usage stays under 1GB limit
- [ ] No OOM (Out of Memory) killer events
- [ ] Services remain responsive under resource constraints

### **Phase 3: End-to-End Integration Testing** (MEDIUM PRIORITY)

#### 3.1 Service Discovery Test
```bash
# Test Traefik service discovery
docker-compose up -d
curl -H "Host: plex.${DOMAIN}" http://localhost/
```

**Expected Results:**
- [ ] Traefik discovers all running services
- [ ] Routes requests correctly to backend services
- [ ] SSL certificates generated automatically
- [ ] Middleware chains apply correctly (security headers, rate limiting)

#### 3.2 Authentication Flow Test
```bash
# Test complete authentication workflow
curl -L -k https://plex.${DOMAIN}  # Should redirect to Authelia
```

**Expected Results:**
- [ ] Unauthenticated requests redirect to Authelia
- [ ] Authelia login page loads correctly
- [ ] After authentication, access to protected services
- [ ] Session persistence works correctly

#### 3.3 Security Middleware Test
```bash
# Test security headers and rate limiting
curl -I -k https://plex.${DOMAIN}
```

**Expected Results:**
- [ ] Security headers present (HSTS, CSP, X-Frame-Options)
- [ ] Rate limiting enforces connection limits
- [ ] HTTPS redirect works (HTTP → HTTPS)
- [ ] No hardcoded example.com references

### **Phase 4: Stress & Performance Testing** (LOW PRIORITY)

#### 4.1 Load Testing
```bash
# Basic load testing
ab -n 100 -c 10 https://plex.${DOMAIN}/
```

**Expected Results:**
- [ ] Services handle moderate concurrent load
- [ ] Resource limits prevent system crashes
- [ ] Health checks continue to pass under load
- [ ] Response times remain reasonable

#### 4.2 Failure Recovery Testing
```bash
# Test service recovery scenarios
docker kill plex        # Simulate service failure
sleep 30                # Wait for health check
docker ps | grep plex   # Should auto-restart
```

**Expected Results:**
- [ ] Unhealthy services restart automatically
- [ ] Traefik removes failed services from rotation
- [ ] Services recover to healthy state
- [ ] No cascading failures

## 🚨 **Rollback Procedures**

### Critical Issue Rollback
```bash
# Emergency rollback to previous working state
docker-compose down
sudo rm -rf /opt/appdata
sudo mv /opt/appdata.backup.$(date +%Y%m%d) /opt/appdata
# Restore previous Docker Compose files from .claude/backups/
```

### Selective Service Rollback
```bash
# Rollback specific service
docker-compose stop [service]
# Edit compose file to remove health check / resource limits
docker-compose up [service] -d
```

## 📊 **Test Results Template**

| Test Phase | Service | Status | Notes |
|------------|---------|--------|-------|
| Phase 1.1  | Traefik | ❌/✅  | |
| Phase 1.2  | Authelia| ❌/✅  | |
| Phase 1.3  | CF-Comp | ❌/✅  | |
| Phase 2.1  | Health  | ❌/✅  | |
| Phase 2.2  | Resources| ❌/✅ | |
| Phase 3.1  | Discovery| ❌/✅ | |
| Phase 3.2  | Auth Flow| ❌/✅ | |
| Phase 3.3  | Security | ❌/✅ | |

## 🎯 **Success Criteria**

### Must Pass (Go/No-Go)
- ✅ Traefik starts and routes traffic
- ✅ Authelia authenticates users  
- ✅ Health checks function correctly
- ✅ No service crashes or OOM events

### Should Pass (Performance)
- ✅ Services respond within reasonable time
- ✅ Resource limits prevent system overload
- ✅ Security headers properly configured

### Nice to Have (Optimization)
- ✅ Load balancing works under stress
- ✅ Automatic service recovery
- ✅ Monitoring/alerting integration

## 📝 **Post-Test Actions**

### If Tests Pass
- [ ] Document successful configuration
- [ ] Create production deployment checklist  
- [ ] Set up monitoring for ongoing operations
- [ ] Update wiki with new procedures

### If Tests Fail
- [ ] Identify root cause of failures
- [ ] Implement fixes or rollback changes
- [ ] Re-run failed test phases
- [ ] Document lessons learned

---

**Test Execution Date**: _TBD_  
**Test Executor**: _TBD_  
**Results**: _TBD_
