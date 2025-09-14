#!/bin/bash

# HomelabARR Native Local-Persist Installation Script
# This installs local-persist as a native system service

set -e

echo "==========================================="
echo "Installing Local-Persist as Native Service"
echo "==========================================="

# Variables
BINARY_URL="https://github.com/MatchbookLab/local-persist/releases/download/v1.3.0/local-persist-linux-amd64"
INSTALL_DIR="/usr/local/bin"
SERVICE_DIR="/etc/systemd/system"
PLUGIN_DIR="/run/docker/plugins"
DATA_DIR="/var/lib/docker/plugin-data"

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root (use sudo)"
   exit 1
fi

# Create directories
echo "Creating required directories..."
mkdir -p "$PLUGIN_DIR"
mkdir -p "$DATA_DIR"
chown docker:docker "$PLUGIN_DIR" "$DATA_DIR" 2>/dev/null || chown root:root "$PLUGIN_DIR" "$DATA_DIR"

# Download and install binary
echo "Downloading local-persist binary..."
curl -L "$BINARY_URL" -o "$INSTALL_DIR/local-persist"
chmod +x "$INSTALL_DIR/local-persist"

# Create systemd service
echo "Creating systemd service..."
cat > "$SERVICE_DIR/local-persist.service" << 'EOF'
[Unit]
Description=Local Persist Volume Plugin
After=docker.service
Requires=docker.service

[Service]
Type=simple
ExecStart=/usr/local/bin/local-persist -dbpath=/var/lib/docker/plugin-data -listen=/run/docker/plugins/local-persist.sock
Restart=always
RestartSec=5
User=root
Group=root

[Install]
WantedBy=multi-user.target
EOF

# Enable and start service
echo "Enabling and starting service..."
systemctl daemon-reload
systemctl enable local-persist.service
systemctl start local-persist.service

# Verify installation
echo "Verifying installation..."
sleep 3
if systemctl is-active --quiet local-persist.service; then
    if [ -S "$PLUGIN_DIR/local-persist.sock" ]; then
        echo "✅ Local-persist service installed and running successfully!"
        echo ""
        echo "Service status:"
        systemctl status local-persist.service --no-pager
        echo ""
        echo "Socket file:"
        ls -la "$PLUGIN_DIR/local-persist.sock"
    else
        echo "❌ Service running but socket file not found"
        exit 1
    fi
else
    echo "❌ Service failed to start"
    systemctl status local-persist.service --no-pager
    exit 1
fi

echo ""
echo "==========================================="
echo "Installation Complete!"
echo "==========================================="
