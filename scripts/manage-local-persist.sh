#!/bin/bash

# HomelabARR CLI - Local-Persist Container Management Script
# Manages the containerized local-persist Docker volume plugin

set -e

# Configuration
CONTAINER_NAME="homelabarr-local-persist"
COMPOSE_FILE="/opt/homelabarr/apps/local-mode-apps/local-persist-fixed.yml"
PLUGIN_SOCKET="/run/docker/plugins/local-persist.sock"
IMAGE="ghcr.io/smashingtags/local-persist:latest"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root (use sudo)"
        exit 1
    fi
}

# Check Docker availability
check_docker() {
    if ! docker info >/dev/null 2>&1; then
        log_error "Docker is not running or not accessible"
        exit 1
    fi
}

# Show help information
show_help() {
    echo "HomelabARR CLI - Local-Persist Management Script"
    echo ""
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo ""
    echo "Commands:"
    echo "  status           Show plugin container status and health"
    echo "  start            Start the local-persist container"
    echo "  stop             Stop the local-persist container"
    echo "  restart          Restart the local-persist container"
    echo "  logs             Show container logs"
    echo "  update           Update to latest image version"
    echo "  remove           Remove container (preserves volumes)"
    echo "  install          Fresh installation of local-persist"
    echo "  create-volume    Create a new persistent volume"
    echo "  list-volumes     List all local-persist volumes"
    echo "  inspect-volume   Inspect a specific volume"
    echo "  cleanup          Clean up orphaned volume data"
    echo "  health           Run comprehensive health check"
    echo ""
    echo "Volume Creation:"
    echo "  create-volume VOLUME_NAME MOUNTPOINT"
    echo "    Example: $0 create-volume myapp /opt/appdata/myapp"
    echo ""
    echo "Volume Inspection:"
    echo "  inspect-volume VOLUME_NAME"
    echo "    Example: $0 inspect-volume unionfs"
    echo ""
    echo "Options:"
    echo "  -h, --help       Show this help message"
    echo "  -v, --verbose    Enable verbose output"
    echo ""
}

# Get container status
get_container_status() {
    if docker ps -q -f name="$CONTAINER_NAME" >/dev/null 2>&1; then
        echo "running"
    elif docker ps -aq -f name="$CONTAINER_NAME" >/dev/null 2>&1; then
        echo "stopped"
    else
        echo "not_found"
    fi
}

# Check plugin socket
check_plugin_socket() {
    if [ -S "$PLUGIN_SOCKET" ]; then
        return 0
    else
        return 1
    fi
}

# Show status information
show_status() {
    log_info "Local-Persist Container Status"
    echo "========================================"
    
    local status=$(get_container_status)
    
    case $status in
        "running")
            log_success "Container: Running"
            echo ""
            docker ps -f name="$CONTAINER_NAME" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
            echo ""
            
            if check_plugin_socket; then
                log_success "Plugin Socket: Active ($PLUGIN_SOCKET)"
            else
                log_warning "Plugin Socket: Not Found ($PLUGIN_SOCKET)"
            fi
            
            # Check health
            local health=$(docker inspect "$CONTAINER_NAME" --format='{{.State.Health.Status}}' 2>/dev/null || echo "unknown")
            case $health in
                "healthy")
                    log_success "Health Check: Healthy"
                    ;;
                "unhealthy")
                    log_error "Health Check: Unhealthy"
                    ;;
                "starting")
                    log_warning "Health Check: Starting"
                    ;;
                *)
                    log_warning "Health Check: Unknown"
                    ;;
            esac
            ;;
        "stopped")
            log_warning "Container: Stopped"
            docker ps -a -f name="$CONTAINER_NAME" --format "table {{.Names}}\t{{.Status}}"
            ;;
        "not_found")
            log_error "Container: Not Found"
            ;;
    esac
    
    echo ""
    log_info "Volume Information:"
    list_volumes_brief
}

