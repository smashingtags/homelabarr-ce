#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}================================================================${NC}"
echo -e "${BLUE}HomelabARR CLI: Confluence to Obsidian Migration Suite${NC}"
echo -e "${BLUE}================================================================${NC}"
echo -e "${YELLOW}🎯 Target Spaces: HLCLI + HC${NC}"
echo -e "${YELLOW}📅 Date Filtering: July/August 2024 onwards${NC}"
echo -e "${YELLOW}⏰ Premium Expires: 3 days remaining${NC}"
echo -e "${BLUE}================================================================${NC}"
echo

# Configuration
PROJECT_DIR="/mnt/f/Coding Projects/homelabarr-ce"
OUTPUT_DIR="$PROJECT_DIR/.claude/obsidian-vault"
LOG_DIR="$PROJECT_DIR/.claude/confluence-export"

# Create directories
mkdir -p "$OUTPUT_DIR"
mkdir -p "$LOG_DIR"

echo -e "${BLUE}📁 Project Directory: $PROJECT_DIR${NC}"
echo -e "${BLUE}📁 Output Directory: $OUTPUT_DIR${NC}"
echo -e "${BLUE}📁 Log Directory: $LOG_DIR${NC}"
echo

# Function to print colored messages
print_status() {
    local status="$1"
    local message="$2"
    case "$status" in
        "success") echo -e "${GREEN}✅ $message${NC}" ;;
        "error") echo -e "${RED}❌ $message${NC}" ;;
        "warning") echo -e "${YELLOW}⚠️ $message${NC}" ;;
        "info") echo -e "${BLUE}ℹ️ $message${NC}" ;;
        *) echo "$message" ;;
    esac
}

# Function to check prerequisites
check_prerequisites() {
    print_status "info" "Checking prerequisites..."
    
    # Check if we're in the right directory
    if [ ! -f "$PROJECT_DIR/CLAUDE.md" ]; then
        print_status "error" "Not in HomelabARR CLI project directory"
        print_status "error" "Please run from: $PROJECT_DIR"
        exit 1
    fi
    
    # Check if Python is available
    if ! command -v python3 >/dev/null 2>&1; then
        print_status "error" "Python 3 not found"
        exit 1
    fi
    
    # Check if migration script exists
    if [ ! -f "$PROJECT_DIR/multi-space-confluence-migrator.py" ]; then
        print_status "error" "Migration script not found: multi-space-confluence-migrator.py"
        exit 1
    fi
    
    # Make scripts executable
    chmod +x "$PROJECT_DIR/multi-space-confluence-migrator.py" 2>/dev/null || true
    chmod +x "$PROJECT_DIR/test-multi-space-migration.sh" 2>/dev/null || true
    
    print_status "success" "Prerequisites check passed"
}

# Function to run connectivity test
run_connectivity_test() {
    print_status "info" "Running connectivity tests..."
    echo
    
    if [ -f "$PROJECT_DIR/test-multi-space-migration.sh" ]; then
        if bash "$PROJECT_DIR/test-multi-space-migration.sh"; then
            print_status "success" "Connectivity tests passed"
            return 0
        else
            print_status "warning" "Some connectivity tests failed"
            echo
            echo -e "${YELLOW}Do you want to continue anyway? [y/N]${NC}"
            read -r response
            if [[ "$response" =~ ^[Yy]$ ]]; then
                return 0
            else
                print_status "error" "Migration cancelled by user"
                exit 1
            fi
        fi
    else
        print_status "warning" "Connectivity test script not found, skipping..."
        return 0
    fi
}

# Function to run migration
run_migration() {
    print_status "info" "Starting migration process..."
    echo
    
    # Set environment variables
    export PYTHONPATH="$PROJECT_DIR:$PYTHONPATH"
    export CONFLUENCE_OUTPUT_DIR="$OUTPUT_DIR"
    
    # Change to project directory
    cd "$PROJECT_DIR"
    
    # Run the migration
    if python3 "multi-space-confluence-migrator.py"; then
        print_status "success" "Migration completed successfully!"
        return 0
    else
        print_status "error" "Migration failed"
        return 1
    fi
}

# Function to show results
show_results() {
    echo
    echo -e "${BLUE}================================================================${NC}"
    echo -e "${GREEN}🎉 MIGRATION RESULTS${NC}"
    echo -e "${BLUE}================================================================${NC}"
    
    # Check for key result files
    local index_file="$OUTPUT_DIR/Confluence Migration/00-migration-index.md"
    local report_file="$OUTPUT_DIR/Confluence Migration/_metadata/multi-space-migration-report.md"
    
    if [ -f "$index_file" ]; then
        print_status "success" "Migration index created: $index_file"
    fi
    
    if [ -f "$report_file" ]; then
        print_status "success" "Detailed report created: $report_file"
    fi
    
    # Count migrated files
    local md_count=0
    if [ -d "$OUTPUT_DIR/Confluence Migration" ]; then
        md_count=$(find "$OUTPUT_DIR/Confluence Migration" -name "*.md" -type f | wc -l)
    fi
    
    echo
    echo -e "${BLUE}📊 Migration Statistics:${NC}"
    echo -e "${BLUE}   • Files created: $md_count${NC}"
    echo -e "${BLUE}   • Output directory: $OUTPUT_DIR${NC}"
    
    # Show directory structure
    echo
    echo -e "${BLUE}📁 Directory Structure:${NC}"
    if [ -d "$OUTPUT_DIR/Confluence Migration" ]; then
        tree "$OUTPUT_DIR/Confluence Migration" -L 2 2>/dev/null || ls -la "$OUTPUT_DIR/Confluence Migration"
    fi
    
    echo
    echo -e "${GREEN}🚀 Next Steps:${NC}"
    echo -e "${BLUE}   1. Open Obsidian and navigate to: $OUTPUT_DIR${NC}"
    echo -e "${BLUE}   2. Review the migration index: 00-migration-index.md${NC}"
    echo -e "${BLUE}   3. Check individual pages for formatting${NC}"
    echo -e "${BLUE}   4. Add wikilinks between related pages${NC}"
    echo -e "${BLUE}   5. Organize content as needed${NC}"
}

