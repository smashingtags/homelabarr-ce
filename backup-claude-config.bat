@echo off
REM Claude Code Configuration Backup Script (Windows)
REM Created: September 15, 2025
REM Purpose: Easy Windows wrapper to run the backup script

echo.
echo 🔧 Claude Code Configuration Backup
echo ==================================

REM Change to the script directory
cd /d "%~dp0"

REM Run the bash script via WSL
echo 💾 Running backup via WSL...
wsl bash ./backup-claude-config.sh

if %errorlevel% equ 0 (
    echo.
    echo ✅ Backup completed successfully!
    echo 📁 Check your OneDrive/Google Drive Backups/Claude-Config folder
) else (
    echo.
    echo ❌ Backup failed with error code %errorlevel%
)

echo.
pause