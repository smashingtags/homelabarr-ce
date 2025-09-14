#!/bin/bash

# HomelabARR CLI Mount Script
# Provides cloud storage mounting capabilities

set -e

# Configuration
CONFIG_DIR="/config"
MOUNT_DIR="/mnt"
LOG_FILE="/logs/mount.log"
PID_FILE="/tmp/mount.pid"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] MOUNT: $1" | tee -a "$LOG_FILE"
}

# Check if running with required privileges
check_privileges() {
    if [[ $EUID -eq 0 ]]; then
        log "Running with root privileges"
    else
        log "WARNING: Not running as root - mounting may fail"
    fi
    
    # Check for required capabilities
    if [[ -c /dev/fuse ]]; then
        log "FUSE device available"
    else
        log "ERROR: FUSE device not available - ensure container runs with --privileged or --cap-add SYS_ADMIN"
        exit 1
    fi
}

# Initialize configuration
init_config() {
    local config_file="$CONFIG_DIR/rclone.conf"
    
    if [[ ! -f "$config_file" ]]; then
        log "Creating default rclone configuration"
        mkdir -p "$CONFIG_DIR"
        cat > "$config_file" <<EOF
# Rclone Configuration
# Add your cloud storage configurations here
# Example:
# [gdrive]
# type = drive
# client_id = your_client_id
# client_secret = your_client_secret
# token = your_token

EOF
        log "Configuration template created at $config_file"
    fi
    
    # Create mount directories
    mkdir -p "$MOUNT_DIR"/{local,cloud,union}
    log "Mount directories initialized"
}

# Mount cloud storage
mount_cloud() {
    local remote="$1"
    local mount_point="$MOUNT_DIR/cloud/$remote"
    
    if [[ -z "$remote" ]]; then
        log "ERROR: No remote specified for mounting"
        return 1
    fi
    
    log "Mounting cloud storage: $remote"
    mkdir -p "$mount_point"
    
    # Mount with rclone
    rclone mount "$remote:" "$mount_point" \
        --config "$CONFIG_DIR/rclone.conf" \
        --allow-other \
        --allow-non-empty \
        --dir-cache-time 72h \
        --drive-chunk-size 512M \
        --log-level INFO \
        --log-file "$LOG_FILE" \
        --cache-dir /tmp/rclone \
        --vfs-read-chunk-size 128M \
        --vfs-read-chunk-size-limit off \
        --buffer-size 1G \
        --daemon &
    
    local mount_pid=$!
    echo "$mount_pid" >> "$PID_FILE"
    
    # Wait for mount to be ready
    local timeout=30
    local count=0
    while [[ $count -lt $timeout ]]; do
        if mountpoint -q "$mount_point" 2>/dev/null; then
            log "✓ Cloud storage $remote mounted successfully at $mount_point"
            return 0
        fi
        sleep 1
        ((count++))
    done
    
    log "✗ Failed to mount cloud storage $remote"
    return 1
}

