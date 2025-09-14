#!/bin/bash

# Simple YAML Fix Script - Test version
set -e

echo "🔧 Simple YAML Fix Test"
echo "======================="

BULK_APPS_DIR="../local-mode-apps"
BACKUP_DIR="./simple-fix-backup-$(date +%Y%m%d-%H%M%S)"

mkdir -p "$BACKUP_DIR"

# Test on just a few files first
test_files=("plex.yml" "nextcloud.yml" "radarr.yml" "sonarr.yml")

for app_file in "${test_files[@]}"; do
    file="$BULK_APPS_DIR/$app_file"
    if [[ -f "$file" ]]; then
        app_name=$(basename "$file" .yml)
        backup_file="$BACKUP_DIR/${app_name}.yml"
        
        echo "Processing $app_name..."
        
        # Create backup
        cp "$file" "$backup_file"
        
        # Fix the specific malformed ports issue
        # Change "ports:      - "port:port"" to proper YAML format
        if grep -q "ports:.*-.*:" "$file"; then
            echo "  🔧 Fixing malformed ports in $app_name"
            
            # Create temp file with fix
            sed 's/ports:[[:space:]]*-[[:space:]]*/ports:\n      - /' "$file" > "${file}.tmp"
            
            # Test YAML validity
            if docker-compose -f "${file}.tmp" config --quiet 2>/dev/null; then
                mv "${file}.tmp" "$file"
                echo "  ✅ Fixed and validated $app_name"
            else
                rm "${file}.tmp"
                echo "  ❌ YAML validation failed for $app_name"
            fi
        else
            echo "  ℹ️ No malformed ports found in $app_name"
        fi
    else
        echo "❌ File not found: $file"
    fi
done

echo
echo "✅ Simple fix complete!"
echo "💾 Backups in: $BACKUP_DIR"
