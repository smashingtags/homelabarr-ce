@echo off
REM Claude Code Backup Automation Setup (Windows)
REM Created: September 15, 2025
REM Purpose: Easy setup wrapper for PowerShell automation

setlocal enabledelayedexpansion

echo.
echo 🔧 Claude Code Backup Automation Setup
echo =====================================
echo.

REM Check if PowerShell is available
powershell -Command "Get-Host" >nul 2>&1
if !errorlevel! neq 0 (
    echo ❌ PowerShell not found or not accessible
    echo Please ensure PowerShell 5.1 or later is installed
    pause
    exit /b 1
)

REM Change to script directory
cd /d "%~dp0"

echo 📋 Available Options:
echo.
echo [1] Install Daily Automatic Backup (2:00 AM)
echo [2] Install Weekly Automatic Backup (Sunday 2:00 AM)
echo [3] Install Hourly Automatic Backup
echo [4] Run One-Time Backup Now
echo [5] Remove Automatic Backup
echo [6] View Current Schedule Status
echo [7] Exit
echo.

set /p choice="Select option (1-7): "

if "%choice%"=="1" goto install_daily
if "%choice%"=="2" goto install_weekly
if "%choice%"=="3" goto install_hourly
if "%choice%"=="4" goto run_backup
if "%choice%"=="5" goto remove_backup
if "%choice%"=="6" goto view_status
if "%choice%"=="7" goto exit
goto invalid_choice

:install_daily
echo.
echo 🕒 Installing Daily Automatic Backup...
echo This will backup your Claude Code config every day at 2:00 AM
echo.
powershell -ExecutionPolicy Bypass -File "Backup-ClaudeConfig.ps1" -InstallScheduler -ScheduleFrequency Daily -ScheduleTime "02:00"
goto end

:install_weekly
echo.
echo 🕒 Installing Weekly Automatic Backup...
echo This will backup your Claude Code config every Sunday at 2:00 AM
echo.
powershell -ExecutionPolicy Bypass -File "Backup-ClaudeConfig.ps1" -InstallScheduler -ScheduleFrequency Weekly -ScheduleTime "02:00"
goto end

:install_hourly
echo.
echo 🕒 Installing Hourly Automatic Backup...
echo This will backup your Claude Code config every hour
echo.
powershell -ExecutionPolicy Bypass -File "Backup-ClaudeConfig.ps1" -InstallScheduler -ScheduleFrequency Hourly -ScheduleTime "00:00"
goto end

:run_backup
echo.
echo 💾 Running One-Time Backup...
echo.
powershell -ExecutionPolicy Bypass -File "Backup-ClaudeConfig.ps1"
goto end

:remove_backup
echo.
echo 🗑️ Removing Automatic Backup...
echo.
powershell -ExecutionPolicy Bypass -File "Backup-ClaudeConfig.ps1" -RemoveScheduler
goto end

:view_status
echo.
echo 📊 Current Backup Status:
echo.
powershell -Command "try { $task = Get-ScheduledTask -TaskName 'Claude-Config-Backup' -ErrorAction Stop; $info = Get-ScheduledTaskInfo -TaskName 'Claude-Config-Backup'; Write-Host '✅ Automatic backup is ENABLED' -ForegroundColor Green; Write-Host 'Task Name:' $task.TaskName; Write-Host 'Description:' $task.Description; Write-Host 'Next Run Time:' $info.NextRunTime; Write-Host 'Last Run Time:' $info.LastRunTime; Write-Host 'Last Task Result:' $info.LastTaskResult } catch { Write-Host '❌ Automatic backup is NOT CONFIGURED' -ForegroundColor Red; Write-Host 'Run option 1, 2, or 3 to enable automatic backups' }"
echo.
pause
goto menu

:invalid_choice
echo.
echo ❌ Invalid choice. Please select 1-7.
echo.
pause
goto menu

:menu
cls
goto start

:start
echo.
echo 🔧 Claude Code Backup Automation Setup
echo =====================================
echo.
goto choice

:end
echo.
echo ✅ Operation completed!
echo.
echo 📁 Your backups are saved to:
echo    - Google Drive: G:\My Drive\claude-code-backups
echo    - OneDrive: C:\Users\micha\OneDrive\Documents\claude-code-backups
echo.
echo 💡 Tips:
echo    - Logs are saved in the Logs\ folder
echo    - Latest configs are always in the configs\ subfolders
echo    - Run this setup again anytime to change your schedule
echo.
pause

:exit
echo.
echo 👋 Thanks for using Claude Code Backup Automation!
echo.