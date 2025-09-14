# YAML Cleanup Script Documentation

## Overview

The `clean-yaml-files.sh` script is a maintenance utility that standardizes YAML files throughout the HomelabARR CLI repository. This documentation provides detailed usage instructions and implementation details.

## Location

```
homelabarr-cli/
├── clean-yaml-files.sh          # Main cleanup script
└── wiki/docs/scripts/
    └── yaml-cleanup.md          # This documentation
```

## Quick Start

### Basic Usage
```bash
# Make script executable and run
chmod +x clean-yaml-files.sh
./clean-yaml-files.sh
```

### Expected Output
```
🧹 Cleaning up YAML installer files...
Processing: ./apps/mediaserver/plex.yml
  ✅ Cleaned
Processing: ./apps/downloadclients/qbittorrent.yml  
  ✅ Cleaned
...
🎉 YAML cleanup complete!
📊 Processed 489 files
🧹 All YAML files are now tidy and uniform
```

## Script Features

### What Gets Cleaned
- **Shebang lines**: Removes `#!/bin/bash` and similar from YAML files
- **Comment headers**: Eliminates author, title, and description comments
- **Empty lines**: Removes leading empty lines before YAML content
- **Legacy metadata**: Cleans old homelabarr-cli references and outdated headers
- **Format inconsistencies**: Ensures proper `---` delimiter placement

### What Gets Preserved
- **All functional YAML**: Services, volumes, networks, and configuration
- **Environment variables**: `${VARIABLE}` references maintained
- **Docker Compose structure**: Version, services, volumes, networks intact
- **Application settings**: Container configurations preserved exactly

## Technical Implementation

### Algorithm Flow
1. **Discovery**: Find all `.yml` files recursively (excluding `.git`)
2. **Analysis**: Read each file line by line
3. **Processing**: Remove headers while preserving YAML structure
4. **Validation**: Ensure proper `---` delimiter placement
5. **Safety**: Use temporary files before overwriting originals

### File Processing Logic
```bash
# Core processing logic
while IFS= read -r line; do
    # Skip shebang lines
    if [[ "$line" =~ ^#!/ ]]; then
        continue
    fi
    
    # Skip comment headers before YAML content
    if [[ "$line" =~ ^#.*$ ]] && [[ "$found_yaml_start" == false ]]; then
        continue
    fi
    
    # Handle --- delimiter
    if [[ "$line" == "---" ]]; then
        found_yaml_start=true
        echo "---"
        continue
    fi
    
    # Add --- if YAML starts with services: or version:
    if [[ "$line" =~ ^(services|version):[[:space:]]* ]]; then
        echo "---"
        echo "$line"
        continue
    fi
    
    # Output all YAML content after detection
    if [[ "$found_yaml_start" == true ]]; then
        echo "$line"
    fi
done
```

### Safety Mechanisms
- **Temporary files**: Creates temp files before modifying originals
- **Content validation**: Checks for empty files and valid content
- **Progress tracking**: Reports processing status for each file
- **Error handling**: Graceful handling of edge cases
- **Git awareness**: Automatically excludes `.git` directory

## Use Cases

### Regular Maintenance
```bash
# Monthly cleanup run
./clean-yaml-files.sh

# After major updates
git pull && ./clean-yaml-files.sh
```

### Development Workflow
```bash
# Before committing changes
./clean-yaml-files.sh
git add .
git commit -m "Standardize YAML files"
```

### New Contributions
```bash
# Clean up new application additions
git add apps/newapp/newapp.yml
./clean-yaml-files.sh
git add .
git commit -m "Add new application with standardized YAML"
```

## Examples

### Before Cleanup
```yaml
#!/usr/bin/env bash
################################################################################
# Title:         HomelabarrCli: Media Server Application
# Author(s):     admin@homelabarr-cli.io
# URL:           https://homelabarr-cli.io
# Description:   Plex media server for homelabarr-cli
################################################################################

version: "3.8"
services:
  plex:
    image: linuxserver/plex:latest
    container_name: plex
```

### After Cleanup
```yaml
---
version: "3.8"
services:
  plex:
    image: linuxserver/plex:latest
    container_name: plex
```

### Edge Case: YAML Without Delimiter
```yaml
# Before (missing ---)
version: "3.8"
services:
  app:
    image: alpine:latest

# After (--- added automatically)  
---
version: "3.8"
services:
  app:
    image: alpine:latest
```

## Impact and Benefits

### Deployment Reliability
- **Consistent parsing**: Docker Compose handles standardized files more reliably
- **Reduced errors**: Eliminates parsing issues from malformed headers
- **Improved compatibility**: Better compatibility across Docker versions

