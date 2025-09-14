#!/bin/bash
#####################################
# homelabarr-cli Port Management System #
# Handles port allocation and       #
# conflict detection for Local Mode #
#####################################

# Configuration paths
PORT_REGISTRY="/opt/homelabarr-cli/.port_registry"
PORT_CONFIG="/opt/homelabarr-cli/.port_config"
PORT_BACKUP="/opt/homelabarr-cli/.port_registry.backup"

# Default port ranges by service category
declare -A SERVICE_CATEGORIES=(
    ["mediaserver"]="8300-8399"
    ["downloadclients"]="8080-8199"
    ["mediamanager"]="6000-6999,7000-7999"
    ["request"]="5000-5099"
    ["addons"]="8200-8299,19000-19999"
    ["selfhosted"]="8400-8499"
    ["backup"]="8500-8599"
    ["system"]="8600-8699"
)

# Common service port mappings
declare -A DEFAULT_PORTS=(
    # Media Servers
    ["plex"]="32400"
    ["jellyfin"]="8096"
    ["emby"]="8920"
    
    # Download Clients
    ["qbittorrent"]="8080"
    ["sabnzbd"]="8081" 
    ["nzbget"]="8082"
    ["deluge"]="8112"
    ["rutorrent"]="8083"
    
    # Media Management
    ["radarr"]="7878"
    ["sonarr"]="8989"
    ["lidarr"]="8686"
    ["bazarr"]="6767"
    ["prowlarr"]="9696"
    ["tautulli"]="8181"
    ["jackett"]="9117"
    
    # Request Apps
    ["overseerr"]="5055"
    ["petio"]="7777"
    ["ombi"]="3579"
    
    # Addons & Monitoring
    ["heimdall"]="8300"
    ["dozzle"]="8888"
    ["netdata"]="19999"
    ["grafana"]="3000"
    ["prometheus"]="9090"
    ["glances"]="61208"
    
    # Self-hosted
    ["nextcloud"]="8400"
    ["bitwarden"]="8401"
    ["freshrss"]="8402"
    ["gitea"]="8403"
    
    # Backup
    ["duplicati"]="8500"
    ["restic"]="8501"
    
    # System
    ["portainer"]="9000"
    ["yacht"]="8600"
    ["watchtower"]="8601"
)

# Initialize port management system
init_port_system() {
    echo "🔧 Initializing homelabarr-cli Port Management System..."
    
    # Create directories
    mkdir -p "$(dirname "$PORT_REGISTRY")"
    mkdir -p "$(dirname "$PORT_CONFIG")"
    
    # Initialize port configuration
    if [[ ! -f "$PORT_CONFIG" ]]; then
        cat > "$PORT_CONFIG" << 'EOF'
# homelabarr-cli Port Configuration
PORT_RANGE_START=8000
PORT_RANGE_END=9999
PORT_INTERFACE=0.0.0.0
RESERVED_PORTS="22,53,80,443,8080"
AUTO_ASSIGN_PORTS=true
CONFLICT_RESOLUTION=ask
EOF
        echo "✓ Port configuration initialized"
    fi
    
    # Initialize port registry
    if [[ ! -f "$PORT_REGISTRY" ]]; then
        create_default_registry
        echo "✓ Port registry initialized"
    fi
    
    echo "✅ Port management system ready"
}

# Create default port registry
create_default_registry() {
    cat > "$PORT_REGISTRY" << 'EOF'
# homelabarr-cli Port Registry
# Format: SERVICE_NAME:PORT:STATUS:CATEGORY:DESCRIPTION
# STATUS: available, used, reserved, conflict
# CATEGORY: mediaserver, downloadclients, mediamanager, request, addons, selfhosted, backup, system

EOF
    
    # Add default port assignments
    for service in "${!DEFAULT_PORTS[@]}"; do
        local port="${DEFAULT_PORTS[$service]}"
        local category=$(get_service_category "$service")
        local description=$(get_service_description "$service")
        echo "${service}:${port}:available:${category}:${description}" >> "$PORT_REGISTRY"
    done
    
    # Sort registry by port number
    sort_registry
}

