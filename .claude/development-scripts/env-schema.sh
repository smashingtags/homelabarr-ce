#!/bin/bash
#####################################
# homelabarr-cli Environment Schema     #
# Manages environment variables     #
# for Local vs Proxy modes          #
#####################################

# Configuration paths
ENV_SCHEMA_DIR="/opt/homelabarr-cli/.env-schema"
LOCAL_ENV_FILE="/opt/homelabarr-cli/.env.local"
PROXY_ENV_FILE="/opt/homelabarr-cli/.env.proxy"
GLOBAL_ENV_FILE="/opt/appdata/compose/.env"
ENV_BACKUP_DIR="/opt/homelabarr-cli/.env-backups"

# Environment variable categories
ENV_CATEGORIES=(
    "core"           # Core system variables
    "network"        # Network configuration  
    "security"       # Security settings
    "proxy"          # Proxy mode specific
    "local"          # Local mode specific
    "services"       # Service-specific variables
    "paths"          # Directory paths
    "optional"       # Optional features
)

# Initialize environment schema system
init_env_schema() {
    echo "🔧 Initializing homelabarr-cli Environment Schema..."
    
    # Create directories
    mkdir -p "$ENV_SCHEMA_DIR"
    mkdir -p "$ENV_BACKUP_DIR"
    
    # Create schema definitions
    create_env_schemas
    
    # Create default environment files
    create_default_envs
    
    echo "✅ Environment schema system initialized"
}

# Create environment variable schemas
create_env_schemas() {
    # Core system variables
    cat > "$ENV_SCHEMA_DIR/core.env" << 'EOF'
# Core System Variables
# Required for all installation modes

# User and Group IDs
ID=1000
PGID=1000
PUID=1000

# Timezone
TZ=America/New_York

# Umask for file permissions
UMASK=002

# Application restart policy
RESTARTAPP=unless-stopped

# Security options
SECURITYOPS=no-new-privileges
SECURITYOPSSET=true

# Application folders
APPFOLDER=/opt/appdata
DOWNLOADFOLDER=/mnt/downloads
STORAGEFOLDER=/mnt/unionfs
EOF

    # Network configuration
    cat > "$ENV_SCHEMA_DIR/network.env" << 'EOF'
# Network Configuration Variables
# Different settings for Local vs Proxy modes

# Docker network (proxy mode: proxy, local mode: bridge)
DOCKERNETWORK=proxy

# Local mode specific
LOCAL_INTERFACE=0.0.0.0
LOCAL_NETWORK=bridge

# Proxy mode specific  
PROXY_NETWORK=proxy
TRAEFIK_NETWORK=proxy
EOF

    # Security settings
    cat > "$ENV_SCHEMA_DIR/security.env" << 'EOF'
# Security Configuration Variables

# Authelia settings (proxy mode only)
AUTHELIA_ENABLED=true
AUTHELIA_LOG_LEVEL=warn

# SSL/TLS settings
SSL_ENABLED=true
CERT_RESOLVER=dns-cloudflare

# Fail2ban settings
FAIL2BAN_ENABLED=true
FAIL2BAN_BANTIME=3600

# Security headers
SECURITY_HEADERS_ENABLED=true
EOF

    # Proxy mode specific variables
    cat > "$ENV_SCHEMA_DIR/proxy.env" << 'EOF'
# Proxy Mode Configuration Variables
# Required when using Traefik and Authelia

# Domain configuration
DOMAIN=example.com
DOMAIN1_ZONE_ID=your_cloudflare_zone_id

# Cloudflare API credentials
CLOUDFLARE_EMAIL=your@email.com
CLOUDFLARE_API_KEY=your_api_key

# Traefik configuration
TRAEFIK_LOG_LEVEL=warn
TRAEFIK_API_ENABLED=true
TRAEFIK_DASHBOARD_ENABLED=true

# Authelia configuration
AUTHELIA_DEFAULT_POLICY=deny
AUTHELIA_SESSION_TIMEOUT=12h
EOF

    # Local mode specific variables
    cat > "$ENV_SCHEMA_DIR/local.env" << 'EOF'
# Local Mode Configuration Variables
# Used when bypassing Traefik and Authelia

# Local mode settings
LOCAL_MODE_ENABLED=true
LOCAL_ACCESS_ONLY=true

# Port configuration
LOCAL_PORT_RANGE_START=8000
LOCAL_PORT_RANGE_END=9999
LOCAL_BIND_INTERFACE=0.0.0.0

# Direct access URLs (no domain required)
LOCAL_BASE_URL=http://localhost
LOCAL_SERVER_IP=192.168.1.100

# Local authentication (per-service)
LOCAL_AUTH_METHOD=individual
LOCAL_DEFAULT_USER=admin
LOCAL_DEFAULT_PASS=changeme
EOF

    # Service-specific variables
    cat > "$ENV_SCHEMA_DIR/services.env" << 'EOF'
# Service-Specific Environment Variables

# Plex configuration
PLEXIMAGE=linuxserver/plex:latest
PLEXVERSION=docker
PLEXTHEME=dark
PLEXADDON=none

# qBittorrent configuration
QBITORRENTIMAGE=linuxserver/qbittorrent:latest
QBITORRENTTHEME=dark

# Radarr/Sonarr configuration  
RADARRIMAGE=linuxserver/radarr:latest
SONARRIMAGE=linuxserver/sonarr:latest

# Jellyfin configuration
JELLYFINIMAGE=linuxserver/jellyfin:latest

# Overseerr configuration
OVERSEERRIMAGE=linuxserver/overseerr:latest

# Database configurations
MYSQL_ROOT_PASSWORD=dockserver_root_pass
POSTGRES_PASSWORD=dockserver_postgres_pass

# Redis configuration
REDIS_PASSWORD=dockserver_redis_pass
EOF

    # Directory paths
    cat > "$ENV_SCHEMA_DIR/paths.env" << 'EOF'
# Directory Path Configuration

# Base directories
APPFOLDER=/opt/appdata
DOWNLOADFOLDER=/mnt/downloads
STORAGEFOLDER=/mnt/unionfs

# Media directories
MOVIES_PATH=/mnt/unionfs/media/movies
TV_PATH=/mnt/unionfs/media/tv
MUSIC_PATH=/mnt/unionfs/media/music
BOOKS_PATH=/mnt/unionfs/media/books

# Download directories
INCOMPLETE_PATH=/mnt/downloads/incomplete
COMPLETE_PATH=/mnt/downloads/complete
TORRENT_PATH=/mnt/downloads/torrent
USENET_PATH=/mnt/downloads/usenet

# Backup directories
BACKUP_PATH=/mnt/unionfs/backups
CONFIG_BACKUP_PATH=/opt/backups/configs
EOF

    # Optional features
    cat > "$ENV_SCHEMA_DIR/optional.env" << 'EOF'
# Optional Feature Configuration

# Theme settings
THEME_PARK_ENABLED=true
THEME_PARK_THEME=dark

# Monitoring
MONITORING_ENABLED=true
METRICS_ENABLED=false

# VPN settings
VPN_ENABLED=false
VPN_TYPE=wireguard
VPN_CONFIG_PATH=/opt/appdata/vpn

# GPU acceleration
GPU_ACCELERATION=false
GPU_TYPE=nvidia

# Backup automation
AUTO_BACKUP_ENABLED=false
BACKUP_SCHEDULE="0 2 * * *"
BACKUP_RETENTION_DAYS=30

# Update automation
AUTO_UPDATE_ENABLED=false
UPDATE_SCHEDULE="0 4 * * 0"
EOF

    echo "✓ Environment schemas created"
}

