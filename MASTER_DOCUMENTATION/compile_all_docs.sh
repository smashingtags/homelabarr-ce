#!/bin/bash

# Comprehensive Documentation Compilation Script
# This script compiles ALL 848+ documentation files into organized sections

echo "=== HomelabARR Documentation Compilation ==="
echo "Compiling 848+ documentation files..."

# Create compilation directories
mkdir -p COMPILED_WIKI
mkdir -p COMPILED_CLAUDE
mkdir -p COMPILED_APPS
mkdir -p COMPILED_SCRIPTS
mkdir -p COMPILED_TXT
mkdir -p COMPILED_MISC

# 1. Compile all wiki documentation (126+ files)
echo "Compiling wiki documentation..."
find ../wiki/docs -name "*.md" -exec cp {} COMPILED_WIKI/ \; 2>/dev/null

# 2. Compile all .claude documentation (261+ files)
echo "Compiling .claude documentation..."
find ../.claude -name "*.md" -exec cp {} COMPILED_CLAUDE/ \; 2>/dev/null
find ../.claude -name "*.txt" -exec cp {} COMPILED_CLAUDE/ \; 2>/dev/null

# 3. Compile all apps documentation
echo "Compiling apps documentation..."
find ../apps -name "README.md" -exec cp {} COMPILED_APPS/ \; 2>/dev/null
find ../apps -name "*.txt" -exec cp {} COMPILED_APPS/ \; 2>/dev/null

# 4. Compile all scripts documentation
echo "Compiling scripts documentation..."
find ../scripts -name "*.md" -exec cp {} COMPILED_SCRIPTS/ \; 2>/dev/null
find ../scripts -name "*.txt" -exec cp {} COMPILED_SCRIPTS/ \; 2>/dev/null

# 5. Compile all root .txt files
echo "Compiling txt files..."
find .. -maxdepth 2 -name "*.txt" -exec cp {} COMPILED_TXT/ \; 2>/dev/null

# 6. Compile all other documentation
echo "Compiling miscellaneous documentation..."
find .. -name "CHANGELOG*" -exec cp {} COMPILED_MISC/ \; 2>/dev/null
find .. -name "TODO*" -exec cp {} COMPILED_MISC/ \; 2>/dev/null
find .. -name "NOTES*" -exec cp {} COMPILED_MISC/ \; 2>/dev/null

# Count results
echo ""
echo "=== Compilation Results ==="
echo "Wiki files: $(ls COMPILED_WIKI | wc -l)"
echo "Claude files: $(ls COMPILED_CLAUDE | wc -l)"
echo "Apps files: $(ls COMPILED_APPS | wc -l)"
echo "Scripts files: $(ls COMPILED_SCRIPTS | wc -l)"
echo "TXT files: $(ls COMPILED_TXT | wc -l)"
echo "Misc files: $(ls COMPILED_MISC | wc -l)"
echo "Total: $(find COMPILED_* -type f | wc -l)"