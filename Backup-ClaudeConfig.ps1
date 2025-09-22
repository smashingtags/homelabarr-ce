# Claude Code Configuration Backup Script (PowerShell)
# Created: September 15, 2025
# Purpose: Automated backup of Claude Code configuration and conversations to cloud storage
# Author: AI Assistant with Context7 research integration
# Version: 2.0

#Requires -Version 5.1

[CmdletBinding()]
param(
    [switch]$Silent = $false,
    [switch]$InstallScheduler = $false,
    [switch]$RemoveScheduler = $false,
    [string]$ScheduleFrequency = "Daily",
    [string]$ScheduleTime = "02:00"
)

# Configuration Constants
$SCRIPT_VERSION = "2.0"
$BACKUP_RETENTION_DAYS = 30
$TIMESTAMP = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$DATE_ONLY = Get-Date -Format "yyyy-MM-dd"

# Backup Locations
$GOOGLE_DRIVE_BACKUP = "G:\My Drive\claude-code-backups"
$ONEDRIVE_BACKUP = "C:\Users\micha\OneDrive\Documents\claude-code-backups"

# Source Paths
$WSL_CLAUDE_CONFIG = "\\wsl.localhost\Ubuntu\home\michael\.claude.json"
$WSL_CLAUDE_PROJECTS = "\\wsl.localhost\Ubuntu\home\michael\.claude\projects"
$WIN_CLAUDE_PROJECTS = "$env:USERPROFILE\.claude\projects"
$PROJECT_ENV = "$PSScriptRoot\.env"

# Task Scheduler Configuration
$TASK_NAME = "Claude-Config-Backup"
$TASK_DESCRIPTION = "Automated backup of Claude Code configuration and conversations"
$TASK_AUTHOR = "Claude Code Backup Automation"

# Logging Configuration
$LOG_PATH = "$PSScriptRoot\Logs"
$LOG_FILE = "$LOG_PATH\backup-log-$DATE_ONLY.txt"

# Create logs directory if it doesn't exist
if (-not (Test-Path $LOG_PATH)) {
    New-Item -Path $LOG_PATH -ItemType Directory -Force | Out-Null
}