# Create default environment files
create_default_envs() {
    # Create local mode environment
    cat > "$LOCAL_ENV_FILE" << 'EOF'
# homelabarr-cli Local Mode Environment
# Auto-generated configuration for local installation

# Load core variables
EOF
    cat "$ENV_SCHEMA_DIR/core.env" >> "$LOCAL_ENV_FILE"
    echo "" >> "$LOCAL_ENV_FILE"
    cat "$ENV_SCHEMA_DIR/network.env" | sed 's/DOCKERNETWORK=proxy/DOCKERNETWORK=bridge/' >> "$LOCAL_ENV_FILE"
    echo "" >> "$LOCAL_ENV_FILE"
    cat "$ENV_SCHEMA_DIR/local.env" >> "$LOCAL_ENV_FILE"
    echo "" >> "$LOCAL_ENV_FILE"
    cat "$ENV_SCHEMA_DIR/services.env" >> "$LOCAL_ENV_FILE"
    echo "" >> "$LOCAL_ENV_FILE"
    cat "$ENV_SCHEMA_DIR/paths.env" >> "$LOCAL_ENV_FILE"
    echo "" >> "$LOCAL_ENV_FILE"
    cat "$ENV_SCHEMA_DIR/optional.env" >> "$LOCAL_ENV_FILE"

    # Create proxy mode environment
    cat > "$PROXY_ENV_FILE" << 'EOF'
# homelabarr-cli Proxy Mode Environment  
# Auto-generated configuration for proxy installation

# Load core variables
EOF
    cat "$ENV_SCHEMA_DIR/core.env" >> "$PROXY_ENV_FILE"
    echo "" >> "$PROXY_ENV_FILE"
    cat "$ENV_SCHEMA_DIR/network.env" >> "$PROXY_ENV_FILE"
    echo "" >> "$PROXY_ENV_FILE"
    cat "$ENV_SCHEMA_DIR/security.env" >> "$PROXY_ENV_FILE"
    echo "" >> "$PROXY_ENV_FILE"
    cat "$ENV_SCHEMA_DIR/proxy.env" >> "$PROXY_ENV_FILE"
    echo "" >> "$PROXY_ENV_FILE"
    cat "$ENV_SCHEMA_DIR/services.env" >> "$PROXY_ENV_FILE"
    echo "" >> "$PROXY_ENV_FILE"
    cat "$ENV_SCHEMA_DIR/paths.env" >> "$PROXY_ENV_FILE"
    echo "" >> "$PROXY_ENV_FILE"
    cat "$ENV_SCHEMA_DIR/optional.env" >> "$PROXY_ENV_FILE"

    echo "✓ Default environment files created"
}

