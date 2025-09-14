#!/bin/bash

# Test deploy sample converted apps
echo "=== Testing Sample Converted Apps ==="

OUTPUT_DIR="../local-mode-apps"

# Create test environment file
cat > .env.test << 'ENVEOF'
PUID=1000
PGID=1000
TZ=America/New_York
UMASK=022
RESTARTAPP=unless-stopped
APPFOLDER=./test-data
ID=1000
SECURITYOPS=no-new-privileges
SECURITYOPSSET=true
PLEXIMAGE=lscr.io/linuxserver/plex:latest
RADARRIMAGE=lscr.io/linuxserver/radarr:latest
SONARRIMAGE=lscr.io/linuxserver/sonarr:latest
QBITORRENTIMAGE=lscr.io/linuxserver/qbittorrent:latest
OVERSEERRIMAGE=lscr.io/linuxserver/overseerr:latest
TAUTULLIIMAGE=lscr.io/linuxserver/tautulli:latest
ENVEOF

# Test apps (popular ones)
test_apps=("plex" "radarr" "sonarr" "qbittorrent" "overseerr" "tautulli")

echo "Testing ${#test_apps[@]} popular apps..."
echo

for app in "${test_apps[@]}"; do
    yaml_file="$OUTPUT_DIR/${app}.yml"
    
    if [[ ! -f "$yaml_file" ]]; then
        echo "✗ $app - File not found"
        continue
    fi
    
    echo "Testing $app deployment..."
    
    # Create app data directory
    mkdir -p "test-data/$app"
    
    # Test YAML syntax with environment
    if docker compose --env-file .env.test -f "$yaml_file" config >/dev/null 2>/dev/null; then
        echo "✓ $app - YAML valid with environment"
        
        # Try to pull the image (don't start to avoid port conflicts)
        service_name=$(grep "image:" "$yaml_file" | head -1 | awk '{print $2}' | tr -d '"')
        if [[ -n "$service_name" ]]; then
            echo "  Image: $service_name"
        fi
    else
        echo "✗ $app - YAML issues remain"
    fi
    echo
done

echo "=== Test Summary ==="
echo "Environment file: .env.test"
echo "Data directories: test-data/"
echo
echo "To deploy an app:"
echo "  docker compose --env-file .env.test -f ../local-mode-apps/APP.yml up -d"
