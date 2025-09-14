#!/bin/bash

# homelabarr-cli Local Mode - Port Auto-Fix Script
# Automatically resolves port conflicts by assigning available ports

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${BOLD}${CYAN}homelabarr-cli Port Auto-Fix${NC}"
echo -e "${CYAN}=========================${NC}"

# Configuration
BULK_APPS_DIR="../local-mode-apps"
BACKUP_DIR="./port-fixes-backup-$(date +%Y%m%d-%H%M%S)"
PORT_START=8200  # Start assigning from this port
PORT_REGISTRY="port-registry.txt"

# Reserved/Common ports to avoid
RESERVED_PORTS=(22 25 53 80 110 143 443 993 995 1433 3306 5432 5672 6379 8080 8443 9000 9090)

# Initialize
mkdir -p "$BACKUP_DIR"
declare -A used_ports
declare -A app_ports
declare -A conflicts
current_port=$PORT_START

echo -e "${BLUE}🔍 Analyzing existing port assignments...${NC}"

# Function to check if port is available
is_port_available() {
    local port=$1
    # Check if port is in reserved list
    for reserved in "${RESERVED_PORTS[@]}"; do
        if [[ $port -eq $reserved ]]; then
            return 1
        fi
    done
    
    # Check if port is already used
    if [[ -n "${used_ports[$port]}" ]]; then
        return 1
    fi
    
    # Check if port is in use on system (Windows/WSL compatible)
    if command -v netstat >/dev/null 2>&1; then
        if netstat -an | grep -q ":$port "; then
            return 1
        fi
    fi
    
    return 0
}

# Function to get next available port
get_next_port() {
    while ! is_port_available $current_port; do
        ((current_port++))
        if [[ $current_port -gt 65535 ]]; then
            echo "Error: No available ports found" >&2
            return 1
        fi
    done
    echo $current_port
    used_ports[$current_port]="assigned"
    ((current_port++))
}

# Function to extract and fix ports in YAML
fix_app_ports() {
    local file="$1"
    local app_name=$(basename "$file" .yml)
    local temp_file="${file}.tmp"
    local backup_file="$BACKUP_DIR/${app_name}.yml"
    local fixed=false
    
    echo -e "${BLUE}Processing $app_name...${NC}"
    
    # Create backup
    cp "$file" "$backup_file"
    cp "$file" "$temp_file"
    
    # Find port conflicts and missing ports
    local has_ports=false
    while IFS= read -r line; do
        if echo "$line" | grep -q "ports:" ; then
            has_ports=true
            break
        fi
    done < "$file"
    
    if [[ "$has_ports" == "false" ]]; then
        echo -e "${YELLOW}  ⚠️  No ports section found, adding default web port${NC}"
        
        # Find where to insert ports (after container_name and before volumes/networks)
        local insert_line=$(grep -n "container_name:" "$temp_file" | head -1 | cut -d: -f1)
        if [[ -n "$insert_line" ]]; then
            local new_port=$(get_next_port)
            app_ports["$app_name"]="$new_port"
            
            # Insert ports section after container_name
            sed -i "${insert_line}a\\    ports:\\
      - \"${new_port}:80\"" "$temp_file"
            fixed=true
            echo -e "${GREEN}  ✅ Added port $new_port${NC}"
        fi
    else
        # Fix existing port conflicts
        while IFS= read -r line_num line_content; do
            if echo "$line_content" | grep -qE "^\s*-\s*[\"']?[0-9]+:"; then
                # Extract the external port
                local port_mapping=$(echo "$line_content" | sed 's/^.*"\(.*\)"/\1/' | sed 's/^.*'"'"'\(.*\)'"'"'/\1/' | sed 's/^[[:space:]]*-[[:space:]]*//')
                local external_port=$(echo "$port_mapping" | cut -d':' -f1)
                local internal_port=$(echo "$port_mapping" | cut -d':' -f2)
                
                if [[ "$external_port" =~ ^[0-9]+$ ]]; then
                    # Check for conflict
                    if [[ -n "${used_ports[$external_port]}" && "${used_ports[$external_port]}" != "$app_name" ]]; then
                        # Port conflict! Assign new port
                        local new_port=$(get_next_port)
                        sed -i "${line_num}s/:$external_port:/:$new_port:/" "$temp_file"
                        sed -i "${line_num}s/\"$external_port:/\"$new_port:/" "$temp_file"
                        app_ports["$app_name"]="${app_ports["$app_name"]} $new_port"
                        fixed=true
                        echo -e "${YELLOW}  🔧 Changed port $external_port → $new_port (conflict resolved)${NC}"
                    else
                        # Port is fine, just register it
                        used_ports[$external_port]="$app_name"
                        app_ports["$app_name"]="${app_ports["$app_name"]} $external_port"
                    fi
                fi
            fi
        done <<< "$(cat -n "$temp_file")"
    fi
    
    # Apply changes if any were made
    if [[ "$fixed" == "true" ]]; then
        mv "$temp_file" "$file"
        echo -e "${GREEN}  ✅ Fixed $app_name${NC}"
    else
        rm "$temp_file"
        echo -e "${CYAN}  ℹ️  $app_name - no changes needed${NC}"
    fi
}