# Function to handle cleanup
cleanup() {
    echo
    print_status "info" "Cleaning up temporary files..."
    
    # Remove any temporary test files
    find "$LOG_DIR" -name "test_space_*.py" -delete 2>/dev/null || true
    
    print_status "success" "Cleanup completed"
}

# Function to show menu
show_menu() {
    echo
    echo -e "${BLUE}Choose an option:${NC}"
    echo -e "${BLUE}1. Run full migration (test + migrate)${NC}"
    echo -e "${BLUE}2. Run connectivity test only${NC}"
    echo -e "${BLUE}3. Run migration only (skip test)${NC}"
    echo -e "${BLUE}4. Show current configuration${NC}"
    echo -e "${BLUE}5. Exit${NC}"
    echo
}

# Function to show configuration
show_configuration() {
    echo
    echo -e "${BLUE}================================================================${NC}"
    echo -e "${BLUE}CURRENT CONFIGURATION${NC}"
    echo -e "${BLUE}================================================================${NC}"
    echo -e "${BLUE}Project Directory:    $PROJECT_DIR${NC}"
    echo -e "${BLUE}Output Directory:     $OUTPUT_DIR${NC}"
    echo -e "${BLUE}Log Directory:        $LOG_DIR${NC}"
    echo -e "${BLUE}Target Spaces:        hlcli, HC${NC}"
    echo -e "${BLUE}Date Filter:          July 2024 onwards (default)${NC}"
    echo -e "${BLUE}Migration Tool:       multi-space-confluence-migrator.py${NC}"
    echo -e "${BLUE}Test Tool:           test-multi-space-migration.sh${NC}"
    echo
    
    # Check file existence
    echo -e "${BLUE}File Status:${NC}"
    [ -f "$PROJECT_DIR/multi-space-confluence-migrator.py" ] && print_status "success" "Migration tool found" || print_status "error" "Migration tool missing"
    [ -f "$PROJECT_DIR/test-multi-space-migration.sh" ] && print_status "success" "Test tool found" || print_status "warning" "Test tool missing"
    [ -d "$OUTPUT_DIR" ] && print_status "success" "Output directory ready" || print_status "warning" "Output directory will be created"
    
    echo
    echo -e "${BLUE}MCP Tools Status:${NC}"
    if command -v mcp__MCP_DOCKER__confluence_search >/dev/null 2>&1; then
        print_status "success" "confluence_search available"
    else
        print_status "error" "confluence_search not available"
    fi
    
    if command -v mcp__MCP_DOCKER__confluence_get_page >/dev/null 2>&1; then
        print_status "success" "confluence_get_page available"
    else
        print_status "error" "confluence_get_page not available"
    fi
}

# Main execution
main() {
    # Check prerequisites first
    check_prerequisites
    
    # Show menu and handle user choice
    while true; do
        show_menu
        echo -n "Enter your choice [1]: "
        read -r choice
        
        # Default to 1 if no choice made
        choice=${choice:-1}
        
        case $choice in
            1)
                print_status "info" "Running full migration (test + migrate)..."
                echo
                
                # Run connectivity test
                if run_connectivity_test; then
                    echo
                    print_status "info" "Connectivity test passed, proceeding with migration..."
                    echo
                    
                    # Run migration
                    if run_migration; then
                        show_results
                    else
                        print_status "error" "Migration failed. Check the output above for details."
                        echo
                        print_status "info" "You can try again or run individual components."
                    fi
                else
                    print_status "error" "Connectivity test failed. Cannot proceed with migration."
                fi
                
                cleanup
                break
                ;;
            2)
                print_status "info" "Running connectivity test only..."
                echo
                
                run_connectivity_test
                echo
                print_status "info" "Test completed. You can now run migration if tests passed."
                ;;
            3)
                print_status "warning" "Skipping connectivity test..."
                echo
                
                if run_migration; then
                    show_results
                else
                    print_status "error" "Migration failed. Run connectivity test first to diagnose issues."
                fi
                
                cleanup
                break
                ;;
            4)
                show_configuration
                ;;
            5)
                print_status "info" "Exiting..."
                exit 0
                ;;
            *)
                print_status "error" "Invalid choice. Please try again."
                ;;
        esac
        
        echo
        echo "Press Enter to continue..."
        read -r
    done
}

# Trap to ensure cleanup on exit
trap cleanup EXIT

# Run main function
main "$@"

echo
echo -e "${BLUE}================================================================${NC}"
echo -e "${GREEN}HomelabARR CLI Migration Suite Complete${NC}"
echo -e "${BLUE}================================================================${NC}"