# Get service category
get_service_category() {
    local service="$1"
    
    case "$service" in
        plex|jellyfin|emby) echo "mediaserver" ;;
        qbittorrent|sabnzbd|nzbget|deluge|rutorrent) echo "downloadclients" ;;
        radarr|sonarr|lidarr|bazarr|prowlarr|tautulli|jackett) echo "mediamanager" ;;
        overseerr|petio|ombi) echo "request" ;;
        heimdall|dozzle|netdata|grafana|prometheus|glances) echo "addons" ;;
        nextcloud|bitwarden|freshrss|gitea) echo "selfhosted" ;;
        duplicati|restic) echo "backup" ;;
        portainer|yacht|watchtower) echo "system" ;;
        *) echo "other" ;;
    esac
}

# Get service description
get_service_description() {
    local service="$1"
    
    case "$service" in
        plex) echo "Plex Media Server" ;;
        jellyfin) echo "Jellyfin Media Server" ;;
        emby) echo "Emby Media Server" ;;
        qbittorrent) echo "qBittorrent Download Client" ;;
        sabnzbd) echo "SABnzbd Usenet Client" ;;
        nzbget) echo "NZBGet Usenet Client" ;;
        deluge) echo "Deluge BitTorrent Client" ;;
        radarr) echo "Radarr Movie Manager" ;;
        sonarr) echo "Sonarr TV Manager" ;;
        lidarr) echo "Lidarr Music Manager" ;;
        bazarr) echo "Bazarr Subtitle Manager" ;;
        prowlarr) echo "Prowlarr Indexer Manager" ;;
        tautulli) echo "Tautulli Plex Stats" ;;
        overseerr) echo "Overseerr Request Manager" ;;
        petio) echo "Petio Request Manager" ;;
        heimdall) echo "Heimdall Dashboard" ;;
        dozzle) echo "Dozzle Docker Logs" ;;
        netdata) echo "Netdata System Monitor" ;;
        *) echo "$service service" ;;
    esac
}

# Check if port is available
is_port_available() {
    local port="$1"
    local interface="${2:-0.0.0.0}"
    
    # Check if port is in use by system
    if command -v netstat >/dev/null 2>&1; then
        if netstat -tuln | grep -q ":${port}\b"; then
            return 1
        fi
    elif command -v ss >/dev/null 2>&1; then
        if ss -tuln | grep -q ":${port}\b"; then
            return 1
        fi
    fi
    
    # Check if port is in use by Docker containers
    if docker ps --format "{{.Ports}}" | grep -q "${port}:"; then
        return 1
    fi
    
    # Check if port is reserved
    source "$PORT_CONFIG"
    if [[ "$RESERVED_PORTS" == *"$port"* ]]; then
        return 1
    fi
    
    return 0
}

# Find available port in range
find_available_port() {
    local start_port="$1"
    local end_port="$2"
    local preferred_port="${3:-}"
    
    # Try preferred port first if specified
    if [[ -n "$preferred_port" ]] && [[ "$preferred_port" -ge "$start_port" ]] && [[ "$preferred_port" -le "$end_port" ]]; then
        if is_port_available "$preferred_port"; then
            echo "$preferred_port"
            return 0
        fi
    fi
    
    # Search for available port in range
    for ((port = start_port; port <= end_port; port++)); do
        if is_port_available "$port"; then
            echo "$port"
            return 0
        fi
    done
    
    return 1
}

