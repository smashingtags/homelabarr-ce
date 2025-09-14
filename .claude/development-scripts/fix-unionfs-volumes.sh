#!/bin/bash

# Script to fix unionfs volume configuration inconsistencies
YAML_DIR="../local-mode-apps"

echo "🔧 Fixing unionfs volume configurations..."
echo "=========================================="

# Standard unionfs volume definition
VOLUME_DEFINITION="
volumes:
  unionfs:
    driver: local-persist
    driver_opts:
      mountpoint: /mnt"

# Create backup directory
BACKUP_DIR="volume-fix-backup-$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"
echo "✅ Created backup directory: $BACKUP_DIR"

# Find all YAML files that use unionfs in volumes but don't define it
for yaml_file in "$YAML_DIR"/*.yml; do
    if [[ -f "$yaml_file" ]]; then
        filename=$(basename "$yaml_file")
        
        # Check if file uses unionfs in volumes section
        if grep -q "unionfs:/mnt" "$yaml_file"; then
            # Check if file already defines unionfs volume
            if ! grep -q "driver: local-persist" "$yaml_file"; then
                echo "🔄 Fixing $filename"
                
                # Create backup
                cp "$yaml_file" "$BACKUP_DIR/"
                
                # Check if file has any volume definitions
                if grep -q "^volumes:" "$yaml_file"; then
                    # File has volumes section but missing unionfs definition
                    if ! grep -q "unionfs:" "$yaml_file" | grep -q "driver:"; then
                        # Add unionfs definition to existing volumes section
                        sed -i '/^volumes:/a\
  unionfs:\
    driver: local-persist\
    driver_opts:\
      mountpoint: /mnt' "$yaml_file"
                    fi
                else
                    # File has no volumes section, add complete volume definition
                    # Add before networks section or at end of file
                    if grep -q "^networks:" "$yaml_file"; then
                        sed -i '/^networks:/i\
volumes:\
  unionfs:\
    driver: local-persist\
    driver_opts:\
      mountpoint: /mnt\
' "$yaml_file"
                    else
                        echo "$VOLUME_DEFINITION" >> "$yaml_file"
                    fi
                fi
                echo "   ✅ Fixed $filename"
            else
                echo "   ℹ️  $filename already has unionfs volume definition"
            fi
        fi
    fi
done

echo ""
echo "🎉 Volume configuration fixes complete!"
echo "📁 Backups stored in: $BACKUP_DIR"
echo ""
echo "Now all YAML files should have consistent unionfs volume definitions."
