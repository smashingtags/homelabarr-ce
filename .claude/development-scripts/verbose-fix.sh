#!/bin/bash

# Verbose Fix - Debug version with detailed output
set -x  # Show commands being executed
set -e  # Exit on error

echo "🔍 VERBOSE YAML Fix - Debug Mode"
echo "================================"

BULK_APPS_DIR="../local-mode-apps"
PORT_START=8200
current_port=$PORT_START

echo "Working directory: $(pwd)"
echo "Bulk apps directory: $BULK_APPS_DIR"
echo "Checking if directory exists..."

if [[ ! -d "$BULK_APPS_DIR" ]]; then
    echo "❌ ERROR: Directory $BULK_APPS_DIR does not exist!"
    echo "Current directory contents:"
    ls -la
    exit 1
fi

echo "✅ Directory exists"
echo "Listing first 5 files in $BULK_APPS_DIR:"
ls "$BULK_APPS_DIR" | head -5

echo "Processing just 3 test files to debug..."

# Test with just 3 specific files
test_files=("alltube.yml" "aria.yml" "plex.yml")

for test_file in "${test_files[@]}"; do
    file="$BULK_APPS_DIR/$test_file"
    echo "Processing: $file"
    
    if [[ -f "$file" ]]; then
        echo "✅ File exists: $file"
        
        app=$(basename "$file" .yml)
        echo "App name: $app"
        echo "Current port: $current_port"
        
        # Show file size
        echo "File size: $(wc -l < "$file") lines"
        
        # Show first few lines
        echo "First 5 lines of file:"
        head -5 "$file"
        
        echo "Creating backup..."
        cp "$file" "${file}.verbose-backup" || {
            echo "❌ Failed to create backup"
            continue
        }
        
        echo "Applying fixes..."
        
        # Test docker-compose before fixes
        echo "Testing YAML before fixes..."
        if docker-compose -f "$file" config --quiet 2>/dev/null; then
            echo "✅ Original YAML is valid"
        else
            echo "❌ Original YAML has issues"
        fi
        
        # Apply one fix at a time with verbose output
        echo "Fix 1: Malformed ports..."
        if grep -q "ports:.*-.*:" "$file"; then
            echo "Found malformed ports, fixing..."
            sed -i 's/ports:[[:space:]]*-[[:space:]]*/ports:\n      - /' "$file" && echo "✅ Fixed malformed ports"
        else
            echo "No malformed ports found"
        fi
        
        echo "Fix 2: Orphaned port lines..."
        if grep -qE "^[[:space:]]*-[[:space:]]*\"[0-9]+:" "$file" && ! grep -q "^[[:space:]]*ports:" "$file"; then
            echo "Found orphaned ports, adding header..."
            sed -i '/^[[:space:]]*-[[:space:]]*"[0-9]/{i\    ports:
            }' "$file" && echo "✅ Added ports header"
        else
            echo "No orphaned ports found"
        fi
        
        echo "Fix 3: Port assignment..."
        if grep -qE "^[[:space:]]*-[[:space:]]*\"[0-9]+:" "$file"; then
            echo "Assigning port $current_port..."
            sed -i "0,/^[[:space:]]*-[[:space:]]*\"[0-9]*:/{s/\"[0-9][0-9]*:/\"${current_port}:/}" "$file" && echo "✅ Port assigned"
        else
            echo "No ports to reassign"
        fi
        
        echo "Testing YAML after fixes..."
        if docker-compose -f "$file" config --quiet 2>/dev/null; then
            echo "✅ $app fixed successfully (port $current_port)"
        else
            echo "❌ $app still has YAML issues"
            echo "Docker-compose error output:"
            docker-compose -f "$file" config 2>&1 || true
        fi
        
        ((current_port++))
        echo "Next port will be: $current_port"
        echo "----------------------------------------"
        
    else
        echo "❌ File not found: $file"
    fi
done

echo "🎉 Verbose fix test complete!"
