#!/usr/bin/env python3
"""
Repository URL Update Script
Updates all references from github.com/smashingtags/homelabarr-cli to github.com/smashingtags/homelabarr-cli
"""

import os
import re
import shutil
from pathlib import Path

def backup_file(file_path):
    """Create a backup of the original file"""
    backup_path = f"{file_path}.repo_backup"
    shutil.copy2(file_path, backup_path)
    return backup_path

def update_file_content(file_path, replacements):
    """Update file content with repository URL changes"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original_content = content
        
        # Apply all replacements
        for old_pattern, new_pattern in replacements.items():
            content = content.replace(old_pattern, new_pattern)
        
        # Only write if content changed
        if content != original_content:
            # Create backup first
            backup_path = backup_file(file_path)
            print(f"Backup created: {backup_path}")
            
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            
            print(f"Updated: {file_path}")
            return True
        else:
            print(f"No changes: {file_path}")
            return False
            
    except Exception as e:
        print(f"Error updating {file_path}: {e}")
        return False

def main():
    """Main function to update repository URLs"""
    
    # Define all replacement patterns
    replacements = {
        # Full HTTPS URLs
        'https://github.com/smashingtags/HomelabarrCli': 'https://github.com/smashingtags/HomelabarrCli',
        
        # URLs without protocol
        'github.com/smashingtags/HomelabarrCli': 'github.com/smashingtags/HomelabarrCli',
        
        # API URLs for badges
        'api.github.com/repos/smashingtags/HomelabarrCli': 'api.github.com/repos/smashingtags/HomelabarrCli',
        
        # Shield badge URLs
        'img.shields.io/github/downloads/smashingtags/HomelabarrCli': 'img.shields.io/github/downloads/smashingtags/HomelabarrCli',
        'img.shields.io/github/v/release/smashingtags/HomelabarrCli': 'img.shields.io/github/v/release/smashingtags/HomelabarrCli',
        'img.shields.io/github/release/smashingtags/HomelabarrCli': 'img.shields.io/github/release/smashingtags/HomelabarrCli',
        'img.shields.io/github/license/smashingtags/HomelabarrCli': 'img.shields.io/github/license/smashingtags/HomelabarrCli',
    }
    
    # Find all files to update
    base_path = Path('.')
    
    file_patterns = [
        '**/*.md',
        '**/*.yml', 
        '**/*.yaml',
        '**/*.json',
        '**/*.sh',
        '**/*.py'
    ]
    
    files_to_update = []
    
    for pattern in file_patterns:
        files_to_update.extend(base_path.glob(pattern))
    
    # Filter out certain directories and files
    excluded_paths = [
        '.git',
        '.claude/backups',
        'HomelabarrCli-wiki',  # Generated files
        'test-',
        '.backup',
        '__pycache__',
        '.pyc'
    ]
    
    filtered_files = []
    for file_path in files_to_update:
        file_str = str(file_path)
        should_exclude = any(excluded in file_str for excluded in excluded_paths)
        if not should_exclude and file_path.is_file():
            filtered_files.append(file_path)
    
    print(f"Found {len(filtered_files)} files to process")
    print("")
    
    updated_count = 0
    
    for file_path in filtered_files:
        if update_file_content(file_path, replacements):
            updated_count += 1
    
    print("")
    print(f"Summary:")
    print(f"   Files processed: {len(filtered_files)}")
    print(f"   Files updated: {updated_count}")
    print(f"   Files unchanged: {len(filtered_files) - updated_count}")
    print("")
    print("Repository URL update completed!")

if __name__ == '__main__':
    main()
