#!/bin/bash

cd ../local-mode-apps
backup_dir="quick-dup-fix-$(date +%H%M%S)"
mkdir -p "$backup_dir"

echo "Fixing duplicate unionfs volumes..."
fixed=0

for file in *.yml; do
    if grep -c "^  unionfs:" "$file" 2>/dev/null | grep -q "[2-9]"; then
        echo "Fixing: $file"
        cp "$file" "$backup_dir/"
        
        # Remove duplicate unionfs sections - keep only first occurrence
        sed -i '/^  unionfs:/,/^$/!b; /^  unionfs:/{:a; N; /\n$/!ba; s/\n  unionfs:.*\n$/\n/}' "$file"
        
        ((fixed++))
    fi
done

echo "Fixed $fixed files with duplicate volumes"
