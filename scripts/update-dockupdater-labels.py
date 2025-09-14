#!/usr/bin/env python3
"""
Update all dockupdater.enable labels to hlupdater.enable
This updates the container update monitoring labels across all YAML files
"""

import os
import re
from pathlib import Path

# Configuration
OLD_LABEL = 'homelabarr-hlupdater.enable'  # What we incorrectly changed to
NEW_LABEL = 'dockupdater.enable'  # What it should be for the real dockupdater

# Directories to process
DIRECTORIES = [
    'apps/',
    'traefik/',
    'MASTER_DOCUMENTATION/',
]

# Directories to skip
SKIP_DIRS = [
    'rebrand_backup',
    '.git',
    'node_modules',
    '.claude',
    '__pycache__'
]

def should_skip_dir(path):
    """Check if directory should be skipped"""
    for skip in SKIP_DIRS:
        if skip in str(path):
            return True
    return False

def update_file(filepath):
    """Update dockupdater labels in a single file"""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Check if file contains the old label
        if OLD_LABEL not in content:
            return False
        
        # Replace the label
        original = content
        
        # Replace both quoted and unquoted versions
        patterns = [
            (f'"{OLD_LABEL}=', f'"{NEW_LABEL}='),
            (f"'{OLD_LABEL}=", f"'{NEW_LABEL}="),
            (f'{OLD_LABEL}=', f'{NEW_LABEL}='),
            (f'- {OLD_LABEL}', f'- {NEW_LABEL}'),
            (f'  {OLD_LABEL}', f'  {NEW_LABEL}'),
        ]
        
        for old_pattern, new_pattern in patterns:
            content = content.replace(old_pattern, new_pattern)
        
        # Write back if changed
        if content != original:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
            return True
        
        return False
        
    except Exception as e:
        print(f"Error processing {filepath}: {e}")
        return False

def main():
    """Main function to update all files"""
    print("=" * 60)
    print("HomelabARR Container Updater Label Migration")
    print("=" * 60)
    print(f"Updating: {OLD_LABEL} -> {NEW_LABEL}")
    print()
    
    updated_files = []
    skipped_files = []
    error_files = []
    
    # Process each directory
    for directory in DIRECTORIES:
        if not os.path.exists(directory):
            continue
            
        for root, dirs, files in os.walk(directory):
            # Skip certain directories
            if should_skip_dir(root):
                dirs[:] = []  # Don't recurse into this directory
                continue
            
            # Process YAML files
            for file in files:
                if file.endswith(('.yml', '.yaml')):
                    filepath = os.path.join(root, file)
                    
                    if update_file(filepath):
                        updated_files.append(filepath)
                        print(f"[UPDATED] {filepath}")
    
    # Summary
    print()
    print("=" * 60)
    print("Summary")
    print("=" * 60)
    print(f"Files updated: {len(updated_files)}")
    
    if len(updated_files) > 0:
        print()
        print("Sample updated files:")
        for file in updated_files[:10]:
            print(f"  - {file}")
        if len(updated_files) > 10:
            print(f"  ... and {len(updated_files) - 10} more")
    
    print()
    print("Next steps:")
    print("1. Review the changes with: git diff")
    print("2. Test a few containers to ensure labels work")
    print("3. Commit with: git commit -m 'fix: Update dockupdater labels to hlupdater'")
    print()
    print("Note: The actual container 'homelabarr-hlupdater' monitors these labels")
    print("      to check for container updates.")

if __name__ == "__main__":
    main()