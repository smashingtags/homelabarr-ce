#!/bin/bash

# HomelabARR CLI - Backup to Bitbucket Script
# Keeps Bitbucket 1-2 days behind GitHub as a safety backup

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}HomelabARR Bitbucket Backup Script${NC}"
echo "======================================="

# Check if we're in the right directory
if [ ! -f "homelabarr-cli.sh" ]; then
    echo -e "${RED}Error: Not in HomelabARR CLI directory${NC}"
    exit 1
fi

# Get current branch
CURRENT_BRANCH=$(git branch --show-current)
echo -e "${YELLOW}Current branch: ${CURRENT_BRANCH}${NC}"

# Fetch latest from GitHub
echo -e "${YELLOW}Fetching latest from GitHub...${NC}"
git fetch origin

# Show commit difference
echo -e "${YELLOW}Commits ahead of Bitbucket:${NC}"
git log bitbucket/main..origin/main --oneline | head -10

# Ask for confirmation
read -p "Push to Bitbucket backup? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Pushing to Bitbucket...${NC}"
    git push bitbucket main
    echo -e "${GREEN}✓ Backup complete!${NC}"
    
    # Log the backup
    echo "$(date): Backed up to Bitbucket" >> .git/backup.log
else
    echo -e "${YELLOW}Backup cancelled${NC}"
fi

echo ""
echo -e "${GREEN}Backup status:${NC}"
echo "GitHub (origin):   $(git log origin/main -1 --format='%h %s' 2>/dev/null || echo 'Not available')"
echo "Bitbucket (backup): $(git log bitbucket/main -1 --format='%h %s' 2>/dev/null || echo 'Not available')"