# Assign port to service
assign_port() {
    local service="$1"
    local port="${2:-}"
    local force="${3:-false}"
    
    # Get current assignment if exists
    local current_port=$(get_service_port "$service")
    
    if [[ -n "$current_port" ]] && [[ "$force" != "true" ]]; then
        echo "⚠️  Service $service already has port $current_port assigned"
        echo "Use 'force' option to reassign"
        return 1
    fi
    
    # Auto-assign if no port specified
    if [[ -z "$port" ]]; then
        local category=$(get_service_category "$service")
        local range="${SERVICE_CATEGORIES[$category]}"
        
        if [[ -z "$range" ]]; then
            source "$PORT_CONFIG"
            range="${PORT_RANGE_START}-${PORT_RANGE_END}"
        fi
        
        # Parse range (handle comma-separated ranges)
        local start_port=$(echo "$range" | cut -d'-' -f1 | cut -d',' -f1)
        local end_port=$(echo "$range" | cut -d'-' -f2 | cut -d',' -f1)
        
        local preferred_port="${DEFAULT_PORTS[$service]}"
        port=$(find_available_port "$start_port" "$end_port" "$preferred_port")
        
        if [[ -z "$port" ]]; then
            echo "❌ No available ports in range $range for service $service"
            return 1
        fi
    fi
    
    # Check if port is available
    if ! is_port_available "$port"; then
        echo "❌ Port $port is not available"
        return 1
    fi
    
    # Update registry
    update_service_port "$service" "$port" "used"
    echo "✓ Assigned port $port to service $service"
    return 0
}

# Update service port in registry
update_service_port() {
    local service="$1"
    local port="$2"
    local status="$3"
    
    # Backup registry
    cp "$PORT_REGISTRY" "$PORT_BACKUP"
    
    # Remove existing entry
    grep -v "^${service}:" "$PORT_REGISTRY" > "${PORT_REGISTRY}.tmp" || true
    
    # Add new entry
    local category=$(get_service_category "$service")
    local description=$(get_service_description "$service")
    echo "${service}:${port}:${status}:${category}:${description}" >> "${PORT_REGISTRY}.tmp"
    
    # Replace registry
    mv "${PORT_REGISTRY}.tmp" "$PORT_REGISTRY"
    
    # Sort registry
    sort_registry
}

# Get assigned port for service
get_service_port() {
    local service="$1"
    
    if [[ -f "$PORT_REGISTRY" ]]; then
        grep "^${service}:" "$PORT_REGISTRY" | cut -d':' -f2 | head -1
    fi
}

# Sort registry by port number
sort_registry() {
    if [[ -f "$PORT_REGISTRY" ]]; then
        # Sort by port number (field 2)
        (head -n 5 "$PORT_REGISTRY" | grep "^#"; grep -v "^#" "$PORT_REGISTRY" | sort -t':' -k2 -n) > "${PORT_REGISTRY}.sorted"
        mv "${PORT_REGISTRY}.sorted" "$PORT_REGISTRY"
    fi
}