# Start the container
start_container() {
    log_info "Starting local-persist container..."
    
    local status=$(get_container_status)
    
    if [ "$status" = "running" ]; then
        log_success "Container is already running"
        return 0
    fi
    
    if [ ! -f "$COMPOSE_FILE" ]; then
        log_error "Compose file not found: $COMPOSE_FILE"
        log_info "Run '$0 install' to install local-persist"
        exit 1
    fi
    
    # Create required directories
    mkdir -p /run/docker/plugins
    mkdir -p /var/lib/docker/plugin-data
    mkdir -p /opt/appdata
    
    # Start with docker-compose
    cd "$(dirname "$COMPOSE_FILE")"
    if command -v docker-compose >/dev/null 2>&1; then
        docker-compose -f "$(basename "$COMPOSE_FILE")" up -d
    else
        docker compose -f "$(basename "$COMPOSE_FILE")" up -d
    fi
    
    # Wait for startup
    log_info "Waiting for container to start..."
    sleep 5
    
    # Verify startup
    if [ "$(get_container_status)" = "running" ]; then
        log_success "Container started successfully"
        
        # Wait for plugin socket
        local retries=0
        while [ $retries -lt 30 ]; do
            if check_plugin_socket; then
                log_success "Plugin socket is active"
                return 0
            fi
            sleep 1
            ((retries++))
        done
        
        log_warning "Plugin socket not detected within 30 seconds"
        log_info "Container may still be initializing"
    else
        log_error "Failed to start container"
        show_logs
        exit 1
    fi
}

# Stop the container
stop_container() {
    log_info "Stopping local-persist container..."
    
    if [ "$(get_container_status)" = "not_found" ]; then
        log_warning "Container not found"
        return 0
    fi
    
    docker stop "$CONTAINER_NAME" 2>/dev/null || true
    log_success "Container stopped"
}

# Restart the container
restart_container() {
    log_info "Restarting local-persist container..."
    stop_container
    sleep 2
    start_container
}

# Show container logs
show_logs() {
    log_info "Container logs for $CONTAINER_NAME:"
    echo "========================================"
    
    if [ "$(get_container_status)" = "not_found" ]; then
        log_error "Container not found"
        return 1
    fi
    
    docker logs --tail=50 --timestamps "$CONTAINER_NAME"
}

# Update to latest image
update_container() {
    log_info "Updating local-persist to latest version..."
    
    # Pull latest image
    log_info "Pulling latest image..."
    docker pull "$IMAGE"
    
    # Restart with new image
    restart_container
    
    log_success "Update completed"
}

# Remove container (preserve volumes)
remove_container() {
    log_warning "This will remove the local-persist container but preserve all volumes"
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Operation cancelled"
        return 0
    fi
    
    log_info "Removing local-persist container..."
    
    docker stop "$CONTAINER_NAME" 2>/dev/null || true
    docker rm "$CONTAINER_NAME" 2>/dev/null || true
    
    log_success "Container removed (volumes preserved)"
    log_info "Run '$0 start' to reinstall"
}

# Fresh installation
install_container() {
    log_info "Installing local-persist container..."
    
    # Check if installation script exists
    local install_script="/opt/homelabarr/scripts/install-local-persist-container.sh"
    if [ -f "$install_script" ]; then
        log_info "Running installation script..."
        "$install_script"
    else
        log_warning "Installation script not found, performing manual installation..."
        
        # Create network if needed
        if ! docker network ls | grep -q "homelabarr-local"; then
            log_info "Creating homelabarr-local network..."
            docker network create homelabarr-local
        fi
        
        # Remove existing container
        docker stop "$CONTAINER_NAME" 2>/dev/null || true
        docker rm "$CONTAINER_NAME" 2>/dev/null || true
        
        # Start new container
        start_container
    fi
}

