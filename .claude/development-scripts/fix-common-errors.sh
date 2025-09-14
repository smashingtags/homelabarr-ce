#!/bin/bash

# Fix common YAML errors in converted files
echo "=== Fixing Common YAML Errors ==="

OUTPUT_DIR="../local-mode-apps"

fix_file() {
    local file="$1"
    local service_name=$(basename "$file" .yml)
    
    echo "Fixing $service_name..."
    
    # Create backup
    cp "$file" "$file.backup"
    
    # Fix 1: Remove duplicate networks section
    # Remove lines between networks: and the end of the proxy network definition
    sed -i '/networks:/,$d' "$file"
    
    # Add clean networks section at the end
    cat >> "$file" << 'NETWORK_EOF'
networks:
  homelabarr-cli-local:
    driver: bridge
NETWORK_EOF

    # Fix 2: Remove duplicate/malformed ports
    # Remove any standalone "ports:" lines without proper indentation
    sed -i '/^[[:space:]]*ports:[[:space:]]*$/d' "$file"
    
    # Fix 3: Remove any remaining traefik references
    sed -i '/traefik/d' "$file"
    
    echo "✓ Fixed $service_name"
}

# Fix all files that had errors
if [[ -d "error-reports" ]]; then
    for error_file in error-reports/*.error; do
        if [[ -f "$error_file" ]]; then
            service_name=$(basename "$error_file" .error)
            yaml_file="$OUTPUT_DIR/${service_name}.yml"
            if [[ -f "$yaml_file" ]]; then
                fix_file "$yaml_file"
            fi
        fi
    done
else
    echo "No error reports found. Run error-check-all.sh first."
fi

echo
echo "Re-running error check..."
./error-check-all.sh
