#!/bin/bash
set -e

echo "================================================================"
echo "HomelabARR CLI: Multi-Space Confluence Migration Test"
echo "================================================================"
echo "Testing connectivity to both HLCLI and HC spaces before migration"
echo "================================================================"

# Configuration
OUTPUT_DIR="/mnt/f/Coding Projects/homelabarr-ce/.claude/confluence-test-export"
TEST_RESULTS="$OUTPUT_DIR/test-results.log"

# Create test directory
mkdir -p "$OUTPUT_DIR"
echo "📁 Test output directory: $OUTPUT_DIR"

# Initialize test log
echo "Multi-Space Migration Test - $(date)" > "$TEST_RESULTS"
echo "=========================================" >> "$TEST_RESULTS"

# Function to test MCP tool availability
test_mcp_tool() {
    local tool_name="$1"
    local description="$2"
    
    echo "🔧 Testing: $description"
    
    if command -v "mcp__MCP_DOCKER__$tool_name" >/dev/null 2>&1; then
        echo "✅ MCP tool available: $tool_name" | tee -a "$TEST_RESULTS"
        return 0
    else
        echo "❌ MCP tool NOT available: $tool_name" | tee -a "$TEST_RESULTS"
        return 1
    fi
}

# Function to test space connectivity
test_space_connectivity() {
    local space_key="$1"
    local space_name="$2"
    
    echo ""
    echo "--- Testing Space: $space_name ($space_key) ---"
    
    # Test 1: Basic search
    echo "🔍 Test: Search pages in $space_key"
    
    # Create a Python test script for this space
    cat << EOF > "$OUTPUT_DIR/test_space_$space_key.py"
#!/usr/bin/env python3
import subprocess
import json
import sys
from datetime import datetime

def test_space_search(space_key):
    """Test searching a specific space."""
    try:
        # Method 1: Direct search
        print(f"  Method 1: Direct search in space {space_key}")
        result1 = subprocess.run([
            "mcp__MCP_DOCKER__confluence_search",
            "--query", "HomelabARR",
            "--limit", "5"
        ], capture_output=True, text=True, timeout=45)
        
        if result1.returncode == 0:
            try:
                data1 = json.loads(result1.stdout)
                pages1 = data1.get("results", [])
                
                # Filter by space
                space_pages = [p for p in pages1 if p.get("space", {}).get("key") == space_key]
                
                print(f"    Found {len(pages1)} total pages, {len(space_pages)} in {space_key}")
                
                if space_pages:
                    print(f"    ✅ Space {space_key} accessible with {len(space_pages)} pages")
                    
                    for page in space_pages[:3]:  # Show first 3 pages
                        title = page.get("title", "No title")
                        page_id = page.get("id", "No ID")
                        print(f"      - {title} (ID: {page_id})")
                    
                    return True, len(space_pages)
                else:
                    print(f"    ⚠️ Space {space_key} found no matching pages")
                    return False, 0
                    
            except json.JSONDecodeError as e:
                print(f"    ❌ JSON decode error: {str(e)}")
                print(f"    Raw output: {result1.stdout[:200]}...")
                return False, 0
        else:
            print(f"    ❌ Search failed with return code {result1.returncode}")
            print(f"    Error: {result1.stderr}")
            return False, 0
            
    except subprocess.TimeoutExpired:
        print(f"    ⏰ Search timed out for space {space_key}")
        return False, 0
    except Exception as e:
        print(f"    ❌ Exception during search: {str(e)}")
        return False, 0

def test_page_retrieval(page_id):
    """Test retrieving a specific page."""
    try:
        print(f"  Testing page retrieval for ID: {page_id}")
        
        result = subprocess.run([
            "mcp__MCP_DOCKER__confluence_get_page",
            "--page_id", page_id,
            "--include_metadata", "true"
        ], capture_output=True, text=True, timeout=30)
        
        if result.returncode == 0:
            try:
                data = json.loads(result.stdout)
                title = data.get("title", "No title")
                content_length = len(str(data.get("body", {})))
                print(f"    ✅ Retrieved page: {title} ({content_length} chars)")
                return True
            except json.JSONDecodeError:
                print(f"    ⚠️ Page retrieved but JSON parse failed")
                return False
        else:
            print(f"    ❌ Failed to retrieve page: {result.stderr}")
            return False
            
    except Exception as e:
        print(f"    ❌ Exception during page retrieval: {str(e)}")
        return False

if __name__ == "__main__":
    space_key = sys.argv[1] if len(sys.argv) > 1 else "hlcli"
    
    print(f"Testing Confluence Space: {space_key}")
    print(f"Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print()
    
    # Test space search
    success, page_count = test_space_search(space_key)
    
    if success and page_count > 0:
        print(f"\n🎉 Space {space_key} is accessible with {page_count} pages")
        print(f"✨ Ready for migration!")
    elif page_count == 0:
        print(f"\n⚠️ Space {space_key} is accessible but no pages found")
        print(f"   This might be due to:")
        print(f"   - Empty space")
        print(f"   - Search query not matching content")
        print(f"   - Date filtering (if applied)")
    else:
        print(f"\n❌ Space {space_key} is not accessible")
        print(f"   Check:")
        print(f"   - Space key spelling: '{space_key}'")
        print(f"   - Confluence permissions")
        print(f"   - MCP tool configuration")
        print(f"   - Premium subscription status")
EOF
    
    # Run the test
    if python3 "$OUTPUT_DIR/test_space_$space_key.py" "$space_key"; then
        echo "✅ $space_name ($space_key) - Test PASSED" >> "$TEST_RESULTS"
        return 0
    else
        echo "❌ $space_name ($space_key) - Test FAILED" >> "$TEST_RESULTS"
        return 1
    fi
}

# Main testing sequence
echo "Starting multi-space connectivity tests..."
echo ""

# Test 1: MCP Tools Availability
echo "=== Phase 1: MCP Tools Availability ==="
echo "" >> "$TEST_RESULTS"
echo "Phase 1: MCP Tools" >> "$TEST_RESULTS"
echo "------------------" >> "$TEST_RESULTS"

mcp_tools_ok=true
test_mcp_tool "confluence_search" "Confluence Search" || mcp_tools_ok=false
test_mcp_tool "confluence_get_page" "Confluence Get Page" || mcp_tools_ok=false

if [ "$mcp_tools_ok" = false ]; then
    echo ""
    echo "❌ CRITICAL: MCP tools are not available"
    echo "💡 Solutions:"
    echo "   1. Ensure you're running from Claude Code with MCP enabled"
    echo "   2. Check .mcp.json configuration"
    echo "   3. Restart Claude Code if needed"
    echo "   4. Verify Docker is running (for MCP_DOCKER tools)"
    echo ""
    echo "❌ Cannot proceed with migration until MCP tools are working"
    exit 1
fi

echo "✅ All MCP tools available"

# Test 2: Space Connectivity
echo ""
echo "=== Phase 2: Space Connectivity Tests ==="
echo "" >> "$TEST_RESULTS"
echo "Phase 2: Space Connectivity" >> "$TEST_RESULTS"
echo "---------------------------" >> "$TEST_RESULTS"

# Test both target spaces
spaces_ok=0
total_spaces=0

# Test HLCLI space
echo "Testing HLCLI space..."
if test_space_connectivity "hlcli" "HomelabARR CLI"; then
    ((spaces_ok++))
fi
((total_spaces++))

# Test HC space
echo "Testing HC space..."
if test_space_connectivity "HC" "HomelabARR Community"; then
    ((spaces_ok++))
fi
((total_spaces++))

# Test DO space as fallback (if user has been using that)
echo "Testing DO space (fallback)..."
if test_space_connectivity "DO" "HomelabARR Documentation"; then
    echo "ℹ️ Note: DO space also available as fallback" >> "$TEST_RESULTS"
fi

# Summary
echo ""
echo "=== Test Summary ==="
echo "" >> "$TEST_RESULTS"
echo "Test Summary" >> "$TEST_RESULTS"
echo "------------" >> "$TEST_RESULTS"
echo "Spaces tested: $total_spaces" >> "$TEST_RESULTS"
echo "Spaces accessible: $spaces_ok" >> "$TEST_RESULTS"
echo "Success rate: $((spaces_ok * 100 / total_spaces))%" >> "$TEST_RESULTS"
echo "Test completed: $(date)" >> "$TEST_RESULTS"

if [ $spaces_ok -eq $total_spaces ]; then
    echo "🎉 ALL TESTS PASSED!"
    echo "✅ Both target spaces (HLCLI and HC) are accessible"
    echo "✅ MCP tools are working correctly"
    echo "🚀 Ready to run full migration!"
    
    echo ""
    echo "=== Next Steps ==="
    echo "1. Run the full migration:"
    echo "   python3 multi-space-confluence-migrator.py"
    echo ""
    echo "2. Migration will include:"
    echo "   - Date filtering (July/August 2024 onwards)"
    echo "   - Space-specific organization"
    echo "   - Metadata preservation"
    echo "   - Automatic categorization"
    echo ""
    echo "3. Estimated time: 10-30 minutes total"
    echo "   (depending on number of pages found)"
    
elif [ $spaces_ok -gt 0 ]; then
    echo "⚠️ PARTIAL SUCCESS"
    echo "✅ $spaces_ok out of $total_spaces spaces accessible"
    echo "⚠️ Some spaces may not be available or have different keys"
    echo ""
    echo "💡 You can still run migration with accessible spaces"
    echo "   The tool will skip inaccessible spaces automatically"
    
else
    echo "❌ ALL TESTS FAILED"
    echo "❌ No target spaces are accessible"
    echo ""
    echo "🔧 Troubleshooting:"
    echo "   1. Verify space keys: 'hlcli' and 'HC'"
    echo "   2. Check Confluence Premium subscription (3 days remaining)"
    echo "   3. Verify permissions to access these spaces"
    echo "   4. Try accessing spaces manually in web browser"
    echo "   5. Check if spaces were renamed or moved"
    echo ""
    echo "💡 Alternative: Try with 'DO' space if that's your main space"
fi

echo ""
echo "📋 Detailed test results saved to: $TEST_RESULTS"
echo ""
echo "================================================================"
echo "Multi-Space Migration Test Complete"
echo "================================================================"

# Create a quick reference for migration
cat << 'REFERENCE' > "$OUTPUT_DIR/migration-quick-reference.md"
# Multi-Space Migration Quick Reference

## Pre-Migration Checklist

- [ ] MCP tools tested and working
- [ ] Target spaces accessible (HLCLI, HC)
- [ ] Obsidian vault path confirmed
- [ ] Confluence Premium active (3 days remaining)
- [ ] Backup existing Obsidian vault (if needed)

## Migration Command

```bash
python3 multi-space-confluence-migrator.py
```

## Expected Results

### Directory Structure Created
```
Confluence Migration/
├── HomelabARR-CLI/          # HLCLI space content
│   ├── Installation/
│   ├── Applications/
│   ├── Project Management/
│   ├── Security/
│   ├── Maintenance/
│   ├── Troubleshooting/
│   ├── Architecture/
│   ├── Development/
│   └── User Guides/
├── HomelabARR-Community/     # HC space content  
│   └── (same structure)
├── _metadata/               # Migration reports
├── _attachments/           # File attachments
└── _exports/              # Raw exports
```

### Key Files
- `00-migration-index.md` - Master navigation
- `_metadata/multi-space-migration-report.md` - Detailed report

## Date Filtering Options
1. July 2024 onwards (recommended)
2. August 2024 onwards  
3. All pages (no filter)
4. Custom date range

## Post-Migration Tasks
1. Review migrated content in Obsidian
2. Check for formatting issues
3. Add additional wikilinks
4. Organize content as needed
5. Update tags and metadata

## Support
- Test results: `test-results.log`
- Migration tool: `multi-space-confluence-migrator.py`
- Fallback tool: `quick-confluence-export.py`
REFERENCE

echo "📖 Migration reference created: $OUTPUT_DIR/migration-quick-reference.md"
