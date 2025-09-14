# HomelabARR CLI - Setup Bitbucket Backup Scheduled Task
# Run as Administrator to install the scheduled task

param(
    [switch]$Uninstall
)

$taskName = "HomelabARR Bitbucket Backup"
$taskPath = "\HomelabARR\"

if ($Uninstall) {
    Write-Host "Removing scheduled task: $taskName" -ForegroundColor Yellow
    try {
        Unregister-ScheduledTask -TaskName $taskName -TaskPath $taskPath -Confirm:$false -ErrorAction Stop
        Write-Host "✓ Task removed successfully" -ForegroundColor Green
    } catch {
        Write-Host "Task not found or already removed" -ForegroundColor Yellow
    }
    exit 0
}

Write-Host "HomelabARR Bitbucket Backup - Task Scheduler Setup" -ForegroundColor Green
Write-Host "===================================================" -ForegroundColor Green

# Check if running as Administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script requires Administrator privileges!" -ForegroundColor Red
    Write-Host "Please run PowerShell as Administrator and try again." -ForegroundColor Yellow
    exit 1
}

# Check if task already exists
$existingTask = Get-ScheduledTask -TaskName $taskName -TaskPath $taskPath -ErrorAction SilentlyContinue
if ($existingTask) {
    Write-Host "Task already exists. Updating..." -ForegroundColor Yellow
    Unregister-ScheduledTask -TaskName $taskName -TaskPath $taskPath -Confirm:$false
}

# Create the scheduled task
$scriptPath = "F:\Coding Projects\homelabarr-cli\scripts\backup-to-bitbucket.ps1"
$workingDir = "F:\Coding Projects\homelabarr-cli"

# Verify script exists
if (-not (Test-Path $scriptPath)) {
    Write-Host "Error: Backup script not found at $scriptPath" -ForegroundColor Red
    exit 1
}

# Create task action
$action = New-ScheduledTaskAction -Execute "powershell.exe" `
    -Argument "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$scriptPath`"" `
    -WorkingDirectory $workingDir

# Create trigger (daily at 3 AM)
$trigger = New-ScheduledTaskTrigger -Daily -At 3:00AM

# Create settings
$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable `
    -RunOnlyIfNetworkAvailable `
    -ExecutionTimeLimit (New-TimeSpan -Hours 1)

# Create principal (run as current user)
$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Limited

# Register the task
try {
    Register-ScheduledTask -TaskName $taskName -TaskPath $taskPath `
        -Action $action -Trigger $trigger -Settings $settings -Principal $principal `
        -Description "Automated daily backup of HomelabARR CLI to Bitbucket, keeping it 1-2 days behind GitHub as a safety measure" `
        -ErrorAction Stop
    
    Write-Host "✓ Scheduled task created successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Task Details:" -ForegroundColor Cyan
    Write-Host "  Name: $taskPath$taskName" -ForegroundColor White
    Write-Host "  Schedule: Daily at 3:00 AM" -ForegroundColor White
    Write-Host "  Script: $scriptPath" -ForegroundColor White
    Write-Host ""
    Write-Host "To test the backup manually, run:" -ForegroundColor Yellow
    Write-Host "  Start-ScheduledTask -TaskName '$taskName' -TaskPath '$taskPath'" -ForegroundColor White
    Write-Host ""
    Write-Host "To view task status:" -ForegroundColor Yellow
    Write-Host "  Get-ScheduledTask -TaskName '$taskName' -TaskPath '$taskPath'" -ForegroundColor White
    
} catch {
    Write-Host "Error creating scheduled task: $_" -ForegroundColor Red
    exit 1
}