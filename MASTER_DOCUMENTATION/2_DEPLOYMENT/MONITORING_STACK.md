# Complete Monitoring Stack Guide

## 🎯 Overview

The HomelabARR monitoring stack provides enterprise-grade observability for your entire infrastructure with:
- **Grafana**: Beautiful dashboards and visualization
- **Prometheus**: Time-series metrics collection
- **Loki**: Log aggregation and querying
- **Alertmanager**: Intelligent alert routing
- **Netdata**: Real-time performance monitoring
- **Uptime Kuma**: Service availability monitoring
- **Dozzle**: Live container log viewer

## 📊 Stack Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Grafana Dashboard                        │
│                    (Visualization Layer)                     │
└─────────────┬──────────────┬──────────────┬─────────────────┘
              │              │              │
     ┌────────▼───────┐ ┌───▼────┐ ┌──────▼──────┐
     │   Prometheus   │ │  Loki  │ │ Alertmanager │
     │   (Metrics)    │ │ (Logs) │ │   (Alerts)   │
     └────────┬───────┘ └───┬────┘ └──────┬──────┘
              │              │              │
     ┌────────▼───────────────▼─────────────▼──────┐
     │           Data Collection Layer              │
     ├──────────────────────────────────────────────┤
     │ • Node Exporter (System Metrics)            │
     │ • cAdvisor (Container Metrics)              │
     │ • Promtail (Log Shipping)                   │
     │ • Netdata (Real-time Monitoring)            │
     │ • Uptime Kuma (Availability)                │
     └──────────────────────────────────────────────┘
```

## 🚀 Quick Deployment

### Complete Stack Installation
```bash
# Navigate to monitoring directory
cd homelabarr-cli/apps/monitoring/

# Deploy the complete stack
docker-compose -f grafana-loki-prometheus.yml up -d

# Deploy additional components
docker-compose -f netdata.yml up -d
docker-compose -f uptime-kuma.yml up -d
```

### Access URLs
| Service | URL | Default Credentials |
|---------|-----|---------------------|
| Grafana | http://localhost:3000 | admin / admin |
| Prometheus | http://localhost:9090 | No auth |
| Alertmanager | http://localhost:9093 | No auth |
| Netdata | http://localhost:19999 | No auth |
| Uptime Kuma | http://localhost:3001 | Set on first login |
| Dozzle | http://localhost:8080 | No auth |

## 📈 Grafana Configuration

### Initial Setup
1. Access Grafana at http://localhost:3000
2. Login with admin/admin
3. Change password when prompted
4. Configure data sources

### Add Data Sources
```yaml
# Prometheus data source
Name: Prometheus
Type: Prometheus
URL: http://prometheus:9090
Access: Server (default)

# Loki data source
Name: Loki
Type: Loki
URL: http://loki:3100
Access: Server (default)
```

### Import Dashboards
```bash
# Use dashboard import script
cd scripts/monitoring/
./import-dashboards.sh

# Or manually import these dashboard IDs:
# - 1860  (Node Exporter Full)
# - 11600 (Docker Container Stats)
# - 12539 (Traefik 2.0)
# - 13639 (Media Server Dashboard)
```

### Custom HomelabARR Dashboards
```json
{
  "dashboard": {
    "title": "HomelabARR Overview",
    "panels": [
      {
        "title": "Container Status",
        "targets": [{
          "expr": "up{job='cadvisor'}"
        }]
      },
      {
        "title": "CPU Usage by Container",
        "targets": [{
          "expr": "rate(container_cpu_usage_seconds_total[5m])"
        }]
      },
      {
        "title": "Memory Usage",
        "targets": [{
          "expr": "container_memory_usage_bytes"
        }]
      }
    ]
  }
}
```

## 🔍 Prometheus Configuration

### prometheus.yml
```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s
  external_labels:
    monitor: 'homelabarr-monitor'

# Alerting configuration
alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - alertmanager:9093

# Load rules
rule_files:
  - "alert_rules.yml"

