#!/usr/bin/env python3
"""
HomelabARR CLI Rebranding Script

CRITICAL: Creates backup before making changes!
Systematically replaces all instances of legacy branding with new branding.

Usage: python rebrand_replacer.py --new-name "homelabarr-cli" --new-username "your-username"
"""

import os
import re
import shutil
import argparse
from pathlib import Path
from datetime import datetime
import json

class RebrandReplacer:
    def __init__(self, new_project_name="homelabarr-cli", new_username="homelabarr"):
        self.new_project_name = new_project_name
        self.new_username = new_username
        self.backup_dir = f"rebrand_backup_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
        
        # Define replacement mappings based on new names
        self.replacements = {
            # Docker registry and images
            r'ghcr\.io/homelabarr/': f'ghcr.io/smashingtags/',
            
            # File paths
            r'/opt/homelabarr\b': f'/opt/{new_project_name}',
            
            # Binary names and commands
            r'/usr/bin/homelabarr\b': f'/usr/bin/{new_project_name}',
            r'/bin/homelabarr\b': f'/bin/{new_project_name}',
            r'\bhomelabarr\b(?=\s|$|\.|\s)': new_project_name,  # Standalone homelabarr
            
            # Network names
            r'homelabarr-local': f'{new_project_name}-local',
            
            # Container names
            r'--name=homelabarr\b': f'--name={new_project_name}',
            
            # Username references
            r'\bmrdoob\b': new_username,
            r'\bMrDoob\b': new_username.title(),
            
            # Project name variations
            r'\bHomelabarr\b': new_project_name.title().replace('-', ''),
            r'\bHomelabARR\b': new_project_name.title().replace('-', ''),
            
            # Docker mod names (keep homelabarr prefix in mod names for now)
            # r'docker-mod-(\w+)': r'homelabarr-mod-\1',  # Uncomment if you want to rebrand mods too
        }
        
        # File extensions to process
        self.file_extensions = {
            '.md', '.yml', '.yaml', '.sh', '.py', '.json', '.txt', 
            '.js', '.html', '.css', '.conf', '.cfg', '.ini',
            '.env', '.example', '.template', '.xml', '.dockerfile'
        }
        
        # Directories to skip
        self.skip_dirs = {
            '.git', '__pycache__', 'node_modules', '.venv', 'venv',
            'logs', 'temp', 'tmp', self.backup_dir
        }
        
        self.stats = {
            'files_processed': 0,
            'files_modified': 0,
            'total_replacements': 0,
            'category_counts': {}
        }

    def create_backup(self):
        """Create backup of entire repository"""
        print(f"Creating backup in {self.backup_dir}...")
        
        # Create backup directory
        os.makedirs(self.backup_dir, exist_ok=True)
        
        # Copy all files except skip directories
        for root, dirs, files in os.walk('.'):
            # Remove skip directories from dirs list
            dirs[:] = [d for d in dirs if d not in self.skip_dirs and not d.startswith('.')]
            
            rel_root = os.path.relpath(root, '.')
            if rel_root == '.':
                backup_root = self.backup_dir
            else:
                backup_root = os.path.join(self.backup_dir, rel_root)
            
            # Create directory structure in backup
            os.makedirs(backup_root, exist_ok=True)
            
            # Copy files
            for file in files:
                if not file.startswith('.'):
                    src = os.path.join(root, file)
                    dst = os.path.join(backup_root, file)
                    try:
                        shutil.copy2(src, dst)
                    except Exception as e:
                        print(f"Warning: Could not backup {src}: {e}")
        
        print(f"Backup created successfully in {self.backup_dir}")

    def should_skip_file(self, file_path):
        """Check if file should be skipped"""
        path = Path(file_path)
        
        # Skip backup directory
        if self.backup_dir in str(path):
            return True
            
        # Skip files without supported extensions
        if path.suffix not in self.file_extensions and path.suffix != '':
            return True
            
        # Skip this script itself
        if path.name in ['rebrand_replacer.py', 'rebrand_analysis.py', 'search_rebrand_terms.py']:
            return True
            
        return False

    def replace_in_file(self, file_path):
        """Apply replacements to a single file"""
        try:
            # Read file content
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                original_content = f.read()
            
            content = original_content
            file_replacements = 0
            
            # Apply each replacement pattern
            for pattern, replacement in self.replacements.items():
                matches = re.findall(pattern, content, re.IGNORECASE)
                if matches:
                    content = re.sub(pattern, replacement, content, flags=re.IGNORECASE)
                    file_replacements += len(matches)
                    self.stats['total_replacements'] += len(matches)
            
            # Write back if changes were made
            if content != original_content:
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(content)
                self.stats['files_modified'] += 1
                return file_replacements
                
        except Exception as e:
            print(f"Error processing {file_path}: {e}")
            
        return 0

    def process_repository(self):
        """Process all files in the repository"""
        print("Processing files for rebranding...")
        
        for root, dirs, files in os.walk('.'):
            # Skip unwanted directories
            dirs[:] = [d for d in dirs if d not in self.skip_dirs]
            
            for file in files:
                file_path = os.path.join(root, file)
                
                if self.should_skip_file(file_path):
                    continue
                
                self.stats['files_processed'] += 1
                replacements_made = self.replace_in_file(file_path)
                
                if replacements_made > 0:
                    rel_path = os.path.relpath(file_path, '.')
                    print(f"  Modified: {rel_path} ({replacements_made} replacements)")

    def generate_summary_report(self):
        """Generate summary report of changes made"""
        report = {
            'rebranding_summary': {
                'new_project_name': self.new_project_name,
                'new_username': self.new_username,
                'timestamp': datetime.now().isoformat(),
                'backup_location': self.backup_dir
            },
            'statistics': self.stats,
            'replacement_patterns': {pattern: replacement for pattern, replacement in self.replacements.items()}
        }
        
        with open('rebrand_summary.json', 'w', encoding='utf-8') as f:
            json.dump(report, f, indent=2)
        
        return report

    def run(self):
        """Execute the complete rebranding process"""
        print("=" * 60)
        print("HOMELABARR CLI REBRANDING SCRIPT")
        print("=" * 60)
        print(f"New project name: {self.new_project_name}")
        print(f"New username: {self.new_username}")
        print()
        
        # Step 1: Create backup
        self.create_backup()
        print()
        
        # Step 2: Process files
        self.process_repository()
        print()
        
        # Step 3: Generate report
        report = self.generate_summary_report()
        
        # Step 4: Show summary
        print("=" * 60)
        print("REBRANDING COMPLETE!")
        print("=" * 60)
        print(f"Files processed: {self.stats['files_processed']}")
        print(f"Files modified: {self.stats['files_modified']}")
        print(f"Total replacements: {self.stats['total_replacements']}")
        print(f"Backup location: {self.backup_dir}")
        print(f"Summary report: rebrand_summary.json")
        print()
        print("NEXT STEPS:")
        print("1. Test the rebranded repository thoroughly")
        print("2. Update any external references (GitHub, Docker Hub, etc.)")
        print("3. Update documentation with new branding")
        print("4. If satisfied, commit changes to git")
        print(f"5. If issues found, restore from backup: {self.backup_dir}")

def main():
    parser = argparse.ArgumentParser(description='Rebrand HomelabARR CLI repository')
    parser.add_argument('--new-name', default='homelabarr-cli', 
                       help='New project name (default: homelabarr-cli)')
    parser.add_argument('--new-username', default='homelabarr',
                       help='New username/organization (default: homelabarr)')
    parser.add_argument('--preview', action='store_true',
                       help='Preview changes without applying them')
    
    args = parser.parse_args()
    
    if args.preview:
        print("PREVIEW MODE - No changes will be made")
        # You could implement preview logic here
        return
    
    # Confirm before proceeding
    print(f"This will rebrand the repository:")
    print(f"  Project name: homelabarr -> {args.new_name}")
    print(f"  Username: mrdoob/MrDoob -> {args.new_username}")
    print()
    
    response = input("Continue? (yes/no): ").lower().strip()
    if response not in ['yes', 'y']:
        print("Rebranding cancelled.")
        return
    
    replacer = RebrandReplacer(args.new_name, args.new_username)
    replacer.run()

if __name__ == "__main__":
    main()
