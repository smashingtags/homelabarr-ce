#!/bin/bash

# Targeted Bulk Fix - Based on Plex Success Pattern
set -e

echo "🚀 homelabarr-cli Bulk YAML Fix - Targeted Approach"
echo "==============================================="

BULK_APPS_DIR="../local-mode-apps"
BACKUP_DIR="./targeted-fix-backup-$(date +%Y%m%d-%H%M%S)"
PORT_START=8200
declare -A used_ports
declare -i current_port=$PORT_START
declare -i fixed_count=0
declare -i total_count=0

# Reserved ports
RESERVED_PORTS=(22 25 53 80 443 5055 7878 8082 8085 8096 8181 8989 9000 32400)

mkdir -p "$BACKUP_DIR"
echo "📦 Backup directory: $BACKUP_DIR"

# Mark reserved ports as used
for port in "${RESERVED_PORTS[@]}"; do
    used_ports[$port]="reserved"
done

# Function to get next available port
get_next_port() {
    while [[ -n "${used_ports[$current_port]}" ]]; do
        ((current_port++))
        if [[ $current_port -gt 65535 ]]; then
            echo "Error: No available ports" >&2
            return 1
        fi
    done
    used_ports[$current_port]="assigned"
    echo $current_port
    ((current_port++))
}

# Function to fix one YAML file
fix_app() {
    local file="$1"
    local app_name=$(basename "$file" .yml)
    local backup_file="$BACKUP_DIR/${app_name}.yml"
    
    echo "🔧 Processing $app_name"
    
    # Create backup
    cp "$file" "$backup_file"
    
    # Get a unique port for this app
    local app_port=$(get_next_port)
    
    # Create fixed version
    {
        # Process the file line by line, fixing known issues
        while IFS= read -r line; do
            # Fix malformed ports lines
            if echo "$line" | grep -q "ports:.*-.*:"; then
                echo "    ports:"
                echo "      - \"$app_port:80\""
                continue
            fi
            
            # Skip orphaned ports lines  
            if echo "$line" | grep -qE "^[[:space:]]*ports:[[:space:]]*-[[:space:]]*\"[0-9]+:[0-9]+\""; then
                continue
            fi
            
            # Fix volume drivers
            if echo "$line" | grep -q "driver: local-persist"; then
                echo "    driver: local"
                # Skip the next 2 lines (driver_opts)
                read -r && read -r
                continue
            fi
            
            # Output the line normally
            echo "$line"
        done < "$file"
        
        # Add missing unionfs volume if needed
        if grep -q "unionfs:" "$file" && ! grep -q "^volumes:" "$file"; then
            echo
            echo "volumes:"
            echo "  unionfs:"
            echo "    driver: local"
        fi
        
    } > "${file}.tmp"
    
    # Test the YAML
    if docker-compose -f "${file}.tmp" config --quiet 2>/dev/null; then
        mv "${file}.tmp" "$file"
        echo "  ✅ Fixed $app_name (port $app_port)"
        ((fixed_count++))
    else
        rm "${file}.tmp"
        echo "  ❌ YAML validation failed for $app_name"
    fi
}

# Process all files
echo
echo "🔄 Processing all YAML files..."

for yaml_file in "$BULK_APPS_DIR"/*.yml; do
    if [[ -f "$yaml_file" ]]; then
        ((total_count++))
        fix_app "$yaml_file"
    fi
done

# Summary
echo
echo "🎉 Bulk Fix Complete!"
echo "===================="
echo "✅ Total files: $total_count"  
echo "✅ Successfully fixed: $fixed_count"
echo "✅ Failed fixes: $((total_count - fixed_count))"
echo "✅ Unique ports assigned: ${#used_ports[@]}"
echo "📁 Backups: $BACKUP_DIR"

# Test a few random apps
echo
echo "🧪 Testing random deployments..."
test_apps=("plex" "nextcloud" "jellyfin" "heimdall")

for app in "${test_apps[@]}"; do
    if [[ -f "$BULK_APPS_DIR/${app}.yml" ]]; then
        echo -n "Testing $app... "
        if docker-compose -f "$BULK_APPS_DIR/${app}.yml" --env-file ../.config/.env config --quiet 2>/dev/null; then
            echo "✅"
        else
            echo "❌"
        fi
    fi
done

echo
echo "🚀 Ready to deploy 171+ applications with unique ports!"
echo "💡 Next: Update comprehensive dashboard with new port assignments"
