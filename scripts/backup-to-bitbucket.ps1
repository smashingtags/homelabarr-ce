# HomelabARR CLI - Automated Bitbucket Backup (PowerShell)
# Runs daily to keep Bitbucket 1-2 days behind GitHub

$ErrorActionPreference = "Stop"

# Change to project directory
Set-Location "F:\Coding Projects\homelabarr-cli"

Write-Host "HomelabARR Bitbucket Backup - $(Get-Date)" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

# Fetch latest from GitHub
Write-Host "Fetching latest from GitHub..." -ForegroundColor Yellow
git fetch origin 2>&1

# Check if there are new commits
$commitsBehind = git rev-list --count bitbucket/main..origin/main 2>$null
if ($commitsBehind -eq 0) {
    Write-Host "Bitbucket is up to date with GitHub" -ForegroundColor Green
    exit 0
}

Write-Host "Bitbucket is $commitsBehind commits behind GitHub" -ForegroundColor Yellow

# Only backup if GitHub is at least 2 days ahead (check commit dates)
$latestGitHub = git log origin/main -1 --format="%ci" 2>$null
$latestBitbucket = git log bitbucket/main -1 --format="%ci" 2>$null

if ($latestGitHub -and $latestBitbucket) {
    $githubDate = [DateTime]::Parse($latestGitHub)
    $bitbucketDate = [DateTime]::Parse($latestBitbucket)
    $daysBehind = ($githubDate - $bitbucketDate).Days
    
    if ($daysBehind -lt 1) {
        Write-Host "Skipping backup - only $daysBehind days behind (waiting for 1-2 days)" -ForegroundColor Yellow
        exit 0
    }
}

# Perform the backup
Write-Host "Pushing to Bitbucket backup..." -ForegroundColor Yellow
git push bitbucket main 2>&1

# Log the backup
$logEntry = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'): Backed up to Bitbucket ($commitsBehind commits)"
Add-Content -Path ".git\backup.log" -Value $logEntry

Write-Host "Backup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Backup status:" -ForegroundColor Green
$githubLatest = git log origin/main -1 --format='%h %s' 2>$null
$bitbucketLatest = git log bitbucket/main -1 --format='%h %s' 2>$null
Write-Host "GitHub (origin):    $githubLatest" -ForegroundColor Cyan
Write-Host "Bitbucket (backup): $bitbucketLatest" -ForegroundColor Cyan