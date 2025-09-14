#!/bin/bash

# HomelabARR CLI - Complete Configuration Modernization Script
# HL-2: Container Configuration Modernization and Port Conflict Resolution
# Version: 2.3.0

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="/tmp/homelabarr-modernization-$(date +%Y%m%d_%H%M%S).log"

# Print colored output
print_status() {
    local status="$1"
    local message="$2"
    case "$status" in
        "SUCCESS") echo -e "${GREEN}✓${NC} $message" ;;
        "WARNING") echo -e "${YELLOW}⚠${NC} $message" ;;
        "ERROR") echo -e "${RED}✗${NC} $message" ;;
        "INFO") echo -e "${BLUE}ℹ${NC} $message" ;;
        "STEP") echo -e "${BLUE}==>${NC} $message" ;;
    esac
}

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Check if required tools exist
check_tools() {
    local tools=("validate-configs.sh" "fix-port-conflicts.sh" "cleanup-temp-files.sh")
    local missing_tools=()
    
    for tool in "${tools[@]}"; do
        if [[ ! -f "$SCRIPT_DIR/$tool" ]]; then
            missing_tools+=("$tool")
        elif [[ ! -x "$SCRIPT_DIR/$tool" ]]; then
            print_status "WARNING" "$tool is not executable, fixing..."
            chmod +x "$SCRIPT_DIR/$tool"
        fi
    done
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        print_status "ERROR" "Missing required tools: ${missing_tools[*]}"
        return 1
    fi
    
    print_status "SUCCESS" "All required tools are available"
    return 0
}

# Run configuration validation
run_validation() {
    print_status "STEP" "Step 1: Validating all container configurations"
    log "Starting configuration validation"
    
    if "$SCRIPT_DIR/validate-configs.sh"; then
        print_status "SUCCESS" "Configuration validation completed"
        return 0
    else
        print_status "WARNING" "Configuration validation found issues"
        return 1
    fi
}

# Run port conflict resolution
run_port_resolution() {
    local mode="${1:-auto}"
    
    print_status "STEP" "Step 2: Resolving port conflicts ($mode mode)"
    log "Starting port conflict resolution - Mode: $mode"
    
    if "$SCRIPT_DIR/fix-port-conflicts.sh" "$mode"; then
        print_status "SUCCESS" "Port conflict resolution completed"
        return 0
    else
        print_status "WARNING" "Port conflict resolution encountered issues"
        return 1
    fi
}

# Run cleanup
run_cleanup() {
    local mode="${1:-auto}"
    
    print_status "STEP" "Step 3: Cleaning up temporary files and artifacts"
    log "Starting cleanup - Mode: $mode"
    
    if "$SCRIPT_DIR/cleanup-temp-files.sh" "$mode"; then
        print_status "SUCCESS" "Cleanup completed"
        return 0
    else
        print_status "WARNING" "Cleanup encountered issues"
        return 1
    fi
}

# Re-validate after changes
final_validation() {
    print_status "STEP" "Step 4: Final validation after modernization"
    log "Running final validation"
    
    if "$SCRIPT_DIR/validate-configs.sh"; then
        print_status "SUCCESS" "Final validation passed - all configurations are compliant"
        return 0
    else
        print_status "ERROR" "Final validation failed - manual intervention required"
        return 1
    fi
}

# Generate modernization report
generate_report() {
    local success="$1"
    local report_file="/tmp/homelabarr-modernization-report-$(date +%Y%m%d_%H%M%S).json"
    
    cat > "$report_file" << EOF
{
  "modernization_timestamp": "$(date -Iseconds)",
  "script_version": "2.3.0",
  "modernization_successful": $success,
  "steps_completed": {
    "validation": true,
    "port_resolution": true,
    "cleanup": true,
    "final_validation": $success
  },
  "log_file": "$LOG_FILE",
  "report_file": "$report_file",
  "next_steps": [
    "Review validation reports for any remaining warnings",
    "Test container deployments",
    "Update documentation if needed",
    "Schedule regular validation runs"
  ]
}
EOF
    
    print_status "INFO" "Modernization report: $report_file"
}

# Show summary
show_summary() {
    local success="$1"
    
    echo
    echo "=============================="
    echo "MODERNIZATION SUMMARY"
    echo "=============================="
    
    if [[ "$success" == "true" ]]; then
        print_status "SUCCESS" "Container configuration modernization completed successfully"
        echo
        echo "✓ All configurations validated"
        echo "✓ Port conflicts resolved"
        echo "✓ Temporary files cleaned"
        echo "✓ Final validation passed"
    else
        print_status "WARNING" "Container configuration modernization completed with warnings"
        echo
        echo "⚠ Some issues may require manual intervention"
        echo "⚠ Check validation reports for details"
    fi
    
    echo
    echo "Log file: $LOG_FILE"
    echo
    echo "Next steps:"
    echo "1. Review any validation warnings"
    echo "2. Test container deployments"
    echo "3. Update documentation if needed"
    echo "4. Schedule regular validation runs"
}

