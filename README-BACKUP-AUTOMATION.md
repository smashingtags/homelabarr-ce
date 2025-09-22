# Claude Code Backup Automation

**Version**: 2.0
**Created**: September 15, 2025
**Platform**: Windows 10/11 with PowerShell 5.1+

## 🚀 Quick Start

### Option 1: Easy Setup (Recommended)
1. **Double-click `Setup-ClaudeBackup.bat`**
2. **Choose option 1** for daily automatic backups
3. **Done!** Your Claude Code config will backup automatically every day at 2:00 AM

### Option 2: PowerShell Command Line
```powershell
# Install daily automatic backup
.\Backup-ClaudeConfig.ps1 -InstallScheduler

# Install weekly backup (Sundays at 2 AM)
.\Backup-ClaudeConfig.ps1 -InstallScheduler -ScheduleFrequency Weekly -ScheduleTime "02:00"

# Run one-time backup
.\Backup-ClaudeConfig.ps1
```

## 📦 What Gets Backed Up

### ✅ Configuration Files
- **WSL Claude Config**: `\\wsl.localhost\Ubuntu\home\michael\.claude.json`
- **Project Environment**: `.env` file with MCP API keys
- **Backup Manifests**: Complete restoration instructions

### 💬 Conversation History
- **WSL Conversations**: `\\wsl.localhost\Ubuntu\home\michael\.claude\projects`
- **Windows Conversations**: `C:\Users\micha\.claude\projects`

### 🏗️ MCP Server Configuration
- **Docker Desktop MCP**: Jira, Confluence, GitHub, Obsidian, Notion
- **Standalone Servers**: Jam (bug analysis), shadcn/ui, Discord, n8n-mcp

## 📍 Backup Locations

### 🌐 Google Drive
```
G:\My Drive\claude-code-backups\
├── daily\                    # Timestamped daily backups
├── configs\                  # Latest configuration files
├── conversations\            # Latest conversation sync
├── env-files\               # Latest environment files
└── logs\                    # Backup operation logs
```

### ☁️ OneDrive
```
C:\Users\micha\OneDrive\Documents\claude-code-backups\
├── daily\                    # Timestamped daily backups
├── configs\                  # Latest configuration files
├── conversations\            # Latest conversation sync
├── env-files\               # Latest environment files
└── logs\                    # Backup operation logs
```

## ⚙️ Features & Benefits

### 🔄 Automation Options
- **Daily Backups**: Every day at 2:00 AM (default)
- **Weekly Backups**: Every Sunday at 2:00 AM
- **Hourly Backups**: Every hour (for critical workflows)
- **Custom Scheduling**: Set any time/frequency you want

### 🛡️ Reliability Features
- **Dual Storage**: Both Google Drive and OneDrive for redundancy
- **Robocopy Integration**: Enterprise-grade file synchronization
- **Error Handling**: Comprehensive logging and error recovery
- **Automatic Cleanup**: Removes backups older than 30 days
- **WSL Path Support**: Handles Windows Subsystem for Linux paths correctly

### 📊 Modern Windows Integration
- **Task Scheduler**: Built-in Windows automation (no third-party tools)
- **PowerShell 5.1+**: Uses modern PowerShell features and cmdlets
- **Detailed Logging**: Complete audit trail of all operations
- **Silent Mode**: Runs quietly in background when scheduled

## 🔧 Command Reference

### Installation Commands
```powershell
# Daily backup at 2:00 AM
.\Backup-ClaudeConfig.ps1 -InstallScheduler

# Weekly backup at custom time
.\Backup-ClaudeConfig.ps1 -InstallScheduler -ScheduleFrequency Weekly -ScheduleTime "03:30"

# Hourly backup
.\Backup-ClaudeConfig.ps1 -InstallScheduler -ScheduleFrequency Hourly
```

### Management Commands
```powershell
# Remove automatic backup
.\Backup-ClaudeConfig.ps1 -RemoveScheduler

# Run backup silently (no console output)
.\Backup-ClaudeConfig.ps1 -Silent

# Check scheduled task status
Get-ScheduledTask -TaskName "Claude-Config-Backup"
```

### PowerShell Task Scheduler Integration
```powershell
# View next run time
(Get-ScheduledTask -TaskName "Claude-Config-Backup" | Get-ScheduledTaskInfo).NextRunTime

# View last run result
(Get-ScheduledTask -TaskName "Claude-Config-Backup" | Get-ScheduledTaskInfo).LastTaskResult

# Manually trigger backup
Start-ScheduledTask -TaskName "Claude-Config-Backup"
```

## 🔄 Restoration Process

