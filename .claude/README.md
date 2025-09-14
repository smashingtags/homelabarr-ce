# .claude Directory Structure

This directory contains resources for managing and maintaining the HomelabARR CLI project.

## 📁 Directory Structure (Updated August 2025)

```
.claude/
├── README.md                     # This file - directory overview
├── MODERNIZATION_CHECKLIST.md   # Current modernization progress tracker
├── REPOSITORY_UPDATE_COMPLETE.md # Major cleanup completion report
├── analysis/                    # Analysis reports and findings
├── backups/                     # Backup configurations and restore scripts
├── configs/                     # Template configurations and examples
├── docs/                        # Generated documentation and guides
├── scripts/                     # Active maintenance tools (7 files)
├── development-scripts/         # Development utilities (44 files)
└── development-backups/         # Development artifacts and test results (44 items)
```

## 📋 Current Files (Post-Cleanup)

### Active Tracking
- **MODERNIZATION_CHECKLIST.md**: Comprehensive checklist tracking the upgrade from legacy versions to modern container stack
- **REPOSITORY_UPDATE_COMPLETE.md**: Documentation of the major repository cleanup and organization effort

### Maintenance Tools (7 active scripts)
- **scripts/clean-yaml-files.sh**: YAML standardization and cleanup utility
- **scripts/fix-discord-links.sh**: Discord link updates across codebase
- **scripts/update-repository-urls.sh**: Repository URL migration tool
- **scripts/repository-maintenance/**: Additional maintenance utilities

### Development Resources (44+ files organized)
- **development-scripts/**: Historical development tools and utilities
- **development-backups/**: Test results, error reports, and development artifacts

## 🔧 Active Directory Contents

### `/scripts/` (Active Maintenance Tools)
- **clean-yaml-files.sh**: ✅ YAML standardization and cleanup utility
- **fix-discord-links.sh**: ✅ Discord link updates across codebase  
- **update-repository-urls.sh**: ✅ Repository URL migration tool
- **repository-maintenance/**: Additional maintenance utilities

### `/development-scripts/` (Development Utilities - 44 files)
- **deploy-local*.sh**: Local deployment testing tools
- **yaml-*.sh**: YAML processing and validation utilities
- **port-*.sh**: Port conflict resolution tools
- **migrate-*.sh**: Container migration utilities
- **test-*.sh**: Testing and validation scripts

### `/development-backups/` (Development Artifacts - 44 items)
- **test-results/**: Comprehensive testing reports and analysis
- **error-reports/**: Application-specific error analysis
- **backup-configurations/**: Development configuration snapshots
- **quick-backups/**: Rapid backup procedures and results

### `/analysis/` (Project Analysis)
- **dependency_matrix.md**: Version compatibility matrix for all services
- **security_audit.md**: Security review findings and recommendations  
- **performance_analysis.md**: Container resource usage and optimization opportunities
- **image_inventory.json**: Complete inventory of all Docker images and versions

### `/configs/`
- **traefik_v3_templates/**: Modern Traefik v3 configuration templates
- **authelia_v4_config/**: Updated Authelia v4.39+ configurations  
- **compose_templates/**: Standardized Docker Compose templates
- **security_defaults/**: Recommended security configurations

### `/docs/`
- **migration_guide.md**: Step-by-step migration guide from current to target state
- **troubleshooting.md**: Common issues and solutions during modernization
- **version_notes.md**: Breaking changes and considerations for each version update
- **best_practices.md**: Container and infrastructure best practices

### `/backups/`
- **pre_migration_backup/**: Full configuration backup before starting changes
- **checkpoint_backups/**: Incremental backups at major milestones
- **rollback_scripts/**: Scripts to quickly revert changes if needed

## 🎯 Usage Guidelines

### For AI Assistants
- **Always update MODERNIZATION_CHECKLIST.md** when completing tasks
- **Use organized tools** from `/scripts/` for maintenance operations
- **Create analysis reports** before making major changes
- **Backup configurations** before modifications
- **Document all decisions** and reasoning in appropriate files
- **Preserve development work** in appropriate subdirectories

### For Human Users
- **Check MODERNIZATION_CHECKLIST.md** for current status
- **Use maintenance tools** from `.claude/scripts/` directory
- **Review analysis reports** before approving changes
- **Access development utilities** from `.claude/development-scripts/` if needed
- **Reference docs/** for understanding changes
- **Check REPOSITORY_UPDATE_COMPLETE.md** for cleanup details

## 🚀 Quick Commands (Updated Tools)

```bash
# View current modernization status
cat .claude/MODERNIZATION_CHECKLIST.md

# View repository cleanup summary
cat .claude/REPOSITORY_UPDATE_COMPLETE.md

# Use organized maintenance tools
.claude/scripts/clean-yaml-files.sh              # YAML standardization
.claude/scripts/fix-discord-links.sh             # Discord link updates
.claude/scripts/update-repository-urls.sh        # Repository URL updates

# Create backup before major changes  
cp -r apps/ .claude/backups/apps_$(date +%Y%m%d)/
cp -r traefik/templates/ .claude/backups/traefik_$(date +%Y%m%d)/

# Check for :latest tags that should be pinned
grep -r ":latest" apps/ | grep -v "# allow-latest"

# Access development tools if needed
ls .claude/development-scripts/                   # Available development utilities
```

## 📈 Cleanup Results (August 2025)

### Major Reorganization Completed
- **863 files organized** into structured maintenance workflow
- **44 development scripts** moved to `development-scripts/`
- **44 development backups** organized in `development-backups/`
- **862 temporary files removed** from main repository
- **29,785 lines** of temporary content cleaned
- **Zero functional changes** - all features preserved

### Professional Benefits
- **Clean repository structure** for better contributor onboarding
- **Organized maintenance tools** in accessible location
- **Preserved development history** while removing clutter
- **Enhanced project presentation** and professional appearance

## 📝 Maintenance Notes

- **Update this README** when adding new directories or files
- **Archive completed checklists** to `/analysis/historical/`
- **Keep scripts executable** with proper shebang lines
- **Use consistent naming** conventions across all files
- **Maintain separation** between active tools and development archives
- **Document major changes** in tracking files

---
**Created**: 2025-08-14  
**Major Cleanup**: 2025-08-16  
**Last Updated**: 2025-08-16
