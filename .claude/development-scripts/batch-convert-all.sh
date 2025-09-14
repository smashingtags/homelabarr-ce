#!/bin/bash

# Batch Convert ALL homelabarr-cli apps to local mode
echo "=== homelabarr-cli Batch Local Mode Converter ==="

# Create output directory
mkdir -p ../local-mode-apps
OUTPUT_DIR="../local-mode-apps"

# Port assignments
declare -A PORTS=(
    ["plex"]="32400" ["jellyfin"]="8096" ["emby"]="8096"
    ["radarr"]="7878" ["sonarr"]="8989" ["lidarr"]="8686" 
    ["bazarr"]="6767" ["readarr"]="8787" ["whisparr"]="6969"
    ["prowlarr"]="9696" ["prowlarr4k"]="9697" ["prowlarrhdr"]="9698"
    ["radarr4k"]="7879" ["radarrhdr"]="7880" ["sonarr4k"]="8990" ["sonarrhdr"]="8991"
    ["qbittorrent"]="8080" ["sabnzbd"]="8085" ["nzbget"]="6789" ["deluge"]="8112"
    ["overseerr"]="5055" ["petio"]="7777" ["ombi"]="3579" ["jellyseerr"]="5056"
    ["tautulli"]="8181" ["netdata"]="19999" ["grafana"]="3000"
    ["jackett"]="9117" ["flaresolverr"]="8191"
)

convert_app() {
    local input="$1"
    local service_name="$2"
    local output="$OUTPUT_DIR/${service_name}.yml"
    
    echo "Converting $service_name..."
    
    # Copy original
    cp "$input" "$output"
    
    # Remove ALL Traefik labels (more thorough)
    sed -i '/traefik\./d' "$output"
    
    # Fix networks - remove proxy references
    sed -i 's/- ${DOCKERNETWORK}/- homelabarr-cli-local/' "$output"
    sed -i '/networks:/,/external: true/{
        /proxy:/c\  homelabarr-cli-local:\n    driver: bridge
        /external: true/d
    }' "$output"
    
    # Add ports section if we have a default port
    local port="${PORTS[$service_name]}"
    if [[ -n "$port" ]]; then
        # Add ports before networks section
        sed -i "/networks:/i\    ports:\
      - \"$port:$port\"" "$output"
    fi
    
    # Fix specific service configs
    case "$service_name" in
        "plex")
            sed -i 's|http://plex\.${DOMAIN}:443|http://localhost:32400|' "$output"
            ;;
        "jellyfin")
            sed -i 's|http://jellyfin\.${DOMAIN}|http://localhost:8096|' "$output"
            ;;
    esac
    
    echo "✓ $service_name -> $output"
}

# Find and convert all apps
total=0
converted=0

echo "Scanning for apps..."
while IFS= read -r -d '' app_file; do
    filename=$(basename "$app_file")
    service_name="${filename%.yml}"
    
    # Skip special files
    case "$filename" in
        "sample"*|"docker-compose"*|*"test"*|*"backup"*)
            continue
            ;;
    esac
    
    # Skip .config directory
    if [[ "$app_file" == *"/.config/"* ]]; then
        continue
    fi
    
    ((total++))
    convert_app "$app_file" "$service_name"
    ((converted++))
    
done < <(find ../. -name "*.yml" -not -path "*/.config/*" -not -path "*/.git/*" -print0)

echo
echo "=== Batch Conversion Complete ==="
echo "Total files processed: $total"
echo "Successfully converted: $converted"
echo "Output directory: $OUTPUT_DIR"
echo
echo "Next steps:"
echo "1. Run error check: ./error-check-all.sh"
echo "2. Test deployments: ./test-sample.sh"