# Create a new volume
create_volume() {
    local volume_name="$1"
    local mountpoint="$2"
    
    if [ -z "$volume_name" ] || [ -z "$mountpoint" ]; then
        log_error "Usage: $0 create-volume VOLUME_NAME MOUNTPOINT"
        log_error "Example: $0 create-volume myapp /opt/appdata/myapp"
        exit 1
    fi
    
    log_info "Creating volume '$volume_name' with mountpoint '$mountpoint'..."
    
    # Check if container is running
    if [ "$(get_container_status)" != "running" ]; then
        log_error "Local-persist container is not running"
        log_info "Run '$0 start' first"
        exit 1
    fi
    
    # Check if plugin socket exists
    if ! check_plugin_socket; then
        log_error "Plugin socket not found. Container may still be starting."
        exit 1
    fi
    
    # Create mountpoint directory if it doesn't exist
    if [ ! -d "$mountpoint" ]; then
        log_info "Creating mountpoint directory: $mountpoint"
        mkdir -p "$mountpoint"
        chown 1000:1000 "$mountpoint"
    fi
    
    # Create the volume
    if docker volume create -d local-persist -o mountpoint="$mountpoint" --name="$volume_name"; then
        log_success "Volume '$volume_name' created successfully"
        log_info "Mountpoint: $mountpoint"
        
        # Verify volume
        docker volume inspect "$volume_name" >/dev/null 2>&1 && \
            log_success "Volume verification passed"
    else
        log_error "Failed to create volume '$volume_name'"
        exit 1
    fi
}

# List all local-persist volumes
list_volumes() {
    log_info "Local-Persist Volumes:"
    echo "========================================"
    
    local volumes=$(docker volume ls -f driver=local-persist --format "{{.Name}}" 2>/dev/null || true)
    
    if [ -z "$volumes" ]; then
        log_warning "No local-persist volumes found"
        return 0
    fi
    
    printf "%-20s %-40s %-10s\n" "VOLUME NAME" "MOUNTPOINT" "SIZE"
    echo "------------------------------------------------------------------------"
    
    for volume in $volumes; do
        local mountpoint=$(docker volume inspect "$volume" --format '{{index .Options "mountpoint"}}' 2>/dev/null || echo "unknown")
        local size="unknown"
        
        if [ -d "$mountpoint" ]; then
            size=$(du -sh "$mountpoint" 2>/dev/null | cut -f1 || echo "unknown")
        fi
        
        printf "%-20s %-40s %-10s\n" "$volume" "$mountpoint" "$size"
    done
}

# Brief volume listing for status
list_volumes_brief() {
    local volumes=$(docker volume ls -f driver=local-persist --format "{{.Name}}" 2>/dev/null | wc -l)
    echo "Local-persist volumes: $volumes"
}

# Inspect a specific volume
inspect_volume() {
    local volume_name="$1"
    
    if [ -z "$volume_name" ]; then
        log_error "Usage: $0 inspect-volume VOLUME_NAME"
        exit 1
    fi
    
    log_info "Volume Details for '$volume_name':"
    echo "========================================"
    
    if ! docker volume inspect "$volume_name" >/dev/null 2>&1; then
        log_error "Volume '$volume_name' not found"
        exit 1
    fi
    
    # Show volume details
    docker volume inspect "$volume_name" --format '
Driver: {{.Driver}}
Name: {{.Name}}
Mountpoint: {{index .Options "mountpoint"}}
Created: {{.CreatedAt}}
'
    
    local mountpoint=$(docker volume inspect "$volume_name" --format '{{index .Options "mountpoint"}}' 2>/dev/null)
    
    if [ -d "$mountpoint" ]; then
        echo ""
        log_info "Directory Information:"
        echo "Path: $mountpoint"
        echo "Size: $(du -sh "$mountpoint" 2>/dev/null | cut -f1 || echo 'unknown')"
        echo "Files: $(find "$mountpoint" -type f 2>/dev/null | wc -l || echo 'unknown')"
        echo "Permissions: $(ls -ld "$mountpoint" | awk '{print $1, $3, $4}')"
    else
        log_warning "Mountpoint directory does not exist: $mountpoint"
    fi
}

