# YAML Cleanup Tool Documentation

## Overview

The YAML Cleanup Tool (`clean-yaml-files.sh`) is an automated maintenance utility designed to standardize and clean up YAML configuration files across the entire HomelabARR CLI repository. This tool ensures consistent formatting, removes unnecessary metadata, and maintains proper YAML structure.

## Purpose

### What It Does
- **Removes metadata junk**: Eliminates author comments, unnecessary headers, and legacy references
- **Standardizes format**: Ensures all YAML files start with the proper `---` delimiter
- **Cleans headers**: Removes shebang lines (`#!/bin/bash`) from YAML files
- **Maintains consistency**: Creates uniform structure across all configuration files
- **Preserves functionality**: Ensures no breaking changes to application configurations

### Why It's Important
- **Improved reliability**: Cleaner YAML files parse more reliably in Docker Compose
- **Better maintainability**: Consistent format makes the codebase easier to maintain
- **Reduced errors**: Standardized files reduce deployment and configuration errors
- **Enhanced developer experience**: Clean, consistent files improve contributor workflow

## Usage

### Basic Usage
```bash
# Navigate to project root
cd /path/to/homelabarr-cli

# Make script executable
chmod +x clean-yaml-files.sh

# Run the cleanup tool
./clean-yaml-files.sh
```

### What Happens During Execution
1. **File Discovery**: Recursively finds all `.yml` files in the repository
2. **Processing**: Analyzes each file for metadata and formatting issues
3. **Cleaning**: Removes unnecessary content while preserving functionality
4. **Validation**: Ensures cleaned files maintain proper YAML structure
5. **Reporting**: Displays progress and summary of processed files

### Output Example
```
🧹 Cleaning up YAML installer files...
Processing: ./apps/mediaserver/plex.yml
  ✅ Cleaned
Processing: ./apps/downloadclients/qbittorrent.yml
  ✅ Cleaned
Processing: ./apps/addons/tautulli.yml
  ⚠️  Skipping empty file

🎉 YAML cleanup complete!
📊 Processed 489 files
🧹 All YAML files are now tidy and uniform
```

## Technical Details

### Script Algorithm
1. **File Detection**: Uses `find` to locate all `.yml` files, excluding `.git` directory
2. **Header Analysis**: Identifies and removes various types of metadata headers:
   - Shebang lines (`#!/usr/bin/env bash`, `#!/bin/bash`)
   - Comment blocks starting with `#`
   - Author/title metadata
   - Empty lines before actual YAML content
3. **YAML Structure**: Ensures proper `---` delimiter at the beginning
4. **Content Preservation**: Maintains all functional YAML content
5. **Safe Operation**: Uses temporary files and validates content before replacement

### File Processing Logic
```bash
# Pseudocode of processing logic
for each .yml file:
    if file is empty:
        skip file
    else:
        create temporary file
        read line by line:
            if line is shebang: skip
            if line is comment header and no YAML found: skip
            if line is empty and no YAML found: skip
            if line starts with "---": mark YAML found, output line
            if line starts with "services:" or "version:": 
                mark YAML found, output "---" then line
            if YAML found: output line
        replace original with cleaned version
```

### Safety Features
- **Backup Creation**: Creates temporary files before making changes
- **Content Validation**: Ensures files have content before processing
- **Error Handling**: Gracefully handles empty files and processing errors
- **Git Integration**: Automatically excludes `.git` directory from processing
- **Progress Tracking**: Reports processing status for each file

## Files Affected

### Application Categories
The cleanup tool processes YAML files across all application categories:

#### Media Servers
- Plex, Jellyfin, Emby configurations
- Media streaming service setups
- Theme and plugin configurations

#### Media Management
- Radarr, Sonarr, Lidarr, Bazarr setups
- Prowlarr indexer management
- Media automation configurations

#### Download Clients
- qBittorrent, SABnzbd, Deluge configs
- Torrent and Usenet client setups
- Download management configurations

#### Request Management
- Overseerr, Petio, Ombi templates
- Media request system configurations
- User management setups

#### Monitoring & Analytics
- Tautulli, Netdata, Grafana configurations
- System monitoring setups
- Performance tracking configurations

#### Self-hosted Applications
- NextCloud, Bitwarden, Home Assistant
- Productivity and security applications
- Custom service configurations

#### Development Tools
- Code-Server, GitLab, VS Code configs
- Development environment setups
- CI/CD pipeline configurations

#### Networking & Security
- Pi-hole, WireGuard, VPN configurations
- Network security setups
- DNS and proxy configurations

### File Structure Examples

#### Before Cleanup
```yaml
#!/usr/bin/env bash
################################################################################
# Title:         HomelabarrCli: Plex Media Server
# Author(s):     admin@homelabarr-cli.io
# URL:           https://homelabarr-cli.io
# Description:   Plex media server configuration
################################################################################

version: "3.8"
services:
  plex:
    image: linuxserver/plex:latest
    container_name: plex
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
```

