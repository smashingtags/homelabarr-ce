#!/bin/bash

# Quick Port Scanner for homelabarr-cli Apps

echo "Scanning for port conflicts in bulk converted apps..."

BULK_APPS_DIR="../local-mode-apps"
declare -A ports
declare -a conflicts

echo "App Name | Port | Status"
echo "---------|------|-------"

for file in "$BULK_APPS_DIR"/*.yml; do
    if [[ -f "$file" ]]; then
        app=$(basename "$file" .yml)
        
        # Look for port mappings like "8080:80" or - "8080:80"
        file_ports=$(grep -E "^[[:space:]]*-?[[:space:]]*[\"']?[0-9]+:[0-9]" "$file" 2>/dev/null | \
                    sed 's/^[[:space:]]*-[[:space:]]*//' | \
                    sed 's/[\"'"'"']//g' | \
                    cut -d':' -f1 | \
                    sort -n | uniq || echo "none")
        
        if [[ "$file_ports" == "none" || -z "$file_ports" ]]; then
            echo "$app | none | NO_PORTS"
        else
            for port in $file_ports; do
                if [[ -n "${ports[$port]}" ]]; then
                    echo "$app | $port | CONFLICT with ${ports[$port]}"
                    conflicts+=("Port $port: ${ports[$port]} vs $app")
                else
                    echo "$app | $port | OK"
                    ports[$port]="$app"
                fi
            done
        fi
    fi
done | head -50  # Show first 50 to avoid overwhelming output

echo
echo "CONFLICTS DETECTED:"
for conflict in "${conflicts[@]}"; do
    echo "⚠️  $conflict"
done

echo
echo "TOTAL APPS: $(ls -1 "$BULK_APPS_DIR"/*.yml 2>/dev/null | wc -l)"
echo "CONFLICTS: ${#conflicts[@]}"
echo "UNIQUE PORTS: ${#ports[@]}"
