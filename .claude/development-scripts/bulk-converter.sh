#!/bin/bash

# Quick Bulk Converter for homelabarr-cli Local Mode
echo "=== homelabarr-cli Bulk Local Mode Converter ==="

# Sample service ports
declare -A PORTS=(
    ["plex"]="32400" ["jellyfin"]="8096" ["emby"]="8096"
    ["radarr"]="7878" ["sonarr"]="8989" ["lidarr"]="8686"
    ["qbittorrent"]="8080" ["sabnzbd"]="8085" ["deluge"]="8112"
    ["overseerr"]="5055" ["tautulli"]="8181" ["ombi"]="3579"
)

convert_app() {
    local input="$1" 
    local output="$2"
    local service="$3"
    
    # Copy and modify
    cp "$input" "$output"
    
    # Remove Traefik labels
    sed -i '/traefik\./d' "$output"
    
    # Change network
    sed -i 's/- ${DOCKERNETWORK}/- bridge/' "$output"
    
    # Add port if we know it
    local port="${PORTS[$service]}"
    if [[ -n "$port" ]]; then
        sed -i "/networks:/i\    ports:\
      - \"$port:$port\"" "$output"
    fi
    
    echo "✓ $service -> $output (port: ${port:-auto})"
}

case "${1:-preview}" in
    "test")
        echo "Converting 10 popular apps for testing..."
        mkdir -p local-apps-test
        
        apps=("plex" "radarr" "sonarr" "qbittorrent" "overseerr" "tautulli" "jellyfin" "lidarr" "bazarr" "ombi")
        
        for app in "${apps[@]}"; do
            input="../**/${app}.yml"
            if ls $input 1> /dev/null 2>&1; then
                for file in $input; do
                    convert_app "$file" "local-apps-test/${app}-local.yml" "$app"
                    break  # Take first match
                done
            else
                echo "? $app not found"
            fi
        done
        
        echo "✓ Test conversion complete - check local-apps-test/"
        ;;
    "preview")
        echo "Available apps with default ports:"
        for service in "${!PORTS[@]}"; do
            printf "%-15s %s\n" "$service" "${PORTS[$service]}"
        done | sort
        echo
        echo "Run './bulk-converter.sh test' to convert 10 popular apps"
        ;;
    *)
        echo "Usage: $0 [preview|test]"
        ;;
esac
