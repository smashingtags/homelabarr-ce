#!/bin/bash

# HomelabARR CLI - Container Configuration Validation Script
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
APPS_DIR="$(dirname "$SCRIPT_DIR")"
LOG_FILE="/tmp/homelabarr-config-validation-$(date +%Y%m%d_%H%M%S).log"
VALIDATION_REPORT="/tmp/homelabarr-validation-report-$(date +%Y%m%d_%H%M%S).json"

# Counters
TOTAL_FILES=0
VALID_FILES=0
WARNING_FILES=0
ERROR_FILES=0

# Required fields for HomelabARR CLI compliance
REQUIRED_FIELDS=(
    "services"
    "networks"
)

REQUIRED_SERVICE_FIELDS=(
    "hostname"
    "container_name"
    "image"
    "restart"
    "networks"
    "labels"
)

REQUIRED_LABELS=(
    "traefik.enable"
    "traefik.docker.network"
    "dockupdater.enable"
)

# Standard ports mapping for port conflict detection
declare -A STANDARD_PORTS=(
    ["plex"]="32400"
    ["radarr"]="7878"
    ["sonarr"]="8989"
    ["lidarr"]="8686"
    ["bazarr"]="6767"
    ["prowlarr"]="9696"
    ["jackett"]="9117"
    ["qbittorrent"]="8080"
    ["sabnzbd"]="8080"
    ["nzbget"]="6789"
    ["tautulli"]="8181"
    ["overseerr"]="5055"
    ["jellyfin"]="8096"
    ["emby"]="8096"
    ["portainer"]="9000"
    ["grafana"]="3000"
    ["prometheus"]="9090"
)

# Initialize validation report
init_report() {
    cat > "$VALIDATION_REPORT" << EOF
{
  "validation_timestamp": "$(date -Iseconds)",
  "script_version": "2.3.0",
  "total_files_scanned": 0,
  "validation_summary": {
    "valid": 0,
    "warnings": 0,
    "errors": 0
  },
  "port_conflicts": [],
  "missing_health_checks": [],
  "deprecated_patterns": [],
  "security_issues": [],
  "files": []
}
EOF
}

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Print colored output
print_status() {
    local status="$1"
    local message="$2"
    case "$status" in
        "SUCCESS") echo -e "${GREEN}✓${NC} $message" ;;
        "WARNING") echo -e "${YELLOW}⚠${NC} $message" ;;
        "ERROR") echo -e "${RED}✗${NC} $message" ;;
        "INFO") echo -e "${BLUE}ℹ${NC} $message" ;;
    esac
}

# Check if required tools are available
check_dependencies() {
    local deps=("yq" "jq")
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            print_status "ERROR" "Required dependency '$dep' not found. Installing..."
            if command -v apt-get &> /dev/null; then
                sudo apt-get update && sudo apt-get install -y "$dep"
            elif command -v yum &> /dev/null; then
                sudo yum install -y "$dep"
            else
                print_status "ERROR" "Cannot install $dep. Please install manually."
                exit 1
            fi
        fi
    done
}

# Validate YAML syntax
validate_yaml_syntax() {
    local file="$1"
    if ! yq eval '.' "$file" > /dev/null 2>&1; then
        return 1
    fi
    return 0
}

# Check required fields
check_required_fields() {
    local file="$1"
    local issues=()
    
    # Check top-level required fields
    for field in "${REQUIRED_FIELDS[@]}"; do
        if ! yq eval "has(\"$field\")" "$file" | grep -q "true"; then
            issues+=("Missing required field: $field")
        fi
    done
    
    # Check service-level fields for first service
    local service_name
    service_name=$(yq eval '.services | keys | .[0]' "$file" 2>/dev/null)
    
    if [[ "$service_name" != "null" && -n "$service_name" ]]; then
        for field in "${REQUIRED_SERVICE_FIELDS[@]}"; do
            if ! yq eval ".services.$service_name | has(\"$field\")" "$file" | grep -q "true"; then
                issues+=("Service '$service_name' missing required field: $field")
            fi
        done
        
        # Check required labels
        for label in "${REQUIRED_LABELS[@]}"; do
            if ! yq eval ".services.$service_name.labels[]?" "$file" 2>/dev/null | grep -q "$label"; then
                issues+=("Service '$service_name' missing required label: $label")
            fi
        done
    fi
    
    printf '%s\n' "${issues[@]}"
}

