#!/bin/bash

# Script to systematically update all Discord invite links
# Usage: ./fix-discord-links.sh [--dry-run]

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Correct Discord invite link
CORRECT_DISCORD="https://discord.gg/Pc7mXX786x"

# Check for dry-run flag
DRY_RUN=false
if [[ "$1" == "--dry-run" ]]; then
    DRY_RUN=true
    echo -e "${YELLOW}🧪 DRY RUN MODE - No files will be modified${NC}"
fi

echo -e "${BLUE}🔗 Discord Links Update Script${NC}"
echo "==========================================="
echo -e "Correct Discord link: ${GREEN}${CORRECT_DISCORD}${NC}"
echo ""

# Function to backup original file
backup_file() {
    local file="$1"
    if [[ "$DRY_RUN" == "false" ]]; then
        cp "$file" "$file.discord-backup.$(date +%Y%m%d_%H%M%S)"
    fi
}

# Function to update Discord links in file
update_discord_link() {
    local file="$1"
    local old_link="$2"
    local description="$3"
    
    if grep -q "$old_link" "$file" 2>/dev/null; then
        echo -e "${CYAN}📝 Updating: ${file}${NC}"
        echo -e "   ${YELLOW}→ ${description}${NC}"
        echo -e "   ${RED}Old: ${old_link}${NC}"
        echo -e "   ${GREEN}New: ${CORRECT_DISCORD}${NC}"
        
        if [[ "$DRY_RUN" == "false" ]]; then
            backup_file "$file"
            sed -i "s|$old_link|$CORRECT_DISCORD|g" "$file"
        else
            echo -e "   ${BLUE}[DRY RUN] Would replace Discord link${NC}"
        fi
        echo ""
        return 0
    fi
    return 1
}

# Counter for tracking changes
total_files=0
total_changes=0

echo -e "${GREEN}📋 Processing Discord Link Updates...${NC}"
echo ""

# List of old Discord links to replace
OLD_DISCORD_LINKS=(
    "https://discord.gg/Pc7mXX786x"
    "https://discord.gg/Pc7mXX786x"
    "https://discord.gg/Pc7mXX786x"
    "https://discord.gg/Pc7mXX786x"
    "https://discord.gg/Pc7mXX786x"
)

# Find all .md files and process them
while IFS= read -r -d '' file; do
    file_changed=false
    
    # Skip backup files
    [[ "$file" == *.discord-backup.* ]] && continue
    [[ "$file" == *.backup.* ]] && continue
    
    # Check each old Discord link
    for old_link in "${OLD_DISCORD_LINKS[@]}"; do
        if update_discord_link "$file" "$old_link" "Update Discord invite link"; then
            file_changed=true
            ((total_changes++))
        fi
    done
    
    if [[ "$file_changed" == "true" ]]; then
        ((total_files++))
    fi
    
done < <(find . -name "*.md" -type f -print0)

# Also check other file types that might contain Discord links
echo -e "${GREEN}🎯 Checking Other File Types...${NC}"

# Check YAML files
while IFS= read -r -d '' file; do
    file_changed=false
    
    for old_link in "${OLD_DISCORD_LINKS[@]}"; do
        if update_discord_link "$file" "$old_link" "Update Discord link in YAML"; then
            file_changed=true
            ((total_changes++))
        fi
    done
    
    if [[ "$file_changed" == "true" ]]; then
        ((total_files++))
    fi
    
done < <(find . -name "*.yml" -o -name "*.yaml" -type f -print0)

# Check shell scripts
while IFS= read -r -d '' file; do
    file_changed=false
    
    for old_link in "${OLD_DISCORD_LINKS[@]}"; do
        if update_discord_link "$file" "$old_link" "Update Discord link in script"; then
            file_changed=true
            ((total_changes++))
        fi
    done
    
    if [[ "$file_changed" == "true" ]]; then
        ((total_files++))
    fi
    
done < <(find . -name "*.sh" -type f -print0)

# Summary
echo ""
echo "==========================================="
if [[ "$total_changes" -eq 0 ]]; then
    echo -e "${GREEN}🎉 No incorrect Discord links found!${NC}"
elif [[ "$DRY_RUN" == "true" ]]; then
    echo -e "${YELLOW}📊 DRY RUN SUMMARY:${NC}"
    echo -e "${YELLOW}   - Would update ${total_files} files${NC}"
    echo -e "${YELLOW}   - Would make ${total_changes} total changes${NC}"
    echo -e "${CYAN}💡 Run without --dry-run to apply changes${NC}"
else
    echo -e "${GREEN}📊 UPDATE COMPLETE:${NC}"
    echo -e "${GREEN}   - Updated ${total_files} files${NC}"
    echo -e "${GREEN}   - Made ${total_changes} total changes${NC}"
    echo -e "${BLUE}💾 Backup files created with .discord-backup.timestamp extension${NC}"
fi

echo ""
echo -e "${BLUE}🔍 Discord link update complete!${NC}"

# Create verification script
if [[ "$DRY_RUN" == "false" && "$total_changes" -gt 0 ]]; then
    echo ""
    echo -e "${BLUE}📝 Creating verification script...${NC}"
    
    cat > verify-discord-links.sh << 'EOF'
#!/bin/bash
echo "🔍 Verification: Scanning for old Discord invite links..."
echo ""
echo "Looking for old Discord links:"
for pattern in "discord\.gg/A7h7bKBCVa" "discord\.gg/FYSvu83caM" "discord\.gg/aGF5vgb" "discord\.gg/HomelabarrCli" "discord\.gg/homelabarr"; do
    echo "Checking for: $pattern"
    files=$(find . -name "*.md" -o -name "*.yml" -o -name "*.yaml" -o -name "*.sh" -type f -exec grep -l "$pattern" {} \; | grep -v ".discord-backup." | head -5)
    if [[ -n "$files" ]]; then
        echo "❌ Found in: $files"
    else
        echo "✅ Not found"
    fi
done
echo ""
echo "Correct Discord link should be: https://discord.gg/Pc7mXX786x"
EOF
    
    chmod +x verify-discord-links.sh
    echo -e "${GREEN}✅ Created verify-discord-links.sh script${NC}"
fi
