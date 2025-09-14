#!/usr/bin/env python3
"""
Container Naming Verification Script
Checks for any remaining docker-* prefixed container references
"""

import os
import re
import json
from pathlib import Path
from typing import Dict, List, Tuple

class ContainerNameVerifier:
    def __init__(self, root_dirs: List[str]):
        self.root_dirs = root_dirs
        self.old_containers = [
            'docker-auto-replyarr', 'docker-backup', 'docker-crunchy',
            'docker-crunchydl', 'docker-dockupdate', 'docker-gdsa',
            'docker-gui', 'docker-local-persist', 'docker-mount',
            'docker-newznab', 'docker-restic', 'docker-rollarr',
            'docker-spotweb', 'docker-traktarr', 'docker-uploader',
            'docker-vnstat', 'docker-wiki', 'docker-alpine',
            'docker-alpine-v3', 'docker-config', 'docker-create',
            'docker-homelabarr', 'docker-ubuntu-focal', 'docker-ubuntu-jammy',
            'docker-ubuntu-noble', 'docker-ui'
        ]
        self.new_containers = {
            old: old.replace('docker-', 'homelabarr-') 
            for old in self.old_containers
        }
        self.findings = {'old_references': [], 'new_references': [], 'issues': []}
        self.exclude_dirs = {'.git', 'node_modules', '.claude', 'backup', 'rebrand_backup'}
        self.include_extensions = {'.yml', '.yaml', '.sh', '.md', '.env', '.json', '.py'}
        
    def should_check_file(self, filepath: Path) -> bool:
        """Check if file should be scanned"""
        # Skip excluded directories
        for part in filepath.parts:
            if part in self.exclude_dirs:
                return False
        
        # Check extension
        if filepath.suffix not in self.include_extensions:
            # Also check Dockerfile
            if filepath.name != 'Dockerfile':
                return False
                
        return True
        
    def scan_file(self, filepath: Path) -> Dict[str, List[Tuple[int, str]]]:
        """Scan a file for container references"""
        results = {'old': [], 'new': []}
        
        try:
            with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
                lines = f.readlines()
                
            for line_num, line in enumerate(lines, 1):
                # Check for old container names
                for old_name in self.old_containers:
                    if old_name in line:
                        # Skip comments in code files
                        if not (line.strip().startswith('#') or line.strip().startswith('//')):
                            results['old'].append((line_num, line.strip()))
                        elif 'TODO' in line or 'FIXME' in line:
                            results['old'].append((line_num, line.strip()))
                
                # Check for new container names
                for new_name in self.new_containers.values():
                    if new_name in line and not line.strip().startswith('#'):
                        results['new'].append((line_num, line.strip()))
                        
        except Exception as e:
            self.findings['issues'].append(f"Error reading {filepath}: {e}")
            
        return results
        
    def verify_workflow_files(self):
        """Special check for GitHub workflow files"""
        workflow_patterns = [
            '*.github/workflows/*.yml',
            '*.github/workflows/*.yaml'
        ]
        
        for root_dir in self.root_dirs:
            workflow_dir = Path(root_dir) / '.github' / 'workflows'
            if workflow_dir.exists():
                for workflow_file in workflow_dir.glob('*.yml'):
                    results = self.scan_file(workflow_file)
                    if results['old']:
                        self.findings['old_references'].append({
                            'file': str(workflow_file),
                            'type': 'workflow',
                            'references': results['old']
                        })
                    if results['new']:
                        self.findings['new_references'].append({
                            'file': str(workflow_file),
                            'type': 'workflow',
                            'references': results['new']
                        })
    
    def verify_docker_compose_files(self):
        """Check Docker Compose files for image references"""
        compose_patterns = ['docker-compose.yml', 'docker-compose.yaml', '*.yml']
        
        for root_dir in self.root_dirs:
            root_path = Path(root_dir)
            
            # Check apps directories
            for apps_dir in ['apps', 'apps/system', 'apps/local-mode-apps']:
                dir_path = root_path / apps_dir
                if dir_path.exists():
                    for yml_file in dir_path.glob('*.yml'):
                        if self.should_check_file(yml_file):
                            results = self.scan_file(yml_file)
                            if results['old']:
                                self.findings['old_references'].append({
                                    'file': str(yml_file),
                                    'type': 'docker-compose',
                                    'references': results['old']
                                })
                            if results['new']:
                                self.findings['new_references'].append({
                                    'file': str(yml_file),
                                    'type': 'docker-compose',
                                    'references': results['new']
                                })
    
    def verify_shell_scripts(self):
        """Check shell scripts for container references"""
        for root_dir in self.root_dirs:
            root_path = Path(root_dir)
            
            for sh_file in root_path.rglob('*.sh'):
                if self.should_check_file(sh_file):
                    results = self.scan_file(sh_file)
                    if results['old']:
                        self.findings['old_references'].append({
                            'file': str(sh_file),
                            'type': 'shell-script',
                            'references': results['old']
                        })
                    if results['new']:
                        self.findings['new_references'].append({
                            'file': str(sh_file),
                            'type': 'shell-script',
                            'references': results['new']
                        })
    
    def run_verification(self):
        """Run complete verification"""
        print("Starting Container Naming Verification\n")
        print("=" * 60)
        
        # Run all verification checks
        print("Checking workflow files...")
        self.verify_workflow_files()
        
        print("Checking Docker Compose files...")
        self.verify_docker_compose_files()
        
        print("Checking shell scripts...")
        self.verify_shell_scripts()
        
        # Generate report
        self.generate_report()
        
    def generate_report(self):
        """Generate verification report"""
        print("\n" + "=" * 60)
        print("VERIFICATION REPORT")
        print("=" * 60)
        
        # Summary
        old_count = len(self.findings['old_references'])
        new_count = len(self.findings['new_references'])
        
        print(f"\n[OK] New homelabarr-* references found: {new_count}")
        print(f"[WARNING] Old docker-* references found: {old_count}")
        
        # Old references that need updating
        if self.findings['old_references']:
            print("\n[X] OLD REFERENCES REQUIRING UPDATE:")
            print("-" * 40)
            for ref in self.findings['old_references']:
                print(f"\n[FILE] {ref['file']} ({ref['type']})")
                for line_num, line in ref['references'][:3]:  # Show first 3
                    print(f"   Line {line_num}: {line[:80]}...")
                if len(ref['references']) > 3:
                    print(f"   ... and {len(ref['references']) - 3} more")
        
        # New references (successful updates)
        if self.findings['new_references']:
            print("\n[OK] SUCCESSFULLY UPDATED REFERENCES:")
            print("-" * 40)
            for ref in self.findings['new_references'][:5]:  # Show first 5 files
                print(f"[FILE] {ref['file']} - {len(ref['references'])} homelabarr-* refs")
        
        # Issues encountered
        if self.findings['issues']:
            print("\n[WARNING] ISSUES ENCOUNTERED:")
            print("-" * 40)
            for issue in self.findings['issues']:
                print(f"   - {issue}")
        
        # Save detailed report
        self.save_json_report()
        
    def save_json_report(self):
        """Save detailed JSON report"""
        report_file = Path('container-naming-report.json')
        
        report = {
            'summary': {
                'old_references_count': len(self.findings['old_references']),
                'new_references_count': len(self.findings['new_references']),
                'issues_count': len(self.findings['issues']),
                'checked_directories': self.root_dirs
            },
            'old_references': self.findings['old_references'],
            'new_references': self.findings['new_references'],
            'issues': self.findings['issues']
        }
        
        with open(report_file, 'w') as f:
            json.dump(report, f, indent=2)
        
        print(f"\n[REPORT] Detailed report saved to: {report_file}")
        
        # Overall status
        if not self.findings['old_references']:
            print("\n[SUCCESS] All container references have been updated!")
        else:
            print(f"\n[ACTION REQUIRED] {len(self.findings['old_references'])} files still need updates")

def main():
    """Main execution"""
    # Define directories to check
    dirs_to_check = [
        r'F:\Coding Projects\homelabarr-cli',
        r'F:\Coding Projects\homelabarr-containers'
    ]
    
    # Filter existing directories
    existing_dirs = [d for d in dirs_to_check if Path(d).exists()]
    
    if not existing_dirs:
        print("[ERROR] No valid directories found to check")
        return
    
    print(f"Checking directories: {existing_dirs}")
    
    # Run verification
    verifier = ContainerNameVerifier(existing_dirs)
    verifier.run_verification()

if __name__ == "__main__":
    main()