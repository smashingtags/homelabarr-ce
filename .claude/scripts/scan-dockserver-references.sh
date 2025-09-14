#!/bin/bash

# Script to scan all .md files for homelabarr-cli references
# Usage: ./scan-HomelabarrCli-references.sh

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔍 Scanning for homelabarr-cli references in .md files...${NC}"
echo "=================================================="

# Function to search for patterns and display results
search_pattern() {
    local pattern="$1"
    local description="$2"
    local color="$3"
    
    echo -e "\n${color}📋 Searching for: ${description}${NC}"
    echo "----------------------------------------"
    
    # Use find to get all .md files, then grep for the pattern
    local results=$(find . -name "*.md" -type f -exec grep -l -i "$pattern" {} \; 2>/dev/null)
    
    if [ -z "$results" ]; then
        echo -e "${GREEN}✅ No instances found${NC}"
        return 0
    fi
    
    local count=0
    while IFS= read -r file; do
        if [ ! -z "$file" ]; then
            echo -e "${YELLOW}📄 File: ${file}${NC}"
            # Show the lines with context
            grep -n -i --color=always "$pattern" "$file" | head -5
            echo ""
            ((count++))
        fi
    done <<< "$results"
    
    echo -e "${RED}⚠️  Found ${count} files with '${description}' references${NC}"
    return $count
}

# Initialize total count
total_files=0

# Search for various homelabarr-cli patterns
search_pattern "HomelabarrCli" "homelabarr-cli (lowercase)" "$YELLOW"
total_files=$((total_files + $?))

search_pattern "HomelabarrCli" "homelabarr-cli (mixed case)" "$YELLOW"
total_files=$((total_files + $?))

search_pattern "HomelabarrCli" "homelabarr-cli (uppercase)" "$YELLOW"
total_files=$((total_files + $?))

search_pattern "dock-server" "dock-server (hyphenated)" "$YELLOW"
total_files=$((total_files + $?))

search_pattern "dock_server" "dock_server (underscore)" "$YELLOW"
total_files=$((total_files + $?))

# Search for Docker Hub references
search_pattern "ghcr\.io/HomelabarrCli" "Docker Hub homelabarr-cli images" "$RED"
total_files=$((total_files + $?))

# Search for GitHub references
search_pattern "github\.com/HomelabarrCli" "GitHub homelabarr-cli references" "$RED"
total_files=$((total_files + $?))

# Summary
echo ""
echo "=================================================="
if [ $total_files -eq 0 ]; then
    echo -e "${GREEN}🎉 SUCCESS: No homelabarr-cli references found in .md files!${NC}"
else
    echo -e "${RED}📊 SUMMARY: Found references in ${total_files} file(s)${NC}"
    echo -e "${YELLOW}💡 Consider updating these references to HomelabARR CLI${NC}"
fi

echo ""
echo -e "${BLUE}🔍 Scan complete!${NC}"

# Create a detailed report
echo ""
echo -e "${BLUE}📝 Generating detailed report...${NC}"
report_file="HomelabarrCli-references-report.txt"

{
    echo "homelabarr-cli References Report"
    echo "Generated: $(date)"
    echo "Repository: $(basename $(pwd))"
    echo "=============================="
    echo ""
    
    find . -name "*.md" -type f -exec grep -l -i "HomelabarrCli\|dock-server\|dock_server" {} \; | while read file; do
        echo "File: $file"
        echo "----------------------------------------"
        grep -n -i "HomelabarrCli\|dock-server\|dock_server" "$file"
        echo ""
    done
} > "$report_file"

echo -e "${GREEN}📄 Detailed report saved to: ${report_file}${NC}"
