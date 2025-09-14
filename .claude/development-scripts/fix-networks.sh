#!/bin/bash

# Better fix for network duplication issues
echo "=== Advanced YAML Network Fix ==="

OUTPUT_DIR="../local-mode-apps"

fix_yaml_file() {
    local file="$1"
    local service_name=$(basename "$file" .yml)
    
    echo "Fixing $service_name..."
    
    # Create temp file
    temp_file="/tmp/${service_name}_temp.yml"
    
    # Process the file to remove everything after the last service definition
    # and add clean networks section
    awk '
    /^networks:/ { exit }  # Stop at networks section
    { print }              # Print everything else
    END {
        print ""
        print "networks:"
        print "  homelabarr-cli-local:"
        print "    driver: bridge"
    }
    ' "$file" > "$temp_file"
    
    # Replace original with fixed version
    mv "$temp_file" "$file"
    
    echo "✓ Fixed $service_name"
}

# Fix all YAML files
for yaml_file in "$OUTPUT_DIR"/*.yml; do
    if [[ -f "$yaml_file" ]]; then
        fix_yaml_file "$yaml_file"
    fi
done

echo "✓ Network fixes complete"
echo "Re-checking errors..."
./error-check-all.sh | tail -5