# Switch environment configuration
switch_env_mode() {
    local target_mode="$1"
    
    # Backup current environment
    if [[ -f "$GLOBAL_ENV_FILE" ]]; then
        local backup_file="$ENV_BACKUP_DIR/env_$(date +%Y%m%d_%H%M%S).backup"
        cp "$GLOBAL_ENV_FILE" "$backup_file"
        echo "✓ Current environment backed up to: $backup_file"
    fi
    
    # Create output directory
    mkdir -p "$(dirname "$GLOBAL_ENV_FILE")"
    
    case "$target_mode" in
        "local")
            if [[ -f "$LOCAL_ENV_FILE" ]]; then
                cp "$LOCAL_ENV_FILE" "$GLOBAL_ENV_FILE"
                echo "✓ Switched to local mode environment"
            else
                echo "❌ Local environment file not found: $LOCAL_ENV_FILE"
                return 1
            fi
            ;;
        "proxy")
            if [[ -f "$PROXY_ENV_FILE" ]]; then
                cp "$PROXY_ENV_FILE" "$GLOBAL_ENV_FILE"
                echo "✓ Switched to proxy mode environment"
            else
                echo "❌ Proxy environment file not found: $PROXY_ENV_FILE"
                return 1
            fi
            ;;
        *)
            echo "❌ Invalid mode: $target_mode (use 'local' or 'proxy')"
            return 1
            ;;
    esac
}

# Generate environment for specific service
generate_service_env() {
    local service_name="$1"
    local mode="${2:-auto}"
    local output_file="${3:-}"
    
    # Auto-detect mode if not specified
    if [[ "$mode" == "auto" ]]; then
        if [[ -f "/opt/homelabarr-cli/.local_mode" ]]; then
            source "/opt/homelabarr-cli/.local_mode"
            if [[ "$LOCAL_MODE_ENABLED" == "true" ]]; then
                mode="local"
            else
                mode="proxy"
            fi
        else
            mode="proxy"
        fi
    fi
    
    # Get service port if in local mode
    local service_port=""
    if [[ "$mode" == "local" ]]; then
        if command -v /opt/homelabarr-cli/apps/.config/port-manager.sh >/dev/null 2>&1; then
            service_port=$(/opt/homelabarr-cli/apps/.config/port-manager.sh get "$service_name" 2>/dev/null)
        fi
    fi
    
    # Generate service-specific environment
    local temp_env=$(mktemp)
    
    # Load base environment
    if [[ "$mode" == "local" && -f "$LOCAL_ENV_FILE" ]]; then
        cat "$LOCAL_ENV_FILE" > "$temp_env"
    elif [[ "$mode" == "proxy" && -f "$PROXY_ENV_FILE" ]]; then
        cat "$PROXY_ENV_FILE" > "$temp_env"
    else
        echo "❌ Environment file for mode '$mode' not found"
        return 1
    fi
    
    # Add service-specific variables
    echo "" >> "$temp_env"
    echo "# Service-specific variables for $service_name" >> "$temp_env"
    
    case "$service_name" in
        "plex")
            if [[ "$mode" == "local" && -n "$service_port" ]]; then
                echo "PLEX_WEB_PORT=$service_port" >> "$temp_env"
                echo "PLEX_LOCAL_URL=http://\${LOCAL_SERVER_IP}:$service_port" >> "$temp_env"
            fi
            ;;
        "qbittorrent")
            if [[ "$mode" == "local" && -n "$service_port" ]]; then
                echo "QBITTORRENT_WEB_PORT=$service_port" >> "$temp_env"
                echo "QBITTORRENT_LOCAL_URL=http://\${LOCAL_SERVER_IP}:$service_port" >> "$temp_env"
            fi
            ;;
        # Add more service-specific configurations as needed
    esac
    
    # Output to file or stdout
    if [[ -n "$output_file" ]]; then
        mv "$temp_env" "$output_file"
        echo "✓ Service environment generated: $output_file"
    else
        cat "$temp_env"
        rm -f "$temp_env"
    fi
}