# Check for health checks
check_health_checks() {
    local file="$1"
    local service_name
    service_name=$(yq eval '.services | keys | .[0]' "$file" 2>/dev/null)
    
    if [[ "$service_name" != "null" && -n "$service_name" ]]; then
        if ! yq eval ".services.$service_name | has(\"healthcheck\")" "$file" | grep -q "true"; then
            echo "Missing health check for service: $service_name"
        fi
    fi
}

# Check resource limits
check_resource_limits() {
    local file="$1"
    local issues=()
    local service_name
    service_name=$(yq eval '.services | keys | .[0]' "$file" 2>/dev/null)
    
    if [[ "$service_name" != "null" && -n "$service_name" ]]; then
        # Check for resource limits
        if ! yq eval ".services.$service_name.deploy.resources.limits" "$file" 2>/dev/null | grep -q -v "null"; then
            issues+=("Service '$service_name' missing resource limits")
        fi
        
        # Check for memory reservations
        if ! yq eval ".services.$service_name.deploy.resources.reservations" "$file" 2>/dev/null | grep -q -v "null"; then
            issues+=("Service '$service_name' missing resource reservations")
        fi
    fi
    
    printf '%s\n' "${issues[@]}"
}

# Extract port information
extract_ports() {
    local file="$1"
    local service_name
    service_name=$(yq eval '.services | keys | .[0]' "$file" 2>/dev/null)
    
    if [[ "$service_name" != "null" && -n "$service_name" ]]; then
        # Extract exposed ports
        yq eval ".services.$service_name.ports[]?" "$file" 2>/dev/null | sed 's/:.*//' || true
        
        # Extract Traefik service port
        yq eval ".services.$service_name.labels[]?" "$file" 2>/dev/null | \
            grep "traefik.http.services.*\.server\.port" | \
            sed 's/.*=//' || true
    fi
}

# Check for deprecated patterns
check_deprecated_patterns() {
    local file="$1"
    local issues=()
    
    # Check for old Traefik v1 labels
    if grep -q "traefik.frontend" "$file" 2>/dev/null; then
        issues+=("Using deprecated Traefik v1 frontend labels")
    fi
    
    # Check for old image tags
    if grep -q ":latest" "$file" 2>/dev/null; then
        issues+=("Using ':latest' tag (should be pinned)")
    fi
    
    # Check for privileged containers
    if yq eval '.services[].privileged' "$file" 2>/dev/null | grep -q "true"; then
        issues+=("Using privileged container (security risk)")
    fi
    
    printf '%s\n' "${issues[@]}"
}

# Check security configurations
check_security() {
    local file="$1"
    local issues=()
    local service_name
    service_name=$(yq eval '.services | keys | .[0]' "$file" 2>/dev/null)
    
    if [[ "$service_name" != "null" && -n "$service_name" ]]; then
        # Check for security_opt
        if ! yq eval ".services.$service_name | has(\"security_opt\")" "$file" | grep -q "true"; then
            issues+=("Service '$service_name' missing security_opt configuration")
        fi
        
        # Check for user mapping
        local has_puid=false
        local has_pgid=false
        
        while IFS= read -r env_var; do
            if [[ "$env_var" == *"PUID"* ]]; then
                has_puid=true
            elif [[ "$env_var" == *"PGID"* ]]; then
                has_pgid=true
            fi
        done < <(yq eval ".services.$service_name.environment[]?" "$file" 2>/dev/null || true)
        
        if ! $has_puid; then
            issues+=("Service '$service_name' missing PUID environment variable")
        fi
        
        if ! $has_pgid; then
            issues+=("Service '$service_name' missing PGID environment variable")
        fi
    fi
    
    printf '%s\n' "${issues[@]}"
}

