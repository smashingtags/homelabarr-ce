---
title: "HomelabARR-CLI : 2025.08.16 HomelabARR CLI Monitoring Stack"
confluence_id: "4784170"
confluence_url: "https://your-instance.atlassian.net/wiki/spaces/DO/pages/4784170"
confluence_space: "DO"
category: "Monitoring"
created_date: "2025-08-17"
updated_date: "2025-08-17"
migrated_date: "2025-09-14"
tags: ['frontend', 'security', 'monitoring', 'docker']
---

# HomelabARR CLI Monitoring Stack

## 📊 Overview

The HomelabARR CLI Monitoring Stack provides comprehensive observability for your entire infrastructure, delivering real-time insights into system performance, application health, and security events. This professional-grade monitoring solution integrates seamlessly with the existing HomelabARR CLI ecosystem and includes advanced log visualization, automated dashboard generation, and comprehensive validation tools.
### 🎯 Core Components
ComponentPurposeAccess URLResource Usage**Grafana**Visualization & Dashboards`https://grafana.yourdomain.com`1GB RAM, 0.5 CPU**Prometheus**Metrics Collection`https://prometheus.yourdomain.com`2GB RAM, 1.0 CPU**Loki**Log Aggregation`https://loki.yourdomain.com`1GB RAM, 0.5 CPU**Promtail**Log Collection AgentInternal Service512MB RAM, 0.3 CPU**cAdvisor**Container Metrics`https://cadvisor.yourdomain.com`512MB RAM, 0.3 CPU**Node Exporter**System MetricsInternal Service256MB RAM, 0.2 CPU**Portainer**Docker Management UI`https://portainer.yourdomain.com`512MB RAM, 0.3 CPU**Dozzle**Real-time Log Viewer`https://dozzle.yourdomain.com`256MB RAM, 0.2 CPU