# Validate environment configuration
validate_env() {
    local env_file="${1:-$GLOBAL_ENV_FILE}"
    local errors=0
    
    echo "🔍 Validating environment configuration: $env_file"
    echo ""
    
    if [[ ! -f "$env_file" ]]; then
        echo "❌ Environment file not found: $env_file"
        return 1
    fi
    
    # Check for required variables
    local required_vars=(
        "ID" "PUID" "PGID" "TZ" "UMASK" "RESTARTAPP" 
        "APPFOLDER" "DOCKERNETWORK"
    )
    
    for var in "${required_vars[@]}"; do
        if ! grep -q "^${var}=" "$env_file"; then
            echo "❌ Missing required variable: $var"
            ((errors++))
        else
            echo "✓ Found required variable: $var"
        fi
    done
    
    # Check mode-specific requirements
    if grep -q "LOCAL_MODE_ENABLED=true" "$env_file"; then
        echo ""
        echo "Validating LOCAL MODE configuration:"
        
        local local_vars=("LOCAL_INTERFACE" "LOCAL_PORT_RANGE_START" "LOCAL_PORT_RANGE_END")
        for var in "${local_vars[@]}"; do
            if ! grep -q "^${var}=" "$env_file"; then
                echo "⚠️  Missing local mode variable: $var"
            else
                echo "✓ Found local mode variable: $var"
            fi
        done
        
        # Check if DOCKERNETWORK is set to bridge for local mode
        if grep -q "DOCKERNETWORK=bridge" "$env_file"; then
            echo "✓ Docker network correctly set to bridge for local mode"
        else
            echo "⚠️  Docker network should be 'bridge' for local mode"
        fi
        
    else
        echo ""
        echo "Validating PROXY MODE configuration:"
        
        local proxy_vars=("DOMAIN" "CLOUDFLARE_EMAIL" "CLOUDFLARE_API_KEY")
        for var in "${proxy_vars[@]}"; do
            if ! grep -q "^${var}=" "$env_file"; then
                echo "❌ Missing proxy mode variable: $var"
                ((errors++))
            else
                echo "✓ Found proxy mode variable: $var"
            fi
        done
        
        # Check if DOCKERNETWORK is set to proxy for proxy mode
        if grep -q "DOCKERNETWORK=proxy" "$env_file"; then
            echo "✓ Docker network correctly set to proxy for proxy mode"
        else
            echo "❌ Docker network should be 'proxy' for proxy mode"
            ((errors++))
        fi
    fi
    
    echo ""
    if [[ $errors -eq 0 ]]; then
        echo "✅ Environment validation passed"
        return 0
    else
        echo "❌ Environment validation failed with $errors errors"
        return 1
    fi
}

