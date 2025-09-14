#!/bin/bash
#####################################
# HomelabARR Mode Switching System  #
# Handles switching between Local   #
# and Proxy installation modes      #
#####################################

# Configuration paths
MODE_CONFIG="/opt/homelabarr/.local_mode"
BACKUP_DIR="/opt/homelabarr/.mode-switch-backups"
SCRIPTS_DIR="/opt/homelabarr/apps/.config"
COMPOSE_DIR="/opt/appdata/compose"

# Service discovery
discover_services() {
    local services=()
    
    # Get running containers (excluding system containers)
    while IFS= read -r container; do
        if [[ ! "$container" =~ ^(traefik|authelia|cf-companion|cloudflared|dockupdater)$ ]]; then
            services+=("$container")
        fi
    done < <(docker ps --format "{{.Names}}" | grep -v '^$')
    
    echo "${services[@]}"
}

# Backup current configuration
backup_current_config() {
    local backup_timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_path="$BACKUP_DIR/$backup_timestamp"
    
    echo "📦 Creating configuration backup..."
    mkdir -p "$backup_path"
    
    # Backup compose files
    if [[ -d "$COMPOSE_DIR" ]]; then
        cp -r "$COMPOSE_DIR" "$backup_path/compose" 2>/dev/null || true
    fi
    
    # Backup environment files
    [[ -f "/opt/appdata/compose/.env" ]] && cp "/opt/appdata/compose/.env" "$backup_path/global.env" 2>/dev/null
    [[ -f "$MODE_CONFIG" ]] && cp "$MODE_CONFIG" "$backup_path/mode_config" 2>/dev/null
    
    # Backup port registry
    [[ -f "/opt/homelabarr/.port_registry" ]] && cp "/opt/homelabarr/.port_registry" "$backup_path/port_registry" 2>/dev/null
    
    # Create backup manifest
    cat > "$backup_path/manifest.txt" << EOF
HomelabARR Configuration Backup
Created: $(date)
Mode: $(get_current_mode)
Services: $(discover_services | wc -w)
EOF
    
    echo "✓ Backup created: $backup_path"
    echo "$backup_path"
}

# Get current installation mode
get_current_mode() {
    if [[ -f "$MODE_CONFIG" ]]; then
        source "$MODE_CONFIG"
        if [[ "$LOCAL_MODE_ENABLED" == "true" ]]; then
            echo "local"
        else
            echo "proxy"
        fi
    else
        # Check if Traefik is required (default behavior)
        if docker ps --format "{{.Names}}" | grep -q "^traefik$"; then
            echo "proxy"
        else
            echo "unknown"
        fi
    fi
}

# Validate mode switch prerequisites
validate_switch_prerequisites() {
    local target_mode="$1"
    local errors=0
    
    echo "🔍 Validating prerequisites for $target_mode mode..."
    
    case "$target_mode" in
        "proxy")
            # Check for Traefik and Authelia
            if ! docker ps --format "{{.Names}}" | grep -q "^traefik$"; then
                echo "❌ Traefik container not found"
                echo "   Install Traefik before switching to proxy mode"
                ((errors++))
            fi
            
            # Check for domain configuration
            if [[ -f "/opt/appdata/compose/.env" ]]; then
                source "/opt/appdata/compose/.env"
                if [[ -z "$DOMAIN" ]]; then
                    echo "❌ Domain not configured"
                    echo "   Set DOMAIN variable in environment"
                    ((errors++))
                fi
                
                if [[ -z "$CLOUDFLARE_EMAIL" || -z "$CLOUDFLARE_API_KEY" ]]; then
                    echo "❌ Cloudflare credentials not configured"
                    echo "   Set CLOUDFLARE_EMAIL and CLOUDFLARE_API_KEY"
                    ((errors++))
                fi
            else
                echo "❌ Environment file not found"
                ((errors++))
            fi
            ;;
            
        "local")
            # Check port management system
            if ! command -v "$SCRIPTS_DIR/port-manager.sh" >/dev/null 2>&1; then
                echo "❌ Port manager not found"
                echo "   Initialize port management system first"
                ((errors++))
            fi
            
            # Check for port conflicts
            if [[ -x "$SCRIPTS_DIR/port-manager.sh" ]]; then
                if ! "$SCRIPTS_DIR/port-manager.sh" check >/dev/null 2>&1; then
                    echo "⚠️  Port conflicts detected"
                    echo "   Run port conflict resolution before switching"
                fi
            fi
            ;;
    esac
    
    # Check Docker and Docker Compose
    if ! command -v docker >/dev/null 2>&1; then
        echo "❌ Docker not found"
        ((errors++))
    fi
    
    if ! command -v docker-compose >/dev/null 2>&1; then
        echo "❌ Docker Compose not found"
        ((errors++))
    fi
    
    if [[ $errors -eq 0 ]]; then
        echo "✅ Prerequisites validation passed"
        return 0
    else
        echo "❌ Prerequisites validation failed ($errors errors)"
        return 1
    fi
}

