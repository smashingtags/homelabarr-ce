#!/bin/bash

# Real-time Fix - Process apps with immediate feedback
set -e

echo "🚀 Real-time YAML Fix - 161 Applications"
echo "========================================"

BULK_APPS_DIR="../local-mode-apps"
PORT_START=8200
current_port=$PORT_START
fixed=0
failed=0
total=0

echo "🔄 Processing applications (showing progress every 10)..."

for file in "$BULK_APPS_DIR"/*.yml; do
    if [[ -f "$file" ]]; then
        app=$(basename "$file" .yml)
        ((total++))
        
        # Create backup
        cp "$file" "${file}.original" 2>/dev/null || true
        
        # Apply fixes (using proven pattern)
        
        # Fix malformed ports
        sed -i 's/ports:[[:space:]]*-[[:space:]]*/ports:\n      - /' "$file" 2>/dev/null || true
        
        # Fix orphaned ports  
        if grep -qE "^[[:space:]]*-[[:space:]]*\"[0-9]+:" "$file" && ! grep -q "^[[:space:]]*ports:" "$file"; then
            sed -i '/^[[:space:]]*-[[:space:]]*"[0-9]/{i\    ports:
            }' "$file" 2>/dev/null || true
        fi
        
        # Assign unique port
        if grep -qE "^[[:space:]]*-[[:space:]]*\"[0-9]+:" "$file"; then
            sed -i "0,/^[[:space:]]*-[[:space:]]*\"[0-9]*:/{s/\"[0-9][0-9]*:/\"${current_port}:/}" "$file" 2>/dev/null || true
        fi
        
        # Add ports if missing completely
        if ! grep -q "ports:" "$file" && grep -q "container_name:" "$file"; then
            sed -i "/container_name:/a\\    ports:\\
      - \"${current_port}:80\"" "$file" 2>/dev/null || true
        fi
        
        # Add unionfs volume
        if grep -q "unionfs:" "$file" && ! grep -q "^volumes:" "$file"; then
            echo -e "\nvolumes:\n  unionfs:\n    driver: local" >> "$file"
        fi
        
        # Test validity
        if docker-compose -f "$file" config --quiet 2>/dev/null; then
            ((fixed++))
            status="✅"
        else
            ((failed++))
            status="❌"
        fi
        
        # Show progress every 10 apps
        if (( total % 10 == 0 )); then
            echo "Progress: $total/161 apps ($fixed fixed, $failed failed) - Latest: $app $status"
        fi
        
        ((current_port++))
    fi
done

echo
echo "🎉 Real-time Fix Complete!"
echo "========================="
echo "Total: $total apps"
echo "Fixed: $fixed apps"
echo "Failed: $failed apps"
echo "Success rate: $(( (fixed * 100) / total ))%"
echo "Port range: $PORT_START-$((current_port-1))"

# Quick test of 3 apps
echo
echo "🧪 Quick validation test..."
test_apps=("plex" "nextcloud" "jellyfin")
for app in "${test_apps[@]}"; do
    if [[ -f "$BULK_APPS_DIR/${app}.yml" ]]; then
        echo -n "$app: "
        if docker-compose -f "$BULK_APPS_DIR/${app}.yml" --env-file ../.config/.env config --quiet 2>/dev/null; then
            echo "✅"
        else
            echo "❌"
        fi
    fi
done

echo
echo "🚀 Ready to deploy $fixed+ applications!"
