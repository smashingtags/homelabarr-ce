#!/bin/bash

# Error check all converted YAML files
echo "=== Checking All Converted YAML Files ==="

OUTPUT_DIR="../local-mode-apps"
ERRORS_DIR="./error-reports"
mkdir -p "$ERRORS_DIR"

total=0
valid=0
errors=0

echo "Checking $OUTPUT_DIR for YAML validity..."
echo

# Check each YAML file
for yaml_file in "$OUTPUT_DIR"/*.yml; do
    if [[ ! -f "$yaml_file" ]]; then
        continue
    fi
    
    ((total++))
    filename=$(basename "$yaml_file")
    service_name="${filename%.yml}"
    
    # Test YAML syntax
    if docker compose -f "$yaml_file" config >/dev/null 2>"$ERRORS_DIR/${service_name}.error"; then
        echo "✓ $service_name"
        ((valid++))
        rm -f "$ERRORS_DIR/${service_name}.error"
    else
        echo "✗ $service_name - ERROR"
        ((errors++))
        echo "  Error details in: $ERRORS_DIR/${service_name}.error"
    fi
done

echo
echo "=== YAML Validation Summary ==="
echo "Total files: $total"
echo "Valid YAML: $valid"
echo "Errors: $errors"

if [[ $errors -gt 0 ]]; then
    echo
    echo "Files with errors:"
    ls "$ERRORS_DIR"/*.error 2>/dev/null | while read error_file; do
        service=$(basename "$error_file" .error)
        echo "- $service"
        echo "  First error line:"
        head -1 "$error_file" | sed 's/^/    /'
    done
    echo
    echo "Run './fix-common-errors.sh' to attempt automatic fixes"
else
    echo "🎉 ALL YAML FILES ARE VALID!"
    rm -rf "$ERRORS_DIR"
fi
