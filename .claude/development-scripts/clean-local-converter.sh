#!/bin/bash

# Clean Local Mode Converter - Fixes YAML issues from bulk conversion
set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Convert single app to clean local mode
clean_convert_app() {
    local input_file="$1"
    local output_file="$2" 
    local service_name="$3"
    local port="$4"
    
    if [[ ! -f "$input_file" ]]; then
        echo -e "${RED}✗ Input file not found: $input_file${NC}"
        return 1
    fi
    
    echo -e "${BLUE}Converting $service_name (port $port)...${NC}"
    
    # Start with clean YAML structure
    cat > "$output_file" << EOF
version: '3.8'

services:
  ${service_name}:
EOF
    
    # Extract service configuration, removing Traefik labels and fixing networks
    awk -v service="$service_name" -v port="$port" '
    BEGIN { in_service = 0; indent = "    " }
    
    /^[[:space:]]*[^[:space:]#-].*:/ && !/^services:/ && !/^networks:/ && !/^volumes:/ {
        if (in_service) {
            # End of service block
            in_service = 0
        }
        if ($0 ~ "^[[:space:]]*" service ":") {
            in_service = 1
            next
        }
    }
    
    in_service && !/traefik\./ && !/proxy/ {
        line = $0
        
        # Skip duplicate ports sections
        if (line ~ /^[[:space:]]*ports:/ && ports_added) {
            skip_ports = 1
            next
        }
        if (skip_ports && line ~ /^[[:space:]]*-.*:[0-9]/) {
            next
        }
        if (skip_ports && line !~ /^[[:space:]]*-/) {
            skip_ports = 0
        }
        
        # Fix networks
        if (line ~ /networks:/) {
            print indent "ports:"
            print indent "  - \"" port ":" port "\""
            ports_added = 1
            print indent "networks:"
            print indent "  - homelabarr-cli-local"
            next
        }
        if (line ~ /^[[:space:]]*-.*proxy/ || line ~ /^[[:space:]]*-.*DOCKERNETWORK/) {
            next
        }
        
        print indent line
    }
    ' "$input_file" >> "$output_file"
    
    # Add clean networks section
    cat >> "$output_file" << EOF

networks:
  homelabarr-cli-local:
    driver: bridge

volumes:
  unionfs:
    driver: local-persist
    driver_opts:
      mountpoint: /mnt
EOF
    
    echo -e "${GREEN}✓ $service_name -> $output_file${NC}"
}

# Port assignments for key services
declare -A SERVICE_PORTS=(
    ["plex"]="32400"
    ["jellyfin"]="8096"
    ["radarr"]="7878"
    ["sonarr"]="8989"
    ["qbittorrent"]="8082"  # Changed from 8080 to avoid conflicts
    ["overseerr"]="5055"
    ["tautulli"]="8181"
    ["lidarr"]="8686"
    ["bazarr"]="6767"
)

# Main conversion function
case "${1:-help}" in
    "sample")
        echo -e "${BLUE}=== Converting Sample Apps with Clean Method ===${NC}"
        mkdir -p clean-local-test
        
        count=0
        for service in "${!SERVICE_PORTS[@]}"; do
            # Find the actual app file location
            app_file=$(find .. -name "${service}.yml" -not -path "*/.config/*" -not -path "*/.templates/*" -not -path "*/local-mode-apps/*" | head -1)
            if [[ -f "$app_file" ]]; then
                output_file="clean-local-test/${service}-local.yml"
                port="${SERVICE_PORTS[$service]}"
                
                if clean_convert_app "$app_file" "$output_file" "$service" "$port"; then
                    ((count++))
                fi
            else
                echo -e "${YELLOW}⚠ Skipping $service - original file not found${NC}"
            fi
        done
        
        echo -e "\n${GREEN}✓ Converted $count sample apps to clean-local-test/${NC}"
        echo -e "${BLUE}Testing YAML validation...${NC}"
        
        # Test each file
        for yaml in clean-local-test/*.yml; do
            if [[ -f "$yaml" ]]; then
                service=$(basename "$yaml" -local.yml)
                echo -n "Testing $service... "
                if docker compose -f "$yaml" config >/dev/null 2>&1; then
                    echo -e "${GREEN}✓${NC}"
                else
                    echo -e "${RED}✗${NC}"
                    echo "  Error: $(docker compose -f "$yaml" config 2>&1 | head -n1)"
                fi
            fi
        done
        ;;
        
    "all")
        echo -e "${BLUE}=== Converting All Apps with Clean Method ===${NC}"
        echo "This would convert all 172 apps - not implemented yet"
        echo "Run '$0 sample' first to test the approach"
        ;;
        
    *)
        echo "Clean Local Mode Converter"
        echo
        echo "Usage: $0 <command>"
        echo
        echo "Commands:"
        echo "  sample   - Convert 9 sample apps with clean method" 
        echo "  all      - Convert all apps (not implemented yet)"
        echo
        echo "This script creates properly formatted YAML files for local mode deployment."
        ;;
esac