### Development Experience
- **Clean codebase**: Uniform formatting improves readability
- **Easier maintenance**: Consistent structure simplifies updates
- **Better reviews**: Standardized files are easier to review in PRs

### Automation Benefits
- **CI/CD integration**: Clean files work better in automated pipelines
- **Testing reliability**: Consistent format improves test reliability
- **Deployment consistency**: Standardized files deploy more predictably

## Integration Options

### Pre-commit Hook
```yaml
# .pre-commit-config.yaml
repos:
  - repo: local
    hooks:
      - id: yaml-cleanup
        name: YAML Cleanup
        entry: ./clean-yaml-files.sh
        language: script
        files: \.yml$
        pass_filenames: false
```

### GitHub Actions
```yaml
# .github/workflows/yaml-check.yml
name: YAML Quality
on: [push, pull_request]
jobs:
  yaml-quality:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run YAML cleanup
        run: |
          chmod +x clean-yaml-files.sh
          ./clean-yaml-files.sh
      - name: Check for changes
        run: |
          if ! git diff --quiet; then
            echo "YAML files were not standardized"
            exit 1
          fi
```

### Manual Integration
```bash
# Add to development workflow
alias yaml-clean='./clean-yaml-files.sh'

# Add to deploy script
#!/bin/bash
echo "Cleaning YAML files..."
./clean-yaml-files.sh
echo "Deploying applications..."
# deployment commands...
```

## Troubleshooting

### Common Issues

#### Permission Denied
```bash
# Solution
chmod +x clean-yaml-files.sh
```

#### No Files Processed
```bash
# Check current directory
pwd
# Should be in homelabarr-cli root

# Check for YAML files
find . -name "*.yml" | head -5
```

#### File Corruption
```bash
# Check for binary files accidentally processed
file apps/mediaserver/plex.yml
# Should output: ASCII text

# Restore from git if needed
git checkout apps/mediaserver/plex.yml
```

### Validation After Cleanup
```bash
# Test Docker Compose parsing
docker-compose -f apps/mediaserver/plex.yml config

# Validate with yamllint (if installed)
yamllint apps/mediaserver/plex.yml

# Check git status
git status
git diff
```

## Advanced Usage

### Selective Processing
```bash
# Process only specific directories
find ./apps/mediaserver -name "*.yml" -type f -print0 | \
while IFS= read -r -d '' file; do
    echo "Processing: $file"
    # Apply cleanup logic here
done
```

### Custom Filtering
```bash
# Skip certain files or patterns
find . -name "*.yml" -not -path "*/backup/*" -type f -print0
```

### Backup Before Cleanup
```bash
# Create backup before running
tar -czf yaml-backup-$(date +%Y%m%d).tar.gz $(find . -name "*.yml")
./clean-yaml-files.sh
```

## Related Scripts

### Maintenance Scripts
- `backup.sh`: Backup system for applications
- `scripts/docker/dockerprune.sh`: Docker cleanup utilities
- `scripts/disk_cleanup.sh`: Disk space management

### Validation Scripts
- `verify-updates.sh`: Verify system updates
- `verify-discord-links.sh`: Check community links

## Performance Notes

### Processing Speed
- **Small repos**: Processes 100-200 files in under 10 seconds
- **Large repos**: Processes 500+ files in under 30 seconds
- **Network independence**: No network calls, pure local processing

### Resource Usage
- **Memory**: Minimal memory footprint, processes one file at a time
- **CPU**: Low CPU usage, primarily I/O bound
- **Disk**: Creates temporary files, requires minimal free space

## Future Enhancements

### Planned Features
- **Syntax validation**: YAML syntax checking during cleanup
- **Custom rules**: Configurable cleanup rules and patterns
- **Multi-format support**: Extension to JSON, TOML, and other formats
- **Integration testing**: Automated testing of cleaned configurations

### Community Contributions
- **Rule suggestions**: Community input on cleanup rules
- **Performance improvements**: Optimization suggestions welcome
- **Platform support**: Testing on different operating systems
- **Documentation**: Improvements to usage documentation

## Support

### Getting Help
- **Issues**: [GitHub Issues](https://github.com/smashingtags/homelabarr-cli/issues)
- **Community**: [Discord](https://discord.gg/Pc7mXX786x)
- **Documentation**: [Wiki](https://github.com/smashingtags/homelabarr-cli/tree/master/wiki)

### Contributing
- **Bug reports**: Report issues with the cleanup process
- **Feature requests**: Suggest improvements and new features  
- **Testing**: Help test across different environments
- **Documentation**: Contribute to documentation improvements

---

**The YAML cleanup script is essential for maintaining code quality and deployment reliability across the HomelabARR CLI ecosystem.**
