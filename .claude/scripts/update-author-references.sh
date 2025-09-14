#!/bin/bash

# Update Author References Script - Standardize project attribution
# Replace legacy author references with HomelabARR CLI project attribution

echo "🔄 Updating author references throughout codebase..."

# Counter for processed files
processed=0

# List of files containing legacy author references (excluding backups)
files_to_update=(
    "./backup.sh"
    "./install.sh"
    "./apps/install.sh"
    "./traefik/install.sh"
    "./preinstall/install.sh"
    "./preinstall/installer/subinstall/lxc.sh"
    "./preinstall/installer/subinstall/lxcstart.sh"
    "./preinstall/installer/subinstall/lxc.yml"
    "./apps/.subactions/autoscan.sh"
    "./apps/.subactions/bitwarden.sh"
    "./apps/.subactions/envmigrate.sh"
)

for file in "${files_to_update[@]}"; do
    if [[ -f "$file" ]]; then
        echo "Processing: $file"
        
        # Create backup of original
        cp "$file" "$file.backup"
        
        # Update author references
        sed -i 's/# Author(s):\s*[a-zA-Z0-9_]*$/# Author(s):  HomelabARR CLI Team/g' "$file"
        sed -i 's/# Copyright (c) 20[0-9][0-9],\s*:\s*[a-zA-Z0-9_]*$/# Copyright (c) 2025, HomelabARR CLI Project/g' "$file"
        sed -i 's/# Copyright (c) 20[0-9][0-9],\s*[a-zA-Z0-9_]*$/# Copyright (c) 2025, HomelabARR CLI Project/g' "$file"
        
        # Remove backup if changes were successful
        if [[ $? -eq 0 ]]; then
            rm "$file.backup"
            echo "  ✅ Updated"
            ((processed++))
        else
            # Restore backup if sed failed
            mv "$file.backup" "$file"
            echo "  ❌ Failed to update"
        fi
    else
        echo "  ⚠️  File not found: $file"
    fi
done

echo ""
echo "🎉 Author reference update complete!"
echo "📊 Processed $processed files"
echo "🔧 Updated all legacy author references to HomelabARR CLI (2025)"
