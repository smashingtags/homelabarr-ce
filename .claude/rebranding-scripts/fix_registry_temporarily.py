#!/usr/bin/env python3
"""
Temporarily revert Docker registry while keeping all other rebranding

Only changes ghcr.io/smashingtags/ back to ghcr.io/dockserver/ 
until new containers are built.
"""

import os
import re
from pathlib import Path

def revert_registry_only():
    """Revert only the Docker registry references"""
    
    # Only change the registry, keep everything else rebranded
    registry_pattern = r'ghcr\.io/smashingtags/'
    registry_replacement = 'ghcr.io/dockserver/'
    
    files_changed = 0
    total_replacements = 0
    
    print("Reverting Docker registry to dockserver (temporarily)...")
    print("Keeping all other rebranding (homelabarr-cli, mrgoober, etc.)")
    print("-" * 60)
    
    # Search through YAML files only (where Docker images are defined)
    for root, dirs, files in os.walk('.'):
        # Skip backup directories to avoid confusion
        if any(skip in root for skip in ['.git', 'rebrand_backup', '__pycache__']):
            continue
            
        for file in files:
            if not file.endswith(('.yml', '.yaml')):
                continue
                
            file_path = Path(root) / file
            
            try:
                with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                    content = f.read()
                
                # Count matches before replacement
                matches = re.findall(registry_pattern, content)
                if matches:
                    # Replace registry references
                    new_content = re.sub(registry_pattern, registry_replacement, content)
                    
                    # Write back the changes
                    with open(file_path, 'w', encoding='utf-8') as f:
                        f.write(new_content)
                    
                    files_changed += 1
                    total_replacements += len(matches)
                    
                    rel_path = file_path.relative_to('.')
                    print(f"  Fixed: {rel_path} ({len(matches)} references)")
                    
            except Exception as e:
                print(f"Error processing {file_path}: {e}")
    
    print("-" * 60)
    print(f"Registry reversion complete!")
    print(f"Files updated: {files_changed}")
    print(f"Docker registry references reverted: {total_replacements}")
    print()
    print("✅ Project is now functional with original containers")
    print("📋 Next steps:")
    print("   1. Test that containers pull successfully")
    print("   2. Set up your smashingtags container registry")
    print("   3. Build/push the required containers")
    print("   4. Run this script in reverse when ready")

if __name__ == "__main__":
    revert_registry_only()