# Scrape configurations
scrape_configs:
  # System metrics
  - job_name: 'node'
    static_configs:
      - targets: ['node-exporter:9100']

  # Container metrics
  - job_name: 'cadvisor'
    static_configs:
      - targets: ['cadvisor:8080']

  # Docker daemon metrics
  - job_name: 'docker'
    static_configs:
      - targets: ['docker-exporter:9323']

  # Traefik metrics
  - job_name: 'traefik'
    static_configs:
      - targets: ['traefik:8082']

  # Application-specific metrics
  - job_name: 'plex'
    static_configs:
      - targets: ['plex-exporter:9594']

  - job_name: 'sonarr'
    static_configs:
      - targets: ['exportarr-sonarr:9707']

  - job_name: 'radarr'
    static_configs:
      - targets: ['exportarr-radarr:9708']
```

### Alert Rules (alert_rules.yml)
```yaml
groups:
  - name: container_alerts
    interval: 30s
    rules:
      - alert: ContainerDown
        expr: up{job="cadvisor"} == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Container {{ $labels.name }} is down"
          description: "Container {{ $labels.name }} has been down for more than 1 minute"

      - alert: HighCPUUsage
        expr: rate(container_cpu_usage_seconds_total[5m]) > 0.8
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High CPU usage on {{ $labels.name }}"
          description: "Container {{ $labels.name }} CPU usage is above 80%"

      - alert: HighMemoryUsage
        expr: container_memory_usage_bytes / container_spec_memory_limit_bytes > 0.9
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High memory usage on {{ $labels.name }}"
          description: "Container {{ $labels.name }} memory usage is above 90%"

      - alert: DiskSpaceLow
        expr: node_filesystem_avail_bytes / node_filesystem_size_bytes < 0.1
        for: 10m
        labels:
          severity: critical
        annotations:
          summary: "Low disk space on {{ $labels.mountpoint }}"
          description: "Less than 10% disk space remaining"
```

## 📝 Loki Log Aggregation

### Promtail Configuration
```yaml
server:
  http_listen_port: 9080
  grpc_listen_port: 0

positions:
  filename: /tmp/positions.yaml

clients:
  - url: http://loki:3100/loki/api/v1/push

