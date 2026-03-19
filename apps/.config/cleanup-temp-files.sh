#!/bin/bash

# HomelabARR CLI - Temporary Files and Configuration Cleanup Script
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
PROJECT_ROOT="$(dirname "$APPS_DIR")"
LOG_FILE="/tmp/homelabarr-cleanup-$(date +%Y%m%d_%H%M%S).log"

# Cleanup categories
declare -A CLEANUP_CATEGORIES=(
    ["temp_files"]="Temporary files and cache"
    ["backup_files"]="Old backup files"
    ["log_files"]="Rotated log files"
    ["docker_artifacts"]="Docker build artifacts"
    ["config_artifacts"]="Configuration artifacts"
    ["validation_reports"]="Old validation reports"
    ["all"]="All cleanup categories"
)

# File patterns to clean
declare -A TEMP_PATTERNS=(
    ["temp_files"]="/tmp/homelabarr-* /tmp/homelabarr-ce-* *.tmp *.temp"
    ["backup_files"]="*.backup *.bak *~"
    ["log_files"]="*.log.* *.log.gz *.log.bz2"
    ["docker_artifacts"]="docker-compose.override.yml .dockerignore"
    ["config_artifacts"]="*.orig *.old *.new"
    ["validation_reports"]="/tmp/homelabarr-validation-* /tmp/homelabarr-port-*"
)

# Age thresholds (in days)
declare -A AGE_THRESHOLDS=(
    ["temp_files"]="1"
    ["backup_files"]="7" 
    ["log_files"]="30"
    ["docker_artifacts"]="7"
    ["config_artifacts"]="7"
    ["validation_reports"]="7"
)

# Statistics
TOTAL_FILES_FOUND=0
TOTAL_FILES_CLEANED=0
TOTAL_SIZE_CLEANED=0

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

# Convert bytes to human readable format
bytes_to_human() {
    local bytes=$1
    if (( bytes < 1024 )); then
        echo "${bytes}B"
    elif (( bytes < 1048576 )); then
        echo "$(( bytes / 1024 ))KB"
    elif (( bytes < 1073741824 )); then
        echo "$(( bytes / 1048576 ))MB"
    else
        echo "$(( bytes / 1073741824 ))GB"
    fi
}

# Check if file is older than threshold
is_file_old_enough() {
    local file="$1"
    local threshold_days="$2"
    
    if [[ ! -f "$file" ]]; then
        return 1
    fi
    
    local file_age
    file_age=$(stat -c %Y "$file" 2>/dev/null || stat -f %m "$file" 2>/dev/null || echo 0)
    local current_time
    current_time=$(date +%s)
    local threshold_seconds=$((threshold_days * 24 * 3600))
    
    if (( current_time - file_age > threshold_seconds )); then
        return 0
    else
        return 1
    fi
}

# Get file size
get_file_size() {
    local file="$1"
    if [[ -f "$file" ]]; then
        stat -c %s "$file" 2>/dev/null || stat -f %z "$file" 2>/dev/null || echo 0
    else
        echo 0
    fi
}