# Validate single file
validate_file() {
    local file="$1"
    local filename
    filename=$(basename "$file")
    local file_errors=()
    local file_warnings=()
    
    log "Validating: $file"
    
    # Skip non-YAML files
    if [[ ! "$file" =~ \.(yml|yaml)$ ]]; then
        return 0
    fi
    
    # Increment total files counter
    ((TOTAL_FILES++))
    
    # Validate YAML syntax
    if ! validate_yaml_syntax "$file"; then
        file_errors+=("Invalid YAML syntax")
        ((ERROR_FILES++))
        print_status "ERROR" "$filename: Invalid YAML syntax"
        return 1
    fi
    
    # Check required fields
    mapfile -t missing_fields < <(check_required_fields "$file")
    if [[ ${#missing_fields[@]} -gt 0 ]]; then
        file_errors+=("${missing_fields[@]}")
    fi
    
    # Check health checks
    mapfile -t health_issues < <(check_health_checks "$file")
    if [[ ${#health_issues[@]} -gt 0 ]]; then
        file_warnings+=("${health_issues[@]}")
    fi
    
    # Check resource limits
    mapfile -t resource_issues < <(check_resource_limits "$file")
    if [[ ${#resource_issues[@]} -gt 0 ]]; then
        file_warnings+=("${resource_issues[@]}")
    fi
    
    # Check deprecated patterns
    mapfile -t deprecated_issues < <(check_deprecated_patterns "$file")
    if [[ ${#deprecated_issues[@]} -gt 0 ]]; then
        file_warnings+=("${deprecated_issues[@]}")
    fi
    
    # Check security configurations
    mapfile -t security_issues < <(check_security "$file")
    if [[ ${#security_issues[@]} -gt 0 ]]; then
        file_warnings+=("${security_issues[@]}")
    fi
    
    # Determine file status
    local status="valid"
    if [[ ${#file_errors[@]} -gt 0 ]]; then
        status="error"
        ((ERROR_FILES++))
        print_status "ERROR" "$filename: ${#file_errors[@]} errors"
    elif [[ ${#file_warnings[@]} -gt 0 ]]; then
        status="warning"
        ((WARNING_FILES++))
        print_status "WARNING" "$filename: ${#file_warnings[@]} warnings"
    else
        ((VALID_FILES++))
        print_status "SUCCESS" "$filename: Valid"
    fi
    
    # Add to report
    local file_report=$(jq -n \
        --arg file "$file" \
        --arg filename "$filename" \
        --arg status "$status" \
        --argjson errors "$(printf '%s\n' "${file_errors[@]}" | jq -R -s 'split("\n")[:-1]')" \
        --argjson warnings "$(printf '%s\n' "${file_warnings[@]}" | jq -R -s 'split("\n")[:-1]')" \
        '{
            file: $file,
            filename: $filename,
            status: $status,
            errors: $errors,
            warnings: $warnings
        }')
    
    # Update report
    jq --argjson file_data "$file_report" '.files += [$file_data]' "$VALIDATION_REPORT" > "${VALIDATION_REPORT}.tmp" && mv "${VALIDATION_REPORT}.tmp" "$VALIDATION_REPORT"
}

# Detect port conflicts across all files
detect_port_conflicts() {
    local port_usage=()
    declare -A port_files
    
    print_status "INFO" "Scanning for port conflicts..."
    
    # Scan all YAML files for port usage
    while IFS= read -r -d '' file; do
        mapfile -t ports < <(extract_ports "$file")
        for port in "${ports[@]}"; do
            if [[ -n "$port" && "$port" =~ ^[0-9]+$ ]]; then
                if [[ -n "${port_files[$port]:-}" ]]; then
                    port_files[$port]="${port_files[$port]}, $(basename "$file")"
                else
                    port_files[$port]="$(basename "$file")"
                fi
            fi
        done
    done < <(find "$APPS_DIR" -name "*.yml" -o -name "*.yaml" | grep -v ".config" | sort -z)
    
    # Find conflicts
    local conflicts=()
    for port in "${!port_files[@]}"; do
        local file_count
        file_count=$(echo "${port_files[$port]}" | tr ',' '\n' | wc -l)
        if [[ $file_count -gt 1 ]]; then
            conflicts+=("{\"port\": \"$port\", \"files\": \"${port_files[$port]}\"}")
        fi
    done
    
    # Update report with conflicts
    if [[ ${#conflicts[@]} -gt 0 ]]; then
        local conflicts_json
        conflicts_json=$(printf '%s\n' "${conflicts[@]}" | jq -s '.')
        jq --argjson conflicts "$conflicts_json" '.port_conflicts = $conflicts' "$VALIDATION_REPORT" > "${VALIDATION_REPORT}.tmp" && mv "${VALIDATION_REPORT}.tmp" "$VALIDATION_REPORT"
        
        print_status "WARNING" "Found ${#conflicts[@]} port conflicts"
        for conflict in "${conflicts[@]}"; do
            local port
            local files
            port=$(echo "$conflict" | jq -r '.port')
            files=$(echo "$conflict" | jq -r '.files')
            print_status "WARNING" "Port $port used by: $files"
        done
    else
        print_status "SUCCESS" "No port conflicts detected"
    fi
}

# Generate summary report
generate_summary() {
    # Update final counters in report
    jq \
        --arg total "$TOTAL_FILES" \
        --arg valid "$VALID_FILES" \
        --arg warnings "$WARNING_FILES" \
        --arg errors "$ERROR_FILES" \
        '.total_files_scanned = ($total | tonumber) |
         .validation_summary.valid = ($valid | tonumber) |
         .validation_summary.warnings = ($warnings | tonumber) |
         .validation_summary.errors = ($errors | tonumber)' \
        "$VALIDATION_REPORT" > "${VALIDATION_REPORT}.tmp" && mv "${VALIDATION_REPORT}.tmp" "$VALIDATION_REPORT"
    
    echo
    echo "=============================="
    echo "VALIDATION SUMMARY"
    echo "=============================="
    echo "Total files scanned: $TOTAL_FILES"
    echo "Valid files: $VALID_FILES"
    echo "Files with warnings: $WARNING_FILES"
    echo "Files with errors: $ERROR_FILES"
    echo
    echo "Log file: $LOG_FILE"
    echo "Detailed report: $VALIDATION_REPORT"
    echo
    
    if [[ $ERROR_FILES -gt 0 ]]; then
        print_status "ERROR" "Validation completed with errors"
        return 1
    elif [[ $WARNING_FILES -gt 0 ]]; then
        print_status "WARNING" "Validation completed with warnings"
        return 0
    else
        print_status "SUCCESS" "All configurations valid"
        return 0
    fi
}

# Main validation function
main() {
    echo "HomelabARR CLI - Configuration Validation"
    echo "========================================"
    echo
    
    # Initialize
    check_dependencies
    init_report
    
    log "Starting configuration validation"
    log "Apps directory: $APPS_DIR"
    
    # Find and validate all YAML files
    while IFS= read -r -d '' file; do
        # Skip config directory
        if [[ "$file" == *"/.config/"* ]]; then
            continue
        fi
        validate_file "$file"
    done < <(find "$APPS_DIR" -name "*.yml" -o -name "*.yaml" | sort -z)
    
    # Detect port conflicts
    detect_port_conflicts
    
    # Generate summary
    generate_summary
}

# Handle script arguments
case "${1:-}" in
    --help|-h)
        echo "HomelabARR CLI Configuration Validation Script"
        echo
        echo "Usage: $0 [OPTIONS]"
        echo
        echo "Options:"
        echo "  --help, -h     Show this help message"
        echo "  --version      Show version information"
        echo
        echo "This script validates all Docker Compose YAML files in the HomelabARR CLI"
        echo "repository for compliance with container standards and best practices."
        echo
        echo "Validation includes:"
        echo "  • YAML syntax validation"
        echo "  • Required field verification"
        echo "  • Health check presence"
        echo "  • Resource limit configuration"
        echo "  • Security settings"
        echo "  • Port conflict detection"
        echo "  • Deprecated pattern identification"
        exit 0
        ;;
    --version)
        echo "HomelabARR CLI Configuration Validation Script v2.3.0"
        echo "Part of HL-2: Container Configuration Modernization"
        exit 0
        ;;
    *)
        main
        ;;
esac
