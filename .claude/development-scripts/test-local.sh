#!/bin/bash

# Quick test script for local mode
echo "=== Testing Local Mode Setup ==="

# Check Docker
echo "Checking Docker..."
if command -v docker &> /dev/null; then
    echo "✓ Docker is available"
    docker --version
else
    echo "✗ Docker not found"
fi

# Check existing services
echo -e "\nChecking existing services..."
for service in plex radarr sonarr qbittorrent; do
    if [[ -f "../$service.yml" ]] || [[ -f "../**/$service.yml" ]]; then
        echo "✓ Found $service configuration"
    else
        echo "? $service configuration not found"
    fi
done

# Test port assignments
echo -e "\n=== Port Assignment Test ==="
declare -A PORTS=(
    ["plex"]="32400"
    ["radarr"]="7878" 
    ["sonarr"]="8989"
    ["qbittorrent"]="8080"
)

for service in "${!PORTS[@]}"; do
    port="${PORTS[$service]}"
    echo "$service -> $port"
done

echo -e "\n=== Creating simple docker-compose.yml for testing ==="
cat > docker-compose-local-test.yml << 'COMPOSE_EOF'
version: '3.8'

services:
  plex-local:
    image: lscr.io/linuxserver/plex:latest
    container_name: plex-local-test
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=America/New_York
      - VERSION=docker
    ports:
      - "32400:32400"
    volumes:
      - ./test-data/plex:/config
    restart: unless-stopped
    networks:
      - local-test

  radarr-local:
    image: lscr.io/linuxserver/radarr:latest
    container_name: radarr-local-test
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=America/New_York
    ports:
      - "7878:7878"
    volumes:
      - ./test-data/radarr:/config
    restart: unless-stopped
    networks:
      - local-test

networks:
  local-test:
    driver: bridge
COMPOSE_EOF

echo "✓ Created test docker-compose.yml"
echo "✓ Local mode test setup complete"
