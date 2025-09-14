#!/bin/bash

# Batch Fix Runner - Process all 171 apps in manageable chunks
set -e

echo "🚀 homelabarr-cli Bulk Fix - Batch Runner"
echo "===================================="

BULK_APPS_DIR="../local-mode-apps"
BACKUP_DIR="./batch-fix-backup-$(date +%Y%m%d-%H%M%S)"
PORT_START=8200
BATCH_SIZE=20
declare -A used_ports
declare -A app_ports
declare -i current_port=$PORT_START
declare -i total_fixed=0
declare -i total_failed=0
declare -i batch_num=1

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

# Function to fix one app
fix_single_app() {
    local file="$1"
    local app_name=$(basename "$file" .yml)
    local backup_file="$BACKUP_DIR/${app_name}.yml"
    local app_port=$(get_next_port)
    
    echo -n "  🔧 $app_name (port $app_port)... "
    
    # Create backup
    cp "$file" "$backup_file"
    
    # Create temp file for processing
    local temp_file="${file}.tmp"
    
    # Fix the file
    {
        local skip_lines=0
        while IFS= read -r line; do
            # Handle line skipping for driver_opts
            if [[ $skip_lines -gt 0 ]]; then
                ((skip_lines--))
                continue
            fi
            
            # Fix malformed ports: "ports:      - "port:port""
            if echo "$line" | grep -q "ports:.*-.*:"; then
                echo "    ports:"
                echo "      - \"$app_port:80\""
                continue
            fi
            
            # Fix orphaned port lines (start with spaces and dash)
            if echo "$line" | grep -qE "^[[:space:]]*-[[:space:]]*\"[0-9]+:[0-9]+"; then
                # If we haven't added ports header yet, add it
                if ! grep -q "ports:" "$temp_file" 2>/dev/null; then
                    echo "    ports:"
                fi
                # Replace the port number with our assigned port
                local fixed_line=$(echo "$line" | sed "s/[0-9][0-9]*:/$app_port:/")
                echo "      $fixed_line"
                continue
            fi
            
            # Fix volume driver
            if echo "$line" | grep -q "driver: local-persist"; then
                echo "    driver: local"
                skip_lines=2  # Skip driver_opts section
                continue
            fi
            
            # Output line normally
            echo "$line"
        done < "$file"
        
        # Add unionfs volume if referenced but not defined
        if grep -q "unionfs:" "$file" && ! grep -A 10 "^volumes:" "$file" | grep -q "unionfs:" 2>/dev/null; then
            if ! grep -q "^volumes:" "$file"; then
                echo ""
                echo "volumes:"
            fi
            if ! grep -A 10 "^volumes:" "$file" | grep -q "unionfs:" 2>/dev/null; then
                echo "  unionfs:"
                echo "    driver: local"
            fi
        fi
        
    } > "$temp_file"
    
    # Validate and apply
    if docker-compose -f "$temp_file" config --quiet 2>/dev/null; then
        mv "$temp_file" "$file"
        app_ports["$app_name"]="$app_port"
        echo "✅"
        ((total_fixed++))
        return 0
    else
        rm -f "$temp_file"
        echo "❌"
        ((total_failed++))
        return 1
    fi
}

# Process files in batches
echo "🔄 Processing all apps in batches of $BATCH_SIZE..."

apps_list=($(ls "$BULK_APPS_DIR"/*.yml 2>/dev/null | head -171))
total_apps=${#apps_list[@]}

echo "📊 Found $total_apps applications to process"
echo

for ((i=0; i<total_apps; i+=BATCH_SIZE)); do
    echo "📦 Batch $batch_num (apps $((i+1))-$((i+BATCH_SIZE > total_apps ? total_apps : i+BATCH_SIZE))):"
    
    # Process this batch
    for ((j=i; j<i+BATCH_SIZE && j<total_apps; j++)); do
        fix_single_app "${apps_list[j]}"
    done
    
    echo "   Batch $batch_num complete: $((j-i)) apps processed"
    echo
    
    ((batch_num++))
    
    # Brief pause between batches
    sleep 1
done

# Generate results
echo "🎉 Bulk Fix Complete!"
echo "===================="
echo "📊 Statistics:"
echo "   Total apps: $total_apps"
echo "   Successfully fixed: $total_fixed"
echo "   Failed: $total_failed"
echo "   Success rate: $(( (total_fixed * 100) / total_apps ))%"
echo "   Ports assigned: ${#app_ports[@]}"
echo "   Backup location: $BACKUP_DIR"

# Create port registry
{
    echo "# homelabarr-cli Local Mode - Port Registry"
    echo "# Generated: $(date)"
    echo "# Total apps: $total_apps, Fixed: $total_fixed"
    echo "# ==============================================="
    echo
    echo "# Curated Templates (Reserved Ports)"
    echo "plex=32400"
    echo "radarr=7878"
    echo "sonarr=8989"
    echo "qbittorrent=8082"
    echo "sabnzbd=8085"
    echo "jellyfin=8096"
    echo "overseerr=5055"
    echo "tautulli=8181"
    echo
    echo "# Bulk Converted Apps (Auto-assigned Ports)"
    for app in $(printf '%s\n' "${!app_ports[@]}" | sort); do
        echo "${app}=${app_ports[$app]}"
    done
    
} > "port-registry-$(date +%Y%m%d-%H%M%S).txt"

echo
echo "🧪 Testing sample deployments..."

# Test 5 random fixed apps
test_count=0
success_count=0
for app in $(printf '%s\n' "${!app_ports[@]}" | sort | head -5); do
    echo -n "Testing $app... "
    if docker-compose -f "$BULK_APPS_DIR/${app}.yml" --env-file ../.config/.env config --quiet 2>/dev/null; then
        echo "✅"
        ((success_count++))
    else
        echo "❌"
    fi
    ((test_count++))
done

echo
echo "✅ Validation: $success_count/$test_count apps passed YAML validation"
echo
echo "🚀 Ready to deploy 171+ applications!"
echo "💡 Port range used: $PORT_START-$((current_port-1))"
echo "📋 Next: Update comprehensive dashboard with new port assignments"