# Clean files by pattern and age
clean_by_pattern() {
    local category="$1"
    local patterns="${TEMP_PATTERNS[$category]}"
    local threshold="${AGE_THRESHOLDS[$category]}"
    local dry_run="$2"
    
    local category_files=0
    local category_size=0
    
    print_status "INFO" "Cleaning category: $category (older than $threshold days)"
    
    # Process each pattern
    for pattern in $patterns; do
        # Handle absolute paths (like /tmp/*)
        if [[ "$pattern" == /* ]]; then
            while IFS= read -r -d '' file; do
                if is_file_old_enough "$file" "$threshold"; then
                    local size
                    size=$(get_file_size "$file")
                    
                    ((TOTAL_FILES_FOUND++))
                    ((category_files++))
                    category_size=$((category_size + size))
                    
                    if [[ "$dry_run" == "false" ]]; then
                        if rm -f "$file" 2>/dev/null; then
                            ((TOTAL_FILES_CLEANED++))
                            TOTAL_SIZE_CLEANED=$((TOTAL_SIZE_CLEANED + size))
                            log "Removed: $file ($(bytes_to_human "$size"))"
                        else
                            print_status "WARNING" "Failed to remove: $file"
                        fi
                    else
                        log "Would remove: $file ($(bytes_to_human "$size"))"
                    fi
                fi
            done < <(find /tmp -name "${pattern#/tmp/}" -type f -print0 2>/dev/null || true)
        else
            # Handle relative patterns
            while IFS= read -r -d '' file; do
                if is_file_old_enough "$file" "$threshold"; then
                    local size
                    size=$(get_file_size "$file")
                    
                    ((TOTAL_FILES_FOUND++))
                    ((category_files++))
                    category_size=$((category_size + size))
                    
                    if [[ "$dry_run" == "false" ]]; then
                        if rm -f "$file" 2>/dev/null; then
                            ((TOTAL_FILES_CLEANED++))
                            TOTAL_SIZE_CLEANED=$((TOTAL_SIZE_CLEANED + size))
                            log "Removed: $file ($(bytes_to_human "$size"))"
                        else
                            print_status "WARNING" "Failed to remove: $file"
                        fi
                    else
                        log "Would remove: $file ($(bytes_to_human "$size"))"
                    fi
                fi
            done < <(find "$PROJECT_ROOT" -name "$pattern" -type f -print0 2>/dev/null || true)
        fi
    done
    
    if [[ $category_files -gt 0 ]]; then
        print_status "SUCCESS" "Category $category: $category_files files ($(bytes_to_human "$category_size"))"
    else
        print_status "INFO" "Category $category: No files to clean"
    fi
}

# Clean Docker-related temporary files
clean_docker_temp() {
    local dry_run="$1"
    
    print_status "INFO" "Cleaning Docker temporary files..."
    
    local docker_temp_dirs=(
        "/tmp/docker-*"
        "/var/tmp/docker-*"
        "$HOME/.docker/tmp"
    )
    
    for dir_pattern in "${docker_temp_dirs[@]}"; do
        if [[ "$dir_pattern" == /* ]]; then
            # Absolute path pattern
            for dir in $dir_pattern; do
                if [[ -d "$dir" ]] && is_file_old_enough "$dir" "1"; then
                    local size
                    size=$(du -sb "$dir" 2>/dev/null | cut -f1 || echo 0)
                    
                    if [[ "$dry_run" == "false" ]]; then
                        if rm -rf "$dir" 2>/dev/null; then
                            TOTAL_SIZE_CLEANED=$((TOTAL_SIZE_CLEANED + size))
                            log "Removed directory: $dir ($(bytes_to_human "$size"))"
                        fi
                    else
                        log "Would remove directory: $dir ($(bytes_to_human "$size"))"
                    fi
                fi
            done
        fi
    done
}

# Clean application-specific cache directories
clean_app_cache() {
    local dry_run="$1"
    
    print_status "INFO" "Cleaning application cache directories..."
    
    # Common cache directories that can be safely cleaned
    local cache_patterns=(
        "*/cache/*"
        "*/tmp/*"
        "*/.cache/*"
        "*/logs/*.log.*"
    )
    
    for pattern in "${cache_patterns[@]}"; do
        while IFS= read -r -d '' file; do
            # Skip if in apps config directory
            if [[ "$file" == *"apps/.config"* ]]; then
                continue
            fi
            
            if is_file_old_enough "$file" "7"; then
                local size
                size=$(get_file_size "$file")
                
                if [[ "$dry_run" == "false" ]]; then
                    if rm -f "$file" 2>/dev/null; then
                        TOTAL_SIZE_CLEANED=$((TOTAL_SIZE_CLEANED + size))
                        log "Removed cache file: $file ($(bytes_to_human "$size"))"
                    fi
                else
                    log "Would remove cache file: $file ($(bytes_to_human "$size"))"
                fi
            fi
        done < <(find "$PROJECT_ROOT" -path "$pattern" -type f -print0 2>/dev/null || true)
    done
}

# Clean orphaned Docker volumes (dry run only shows, never auto-removes)
check_orphaned_volumes() {
    print_status "INFO" "Checking for orphaned Docker volumes..."
    
    if command -v docker &> /dev/null; then
        local orphaned_volumes
        orphaned_volumes=$(docker volume ls -q --filter dangling=true 2>/dev/null || true)
        
        if [[ -n "$orphaned_volumes" ]]; then
            print_status "WARNING" "Found orphaned Docker volumes:"
            echo "$orphaned_volumes" | while read -r volume; do
                if [[ -n "$volume" ]]; then
                    print_status "WARNING" "  - $volume"
                fi
            done
            echo
            print_status "INFO" "To remove orphaned volumes manually, run:"
            print_status "INFO" "  docker volume prune"
        else
            print_status "SUCCESS" "No orphaned Docker volumes found"
        fi
    else
        print_status "WARNING" "Docker not available - skipping volume check"
    fi
}

# Vacuum and optimize databases if present
optimize_databases() {
    local dry_run="$1"
    
    print_status "INFO" "Checking for database optimization opportunities..."
    
    # Look for SQLite databases that might benefit from VACUUM
    while IFS= read -r -d '' db_file; do
        if [[ -f "$db_file" ]] && file "$db_file" | grep -q "SQLite"; then
            local size_before
            size_before=$(get_file_size "$db_file")
            
            if [[ "$dry_run" == "false" ]]; then
                if sqlite3 "$db_file" "VACUUM;" 2>/dev/null; then
                    local size_after
                    size_after=$(get_file_size "$db_file")
                    local savings=$((size_before - size_after))
                    
                    if [[ $savings -gt 0 ]]; then
                        log "Optimized database: $db_file (saved $(bytes_to_human "$savings"))"
                        TOTAL_SIZE_CLEANED=$((TOTAL_SIZE_CLEANED + savings))
                    fi
                fi
            else
                log "Would optimize database: $db_file ($(bytes_to_human "$size_before"))"
            fi
        fi
    done < <(find "$PROJECT_ROOT" -name "*.db" -o -name "*.sqlite" -o -name "*.sqlite3" | head -20 | xargs -0 -I {} echo {} | tr '\n' '\0')
}

# Clean system-level temporary files (with caution)
clean_system_temp() {
    local dry_run="$1"
    
    print_status "INFO" "Cleaning system temporary files..."
    
    # Only clean files we know are safe and related to our project
    local safe_system_patterns=(
        "/tmp/homelabarr-*"
        "/tmp/homelabarr-ce-*" 
        "/tmp/*validation-report*"
        "/tmp/*port-fix*"
        "/tmp/*config-backup*"
    )
    
    for pattern in "${safe_system_patterns[@]}"; do
        for file in $pattern; do
            if [[ -f "$file" ]] && is_file_old_enough "$file" "1"; then
                local size
                size=$(get_file_size "$file")
                
                if [[ "$dry_run" == "false" ]]; then
                    if rm -f "$file" 2>/dev/null; then
                        TOTAL_SIZE_CLEANED=$((TOTAL_SIZE_CLEANED + size))
                        log "Removed system temp file: $file ($(bytes_to_human "$size"))"
                    fi
                else
                    log "Would remove system temp file: $file ($(bytes_to_human "$size"))"
                fi
            fi
        done
    done
}

# Generate cleanup report
generate_report() {
    local dry_run="$1"
    local report_file="/tmp/homelabarr-cleanup-report-$(date +%Y%m%d_%H%M%S).json"
    
    local action
    if [[ "$dry_run" == "true" ]]; then
        action="would_clean"
    else
        action="cleaned"
    fi
    
    cat > "$report_file" << EOF
{
  "cleanup_timestamp": "$(date -Iseconds)",
  "script_version": "2.3.0",
  "dry_run": $dry_run,
  "summary": {
    "total_files_found": $TOTAL_FILES_FOUND,
    "total_files_$action": $TOTAL_FILES_CLEANED,
    "total_size_$action": "$TOTAL_SIZE_CLEANED",
    "total_size_human": "$(bytes_to_human $TOTAL_SIZE_CLEANED)"
  },
  "categories_processed": [
    $(printf '"%s",' "${!CLEANUP_CATEGORIES[@]}" | sed 's/,$//')
  ],
  "log_file": "$LOG_FILE",
  "report_file": "$report_file"
}
EOF
    
    print_status "INFO" "Cleanup report generated: $report_file"
}

# Show cleanup summary
show_summary() {
    local dry_run="$1"
    
    echo
    echo "=============================="
    echo "CLEANUP SUMMARY"
    echo "=============================="
    
    if [[ "$dry_run" == "true" ]]; then
        echo "DRY RUN - No files were actually removed"
        echo "Files that would be cleaned: $TOTAL_FILES_FOUND"
        echo "Space that would be freed: $(bytes_to_human $TOTAL_SIZE_CLEANED)"
    else
        echo "Files processed: $TOTAL_FILES_FOUND"
        echo "Files cleaned: $TOTAL_FILES_CLEANED"
        echo "Space freed: $(bytes_to_human $TOTAL_SIZE_CLEANED)"
    fi
    
    echo "Log file: $LOG_FILE"
    echo
    
    if [[ $TOTAL_FILES_CLEANED -gt 0 ]] || [[ "$dry_run" == "true" && $TOTAL_FILES_FOUND -gt 0 ]]; then
        if [[ "$dry_run" == "true" ]]; then
            print_status "INFO" "Dry run completed - no changes made"
        else
            print_status "SUCCESS" "Cleanup completed successfully"
        fi
    else
        print_status "INFO" "No files needed cleaning"
    fi
}

# Interactive mode for selective cleanup
interactive_cleanup() {
    print_status "INFO" "Interactive cleanup mode"
    echo
    
    echo "Select cleanup categories:"
    local i=1
    local categories=()
    
    for category in "${!CLEANUP_CATEGORIES[@]}"; do
        if [[ "$category" != "all" ]]; then
            categories+=("$category")
            echo "  $i) $category - ${CLEANUP_CATEGORIES[$category]}"
            ((i++))
        fi
    done
    
    echo "  $i) all - Clean all categories"
    echo "  0) Exit"
    echo
    
    read -p "Enter your choice (0-$i): " choice
    
    if [[ "$choice" == "0" ]]; then
        print_status "INFO" "Cleanup cancelled"
        return 0
    elif [[ "$choice" == "$i" ]]; then
        # Clean all categories
        for category in "${categories[@]}"; do
            clean_by_pattern "$category" "false"
        done
        clean_docker_temp "false"
        clean_app_cache "false"
        optimize_databases "false"
    elif [[ "$choice" =~ ^[1-9][0-9]*$ ]] && [[ $choice -le ${#categories[@]} ]]; then
        local selected_category="${categories[$((choice-1))]}"
        print_status "INFO" "Cleaning category: $selected_category"
        clean_by_pattern "$selected_category" "false"
    else
        print_status "ERROR" "Invalid choice"
        return 1
    fi
}

# Main cleanup function
main() {
    local mode="${1:-auto}"
    local dry_run="${2:-false}"
    
    echo "HomelabARR CLI - Cleanup Utility"
    echo "================================"
    echo
    
    if [[ "$dry_run" == "true" ]]; then
        print_status "INFO" "DRY RUN MODE - No files will be deleted"
        echo
    fi
    
    log "Starting cleanup - Mode: $mode, Dry run: $dry_run"
    
    case "$mode" in
        "auto")
            print_status "INFO" "Automatic cleanup mode"
            for category in "${!CLEANUP_CATEGORIES[@]}"; do
                if [[ "$category" != "all" ]]; then
                    clean_by_pattern "$category" "$dry_run"
                fi
            done
            clean_docker_temp "$dry_run"
            clean_app_cache "$dry_run"
            clean_system_temp "$dry_run"
            check_orphaned_volumes
            optimize_databases "$dry_run"
            ;;
        "interactive")
            interactive_cleanup
            ;;
        "temp-only")
            print_status "INFO" "Temporary files only"
            clean_by_pattern "temp_files" "$dry_run"
            clean_system_temp "$dry_run"
            ;;
        "docker")
            print_status "INFO" "Docker cleanup mode"
            clean_docker_temp "$dry_run"
            check_orphaned_volumes
            ;;
        *)
            if [[ -n "${CLEANUP_CATEGORIES[$mode]:-}" ]]; then
                clean_by_pattern "$mode" "$dry_run"
            else
                print_status "ERROR" "Invalid mode: $mode"
                return 1
            fi
            ;;
    esac
    
    generate_report "$dry_run"
    show_summary "$dry_run"
}

# Handle script arguments
case "${1:-}" in
    --help|-h)
        echo "HomelabARR CLI Cleanup Utility"
        echo
        echo "Usage: $0 [MODE] [OPTIONS]"
        echo
        echo "Modes:"
        echo "  auto         Clean all categories automatically (default)"
        echo "  interactive  Interactive cleanup with category selection"
        echo "  temp-only    Clean only temporary files"
        echo "  docker       Clean Docker-related temporary files"
        printf "  %-12s Clean specific category\n" "$(printf "%s|" "${!CLEANUP_CATEGORIES[@]}" | sed 's/|$//')"
        echo
        echo "Options:"
        echo "  --dry-run    Show what would be cleaned without deleting"
        echo "  --help, -h   Show this help message"
        echo "  --version    Show version information"
        echo
        echo "Categories:"
        for category in "${!CLEANUP_CATEGORIES[@]}"; do
            printf "  %-15s %s\n" "$category" "${CLEANUP_CATEGORIES[$category]}"
        done
        echo
        echo "Examples:"
        echo "  $0                    # Auto cleanup"
        echo "  $0 --dry-run          # Show what would be cleaned"
        echo "  $0 interactive        # Interactive mode"
        echo "  $0 temp-only          # Clean only temp files"
        echo "  $0 backup_files       # Clean only backup files"
        exit 0
        ;;
    --version)
        echo "HomelabARR CLI Cleanup Utility v2.3.0"
        echo "Part of HL-2: Container Configuration Modernization"
        exit 0
        ;;
    --dry-run)
        main "${2:-auto}" "true"
        ;;
    *)
        # Check if second argument is --dry-run
        if [[ "${2:-}" == "--dry-run" ]]; then
            main "${1:-auto}" "true"
        else
            main "${1:-auto}" "false"
        fi
        ;;
esac
