#!/bin/bash
# Auto-validation script for HomelabARR CLI changes

validate_file() {
    local file="$1"
    local validation_passed=true
    
    echo "🔍 Validating: $file"
    
    # YAML validation
    if [[ "$file" == *.yml ]] || [[ "$file" == *.yaml ]]; then
        if command -v docker-compose &> /dev/null; then
            if ! docker-compose -f "$file" config --quiet 2>/dev/null; then
                echo "❌ YAML validation failed: $file"
                validation_passed=false
            else
                echo "✅ YAML valid: $file"
            fi
        else
            # Fallback to Python YAML validation
            if ! python -c "import yaml; yaml.safe_load(open('$file'))" 2>/dev/null; then
                echo "❌ YAML syntax error: $file"
                validation_passed=false
            else
                echo "✅ YAML syntax valid: $file"
            fi
        fi
    fi
    
    # JSON validation
    if [[ "$file" == *.json ]]; then
        if ! python -c "import json; json.load(open('$file'))" 2>/dev/null; then
            echo "❌ JSON validation failed: $file"
            validation_passed=false
        else
            echo "✅ JSON valid: $file"
        fi
    fi
    
    # Shell script validation
    if [[ "$file" == *.sh ]]; then
        if command -v shellcheck &> /dev/null; then
            if ! shellcheck "$file"; then
                echo "❌ Shell script validation failed: $file"
                validation_passed=false
            else
                echo "✅ Shell script valid: $file"
            fi
        else
            echo "⚠️  ShellCheck not available for: $file"
        fi
    fi
    
    return $validation_passed
}

# Main validation function
main() {
    echo "🚀 HomelabARR CLI Auto-Validation"
    echo "=================================="
    
    local overall_status=true
    local changed_files
    
    # Get changed files from git
    if git rev-parse --git-dir > /dev/null 2>&1; then
        changed_files=$(git diff --name-only HEAD)
        if [[ -z "$changed_files" ]]; then
            changed_files=$(git diff --name-only --cached)
        fi
    fi
    
    # If no git changes, validate provided files
    if [[ -z "$changed_files" ]] && [[ $# -gt 0 ]]; then
        changed_files="$*"
    fi
    
    if [[ -z "$changed_files" ]]; then
        echo "ℹ️  No changes detected"
        exit 0
    fi
    
    echo "📁 Files to validate:"
    echo "$changed_files" | sed 's/^/  - /'
    echo
    
    # Validate each file
    while IFS= read -r file; do
        if [[ -f "$file" ]]; then
            if ! validate_file "$file"; then
                overall_status=false
            fi
        else
            echo "⚠️  File not found: $file"
        fi
        echo
    done <<< "$changed_files"
    
    # Final status
    if $overall_status; then
        echo "✅ All validations passed!"
        exit 0
    else
        echo "❌ Some validations failed!"
        exit 1
    fi
}

main "$@"
