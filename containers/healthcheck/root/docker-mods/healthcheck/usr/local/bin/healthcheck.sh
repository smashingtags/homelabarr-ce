#!/bin/bash

# HomelabARR CLI Health Check Script
# Provides standardized health checking for media server applications

set -e

# Configuration
HEALTH_CHECK_PORT="${HEALTH_CHECK_PORT:-8080}"
HEALTH_CHECK_PATH="${HEALTH_CHECK_PATH:-/health}"
HEALTH_CHECK_TIMEOUT="${HEALTH_CHECK_TIMEOUT:-10}"
HEALTH_CHECK_INTERVAL="${HEALTH_CHECK_INTERVAL:-30}"
APP_PORT="${APP_PORT:-8080}"
APP_HEALTH_PATH="${APP_HEALTH_PATH:-/}"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] HEALTHCHECK: $1"
}

# Generic health check function
check_http_endpoint() {
    local url="$1"
    local timeout="${2:-$HEALTH_CHECK_TIMEOUT}"
    
    if curl -f -s --max-time "$timeout" "$url" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Check if process is running
check_process() {
    local process_name="$1"
    if pgrep -f "$process_name" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Check if port is listening
check_port() {
    local port="$1"
    local host="${2:-localhost}"
    
    if nc -z "$host" "$port" 2>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Main health check logic
main_health_check() {
    local app_name="${APP_NAME:-unknown}"
    local health_status="healthy"
    local checks_passed=0
    local total_checks=0
    
    log "Starting health check for $app_name"
    
    # Check 1: Application port accessibility
    ((total_checks++))
    if check_port "$APP_PORT"; then
        log "✓ Port $APP_PORT is accessible"
        ((checks_passed++))
    else
        log "✗ Port $APP_PORT is not accessible"
        health_status="unhealthy"
    fi
    
    # Check 2: HTTP endpoint response
    ((total_checks++))
    if check_http_endpoint "http://localhost:$APP_PORT$APP_HEALTH_PATH"; then
        log "✓ HTTP endpoint responding"
        ((checks_passed++))
    else
        log "✗ HTTP endpoint not responding"
        health_status="unhealthy"
    fi
    
    # Check 3: Configuration files exist (if specified)
    if [[ -n "$CONFIG_PATH" ]]; then
        ((total_checks++))
        if [[ -f "$CONFIG_PATH" ]]; then
            log "✓ Configuration file exists at $CONFIG_PATH"
            ((checks_passed++))
        else
            log "✗ Configuration file missing at $CONFIG_PATH"
            health_status="unhealthy"
        fi
    fi
    
    # Check 4: Data directory accessible (if specified)
    if [[ -n "$DATA_PATH" ]]; then
        ((total_checks++))
        if [[ -d "$DATA_PATH" && -r "$DATA_PATH" ]]; then
            log "✓ Data directory accessible at $DATA_PATH"
            ((checks_passed++))
        else
            log "✗ Data directory not accessible at $DATA_PATH"
            health_status="unhealthy"
        fi
    fi
    
    # Application-specific checks
    case "$app_name" in
        "plex")
            ((total_checks++))
            if check_http_endpoint "http://localhost:$APP_PORT/identity"; then
                log "✓ Plex identity endpoint responding"
                ((checks_passed++))
            else
                log "✗ Plex identity endpoint not responding"
                health_status="unhealthy"
            fi
            ;;
        "radarr"|"sonarr"|"lidarr"|"readarr"|"bazarr")
            ((total_checks++))
            if check_http_endpoint "http://localhost:$APP_PORT/api/system/status" || \
               check_http_endpoint "http://localhost:$APP_PORT/ping"; then
                log "✓ Servarr API responding"
                ((checks_passed++))
            else
                log "✗ Servarr API not responding"
                health_status="unhealthy"
            fi
            ;;
        "qbittorrent")
            ((total_checks++))
            if check_http_endpoint "http://localhost:$APP_PORT/api/v2/app/version"; then
                log "✓ qBittorrent API responding"
                ((checks_passed++))
            else
                log "✗ qBittorrent API not responding"
                health_status="unhealthy"
            fi
            ;;
        "sabnzbd")
            ((total_checks++))
            if check_http_endpoint "http://localhost:$APP_PORT/api?mode=version"; then
                log "✓ SABnzbd API responding"
                ((checks_passed++))
            else
                log "✗ SABnzbd API not responding"
                health_status="unhealthy"
            fi
            ;;
        "jellyfin"|"emby")
            ((total_checks++))
            if check_http_endpoint "http://localhost:$APP_PORT/System/Info/Public"; then
                log "✓ Media server API responding"
                ((checks_passed++))
            else
                log "✗ Media server API not responding"
                health_status="unhealthy"
            fi
            ;;
    esac
    
    # Final health assessment
    log "Health check completed: $checks_passed/$total_checks checks passed"
    
    if [[ "$health_status" == "healthy" ]]; then
        log "✓ Application is healthy"
        exit 0
    else
        log "✗ Application is unhealthy"
        exit 1
    fi
}

# Simple HTTP server for health endpoint
start_health_server() {
    log "Starting health check server on port $HEALTH_CHECK_PORT"
    
    while true; do
        echo -e "HTTP/1.1 200 OK\r\nContent-Type: application/json\r\n\r\n{\"status\":\"healthy\",\"timestamp\":\"$(date -Iseconds)\"}" | nc -l -p "$HEALTH_CHECK_PORT" -q 1
    done
}

# Command line interface
case "${1:-check}" in
    "check")
        main_health_check
        ;;
    "server")
        start_health_server
        ;;
    "test")
        log "Testing health check functionality"
        APP_NAME="test" APP_PORT="80" main_health_check
        ;;
    *)
        echo "Usage: $0 {check|server|test}"
        echo "  check  - Run health check (default)"
        echo "  server - Start health check HTTP server"
        echo "  test   - Run test health check"
        exit 1
        ;;
esac
