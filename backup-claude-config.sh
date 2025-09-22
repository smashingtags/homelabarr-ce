#!/bin/bash
# Claude Code Configuration Backup Script
# Created: September 15, 2025
# Purpose: Backup Claude Code config and conversations to OneDrive/Google Drive with version control

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
DATE_ONLY=$(date +"%Y-%m-%d")

# Backup directories
ONEDRIVE_BACKUP="/mnt/c/Users/micha/OneDrive/Backups/Claude-Config"
GDRIVE_BACKUP="/mnt/c/Users/micha/Google Drive/Backups/Claude-Config"

# Source files/directories
WSL_CLAUDE_CONFIG="/home/michael/.claude.json"
WSL_CLAUDE_PROJECTS="/home/michael/.claude/projects"
WIN_CLAUDE_PROJECTS="/mnt/c/Users/micha/.claude/projects"
PROJECT_ENV="$SCRIPT_DIR/.env"

echo "🔧 Claude Code Configuration Backup - $TIMESTAMP"
echo "=================================================="

# Create backup directories
create_backup_dirs() {
    local backup_dir="$1"
    echo "📁 Creating backup directory: $backup_dir"
    mkdir -p "$backup_dir/daily"
    mkdir -p "$backup_dir/configs"
    mkdir -p "$backup_dir/conversations"
    mkdir -p "$backup_dir/env-files"
}

# Backup function
backup_to_location() {
    local backup_root="$1"
    local location_name="$2"

    echo "💾 Backing up to $location_name..."

    create_backup_dirs "$backup_root"

    # Daily timestamped backup (full backup)
    local daily_backup="$backup_root/daily/claude-backup-$TIMESTAMP"
    mkdir -p "$daily_backup"

    # Copy WSL Claude config
    if [ -f "$WSL_CLAUDE_CONFIG" ]; then
        echo "  ✅ Copying WSL Claude config"
        cp "$WSL_CLAUDE_CONFIG" "$daily_backup/claude-config-wsl.json"
        # Also keep latest in configs folder
        cp "$WSL_CLAUDE_CONFIG" "$backup_root/configs/claude-config-wsl-latest.json"
    else
        echo "  ❌ WSL Claude config not found: $WSL_CLAUDE_CONFIG"
    fi

    # Copy WSL conversations (if they exist)
    if [ -d "$WSL_CLAUDE_PROJECTS" ]; then
        echo "  ✅ Copying WSL conversations"
        cp -r "$WSL_CLAUDE_PROJECTS" "$daily_backup/wsl-conversations"
        # Sync latest to conversations folder
        rsync -av --delete "$WSL_CLAUDE_PROJECTS/" "$backup_root/conversations/wsl-latest/"
    else
        echo "  ⚠️  WSL conversations not found: $WSL_CLAUDE_PROJECTS"
    fi

    # Copy Windows conversations (if accessible)
    if [ -d "$WIN_CLAUDE_PROJECTS" ]; then
        echo "  ✅ Copying Windows conversations"
        cp -r "$WIN_CLAUDE_PROJECTS" "$daily_backup/win-conversations"
        # Sync latest to conversations folder
        rsync -av --delete "$WIN_CLAUDE_PROJECTS/" "$backup_root/conversations/win-latest/"
    else
        echo "  ⚠️  Windows conversations not accessible: $WIN_CLAUDE_PROJECTS"
    fi

    # Copy project .env file
    if [ -f "$PROJECT_ENV" ]; then
        echo "  ✅ Copying project .env file"
        cp "$PROJECT_ENV" "$daily_backup/project-env"
        cp "$PROJECT_ENV" "$backup_root/env-files/env-latest"
    else
        echo "  ⚠️  Project .env not found: $PROJECT_ENV"
    fi

    # Create a backup manifest
    cat > "$daily_backup/BACKUP_MANIFEST.txt" << EOF
Claude Code Configuration Backup
================================
Timestamp: $TIMESTAMP
Backup Location: $location_name
Script Location: $SCRIPT_DIR

Files Backed Up:
- WSL Claude Config: $WSL_CLAUDE_CONFIG
- WSL Conversations: $WSL_CLAUDE_PROJECTS
- Windows Conversations: $WIN_CLAUDE_PROJECTS
- Project Environment: $PROJECT_ENV

MCP Servers (Global Configuration):
- MCP_DOCKER: Docker Desktop MCP toolkit
- Jam: Bug analysis (https://mcp.jam.dev/mcp)
- shadcn: UI components (https://www.shadcn.io/api/mcp)
- n8n-mcp: Workflow automation (Docker container)
- discord: Server management (http://127.0.0.1:8099/mcp)

Restore Instructions:
1. Copy claude-config-wsl.json to /home/michael/.claude.json
2. Copy project-env to your project directory as .env
3. Restart Claude Code
4. All MCP tools should be available globally

Notes:
- All MCP servers now configured globally (no project-specific configs)
- LinkedIn MCP completely removed (was causing conflicts)
- Configuration works across all projects and machines
EOF

    echo "  ✅ Created backup manifest"
    echo "  📝 Backup completed: $daily_backup"
}

# Cleanup old backups (keep last 30 days)
cleanup_old_backups() {
    local backup_dir="$1"
    if [ -d "$backup_dir/daily" ]; then
        echo "🧹 Cleaning up old backups (keeping last 30 days)..."
        find "$backup_dir/daily" -type d -name "claude-backup-*" -mtime +30 -exec rm -rf {} + 2>/dev/null || true
    fi
}

# Main backup process
main() {
    echo "🚀 Starting Claude Code backup process..."

    # Backup to OneDrive if available
    if [ -d "/mnt/c/Users/micha/OneDrive" ]; then
        backup_to_location "$ONEDRIVE_BACKUP" "OneDrive"
        cleanup_old_backups "$ONEDRIVE_BACKUP"
    else
        echo "⚠️  OneDrive not found, skipping..."
    fi

    # Backup to Google Drive if available
    if [ -d "/mnt/c/Users/micha/Google Drive" ]; then
        backup_to_location "$GDRIVE_BACKUP" "Google Drive"
        cleanup_old_backups "$GDRIVE_BACKUP"
    else
        echo "⚠️  Google Drive not found, skipping..."
    fi

    echo ""
    echo "✅ Backup process completed successfully!"
    echo "📊 Summary:"
    echo "   - Configuration files backed up with timestamp"
    echo "   - Latest configs available in /configs folders"
    echo "   - Conversations synced to /conversations folders"
    echo "   - Environment files saved to /env-files folders"
    echo "   - Old backups (30+ days) automatically cleaned up"
    echo ""
    echo "🔄 To restore: Copy claude-config-wsl-latest.json to /home/michael/.claude.json"
}

# Run the backup
main

echo "💡 Tip: Add this script to a cron job or Windows Task Scheduler for automatic backups!"
echo "   Example cron (daily at 2 AM): 0 2 * * * $SCRIPT_DIR/backup-claude-config.sh"