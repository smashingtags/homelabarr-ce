---
title: "HomelabARR-CLI : 2025.08.19 HomelabARR CLI Monitoring Stack and Grafana Dashboards"
confluence_id: "6619137"
confluence_url: "https://mjashley.atlassian.net/wiki/spaces/DO/pages/6619137"
confluence_space: "DO"
category: "Monitoring"
created_date: ""
updated_date: ""
migrated_date: "2025-09-14"
tags: ['frontend', 'media-server', 'docker', 'traefik', 'golang', 'servarr', 'security', 'authelia', 'monitoring', 'storage']
---

# HomelabARR CLI Monitoring Stack and Grafana Dashboards

## Executive Summary

HomelabARR CLI includes a comprehensive monitoring and observability stack with pre-built Grafana dashboards, real-time metrics collection, and integrated alerting systems. This document details the monitoring infrastructure, available dashboards, and expansion roadmap.
## Monitoring Architecture

### Core Components

#### 1.**Grafana**- Visualization and Analytics

- **Purpose:**Primary dashboard platform for metrics visualization
- **Port:**3000 (via Traefik routing)
- **Features:**
- Pre-built dashboards for infrastructure monitoring
- Custom dashboards for application-specific metrics
- Alert management and notification routing
- Multi-user access with role-based permissions
#### 2.**Prometheus**- Metrics Collection and Storage

- **Purpose:**Time-series database and metrics aggregation
- **Port:**9090 (internal)
- **Features:**
- Container and host metrics scraping
- Service discovery for dynamic environments
- PromQL query language for advanced analytics
- Long-term metrics retention
#### 3.**Netdata**- Real-Time Performance Monitoring

- **Purpose:**Real-time system and application monitoring
- **Port:**19999 (via Traefik routing)
- **Features:**
- Per-second granularity metrics
- Zero-configuration monitoring
- Interactive web interface
- Low resource overhead
#### 4.**Uptime Kuma**- Service Availability Monitoring

- **Purpose:**HTTP/HTTPS/TCP service monitoring
- **Port:**3001 (via Traefik routing)
- **Features:**
- Service endpoint monitoring
- Downtime alerting
- Status page generation
- Multiple notification channels
## Pre-Built Grafana Dashboards

### 🖥️ Infrastructure Dashboards

#### **1. System Overview Dashboard**

- **Metrics:**CPU, Memory, Disk, Network utilization
- **Scope:**Host system and Docker daemon
- **Refresh:**30 seconds
- **Features:**
- Real-time resource usage
- Historical trends (24h/7d/30d)
- Alert thresholds and status indicators
#### **2. Docker Container Dashboard**

- **Metrics:**Container resource usage, restart counts, image sizes
- **Scope:**All HomelabARR containers
- **Refresh:**15 seconds
- **Features:**
- Per-container resource breakdown
- Container health status
- Image update notifications
#### **3. Network Performance Dashboard**

- **Metrics:**Bandwidth usage, connection counts, latency
- **Scope:**Traefik proxy and container networking
- **Features:**
- Request rates and response times
- Geographic traffic distribution
- SSL certificate expiration tracking
### 📊 Application-Specific Dashboards

#### **4. Media Server Dashboard**

- **Applications:**Plex, Jellyfin, Emby
- **Metrics:**
- Active streaming sessions
- Transcoding performance
- Library statistics
- User activity patterns
#### **5. Download Automation Dashboard**

- **Applications:**Sonarr, Radarr, Lidarr, qBittorrent, SABnzbd
- **Metrics:**
- Download queue status
- Bandwidth utilization
- Success/failure rates
- Storage usage trends
#### **6. Security and Access Dashboard**

- **Applications:**Authelia, Traefik, Fail2ban
- **Metrics:**
- Authentication attempts and failures
- Geographic access patterns
- Blocked IP addresses
- SSL/TLS security metrics
### 🔍 Service Health Dashboard

#### **7. Application Status Overview**

- **Scope:**All deployed HomelabARR applications
- **Features:**
- Service availability matrix
- Response time heatmaps
- Dependency mapping
- Incident timeline
## Metrics Collection Strategy

### Host-Level Metrics

```
`# Collected via Node Exporter
- CPU usage (per core and aggregate)
- Memory utilization and swap
- Disk I/O and space usage
- Network interface statistics
- System load averages
`
```

### Container-Level Metrics

```
`# Collected via cAdvisor
- Container CPU and memory usage
- Network and disk I/O per container
- Container restart counts
- Image layer information
`
```

### Application-Level Metrics

```
`# Collected via application exporters
- HTTP request rates and latencies
- Database connection pools
- Queue lengths and processing times
- Custom business metrics
`
```

## Alerting and Notifications

### Alert Rules Configuration

#### **Critical Alerts**

