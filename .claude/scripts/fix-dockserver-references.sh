#!/bin/bash

# Comprehensive script to update homelabarr-cli references to HomelabARR CLI
# Usage: ./fix-HomelabarrCli-references.sh [--dry-run]

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Check for dry-run flag
DRY_RUN=false
if [[ "$1" == "--dry-run" ]]; then
    DRY_RUN=true
    echo -e "${YELLOW}🧪 DRY RUN MODE - No files will be modified${NC}"
fi

echo -e "${BLUE}🔄 HomelabARR CLI Reference Update Script${NC}"
echo "=============================================="

# Function to backup original file
backup_file() {
    local file="$1"
    if [[ "$DRY_RUN" == "false" ]]; then
        cp "$file" "$file.backup.$(date +%Y%m%d_%H%M%S)"
    fi
}

# Function to update file with pattern replacement
update_file() {
    local file="$1"
    local old_pattern="$2"
    local new_pattern="$3"
    local description="$4"
    
    if grep -q "$old_pattern" "$file" 2>/dev/null; then
        echo -e "${CYAN}📝 Updating: ${file}${NC}"
        echo -e "   ${YELLOW}→ ${description}${NC}"
        
        if [[ "$DRY_RUN" == "false" ]]; then
            backup_file "$file"
            sed -i "s|$old_pattern|$new_pattern|g" "$file"
        else
            echo -e "   ${BLUE}[DRY RUN] Would replace: $old_pattern → $new_pattern${NC}"
        fi
        return 0
    fi
    return 1
}

# Counter for tracking changes
total_files=0
total_changes=0

echo -e "\n${GREEN}📋 Processing Reference Updates...${NC}"

# Find all .md files and process them
while IFS= read -r -d '' file; do
    file_changed=false
    
    # Skip backup files
    [[ "$file" == *.backup.* ]] && continue
    
    # 1. Image references - homelabarr-cli branding in images
    if update_file "$file" "Image of HomelabarrCli" "Image of HomelabARR CLI" "Update image alt text"; then
        file_changed=true
        ((total_changes++))
    fi
    
    # 2. Docker image references - docker-homelabarr-cli.png
    if update_file "$file" "docker-HomelabarrCli\.png" "docker-homelabarr-cli.png" "Update Docker image filename"; then
        file_changed=true
        ((total_changes++))
    fi
    
    # 3. Text references - homelabarr-cli project name
    if update_file "$file" "HomelabarrCli" "HomelabARR CLI" "Update project name"; then
        file_changed=true
        ((total_changes++))
    fi
    
    # 4. Lowercase references
    if update_file "$file" " HomelabarrCli" " homelabarr-cli" "Update lowercase references"; then
        file_changed=true
        ((total_changes++))
    fi
    
    # 5. GitHub repository references
    if update_file "$file" "github\.com/HomelabarrCli" "github.com/smashingtags/homelabarr-cli" "Update GitHub URLs"; then
        file_changed=true
        ((total_changes++))
    fi
    
    # 6. Docker Hub references
    if update_file "$file" "ghcr\.io/HomelabarrCli" "ghcr.io/smashingtags/homelabarr-cli" "Update Docker Hub URLs"; then
        file_changed=true
        ((total_changes++))
    fi
    
    # 7. Directory references
    if update_file "$file" "/HomelabarrCli/" "/homelabarr-cli/" "Update directory paths"; then
        file_changed=true
        ((total_changes++))
    fi
    
    # 8. Command references
    if update_file "$file" "cd HomelabarrCli" "cd homelabarr-cli" "Update command paths"; then
        file_changed=true
        ((total_changes++))
    fi
    
    # 9. Network references
    if update_file "$file" "homelabarr-cli-local" "homelabarr-local" "Update network names"; then
        file_changed=true
        ((total_changes++))
    fi
    
    # 10. Installation path references
    if update_file "$file" "/opt/homelabarr-cli" "/opt/homelabarr" "Update installation paths"; then
        file_changed=true
        ((total_changes++))
    fi
    
    # 11. Remove 'rm -rf HomelabarrCli' references (dangerous commands)
    if update_file "$file" "rm -rf.*HomelabarrCli" "rm -rf homelabarr-cli" "Update cleanup commands"; then
        file_changed=true
        ((total_changes++))
    fi
    
    # 12. Clone command references
    if update_file "$file" "clone.*HomelabarrCli/HomelabarrCli" "clone https://github.com/smashingtags/homelabarr-cli.git" "Update git clone commands"; then
        file_changed=true
        ((total_changes++))
    fi
    
    if [[ "$file_changed" == "true" ]]; then
        ((total_files++))
    fi
    
done < <(find . -name "*.md" -type f -print0)

# Special handling for specific file patterns
echo -e "\n${GREEN}🎯 Processing Special Cases...${NC}"

# Fix apps/.config files specifically
for config_file in ./apps/.config/*.md; do
    if [[ -f "$config_file" ]]; then
        if update_file "$config_file" "homelabarr-cli Local Mode" "HomelabARR CLI Local Mode" "Update local mode branding"; then
            ((total_changes++))
        fi
    fi
done

# Fix wiki documentation specifically
for wiki_file in ./wiki/docs/**/*.md; do
    if [[ -f "$wiki_file" ]]; then
        # Update support references
        if update_file "$wiki_file" "Support by HomelabarrCli" "Support by HomelabARR CLI" "Update support references"; then
            ((total_changes++))
        fi
        
        # Update installation references
        if update_file "$wiki_file" "Install via HomelabarrCli" "Install via HomelabARR CLI" "Update installation instructions"; then
            ((total_changes++))
        fi
    fi
done

# Summary
echo ""
echo "=============================================="
if [[ "$total_changes" -eq 0 ]]; then
    echo -e "${GREEN}🎉 No homelabarr-cli references found to update!${NC}"
elif [[ "$DRY_RUN" == "true" ]]; then
    echo -e "${YELLOW}📊 DRY RUN SUMMARY:${NC}"
    echo -e "${YELLOW}   - Would update ${total_files} files${NC}"
    echo -e "${YELLOW}   - Would make ${total_changes} total changes${NC}"
    echo -e "${CYAN}💡 Run without --dry-run to apply changes${NC}"
else
    echo -e "${GREEN}📊 UPDATE COMPLETE:${NC}"
    echo -e "${GREEN}   - Updated ${total_files} files${NC}"
    echo -e "${GREEN}   - Made ${total_changes} total changes${NC}"
    echo -e "${BLUE}💾 Backup files created with .backup.timestamp extension${NC}"
fi

echo ""
echo -e "${BLUE}🔍 Update complete!${NC}"

# Create verification script
if [[ "$DRY_RUN" == "false" && "$total_changes" -gt 0 ]]; then
    echo ""
    echo -e "${BLUE}📝 Creating verification script...${NC}"
    
    cat > verify-updates.sh << 'EOF'
#!/bin/bash
echo "🔍 Verification: Scanning for remaining homelabarr-cli references..."
find . -name "*.md" -type f -exec grep -l -i "HomelabarrCli\|dock-server" {} \; | grep -v ".backup." | head -10
echo ""
echo "If no files are listed above, all references have been successfully updated!"
EOF
    
    chmod +x verify-updates.sh
    echo -e "${GREEN}✅ Created verify-updates.sh script${NC}"
fi
