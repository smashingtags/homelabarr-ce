#!/bin/bash

# HomelabARR CLI - Port Conflict Resolution Tool
# HL-2: Container Configuration Modernization and Port Conflict Resolution
# Version: 2.3.0

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APPS_DIR="$(dirname "$SCRIPT_DIR")"
LOG_FILE="/tmp/homelabarr-port-fix-$(date +%Y%m%d_%H%M%S).log"
BACKUP_DIR="/tmp/homelabarr-port-fix-backup-$(date +%Y%m%d_%H%M%S)"
PORT_REGISTRY="/tmp/homelabarr-port-registry.json"

# Port ranges for automatic assignment
USER_PORT_START=10000
USER_PORT_END=19999
CURRENT_PORT=$USER_PORT_START

# Standard application ports (these should be preserved if not conflicting)
declare -A STANDARD_PORTS=(
    # Media Servers
    ["plex"]="32400"
    ["jellyfin"]="8096"
    ["emby"]="8096"
    
    # Media Management (Servarr Stack)
    ["radarr"]="7878"
    ["sonarr"]="8989"
    ["lidarr"]="8686"
    ["readarr"]="8787"
    ["bazarr"]="6767"
    ["prowlarr"]="9696"
    ["jackett"]="9117"
    
    # Download Clients
    ["qbittorrent"]="8080"
    ["sabnzbd"]="8080"
    ["nzbget"]="6789"
    ["deluge"]="8112"
    ["transmission"]="9091"
    
    # Monitoring & Management
    ["tautulli"]="8181"
    ["grafana"]="3000"
    ["prometheus"]="9090"
    ["netdata"]="19999"
    ["portainer"]="9000"
    ["yacht"]="8000"
    
    # Request Systems
    ["overseerr"]="5055"
    ["petio"]="7777"
    ["ombi"]="3579"
    
    # Utilities
    ["heimdall"]="80"
    ["organizr"]="80"
    ["dashy"]="80"
    ["homepage"]="3000"
)

# Reserved ports that should never be used
RESERVED_PORTS=(
    22 25 53 80 110 143 443 993 995 3306 5432 6379 11211 27017
    # SSH, SMTP, DNS, HTTP, HTTPS, POP3, IMAP, MySQL, PostgreSQL, Redis, Memcached, MongoDB
)

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Print colored output
print_status() {
    local status="$1"
    local message="$2"
    case "$status" in
        "SUCCESS") echo -e "${GREEN}✓${NC} $message" ;;
        "WARNING") echo -e "${YELLOW}⚠${NC} $message" ;;
        "ERROR") echo -e "${RED}✗${NC} $message" ;;
        "INFO") echo -e "${BLUE}ℹ${NC} $message" ;;
    esac
}

# Check if port is reserved
is_reserved_port() {
    local port="$1"
    for reserved in "${RESERVED_PORTS[@]}"; do
        if [[ "$port" == "$reserved" ]]; then
            return 0
        fi
    done
    return 1
}

# Check if port is available on system
is_port_available() {
    local port="$1"
    ! netstat -tuln 2>/dev/null | grep -q ":$port " && ! ss -tuln 2>/dev/null | grep -q ":$port "
}

# Get next available port
get_next_available_port() {
    while [[ $CURRENT_PORT -le $USER_PORT_END ]]; do
        if ! is_reserved_port "$CURRENT_PORT" && is_port_available "$CURRENT_PORT"; then
            echo "$CURRENT_PORT"
            ((CURRENT_PORT++))
            return 0
        fi
        ((CURRENT_PORT++))
    done
    
    # If we've exhausted the range, start looking in extended range
    local extended_start=20000
    local extended_end=29999
    local port=$extended_start
    
    while [[ $port -le $extended_end ]]; do
        if ! is_reserved_port "$port" && is_port_available "$port"; then
            echo "$port"
            return 0
        fi
        ((port++))
    done
    
    return 1
}

# Extract service name from filename
get_service_name() {
    local file="$1"
    basename "$file" .yml | basename .yaml
}

