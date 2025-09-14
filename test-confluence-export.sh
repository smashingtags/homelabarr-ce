#!/bin/bash
"""
Test Confluence Export - Quick Test Script
==========================================

This script tests the MCP Confluence tools and performs a quick export
to validate everything is working before running the full migration.
"""

set -e

echo "======================================"
echo "HomelabARR CLI: Confluence Export Test"
echo "======================================"

# Test MCP tool availability
echo "🔧 Testing MCP tool availability..."

# Test 1: Search for pages
echo "📋 Test 1: Search Confluence pages"
mcp__MCP_DOCKER__confluence_search --query "HomelabARR" --limit 5 2>/dev/null || {
    echo "❌ MCP Confluence search tool not available"
    echo "💡 Make sure you're running this from Claude Code with MCP Docker enabled"
    exit 1
}

echo "✅ Confluence search tool working"

# Test 2: Try to get a specific page (using known HomelabARR CLI home page ID)
echo "📄 Test 2: Get specific page content"
mcp__MCP_DOCKER__confluence_get_page --page_id "3899503" --include_metadata true 2>/dev/null || {
    echo "❌ MCP Confluence get_page tool failed"
    echo "💡 This might be expected if page ID doesn't exist or permissions issue"
}

echo "✅ Basic MCP tools tested"

# Create test output directory
OUTPUT_DIR="/mnt/f/Coding Projects/homelabarr-ce/.claude/confluence-test-export"
mkdir -p "$OUTPUT_DIR"
echo "📁 Test output directory: $OUTPUT_DIR"

# Run a quick search and export test
echo "🚀 Running quick export test..."

cat << 'EOF' > "$OUTPUT_DIR/test_export.py"
#!/usr/bin/env python3
import subprocess
import json
import sys

def test_search():
    try:
        result = subprocess.run([
            "mcp__MCP_DOCKER__confluence_search",
            "--query", "HomelabARR",
            "--limit", "3"
        ], capture_output=True, text=True, timeout=30)

        if result.returncode == 0:
            data = json.loads(result.stdout)
            pages = data.get("results", [])
            print(f"✅ Found {len(pages)} pages")

            for page in pages:
                title = page.get("title", "No title")
                page_id = page.get("id", "No ID")
                print(f"  - {title} (ID: {page_id})")

            return pages
        else:
            print(f"❌ Search failed: {result.stderr}")
            return []

    except Exception as e:
        print(f"❌ Error: {str(e)}")
        return []

if __name__ == "__main__":
    print("🔍 Testing Confluence search...")
    pages = test_search()

    if pages:
        print(f"\n🎉 MCP Confluence tools are working!")
        print(f"✨ Ready to run full export with quick-confluence-export.py")
    else:
        print(f"\n❌ MCP tools not working or no access to Confluence")
        print(f"💡 Check your MCP Docker setup and Confluence permissions")
EOF

python3 "$OUTPUT_DIR/test_export.py"

echo ""
echo "======================================"
echo "🎯 Next Steps:"
echo "======================================"
echo "1. If tests passed, run: python3 quick-confluence-export.py"
echo "2. If tests failed, check MCP Docker setup in Claude Code"
echo "3. Ensure Confluence Premium is still active (3 days remaining)"
echo "4. Your export will be saved to: .claude/confluence-export/"
echo ""
echo "💡 The full export script has options for:"
echo "   - Date filtering (July/August 2024 onwards)"
echo "   - All pages or specific key pages"
echo "   - Automatic Obsidian-compatible formatting"
echo "   - Metadata preservation"
echo ""
echo "🚀 Ready to migrate your Confluence docs to Obsidian!"