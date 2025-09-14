---
title: "HomelabARR-CLI : 2025-08-21 RCA: CLAUDE.md File Deletion Incident"
confluence_id: "7930025"
confluence_url: "https://mjashley.atlassian.net/wiki/spaces/DO/pages/7930025"
confluence_space: "DO"
category: "Troubleshooting"
created_date: "2025-08-21"
updated_date: "2025-08-21"
migrated_date: "2025-09-14"
tags: ['frontend', 'media-server', 'august-2025']
---

# 2025-08-21 RCA: CLAUDE.md File Deletion Incident

## Incident Summary

**Date:**August 21, 2025
**Impact:**Critical project documentation (CLAUDE.md) and agent configuration files were accidentally deleted during repository cleanup
**Recovery Time:**~30 minutes
**Data Loss:**None (full recovery from git history and backups)
## Timeline of Events

### 11:30 AM - Initial Problem

- 10,475 pending git changes discovered in VS Code
- Root cause: Problematic backup directory`.claude/Working Backup From 8.19.2025/`with deeply nested files
- Error: "Filename too long" preventing git operations
### 11:35 AM - Cleanup Initiated

- User approved removal of backup directory (zip backup available)
- Repository cleanup reduced changes from 10,475 → 388 → 0
### 11:40 AM - Critical Incident

- **CLAUDE.md accidentally deleted during cleanup**
- User immediately noticed: "Wait we need to get that claude md back immediately"
- File restored from git history (commit 5906579c9)
### 11:45 AM - Protection Implemented

- User requested file protection: "we need to make sure i cant delete or lose those"
- Read-only protection applied to CLAUDE.md and .claude folder using Windows attrib commands
### 12:15 PM - Secondary Issue Discovered

- User discovered agent files were wrong versions
- 18 consolidated agent files had been replaced with old versions
- Proper files restored from user's backup at`c:/Users/micha/OneDrive/Desktop/.Claude Files/`
## Root Cause Analysis

### Primary Causes

- **Overly aggressive cleanup command**- Used`git clean -fd`without proper dry run
- **No pre-cleanup validation**- Didn't verify which files would be affected
- **Missing safety checks**- No confirmation step before deletion
- **Inadequate file protection**- Critical files weren't marked as protected
### Contributing Factors

- Complex nested backup directory structure
- Git filename length limitations on Windows
- Multiple backup versions causing confusion
- No automated backup verification process
## Impact Assessment

### What Went Wrong

- Critical documentation temporarily lost
- Agent configuration files reverted to old versions
- Development workflow interrupted for ~30 minutes
- Trust in automated cleanup processes diminished
### What Went Right

- Immediate user detection of the issue
- Quick recovery from git history
- User had external backups available
- Protection measures implemented immediately
## Lessons Learned

### Technical Lessons

- **Always use dry run first**-`git clean -fdn`before`git clean -fd`
- **Verify file lists**- Review what will be deleted before proceeding
- **Implement file protection**- Mark critical files as read-only
- **Maintain multiple backups**- Git history + external backups saved the day
### Process Improvements

- **Mandatory dry runs**- Never execute destructive commands without preview
- **User confirmation**- Always get explicit approval for file deletions
- **Backup verification**- Confirm backup integrity before cleanup
- **Documentation protection**- Critical files should be protected by default
## Action Items Implemented

### Immediate Actions (Completed)

- ✅ Restored CLAUDE.md from git commit 5906579c9
- ✅ Restored 18 agent files from proper backup
- ✅ Implemented read-only protection on critical files
- ✅ Created file deletion prevention policy
- ✅ Documented incident in Confluence
### File Protection Script Created

```
# Make CLAUDE.md read-only
Set-ItemProperty -Path "CLAUDE.md" -Name IsReadOnly -Value $true
# Protect .claude folder
Get-ChildItem -Path ".claude" -Recurse -File | ForEach-Object {
    Set-ItemProperty -Path $_.FullName -Name IsReadOnly -Value $true
}
```