# Monitoring Stack

HomelabARR CE includes an optional monitoring stack that gives you dashboards for every container you run. Enable it from **Settings > Monitoring** in the web dashboard.

## What Gets Deployed

| Service | Purpose | Port |
|---------|---------|------|
| **Grafana** | Dashboards and visualization | 3000 (configurable) |
| **Prometheus** | Metrics collection | Internal only |
| **Node Exporter** | Host system metrics (CPU, RAM, disk, network) | Internal only |
| **cAdvisor** | Per-container metrics | Internal only |

Optional (enable "Log Collection" in settings):

| Service | Purpose | Port |
|---------|---------|------|
| **Loki** | Log aggregation | Internal only |
| **Promtail** | Log collection from all containers | Internal only |

## Signing In to Grafana

**URL:** `http://YOUR-SERVER-IP:3000`

**Default login:** Username `admin`, Password `admin`

!!! danger "Change your Grafana password"
    The default Grafana credentials are separate from your HomelabARR login. Change them on first login: click the user icon (bottom left) > Profile > Change Password.

## Pre-loaded Dashboards

Four dashboards are pre-loaded and starred for the admin user:

| Dashboard | What it shows |
|-----------|--------------|
| **HomelabARR Overview** | System health, container CPU, storage, network traffic |
| **Node Exporter** | Detailed host metrics — CPU cores, memory, disk I/O, network interfaces |
| **cAdvisor** | Per-container resource usage — CPU, memory, network, block I/O |
| **Promtail** | Log pipeline health (requires Log Collection enabled) |

Find your starred dashboards from the Grafana home page or the star icon in the left sidebar.

## Enabling Monitoring

1. Sign in to HomelabARR CE
2. Click your username > **Settings**
3. Go to the **Monitoring** tab
4. Click **Enable Monitoring Stack**
5. Optionally enable **Log Collection** for container log aggregation
6. Wait for containers to start (~30 seconds)
7. Click **Open Grafana** or go to `http://YOUR-SERVER-IP:3000`

## Disabling Monitoring

Same path: Settings > Monitoring > Disable. All monitoring containers are stopped and removed. Your data volumes are preserved — re-enabling restores your history.

## Resource Usage

| Configuration | Containers | Estimated RAM |
|--------------|------------|---------------|
| Core monitoring | 4 | ~500 MB |
| Core + Log Collection | 6 | ~800 MB |

## Navigation

Every dashboard has a navigation bar at the top linking to all other dashboards: **Overview | System | Containers | Logs**. No need to dig through Grafana's menus.
