#!/bin/bash

# Fast GHCR migration script using pre-validated LinuxServer packages
set -euo pipefail

LOG_FILE="fast-ghcr-migration-$(date +%Y%m%d-%H%M%S).log"
BACKUP_DIR="fast-ghcr-backup-$(date +%Y%m%d-%H%M%S)"
APPS_DIR="$(dirname "$0")/../local-mode-apps"
ENV_FILE="$(dirname "$0")/.env"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo -e "${BLUE}[$(date +'%H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_FILE"
}

# Pre-validated LinuxServer packages available on GHCR
declare -A LINUXSERVER_GHCR_PACKAGES=(
    ["lscr.io/linuxserver/sonarr"]="ghcr.io/linuxserver/sonarr"
    ["linuxserver/sonarr"]="ghcr.io/linuxserver/sonarr"
    ["lscr.io/linuxserver/radarr"]="ghcr.io/linuxserver/radarr"
    ["linuxserver/radarr"]="ghcr.io/linuxserver/radarr"
    ["lscr.io/linuxserver/bazarr"]="ghcr.io/linuxserver/bazarr"
    ["linuxserver/bazarr"]="ghcr.io/linuxserver/bazarr"
    ["lscr.io/linuxserver/lidarr"]="ghcr.io/linuxserver/lidarr"
    ["linuxserver/lidarr"]="ghcr.io/linuxserver/lidarr"
    ["lscr.io/linuxserver/prowlarr"]="ghcr.io/linuxserver/prowlarr"
    ["linuxserver/prowlarr"]="ghcr.io/linuxserver/prowlarr"
    ["lscr.io/linuxserver/overseerr"]="ghcr.io/linuxserver/overseerr"
    ["linuxserver/overseerr"]="ghcr.io/linuxserver/overseerr"
    ["lscr.io/linuxserver/jellyfin"]="ghcr.io/linuxserver/jellyfin"
    ["linuxserver/jellyfin"]="ghcr.io/linuxserver/jellyfin"
    ["lscr.io/linuxserver/emby"]="ghcr.io/linuxserver/emby"
    ["linuxserver/emby"]="ghcr.io/linuxserver/emby"
    ["lscr.io/linuxserver/plex"]="ghcr.io/linuxserver/plex"
    ["linuxserver/plex"]="ghcr.io/linuxserver/plex"
    ["lscr.io/linuxserver/tautulli"]="ghcr.io/linuxserver/tautulli"
    ["linuxserver/tautulli"]="ghcr.io/linuxserver/tautulli"
    ["lscr.io/linuxserver/jackett"]="ghcr.io/linuxserver/jackett"
    ["linuxserver/jackett"]="ghcr.io/linuxserver/jackett"
    ["lscr.io/linuxserver/qbittorrent"]="ghcr.io/linuxserver/qbittorrent"
    ["linuxserver/qbittorrent"]="ghcr.io/linuxserver/qbittorrent"
    ["lscr.io/linuxserver/deluge"]="ghcr.io/linuxserver/deluge"
    ["linuxserver/deluge"]="ghcr.io/linuxserver/deluge"
    ["lscr.io/linuxserver/sabnzbd"]="ghcr.io/linuxserver/sabnzbd"
    ["linuxserver/sabnzbd"]="ghcr.io/linuxserver/sabnzbd"
    ["lscr.io/linuxserver/nzbget"]="ghcr.io/linuxserver/nzbget"
    ["linuxserver/nzbget"]="ghcr.io/linuxserver/nzbget"
    ["lscr.io/linuxserver/readarr"]="ghcr.io/linuxserver/readarr"
    ["linuxserver/readarr"]="ghcr.io/linuxserver/readarr"
    ["lscr.io/linuxserver/lazylibrarian"]="ghcr.io/linuxserver/lazylibrarian"
    ["linuxserver/lazylibrarian"]="ghcr.io/linuxserver/lazylibrarian"
    ["lscr.io/linuxserver/heimdall"]="ghcr.io/linuxserver/heimdall"
    ["linuxserver/heimdall"]="ghcr.io/linuxserver/heimdall"
    ["lscr.io/linuxserver/organizr"]="ghcr.io/linuxserver/organizr"
    ["linuxserver/organizr"]="ghcr.io/linuxserver/organizr"
    ["lscr.io/linuxserver/nextcloud"]="ghcr.io/linuxserver/nextcloud"
    ["linuxserver/nextcloud"]="ghcr.io/linuxserver/nextcloud"
    ["lscr.io/linuxserver/duplicati"]="ghcr.io/linuxserver/duplicati"
    ["linuxserver/duplicati"]="ghcr.io/linuxserver/duplicati"
    ["lscr.io/linuxserver/code-server"]="ghcr.io/linuxserver/code-server"
    ["linuxserver/code-server"]="ghcr.io/linuxserver/code-server"
    ["lscr.io/linuxserver/calibre-web"]="ghcr.io/linuxserver/calibre-web"
    ["linuxserver/calibre-web"]="ghcr.io/linuxserver/calibre-web"
    ["lscr.io/linuxserver/bookstack"]="ghcr.io/linuxserver/bookstack"
    ["linuxserver/bookstack"]="ghcr.io/linuxserver/bookstack"
    ["lscr.io/linuxserver/firefox"]="ghcr.io/linuxserver/firefox"
    ["linuxserver/firefox"]="ghcr.io/linuxserver/firefox"
    ["lscr.io/linuxserver/webtop"]="ghcr.io/linuxserver/webtop"
    ["linuxserver/webtop"]="ghcr.io/linuxserver/webtop"
    ["lscr.io/linuxserver/freshrss"]="ghcr.io/linuxserver/freshrss"
    ["linuxserver/freshrss"]="ghcr.io/linuxserver/freshrss"
    ["lscr.io/linuxserver/handbrake"]="ghcr.io/linuxserver/handbrake"
    ["linuxserver/handbrake"]="ghcr.io/linuxserver/handbrake"
)

