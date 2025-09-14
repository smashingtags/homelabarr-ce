# Documentation Migration Strategy

**Status**: IN PROGRESS  
**Date**: August 19, 2025

## 📋 Migration Plan

This document tracks the consolidation of 848+ documentation files into a unified structure.

## Phase 1: Structure Creation ✅

Created the following structure:
```
MASTER_DOCUMENTATION/
├── README.md (Hub document)
├── 1_GETTING_STARTED/
├── 2_DEPLOYMENT/
├── 3_ARCHITECTURE/
├── 4_DEVELOPMENT/
├── 5_OPERATIONS/
└── 6_PROJECT_MANAGEMENT/
```

## Phase 2: Content Migration (IN PROGRESS)

### Source Files to Migrate

| Original File | New Location | Status | Notes |
|--------------|--------------|--------|-------|
| README.md | 1_GETTING_STARTED/README.md | Pending | Keep original |
| DEPLOYMENT.md | 2_DEPLOYMENT/COMPLETE_GUIDE.md | ✅ Done | Most comprehensive |
| LOCAL_MODE_README.md | 2_DEPLOYMENT/LOCAL_MODE.md | Pending | |
| HomelabARR_Ecosystem_Complete_Guide.md | 3_ARCHITECTURE/ECOSYSTEM_OVERVIEW.md | Pending | |
| CLAUDE.md | 4_DEVELOPMENT/DEVELOPER_GUIDE.md | Pending | |
| sprint-documentation.md | 6_PROJECT_MANAGEMENT/SPRINT_RESULTS.md | Pending | |
| LINUX_INSTALLATION_SUCCESS_SUMMARY.md | 1_GETTING_STARTED/LINUX_INSTALL.md | Pending | |

### Confluence Pages to Import

| Page Title | Target Location | Status |
|-----------|-----------------|--------|
| HomelabARR Complete Deployment Guide | 2_DEPLOYMENT/ | Pending |
| HomelabARR CLI Monitoring Stack | 2_DEPLOYMENT/MONITORING_STACK.md | Pending |
| Agent Routing Guide | 4_DEVELOPMENT/AGENT_ROUTING.md | Pending |
| Technical Challenges & Solutions | 5_OPERATIONS/CHALLENGES.md | Pending |
| Story Point Estimation | 6_PROJECT_MANAGEMENT/ESTIMATION.md | Pending |

### Jira Tickets to Document

| Ticket | Content | Target | Status |
|--------|---------|--------|--------|
| HL-81 | Docker Image Migration | 6_PROJECT_MANAGEMENT/MIGRATION_STATUS.md | ✅ Done |
| HL-79 | Authentication Hardening | 5_OPERATIONS/SECURITY.md | Pending |
| HL-77 | Production Configuration | 2_DEPLOYMENT/PRODUCTION_CONFIG.md | Pending |
| HL-53 | ARM Support | 3_ARCHITECTURE/ARM_SUPPORT.md | Pending |

## Phase 3: Backup Original Files

### Backup Strategy
```bash
#!/bin/bash
# Create backups before deletion

# Method 1: Add .bk extension
for file in $(find . -name "*.md" -o -name "*.txt"); do
  if [[ ! "$file" == *"MASTER_DOCUMENTATION"* ]]; then
    cp "$file" "$file.bk"
    echo "Backed up: $file"
  fi
done

# Method 2: Create backup directory
mkdir -p DOCUMENTATION_BACKUP_$(date +%Y%m%d)
cp -r wiki/ DOCUMENTATION_BACKUP_*/
cp *.md DOCUMENTATION_BACKUP_*/
cp .claude/local-notes/*.md DOCUMENTATION_BACKUP_*/
```

## Phase 4: Update References

### Files Requiring Updates
- [ ] README.md - Point to new structure
- [ ] Wiki navigation files
- [ ] GitHub Pages config
- [ ] CI/CD documentation references
- [ ] Install scripts with doc links

### Link Mapping
```
Old: wiki/docs/install/install.md
New: MASTER_DOCUMENTATION/2_DEPLOYMENT/PRODUCTION_MODE.md

Old: wiki/docs/install/local-mode.md
New: MASTER_DOCUMENTATION/2_DEPLOYMENT/LOCAL_MODE.md

Old: .claude/local-notes/docker-image-migration-plan.md
New: MASTER_DOCUMENTATION/6_PROJECT_MANAGEMENT/MIGRATION_STATUS.md
```

## Phase 5: Validation

### Checklist
- [ ] All 848 files reviewed
- [ ] No broken links
- [ ] Confluence content imported
- [ ] Jira tickets documented
- [ ] Search/replace completed
- [ ] Navigation tested
- [ ] Backups verified

## Phase 6: Cleanup (DO NOT EXECUTE YET)

### Future Cleanup (After Validation)
```bash
# ONLY after full validation and testing
# Remove .bk files
find . -name "*.bk" -delete

# Archive old structure
tar -czf old_docs_archive.tar.gz wiki/ *.md .claude/local-notes/

# Remove duplicates
# TO BE DETERMINED
```

## 📊 Progress Tracking

| Category | Files | Migrated | Remaining |
|----------|-------|----------|-----------|
| Local .md files | 400+ | 5 | 395+ |
| Local .txt files | 448+ | 0 | 448+ |
| Confluence pages | 18+ | 0 | 18+ |
| Jira tickets | 79 | 3 | 76 |
| **Total** | **945+** | **8** | **937+** |

## ⚠️ Important Notes

1. **DO NOT DELETE** original files until:
   - Software is fully working
   - All documentation is migrated
   - Backups are verified
   - Team approval received

2. **Priority Order**:
   - Critical deployment docs first
   - Troubleshooting guides second
   - Development docs third
   - Historical/archive last

3. **Conflicts to Resolve**:
   - Docker image references (DockServer vs HomelabARR)
   - Repository paths (.claude tracking)
   - Authentication methods (admin/admin vs production)
   - API endpoints (localhost vs configurable)

## 🔄 Next Steps

1. Continue populating sections with content
2. Import Confluence pages
3. Document remaining Jira tickets
4. Create comprehensive index
5. Test all documentation paths
6. Get team review
7. Create final backup
8. Switch to new structure

---

**Tracking**: This migration is tracked in the MASTER_DOCUMENTATION directory while preserving all original files.