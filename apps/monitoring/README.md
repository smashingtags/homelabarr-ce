# HomelabARR CLI Monitoring Stack

Comprehensive monitoring solution for HomelabARR CLI infrastructure featuring Grafana, Prometheus, Loki, and Portainer.

## Components

- **Grafana** - Visualization and dashboards at `grafana.domain.com`
- **Prometheus** - Metrics collection at `prometheus.domain.com`
- **Loki** - Log aggregation at `loki.domain.com`
- **Promtail** - Log shipping agent
- **cAdvisor** - Container metrics at `cadvisor.domain.com`
- **Node Exporter** - System metrics
- **Portainer** - Docker management UI at `portainer.domain.com`

## Pre-built Dashboards

1. **Infrastructure Overview** - System health, service status, container metrics
2. **Media Server Stack** - Plex, Sonarr, Radarr, qBittorrent monitoring
3. **Traefik & Authelia** - Proxy performance and authentication events

## Installation

1. Deploy Traefik first (required)
2. Run the apps installer: `sudo ./apps/install.sh`
3. Select `monitoring` from the category menu
4. Choose `grafana-loki-prometheus` from the app list

## Configuration

### Environment Variables
Required variables in your `.env` file:
```bash
# Grafana admin credentials
GRAFANA_ADMIN_PASSWORD=your_secure_password

# SMTP settings (optional)
SMTP_HOST=smtp.gmail.com
SMTP_USERNAME=your_email@gmail.com
SMTP_PASSWORD=your_app_password
```

### Data Sources
Auto-configured data sources:
- Prometheus: `http://prometheus:9090`
- Loki: `http://loki:3100`
- AlertManager: `http://alertmanager:9093`

### Dashboards
Dashboards auto-load into "HomelabARR CLI" folder in Grafana.

## Access URLs

All services are protected by Authelia and accessible via:
- `https://grafana.yourdomain.com` - Main monitoring interface
- `https://prometheus.yourdomain.com` - Metrics explorer
- `https://portainer.yourdomain.com` - Container management
- `https://cadvisor.yourdomain.com` - Container insights

## Data Retention

- **Prometheus**: 90 days, 10GB max
- **Loki**: 90 days with automatic cleanup
- **Container logs**: Collected from all Docker containers

## Resource Requirements

- **CPU**: ~1.5 cores total
- **Memory**: ~4GB total
- **Storage**: ~20GB for metrics and logs

## Monitoring Features

### System Monitoring
- CPU, memory, disk usage
- Network I/O and disk I/O
- System services health

### Application Monitoring  
- All HomelabARR CLI services
- Container resource usage
- Application logs and errors

### Infrastructure Monitoring
- Traefik proxy metrics
- Docker container health
- SSL certificate status

## Troubleshooting

### Service Not Starting
```bash
# Check container logs
docker logs grafana
docker logs prometheus
docker logs loki

# Verify configuration
docker-compose config
```

### Dashboard Not Loading
1. Check Grafana datasource configuration
2. Verify Prometheus targets are up
3. Check network connectivity between containers

### Missing Metrics
1. Ensure containers have monitoring labels
2. Check Prometheus scrape configuration
3. Verify service discovery is working

For support, check the HomelabARR CLI documentation or community forums.