scrape_configs:
  # Docker container logs
  - job_name: containers
    docker_sd_configs:
      - host: unix:///var/run/docker.sock
        refresh_interval: 5s
    relabel_configs:
      - source_labels: ['__meta_docker_container_name']
        regex: '/(.*)'
        target_label: 'container'
      - source_labels: ['__meta_docker_container_log_stream']
        target_label: 'stream'

  # System logs
  - job_name: syslog
    static_configs:
      - targets:
          - localhost
        labels:
          job: syslog
          __path__: /var/log/syslog

  # Application-specific logs
  - job_name: traefik
    static_configs:
      - targets:
          - localhost
        labels:
          job: traefik
          __path__: /var/log/traefik/*.log
```

### LogQL Queries in Grafana
```
# All container logs
{job="containers"}

# Specific container logs
{container="plex"}

# Error logs only
{job="containers"} |= "error"

# Traefik access logs
{job="traefik"} | json | status >= 400

# Rate of errors
rate({job="containers"} |= "error" [5m])
```

## 🔔 Alertmanager Configuration

### alertmanager.yml
```yaml
global:
  resolve_timeout: 5m
  smtp_from: 'homelabarr@yourdomain.com'
  smtp_smarthost: 'smtp.gmail.com:587'
  smtp_auth_username: 'your-email@gmail.com'
  smtp_auth_password: 'your-app-password'

# Notification templates
templates:
  - '/etc/alertmanager/templates/*.tmpl'

# Routing tree
route:
  group_by: ['alertname', 'cluster', 'service']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 12h
  receiver: 'default'
  
  routes:
    - match:
        severity: critical
      receiver: 'critical'
      continue: true
    
    - match:
        severity: warning
      receiver: 'warning'

# Receivers
receivers:
  - name: 'default'
    email_configs:
      - to: 'admin@yourdomain.com'

  - name: 'critical'
    email_configs:
      - to: 'alerts@yourdomain.com'
    discord_webhook_configs:
      - webhook_url: 'https://discord.com/api/webhooks/YOUR_WEBHOOK'

  - name: 'warning'
    email_configs:
      - to: 'admin@yourdomain.com'
        send_resolved: false
```

## 📊 Netdata Real-time Monitoring

### Installation
```bash
docker run -d \
  --name=netdata \
  --pid=host \
  --network=host \
  --cap-add SYS_PTRACE \
  --security-opt apparmor=unconfined \
  -v /etc/passwd:/host/etc/passwd:ro \
  -v /etc/group:/host/etc/group:ro \
  -v /proc:/host/proc:ro \
  -v /sys:/host/sys:ro \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  netdata/netdata
```

### Netdata Cloud Integration
```bash
# Claim node to Netdata Cloud
docker exec netdata \
  netdata-claim.sh \
  -token=YOUR_CLAIM_TOKEN \
  -rooms=YOUR_ROOM_ID \
  -url=https://app.netdata.cloud
```

## 🔄 Uptime Kuma Setup

### Service Monitoring Configuration
1. Access Uptime Kuma at http://localhost:3001
2. Create admin account
3. Add monitors for each service:

```javascript
// Example monitor configuration
{
  "name": "Plex",
  "type": "HTTP(s)",
  "url": "http://plex:32400/web",
  "interval": 60,
  "retryInterval": 20,
  "maxRetries": 3,
  "notificationIDList": [1, 2]
}
```

### Notification Channels
- Email (SMTP)
- Discord
- Telegram
- Slack
- Pushover
- Webhook

## 🐋 Dozzle Container Logs

### Docker Compose Configuration
```yaml
version: '3.9'
services:
  dozzle:
    container_name: dozzle
    image: amir20/dozzle:latest
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
    ports:
      - 8080:8080
    environment:
      - DOZZLE_LEVEL=info
      - DOZZLE_TAILSIZE=300
      - DOZZLE_FILTER="status=running"
      - DOZZLE_FILTER="label=org.label-schema.group=monitoring"
```

## 📈 Performance Tuning

### Resource Limits
```yaml
services:
  prometheus:
    mem_limit: 2g
    cpus: '1.0'
    
  grafana:
    mem_limit: 1g
    cpus: '0.5'
    
  loki:
    mem_limit: 1g
    cpus: '0.5'
```

### Storage Retention
```yaml
# Prometheus retention
prometheus:
  command:
    - '--storage.tsdb.retention.time=30d'
    - '--storage.tsdb.retention.size=10GB'

# Loki retention
loki:
  config:
    limits_config:
      retention_period: 720h  # 30 days
```

## 🔒 Security Hardening

### Enable Authentication
```yaml
# Grafana
GF_SECURITY_ADMIN_PASSWORD: 'strong-password'
GF_AUTH_BASIC_ENABLED: 'true'
GF_AUTH_ANONYMOUS_ENABLED: 'false'

# Prometheus (basic auth via nginx)
nginx:
  location /prometheus/ {
    auth_basic "Prometheus";
    auth_basic_user_file /etc/nginx/.htpasswd;
    proxy_pass http://prometheus:9090/;
  }
```

### Traefik Integration
```yaml
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.grafana.rule=Host(`grafana.${DOMAIN}`)"
  - "traefik.http.routers.grafana.middlewares=authelia@docker"
  - "traefik.http.services.grafana.loadbalancer.server.port=3000"
```

## 🎯 Best Practices

1. **Regular Backups**
   ```bash
   # Backup Grafana dashboards
   curl -X GET http://admin:admin@localhost:3000/api/dashboards/db > dashboards-backup.json
   
   # Backup Prometheus data
   docker exec prometheus promtool tsdb snapshot /prometheus
   ```

2. **Monitor the Monitors**
   - Set up alerts for monitoring stack health
   - Use Uptime Kuma to monitor Grafana/Prometheus

3. **Log Rotation**
   - Configure log rotation for all services
   - Use Loki retention policies

4. **Dashboard Organization**
   - Create folders for different service categories
   - Use tags for easy searching
   - Version control dashboard JSON

## 📚 Troubleshooting

### Common Issues

**Grafana can't connect to Prometheus**
```bash
# Check network connectivity
docker exec grafana curl http://prometheus:9090/api/v1/query

# Verify data source configuration
curl -X GET http://admin:admin@localhost:3000/api/datasources
```

**High memory usage**
```bash
# Check Prometheus cardinality
curl http://localhost:9090/api/v1/label/__name__/values | jq '. | length'

# Reduce scrape frequency or retention
```

**Missing metrics**
```bash
# Verify exporters are running
docker ps | grep exporter

# Check Prometheus targets
curl http://localhost:9090/api/v1/targets
```

---

**Support**: [Discord](https://discord.gg/Pc7mXX786x) | [Documentation](https://mjashley.atlassian.net/wiki/spaces/DO)