#### After Cleanup
```yaml
---
version: "3.8"
services:
  plex:
    image: linuxserver/plex:latest
    container_name: plex
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
```

## Benefits

### For Developers
- **Consistent codebase**: Uniform formatting across all YAML files
- **Easier maintenance**: Predictable file structure simplifies updates
- **Reduced merge conflicts**: Standardized format minimizes git conflicts
- **Better code reviews**: Clean files are easier to review and understand

### For Users
- **Improved reliability**: Standardized files reduce deployment failures
- **Faster deployments**: Cleaner YAML files parse more quickly
- **Better error messages**: Consistent structure improves error reporting
- **Enhanced troubleshooting**: Standard format makes debugging easier

### For Contributors
- **Clear standards**: Established formatting guidelines for new contributions
- **Automated quality**: Tool ensures new files meet project standards
- **Simplified onboarding**: Consistent codebase easier for new contributors
- **Quality assurance**: Automated tool maintains code quality standards

## Maintenance and Updates

### Regular Usage
- **Monthly cleanup**: Run the tool monthly to maintain standards
- **Before releases**: Clean up files before major releases
- **After contributions**: Use tool to standardize new contributions
- **Continuous integration**: Consider integrating into CI/CD pipeline

### Tool Enhancement
The cleanup tool is actively maintained and enhanced with:
- **Extended validation**: Additional YAML quality checks
- **Performance optimization**: Improved processing speed for large repositories
- **Multi-format support**: Potential extension to other configuration formats
- **Integration testing**: Automated validation of cleaned configurations

### Contributing to the Tool
- **Bug reports**: Report issues with the cleanup process
- **Feature requests**: Suggest improvements and new features
- **Testing**: Help test the tool across different environments
- **Documentation**: Contribute to tool documentation and usage guides

## Troubleshooting

### Common Issues

#### Permission Errors
```bash
# Solution: Ensure script is executable
chmod +x clean-yaml-files.sh
```

#### File Processing Errors
```bash
# Check for file corruption or invalid characters
file --mime-encoding problematic-file.yml

# Manually inspect problematic files
cat -A problematic-file.yml
```

#### Git Integration Issues
```bash
# Ensure you're in the project root
pwd
git status

# Check if .git directory exists
ls -la .git
```

### Recovery Procedures
If the cleanup tool causes issues:

1. **Check git status**: `git status` to see modified files
2. **Review changes**: `git diff` to see what was changed
3. **Selective restoration**: `git checkout -- specific-file.yml` to restore individual files
4. **Full restoration**: `git checkout .` to restore all files (caution: loses all changes)
5. **Report issues**: Create GitHub issue with details about the problem

### Validation
After running the cleanup tool:

```bash
# Test Docker Compose parsing
docker-compose -f apps/mediaserver/plex.yml config

# Validate YAML syntax
yamllint apps/mediaserver/plex.yml

# Test actual deployment
docker-compose -f apps/mediaserver/plex.yml up --dry-run
```

## Integration with Development Workflow

### Pre-commit Hooks
Consider integrating the cleanup tool into pre-commit hooks:

```yaml
# .pre-commit-config.yaml
repos:
  - repo: local
    hooks:
      - id: yaml-cleanup
        name: Clean YAML files
        entry: ./clean-yaml-files.sh
        language: script
        files: \.yml$
```

### CI/CD Integration
Integrate into GitHub Actions workflow:

```yaml
# .github/workflows/yaml-quality.yml
name: YAML Quality Check
on: [push, pull_request]
jobs:
  yaml-quality:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run YAML cleanup
        run: ./clean-yaml-files.sh
      - name: Check for changes
        run: git diff --exit-code
```

## Related Documentation

- **[YAML Standardization Release Notes](../releases/yaml-standardization-v2.1.md)**: Detailed technical documentation
- **[Contributing Guidelines](contributing.md)**: Standards for new contributions
- **[Architecture Overview](architecture.md)**: Project structure and design principles
- **[Changelog](../install/changelog.md)**: Recent updates and improvements

## Support

### Getting Help
- **GitHub Issues**: [Report cleanup tool issues](https://github.com/smashingtags/homelabarr-cli/issues)
- **Community Discord**: [Join discussion](https://discord.gg/Pc7mXX786x)
- **Documentation**: [Browse wiki](https://github.com/smashingtags/homelabarr-cli/tree/master/wiki)

### Contributing
- **Bug fixes**: Submit pull requests for tool improvements
- **Feature additions**: Propose and implement new functionality
- **Testing**: Help test the tool across different environments
- **Documentation**: Improve tool documentation and usage guides

---

**The YAML Cleanup Tool is a critical component of HomelabARR CLI's infrastructure, ensuring consistent, reliable, and maintainable configuration files across the entire project.**