# Check for port conflicts
check_conflicts() {
    echo "🔍 Checking for port conflicts..."
    
    local conflicts_found=false
    local system_ports=""
    local docker_ports=""
    
    # Get system ports
    if command -v netstat >/dev/null 2>&1; then
        system_ports=$(netstat -tuln | awk 'NR>2 {split($4, a, ":"); print a[length(a)]}' | sort -n | uniq)
    elif command -v ss >/dev/null 2>&1; then
        system_ports=$(ss -tuln | awk 'NR>1 {split($5, a, ":"); print a[length(a)]}' | sort -n | uniq)
    fi
    
    # Get Docker container ports
    docker_ports=$(docker ps --format "{{.Ports}}" | grep -oE '[0-9]+:' | sed 's/://' | sort -n | uniq)
    
    # Combine all used ports
    local all_used_ports=$(echo -e "$system_ports\n$docker_ports" | sort -n | uniq | grep -E '^[0-9]+$')
    
    echo ""
    echo "CONFLICT ANALYSIS:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    printf "%-20s %-8s %-12s %-15s %s\n" "SERVICE" "PORT" "STATUS" "CATEGORY" "CONFLICT"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Check each service in registry
    while IFS=':' read -r service port status category description; do
        if [[ $service =~ ^[^#] ]] && [[ -n "$service" ]]; then  # Skip comments and empty lines
            local conflict=""
            
            if echo "$all_used_ports" | grep -q "^$port$"; then
                conflict="🚨 IN USE"
                conflicts_found=true
                # Update status to conflict
                update_service_port "$service" "$port" "conflict"
            else
                conflict="✅ Available"
            fi
            
            printf "%-20s %-8s %-12s %-15s %s\n" "$service" "$port" "$status" "$category" "$conflict"
        fi
    done < "$PORT_REGISTRY"
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    if [[ "$conflicts_found" == "true" ]]; then
        echo ""
        echo "🚨 CONFLICTS DETECTED!"
        echo "Some assigned ports are already in use."
        echo "Use 'resolve-conflicts' command to automatically reassign conflicting services."
        return 1
    else
        echo ""
        echo "✅ NO CONFLICTS FOUND"
        echo "All assigned ports are available."
        return 0
    fi
}

# Resolve port conflicts automatically
resolve_conflicts() {
    echo "🔧 Resolving port conflicts..."
    
    local resolved_count=0
    
    # Find services with conflicts
    while IFS=':' read -r service port status category description; do
        if [[ $service =~ ^[^#] ]] && [[ "$status" == "conflict" ]]; then
            echo "Resolving conflict for $service (current port: $port)"
            
            # Find new available port
            local range="${SERVICE_CATEGORIES[$category]}"
            if [[ -z "$range" ]]; then
                source "$PORT_CONFIG"
                range="${PORT_RANGE_START}-${PORT_RANGE_END}"
            fi
            
            local start_port=$(echo "$range" | cut -d'-' -f1 | cut -d',' -f1)
            local end_port=$(echo "$range" | cut -d'-' -f2 | cut -d',' -f1)
            
            local new_port=$(find_available_port "$start_port" "$end_port")
            
            if [[ -n "$new_port" ]]; then
                update_service_port "$service" "$new_port" "available"
                echo "✓ Reassigned $service from port $port to $new_port"
                ((resolved_count++))
            else
                echo "❌ Could not find available port for $service"
            fi
        fi
    done < "$PORT_REGISTRY"
    
    echo ""
    echo "✅ Resolved $resolved_count conflicts"
}

# Display port registry
show_registry() {
    local filter_category="${1:-}"
    
    echo "📋 homelabarr-cli Port Registry"
    echo ""
    
    if [[ -n "$filter_category" ]]; then
        echo "Category Filter: $filter_category"
        echo ""
    fi
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    printf "%-20s %-8s %-12s %-15s %s\n" "SERVICE" "PORT" "STATUS" "CATEGORY" "DESCRIPTION"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    while IFS=':' read -r service port status category description; do
        if [[ $service =~ ^[^#] ]] && [[ -n "$service" ]]; then  # Skip comments and empty lines
            if [[ -z "$filter_category" ]] || [[ "$category" == "$filter_category" ]]; then
                # Color code status
                local status_display="$status"
                case "$status" in
                    "available") status_display="✅ available" ;;
                    "used") status_display="🔵 used" ;;
                    "conflict") status_display="🚨 conflict" ;;
                    "reserved") status_display="🔒 reserved" ;;
                esac
                
                printf "%-20s %-8s %-12s %-15s %s\n" "$service" "$port" "$status_display" "$category" "$description"
            fi
        fi
    done < "$PORT_REGISTRY"
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# Export port assignments for external tools
export_ports() {
    local format="${1:-env}"
    local output_file="${2:-}"
    
    case "$format" in
        "env")
            # Export as environment variables
            if [[ -n "$output_file" ]]; then
                echo "# homelabarr-cli Port Assignments" > "$output_file"
                echo "# Generated on $(date)" >> "$output_file"
                echo "" >> "$output_file"
            fi
            
            while IFS=':' read -r service port status category description; do
                if [[ $service =~ ^[^#] ]] && [[ -n "$service" ]]; then
                    local var_name="DS_PORT_$(echo "$service" | tr '[:lower:]' '[:upper:]' | tr '-' '_')"
                    local export_line="export ${var_name}=${port}"
                    
                    if [[ -n "$output_file" ]]; then
                        echo "$export_line" >> "$output_file"
                    else
                        echo "$export_line"
                    fi
                fi
            done < "$PORT_REGISTRY"
            ;;
        "json")
            # Export as JSON
            echo "{"
            local first=true
            while IFS=':' read -r service port status category description; do
                if [[ $service =~ ^[^#] ]] && [[ -n "$service" ]]; then
                    if [[ "$first" == "false" ]]; then
                        echo ","
                    fi
                    echo -n "  \"$service\": {\"port\": $port, \"status\": \"$status\", \"category\": \"$category\", \"description\": \"$description\"}"
                    first=false
                fi
            done < "$PORT_REGISTRY"
            echo ""
            echo "}"
            ;;
        "csv")
            # Export as CSV
            echo "service,port,status,category,description"
            while IFS=':' read -r service port status category description; do
                if [[ $service =~ ^[^#] ]] && [[ -n "$service" ]]; then
                    echo "$service,$port,$status,$category,\"$description\""
                fi
            done < "$PORT_REGISTRY"
            ;;
    esac
}

# Main command processing
case "${1:-help}" in
    "init")
        init_port_system
        ;;
    "assign")
        if [[ -n "$2" ]]; then
            assign_port "$2" "$3" "$4"
        else
            echo "Usage: $0 assign <service> [port] [force]"
        fi
        ;;
    "check")
        check_conflicts
        ;;
    "resolve")
        resolve_conflicts
        ;;
    "show"|"list")
        show_registry "$2"
        ;;
    "export")
        export_ports "$2" "$3"
        ;;
    "get")
        if [[ -n "$2" ]]; then
            port=$(get_service_port "$2")
            if [[ -n "$port" ]]; then
                echo "$port"
            else
                echo "Service $2 not found in registry"
                exit 1
            fi
        else
            echo "Usage: $0 get <service>"
        fi
        ;;
    "available")
        if [[ -n "$2" ]]; then
            if is_port_available "$2"; then
                echo "Port $2 is available"
                exit 0
            else
                echo "Port $2 is not available"
                exit 1
            fi
        else
            echo "Usage: $0 available <port>"
        fi
        ;;
    "categories")
        echo "Available service categories:"
        for category in "${!SERVICE_CATEGORIES[@]}"; do
            echo "  $category: ${SERVICE_CATEGORIES[$category]}"
        done
        ;;
    "help"|*)
        cat << 'EOF'
homelabarr-cli Port Management System

Usage:
    port-manager.sh init                           Initialize port management system
    port-manager.sh assign <service> [port] [force]  Assign port to service
    port-manager.sh check                          Check for port conflicts
    port-manager.sh resolve                        Resolve port conflicts automatically
    port-manager.sh show [category]                Show port registry (optionally filtered)
    port-manager.sh get <service>                  Get assigned port for service
    port-manager.sh available <port>               Check if port is available
    port-manager.sh export [format] [file]         Export port assignments (env|json|csv)
    port-manager.sh categories                     Show service categories and port ranges

Examples:
    # Initialize system
    ./port-manager.sh init
    
    # Assign specific port to service
    ./port-manager.sh assign plex 32400
    
    # Auto-assign port to service
    ./port-manager.sh assign jellyfin
    
    # Check for conflicts
    ./port-manager.sh check
    
    # Show only media servers
    ./port-manager.sh show mediaserver
    
    # Export as environment variables
    ./port-manager.sh export env ports.env

EOF
        ;;
esac
