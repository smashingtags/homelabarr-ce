#!/bin/bash

# Manual Fix - Small Batch Approach
set -e

echo "🔧 Manual Fix - Processing 10 apps at a time"
echo "==========================================="

BULK_APPS_DIR="../local-mode-apps"
PORT_START=8200
current_port=$PORT_START

# Test with first 10 apps that we know exist
apps=("alltube" "amd" "aria" "autoscan" "bazarr" "bitwarden" "calibre-web" "changedetection" "chrome" "cloud9")

echo "📦 Processing 10 test applications..."

for app in "${apps[@]}"; do
    file="$BULK_APPS_DIR/${app}.yml"
    if [[ -f "$file" ]]; then
        echo -n "🔧 $app (port $current_port)... "
        
        # Create backup
        cp "$file" "${file}.backup"
        
        # Quick manual fixes based on patterns we identified
        
        # 1. Fix malformed "ports:      - "port:port""
        if grep -q "ports:.*-.*:" "$file"; then
            sed -i 's/ports:[[:space:]]*-[[:space:]]*/ports:\n      - /' "$file"
        fi
        
        # 2. Fix orphaned port lines
        if grep -qE "^[[:space:]]*-[[:space:]]*\"[0-9]+:[0-9]+" "$file" && ! grep -q "^[[:space:]]*ports:" "$file"; then
            # Add ports header before first orphaned port line
            sed -i '/^[[:space:]]*-[[:space:]]*"[0-9]/{i\    ports:
            }' "$file"
        fi
        
        # 3. Change first port number to our assigned port
        if grep -qE "^[[:space:]]*-[[:space:]]*\"[0-9]+:" "$file"; then
            sed -i "0,/^[[:space:]]*-[[:space:]]*\"[0-9]*:/{s/[0-9][0-9]*:/${current_port}:/}" "$file"
        fi
        
        # 4. Add unionfs volume if missing
        if grep -q "unionfs:" "$file" && ! grep -A 10 "^volumes:" "$file" | grep -q "unionfs:" 2>/dev/null; then
            if ! grep -q "^volumes:" "$file"; then
                echo -e "\nvolumes:\n  unionfs:\n    driver: local" >> "$file"
            else
                sed -i '/^volumes:/a\  unionfs:\n    driver: local' "$file"
            fi
        fi
        
        # 5. Fix local-persist driver
        if grep -q "driver: local-persist" "$file"; then
            sed -i '/driver: local-persist/,+2d' "$file"
            sed -i '/unionfs:/a\    driver: local' "$file"
        fi
        
        # Test the result
        if docker-compose -f "$file" config --quiet 2>/dev/null; then
            echo "✅ (Port $current_port assigned)"
        else
            echo "❌ (YAML invalid, restored backup)"
            cp "${file}.backup" "$file"
        fi
        
        ((current_port++))
    else
        echo "❓ $app - file not found"
    fi
done

echo
echo "✅ Manual batch fix complete!"
echo "🧪 Testing 3 random apps..."

# Test 3 apps
for app in "alltube" "aria" "bazarr"; do
    if [[ -f "$BULK_APPS_DIR/${app}.yml" ]]; then
        echo -n "Testing $app... "
        if docker-compose -f "$BULK_APPS_DIR/${app}.yml" --env-file ../.config/.env config --quiet 2>/dev/null; then
            echo "✅"
        else
            echo "❌"
        fi
    fi
done
