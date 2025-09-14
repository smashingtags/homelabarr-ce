#!/bin/bash

# DockServer to HomelabARR Migration Script
# This script helps users migrate from DockServer to HomelabARR
# It updates container names, configurations, and data paths

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
BACKUP_DIR="/opt/backups/dockserver-migration-$(date +%Y%m%d-%H%M%S)"
DOCKER_COMPOSE_DIR="/opt/homelabarr/apps"
DATA_DIR="/opt/appdata"

# Print colored messages
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "This script must be run as root"
        exit 1
    fi
}

# Create backup directory
create_backup() {
    print_info "Creating backup directory: $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
    
    # Backup docker-compose files
    if [ -d "$DOCKER_COMPOSE_DIR" ]; then
        print_info "Backing up Docker Compose files..."
        cp -r "$DOCKER_COMPOSE_DIR" "$BACKUP_DIR/docker-compose-backup"
    fi
    
    # Backup appdata
    if [ -d "$DATA_DIR" ]; then
        print_info "Creating list of appdata directories..."
        ls -la "$DATA_DIR" > "$BACKUP_DIR/appdata-list.txt"
    fi
    
    print_success "Backup created at $BACKUP_DIR"
}

# Stop running containers
stop_containers() {
    print_info "Stopping DockServer containers..."
    
    # Stop specific DockServer containers
    local containers=("dockserver-ui" "dockserver" "dockserver-autoscan" "dockserver-mount")
    
    for container in "${containers[@]}"; do
        if docker ps -a --format '{{.Names}}' | grep -q "^${container}$"; then
            print_info "Stopping $container..."
            docker stop "$container" 2>/dev/null || true
            docker rm "$container" 2>/dev/null || true
        fi
    done
    
    print_success "DockServer containers stopped"
}

# Update container image references
update_images() {
    print_info "Updating container image references..."
    
    # Map old images to new ones
    declare -A image_map=(
        ["dockserver/dockserver"]="ghcr.io/smashingtags/homelabarr-legacy-base"
        ["dockserver/dockserver-ui"]="ghcr.io/smashingtags/homelabarr-ui-legacy"
        ["dockserver/autoscan"]="ghcr.io/smashingtags/homelabarr-autoscan"
        ["dockserver/mount"]="ghcr.io/smashingtags/homelabarr-mount"
    )
    
    # Update docker-compose files
    for compose_file in $(find "$DOCKER_COMPOSE_DIR" -name "*.yml" -o -name "*.yaml"); do
        if [ -f "$compose_file" ]; then
            cp "$compose_file" "$compose_file.bak"
            
            for old_image in "${!image_map[@]}"; do
                new_image="${image_map[$old_image]}"
                sed -i "s|image: $old_image|image: $new_image|g" "$compose_file"
                sed -i "s|image: '$old_image'|image: '$new_image'|g" "$compose_file"
                sed -i "s|image: \"$old_image\"|image: \"$new_image\"|g" "$compose_file"
            done
            
            print_info "Updated $compose_file"
        fi
    done
    
    print_success "Container images updated"
}

# Update environment variables
update_env_vars() {
    print_info "Updating environment variables..."
    
    # Find and update .env files
    for env_file in $(find "$DOCKER_COMPOSE_DIR" -name ".env*"); do
        if [ -f "$env_file" ]; then
            cp "$env_file" "$env_file.bak"
            
            # Update common DockServer variables to HomelabARR
            sed -i 's/DOCKSERVER_/HOMELABARR_/g' "$env_file"
            sed -i 's/DS_/HL_/g' "$env_file"
            
            print_info "Updated $env_file"
        fi
    done
    
    print_success "Environment variables updated"
}

# Update data paths
update_data_paths() {
    print_info "Checking data paths..."
    
    # Map old paths to new ones
    declare -A path_map=(
        ["/opt/dockserver"]="/opt/homelabarr"
        ["/opt/appdata/dockserver"]="/opt/appdata/homelabarr"
    )
    
    for old_path in "${!path_map[@]}"; do
        new_path="${path_map[$old_path]}"
        
        if [ -d "$old_path" ] && [ ! -d "$new_path" ]; then
            print_info "Moving $old_path to $new_path..."
            mv "$old_path" "$new_path"
        elif [ -d "$old_path" ] && [ -d "$new_path" ]; then
            print_warning "Both $old_path and $new_path exist. Manual intervention required."
        fi
    done
    
    print_success "Data paths updated"
}

# Update systemd services
update_systemd() {
    print_info "Updating systemd services..."
    
    local service_files=(
        "/etc/systemd/system/dockserver.service"
        "/etc/systemd/system/dockserver-mount.service"
    )
    
    for service in "${service_files[@]}"; do
        if [ -f "$service" ]; then
            new_service="${service/dockserver/homelabarr}"
            
            print_info "Updating $service to $new_service..."
            cp "$service" "$service.bak"
            
            # Update service content
            sed -i 's/DockServer/HomelabARR/g' "$service"
            sed -i 's/dockserver/homelabarr/g' "$service"
            
            # Rename service file
            mv "$service" "$new_service"
            
            # Reload systemd
            systemctl daemon-reload
        fi
    done
    
    print_success "Systemd services updated"
}

# Clean up old images
cleanup_images() {
    print_info "Cleaning up old DockServer images..."
    
    local old_images=(
        "dockserver/dockserver"
        "dockserver/dockserver-ui"
        "dockserver/autoscan"
        "dockserver/mount"
    )
    
    for image in "${old_images[@]}"; do
        if docker images | grep -q "$image"; then
            print_info "Removing $image..."
            docker rmi "$image" 2>/dev/null || true
        fi
    done
    
    print_success "Old images cleaned up"
}

# Verify migration
verify_migration() {
    print_info "Verifying migration..."
    
    local errors=0
    
    # Check for new image references
    if grep -r "dockserver/dockserver" "$DOCKER_COMPOSE_DIR" 2>/dev/null; then
        print_warning "Found remaining DockServer image references"
        ((errors++))
    fi
    
    # Check for new environment variables
    if grep -r "DOCKSERVER_" "$DOCKER_COMPOSE_DIR" 2>/dev/null; then
        print_warning "Found remaining DOCKSERVER_ variables"
        ((errors++))
    fi
    
    if [ $errors -eq 0 ]; then
        print_success "Migration verified successfully"
        return 0
    else
        print_warning "Migration completed with warnings. Please review the above messages."
        return 1
    fi
}

# Main migration process
main() {
    echo "========================================="
    echo "  DockServer to HomelabARR Migration"
    echo "========================================="
    echo ""
    
    check_root
    
    print_warning "This script will migrate your DockServer installation to HomelabARR."
    print_warning "A backup will be created, but please ensure you have your own backups."
    echo ""
    read -p "Continue with migration? (y/n): " -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Migration cancelled"
        exit 0
    fi
    
    # Run migration steps
    create_backup
    stop_containers
    update_images
    update_env_vars
    update_data_paths
    update_systemd
    cleanup_images
    verify_migration
    
    echo ""
    echo "========================================="
    echo "        Migration Complete!"
    echo "========================================="
    echo ""
    print_info "Backup location: $BACKUP_DIR"
    print_info "Please review the changes and start your containers with:"
    print_info "  docker-compose up -d"
    echo ""
    print_warning "Note: The legacy containers (homelabarr-legacy-base and homelabarr-ui-legacy)"
    print_warning "are temporary and will be deprecated. Consider migrating to the new"
    print_warning "HomelabARR native solutions when available."
}

# Run main function
main "$@"