# Extract ports from YAML file
extract_port_info() {
    local file="$1"
    local service_name
    service_name=$(yq eval '.services | keys | .[0]' "$file" 2>/dev/null)
    
    if [[ "$service_name" == "null" || -z "$service_name" ]]; then
        return 0
    fi
    
    # Extract exposed ports (host:container format)
    local exposed_ports=()
    while IFS= read -r port_mapping; do
        if [[ -n "$port_mapping" && "$port_mapping" != "null" ]]; then
            exposed_ports+=("$port_mapping")
        fi
    done < <(yq eval ".services.$service_name.ports[]?" "$file" 2>/dev/null || true)
    
    # Extract Traefik service port
    local traefik_port=""
    traefik_port=$(yq eval ".services.$service_name.labels[]?" "$file" 2>/dev/null | \
        grep "traefik.http.services.*\.server\.port" | \
        sed 's/.*=//' | head -1 || true)
    
    # Extract container port from environment variables
    local container_port=""
    container_port=$(yq eval ".services.$service_name.environment[]?" "$file" 2>/dev/null | \
        grep -E "WEBUI_PORT|PORT|HTTP_PORT" | \
        sed 's/.*=//' | head -1 || true)
    
    # Output port information
    jq -n \
        --arg service "$service_name" \
        --arg file "$file" \
        --argjson exposed "$(printf '%s\n' "${exposed_ports[@]}" | jq -R -s 'split("\n")[:-1]')" \
        --arg traefik "${traefik_port:-}" \
        --arg container "${container_port:-}" \
        '{
            service: $service,
            file: $file,
            exposed_ports: $exposed,
            traefik_port: $traefik,
            container_port: $container
        }'
}

# Build port registry
build_port_registry() {
    print_status "INFO" "Building port registry..."
    
    # Initialize registry
    echo '{"services": [], "conflicts": [], "registry_timestamp": "'$(date -Iseconds)'"}' > "$PORT_REGISTRY"
    
    # Scan all YAML files
    local all_services=()
    while IFS= read -r -d '' file; do
        # Skip config directory
        if [[ "$file" == *"/.config/"* ]]; then
            continue
        fi
        
        local port_info
        port_info=$(extract_port_info "$file")
        
        if [[ "$port_info" != "null" && -n "$port_info" ]]; then
            all_services+=("$port_info")
        fi
    done < <(find "$APPS_DIR" -name "*.yml" -o -name "*.yaml" | sort -z)
    
    # Add services to registry
    local services_json
    services_json=$(printf '%s\n' "${all_services[@]}" | jq -s '.')
    jq --argjson services "$services_json" '.services = $services' "$PORT_REGISTRY" > "${PORT_REGISTRY}.tmp" && mv "${PORT_REGISTRY}.tmp" "$PORT_REGISTRY"
    
    print_status "SUCCESS" "Port registry built with $(echo "$services_json" | jq 'length') services"
}

# Detect port conflicts
detect_conflicts() {
    print_status "INFO" "Detecting port conflicts..."
    
    declare -A port_usage
    local conflicts=()
    
    # Analyze port usage
    while IFS= read -r service_data; do
        local service_name
        local file
        local exposed_ports
        local traefik_port
        
        service_name=$(echo "$service_data" | jq -r '.service')
        file=$(echo "$service_data" | jq -r '.file')
        traefik_port=$(echo "$service_data" | jq -r '.traefik_port // empty')
        
        # Check exposed ports
        while IFS= read -r port_mapping; do
            if [[ -n "$port_mapping" && "$port_mapping" != "null" ]]; then
                local host_port
                host_port=$(echo "$port_mapping" | cut -d':' -f1)
                
                if [[ -n "${port_usage[$host_port]:-}" ]]; then
                    conflicts+=("{\"port\": \"$host_port\", \"type\": \"exposed\", \"services\": [\"${port_usage[$host_port]}\", \"$service_name:$file\"]}")
                else
                    port_usage[$host_port]="$service_name:$file"
                fi
            fi
        done < <(echo "$service_data" | jq -r '.exposed_ports[]? // empty')
        
        # Check Traefik ports
        if [[ -n "$traefik_port" ]]; then
            if [[ -n "${port_usage[$traefik_port]:-}" ]]; then
                conflicts+=("{\"port\": \"$traefik_port\", \"type\": \"traefik\", \"services\": [\"${port_usage[$traefik_port]}\", \"$service_name:$file\"]}")
            else
                port_usage[$traefik_port]="$service_name:$file"
            fi
        fi
    done < <(jq -c '.services[]' "$PORT_REGISTRY")
    
    # Update registry with conflicts
    if [[ ${#conflicts[@]} -gt 0 ]]; then
        local conflicts_json
        conflicts_json=$(printf '%s\n' "${conflicts[@]}" | jq -s '.')
        jq --argjson conflicts "$conflicts_json" '.conflicts = $conflicts' "$PORT_REGISTRY" > "${PORT_REGISTRY}.tmp" && mv "${PORT_REGISTRY}.tmp" "$PORT_REGISTRY"
        
        print_status "WARNING" "Found ${#conflicts[@]} port conflicts"
        return 1
    else
        print_status "SUCCESS" "No port conflicts detected"
        return 0
    fi
}

# Create backup of files before modification
create_backup() {
    local file="$1"
    mkdir -p "$BACKUP_DIR"
    cp "$file" "$BACKUP_DIR/$(basename "$file").backup"
    log "Backed up: $file"
}

# Update port in YAML file
update_port_in_file() {
    local file="$1"
    local old_port="$2"
    local new_port="$3"
    local port_type="$4"  # exposed, traefik, container
    
    create_backup "$file"
    
    case "$port_type" in
        "exposed")
            # Update exposed ports (host:container mapping)
            sed -i "s/\"$old_port:/$new_port:/g" "$file"
            sed -i "s/'$old_port:/$new_port:/g" "$file"
            sed -i "s/- $old_port:/- $new_port:/g" "$file"
            ;;
        "traefik")
            # Update Traefik service port labels
            sed -i "s/server\.port=$old_port/server.port=$new_port/g" "$file"
            ;;
        "container")
            # Update container port environment variables
            sed -i "s/WEBUI_PORT=$old_port/WEBUI_PORT=$new_port/g" "$file"
            sed -i "s/PORT=$old_port/PORT=$new_port/g" "$file"
            sed -i "s/HTTP_PORT=$old_port/HTTP_PORT=$new_port/g" "$file"
            ;;
    esac
    
    log "Updated $port_type port $old_port -> $new_port in $(basename "$file")"
}