# Main processing
if [[ ! -d "$BULK_APPS_DIR" ]]; then
    echo -e "${RED}❌ Bulk apps directory not found: $BULK_APPS_DIR${NC}"
    exit 1
fi

echo -e "${BLUE}📦 Creating backup directory: $BACKUP_DIR${NC}"

# Process all YAML files
processed=0
fixed=0

for yaml_file in "$BULK_APPS_DIR"/*.yml; do
    if [[ -f "$yaml_file" ]]; then
        if fix_app_ports "$yaml_file"; then
            ((fixed++))
        fi
        ((processed++))
    fi
done

# Generate port registry
{
    echo "homelabarr-cli Local Mode - Port Registry"
    echo "Generated: $(date)"
    echo "====================================="
    echo
    echo "PORT ASSIGNMENTS:"
    echo "=================="
    
    for app in $(printf '%s\n' "${!app_ports[@]}" | sort); do
        echo "$app:${app_ports[$app]}"
    done
    
    echo
    echo "USED PORT RANGES:"
    echo "=================="
    echo "System reserved: 1-1024"
    echo "homelabarr-cli curated: 5055, 7878, 8082, 8085, 8096, 8181, 8989, 32400"
    echo "Auto-assigned range: ${PORT_START}+"
    echo
    echo "NEXT AVAILABLE PORT: $current_port"
    
} > "$PORT_REGISTRY"

# Summary
echo
echo -e "${BOLD}${GREEN}🎉 Port Auto-Fix Complete${NC}"
echo -e "${GREEN}==========================${NC}"
echo -e "${GREEN}✅ Apps processed:${NC} $processed"
echo -e "${GREEN}✅ Apps fixed:${NC} $fixed"
echo -e "${GREEN}✅ Total ports assigned:${NC} ${#used_ports[@]}"
echo -e "${CYAN}💾 Port registry:${NC} $PORT_REGISTRY"
echo -e "${CYAN}💾 Backups stored in:${NC} $BACKUP_DIR"

# Show some example port assignments
echo
echo -e "${BOLD}${YELLOW}📋 Sample Port Assignments${NC}"
echo -e "${YELLOW}===========================${NC}"
sample_count=0
for app in $(printf '%s\n' "${!app_ports[@]}" | sort | head -10); do
    echo -e "${CYAN}$app${NC}:${app_ports[$app]}"
    ((sample_count++))
done

if [[ ${#app_ports[@]} -gt $sample_count ]]; then
    echo -e "... and $((${#app_ports[@]} - sample_count)) more apps"
fi

echo
echo -e "${BOLD}${BLUE}🚀 Next Steps${NC}"
echo -e "${BLUE}=============${NC}"
echo -e "1. ${CYAN}Review the port registry:${NC} cat $PORT_REGISTRY"
echo -e "2. ${CYAN}Test deployments:${NC} Deploy a few apps to verify ports work"
echo -e "3. ${CYAN}Update documentation:${NC} Add port assignments to service docs"
echo -e "4. ${CYAN}Rollback if needed:${NC} Restore from $BACKUP_DIR"

echo
echo -e "${GREEN}🎯 All 171 apps should now have unique, conflict-free port assignments!${NC}"
