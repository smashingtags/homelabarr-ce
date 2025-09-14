#!/bin/bash

# Convert existing homelabarr-cli YAML to local mode
convert_to_local() {
    local input_file="$1"
    local output_file="$2"
    
    if [[ ! -f "$input_file" ]]; then
        echo "ERROR: Input file $input_file not found"
        return 1
    fi
    
    echo "Converting $input_file to local mode..."
    
    # Copy file and modify it
    cp "$input_file" "$output_file"
    
    # Remove Traefik labels
    sed -i '/traefik\./d' "$output_file"
    
    # Change network from proxy to bridge
    sed -i 's/- ${DOCKERNETWORK}/- bridge/' "$output_file"
    sed -i 's/proxy:/bridge:/' "$output_file"
    sed -i 's/external: true/driver: bridge/' "$output_file"
    
    # Add direct port mapping for common services
    local service_name=$(basename "$input_file" .yml)
    case "$service_name" in
        "plex")
            # Plex already has port 32400, just ensure it's exposed
            if ! grep -q "ports:" "$output_file"; then
                sed -i '/ports:/i\    ports:' "$output_file"
                sed -i '/ports:/a\      - "32400:32400"' "$output_file"
            fi
            # Update ADVERTISE_IP for local access
            sed -i 's/http:\/\/plex\.${DOMAIN}:443/http:\/\/${SERVER_IP:-localhost}:32400/' "$output_file"
            ;;
        "radarr")
            # Add port for radarr
            sed -i '/ports:/d' "$output_file"
            sed -i '/networks:/i\    ports:\n      - "7878:7878"' "$output_file"
            ;;
        "sonarr")
            # Add port for sonarr
            sed -i '/ports:/d' "$output_file"
            sed -i '/networks:/i\    ports:\n      - "8989:8989"' "$output_file"
            ;;
        "qbittorrent")
            # Add port for qbittorrent
            sed -i '/ports:/d' "$output_file"
            sed -i '/networks:/i\    ports:\n      - "8080:8080"' "$output_file"
            ;;
    esac
    
    echo "✓ Converted to local mode: $output_file"
}

# Test conversion with Plex
convert_to_local "../mediaserver/plex.yml" "plex-local.yml"
convert_to_local "../mediamanager/radarr.yml" "radarr-local.yml"

echo "=== Local Mode Files Created ==="
ls -la *-local.yml

echo "=== Testing Plex Local Configuration ==="
if [[ -f "plex-local.yml" ]]; then
    echo "Plex local config preview:"
    grep -A 5 -B 5 "ports:\|SERVER_IP\|32400" "plex-local.yml" || echo "No direct port config found"
fi
