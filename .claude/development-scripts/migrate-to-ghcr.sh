#!/bin/bash

# Script to migrate Docker images from Docker Hub to GitHub Container Registry (GHCR)
# Specifically targeting LinuxServer images to avoid Docker Hub rate limits

set -euo pipefail

LOG_FILE="ghcr-migration-$(date +%Y%m%d-%H%M%S).log"
BACKUP_DIR="ghcr-migration-backup-$(date +%Y%m%d-%H%M%S)"
APPS_DIR="$(dirname "$0")/../local-mode-apps"
ENV_FILE="$(dirname "$0")/.env"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_FILE"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOG_FILE"
}

# Function to check if image exists on registry
check_image_exists() {
    local image="$1"
    local registry_url=""
    
    if [[ "$image" == ghcr.io/* ]]; then
        # For GHCR, use GitHub API
        local repo_path=$(echo "$image" | sed 's|ghcr.io/||' | cut -d':' -f1)
        local tag=$(echo "$image" | cut -d':' -f2)
        [[ "$tag" == "$image" ]] && tag="latest"
        
        registry_url="https://ghcr.io/v2/${repo_path}/manifests/${tag}"
        if curl -s -f -H "Accept: application/vnd.docker.distribution.manifest.v2+json" "$registry_url" >/dev/null 2>&1; then
            return 0
        fi
    else
        # For Docker Hub
        local repo=$(echo "$image" | cut -d':' -f1)
        local tag=$(echo "$image" | cut -d':' -f2)
        [[ "$tag" == "$image" ]] && tag="latest"
        
        # Handle official images (no namespace)
        if [[ "$repo" != *"/"* ]]; then
            repo="library/$repo"
        fi
        
        registry_url="https://registry-1.docker.io/v2/${repo}/manifests/${tag}"
        if curl -s -f -H "Accept: application/vnd.docker.distribution.manifest.v2+json" "$registry_url" >/dev/null 2>&1; then
            return 0
        fi
    fi
    
    return 1
}

# Function to get LinuxServer equivalent
get_linuxserver_equivalent() {
    local current_image="$1"
    local app_name="$2"
    
    # Extract base image name
    local base_name=""
    if [[ "$current_image" == *"/"* ]]; then
        base_name=$(basename "$current_image" | cut -d':' -f1)
    else
        base_name=$(echo "$current_image" | cut -d':' -f1)
    fi
    
    # Common LinuxServer image mappings
    local ghcr_image="ghcr.io/linuxserver/${base_name}:latest"
    
    # Special cases for known mappings
    case "$base_name" in
        "plex"|"plexinc/pms-docker")
            ghcr_image="ghcr.io/linuxserver/plex:latest"
            ;;
        "qbittorrent")
            ghcr_image="ghcr.io/linuxserver/qbittorrent:latest"
            ;;
        "sonarr")
            ghcr_image="ghcr.io/linuxserver/sonarr:latest"
            ;;
        "radarr")
            ghcr_image="ghcr.io/linuxserver/radarr:latest"
            ;;
        "bazarr")
            ghcr_image="ghcr.io/linuxserver/bazarr:latest"
            ;;
        "lidarr")
            ghcr_image="ghcr.io/linuxserver/lidarr:latest"
            ;;
        "prowlarr")
            ghcr_image="ghcr.io/linuxserver/prowlarr:latest"
            ;;
        "overseerr")
            ghcr_image="ghcr.io/linuxserver/overseerr:latest"
            ;;
        "jellyfin")
            ghcr_image="ghcr.io/linuxserver/jellyfin:latest"
            ;;
        "emby"|"embyserver")
            ghcr_image="ghcr.io/linuxserver/emby:latest"
            ;;
        "tautulli")
            ghcr_image="ghcr.io/linuxserver/tautulli:latest"
            ;;
        "jackett")
            ghcr_image="ghcr.io/linuxserver/jackett:latest"
            ;;
        "deluge")
            ghcr_image="ghcr.io/linuxserver/deluge:latest"
            ;;
        "sabnzbd")
            ghcr_image="ghcr.io/linuxserver/sabnzbd:latest"
            ;;
        "nzbget")
            ghcr_image="ghcr.io/linuxserver/nzbget:latest"
            ;;
        "readarr")
            ghcr_image="ghcr.io/linuxserver/readarr:latest"
            ;;
        "lazylibrarian")
            ghcr_image="ghcr.io/linuxserver/lazylibrarian:latest"
            ;;
        "heimdall")
            ghcr_image="ghcr.io/linuxserver/heimdall:latest"
            ;;
        "organizr")
            ghcr_image="ghcr.io/linuxserver/organizr:latest"
            ;;
        "nextcloud")
            ghcr_image="ghcr.io/linuxserver/nextcloud:latest"
            ;;
        "duplicati")
            ghcr_image="ghcr.io/linuxserver/duplicati:latest"
            ;;
        "code-server")
            ghcr_image="ghcr.io/linuxserver/code-server:latest"
            ;;
        "calibre-web")
            ghcr_image="ghcr.io/linuxserver/calibre-web:latest"
            ;;
        "bookstack")
            ghcr_image="ghcr.io/linuxserver/bookstack:latest"
            ;;
        *)
            # Try the app name if base name doesn't work
            if [[ "$app_name" != "$base_name" ]]; then
                ghcr_image="ghcr.io/linuxserver/${app_name}:latest"
            fi
            ;;
    esac
    
    echo "$ghcr_image"
}

# Function to update image in file
update_image_in_file() {
    local file="$1"
    local old_image="$2"
    local new_image="$3"
    local var_name="$4"
    
    if [[ -f "$file" ]]; then
        # Create backup
        cp "$file" "${BACKUP_DIR}/$(basename "$file")"
        
        # Update the image reference
        sed -i "s|image: ${old_image}|image: ${new_image}|g" "$file"
        
        # Also update in .env file if it's an environment variable
        if [[ -n "$var_name" && -f "$ENV_FILE" ]]; then
            if grep -q "^${var_name}=" "$ENV_FILE"; then
                sed -i "s|^${var_name}=.*|${var_name}=${new_image}|" "$ENV_FILE"
            else
                echo "${var_name}=${new_image}" >> "$ENV_FILE"
            fi
        fi
        
        success "Updated $file: $old_image -> $new_image"
        return 0
    else
        error "File not found: $file"
        return 1
    fi
}

# Function to process a single YAML file
process_yaml_file() {
    local file="$1"
    local app_name=$(basename "$file" .yml)
    local changes_made=0
    
    log "Processing: $file"
    
    # Extract images from the YAML file
    local images=($(grep -E "^\s*image:\s*" "$file" | sed 's/.*image:\s*//' | tr -d '"' | sort -u))
    
    # Also check for environment variable references
    local env_images=($(grep -E "^\s*image:\s*\\\$\{.*\}" "$file" | sed 's/.*image:\s*\${//' | sed 's/}.*//' | sort -u))
    
    for image in "${images[@]}"; do
        [[ -z "$image" ]] && continue
        
        # Skip if already using GHCR LinuxServer
        if [[ "$image" == ghcr.io/linuxserver/* ]]; then
            log "  Already using GHCR LinuxServer: $image"
            continue
        fi
        
        # Skip if it's an environment variable
        if [[ "$image" == \$\{*\} ]]; then
            continue
        fi
        
        local ghcr_image=$(get_linuxserver_equivalent "$image" "$app_name")
        
        log "  Checking: $image -> $ghcr_image"
        
        if check_image_exists "$ghcr_image"; then
            success "  ✓ GHCR image exists: $ghcr_image"
            if update_image_in_file "$file" "$image" "$ghcr_image" ""; then
                ((changes_made++))
            fi
        else
            warning "  ✗ GHCR image not found: $ghcr_image"
            log "    Keeping original: $image"
        fi
    done
    
    # Process environment variable images
    for env_var in "${env_images[@]}"; do
        [[ -z "$env_var" ]] && continue
        
        if [[ -f "$ENV_FILE" ]] && grep -q "^${env_var}=" "$ENV_FILE"; then
            local current_image=$(grep "^${env_var}=" "$ENV_FILE" | cut -d'=' -f2)
            
            # Skip if already using GHCR LinuxServer
            if [[ "$current_image" == ghcr.io/linuxserver/* ]]; then
                log "  Environment var $env_var already using GHCR LinuxServer: $current_image"
                continue
            fi
            
            local ghcr_image=$(get_linuxserver_equivalent "$current_image" "$app_name")
            
            log "  Checking env var $env_var: $current_image -> $ghcr_image"
            
            if check_image_exists "$ghcr_image"; then
                success "  ✓ GHCR image exists for $env_var: $ghcr_image"
                if update_image_in_file "$file" "$current_image" "$ghcr_image" "$env_var"; then
                    ((changes_made++))
                fi
            else
                warning "  ✗ GHCR image not found for $env_var: $ghcr_image"
                log "    Keeping original: $current_image"
            fi
        fi
    done
    
    if [[ $changes_made -gt 0 ]]; then
        success "  Made $changes_made changes in $file"
    else
        log "  No changes needed for $file"
    fi
    
    return $changes_made
}

# Main execution
main() {
    log "Starting GHCR migration for homelabarr-cli packages"
    log "Log file: $LOG_FILE"
    
    # Create backup directory
    mkdir -p "$BACKUP_DIR"
    log "Backup directory: $BACKUP_DIR"
    
    # Check if apps directory exists
    if [[ ! -d "$APPS_DIR" ]]; then
        error "Apps directory not found: $APPS_DIR"
        exit 1
    fi
    
    local total_files=0
    local processed_files=0
    local total_changes=0
    
    # Count total YAML files
    total_files=$(find "$APPS_DIR" -name "*.yml" -type f | wc -l)
    log "Found $total_files YAML files to process"
    
    # Process each YAML file
    while IFS= read -r -d '' file; do
        ((processed_files++))
        log "Progress: $processed_files/$total_files"
        
        if process_yaml_file "$file"; then
            ((total_changes += $?))
        fi
        
        echo "---"
    done < <(find "$APPS_DIR" -name "*.yml" -type f -print0)
    
    # Summary
    echo ""
    log "=== MIGRATION SUMMARY ==="
    log "Total files processed: $processed_files"
    log "Total changes made: $total_changes"
    log "Backup directory: $BACKUP_DIR"
    log "Log file: $LOG_FILE"
    
    if [[ $total_changes -gt 0 ]]; then
        success "Migration completed successfully!"
        log ""
        log "Next steps:"
        log "1. Review the changes in the log file"
        log "2. Test your applications"
        log "3. If issues occur, restore from backup: $BACKUP_DIR"
    else
        log "No changes were needed."
    fi
}

# Check if running with required tools
if ! command -v curl >/dev/null 2>&1; then
    error "curl is required but not installed"
    exit 1
fi

if ! command -v sed >/dev/null 2>&1; then
    error "sed is required but not installed"
    exit 1
fi

# Run main function
main "$@"
