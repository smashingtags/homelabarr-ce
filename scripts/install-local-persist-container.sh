#!/bin/bash

# HomelabARR Local-Persist Container Installation Script
# This script deploys the local-persist plugin as a container using the GHCR image

set -e

echo "==========================================="
echo "Installing Local-Persist Container"
echo "==========================================="

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo "ERROR: Docker is not running or not accessible"
    exit 1
fi

# Check if docker-compose is available
if ! command -v docker-compose >/dev/null 2>&1 && ! docker compose version >/dev/null 2>&1; then
    echo "ERROR: Docker Compose is not available"
    exit 1
fi

# Set the compose file path
COMPOSE_FILE="/opt/homelabarr/apps/local-mode-apps/local-persist-fixed.yml"

# Check if compose file exists
if [ ! -f "$COMPOSE_FILE" ]; then
    echo "ERROR: Compose file not found at $COMPOSE_FILE"
    echo "Please ensure HomelabARR is properly installed"
    exit 1
fi

# Create required directories with proper permissions
echo "Creating required directories..."
mkdir -p /run/docker/plugins
mkdir -p /var/lib/docker/plugin-data
mkdir -p /opt/appdata
chmod 755 /run/docker/plugins
chmod 755 /var/lib/docker/plugin-data
chmod 755 /opt/appdata

# Create homelabarr-local network if it doesn't exist
if ! docker network ls | grep -q "homelabarr-local"; then
    echo "Creating homelabarr-local network..."
    docker network create homelabarr-local
fi

# Stop existing local-persist container if running
echo "Stopping existing local-persist container..."
docker stop homelabarr-local-persist 2>/dev/null || true
docker rm homelabarr-local-persist 2>/dev/null || true

# Pull the latest image
echo "Pulling latest local-persist image..."
docker pull ghcr.io/smashingtags/local-persist:latest

# Deploy the container
echo "Deploying local-persist container..."
cd "$(dirname "$COMPOSE_FILE")"
if command -v docker-compose >/dev/null 2>&1; then
    docker-compose -f local-persist-fixed.yml up -d
else
    docker compose -f local-persist-fixed.yml up -d
fi

# Wait for container to start
echo "Waiting for local-persist to start..."
sleep 5

# Verify installation
echo "Verifying container deployment..."
if docker ps | grep -q "homelabarr-local-persist"; then
    echo "✅ Local-persist container deployed successfully!"
    echo ""
    echo "Container status:"
    docker ps | grep homelabarr-local-persist
    echo ""
    echo "Checking plugin socket..."
    if docker exec homelabarr-local-persist test -S /run/docker/plugins/local-persist.sock; then
        echo "✅ Plugin socket is active"
    else
        echo "⚠️  Plugin socket not found - container may still be starting"
    fi
    echo ""
    echo "Usage example:"
    echo "docker volume create -d local-persist -o mountpoint=/opt/appdata/myapp --name myapp-data"
else
    echo "❌ Container deployment failed"
    echo "Container logs:"
    docker logs homelabarr-local-persist 2>/dev/null || echo "No logs available"
    exit 1
fi

echo ""
echo "==========================================="
echo "Installation Complete!"
echo "==========================================="
echo "The local-persist plugin is now running as a container"
echo "and will automatically start with Docker."