# Create union filesystem
create_union() {
    local union_point="$MOUNT_DIR/union"
    local local_dir="$MOUNT_DIR/local"
    local cloud_dirs=""
    
    # Find all cloud mount points
    for cloud_mount in "$MOUNT_DIR/cloud"/*; do
        if [[ -d "$cloud_mount" ]] && mountpoint -q "$cloud_mount" 2>/dev/null; then
            cloud_dirs="$cloud_dirs:$cloud_mount=RO"
        fi
    done
    
    if [[ -n "$cloud_dirs" ]]; then
        log "Creating union filesystem"
        mkdir -p "$local_dir" "$union_point"
        
        # Create union with mergerfs
        mergerfs "$local_dir$cloud_dirs" "$union_point" \
            -o rw,async_read=false,use_ino,allow_other,func.getattr=newest,category.action=all,category.create=ff &
        
        local union_pid=$!
        echo "$union_pid" >> "$PID_FILE"
        
        # Wait for union to be ready
        local timeout=10
        local count=0
        while [[ $count -lt $timeout ]]; do
            if mountpoint -q "$union_point" 2>/dev/null; then
                log "✓ Union filesystem created at $union_point"
                return 0
            fi
            sleep 1
            ((count++))
        done
        
        log "✗ Failed to create union filesystem"
        return 1
    else
        log "No cloud mounts available for union filesystem"
        return 1
    fi
}

# Unmount all filesystems
unmount_all() {
    log "Unmounting all filesystems..."
    
    # Unmount union first
    if mountpoint -q "$MOUNT_DIR/union" 2>/dev/null; then
        fusermount -u "$MOUNT_DIR/union" 2>/dev/null || umount -l "$MOUNT_DIR/union" 2>/dev/null
        log "Union filesystem unmounted"
    fi
    
    # Unmount cloud storage
    for cloud_mount in "$MOUNT_DIR/cloud"/*; do
        if [[ -d "$cloud_mount" ]] && mountpoint -q "$cloud_mount" 2>/dev/null; then
            fusermount -u "$cloud_mount" 2>/dev/null || umount -l "$cloud_mount" 2>/dev/null
            log "Cloud mount $cloud_mount unmounted"
        fi
    done
    
    # Kill any remaining processes
    if [[ -f "$PID_FILE" ]]; then
        while IFS= read -r pid; do
            if kill -0 "$pid" 2>/dev/null; then
                kill -TERM "$pid" 2>/dev/null || true
            fi
        done < "$PID_FILE"
        rm -f "$PID_FILE"
    fi
    
    log "All filesystems unmounted"
}

# Health check
health_check() {
    local healthy=true
    local status_file="/tmp/mount_status.json"
    
    # Check cloud mounts
    local cloud_mounts=0
    local healthy_mounts=0
    
    for cloud_mount in "$MOUNT_DIR/cloud"/*; do
        if [[ -d "$cloud_mount" ]]; then
            ((cloud_mounts++))
            if mountpoint -q "$cloud_mount" 2>/dev/null; then
                ((healthy_mounts++))
            fi
        fi
    done
    
    # Check union mount
    local union_healthy=false
    if mountpoint -q "$MOUNT_DIR/union" 2>/dev/null; then
        union_healthy=true
    fi
    
    if [[ $healthy_mounts -lt $cloud_mounts ]] || [[ $union_healthy == false ]]; then
        healthy=false
    fi
    
    # Generate status JSON
    cat > "$status_file" <<EOF
{
    "status": "$([ "$healthy" == true ] && echo "healthy" || echo "unhealthy")",
    "timestamp": "$(date -Iseconds)",
    "mounts": {
        "cloud": {
            "total": $cloud_mounts,
            "healthy": $healthy_mounts
        },
        "union": {
            "healthy": $union_healthy
        }
    }
}
EOF
    
    if [[ "$healthy" == true ]]; then
        log "Health check: All mounts healthy"
        return 0
    else
        log "Health check: Some mounts unhealthy"
        return 1
    fi
}

# Simple HTTP server for health endpoint
start_web_server() {
    log "Starting web server on port 5572"
    
    while true; do
        {
            read -r request
            
            if [[ "$request" == *"GET /health"* ]]; then
                health_check
                local health_status=$?
                local status_file="/tmp/mount_status.json"
                
                if [[ $health_status -eq 0 ]]; then
                    echo -e "HTTP/1.1 200 OK\r\nContent-Type: application/json\r\n"
                else
                    echo -e "HTTP/1.1 503 Service Unavailable\r\nContent-Type: application/json\r\n"
                fi
                
                echo -e "\r"
                if [[ -f "$status_file" ]]; then
                    cat "$status_file"
                else
                    echo '{"status":"unknown","timestamp":"'$(date -Iseconds)'"}'
                fi
            elif [[ "$request" == *"GET /status"* ]]; then
                echo -e "HTTP/1.1 200 OK\r\nContent-Type: application/json\r\n\r"
                health_check >/dev/null 2>&1
                cat "/tmp/mount_status.json" 2>/dev/null || echo '{"status":"unknown"}'
            else
                echo -e "HTTP/1.1 404 Not Found\r\nContent-Type: text/plain\r\n\r\n404 Not Found"
            fi
        } | nc -l -p 5572 -q 1
    done
}

# Cleanup function
cleanup() {
    log "Received shutdown signal, cleaning up..."
    unmount_all
    exit 0
}

# Set up signal handlers
trap cleanup SIGTERM SIGINT

# Command line interface
case "${1:-start}" in
    "start")
        log "Starting mount service"
        check_privileges
        init_config
        
        # Mount cloud storage based on configuration
        if [[ -f "$CONFIG_DIR/mount.conf" ]]; then
            while IFS= read -r remote; do
                [[ -z "$remote" || "$remote" == \#* ]] && continue
                mount_cloud "$remote"
            done < "$CONFIG_DIR/mount.conf"
        else
            log "No mount configuration found at $CONFIG_DIR/mount.conf"
            log "Creating example configuration..."
            cat > "$CONFIG_DIR/mount.conf" <<EOF
# Mount Configuration
# List cloud remotes to mount (one per line)
# Example:
# gdrive
# dropbox
# onedrive

EOF
        fi
        
        # Create union filesystem
        create_union
        
        # Start web server
        start_web_server
        ;;
    "stop")
        unmount_all
        ;;
    "health")
        health_check
        ;;
    "status")
        health_check >/dev/null 2>&1
        cat "/tmp/mount_status.json" 2>/dev/null || echo '{"status":"unknown"}'
        ;;
    *)
        echo "Usage: $0 {start|stop|health|status}"
        echo "  start  - Start mount service (default)"
        echo "  stop   - Stop all mounts"
        echo "  health - Check health status"
        echo "  status - Get detailed status"
        exit 1
        ;;
esac
