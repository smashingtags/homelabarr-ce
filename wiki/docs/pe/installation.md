# PE Installation

HomelabARR PE ships as a single binary with everything embedded — the Go backend, React frontend, all 137+ app templates, and documentation. No dependencies, no Docker required for the management layer itself.

## Quick Install

```bash
# Download the latest release
wget https://releases.homelabarr.com/latest/homelabarr
chmod +x homelabarr

# Run it
./homelabarr
```

That's it. The web dashboard is available at `http://localhost:8080`.

## System Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| OS | Ubuntu 22.04+ / Debian 12+ | Ubuntu 24.04 LTS |
| CPU | 2 cores | 4+ cores |
| RAM | 2 GB | 8+ GB (depends on containers) |
| Storage | 20 GB system | SSD for system, HDDs for array |
| Docker | 24.0+ | Latest stable |

## What's Embedded

The single binary contains:

- **Go backend** — 50+ REST API endpoints, WebSocket real-time updates
- **React 19 frontend** — shadcn/ui dashboard with dark mode
- **137+ Docker Compose templates** — pre-configured app deployments
- **Template engine** — Jinja2 processing for dynamic configurations
- **Documentation** — built-in help accessible from the dashboard

## Configuration

On first run, PE creates a configuration directory at `~/.homelabarr/` with:

```
~/.homelabarr/
├── config.yml          # Main configuration
├── state.db            # LevelDB state database
├── templates/          # Docker Compose templates (extracted from binary)
└── logs/               # Application logs
```

## Updating

```bash
# Download new version
wget https://releases.homelabarr.com/latest/homelabarr -O homelabarr-new
chmod +x homelabarr-new

# Stop current instance, swap binary, restart
mv homelabarr-new homelabarr
./homelabarr
```

Your configuration and state are preserved across updates — they live in `~/.homelabarr/`, not in the binary.

## Running as a Service

```bash
# Create systemd service
sudo tee /etc/systemd/system/homelabarr.service << 'EOF'
[Unit]
Description=HomelabARR PE
After=docker.service
Requires=docker.service

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/homelabarr server
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable homelabarr
sudo systemctl start homelabarr
```

## Next Steps

- [Storage Setup](storage.md) — Configure your drives
- [Dashboard](dashboard.md) — Tour the web UI
- [App Deployment](../apps/apps.md) — Install your first containers
