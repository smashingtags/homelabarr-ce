#!/bin/bash

# Fix duplicate volume definitions in YAML files
set -euo pipefail

APPS_DIR="../local-mode-apps"
BACKUP_DIR="duplicate-fix-backup-$(date +%Y%m%d-%H%M%S)"

echo "Creating backup: $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

fixed=0
total=0

echo "Fixing duplicate volume definitions..."

for file in "$APPS_DIR"/*.yml; do
    [[ ! -f "$file" ]] && continue
    ((total++))
    
    filename=$(basename "$file")
    
    # Check if file has duplicate unionfs volumes
    if grep -c "^  unionfs:" "$file" 2>/dev/null | grep -q "^[2-9]"; then
        echo "Fixing: $filename"
        
        # Create backup
        cp "$file" "$BACKUP_DIR/"
        
        # Remove duplicate unionfs volume definitions
        # Keep only the first unionfs definition
        awk '
        /^volumes:/ { in_volumes = 1 }
        /^[a-zA-Z]/ && !/^volumes:/ { in_volumes = 0 }
        /^  unionfs:/ && in_volumes {
            if (!seen_unionfs) {
                seen_unionfs = 1
                print
                getline
                while (/^    / && NF > 0) {
                    print
                    getline
                }
                print
            } else {
                # Skip duplicate unionfs section
                getline
                while (/^    / && NF > 0) {
                    getline
                }
            }
            next
        }
        { print }
        ' "$file" > "${file}.tmp" && mv "${file}.tmp" "$file"
        
        ((fixed++))
    fi
done

echo ""
echo "=== SUMMARY ==="
echo "Files processed: $total"
echo "Files fixed: $fixed"
echo "Backup location: $BACKUP_DIR"

if [[ $fixed -gt 0 ]]; then
    echo "✅ Fixed $fixed files with duplicate volumes"
else
    echo "✅ No duplicate volumes found"
fi