# Clean up orphaned volume data
cleanup() {
    log_info "Cleaning up orphaned volume data..."
    
    # Check for unused volumes
    local unused_volumes=$(docker volume ls -q -f dangling=true -f driver=local-persist 2>/dev/null || true)
    
    if [ -n "$unused_volumes" ]; then
        log_warning "Found unused local-persist volumes:"
        echo "$unused_volumes"
        
        read -p "Remove unused volumes? (y/N): " -n 1 -r
        echo
        
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "$unused_volumes" | xargs docker volume rm
            log_success "Unused volumes removed"
        fi
    else
        log_success "No unused volumes found"
    fi
    
    # Check plugin data directory
    local plugin_data="/var/lib/docker/plugin-data"
    if [ -d "$plugin_data" ]; then
        local size=$(du -sh "$plugin_data" 2>/dev/null | cut -f1 || echo 'unknown')
        log_info "Plugin data directory size: $size"
    fi
}

# Comprehensive health check
health_check() {
    log_info "Running comprehensive health check..."
    echo "========================================"
    
    local exit_code=0
    
    # Check Docker
    if docker info >/dev/null 2>&1; then
        log_success "Docker: Running"
    else
        log_error "Docker: Not accessible"
        exit_code=1
    fi
    
    # Check container
    local status=$(get_container_status)
    case $status in
        "running")
            log_success "Container: Running"
            ;;
        "stopped")
            log_error "Container: Stopped"
            exit_code=1
            ;;
        "not_found")
            log_error "Container: Not found"
            exit_code=1
            ;;
    esac
    
    # Check plugin socket
    if check_plugin_socket; then
        log_success "Plugin Socket: Active"
    else
        log_error "Plugin Socket: Missing"
        exit_code=1
    fi
    
    # Check compose file
    if [ -f "$COMPOSE_FILE" ]; then
        log_success "Compose File: Found"
    else
        log_error "Compose File: Missing ($COMPOSE_FILE)"
        exit_code=1
    fi
    
    # Check directories
    for dir in "/run/docker/plugins" "/var/lib/docker/plugin-data" "/opt/appdata"; do
        if [ -d "$dir" ]; then
            log_success "Directory: $dir exists"
        else
            log_error "Directory: $dir missing"
            exit_code=1
        fi
    done
    
    # Test volume creation
    if [ "$status" = "running" ] && check_plugin_socket; then
        local test_volume="test-volume-$(date +%s)"
        local test_path="/tmp/local-persist-test"
        
        mkdir -p "$test_path"
        
        if docker volume create -d local-persist -o mountpoint="$test_path" --name="$test_volume" >/dev/null 2>&1; then
            log_success "Volume Creation: Working"
            docker volume rm "$test_volume" >/dev/null 2>&1
            rm -rf "$test_path"
        else
            log_error "Volume Creation: Failed"
            exit_code=1
        fi
    fi
    
    echo ""
    if [ $exit_code -eq 0 ]; then
        log_success "All health checks passed"
    else
        log_error "Some health checks failed"
    fi
    
    return $exit_code
}

# Main execution
main() {
    check_root
    check_docker
    
    case "${1:-}" in
        "status"|"")
            show_status
            ;;
        "start")
            start_container
            ;;
        "stop")
            stop_container
            ;;
        "restart")
            restart_container
            ;;
        "logs")
            show_logs
            ;;
        "update")
            update_container
            ;;
        "remove")
            remove_container
            ;;
        "install")
            install_container
            ;;
        "create-volume")
            create_volume "$2" "$3"
            ;;
        "list-volumes")
            list_volumes
            ;;
        "inspect-volume")
            inspect_volume "$2"
            ;;
        "cleanup")
            cleanup
            ;;
        "health")
            health_check
            ;;
        "-h"|"--help"|"help")
            show_help
            ;;
        *)
            log_error "Unknown command: $1"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"
