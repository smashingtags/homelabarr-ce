#!/bin/bash

# HomelabARR Local-Persist Plugin Installation Script
# This script installs the local-persist plugin as a managed Docker plugin

set -e

echo "==========================================="
echo "Installing Local-Persist Docker Plugin"
echo "==========================================="

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo "ERROR: Docker is not running or not accessible"
    exit 1
fi

# Remove existing plugin if it exists
if docker plugin ls | grep -q "local-persist"; then
    echo "Removing existing local-persist plugin..."
    docker plugin disable local-persist 2>/dev/null || true
    docker plugin rm local-persist 2>/dev/null || true
fi

# Install the plugin from Docker Hub
echo "Installing local-persist plugin..."
docker plugin install cwspear/docker-local-persist-volume-plugin:latest \
    --grant-all-permissions \
    --alias local-persist

# Verify installation
echo "Verifying plugin installation..."
if docker plugin ls | grep -q "local-persist.*true"; then
    echo "✅ Local-persist plugin installed successfully!"
    echo ""
    echo "Plugin details:"
    docker plugin ls | grep local-persist
    echo ""
    echo "Usage example:"
    echo "docker volume create -d local-persist -o mountpoint=/opt/appdata/myapp --name myapp-data"
else
    echo "❌ Plugin installation failed"
    exit 1
fi

echo ""
echo "==========================================="
echo "Installation Complete!"
echo "==========================================="