### Quick Restore (Most Common)
1. **Navigate to latest configs**:
   - Google Drive: `G:\My Drive\claude-code-backups\configs\`
   - OneDrive: `C:\Users\micha\OneDrive\Documents\claude-code-backups\configs\`

2. **Copy configuration**:
   ```bash
   # Copy latest config to WSL
   cp "/mnt/g/My Drive/claude-code-backups/configs/claude-config-wsl-latest.json" "/home/michael/.claude.json"
   ```

3. **Copy environment file**:
   ```bash
   # Copy latest .env to project
   cp "/mnt/g/My Drive/claude-code-backups/env-files/env-latest" "/path/to/your/project/.env"
   ```

4. **Restart Claude Code**

### Full Restore (Complete Recovery)
1. **Choose backup date** from `daily\` folder
2. **Follow restoration instructions** in `BACKUP_MANIFEST.txt`
3. **All MCP servers automatically available** after restart

## 🔍 Troubleshooting

### Common Issues

**❌ "WSL path not accessible"**
- Ensure WSL is running: `wsl --status`
- Verify Ubuntu distribution is installed: `wsl --list`
- Check if `\\wsl.localhost\Ubuntu\` path works in File Explorer

**❌ "Google Drive path not found"**
- Ensure Google Drive is mounted at `G:\`
- Check if `G:\My Drive\` folder exists
- Alternative: Modify `$GOOGLE_DRIVE_BACKUP` path in script

**❌ "Task Scheduler permission denied"**
- Run PowerShell as Administrator
- Use "Run as Administrator" on `Setup-ClaudeBackup.bat`

**❌ "Execution policy error"**
- The scripts automatically use `-ExecutionPolicy Bypass`
- If issues persist: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`

### Viewing Logs
```powershell
# View today's log
Get-Content ".\Logs\backup-log-$(Get-Date -Format 'yyyy-MM-dd').txt"

# Monitor live backup (run in separate window)
Get-Content ".\Logs\backup-log-$(Get-Date -Format 'yyyy-MM-dd').txt" -Wait
```

### Manual Task Scheduler Management
```powershell
# List all Claude backup tasks
Get-ScheduledTask | Where-Object {$_.TaskName -like "*Claude*"}

# View task details
Get-ScheduledTask -TaskName "Claude-Config-Backup" | Format-List *

# Test task manually
Start-ScheduledTask -TaskName "Claude-Config-Backup"
```

## 🏠 Multi-Machine Setup

### Replicating to New Machine
1. **Copy backup folder** from Google Drive or OneDrive
2. **Run setup**: `.\Setup-ClaudeBackup.bat`
3. **Choose option 1** (Daily backup)
4. **Done!** All MCP tools work immediately

### Network Drive Setup (Advanced)
```powershell
# Modify backup paths for network storage
$GOOGLE_DRIVE_BACKUP = "\\network-nas\claude-backups"
$ONEDRIVE_BACKUP = "\\server\shared\claude-backups"
```

## 📈 Advanced Configuration

### Custom Backup Retention
```powershell
# Modify retention period (default: 30 days)
$BACKUP_RETENTION_DAYS = 60  # Keep backups for 60 days
```

### Additional Backup Locations
```powershell
# Add third backup location
$EXTERNAL_BACKUP = "E:\Claude-Backups"
Invoke-BackupToLocation -BackupRoot $EXTERNAL_BACKUP -LocationName "External Drive"
```

### Integration with Power Automate (Optional)
1. **Create Power Automate flow** triggered by file changes in backup folders
2. **Add email notifications** when backups complete
3. **Monitor backup health** via Office 365 integration

## 🎯 Why This Solution?

### ✅ Designed for Your Workflow
- **Researched using REF/Context7**: Modern Windows automation best practices
- **Dual cloud redundancy**: Never lose your configurations again
- **MCP-aware**: Understands your complete MCP server setup
- **WSL compatibility**: Handles Linux paths correctly from Windows

### ✅ Enterprise-Grade Features
- **Robocopy synchronization**: Used by enterprises worldwide
- **Task Scheduler integration**: Native Windows automation
- **Comprehensive logging**: Full audit trail for troubleshooting
- **Error recovery**: Continues backup even if one location fails

### ✅ Zero-Maintenance Operation
- **Set it and forget it**: Runs automatically in background
- **Automatic cleanup**: Manages disk space by removing old backups
- **Self-documenting**: Every backup includes complete restoration instructions
- **Multi-machine ready**: Copy to any Windows machine and it just works

---

## 🤝 Support

**Created by AI Assistant with Context7/REF Research Integration**

This automation solution combines:
- Modern PowerShell scripting techniques
- Windows Task Scheduler best practices
- Enterprise backup strategies
- MCP server configuration management
- Cross-platform file system handling

**Remember**: You never have to run PowerShell scripts manually again - the automation handles everything! 🎉