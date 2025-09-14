#!/bin/bash

# Quick GHCR migration script
BACKUP_DIR="quick-backup-$(date +%Y%m%d-%H%M%S)"
APPS_DIR="../local-mode-apps"
ENV_FILE=".env"

echo "Creating backup: $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

# Backup .env file
cp "$ENV_FILE" "$BACKUP_DIR/" 2>/dev/null || true

changes=0

echo "Updating .env file..."

# Update common LinuxServer images in .env
sed -i 's|lscr\.io/linuxserver/|ghcr.io/linuxserver/|g' "$ENV_FILE"
sed -i 's|linuxserver/\([^:]*\):latest|ghcr.io/linuxserver/\1:latest|g' "$ENV_FILE"

echo "Updating YAML files..."

# Update YAML files
for file in "$APPS_DIR"/*.yml; do
    [[ ! -f "$file" ]] && continue
    
    filename=$(basename "$file")
    cp "$file" "$BACKUP_DIR/"
    
    # Replace lscr.io/linuxserver with ghcr.io/linuxserver
    if sed -i 's|lscr\.io/linuxserver/|ghcr.io/linuxserver/|g' "$file"; then
        echo "  Updated: $filename"
        ((changes++))
    fi
    
    # Replace direct linuxserver references
    if sed -i 's|image: linuxserver/\([^:]*\)|image: ghcr.io/linuxserver/\1|g' "$file"; then
        echo "  Updated: $filename"
        ((changes++))
    fi
done

echo ""
echo "=== SUMMARY ==="
echo "Files processed: $(ls "$APPS_DIR"/*.yml | wc -l)"
echo "Changes made: $changes"
echo "Backup location: $BACKUP_DIR"
echo ""
echo "✓ Migration complete! LinuxServer images now use GHCR registry."