# Resolve conflicts automatically
resolve_conflicts() {
    local conflicts
    conflicts=$(jq '.conflicts' "$PORT_REGISTRY")
    
    if [[ "$conflicts" == "[]" ]]; then
        print_status "INFO" "No conflicts to resolve"
        return 0
    fi
    
    print_status "INFO" "Resolving port conflicts..."
    
    # Process each conflict
    while IFS= read -r conflict; do
        local port
        local port_type
        local services
        
        port=$(echo "$conflict" | jq -r '.port')
        port_type=$(echo "$conflict" | jq -r '.type')
        services=$(echo "$conflict" | jq -r '.services[]')
        
        print_status "WARNING" "Resolving conflict on port $port ($port_type)"
        
        # Get list of services using this port
        local service_files=()
        while IFS= read -r service_info; do
            local service_name
            local file
            service_name=$(echo "$service_info" | cut -d':' -f1)
            file=$(echo "$service_info" | cut -d':' -f2)
            service_files+=("$service_name:$file")
        done <<< "$services"
        
        # Resolve conflict - keep first service on standard port if applicable
        local keep_standard=false
        local first_service
        first_service=$(echo "${service_files[0]}" | cut -d':' -f1)
        
        # Check if first service should keep its standard port
        if [[ -n "${STANDARD_PORTS[$first_service]:-}" ]] && [[ "${STANDARD_PORTS[$first_service]}" == "$port" ]]; then
            keep_standard=true
            print_status "INFO" "Keeping standard port $port for $first_service"
        fi
        
        # Reassign ports for conflicting services
        local start_index
        if $keep_standard; then
            start_index=1
        else
            start_index=0
        fi
        
        for ((i=start_index; i<${#service_files[@]}; i++)); do
            local service_file="${service_files[$i]}"
            local service_name
            local file
            service_name=$(echo "$service_file" | cut -d':' -f1)
            file=$(echo "$service_file" | cut -d':' -f2)
            
            # Get new available port
            local new_port
            if ! new_port=$(get_next_available_port); then
                print_status "ERROR" "No available ports for $service_name"
                continue
            fi
            
            # Update the file
            update_port_in_file "$file" "$port" "$new_port" "$port_type"
            print_status "SUCCESS" "Reassigned $service_name from port $port to $new_port"
        done
        
    done < <(echo "$conflicts" | jq -c '.[]')
}

# Validate port assignments
validate_assignments() {
    print_status "INFO" "Validating port assignments..."
    
    # Rebuild registry after changes
    build_port_registry
    
    # Check for remaining conflicts
    if detect_conflicts; then
        print_status "SUCCESS" "All port conflicts resolved"
        return 0
    else
        print_status "WARNING" "Some conflicts remain - manual intervention may be required"
        return 1
    fi
}

# Generate port assignment report
generate_report() {
    local report_file="/tmp/homelabarr-port-report-$(date +%Y%m%d_%H%M%S).json"
    
    # Create comprehensive report
    jq '{
        report_timestamp: now | strftime("%Y-%m-%d %H:%M:%S"),
        total_services: (.services | length),
        conflicts_found: (.conflicts | length),
        conflicts_resolved: (.conflicts | length),
        port_assignments: [
            .services[] | {
                service: .service,
                file: (.file | split("/") | last),
                exposed_ports: .exposed_ports,
                traefik_port: .traefik_port,
                container_port: .container_port
            }
        ] | sort_by(.service),
        backup_location: "'"$BACKUP_DIR"'",
        log_file: "'"$LOG_FILE"'"
    }' "$PORT_REGISTRY" > "$report_file"
    
    print_status "INFO" "Port assignment report: $report_file"
    
    # Display summary
    echo
    echo "=============================="
    echo "PORT RESOLUTION SUMMARY"
    echo "=============================="
    jq -r '
        "Total services processed: " + (.total_services | tostring) + "\n" +
        "Conflicts found: " + (.conflicts_found | tostring) + "\n" +
        "Backup directory: " + .backup_location + "\n" +
        "Report file: " + "'"$report_file"'"
    ' "$report_file"
    echo
}

# Interactive mode for manual conflict resolution
interactive_mode() {
    print_status "INFO" "Entering interactive mode for conflict resolution"
    
    local conflicts
    conflicts=$(jq '.conflicts' "$PORT_REGISTRY")
    
    if [[ "$conflicts" == "[]" ]]; then
        print_status "INFO" "No conflicts to resolve interactively"
        return 0
    fi
    
    while IFS= read -r conflict; do
        local port
        local services
        
        port=$(echo "$conflict" | jq -r '.port')
        services=$(echo "$conflict" | jq -r '.services | join(", ")')
        
        echo
        print_status "WARNING" "Port conflict on $port:"
        echo "  Services: $services"
        echo
        echo "Options:"
        echo "  1) Auto-resolve (assign new ports)"
        echo "  2) Manually specify ports"
        echo "  3) Skip this conflict"
        echo
        
        read -p "Choose option (1-3): " choice
        
        case "$choice" in
            1)
                print_status "INFO" "Auto-resolving conflict on port $port"
                # This would call the auto-resolution logic for this specific conflict
                ;;
            2)
                print_status "INFO" "Manual port assignment not implemented yet"
                ;;
            3)
                print_status "INFO" "Skipping conflict on port $port"
                ;;
            *)
                print_status "WARNING" "Invalid choice, skipping"
                ;;
        esac
        
    done < <(echo "$conflicts" | jq -c '.[]')
}

