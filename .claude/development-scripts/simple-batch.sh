#!/bin/bash

# Simple Batch - Process 10 apps at a time
echo "🔧 Simple Batch Fix - 10 apps at a time"
echo "======================================="

BULK_APPS_DIR="../local-mode-apps"
PORT_START=8200

# Get list of first 10 apps
apps=($(ls "$BULK_APPS_DIR"/*.yml | head -10 | xargs -n1 basename))

echo "Processing these 10 apps:"
for app in "${apps[@]}"; do
    echo "  - $app"
done

current_port=$PORT_START
fixed=0

echo
echo "Starting fixes..."

for app in "${apps[@]}"; do
    file="$BULK_APPS_DIR/$app"
    app_name=$(basename "$app" .yml)
    
    echo -n "🔧 $app_name (port $current_port)... "
    
    # Simple backup
    cp "$file" "${file}.bak" 2>/dev/null || true
    
    # Apply single fix at a time
    
    # 1. Fix malformed ports first
    if grep -q "ports:.*-.*:" "$file"; then
        sed -i 's/ports:[[:space:]]*-[[:space:]]*/ports:\n      - /' "$file"
    fi
    
    # 2. Add ports header if missing
    if grep -qE "^[[:space:]]*-[[:space:]]*\"[0-9]+" "$file" && ! grep -q "ports:" "$file"; then
        sed -i '/^[[:space:]]*-[[:space:]]*"[0-9]/{i\    ports:
        }' "$file"
    fi
    
    # 3. Replace port number
    if grep -qE "^[[:space:]]*-[[:space:]]*\"[0-9]+" "$file"; then
        sed -i "s/^[[:space:]]*-[[:space:]]*\"[0-9]*:/      - \"$current_port:/" "$file"
    fi
    
    # 4. Add ports if none exist
    if ! grep -q "ports:" "$file"; then
        sed -i "/container_name:/a\\    ports:\\
      - \"$current_port:80\"" "$file"
    fi
    
    # Quick test
    if docker-compose -f "$file" --env-file ../.config/.env config --quiet 2>/dev/null; then
        echo "✅"
        ((fixed++))
    else
        echo "❌"
    fi
    
    ((current_port++))
done

echo
echo "Batch 1 complete: $fixed/10 apps fixed"
echo "Next batch will start at port $current_port"
