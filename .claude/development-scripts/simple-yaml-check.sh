#!/bin/bash

cd ../local-mode-apps
valid=0
invalid=0

echo "Checking YAML syntax..."

for file in *.yml; do
    if docker-compose -f "$file" config --quiet 2>/dev/null; then
        echo "✓ $file"
        ((valid++))
    else
        echo "✗ $file"
        ((invalid++))
    fi
done

echo ""
echo "=== SUMMARY ==="
echo "Valid files: $valid"
echo "Invalid files: $invalid"
echo "Total files: $((valid + invalid))"

if [ $invalid -eq 0 ]; then
    echo "🎉 All YAML files are valid!"
else
    echo "⚠️  $invalid files have syntax errors"
fi
