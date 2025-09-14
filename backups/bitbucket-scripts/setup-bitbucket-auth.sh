#!/bin/bash

# HomelabARR CLI - Bitbucket Authentication Setup
# Use your Bitbucket app password when prompted

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}Bitbucket Authentication Setup${NC}"
echo "======================================="
echo ""
echo -e "${YELLOW}Instructions:${NC}"
echo "1. When prompted for password, use your Bitbucket App Password"
echo "2. App passwords can be created at: https://bitbucket.org/account/settings/app-passwords/"
echo "3. The password will be stored securely in your Git credential store"
echo ""

# Test authentication
echo -e "${YELLOW}Testing Bitbucket authentication...${NC}"
git ls-remote bitbucket

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Authentication successful!${NC}"
    echo ""
    echo -e "${GREEN}You can now use:${NC}"
    echo "  ./scripts/backup-to-bitbucket.sh   - Manual backup to Bitbucket"
    echo "  git push bitbucket main            - Direct push to backup"
else
    echo -e "${RED}✗ Authentication failed${NC}"
    echo "Please check your app password and try again"
    exit 1
fi