#!/usr/bin/env python3
"""
Rebranding Analysis Script - Generates detailed report for rebranding effort

Creates categorized lists of files that need rebranding updates.
"""

import os
import re
import json
from pathlib import Path
from collections import defaultdict

def analyze_rebranding_scope():
    """Analyze the scope of rebranding work needed"""
    
    # File categories for different types of updates
    categories = {
        'docker_images': [],       # Docker image references (ghcr.io/homelabarr/*)
        'file_paths': [],          # File system paths (/opt/homelabarr/*)
        'binary_names': [],        # Binary/executable names (homelabarr command)
        'docker_mods': [],         # Docker mod references
        'copyright': [],           # Copyright notices
        'usernames': [],           # Username references (mrdoob/MrDoob)
        'network_names': [],       # Docker network names
        'container_names': [],     # Container names
        'comments': [],            # Comment headers
        'documentation': []        # Documentation files
    }
    
    # Pattern classifications
    patterns = {
        r'ghcr\.io/homelabarr/': 'docker_images',
        r'/opt/homelabarr': 'file_paths',
        r'/usr/bin/homelabarr': 'binary_names',
        r'/bin/homelabarr': 'binary_names',
        r'docker-mod-\w+': 'docker_mods',
        r'Copyright.*homelabarr': 'copyright',
        r'\bmrdoob\b': 'usernames',
        r'\bMrDoob\b': 'usernames',
        r'homelabarr-local': 'network_names',
        r'--name=homelabarr': 'container_names',
        r'# Docker.*homelabarr': 'comments'
    }
    
    results = defaultdict(list)
    file_counts = defaultdict(int)
    
    # Search through files
    for root, dirs, files in os.walk('.'):
        # Skip unwanted directories
        if any(skip in root for skip in ['.git', '__pycache__', 'node_modules']):
            continue
            
        for file in files:
            file_path = Path(root) / file
            
            # Only process text files
            if not any(file.endswith(ext) for ext in [
                '.md', '.yml', '.yaml', '.sh', '.py', '.json', '.txt', 
                '.js', '.html', '.css', '.conf', '.cfg', '.ini', 
                '.env', '.example', '.template', '.xml'
            ]):
                continue
                
            try:
                with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                    content = f.read()
                    
                # Check for any homelabarr references
                if re.search(r'\b(homelabarr|mrdoob|MrDoob|Homelabarr)\b', content, re.IGNORECASE):
                    file_rel_path = str(file_path.relative_to('.'))
                    
                    # Categorize the file based on its type
                    if file.endswith(('.md', '.txt')):
                        categories['documentation'].append(file_rel_path)
                    elif file.endswith(('.yml', '.yaml')):
                        categories['docker_images'].append(file_rel_path)
                    elif file.endswith('.sh'):
                        categories['binary_names'].append(file_rel_path)
                    
                    # Count matches per pattern
                    for pattern, category in patterns.items():
                        matches = re.findall(pattern, content, re.IGNORECASE)
                        if matches:
                            results[category].append({
                                'file': file_rel_path,
                                'matches': len(matches),
                                'examples': matches[:3]  # First 3 examples
                            })
                            file_counts[category] += len(matches)
                            
            except Exception as e:
                print(f"Warning: Could not process {file_path}: {e}")
    
    return results, file_counts, categories

def generate_replacement_mapping():
    """Generate suggested replacement mappings"""
    return {
        # Docker images - need new container registry
        'ghcr.io/homelabarr/': 'ghcr.io/homelabarr/',  # or your new registry
        
        # File paths
        '/opt/homelabarr': '/opt/homelabarr-cli',
        
        # Binary names
        '/usr/bin/homelabarr': '/usr/bin/homelabarr',
        '/bin/homelabarr': '/bin/homelabarr',
        'homelabarr': 'homelabarr',
        
        # Network names
        'homelabarr-local': 'homelabarr-local',
        
        # Container names
        '--name=homelabarr': '--name=homelabarr',
        
        # Usernames (you'll need to specify your new username)
        'mrdoob': 'your-new-username',
        'MrDoob': 'YourNewUsername',
        
        # Project name variations
        'Homelabarr': 'HomelabARR-CLI',
        'homelabarr': 'homelabarr-cli',
        'HomelabARR': 'HomelabARR-CLI'
    }

def main():
    print("=== REBRANDING ANALYSIS ===")
    print("Analyzing repository for rebranding scope...")
    
    results, file_counts, categories = analyze_rebranding_scope()
    replacements = generate_replacement_mapping()
    
    print(f"\n=== SUMMARY ===")
    print(f"Total categories with matches: {len([k for k, v in file_counts.items() if v > 0])}")
    
    for category, count in file_counts.items():
        if count > 0:
            print(f"  {category:20}: {count:4d} matches")
    
    print(f"\n=== DETAILED BREAKDOWN ===")
    for category, matches in results.items():
        if matches:
            print(f"\n[{category.upper()}] - {len(matches)} files affected:")
            for match_info in matches[:10]:  # Show first 10 files per category
                print(f"  {match_info['file']:40} ({match_info['matches']} matches)")
                if match_info['examples']:
                    print(f"    Examples: {', '.join(match_info['examples'][:2])}")
            if len(matches) > 10:
                print(f"  ... and {len(matches) - 10} more files")
    
    print(f"\n=== SUGGESTED REPLACEMENTS ===")
    for old, new in replacements.items():
        print(f"  '{old}' -> '{new}'")
    
    # Save detailed results
    with open('rebrand_analysis_results.json', 'w') as f:
        json.dump({
            'summary': dict(file_counts),
            'details': dict(results),
            'suggested_replacements': replacements
        }, f, indent=2)
    
    print(f"\n=== NEXT STEPS ===")
    print("1. Review rebrand_analysis_results.json for complete details")
    print("2. Update the replacement mappings in generate_replacement_mapping()")
    print("3. Create backup of repository before running replacements")
    print("4. Run targeted replacement scripts by category")
    print("5. Test each category of changes before proceeding to next")
    
    print(f"\n=== PRIORITY ORDER ===")
    print("1. Docker images (need new container registry)")
    print("2. File paths (affects installations)")
    print("3. Binary names (affects command-line usage)")
    print("4. Documentation (user-facing)")
    print("5. Comments and copyright notices")

if __name__ == "__main__":
    main()
