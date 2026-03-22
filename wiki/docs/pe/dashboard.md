# PE Dashboard

HomelabARR PE includes a full web dashboard built with React 19, TypeScript, and shadcn/ui. It provides real-time container management, storage monitoring, and one-click app deployment.

## Accessing the Dashboard

After starting HomelabARR PE, open your browser to:

```
http://your-server-ip:8080
```

Default credentials are set during first run.

## Dashboard Sections

### Container Management

The main dashboard shows all running containers with:

- **Status** — Running, stopped, unhealthy, with color-coded indicators
- **Resource usage** — CPU and memory per container
- **Quick actions** — Start, stop, restart, view logs, open web UI
- **Bulk operations** — Select multiple containers for batch actions
- **Real-time updates** — WebSocket pushes status changes instantly

### App Store

Browse and deploy 137+ pre-configured applications:

- **Categories** — Media servers, download clients, monitoring, security, backup, productivity, and more
- **One-click install** — Select an app, configure ports and volumes, deploy
- **Search** — Filter by name, category, or description
- **Status indicators** — See which apps are already installed

### Storage Dashboard

Visual overview of your storage infrastructure:

- **Pool capacity** — Total, used, and available across all drives
- **Drive health** — SMART data, temperature, I/O rates per drive
- **Cache status** — NVMe utilization, files pending age-out
- **SnapRAID status** — Last sync, scrub results, parity health
- **MergerFS pool** — Per-drive breakdown within the unified pool

### System Monitoring

Hardware and system metrics:

- **CPU** — Usage, temperature, load average
- **Memory** — Used, cached, available
- **Network** — Throughput per interface
- **Disk I/O** — Read/write speeds per drive

### Settings

Configuration management through the UI:

- **Storage config** — Add drives, configure cache mover rules, SnapRAID schedule
- **Network** — Traefik reverse proxy, domain configuration
- **Security** — Authelia integration, user management
- **Backup** — Scheduled backup configuration
- **Updates** — Check for new PE versions

## Tech Stack

- **React 19** with TypeScript
- **shadcn/ui** component library (51 components)
- **Tailwind CSS** for styling
- **WebSocket** for real-time updates (30-second cache TTL)
- **Vite** build system
- **Dark mode** with system preference detection

The frontend is embedded in the Go binary via `go:embed` — no separate web server needed.