function Write-Log {
    param(
        [string]$Message,
        [ValidateSet("INFO", "WARN", "ERROR", "SUCCESS")]
        [string]$Level = "INFO",
        [switch]$NoConsole
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"

    # Write to log file
    Add-Content -Path $LOG_FILE -Value $logEntry -Encoding UTF8

    # Write to console unless suppressed or in silent mode
    if (-not $NoConsole -and -not $Silent) {
        switch ($Level) {
            "INFO" { Write-Host $logEntry -ForegroundColor Cyan }
            "WARN" { Write-Host $logEntry -ForegroundColor Yellow }
            "ERROR" { Write-Host $logEntry -ForegroundColor Red }
            "SUCCESS" { Write-Host $logEntry -ForegroundColor Green }
        }
    }
}

function Show-Banner {
    if (-not $Silent) {
        $banner = @"

🔧 Claude Code Configuration Backup v$SCRIPT_VERSION
==================================================
Automated PowerShell backup with modern scheduling
Generated: $TIMESTAMP

"@
        Write-Host $banner -ForegroundColor Magenta
    }
}

function Test-PathAccessible {
    param([string]$Path)

    try {
        if ($Path -like "*wsl.localhost*") {
            # Special handling for WSL paths
            $testResult = Test-Path $Path -ErrorAction Stop
            return $testResult
        } else {
            return Test-Path $Path -ErrorAction Stop
        }
    } catch {
        return $false
    }
}

function New-BackupDirectory {
    param([string]$BackupRoot)

    try {
        $directories = @(
            "$BackupRoot\daily",
            "$BackupRoot\configs",
            "$BackupRoot\conversations",
            "$BackupRoot\env-files",
            "$BackupRoot\logs"
        )

        foreach ($dir in $directories) {
            if (-not (Test-Path $dir)) {
                New-Item -Path $dir -ItemType Directory -Force | Out-Null
            }
        }

        Write-Log "Created backup directory structure: $BackupRoot" -Level SUCCESS
        return $true
    } catch {
        Write-Log "Failed to create backup directory structure: $($_.Exception.Message)" -Level ERROR
        return $false
    }
}

function Copy-WithRobocopy {
    param(
        [string]$Source,
        [string]$Destination,
        [string]$Description,
        [switch]$IsFile
    )

    try {
        if (-not (Test-PathAccessible $Source)) {
            Write-Log "$Description source not found: $Source" -Level WARN
            return $false
        }

        # Ensure destination directory exists
        $destDir = if ($IsFile) { Split-Path $Destination -Parent } else { $Destination }
        if (-not (Test-Path $destDir)) {
            New-Item -Path $destDir -ItemType Directory -Force | Out-Null
        }

        if ($IsFile) {
            # Simple file copy for single files
            Copy-Item -Path $Source -Destination $Destination -Force
            Write-Log "✅ Copied $Description" -Level SUCCESS
        } else {
            # Use Robocopy for directories (more reliable for large datasets)
            $robocopyArgs = @(
                "`"$Source`"",
                "`"$Destination`"",
                "/MIR",     # Mirror directory tree
                "/R:1",     # Retry once on failure
                "/W:1",     # Wait 1 second between retries
                "/NP",      # No progress display
                "/NDL",     # No directory listing
                "/NFL"      # No file listing
            )

            $robocopyCmd = "robocopy.exe $($robocopyArgs -join ' ')"
            $result = Invoke-Expression $robocopyCmd

            # Robocopy exit codes: 0-3 are success, >3 are errors
            if ($LASTEXITCODE -le 3) {
                Write-Log "✅ Synced $Description using Robocopy" -Level SUCCESS
            } else {
                Write-Log "❌ Robocopy failed for $Description (Exit code: $LASTEXITCODE)" -Level ERROR
                return $false
            }
        }
        return $true
    } catch {
        Write-Log "❌ Failed to copy $Description`: $($_.Exception.Message)" -Level ERROR
        return $false
    }
}

function New-BackupManifest {
    param(
        [string]$BackupPath,
        [string]$LocationName
    )

    $manifestPath = "$BackupPath\BACKUP_MANIFEST.txt"
    $manifestContent = @"
Claude Code Configuration Backup
================================
Timestamp: $TIMESTAMP
Backup Version: $SCRIPT_VERSION
Location: $LocationName
Script Path: $PSScriptRoot
PowerShell Version: $($PSVersionTable.PSVersion)
Computer: $env:COMPUTERNAME
User: $env:USERNAME

Source Locations Backed Up:
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

Backup Features:
- Automated PowerShell Task Scheduler integration
- Dual cloud storage (Google Drive + OneDrive)
- 30-day retention with automatic cleanup
- Robocopy-based reliable file synchronization
- Comprehensive logging and error handling
- Modern Windows automation via Task Scheduler

Restore Instructions:
1. Copy claude-config-wsl-latest.json to \\wsl.localhost\Ubuntu\home\michael\.claude.json
2. Copy project-env-latest to your project directory as .env
3. Restart Claude Code
4. All MCP tools should be available globally

Multi-Machine Replication:
1. Copy this entire backup folder to new machine
2. Run: .\Backup-ClaudeConfig.ps1 -InstallScheduler
3. Configuration automatically replicates across machines
4. All MCP tools work immediately in any project folder

Next Scheduled Backup: $(if (Get-ScheduledTask -TaskName $TASK_NAME -ErrorAction SilentlyContinue) {
    (Get-ScheduledTask -TaskName $TASK_NAME | Get-ScheduledTaskInfo).NextRunTime
} else {
    "Not scheduled - run with -InstallScheduler to enable"
})

Generated by: Claude Code Backup Automation v$SCRIPT_VERSION
"@

    try {
        $manifestContent | Out-File -FilePath $manifestPath -Encoding UTF8
        Write-Log "Created backup manifest: $manifestPath" -Level SUCCESS
    } catch {
        Write-Log "Failed to create backup manifest: $($_.Exception.Message)" -Level ERROR
    }
}

function Invoke-BackupToLocation {
    param(
        [string]$BackupRoot,
        [string]$LocationName
    )

    if (-not (Test-Path (Split-Path $BackupRoot -Parent))) {
        Write-Log "⚠️  $LocationName not accessible, skipping..." -Level WARN
        return $false
    }

    Write-Log "💾 Starting backup to $LocationName..." -Level INFO

    # Create backup directory structure
    if (-not (New-BackupDirectory -BackupRoot $BackupRoot)) {
        Write-Log "Failed to create backup structure for $LocationName" -Level ERROR
        return $false
    }

    # Daily timestamped backup
    $dailyBackup = "$BackupRoot\daily\claude-backup-$TIMESTAMP"
    New-Item -Path $dailyBackup -ItemType Directory -Force | Out-Null

    $backupSuccess = $true

    # Backup WSL Claude config
    if (Copy-WithRobocopy -Source $WSL_CLAUDE_CONFIG -Destination "$dailyBackup\claude-config-wsl.json" -Description "WSL Claude config" -IsFile) {
        Copy-Item -Path "$dailyBackup\claude-config-wsl.json" -Destination "$BackupRoot\configs\claude-config-wsl-latest.json" -Force -ErrorAction SilentlyContinue
    } else {
        $backupSuccess = $false
    }

    # Backup WSL conversations
    if (Copy-WithRobocopy -Source $WSL_CLAUDE_PROJECTS -Destination "$dailyBackup\wsl-conversations" -Description "WSL conversations") {
        Copy-WithRobocopy -Source $WSL_CLAUDE_PROJECTS -Destination "$BackupRoot\conversations\wsl-latest" -Description "WSL conversations (latest sync)"
    }

    # Backup Windows conversations
    if (Copy-WithRobocopy -Source $WIN_CLAUDE_PROJECTS -Destination "$dailyBackup\win-conversations" -Description "Windows conversations") {
        Copy-WithRobocopy -Source $WIN_CLAUDE_PROJECTS -Destination "$BackupRoot\conversations\win-latest" -Description "Windows conversations (latest sync)"
    }

    # Backup project .env file
    if (Copy-WithRobocopy -Source $PROJECT_ENV -Destination "$dailyBackup\project-env" -Description "Project .env file" -IsFile) {
        Copy-Item -Path "$dailyBackup\project-env" -Destination "$BackupRoot\env-files\env-latest" -Force -ErrorAction SilentlyContinue
    }

    # Create backup manifest
    New-BackupManifest -BackupPath $dailyBackup -LocationName $LocationName

    # Copy log file to backup
    Copy-Item -Path $LOG_FILE -Destination "$BackupRoot\logs\backup-log-$TIMESTAMP.txt" -Force -ErrorAction SilentlyContinue

    Write-Log "📝 Backup completed: $dailyBackup" -Level SUCCESS
    return $backupSuccess
}

function Remove-OldBackups {
    param([string]$BackupRoot)

    $dailyBackupPath = "$BackupRoot\daily"
    if (-not (Test-Path $dailyBackupPath)) {
        return
    }

    try {
        Write-Log "🧹 Cleaning up old backups (keeping last $BACKUP_RETENTION_DAYS days)..." -Level INFO

        $cutoffDate = (Get-Date).AddDays(-$BACKUP_RETENTION_DAYS)
        $oldBackups = Get-ChildItem -Path $dailyBackupPath -Directory | Where-Object {
            $_.Name -like "claude-backup-*" -and $_.CreationTime -lt $cutoffDate
        }

        $removedCount = 0
        foreach ($backup in $oldBackups) {
            try {
                Remove-Item -Path $backup.FullName -Recurse -Force
                $removedCount++
                Write-Log "Removed old backup: $($backup.Name)" -Level INFO -NoConsole
            } catch {
                Write-Log "Failed to remove old backup $($backup.Name): $($_.Exception.Message)" -Level WARN
            }
        }

        if ($removedCount -gt 0) {
            Write-Log "Cleaned up $removedCount old backup(s)" -Level SUCCESS
        }
    } catch {
        Write-Log "Error during cleanup: $($_.Exception.Message)" -Level ERROR
    }
}

function Install-TaskScheduler {
    param(
        [string]$Frequency = "Daily",
        [string]$Time = "02:00"
    )

    Write-Log "🔧 Installing Task Scheduler automation..." -Level INFO

    try {
        # Check if task already exists
        $existingTask = Get-ScheduledTask -TaskName $TASK_NAME -ErrorAction SilentlyContinue
        if ($existingTask) {
            Write-Log "Task '$TASK_NAME' already exists. Removing and recreating..." -Level INFO
            Unregister-ScheduledTask -TaskName $TASK_NAME -Confirm:$false
        }

        # Create task action
        $scriptPath = $PSCommandPath
        $arguments = "-ExecutionPolicy Bypass -File `"$scriptPath`" -Silent"
        $action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument $arguments

        # Create task trigger based on frequency
        switch ($Frequency.ToLower()) {
            "daily" {
                $trigger = New-ScheduledTaskTrigger -Daily -At $Time
            }
            "weekly" {
                $trigger = New-ScheduledTaskTrigger -Weekly -At $Time -DaysOfWeek Sunday
            }
            "hourly" {
                $trigger = New-ScheduledTaskTrigger -Once -At $Time -RepetitionInterval (New-TimeSpan -Hours 1) -RepetitionDuration (New-TimeSpan -Days 365)
            }
            default {
                $trigger = New-ScheduledTaskTrigger -Daily -At $Time
            }
        }

        # Create task principal (run as current user with highest privileges)
        $principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Highest

        # Create task settings
        $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -RunOnlyIfNetworkAvailable:$false

        # Register the scheduled task
        Register-ScheduledTask -TaskName $TASK_NAME -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Description $TASK_DESCRIPTION -Force

        Write-Log "✅ Task Scheduler backup automation installed successfully!" -Level SUCCESS
        Write-Log "Task Name: $TASK_NAME" -Level INFO
        Write-Log "Schedule: $Frequency at $Time" -Level INFO
        Write-Log "Next Run: $((Get-ScheduledTask -TaskName $TASK_NAME | Get-ScheduledTaskInfo).NextRunTime)" -Level INFO

        return $true
    } catch {
        Write-Log "❌ Failed to install Task Scheduler automation: $($_.Exception.Message)" -Level ERROR
        return $false
    }
}

function Remove-TaskScheduler {
    try {
        $existingTask = Get-ScheduledTask -TaskName $TASK_NAME -ErrorAction SilentlyContinue
        if ($existingTask) {
            Unregister-ScheduledTask -TaskName $TASK_NAME -Confirm:$false
            Write-Log "✅ Task Scheduler automation removed successfully!" -Level SUCCESS
            return $true
        } else {
            Write-Log "No existing task found to remove." -Level INFO
            return $true
        }
    } catch {
        Write-Log "❌ Failed to remove Task Scheduler automation: $($_.Exception.Message)" -Level ERROR
        return $false
    }
}

function Show-Summary {
    param(
        [bool]$GoogleDriveSuccess,
        [bool]$OneDriveSuccess
    )

    if (-not $Silent) {
        Write-Host ""
        Write-Log "📊 Backup Summary:" -Level INFO
        Write-Log "   - Google Drive: $(if ($GoogleDriveSuccess) { '✅ Success' } else { '❌ Failed/Skipped' })" -Level INFO
        Write-Log "   - OneDrive: $(if ($OneDriveSuccess) { '✅ Success' } else { '❌ Failed/Skipped' })" -Level INFO
        Write-Log "   - Configuration files backed up with timestamp" -Level INFO
        Write-Log "   - Latest configs available in /configs folders" -Level INFO
        Write-Log "   - Conversations synced to /conversations folders" -Level INFO
        Write-Log "   - Environment files saved to /env-files folders" -Level INFO
        Write-Log "   - Old backups (30+ days) automatically cleaned up" -Level INFO
        Write-Log "   - Logs saved to: $LOG_FILE" -Level INFO

        $taskInfo = Get-ScheduledTask -TaskName $TASK_NAME -ErrorAction SilentlyContinue
        if ($taskInfo) {
            $nextRun = (Get-ScheduledTaskInfo -TaskName $TASK_NAME).NextRunTime
            Write-Log "   - Next automated backup: $nextRun" -Level INFO
        }

        Write-Host ""
        Write-Log "🔄 To restore: Copy claude-config-wsl-latest.json to \\wsl.localhost\Ubuntu\home\michael\.claude.json" -Level INFO
        Write-Host ""
        Write-Log "💡 Automation Tips:" -Level INFO
        Write-Log "   - Run with -InstallScheduler to enable daily automatic backups" -Level INFO
        Write-Log "   - Run with -RemoveScheduler to disable automatic backups" -Level INFO
        Write-Log "   - Use -ScheduleFrequency Daily|Weekly|Hourly and -ScheduleTime HH:MM for custom scheduling" -Level INFO
        Write-Host ""
    }
}

function Start-BackupProcess {
    Write-Log "🚀 Starting Claude Code backup process..." -Level INFO

    $googleDriveSuccess = $false
    $oneDriveSuccess = $false

    # Backup to Google Drive
    $googleDriveSuccess = Invoke-BackupToLocation -BackupRoot $GOOGLE_DRIVE_BACKUP -LocationName "Google Drive"
    if ($googleDriveSuccess) {
        Remove-OldBackups -BackupRoot $GOOGLE_DRIVE_BACKUP
    }

    # Backup to OneDrive
    $oneDriveSuccess = Invoke-BackupToLocation -BackupRoot $ONEDRIVE_BACKUP -LocationName "OneDrive"
    if ($oneDriveSuccess) {
        Remove-OldBackups -BackupRoot $ONEDRIVE_BACKUP
    }

    if ($googleDriveSuccess -or $oneDriveSuccess) {
        Write-Log "✅ Backup process completed successfully!" -Level SUCCESS
    } else {
        Write-Log "❌ All backup locations failed!" -Level ERROR
        exit 1
    }

    Show-Summary -GoogleDriveSuccess $googleDriveSuccess -OneDriveSuccess $oneDriveSuccess
}

# Main Script Execution
try {
    Show-Banner
    Write-Log "Claude Code Backup Script v$SCRIPT_VERSION started" -Level INFO
    Write-Log "Log file: $LOG_FILE" -Level INFO

    # Handle command line parameters
    if ($InstallScheduler) {
        if (Install-TaskScheduler -Frequency $ScheduleFrequency -Time $ScheduleTime) {
            Write-Log "Automation installed. Running initial backup..." -Level INFO
            Start-BackupProcess
        } else {
            exit 1
        }
    } elseif ($RemoveScheduler) {
        Remove-TaskScheduler
        exit 0
    } else {
        # Regular backup execution
        Start-BackupProcess
    }

    Write-Log "Script execution completed successfully" -Level SUCCESS
} catch {
    Write-Log "Critical error during script execution: $($_.Exception.Message)" -Level ERROR
    Write-Log "Stack trace: $($_.ScriptStackTrace)" -Level ERROR
    exit 1
}