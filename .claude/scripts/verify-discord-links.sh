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
