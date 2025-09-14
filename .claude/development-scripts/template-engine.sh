#!/bin/bash
#####################################
# homelabarr-cli YAML Template Engine   #
# Generates conditional configs      #
# for Local vs Proxy modes          #
#####################################

# Configuration paths
LOCAL_MODE_CONFIG="/opt/homelabarr-cli/.local_mode"
PORT_REGISTRY="/opt/homelabarr-cli/.port_registry"
TEMPLATE_DIR="/opt/homelabarr-cli/apps/.templates"
OUTPUT_DIR="/opt/appdata/compose"

# Default configurations
DEFAULT_LOCAL_INTERFACE="0.0.0.0"
DEFAULT_NETWORK="bridge"

# Load configuration
load_config() {
    if [[ -f "$LOCAL_MODE_CONFIG" ]]; then
        source "$LOCAL_MODE_CONFIG"
    else
        LOCAL_MODE_ENABLED=false
    fi
    
    # Set defaults if not configured
    LOCAL_INTERFACE=${LOCAL_INTERFACE:-$DEFAULT_LOCAL_INTERFACE}
    LOCAL_NETWORK=${LOCAL_NETWORK:-$DEFAULT_NETWORK}
}

# Get assigned port for a service
get_service_port() {
    local service_name="$1"
    local default_port="$2"
    
    if [[ -f "$PORT_REGISTRY" ]]; then
        local assigned_port=$(grep "^${service_name}:" "$PORT_REGISTRY" | cut -d':' -f2)
        if [[ -n "$assigned_port" ]]; then
            echo "$assigned_port"
            return
        fi
    fi
    
    echo "$default_port"
}

# Generate YAML configuration based on mode
generate_config() {
    local service_name="$1"
    local template_file="$2"
    local output_file="$3"
    
    load_config
    
    if [[ ! -f "$template_file" ]]; then
        echo "❌ Template file not found: $template_file"
        return 1
    fi
    
    # Create output directory
    mkdir -p "$(dirname "$output_file")"
    
    if [[ "$LOCAL_MODE_ENABLED" == "true" ]]; then
        generate_local_config "$service_name" "$template_file" "$output_file"
    else
        generate_proxy_config "$service_name" "$template_file" "$output_file"
    fi
}

# Generate configuration for local mode
generate_local_config() {
    local service_name="$1"
    local template_file="$2"
    local output_file="$3"
    
    echo "🏠 Generating local mode configuration for $service_name"
    
    # Get service port assignment
    local service_port=$(get_service_port "$service_name" "8080")
    
    # Process template with local mode substitutions
    cat "$template_file" | \
    # Remove Traefik labels
    sed '/traefik\./d' | \
    # Remove proxy network and add local network
    sed "s/\${DOCKERNETWORK}/$LOCAL_NETWORK/" | \
    # Add port mapping - this is service-specific and needs enhancement
    process_local_ports "$service_name" "$service_port" | \
    # Remove Authelia middleware references
    sed '/chain-authelia/d' | \
    # Process other local mode specific changes
    process_local_environment "$service_name" > "$output_file"
    
    echo "✓ Local configuration generated: $output_file"
}

# Generate configuration for proxy mode  
generate_proxy_config() {
    local service_name="$1"
    local template_file="$2"
    local output_file="$3"
    
    echo "🌐 Generating proxy mode configuration for $service_name"
    
    # Simply copy template for proxy mode (existing behavior)
    cp "$template_file" "$output_file"
    
    echo "✓ Proxy configuration generated: $output_file"
}

# Process port mappings for local mode
process_local_ports() {
    local service_name="$1"
    local service_port="$2"
    local temp_file=$(mktemp)
    
    # Read input and add port mappings
    while IFS= read -r line; do
        echo "$line"
        
        # Add port mapping after ports: section
        if [[ "$line" =~ ^[[:space:]]*ports:[[:space:]]*$ ]]; then
            # Add standard port mapping
            echo "      - \"${service_port}:${service_port}\""
            
            # Add service-specific additional ports
            case "$service_name" in
                "plex")
                    echo "      - \"32400:32400\""
                    echo "      - \"3005:3005\""
                    echo "      - \"8324:8324\""
                    echo "      - \"32469:32469\""
                    echo "      - \"1900:1900/udp\""
                    echo "      - \"32410:32410/udp\""
                    echo "      - \"32412:32412/udp\""
                    echo "      - \"32413:32413/udp\""
                    echo "      - \"32414:32414/udp\""
                    ;;
                "qbittorrent")
                    echo "      - \"6881:6881\""
                    echo "      - \"6881:6881/udp\""
                    ;;
                "sabnzbd")
                    # Additional ports if needed
                    ;;
            esac
        fi
    done
    
    rm -f "$temp_file"
}

# Process environment variables for local mode
process_local_environment() {
    local service_name="$1"
    
    while IFS= read -r line; do
        # Skip domain-related environment variables in local mode
        if [[ "$line" =~ DOMAIN|ADVERTISE_IP ]]; then
            # Replace with local equivalents
            case "$service_name" in
                "plex")
                    if [[ "$line" =~ ADVERTISE_IP ]]; then
                        echo "      - \"ADVERTISE_IP=http://${LOCAL_INTERFACE}:32400\""
                        continue
                    fi
                    ;;
            esac
        fi
        
        echo "$line"
    done
}

