#!/bin/bash

# YAML validation script for homelabarr-cli apps
set -euo pipefail

APPS_DIR="../local-mode-apps"
LOG_FILE="yaml-validation-$(date +%Y%m%d-%H%M%S).log"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo -e "${BLUE}[$(date +'%H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_FILE"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOG_FILE"
}

# Function to validate YAML syntax
validate_yaml() {
    local file="$1"
    local filename=$(basename "$file")
    
    # Try different validation methods
    if command -v python3 >/dev/null 2>&1; then
        # Use Python YAML validation
        if python3 -c "
import yaml
import sys
try:
    with open('$file', 'r') as f:
        yaml.safe_load(f)
    print('✓ Valid YAML')
    sys.exit(0)
except yaml.YAMLError as e:
    print(f'✗ YAML Error: {e}')
    sys.exit(1)
except Exception as e:
    print(f'✗ Error: {e}')
    sys.exit(1)
" 2>/dev/null; then
        success "  $filename: Valid YAML syntax"
        return 0
    else
        error "  $filename: YAML syntax error detected"
        return 1
    fi
    elif command -v docker >/dev/null 2>&1; then
        # Use docker-compose to validate
        if docker-compose -f "$file" config --quiet 2>/dev/null; then
            success "  $filename: Valid Docker Compose syntax"
            return 0
        else
            error "  $filename: Docker Compose validation failed"
            return 1
        fi
    else
        # Basic YAML structure check
        if grep -q "version:" "$file" && grep -q "services:" "$file"; then
            success "  $filename: Basic YAML structure valid"
            return 0
        else
            warning "  $filename: Missing required Docker Compose structure"
            return 1
        fi
    fi
}

# Function to check common YAML issues
check_common_issues() {
    local file="$1"
    local filename=$(basename "$file")
    local issues=0
    
    # Check for duplicate keys (common issue)
    if awk '
    {
        # Extract key from lines like "  key:" or "key:"
        if (match($0, /^[[:space:]]*([^[:space:]#:]+):[[:space:]]*/, arr)) {
            key = arr[1]
            if (key in seen) {
                print "Duplicate key found: " key " (line " NR ")"
                exit 1
            }
            seen[key] = NR
        }
    }
    ' "$file" 2>/dev/null; then
        success "    No duplicate keys found"
    else
        error "    Duplicate keys detected"
        ((issues++))
    fi
    
    # Check for common indentation issues
    if grep -n "^[[:space:]]*[[:space:]][[:space:]]" "$file" | grep -v "^[[:space:]]*-" >/dev/null; then
        warning "    Potential indentation issues found"
        ((issues++))
    fi
    
    # Check for missing image references
    if ! grep -q "image:" "$file"; then
        warning "    No image references found"
        ((issues++))
    fi
    
    # Check for environment variable syntax
    if grep -n '\${[^}]*[^}]$' "$file" >/dev/null; then
        error "    Malformed environment variable references"
        ((issues++))
    fi
    
    return $issues
}

# Main validation
main() {
    log "Starting YAML validation for homelabarr-cli apps"
    log "Log file: $LOG_FILE"
    
    if [[ ! -d "$APPS_DIR" ]]; then
        error "Apps directory not found: $APPS_DIR"
        exit 1
    fi
    
    local total_files=0
    local valid_files=0
    local invalid_files=0
    local warning_files=0
    
    log "Validating YAML files in: $APPS_DIR"
    
    for file in "$APPS_DIR"/*.yml; do
        [[ ! -f "$file" ]] && continue
        ((total_files++))
        
        filename=$(basename "$file")
        log "Validating: $filename"
        
        if validate_yaml "$file"; then
            ((valid_files++))
            
            # Check for common issues
            if check_common_issues "$file"; then
                issues=$?
                if [[ $issues -gt 0 ]]; then
                    ((warning_files++))
                fi
            fi
        else
            ((invalid_files++))
            error "  $filename: FAILED validation"
        fi
        
        echo ""
    done
    
    # Summary
    log "=== VALIDATION SUMMARY ==="
    log "Total files checked: $total_files"
    success "Valid files: $valid_files"
    [[ $warning_files -gt 0 ]] && warning "Files with warnings: $warning_files"
    [[ $invalid_files -gt 0 ]] && error "Invalid files: $invalid_files"
    
    if [[ $invalid_files -eq 0 ]]; then
        success "✅ All YAML files passed validation!"
        if [[ $warning_files -gt 0 ]]; then
            warning "⚠️  Some files have warnings - check log for details"
        fi
    else
        error "❌ $invalid_files files failed validation"
        log "Check the log file for detailed error information: $LOG_FILE"
        exit 1
    fi
}

# Check dependencies
if ! command -v python3 >/dev/null 2>&1 && ! command -v docker >/dev/null 2>&1; then
    warning "Neither Python3 nor Docker found. Using basic validation only."
fi

# Run validation
main "$@"
