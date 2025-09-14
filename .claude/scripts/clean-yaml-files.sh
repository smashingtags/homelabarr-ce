#!/bin/bash

# YAML Cleanup Script - Remove metadata junk and standardize format
# Makes all YAML files tidy and uniform

echo "🧹 Cleaning up YAML installer files..."

# Counter for processed files
processed=0

# Find all YAML files in the repository
while IFS= read -r -d '' file; do
    echo "Processing: $file"
    
    # Create a temporary file
    temp_file=$(mktemp)
    
    # Check if file has content before processing
    if [[ ! -s "$file" ]]; then
        echo "  ⚠️  Skipping empty file"
        rm "$temp_file"
        continue
    fi
    
    # Read the file and process it
    {
        found_yaml_start=false
        found_services_or_version=false
        
        while IFS= read -r line; do
            # Skip shebang lines
            if [[ "$line" =~ ^#!/ ]]; then
                continue
            fi
            
            # Skip comment headers (lines starting with # but not YAML comments within content)
            if [[ "$line" =~ ^#.*$ ]] && [[ "$found_yaml_start" == false ]] && [[ "$found_services_or_version" == false ]]; then
                continue
            fi
            
            # Skip author/title metadata lines
            if [[ "$line" =~ ^[[:space:]]*$ ]] && [[ "$found_yaml_start" == false ]] && [[ "$found_services_or_version" == false ]]; then
                continue
            fi
            
            # If we find --- at the start, this is proper YAML format
            if [[ "$line" == "---" ]]; then
                found_yaml_start=true
                echo "---"
                continue
            fi
            
            # If we find services: or version: at the start, we need to add ---
            if [[ "$line" =~ ^(services|version):[[:space:]]* ]] && [[ "$found_yaml_start" == false ]]; then
                found_services_or_version=true
                echo "---"
                echo "$line"
                continue
            fi
            
            # Once we've found the start of actual YAML content, print everything
            if [[ "$found_yaml_start" == true ]] || [[ "$found_services_or_version" == true ]]; then
                echo "$line"
            fi
            
        done < "$file"
    } > "$temp_file"
    
    # Only replace the file if we actually processed content
    if [[ -s "$temp_file" ]]; then
        mv "$temp_file" "$file"
        echo "  ✅ Cleaned"
        ((processed++))
    else
        echo "  ⚠️  No content to process"
        rm "$temp_file"
    fi
    
done < <(find . -name "*.yml" -type f -print0 | grep -zv "\.git")

echo ""
echo "🎉 YAML cleanup complete!"
echo "📊 Processed $processed files"
echo "🧹 All YAML files are now tidy and uniform"