# Create template from existing YAML
create_template() {
    local source_yaml="$1"
    local service_name="$2"
    local template_file="$3"
    
    if [[ ! -f "$source_yaml" ]]; then
        echo "❌ Source YAML not found: $source_yaml"
        return 1
    fi
    
    # Create template directory
    mkdir -p "$(dirname "$template_file")"
    
    # Create template with conditional sections
    cat > "$template_file" << 'EOF'
---
# TEMPLATE: Conditional configuration for Local/Proxy modes
# This template supports both local and proxy mode deployment
services:
EOF
    
    # Extract service definition from original YAML
    # Skip the first 3 lines (---, services:, service_name:) and add template markers
    tail -n +4 "$source_yaml" | sed 's/^  //' >> "$template_file"
    
    echo "✓ Template created: $template_file"
}

# Batch convert existing YAML files to templates
convert_existing_yamls() {
    echo "🔄 Converting existing YAML files to templates..."
    
    local apps_dir="/opt/homelabarr-cli/apps"
    local template_base="$TEMPLATE_DIR"
    
    # Create template directory structure
    mkdir -p "$template_base"
    
    # Find all YAML files and convert them
    find "$apps_dir" -name "*.yml" -type f | while read -r yaml_file; do
        # Get relative path and service name
        local rel_path=$(realpath --relative-to="$apps_dir" "$yaml_file")
        local service_name=$(basename "$yaml_file" .yml)
        local template_file="$template_base/$rel_path"
        
        # Create directory for template
        mkdir -p "$(dirname "$template_file")"
        
        # Convert to template
        echo "Converting: $yaml_file -> $template_file"
        create_template "$yaml_file" "$service_name" "$template_file"
    done
    
    echo "✓ Template conversion completed"
}

# Generate all configurations for current mode
generate_all_configs() {
    echo "🏗️  Generating all service configurations..."
    
    load_config
    
    if [[ "$LOCAL_MODE_ENABLED" == "true" ]]; then
        echo "Mode: Local (Direct Port Access)"
    else
        echo "Mode: Proxy (Traefik/Authelia)"
    fi
    
    local template_base="$TEMPLATE_DIR"
    local output_base="$OUTPUT_DIR"
    
    # Generate configurations for all templates
    find "$template_base" -name "*.yml" -type f | while read -r template_file; do
        # Get relative path and service name
        local rel_path=$(realpath --relative-to="$template_base" "$template_file")
        local service_name=$(basename "$template_file" .yml)
        local output_file="$output_base/$service_name.yml"
        
        echo "Processing: $service_name"
        generate_config "$service_name" "$template_file" "$output_file"
    done
    
    echo "✓ Configuration generation completed"
}

# Validate generated configuration
validate_config() {
    local config_file="$1"
    
    if [[ ! -f "$config_file" ]]; then
        echo "❌ Config file not found: $config_file"
        return 1
    fi
    
    # Check YAML syntax
    if command -v docker-compose >/dev/null 2>&1; then
        if docker-compose -f "$config_file" config >/dev/null 2>&1; then
            echo "✓ Configuration valid: $config_file"
            return 0
        else
            echo "❌ Configuration invalid: $config_file"
            return 1
        fi
    else
        echo "⚠️  Cannot validate (docker-compose not available)"
        return 0
    fi
}

# Main execution based on arguments
case "${1:-help}" in
    "generate")
        if [[ -n "$2" && -n "$3" && -n "$4" ]]; then
            generate_config "$2" "$3" "$4"
        else
            echo "Usage: $0 generate <service_name> <template_file> <output_file>"
        fi
        ;;
    "create-template")
        if [[ -n "$2" && -n "$3" && -n "$4" ]]; then
            create_template "$2" "$3" "$4"
        else
            echo "Usage: $0 create-template <source_yaml> <service_name> <template_file>"
        fi
        ;;
    "convert-all")
        convert_existing_yamls
        ;;
    "generate-all")
        generate_all_configs
        ;;
    "validate")
        if [[ -n "$2" ]]; then
            validate_config "$2"
        else
            echo "Usage: $0 validate <config_file>"
        fi
        ;;
    "help"|*)
        cat << 'EOF'
homelabarr-cli YAML Template Engine

Usage:
    template-engine.sh generate <service> <template> <output>    Generate config from template
    template-engine.sh create-template <yaml> <service> <template>  Create template from YAML
    template-engine.sh convert-all                              Convert all existing YAMLs to templates
    template-engine.sh generate-all                             Generate all configs for current mode
    template-engine.sh validate <config>                        Validate generated configuration

Examples:
    # Convert existing YAML to template
    ./template-engine.sh create-template /opt/homelabarr-cli/apps/mediaserver/plex.yml plex /opt/homelabarr-cli/apps/.templates/mediaserver/plex.yml
    
    # Generate configuration for current mode
    ./template-engine.sh generate plex /opt/homelabarr-cli/apps/.templates/mediaserver/plex.yml /opt/appdata/compose/plex.yml
    
    # Convert all existing YAMLs to templates
    ./template-engine.sh convert-all
    
    # Generate all configurations for current mode
    ./template-engine.sh generate-all

EOF
        ;;
esac
