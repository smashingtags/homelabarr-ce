#!/bin/bash
echo "🔍 Verification: Scanning for remaining homelabarr-cli references..."
find . -name "*.md" -type f -exec grep -l -i "HomelabarrCli\|dock-server" {} \; | grep -v ".backup." | head -10
echo ""
echo "If no files are listed above, all references have been successfully updated!"
