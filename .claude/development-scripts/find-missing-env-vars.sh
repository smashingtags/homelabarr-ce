#!/bin/bash

# Script to find missing environment variables in YAML files
# and automatically add them to .env file

ENV_FILE=".env"
YAML_DIR="../local-mode-apps"

echo "🔍 Analyzing YAML files for missing environment variables..."
echo "=================================================="

# Arrays to store found variables
declare -A image_vars
declare -A theme_vars
declare -A other_vars

# Read current .env file to see what we already have
current_vars=$(grep -E "^[A-Z_]+=" "$ENV_FILE" 2>/dev/null | cut -d'=' -f1 || echo "")

echo "📋 Current variables in .env:"
echo "$current_vars"
echo ""

# Find all variables used in YAML files
echo "🔍 Scanning YAML files for variable references..."

for yaml_file in "$YAML_DIR"/*.yml; do
    if [[ -f "$yaml_file" ]]; then
        filename=$(basename "$yaml_file")
        
        # Find IMAGE variables
        image_var=$(grep -o '\${[A-Z_]*IMAGE[A-Z_]*}' "$yaml_file" 2>/dev/null | sed 's/[{}$]//g' | sort -u)
        if [[ -n "$image_var" ]]; then
            for var in $image_var; do
                image_vars["$var"]="$filename"
            done
        fi
        
        # Find THEME variables
        theme_var=$(grep -o '\${[A-Z_]*THEME[A-Z_]*}' "$yaml_file" 2>/dev/null | sed 's/[{}$]//g' | sort -u)
        if [[ -n "$theme_var" ]]; then
            for var in $theme_var; do
                theme_vars["$var"]="$filename"
            done
        fi
        
        # Find other variables (excluding common ones we know about)
        other_var=$(grep -o '\${[A-Z_][A-Z0-9_]*}' "$yaml_file" 2>/dev/null | sed 's/[{}$]//g' | sort -u | grep -vE '^(ID|TZ|UMASK|RESTARTAPP|SECURITYOPS|SECURITYOPSSET|APPFOLDER|PORTBLOCK)$' | grep -vE 'IMAGE$|THEME$')
        if [[ -n "$other_var" ]]; then
            for var in $other_var; do
                if [[ ! "$current_vars" =~ $var ]]; then
                    other_vars["$var"]="$filename"
                fi
            done
        fi
    fi
done

echo ""
echo "📊 Missing Variables Found:"
echo "=========================="

# Create backup of current .env
cp "$ENV_FILE" "$ENV_FILE.backup.$(date +%Y%m%d_%H%M%S)"
echo "✅ Backup created: $ENV_FILE.backup.$(date +%Y%m%d_%H%M%S)"

missing_count=0

# Check IMAGE variables
echo ""
echo "🖼️  Missing IMAGE Variables:"
for var in "${!image_vars[@]}"; do
    if [[ ! "$current_vars" =~ $var ]]; then
        echo "   $var (used in: ${image_vars[$var]})"
        
        # Auto-generate image name based on variable name
        app_name=$(echo "$var" | sed 's/IMAGE$//' | tr '[:upper:]' '[:lower:]')
        echo "MISSING: $var=lscr.io/linuxserver/$app_name:latest" >> /tmp/missing_vars.txt
        missing_count=$((missing_count + 1))
    fi
done

# Check THEME variables
echo ""
echo "🎨 Missing THEME Variables:"
for var in "${!theme_vars[@]}"; do
    if [[ ! "$current_vars" =~ $var ]]; then
        echo "   $var (used in: ${theme_vars[$var]})"
        echo "MISSING: $var=dark" >> /tmp/missing_vars.txt
        missing_count=$((missing_count + 1))
    fi
done

# Check other variables
echo ""
echo "🔧 Other Missing Variables:"
for var in "${!other_vars[@]}"; do
    if [[ ! "$current_vars" =~ $var ]]; then
        echo "   $var (used in: ${other_vars[$var]})"
        
        # Try to guess appropriate values for common patterns
        if [[ "$var" =~ PASSWORD|SECRET ]]; then
            echo "MISSING: $var=dockserver123" >> /tmp/missing_vars.txt
        elif [[ "$var" =~ PORT ]]; then
            echo "MISSING: $var=8080" >> /tmp/missing_vars.txt
        elif [[ "$var" =~ VERSION ]]; then
            echo "MISSING: $var=latest" >> /tmp/missing_vars.txt
        else
            echo "MISSING: $var=" >> /tmp/missing_vars.txt
        fi
        missing_count=$((missing_count + 1))
    fi
done

echo ""
echo "📈 Summary: Found $missing_count missing variables"

if [[ $missing_count -gt 0 ]]; then
    echo ""
    echo "🛠️  Would you like to automatically add these to .env? (y/n)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        echo "" >> "$ENV_FILE"
        echo "# Auto-generated missing variables - $(date)" >> "$ENV_FILE"
        
        # Add IMAGE variables
        if [[ -n "$(grep "IMAGE=" /tmp/missing_vars.txt)" ]]; then
            echo "" >> "$ENV_FILE"
            echo "# Missing Container Images" >> "$ENV_FILE"
            grep "IMAGE=" /tmp/missing_vars.txt | sed 's/MISSING: //' >> "$ENV_FILE"
        fi
        
        # Add THEME variables
        if [[ -n "$(grep "THEME=" /tmp/missing_vars.txt)" ]]; then
            echo "" >> "$ENV_FILE"
            echo "# Missing Theme Configuration" >> "$ENV_FILE"
            grep "THEME=" /tmp/missing_vars.txt | sed 's/MISSING: //' >> "$ENV_FILE"
        fi
        
        # Add other variables
        if [[ -n "$(grep -v "IMAGE=\|THEME=" /tmp/missing_vars.txt)" ]]; then
            echo "" >> "$ENV_FILE"
            echo "# Other Missing Variables" >> "$ENV_FILE"
            grep -v "IMAGE=\|THEME=" /tmp/missing_vars.txt | sed 's/MISSING: //' >> "$ENV_FILE"
        fi
        
        echo "✅ Added $missing_count variables to $ENV_FILE"
        echo "📝 Please review and adjust values as needed"
    fi
fi

# Clean up
rm -f /tmp/missing_vars.txt

echo ""
echo "🎉 Analysis complete!"
