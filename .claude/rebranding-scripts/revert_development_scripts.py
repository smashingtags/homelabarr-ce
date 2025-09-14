#!/usr/bin/env python3
"""
Selective revert of development scripts that contained historical MrDoob references
These scripts documented the conversion process from MrDoob's code and should preserve that context
"""

import os
import re
import shutil
from pathlib import Path

def revert_development_scripts():
    """Revert inappropriate changes to .claude/development-scripts"""
    
    dev_scripts_dir = Path("F:/Coding Projects/homelabarr/.claude/development-scripts")
    backup_dir = Path("F:/Coding Projects/homelabarr/dev_scripts_backup_" + 
                     str(int(__import__('time').time())))
    
    # Create backup
    backup_dir.mkdir(exist_ok=True)
    print(f"Creating backup at: {backup_dir}")
    
    reverted_files = []
    
    for script_file in dev_scripts_dir.glob("*.sh"):
        if not script_file.is_file():
            continue
            
        # Backup current version
        shutil.copy2(script_file, backup_dir / script_file.name)
        
        with open(script_file, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original_content = content
        
        # Revert project references where they were conversion documentation
        # Keep the current project name for actual functionality but preserve historical context
        
        # Look for patterns that suggest historical documentation
        historical_patterns = [
            # Comments about conversion from MrDoob
            (r'# Converting from mrgoober', '# Converting from MrDoob'),
            (r'# Migration from mrgoober', '# Migration from MrDoob'),
            (r'# Original mrgoober code', '# Original MrDoob code'),
            (r'# Based on mrgoober', '# Based on MrDoob'),
            (r'# Forked from mrgoober', '# Forked from MrDoob'),
            
            # URL references that were historical
            (r'github\.com/mrgoober/', 'github.com/mrdoob/'),
            (r'raw\.githubusercontent\.com/mrgoober/', 'raw.githubusercontent.com/mrdoob/'),
            
            # Attribution in headers where it was crediting original work
            (r'# Author: mrgoober \(original: MrDoob\)', '# Author: mrgoober (original: MrDoob)'),
            (r'# Originally by mrgoober', '# Originally by MrDoob'),
        ]
        
        # Apply reverts for historical context
        for pattern, replacement in historical_patterns:
            content = re.sub(pattern, replacement, content, flags=re.IGNORECASE)
        
        # Special handling for conversion scripts that document the process
        if any(keyword in script_file.name.lower() for keyword in ['convert', 'migrate', 'fix', 'bulk']):
            # These scripts likely document conversion from MrDoob's code
            # Check for echo statements or comments that reference the conversion
            conversion_patterns = [
                (r'echo.*"Converting.*homelabarr-cli', 
                 lambda m: m.group(0).replace('homelabarr-cli', 'homelabarr')),
                (r'echo.*"Migrating.*homelabarr-cli', 
                 lambda m: m.group(0).replace('homelabarr-cli', 'homelabarr')),
            ]
            
            for pattern, replacement in conversion_patterns:
                if callable(replacement):
                    content = re.sub(pattern, replacement, content)
                else:
                    content = re.sub(pattern, replacement, content)
        
        # Write back if changed
        if content != original_content:
            with open(script_file, 'w', encoding='utf-8') as f:
                f.write(content)
            reverted_files.append(script_file.name)
            print(f"✓ Reverted historical references in: {script_file.name}")
    
    if reverted_files:
        print(f"\nReverted {len(reverted_files)} development scripts:")
        for file in reverted_files:
            print(f"  - {file}")
        print(f"\nBackup saved to: {backup_dir}")
    else:
        print("No historical references found that needed reverting.")
        # Remove empty backup dir
        backup_dir.rmdir()

if __name__ == "__main__":
    revert_development_scripts()