# Create backup directory
mkdir -p "$BACKUP_DIR"
log "Created backup directory: $BACKUP_DIR"

total_changes=0
total_files=0

# Process all YAML files
for file in "$APPS_DIR"/*.yml; do
    [[ ! -f "$file" ]] && continue
    ((total_files++))
    
    filename=$(basename "$file")
    log "Processing: $filename"
    
    # Create backup
    cp "$file" "$BACKUP_DIR/"
    
    file_changed=false
    
    # Check for image references and environment variables
    while IFS= read -r line; do
        if [[ "$line" =~ image:.*\$\{([^}]+)\} ]]; then
            # Environment variable reference
            env_var="${BASH_REMATCH[1]}"
            if [[ -f "$ENV_FILE" ]] && grep -q "^${env_var}=" "$ENV_FILE"; then
                current_image=$(grep "^${env_var}=" "$ENV_FILE" | cut -d'=' -f2)
                current_base=$(echo "$current_image" | cut -d':' -f1)
                
                if [[ -n "${LINUXSERVER_GHCR_PACKAGES[$current_base]:-}" ]]; then
                    new_image="${LINUXSERVER_GHCR_PACKAGES[$current_base]}:latest"
                    sed -i "s|^${env_var}=.*|${env_var}=${new_image}|" "$ENV_FILE"
                    success "  Updated env var $env_var: $current_image -> $new_image"
                    file_changed=true
                    ((total_changes++))
                fi
            fi
        elif [[ "$line" =~ image:[[:space:]]*([^[:space:]]+) ]]; then
            # Direct image reference
            current_image="${BASH_REMATCH[1]}"
            current_base=$(echo "$current_image" | cut -d':' -f1)
            
            if [[ -n "${LINUXSERVER_GHCR_PACKAGES[$current_base]:-}" ]]; then
                new_image="${LINUXSERVER_GHCR_PACKAGES[$current_base]}:latest"
                sed -i "s|image: ${current_image}|image: ${new_image}|g" "$file"
                success "  Updated image: $current_image -> $new_image"
                file_changed=true
                ((total_changes++))
            fi
        fi
    done < "$file"
    
    if [[ "$file_changed" == false ]]; then
        log "  No changes needed"
    fi
done

log ""
log "=== MIGRATION SUMMARY ==="
log "Files processed: $total_files"
log "Total changes: $total_changes"
log "Backup location: $BACKUP_DIR"

if [[ $total_changes -gt 0 ]]; then
    success "Migration completed! $total_changes images migrated to GHCR."
else
    log "No eligible images found for migration."
fi