# Show current environment status
show_env_status() {
    echo "📋 homelabarr-cli Environment Status"
    echo ""
    
    # Check which mode is active
    if [[ -f "$GLOBAL_ENV_FILE" ]]; then
        echo "Active environment file: $GLOBAL_ENV_FILE"
        
        if grep -q "LOCAL_MODE_ENABLED=true" "$GLOBAL_ENV_FILE"; then
            echo "Current mode: 🏠 LOCAL MODE"
            
            # Show local mode specific info
            local interface=$(grep "^LOCAL_INTERFACE=" "$GLOBAL_ENV_FILE" | cut -d'=' -f2)
            local port_start=$(grep "^LOCAL_PORT_RANGE_START=" "$GLOBAL_ENV_FILE" | cut -d'=' -f2)
            local port_end=$(grep "^LOCAL_PORT_RANGE_END=" "$GLOBAL_ENV_FILE" | cut -d'=' -f2)
            
            echo "  Interface: ${interface:-0.0.0.0}"
            echo "  Port range: ${port_start:-8000}-${port_end:-9999}"
            
        else
            echo "Current mode: 🌐 PROXY MODE"
            
            # Show proxy mode specific info
            local domain=$(grep "^DOMAIN=" "$GLOBAL_ENV_FILE" | cut -d'=' -f2)
            local network=$(grep "^DOCKERNETWORK=" "$GLOBAL_ENV_FILE" | cut -d'=' -f2)
            
            echo "  Domain: ${domain:-not configured}"
            echo "  Network: ${network:-proxy}"
        fi
        
        echo ""
        echo "Key variables:"
        
        # Show important variables
        local important_vars=("ID" "TZ" "APPFOLDER" "DOCKERNETWORK")
        for var in "${important_vars[@]}"; do
            local value=$(grep "^${var}=" "$GLOBAL_ENV_FILE" | cut -d'=' -f2)
            echo "  $var = ${value:-not set}"
        done
        
    else
        echo "❌ No active environment file found"
        echo "Run 'init' to create default environment files"
    fi
    
    echo ""
    echo "Available environment files:"
    [[ -f "$LOCAL_ENV_FILE" ]] && echo "  ✓ Local mode template: $LOCAL_ENV_FILE"
    [[ -f "$PROXY_ENV_FILE" ]] && echo "  ✓ Proxy mode template: $PROXY_ENV_FILE"
    
    # Show recent backups
    if [[ -d "$ENV_BACKUP_DIR" ]] && [[ $(ls -1 "$ENV_BACKUP_DIR"/*.backup 2>/dev/null | wc -l) -gt 0 ]]; then
        echo ""
        echo "Recent backups:"
        ls -1t "$ENV_BACKUP_DIR"/*.backup 2>/dev/null | head -3 | while read -r backup; do
            echo "  $(basename "$backup")"
        done
    fi
}

# Export environment in different formats
export_env() {
    local format="${1:-bash}"
    local env_file="${2:-$GLOBAL_ENV_FILE}"
    local output_file="$3"
    
    if [[ ! -f "$env_file" ]]; then
        echo "❌ Environment file not found: $env_file"
        return 1
    fi
    
    case "$format" in
        "bash"|"sh")
            # Export as bash/shell variables
            grep -v '^#' "$env_file" | grep -v '^$' | sed 's/^/export /'
            ;;
        "docker")
            # Export as Docker environment file format
            grep -v '^#' "$env_file" | grep -v '^$'
            ;;
        "json")
            # Export as JSON
            echo "{"
            local first=true
            while IFS='=' read -r key value; do
                if [[ ! "$key" =~ ^# ]] && [[ -n "$key" ]]; then
                    if [[ "$first" == "false" ]]; then
                        echo ","
                    fi
                    echo -n "  \"$key\": \"$value\""
                    first=false
                fi
            done < "$env_file"
            echo ""
            echo "}"
            ;;
        "yaml")
            # Export as YAML
            echo "# homelabarr-cli Environment Variables"
            echo "environment:"
            while IFS='=' read -r key value; do
                if [[ ! "$key" =~ ^# ]] && [[ -n "$key" ]]; then
                    echo "  $key: \"$value\""
                fi
            done < "$env_file"
            ;;
    esac
}

# Main command processing
case "${1:-help}" in
    "init")
        init_env_schema
        ;;
    "switch")
        if [[ -n "$2" ]]; then
            switch_env_mode "$2"
        else
            echo "Usage: $0 switch <local|proxy>"
        fi
        ;;
    "generate")
        if [[ -n "$2" ]]; then
            generate_service_env "$2" "$3" "$4"
        else
            echo "Usage: $0 generate <service> [mode] [output_file]"
        fi
        ;;
    "validate")
        validate_env "$2"
        ;;
    "status")
        show_env_status
        ;;
    "export")
        export_env "$2" "$3" "$4"
        ;;
    "help"|*)
        cat << 'EOF'
homelabarr-cli Environment Schema Manager

Usage:
    env-schema.sh init                                Initialize environment schema system
    env-schema.sh switch <local|proxy>                Switch environment mode
    env-schema.sh generate <service> [mode] [file]    Generate service-specific environment
    env-schema.sh validate [env_file]                 Validate environment configuration
    env-schema.sh status                              Show current environment status
    env-schema.sh export [format] [env_file] [output] Export environment in different formats

Formats for export: bash, docker, json, yaml

Examples:
    # Initialize system
    ./env-schema.sh init
    
    # Switch to local mode
    ./env-schema.sh switch local
    
    # Generate environment for Plex in local mode
    ./env-schema.sh generate plex local /opt/appdata/plex/.env
    
    # Validate current environment
    ./env-schema.sh validate
    
    # Export as JSON
    ./env-schema.sh export json > environment.json

EOF
        ;;
esac
