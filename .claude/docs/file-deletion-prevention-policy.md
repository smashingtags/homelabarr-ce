# File Deletion Prevention Policy

## MANDATORY: Pre-Deletion Dry Run Process

### Before ANY file deletion operation:

1. **Generate Deletion Preview**
```bash
# ALWAYS run this first
git clean -fdn > deletion-preview.md
echo "Files to be deleted:" >> deletion-preview.md
find . -name "pattern" >> deletion-preview.md
```

2. **Review with User**
- Show deletion-preview.md contents
- Get explicit approval for EACH directory/file type
- Document approval in chat

3. **Backup Critical Files**
```bash
# Before any cleanup
cp CLAUDE.md CLAUDE.md.backup.$(date +%Y%m%d_%H%M%S)
tar -czf .claude-backup-$(date +%Y%m%d_%H%M%S).tar.gz .claude/
```

4. **Staged Deletion**
- Delete in small batches
- Verify after each batch
- Keep running git status

## Protection Rules

### NEVER DELETE WITHOUT PREVIEW:
- CLAUDE.md
- .claude/ directory
- package.json files
- .env files
- Configuration files

### ALWAYS USE DRY RUN FLAGS:
- `git clean -fdn` (n = dry run)
- `rm -i` (interactive confirmation)
- `find -exec echo {}` before `find -exec rm {}`

## Recovery Checklist

If files are accidentally deleted:
1. Check git history: `git log --oneline --follow FILENAME`
2. Check external backups
3. Check git stash: `git stash list`
4. Check git reflog: `git reflog`
5. Check filesystem trash/recycle bin

## Lessons Learned

1. **Dry runs are NOT optional** - They prevent disasters
2. **Show, don't just do** - User should see what will happen
3. **Verify restorations** - Check content, not just file existence
4. **Recent backups first** - Check user's backups before old git commits
5. **Incremental changes** - Small, reversible steps

## Implementation

Add to .claude/scripts/safe-cleanup.sh:
```bash
#!/bin/bash
# Safe cleanup with mandatory dry run

echo "🔍 Analyzing files for cleanup..."
git clean -fdn > cleanup-preview.md
echo "" >> cleanup-preview.md
echo "Total files to be deleted: $(git clean -fdn | wc -l)" >> cleanup-preview.md

echo "📋 Preview saved to cleanup-preview.md"
echo "Review the file and run with --confirm to proceed"

if [[ "$1" == "--confirm" ]]; then
    echo "⚠️  Proceeding with deletion..."
    git clean -fd
else
    echo "ℹ️  No files deleted. Review cleanup-preview.md first."
fi
```