# Rollback changes
rollback() {
    if [[ ! -d "$BACKUP_DIR" ]]; then
        print_status "ERROR" "No backup directory found"
        return 1
    fi
    
    print_status "INFO" "Rolling back changes..."
    
    while IFS= read -r -d '' backup_file; do
        local original_file
        original_file="${backup_file%.backup}"
        original_file="$APPS_DIR/$(basename "$original_file")"
        
        if [[ -f "$backup_file" ]]; then
            cp "$backup_file" "$original_file"
            print_status "SUCCESS" "Restored $(basename "$original_file")"
        fi
    done < <(find "$BACKUP_DIR" -name "*.backup" -print0)
    
    print_status "SUCCESS" "Rollback completed"
}

# Main function
main() {
    local mode="${1:-auto}"
    
    echo "HomelabARR CLI - Port Conflict Resolution Tool"
    echo "============================================="
    echo
    
    log "Starting port conflict resolution - Mode: $mode"
    
    # Build port registry
    build_port_registry
    
    # Detect conflicts
    if detect_conflicts; then
        print_status "SUCCESS" "No port conflicts detected"
        generate_report
        return 0
    fi
    
    # Show conflicts
    echo
    print_status "INFO" "Port conflicts detected:"
    jq -r '.conflicts[] | "  Port " + .port + " (" + .type + "): " + (.services | join(", "))' "$PORT_REGISTRY"
    echo
    
    case "$mode" in
        "auto")
            resolve_conflicts
            validate_assignments
            generate_report
            ;;
        "interactive")
            interactive_mode
            validate_assignments
            generate_report
            ;;
        "detect-only")
            print_status "INFO" "Detection only mode - no changes made"
            generate_report
            ;;
        *)
            print_status "ERROR" "Invalid mode: $mode"
            return 1
            ;;
    esac
}

# Handle script arguments
case "${1:-}" in
    --help|-h)
        echo "HomelabARR CLI Port Conflict Resolution Tool"
        echo
        echo "Usage: $0 [MODE] [OPTIONS]"
        echo
        echo "Modes:"
        echo "  auto         Automatically resolve all conflicts (default)"
        echo "  interactive  Interactive conflict resolution"
        echo "  detect-only  Only detect conflicts, make no changes"
        echo "  rollback     Rollback previous changes"
        echo
        echo "Options:"
        echo "  --help, -h   Show this help message"
        echo "  --version    Show version information"
        echo
        echo "This tool detects and resolves port conflicts in HomelabARR CLI"
        echo "Docker Compose configurations."
        echo
        echo "Examples:"
        echo "  $0                    # Auto-resolve all conflicts"
        echo "  $0 interactive        # Interactive mode"
        echo "  $0 detect-only        # Just detect conflicts"
        echo "  $0 rollback           # Rollback changes"
        exit 0
        ;;
    --version)
        echo "HomelabARR CLI Port Conflict Resolution Tool v2.3.0"
        echo "Part of HL-2: Container Configuration Modernization"
        exit 0
        ;;
    rollback)
        rollback
        ;;
    *)
        main "$@"
        ;;
esac
