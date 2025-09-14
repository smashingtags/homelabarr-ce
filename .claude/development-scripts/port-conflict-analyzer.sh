#!/bin/bash

# homelabarr-cli Local Mode - Port Conflict Analyzer
# Scans all 171 bulk converted apps for port conflicts and suggests fixes

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${BOLD}${CYAN}homelabarr-cli Port Conflict Analyzer${NC}"
echo -e "${CYAN}=================================${NC}"

# Directories
BULK_APPS_DIR="../local-mode-apps"
OUTPUT_FILE="port-analysis-$(date +%Y%m%d-%H%M%S).txt"

# Initialize arrays
declare -A port_map
declare -A service_ports
declare -a conflicts
declare -a missing_ports

echo -e "${BLUE}🔍 Scanning 171 bulk converted applications...${NC}"

# Function to extract ports from YAML
extract_ports() {
    local file="$1"
    local app_name=$(basename "$file" .yml)
    
    # Extract port mappings (look for patterns like "8080:80" or "${VAR}:80")
    local ports=$(grep -E "^[[:space:]]*-[[:space:]]*[\"']?[0-9]" "$file" 2>/dev/null | \
                 sed 's/^.*"\([^"]*\)".*/\1/' | \
                 sed "s/^.*'\([^']*\)'.*/\1/" | \
                 sed 's/^[[:space:]]*-[[:space:]]*//' || true)
    
    if [[ -n "$ports" ]]; then
        while IFS= read -r port_mapping; do
            # Extract external port (before the colon)
            local external_port=$(echo "$port_mapping" | cut -d':' -f1 | sed 's/[${}"]*//g')
            
            # Skip if it's a variable or empty  
            if [[ "$external_port" =~ ^[0-9]+$ ]] && [[ -n "$external_port" ]]; then
                service_ports["$app_name"]="${service_ports["$app_name"]} $external_port"
                
                # Check for conflicts
                if [[ -n "${port_map[$external_port]}" ]]; then
                    conflicts+=("Port $external_port: ${port_map[$external_port]} vs $app_name")
                else
                    port_map["$external_port"]="$app_name"
                fi
            fi
        done <<< "$ports"
    else
        missing_ports+=("$app_name")
    fi
}

# Scan all YAML files
if [[ -d "$BULK_APPS_DIR" ]]; then
    file_count=0
    for yaml_file in "$BULK_APPS_DIR"/*.yml; do
        if [[ -f "$yaml_file" ]]; then
            extract_ports "$yaml_file"
            ((file_count++))
        fi
    done
    
    echo -e "${GREEN}✅ Scanned $file_count YAML files${NC}"
else
    echo -e "${RED}❌ Bulk apps directory not found: $BULK_APPS_DIR${NC}"
    exit 1
fi

# Generate report
{
    echo "homelabarr-cli Local Mode - Port Conflict Analysis Report"
    echo "Generated: $(date)"
    echo "========================================================"
    echo
    
    echo "SUMMARY:"
    echo "--------"
    echo "Total apps scanned: $file_count"
    echo "Apps with defined ports: $((file_count - ${#missing_ports[@]}))"
    echo "Apps missing ports: ${#missing_ports[@]}"
    echo "Port conflicts detected: ${#conflicts[@]}"
    echo "Unique ports in use: ${#port_map[@]}"
    echo
    
    if [[ ${#conflicts[@]} -gt 0 ]]; then
        echo "CRITICAL - PORT CONFLICTS DETECTED:"
        echo "==================================="
        for conflict in "${conflicts[@]}"; do
            echo "⚠️  $conflict"
        done
        echo
    else
        echo "✅ No port conflicts detected!"
        echo
    fi
    
    if [[ ${#missing_ports[@]} -gt 0 ]]; then
        echo "APPS WITHOUT PORT DEFINITIONS:"
        echo "=============================="
        for app in "${missing_ports[@]}"; do
            echo "❓ $app"
        done
        echo
    fi
    
    echo "PORT ASSIGNMENTS BY SERVICE:"
    echo "============================"
    for app in $(printf '%s\n' "${!service_ports[@]}" | sort); do
        echo "$app:${service_ports[$app]}"
    done
    echo
    
    echo "USED PORTS (sorted):"
    echo "===================="
    for port in $(printf '%s\n' "${!port_map[@]}" | sort -n); do
        echo "Port $port: ${port_map[$port]}"
    done
    
} > "$OUTPUT_FILE"

# Display summary
echo
echo -e "${BOLD}${YELLOW}📊 Analysis Complete${NC}"
echo -e "${YELLOW}===================${NC}"
echo -e "${GREEN}✅ Total apps scanned:${NC} $file_count"
echo -e "${GREEN}✅ Apps with ports:${NC} $((file_count - ${#missing_ports[@]}))"
echo -e "${YELLOW}⚠️  Apps missing ports:${NC} ${#missing_ports[@]}"

if [[ ${#conflicts[@]} -gt 0 ]]; then
    echo -e "${RED}🚨 PORT CONFLICTS:${NC} ${#conflicts[@]}"
    echo
    echo -e "${BOLD}${RED}Critical Conflicts Detected:${NC}"
    for conflict in "${conflicts[@]}"; do
        echo -e "${RED}⚠️  $conflict${NC}"
    done
else
    echo -e "${GREEN}✅ Port conflicts:${NC} None detected!"
fi

echo -e "${CYAN}💾 Full report saved to:${NC} $OUTPUT_FILE"

# Suggest next steps
echo
echo -e "${BOLD}${YELLOW}🔧 Suggested Actions${NC}"
echo -e "${YELLOW}===================${NC}"

if [[ ${#conflicts[@]} -gt 0 ]]; then
    echo -e "1. ${CYAN}Fix port conflicts${NC} - Run port auto-assignment script"
    echo -e "2. ${CYAN}Review conflicts${NC} - Check the detailed report above"
    echo -e "3. ${CYAN}Test deployments${NC} - Verify fixes work correctly"
else
    echo -e "1. ${CYAN}Assign ports${NC} - Add port mappings to apps without them"
    echo -e "2. ${CYAN}Create port registry${NC} - Document all port assignments"
fi

if [[ ${#missing_ports[@]} -gt 0 ]]; then
    echo
    echo -e "${YELLOW}Apps needing port assignments:${NC}"
    for app in "${missing_ports[@]:0:10}"; do  # Show first 10
        echo -e "  • $app"
    done
    if [[ ${#missing_ports[@]} -gt 10 ]]; then
        echo -e "  ... and $((${#missing_ports[@]} - 10)) more (see full report)"
    fi
fi

echo
echo -e "${BLUE}Next: Run ./port-auto-fix.sh to automatically resolve conflicts${NC}"
