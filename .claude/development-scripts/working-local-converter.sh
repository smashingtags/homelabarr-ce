#!/bin/bash

# Working Local Mode Converter
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

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
    
    # Create clean output file
    {
        echo "version: '3.8'"
        echo
        echo "services:"
        
        # Extract service section and clean it up
        awk -v service="$service_name" -v port="$port" '
        BEGIN { 
            in_service = 0
            skip_until_next_section = 0
            ports_added = 0
        }
        
        # Start of service section
        /^[[:space:]]*'"$service_name"':/ { 
            print "  " service ":"
            in_service = 1 
            next 
        }
        
        # End of service section (next top-level key or networks/volumes)
        /^[[:space:]]*[^[:space:]#-].*:/ && !/^services:/ && in_service {
            if ($0 ~ /^networks:/ || $0 ~ /^volumes:/ || ($0 !~ /^[[:space:]][[:space:]]/ && $0 !~ /^[[:space:]]*#/)) {
                # Add ports before networks if not added yet
                if (!ports_added && $0 ~ /networks:/) {
                    print "    ports:"
                    print "      - \"" port ":" port "\""
                    ports_added = 1
                }
                
                # Handle networks
                if ($0 ~ /networks:/) {
                    print "    networks:"
                    print "      - homelabarr-cli-local"
                    skip_until_next_section = 1
                    next
                }
                
                # End service processing
                in_service = 0
            }
        }
        
        # Skip content until next section
        skip_until_next_section && /^[[:space:]]*[^[:space:]#-].*:/ && !/^[[:space:]][[:space:]]/ {
            skip_until_next_section = 0
        }
        
        # Process service content
        in_service && !skip_until_next_section {
            line = $0
            
            # Skip traefik labels
            if (line ~ /traefik\./) next
            
            # Skip existing ports sections
            if (line ~ /^[[:space:]]*ports:/) {
                skip_until_next_section = 1
                next
            }
            
            # Skip network references to proxy
            if (line ~ /proxy/ || line ~ /DOCKERNETWORK/) next
            
            # Add proper indentation and print
            if (line ~ /^[[:space:]]*[^[:space:]]/) {
                print "  " line
            } else {
                print line
            }
        }
        
        END {
            # Add ports at end if not added yet
            if (in_service && !ports_added) {
                print "    ports:"
                print "      - \"" port ":" port "\""
                print "    networks:"
                print "      - homelabarr-cli-local"
            }
        }
        ' "$input_file"
        
        echo
        echo "networks:"
        echo "  homelabarr-cli-local:"
        echo "    driver: bridge"
        echo
        echo "volumes:"
        echo "  unionfs:"
        echo "    driver: local-persist"
        echo "    driver_opts:"
        echo "      mountpoint: /mnt"
        
    } > "$output_file"
    
    echo -e "${GREEN}✓ $service_name converted${NC}"
}

case "${1:-help}" in
    "test")
        echo -e "${BLUE}=== Working Local Mode Converter Test ===${NC}"
        mkdir -p working-local-test
        
        # Test with Plex
        app_file="../mediaserver/plex.yml"
        if [[ -f "$app_file" ]]; then
            convert_to_local "$app_file" "working-local-test/plex-local.yml" "plex" "32400"
            
            echo -e "\n${BLUE}Testing YAML validation...${NC}"
            if docker compose -f "working-local-test/plex-local.yml" config >/dev/null 2>&1; then
                echo -e "${GREEN}✓ Plex YAML is valid${NC}"
                echo -e "\n${BLUE}Testing deployment...${NC}"
                if docker compose -f "working-local-test/plex-local.yml" up -d --dry-run >/dev/null 2>&1; then
                    echo -e "${GREEN}✓ Deployment test passed${NC}"
                else
                    echo -e "${YELLOW}⚠ Deployment test failed (expected - missing env vars)${NC}"
                fi
            else
                echo -e "${RED}✗ Plex YAML validation failed:${NC}"
                docker compose -f "working-local-test/plex-local.yml" config 2>&1 | head -n3
            fi
        else
            echo -e "${RED}✗ Plex file not found at $app_file${NC}"
        fi
        ;;
        
    "sample")
        echo -e "${BLUE}=== Converting Sample Apps ===${NC}"
        mkdir -p working-local-test
        
        success=0
        failed=0
        
        for service in "${!SERVICE_PORTS[@]}"; do
            app_file=$(find .. -name "${service}.yml" -not -path "*/.config/*" -not -path "*/.templates/*" -not -path "*/local-mode-apps/*" | head -1)
            if [[ -f "$app_file" ]]; then
                port="${SERVICE_PORTS[$service]}"
                output_file="working-local-test/${service}-local.yml"
                
                if convert_to_local "$app_file" "$output_file" "$service" "$port"; then
                    # Test the converted file
                    if docker compose -f "$output_file" config >/dev/null 2>&1; then
                        ((success++))
                        echo -e "  ${GREEN}✓ Valid YAML${NC}"
                    else
                        ((failed++))
                        echo -e "  ${RED}✗ Invalid YAML${NC}"
                    fi
                else
                    ((failed++))
                fi
            else
                echo -e "${YELLOW}⚠ Skipping $service - file not found${NC}"
            fi
        done
        
        echo -e "\n${BLUE}=== Results ===${NC}"
        echo -e "Successfully converted and validated: ${GREEN}$success${NC}"
        echo -e "Failed: ${RED}$failed${NC}"
        ;;
        
    *)
        echo "Working Local Mode Converter"
        echo
        echo "Usage: $0 <command>"
        echo "Commands:"
        echo "  test     - Test conversion with Plex"
        echo "  sample   - Convert all sample apps and validate"
        ;;
esac