# Stop all services gracefully
stop_services() {
    local services=($(discover_services))
    
    if [[ ${#services[@]} -eq 0 ]]; then
        echo "ℹ️  No services to stop"
        return 0
    fi
    
    echo "⏹️  Stopping ${#services[@]} services..."
    
    for service in "${services[@]}"; do
        echo "  Stopping $service..."
        docker stop "$service" >/dev/null 2>&1 || echo "    ⚠️  Failed to stop $service"
    done
    
    # Wait for graceful shutdown
    echo "⏳ Waiting for services to stop..."
    sleep 5
    
    # Check if any services are still running
    local still_running=()
    for service in "${services[@]}"; do
        if docker ps --format "{{.Names}}" | grep -q "^${service}$"; then
            still_running+=("$service")
        fi
    done
    
    if [[ ${#still_running[@]} -gt 0 ]]; then
        echo "⚠️  Some services are still running: ${still_running[*]}"
        echo "   Force stopping remaining services..."
        
        for service in "${still_running[@]}"; do
            docker kill "$service" >/dev/null 2>&1
        done
    fi
    
    echo "✅ All services stopped"
}

# Switch to local mode
switch_to_local() {
    echo "🏠 Switching to Local Mode..."
    
    # Initialize local mode systems
    echo "🔧 Initializing local mode systems..."
    
    # Initialize port management
    if [[ -x "$SCRIPTS_DIR/port-manager.sh" ]]; then
        "$SCRIPTS_DIR/port-manager.sh" init
    else
        echo "❌ Port manager not found"
        return 1
    fi
    
    # Initialize environment schema
    if [[ -x "$SCRIPTS_DIR/env-schema.sh" ]]; then
        "$SCRIPTS_DIR/env-schema.sh" init
        "$SCRIPTS_DIR/env-schema.sh" switch local
    else
        echo "❌ Environment schema manager not found"
        return 1
    fi
    
    # Update mode configuration
    cat > "$MODE_CONFIG" << 'EOF'
# HomelabARR Local Mode Configuration
LOCAL_MODE_ENABLED=true
LOCAL_INTERFACE=0.0.0.0
LOCAL_PORT_RANGE_START=8000
LOCAL_PORT_RANGE_END=9999
LOCAL_NETWORK=bridge
SWITCH_DATE=$(date)
SWITCH_REASON="Manual switch to local mode"
EOF
    
    # Regenerate all service configurations
    echo "🔄 Regenerating service configurations for local mode..."
    if [[ -x "$SCRIPTS_DIR/template-engine.sh" ]]; then
        "$SCRIPTS_DIR/template-engine.sh" generate-all
    else
        echo "❌ Template engine not found"
        return 1
    fi
    
    echo "✅ Local mode switch completed"
}

# Switch to proxy mode
switch_to_proxy() {
    echo "🌐 Switching to Proxy Mode..."
    
    # Check for Traefik
    if ! docker ps --format "{{.Names}}" | grep -q "^traefik$"; then
        echo "❌ Traefik not running. Start Traefik first."
        return 1
    fi
    
    # Initialize environment schema
    if [[ -x "$SCRIPTS_DIR/env-schema.sh" ]]; then
        "$SCRIPTS_DIR/env-schema.sh" init
        "$SCRIPTS_DIR/env-schema.sh" switch proxy
    else
        echo "❌ Environment schema manager not found"
        return 1
    fi
    
    # Update mode configuration
    cat > "$MODE_CONFIG" << 'EOF'
# HomelabARR Proxy Mode Configuration
LOCAL_MODE_ENABLED=false
PROXY_MODE_ENABLED=true
SWITCH_DATE=$(date)
SWITCH_REASON="Manual switch to proxy mode"
EOF
    
    # Regenerate all service configurations
    echo "🔄 Regenerating service configurations for proxy mode..."
    if [[ -x "$SCRIPTS_DIR/template-engine.sh" ]]; then
        "$SCRIPTS_DIR/template-engine.sh" generate-all
    else
        echo "❌ Template engine not found"
        return 1
    fi
    
    echo "✅ Proxy mode switch completed"
}

# Restart services in new mode
restart_services() {
    local services=($(discover_services))
    
    if [[ ${#services[@]} -eq 0 ]]; then
        echo "ℹ️  No services to restart"
        return 0
    fi
    
    echo "🔄 Restarting ${#services[@]} services in new mode..."
    
    # Start services one by one to handle dependencies
    for service in "${services[@]}"; do
        echo "  Starting $service..."
        
        # Check if service has a compose file
        local compose_file="$COMPOSE_DIR/${service}.yml"
        if [[ -f "$compose_file" ]]; then
            # Use docker-compose for proper service startup
            cd "$COMPOSE_DIR"
            docker-compose -f "${service}.yml" up -d 2>/dev/null || {
                echo "    ⚠️  Failed to start $service with compose, trying docker start"
                docker start "$service" >/dev/null 2>&1
            }
        else
            # Fallback to docker start
            docker start "$service" >/dev/null 2>&1 || echo "    ⚠️  Failed to start $service"
        fi
        
        # Brief pause between starts
        sleep 2
    done
    
    # Wait for services to stabilize
    echo "⏳ Waiting for services to stabilize..."
    sleep 10
    
    # Check service health
    echo "🏥 Checking service health..."
    local healthy_count=0
    local total_count=${#services[@]}
    
    for service in "${services[@]}"; do
        if docker ps --format "{{.Names}}" | grep -q "^${service}$"; then
            ((healthy_count++))
            echo "  ✅ $service is running"
        else
            echo "  ❌ $service failed to start"
        fi
    done
    
    echo ""
    echo "📊 Service Health Summary: $healthy_count/$total_count services running"
    
    if [[ $healthy_count -eq $total_count ]]; then
        echo "✅ All services restarted successfully"
        return 0
    else
        echo "⚠️  Some services failed to restart"
        return 1
    fi
}

# Generate access information
generate_access_info() {
    local mode=$(get_current_mode)
    local output_file="/opt/homelabarr/access_info.txt"
    
    echo "📋 Generating access information..."
    
    cat > "$output_file" << EOF
HomelabARR Access Information
Generated: $(date)
Mode: $mode

EOF

    if [[ "$mode" == "local" ]]; then
        # Get local server IP
        local server_ip=$(hostname -I | awk '{print $1}')
        
        echo "LOCAL MODE ACCESS:" >> "$output_file"
        echo "Services are accessible via direct IP:PORT access" >> "$output_file"
        echo "Server IP: $server_ip" >> "$output_file"
        echo "" >> "$output_file"
        echo "Service URLs:" >> "$output_file"
        
        # Get port assignments
        if [[ -x "$SCRIPTS_DIR/port-manager.sh" ]]; then
            while IFS=':' read -r service port status category description; do
                if [[ $service =~ ^[^#] ]] && [[ "$status" == "used" ]]; then
                    echo "  $service: http://$server_ip:$port" >> "$output_file"
                fi
            done < /opt/homelabarr/.port_registry
        fi
        
    else
        # Proxy mode
        echo "PROXY MODE ACCESS:" >> "$output_file"
        echo "Services are accessible via HTTPS domains" >> "$output_file"
        
        if [[ -f "/opt/appdata/compose/.env" ]]; then
            source "/opt/appdata/compose/.env"
            echo "Domain: $DOMAIN" >> "$output_file"
            echo "" >> "$output_file"
            echo "Service URLs:" >> "$output_file"
            
            # List common services
            local services=($(discover_services))
            for service in "${services[@]}"; do
                echo "  $service: https://$service.$DOMAIN" >> "$output_file"
            done
        fi
    fi
    
    echo "✅ Access information saved to: $output_file"
    echo ""
    echo "📋 Quick Access Summary:"
    head -20 "$output_file"
}

# Rollback to previous configuration
rollback_config() {
    local backup_path="$1"
    
    if [[ ! -d "$backup_path" ]]; then
        echo "❌ Backup path not found: $backup_path"
        return 1
    fi
    
    echo "⏪ Rolling back to configuration: $backup_path"
    
    # Stop services
    stop_services
    
    # Restore files
    if [[ -d "$backup_path/compose" ]]; then
        echo "🔄 Restoring compose files..."
        rm -rf "$COMPOSE_DIR"
        cp -r "$backup_path/compose" "$COMPOSE_DIR"
    fi
    
    if [[ -f "$backup_path/global.env" ]]; then
        echo "🔄 Restoring environment file..."
        cp "$backup_path/global.env" "/opt/appdata/compose/.env"
    fi
    
    if [[ -f "$backup_path/mode_config" ]]; then
        echo "🔄 Restoring mode configuration..."
        cp "$backup_path/mode_config" "$MODE_CONFIG"
    fi
    
    if [[ -f "$backup_path/port_registry" ]]; then
        echo "🔄 Restoring port registry..."
        cp "$backup_path/port_registry" "/opt/homelabarr/.port_registry"
    fi
    
    # Restart services
    restart_services
    
    echo "✅ Rollback completed"
}

# List available backups
list_backups() {
    echo "📦 Available Configuration Backups:"
    echo ""
    
    if [[ ! -d "$BACKUP_DIR" ]] || [[ $(ls -1 "$BACKUP_DIR" | wc -l) -eq 0 ]]; then
        echo "No backups found."
        return 0
    fi
    
    for backup in "$BACKUP_DIR"/*; do
        if [[ -d "$backup" ]]; then
            local backup_name=$(basename "$backup")
            local manifest_file="$backup/manifest.txt"
            
            echo "Backup: $backup_name"
            
            if [[ -f "$manifest_file" ]]; then
                while IFS= read -r line; do
                    echo "  $line"
                done < "$manifest_file"
            fi
            
            echo ""
        fi
    done
}

# Perform complete mode switch
perform_mode_switch() {
    local target_mode="$1"
    local current_mode=$(get_current_mode)
    
    if [[ "$current_mode" == "$target_mode" ]]; then
        echo "ℹ️  Already in $target_mode mode"
        return 0
    fi
    
    echo "🔄 HomelabARR Mode Switch: $current_mode → $target_mode"
    echo ""
    
    # Validate prerequisites
    if ! validate_switch_prerequisites "$target_mode"; then
        echo "❌ Mode switch aborted due to validation errors"
        return 1
    fi
    
    # Create backup
    local backup_path=$(backup_current_config)
    
    # Stop services
    stop_services
    
    # Perform the switch
    case "$target_mode" in
        "local")
            if ! switch_to_local; then
                echo "❌ Local mode switch failed, rolling back..."
                rollback_config "$backup_path"
                return 1
            fi
            ;;
        "proxy")
            if ! switch_to_proxy; then
                echo "❌ Proxy mode switch failed, rolling back..."
                rollback_config "$backup_path"
                return 1
            fi
            ;;
        *)
            echo "❌ Invalid target mode: $target_mode"
            return 1
            ;;
    esac
    
    # Restart services
    if ! restart_services; then
        echo "⚠️  Some services failed to restart"
        echo "💡 Consider manual intervention or rollback"
    fi
    
    # Generate access information
    generate_access_info
    
    echo ""
    echo "🎉 Mode switch completed successfully!"
    echo "   Current mode: $(get_current_mode)"
    echo "   Backup available at: $backup_path"
    
    return 0
}

# Interactive mode switch
interactive_mode_switch() {
    local current_mode=$(get_current_mode)
    
    echo "🔄 HomelabARR Interactive Mode Switch"
    echo ""
    echo "Current mode: $current_mode"
    echo ""
    
    case "$current_mode" in
        "local")
            echo "Available action:"
            echo "  1) Switch to Proxy Mode (requires Traefik/Authelia)"
            echo "  2) Cancel"
            ;;
        "proxy")
            echo "Available action:"
            echo "  1) Switch to Local Mode (direct port access)"
            echo "  2) Cancel"
            ;;
        "unknown")
            echo "Available actions:"
            echo "  1) Configure Local Mode"
            echo "  2) Configure Proxy Mode"
            echo "  3) Cancel"
            ;;
    esac
    
    echo ""
    read -erp "Choose option [1-3]: " choice
    
    case "$choice" in
        1)
            if [[ "$current_mode" == "local" ]]; then
                perform_mode_switch "proxy"
            elif [[ "$current_mode" == "proxy" ]]; then
                perform_mode_switch "local"
            else
                perform_mode_switch "local"
            fi
            ;;
        2)
            if [[ "$current_mode" == "unknown" ]]; then
                perform_mode_switch "proxy"
            else
                echo "Cancelled"
            fi
            ;;
        3|*)
            echo "Cancelled"
            ;;
    esac
}

# Main command processing
case "${1:-help}" in
    "switch")
        if [[ -n "$2" ]]; then
            perform_mode_switch "$2"
        else
            echo "Usage: $0 switch <local|proxy>"
        fi
        ;;
    "interactive")
        interactive_mode_switch
        ;;
    "status")
        echo "Current mode: $(get_current_mode)"
        echo "Services: $(discover_services | wc -w)"
        ;;
    "backup")
        backup_current_config
        ;;
    "rollback")
        if [[ -n "$2" ]]; then
            rollback_config "$2"
        else
            echo "Usage: $0 rollback <backup_path>"
        fi
        ;;
    "list-backups")
        list_backups
        ;;
    "access-info")
        generate_access_info
        ;;
    "validate")
        if [[ -n "$2" ]]; then
            validate_switch_prerequisites "$2"
        else
            echo "Usage: $0 validate <local|proxy>"
        fi
        ;;
    "help"|*)
        cat << 'EOF'
HomelabARR Mode Switching System

Usage:
    mode-switch.sh switch <local|proxy>        Perform mode switch
    mode-switch.sh interactive                 Interactive mode selection
    mode-switch.sh status                      Show current mode and services
    mode-switch.sh backup                      Create configuration backup
    mode-switch.sh rollback <backup_path>      Rollback to previous configuration
    mode-switch.sh list-backups                List available backups
    mode-switch.sh access-info                 Generate service access information
    mode-switch.sh validate <local|proxy>      Validate prerequisites for mode

Examples:
    # Switch to local mode
    ./mode-switch.sh switch local
    
    # Interactive mode selection
    ./mode-switch.sh interactive
    
    # Check current status
    ./mode-switch.sh status
    
    # Create backup before changes
    ./mode-switch.sh backup
    
    # Validate proxy mode requirements
    ./mode-switch.sh validate proxy

EOF
        ;;
esac