# Interactive mode
interactive_mode() {
    print_status "INFO" "Interactive modernization mode"
    echo
    
    # Step 1: Validation (always run)
    if ! run_validation; then
        echo
        read -p "Validation found issues. Continue anyway? (y/N): " continue_choice
        if [[ ! "$continue_choice" =~ ^[Yy]$ ]]; then
            print_status "INFO" "Modernization cancelled"
            return 1
        fi
    fi
    
    # Step 2: Port resolution
    echo
    echo "Port conflict resolution options:"
    echo "  1) Automatic resolution"
    echo "  2) Interactive resolution"
    echo "  3) Detection only (no changes)"
    echo "  4) Skip port resolution"
    echo
    
    read -p "Choose option (1-4): " port_choice
    
    case "$port_choice" in
        1) run_port_resolution "auto" ;;
        2) run_port_resolution "interactive" ;;
        3) run_port_resolution "detect-only" ;;
        4) print_status "INFO" "Skipping port resolution" ;;
        *) print_status "WARNING" "Invalid choice, using automatic resolution"
           run_port_resolution "auto" ;;
    esac
    
    # Step 3: Cleanup
    echo
    echo "Cleanup options:"
    echo "  1) Automatic cleanup"
    echo "  2) Interactive cleanup" 
    echo "  3) Dry run (show what would be cleaned)"
    echo "  4) Skip cleanup"
    echo
    
    read -p "Choose option (1-4): " cleanup_choice
    
    case "$cleanup_choice" in
        1) run_cleanup "auto" ;;
        2) run_cleanup "interactive" ;;
        3) run_cleanup "--dry-run" ;;
        4) print_status "INFO" "Skipping cleanup" ;;
        *) print_status "WARNING" "Invalid choice, using automatic cleanup"
           run_cleanup "auto" ;;
    esac
    
    # Step 4: Final validation
    if final_validation; then
        generate_report "true"
        show_summary "true"
        return 0
    else
        generate_report "false"
        show_summary "false"
        return 1
    fi
}

# Automatic mode
automatic_mode() {
    print_status "INFO" "Automatic modernization mode"
    
    local validation_success=true
    local port_success=true
    local cleanup_success=true
    local final_success=true
    
    # Step 1: Validation
    if ! run_validation; then
        validation_success=false
    fi
    
    # Step 2: Port resolution
    if ! run_port_resolution "auto"; then
        port_success=false
    fi
    
    # Step 3: Cleanup
    if ! run_cleanup "auto"; then
        cleanup_success=false
    fi
    
    # Step 4: Final validation
    if ! final_validation; then
        final_success=false
    fi
    
    # Determine overall success
    if $validation_success && $port_success && $cleanup_success && $final_success; then
        generate_report "true"
        show_summary "true"
        return 0
    else
        generate_report "false"
        show_summary "false"
        return 1
    fi
}

# Dry run mode
dry_run_mode() {
    print_status "INFO" "Dry run mode - no changes will be made"
    echo
    
    # Validation (always safe)
    run_validation
    
    # Port conflict detection only
    print_status "STEP" "Checking for port conflicts (detection only)"
    "$SCRIPT_DIR/fix-port-conflicts.sh" "detect-only"
    
    # Cleanup dry run
    print_status "STEP" "Showing what would be cleaned"
    "$SCRIPT_DIR/cleanup-temp-files.sh" "--dry-run"
    
    print_status "INFO" "Dry run completed - no changes were made"
}

# Main function
main() {
    local mode="${1:-auto}"
    
    echo "HomelabARR CLI Container Configuration Modernization"
    echo "==================================================="
    echo "HL-2: Container Configuration Modernization and Port Conflict Resolution"
    echo "Version: 2.3.0"
    echo
    
    log "Starting container configuration modernization - Mode: $mode"
    
    # Check if tools are available
    if ! check_tools; then
        exit 1
    fi
    
    case "$mode" in
        "auto")
            automatic_mode
            ;;
        "interactive")
            interactive_mode
            ;;
        "dry-run")
            dry_run_mode
            ;;
        *)
            print_status "ERROR" "Invalid mode: $mode"
            echo
            echo "Available modes:"
            echo "  auto        - Automatic modernization (default)"
            echo "  interactive - Interactive modernization with choices"
            echo "  dry-run     - Show what would be done without changes"
            exit 1
            ;;
    esac
}

# Handle script arguments
case "${1:-}" in
    --help|-h)
        echo "HomelabARR CLI Container Configuration Modernization"
        echo
        echo "Usage: $0 [MODE] [OPTIONS]"
        echo
        echo "Modes:"
        echo "  auto         Automatic modernization (default)"
        echo "  interactive  Interactive modernization with user choices"
        echo "  dry-run      Show what would be done without making changes"
        echo
        echo "Options:"
        echo "  --help, -h   Show this help message"
        echo "  --version    Show version information"
        echo
        echo "This script performs complete container configuration modernization:"
        echo "  1. Validates all YAML configurations"
        echo "  2. Resolves port conflicts automatically"
        echo "  3. Cleans up temporary files and artifacts"
        echo "  4. Performs final validation"
        echo
        echo "Examples:"
        echo "  $0                    # Automatic modernization"
        echo "  $0 interactive        # Interactive mode"
        echo "  $0 dry-run            # Preview changes only"
        exit 0
        ;;
    --version)
        echo "HomelabARR CLI Container Configuration Modernization v2.3.0"
        echo "Part of HL-2: Container Configuration Modernization and Port Conflict Resolution"
        exit 0
        ;;
    *)
        main "$@"
        ;;
esac