- System CPU > 90% for 5 minutes
- Memory usage > 95% for 2 minutes
- Disk space < 10% remaining
- Container restart loops (>3 restarts/hour)
- Service downtime > 1 minute
#### **Warning Alerts**

- System CPU > 80% for 10 minutes
- Memory usage > 85% for 5 minutes
- Disk space < 20% remaining
- High error rates (>5% of requests)
### Notification Channels

- **Discord Webhooks**- Real-time alerts to dedicated channels
- **Email Notifications**- Digest reports and critical alerts
- **Gotify Push Notifications**- Mobile alerts for urgent issues
- **Webhook Integration**- Custom notification endpoints
## Dashboard Expansion Roadmap

### Phase 1: Core Infrastructure (✅ Complete)

- System resource monitoring
- Container health and performance
- Network and security metrics
### Phase 2: Application Integration (🚧 In Progress)

- Media server analytics
- Download automation metrics
- User activity tracking
### Phase 3: Advanced Analytics (📋 Planned)

- Predictive capacity planning
- Performance trend analysis
- Cost optimization insights
- Security threat detection
### Phase 4: Business Intelligence (🔮 Future)

- User behavior analytics
- Content popularity metrics
- Resource optimization recommendations
- Automated scaling triggers
## Implementation Details

### Grafana Configuration

```
`# Dashboard provisioning
dashboards:
  - name: 'HomelabARR Infrastructure'
    folder: 'Infrastructure'
    type: file
    options:
      path: /etc/grafana/provisioning/dashboards

# Data source configuration
datasources:
  - name: Prometheus
    type: prometheus
    url: http://prometheus:9090
  - name: Netdata
    type: prometheus
    url: http://netdata:19999/api/v1/allmetrics?format=prometheus
`
```

### Prometheus Scrape Configuration

```
`scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'netdata'
    static_configs:
      - targets: ['netdata:19999']

  - job_name: 'docker'
    static_configs:
      - targets: ['cadvisor:8080']

  - job_name: 'traefik'
    static_configs:
      - targets: ['traefik:8080']
`
```

## Access and Security

### Authentication Integration

- **Authelia SSO**- Unified authentication for all monitoring tools
- **Role-Based Access**- Different permission levels for users
- **Audit Logging**- All access and configuration changes logged
### Network Security

- **Traefik Reverse Proxy**- SSL termination and routing
- **Internal Network**- Monitoring services on isolated Docker network
- **API Security**- Rate limiting and IP restrictions
## Performance Optimization

### Resource Allocation

- **Grafana:**512MB RAM, 0.5 CPU cores
- **Prometheus:**2GB RAM, 1 CPU core, 50GB storage
- **Netdata:**256MB RAM, 0.25 CPU cores
- **Total Overhead:**~3GB RAM, ~2 CPU cores
### Data Retention Policies

- **Real-time metrics:**1 second granularity for 6 hours
- **Short-term storage:**1 minute granularity for 7 days
- **Long-term storage:**5 minute granularity for 1 year
- **Archive storage:**1 hour granularity for 5 years
## Troubleshooting and Maintenance

### Common Issues

- **High memory usage**- Adjust retention policies
- **Missing metrics**- Check service discovery configuration
- **Slow dashboard loading**- Optimize query time ranges
- **Alert fatigue**- Fine-tune alert thresholds
### Maintenance Tasks

- Weekly dashboard review and optimization
- Monthly retention policy evaluation
- Quarterly performance capacity planning
- Annual security audit and updates
## Integration with HomelabARR CLI

### Automated Dashboard Deployment

```
`# Dashboard deployment as part of app installation
./homelabarr install monitoring
./homelabarr install grafana --with-dashboards
./homelabarr dashboard list
./homelabarr dashboard import <dashboard-name>
`
```

### Dynamic Service Discovery

- Automatic metric endpoint discovery for new applications
- Self-configuring dashboards based on detected services
- Zero-configuration monitoring for supported applications
## Future Enhancements

### Planned Features

- **AI-Powered Analytics**- Machine learning for anomaly detection
- **Mobile Dashboard App**- Dedicated mobile monitoring interface
- **Cross-Instance Monitoring**- Multi-homelab dashboard aggregation
- **Automated Remediation**- Self-healing infrastructure responses
### Community Dashboards

- **Dashboard Repository**- Community-contributed monitoring dashboards
- **Template System**- Standardized dashboard creation framework
- **Import/Export Tools**- Easy dashboard sharing and deployment
## Related Documentation

- [Grafana Official Documentation](https://grafana.com/docs/)
- [Prometheus Monitoring Guide](https://prometheus.io/docs/)
- [Netdata Configuration](https://learn.netdata.cloud/)
- [HomelabARR CLI Installation Guide](../install/linux-installation.md)

*Documentation created: August 19, 2025*
*Author: HomelabARR CLI Development Team*
*Next Review: September 19, 2025*