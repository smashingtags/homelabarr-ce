#!/bin/bash

# Simple Local Mode Converter - Clean approach using sed
set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Port assignments
declare -A SERVICE_PORTS=(
    ["plex"]="32400"
    ["jellyfin"]="8096"
    ["radarr"]="7878"
    ["sonarr"]="8989"
    ["qbittorrent"]="8082"
    ["overseerr"]="5055"
    ["tautulli"]="8181"
    ["lidarr"]="8686"
    ["bazarr"]="6767"
)

convert_to_local() {
    local input_file="$1"
    local output_file="$2"
    local service_name="$3"
    local port="$4"
    
    if [[ ! -f "$input_file" ]]; then
        echo -e "${RED}✗ File not found: $input_file${NC}"
        return 1
    fi
    
    echo -e "${BLUE}Converting $service_name (port $port)...${NC}"
    
    # Copy original file
    cp "$input_file" "$output_file"
    
    # Add version if missing
    if ! grep -q "^version:" "$output_file"; then
        sed -i '1i version: '\''3.8'\''\n' "$output_file"
    fi
    
    # Remove all Traefik labels
    sed -i '/traefik\./d' "$output_file"
    
    # Remove duplicate ports sections and add clean one
    sed -i '/^[[:space:]]*ports:/,/^[[:space:]]*[^[:space:]-]/ {
        /^[[:space:]]*ports:/d
        /^[[:space:]]*-.*:[0-9]/d
    }' "$output_file"
    
    # Add ports section before networks
    sed -i "/^[[:space:]]*networks:/i\\    ports:\\
      - \"$port:$port\"" "$output_file"
    
    # Fix networks - replace proxy with homelabarr-cli-local
    sed -i 's/- ${DOCKERNETWORK}/- homelabarr-cli-local/' "$output_file"
    sed -i 's/- proxy/- homelabarr-cli-local/' "$output_file"
    
    # Fix networks section at bottom
    sed -i '/^networks:/,$ {
        /proxy:/,/external: true/ {
            c\  homelabarr-cli-local:\
    driver: bridge
        }
    }' "$output_file"
    
    echo -e "${GREEN}✓ $service_name converted${NC}"
}

# Main execution
case "${1:-help}" in
    "test")
        echo -e "${BLUE}=== Simple Local Mode Converter Test ===${NC}"
        mkdir -p simple-local-test
        
        # Test with just plex first
        app_file="../mediaserver/plex.yml"
        if [[ -f "$app_file" ]]; then
            convert_to_local "$app_file" "simple-local-test/plex-local.yml" "plex" "32400"
            
            echo -e "\n${BLUE}Testing YAML validation...${NC}"
            if docker compose -f "simple-local-test/plex-local.yml" config >/dev/null 2>&1; then
                echo -e "${GREEN}✓ Plex YAML is valid${NC}"
            else
                echo -e "${RED}✗ Plex YAML validation failed:${NC}"
                docker compose -f "simple-local-test/plex-local.yml" config 2>&1 | head -n5
            fi
        else
            echo -e "${RED}✗ Plex file not found${NC}"
        fi
        ;;
        
    "sample")
        echo -e "${BLUE}=== Converting Sample Apps ===${NC}"
        mkdir -p simple-local-test
        
        converted=0
        for service in "${!SERVICE_PORTS[@]}"; do
            # Find the app file
            app_file=$(find .. -name "${service}.yml" -not -path "*/.config/*" -not -path "*/.templates/*" -not -path "*/local-mode-apps/*" | head -1)
            if [[ -f "$app_file" ]]; then
                port="${SERVICE_PORTS[$service]}"
                output_file="simple-local-test/${service}-local.yml"
                
                if convert_to_local "$app_file" "$output_file" "$service" "$port"; then
                    ((converted++))
                fi
            else
                echo -e "${YELLOW}⚠ Skipping $service - file not found${NC}"
            fi
        done
        
        echo -e "\n${GREEN}✓ Converted $converted apps${NC}"
        
        # Test validation of all converted files
        echo -e "\n${BLUE}Testing YAML validation...${NC}"
        for yaml in simple-local-test/*-local.yml; do
            if [[ -f "$yaml" ]]; then
                service=$(basename "$yaml" -local.yml)
                echo -n "  $service... "
                if docker compose -f "$yaml" config >/dev/null 2>&1; then
                    echo -e "${GREEN}✓${NC}"
                else
                    echo -e "${RED}✗${NC}"
                fi
            fi
        done
        ;;
        
    *)
        echo "Simple Local Mode Converter"
        echo
        echo "Usage: $0 <command>"
        echo "Commands:"
        echo "  test     - Test conversion with Plex only"
        echo "  sample   - Convert all sample apps"
        ;;
esac
