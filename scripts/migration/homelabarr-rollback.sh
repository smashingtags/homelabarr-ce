#!/bin/bash

# HomelabARR to HomelabARR Rollback Script
# This script helps users rollback from HomelabARR to HomelabARR if needed
# It restores container names, configurations, and data paths from backup

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
DOCKER_COMPOSE_DIR="/opt/homelabarr/apps"

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

# Find backup directory
find_backup() {
    print_info "Looking for backup directories..."
    
    local backup_base="/opt/backups"
    
    if [ ! -d "$backup_base" ]; then
        print_error "No backup directory found at $backup_base"
        exit 1
    fi
    
    # List available backups
    local backups=($(ls -d "$backup_base"/homelabarr-migration-* 2>/dev/null | sort -r))
    
    if [ ${#backups[@]} -eq 0 ]; then
        print_error "No migration backups found"
        exit 1
    fi
    
    echo "Available backups:"
    for i in "${!backups[@]}"; do
        echo "  $((i+1)). ${backups[$i]}"
    done
    
    read -p "Select backup number (or enter path): " backup_choice
    
    if [[ "$backup_choice" =~ ^[0-9]+$ ]]; then
        BACKUP_DIR="${backups[$((backup_choice-1))]}"
    else
        BACKUP_DIR="$backup_choice"
    fi
    
    if [ ! -d "$BACKUP_DIR" ]; then
        print_error "Backup directory not found: $BACKUP_DIR"
        exit 1
    fi
    
    print_success "Using backup: $BACKUP_DIR"
}

# Stop running containers
stop_containers() {
    print_info "Stopping HomelabARR containers..."
    
    # Stop specific HomelabARR containers
    local containers=("homelabarr-ui-legacy" "homelabarr-legacy-base" "homelabarr-autoscan" "homelabarr-mount")
    
    for container in "${containers[@]}"; do
        if docker ps -a --format '{{.Names}}' | grep -q "^${container}$"; then
            print_info "Stopping $container..."
            docker stop "$container" 2>/dev/null || true
            docker rm "$container" 2>/dev/null || true
        fi
    done
    
    print_success "HomelabARR containers stopped"
}

# Restore docker-compose files
restore_compose() {
    print_info "Restoring Docker Compose files..."
    
    local backup_compose="$BACKUP_DIR/docker-compose-backup"
    
    if [ ! -d "$backup_compose" ]; then
        print_warning "No docker-compose backup found"
        return
    fi
    
    # Restore all .bak files
    for backup_file in $(find "$DOCKER_COMPOSE_DIR" -name "*.bak"); do
        original_file="${backup_file%.bak}"
        print_info "Restoring $original_file..."
        mv "$backup_file" "$original_file"
    done
    
    print_success "Docker Compose files restored"
}

# Restore environment files
restore_env() {
    print_info "Restoring environment files..."
    
    # Restore all .env.bak files
    for backup_file in $(find "$DOCKER_COMPOSE_DIR" -name ".env*.bak"); do
        original_file="${backup_file%.bak}"
        print_info "Restoring $original_file..."
        mv "$backup_file" "$original_file"
    done
    
    print_success "Environment files restored"
}

# Restore data paths
restore_paths() {
    print_info "Restoring data paths..."
    
    # Reverse path changes
    if [ -d "/opt/homelabarr" ] && [ ! -d "/opt/homelabarr" ]; then
        print_info "Moving /opt/homelabarr back to /opt/homelabarr..."
        mv "/opt/homelabarr" "/opt/homelabarr"
    fi
    
    if [ -d "/opt/appdata/homelabarr" ] && [ ! -d "/opt/appdata/homelabarr" ]; then
        print_info "Moving /opt/appdata/homelabarr back to /opt/appdata/homelabarr..."
        mv "/opt/appdata/homelabarr" "/opt/appdata/homelabarr"
    fi
    
    print_success "Data paths restored"
}

# Restore systemd services
restore_systemd() {
    print_info "Restoring systemd services..."
    
    local service_files=(
        "/etc/systemd/system/homelabarr.service"
        "/etc/systemd/system/homelabarr-mount.service"
    )
    
    for service in "${service_files[@]}"; do
        if [ -f "$service.bak" ]; then
            old_service="${service/homelabarr/homelabarr}"
            
            print_info "Restoring $old_service..."
            mv "$service.bak" "$old_service"
            
            # Remove new service
            rm -f "$service"
        fi
    done
    
    # Reload systemd
    systemctl daemon-reload
    
    print_success "Systemd services restored"
}

# Pull HomelabARR images
pull_images() {
    print_info "Pulling HomelabARR images..."
    
    local images=(
        "homelabarr/homelabarr:latest"
        "homelabarr/homelabarr-ui:latest"
    )
    
    for image in "${images[@]}"; do
        print_info "Pulling $image..."
        docker pull "$image" || print_warning "Could not pull $image"
    done
    
    print_success "HomelabARR images pulled"
}

# Verify rollback
verify_rollback() {
    print_info "Verifying rollback..."
    
    local errors=0
    
    # Check for HomelabARR paths
    if [ ! -d "/opt/homelabarr" ]; then
        print_warning "/opt/homelabarr directory not found"
        ((errors++))
    fi
    
    # Check for backup files removed
    local bak_count=$(find "$DOCKER_COMPOSE_DIR" -name "*.bak" 2>/dev/null | wc -l)
    if [ $bak_count -gt 0 ]; then
        print_warning "Found $bak_count backup files remaining"
    fi
    
    if [ $errors -eq 0 ]; then
        print_success "Rollback verified successfully"
        return 0
    else
        print_warning "Rollback completed with warnings. Please review the above messages."
        return 1
    fi
}

# Main rollback process
main() {
    echo "========================================="
    echo "  HomelabARR to HomelabARR Rollback"
    echo "========================================="
    echo ""
    
    check_root
    
    print_warning "This script will rollback your HomelabARR installation to HomelabARR."
    print_warning "This should only be used if you encounter issues with HomelabARR."
    echo ""
    read -p "Continue with rollback? (y/n): " -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Rollback cancelled"
        exit 0
    fi
    
    # Run rollback steps
    find_backup
    stop_containers
    restore_compose
    restore_env
    restore_paths
    restore_systemd
    pull_images
    verify_rollback
    
    echo ""
    echo "========================================="
    echo "         Rollback Complete!"
    echo "========================================="
    echo ""
    print_info "Please review the changes and start your containers with:"
    print_info "  cd /opt/homelabarr && docker-compose up -d"
    echo ""
    print_warning "Note: You may need to manually adjust some configurations"
    print_warning "if they were modified after the initial migration."
}

# Run main function
main "$@"