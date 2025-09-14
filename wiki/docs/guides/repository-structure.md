# Repository Structure Guide

This guide documents the organized structure of the HomelabARR CLI repository and explains where to find maintenance tools, development resources, and project components.

## 🏗️ Repository Organization

Following our comprehensive cleanup and organization effort (August 2025), the repository now follows a clear, professional structure that separates user-facing components from maintenance and development tools.

## 📁 Core Directory Structure

### User-Facing Components

```
homelabarr-cli/
├── apps/                    # Docker Compose applications (489+ files)
│   ├── mediaserver/        # Plex, Jellyfin, Emby
│   ├── mediamanager/       # Radarr, Sonarr, Lidarr, Bazarr
│   ├── downloadclients/    # qBittorrent, SABnzbd, NZBGet
│   ├── request/            # Overseerr, Petio
│   ├── addons/             # Monitoring, dashboards
│   ├── backup/             # Duplicati, Restic
│   └── selfhosted/         # Various self-hosted apps
├── traefik/                # Reverse proxy configuration
├── scripts/                # User utility scripts
├── preinstall/             # System preparation
├── wiki/                   # Documentation site (MkDocs)
├── install.sh              # Main installer
└── README.md               # Project overview
```

### Maintenance & Development Structure

```
.claude/                    # Maintenance & development resources
├── README.md              # Directory overview and usage
├── MODERNIZATION_CHECKLIST.md  # Project upgrade tracking
├── scripts/               # Active maintenance tools (7 files)
│   ├── clean-yaml-files.sh
│   ├── fix-discord-links.sh
│   └── repository-maintenance/
├── development-scripts/   # Development tools (44 files)
│   ├── batch-convert-all.sh
│   ├── deploy-local.sh
│   ├── yaml-validation/
│   └── testing-tools/
├── development-backups/   # Development artifacts (44 items)
│   ├── test-results/
│   ├── backup-configurations/
│   └── error-reports/
├── analysis/              # Project analysis reports
├── backups/               # Configuration backups
├── configs/               # Template configurations
└── docs/                  # Generated documentation
```

## 🔧 Maintenance Tools Location

### Active Maintenance Scripts

All current maintenance tools are located in `.claude/scripts/`:

```bash
# YAML file cleanup and standardization
.claude/scripts/clean-yaml-files.sh

# Discord link updates across codebase
.claude/scripts/fix-discord-links.sh

# Repository URL updates
.claude/scripts/update-repository-urls.sh

# General maintenance utilities
.claude/scripts/repository-maintenance/
```

### Development Scripts (Archived)

Historical development scripts are preserved in `.claude/development-scripts/`:

```bash
# Local deployment testing
.claude/development-scripts/deploy-local*.sh

# YAML processing and validation
.claude/development-scripts/*yaml*.sh

# Port conflict resolution
.claude/development-scripts/port-*.sh

# Container migration tools
.claude/development-scripts/migrate-*.sh
```

## 📊 Cleanup Summary (August 2025)

### Files Organized
- **863 total files** moved to organized structure
- **44 development scripts** properly categorized
- **44 development backups** preserved but organized
- **7 maintenance scripts** kept active and accessible

### Content Removed
- **862 temporary backup files** deleted from main repository
- **29,785 lines** of temporary content cleaned
- **Test artifacts** and **cache files** removed
- **Duplicate configurations** consolidated

### Quality Improvements
- **Zero breaking changes** - all functionality preserved
- **Professional organization** for contributor onboarding
- **Clear separation** between user and maintenance tools
- **Comprehensive documentation** of structure and usage

## 🚀 Finding What You Need

### For Users
- **Applications**: Browse `apps/` directory by category
- **Installation**: Use `install.sh` or category-specific installers
- **Documentation**: Visit `wiki/docs/` or the online documentation
- **Utilities**: Check `scripts/` for user-facing tools

### For Contributors
- **Project status**: Check `.claude/MODERNIZATION_CHECKLIST.md`
- **Maintenance tools**: Use scripts in `.claude/scripts/`
- **Development history**: Review `.claude/development-backups/`
- **Analysis reports**: Read `.claude/analysis/` findings

### For Maintainers
- **Bulk operations**: Use `.claude/scripts/` utilities
- **Testing tools**: Access `.claude/development-scripts/`
- **Backup procedures**: Follow `.claude/backups/` guidelines
- **Configuration templates**: Use `.claude/configs/` examples

## 📋 Usage Guidelines

### Accessing Maintenance Tools

```bash
# View current project status
cat .claude/MODERNIZATION_CHECKLIST.md

# Run YAML standardization
.claude/scripts/clean-yaml-files.sh

# Update Discord links across repository
.claude/scripts/fix-discord-links.sh

# Create configuration backup
cp -r apps/ .claude/backups/apps_$(date +%Y%m%d)/
```

### Contributing Workflow

1. **Check project status** in `.claude/MODERNIZATION_CHECKLIST.md`
2. **Use maintenance scripts** from `.claude/scripts/` for bulk operations
3. **Document changes** in appropriate `.claude/analysis/` reports
4. **Create backups** before major modifications
5. **Update tracking files** when completing tasks

## 🔍 Search & Navigation

### Finding Specific Components

```bash
# Find all applications by type
ls apps/mediaserver/        # Media servers
ls apps/downloadclients/    # Download clients
ls apps/addons/            # Additional tools

# Locate maintenance tools
ls .claude/scripts/         # Active maintenance
ls .claude/development-scripts/  # Development tools

# Access documentation
ls wiki/docs/              # User documentation
ls .claude/docs/           # Development docs
```

### Common Locations

| Component | Location | Purpose |
|-----------|----------|---------|
| Docker Apps | `apps/*/` | User-deployable services |
| Documentation | `wiki/docs/` | User guides and references |
| Maintenance | `.claude/scripts/` | Active maintenance tools |
| Development | `.claude/development-scripts/` | Historical dev tools |
| Backups | `.claude/backups/` | Configuration backups |
| Analysis | `.claude/analysis/` | Project analysis reports |

## 📈 Benefits of New Structure

### Professional Organization
- **Clear separation** of concerns between user and maintenance tools
- **Consistent naming** conventions across all directories
- **Logical grouping** of related functionality
- **Easy navigation** for contributors and users

### Improved Maintainability
- **Centralized maintenance** tools in `.claude/scripts/`
- **Preserved development history** in organized backups
- **Clear documentation** of all components and purposes
- **Streamlined workflows** for common operations

### Enhanced Contributor Experience
- **Quick orientation** through clear directory structure
- **Easy access** to relevant tools and documentation
- **Comprehensive tracking** of project status and changes
- **Professional presentation** for new contributors

## 🛡️ Safety & Backup

### Backup Strategy
- **All development work** preserved in `.claude/development-backups/`
- **Configuration backups** maintained in `.claude/backups/`
- **Incremental backups** created before major changes
- **Rollback procedures** documented for critical operations

### Safety Measures
- **No functional changes** during reorganization
- **Comprehensive testing** before file removal
- **Version control tracking** of all changes
- **Recovery procedures** for accidental deletions

---

**Last Updated**: August 16, 2025  
**Cleanup Version**: v2.2  
**Files Organized**: 863  
**Content Removed**: 29,785 lines

For questions about repository organization or maintenance procedures, check [Contributing Guidelines](contributing.md) or visit our [Discord community](https://discord.gg/Pc7mXX786x).

Support the project: [Ko-fi](https://ko-fi.com/homelabarr) | [GitHub Sponsors](https://github.com/sponsors/smashingtags)
