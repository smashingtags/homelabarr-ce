#!/usr/bin/env python3
"""
Repository Rebranding Search Script

Searches for all instances of legacy terms that need to be updated during rebranding:
- homelabarr (any case)
- mrdoob / MrDoob  
- Homelabarr

Usage: python search_rebrand_terms.py
"""

import os
import re
import json
from pathlib import Path
from typing import Dict, List, Tuple

class RebrandSearch:
    def __init__(self, root_dir: str = "."):
        self.root_dir = Path(root_dir)
        self.results = {}
        
        # Terms to search for (case-insensitive patterns)
        self.search_patterns = [
            r'\bhomelabarr\b',
            r'\bmrdoob\b', 
            r'\bMrDoob\b',
            r'\bHomelabarr\b'
        ]
        
        # File extensions to search
        self.search_extensions = {
            '.py', '.sh', '.yml', '.yaml', '.md', '.txt', '.json', 
            '.js', '.ts', '.html', '.css', '.conf', '.cfg', '.ini',
            '.env', '.example', '.template', '.xml', '.dockerfile'
        }
        
        # Directories to skip
        self.skip_dirs = {
            '.git', '__pycache__', 'node_modules', '.venv', 'venv',
            '.docker', 'logs', 'temp', 'tmp'
        }
        
        # Files to skip
        self.skip_files = {
            'search_rebrand_terms.py',  # Skip this script itself
            '.gitignore', '.dockerignore'
        }

    def should_skip_path(self, path: Path) -> bool:
        """Check if path should be skipped"""
        # Skip directories
        if path.is_dir() and path.name in self.skip_dirs:
            return True
            
        # Skip files
        if path.is_file() and path.name in self.skip_files:
            return True
            
        # Skip files without extension or with unsupported extensions
        if path.is_file() and path.suffix not in self.search_extensions and not path.suffix == '':
            return True
            
        return False

    def search_file(self, file_path: Path) -> List[Tuple[int, str, str]]:
        """Search for patterns in a single file"""
        matches = []
        
        try:
            # Try different encodings
            for encoding in ['utf-8', 'latin-1', 'cp1252']:
                try:
                    with open(file_path, 'r', encoding=encoding) as f:
                        lines = f.readlines()
                    break
                except UnicodeDecodeError:
                    continue
            else:
                print(f"Warning: Could not decode {file_path}")
                return matches
                
            for line_num, line in enumerate(lines, 1):
                for pattern in self.search_patterns:
                    for match in re.finditer(pattern, line, re.IGNORECASE):
                        matches.append((line_num, match.group(), line.strip()))
                        
        except Exception as e:
            print(f"Error reading {file_path}: {e}")
            
        return matches

    def search_repository(self) -> Dict:
        """Search entire repository for rebranding terms"""
        print(f"Searching repository: {self.root_dir.absolute()}")
        print(f"Looking for patterns: {', '.join(self.search_patterns)}")
        print("-" * 60)
        
        total_files = 0
        files_with_matches = 0
        total_matches = 0
        
        for root, dirs, files in os.walk(self.root_dir):
            root_path = Path(root)
            
            # Skip unwanted directories
            dirs[:] = [d for d in dirs if not self.should_skip_path(root_path / d)]
            
            for file_name in files:
                file_path = root_path / file_name
                
                if self.should_skip_path(file_path):
                    continue
                    
                total_files += 1
                matches = self.search_file(file_path)
                
                if matches:
                    files_with_matches += 1
                    total_matches += len(matches)
                    
                    # Store relative path for cleaner output
                    rel_path = file_path.relative_to(self.root_dir)
                    self.results[str(rel_path)] = matches
                    
                    print(f"\n[FILE] {rel_path}")
                    for line_num, matched_text, line_content in matches:
                        print(f"  Line {line_num:3d}: {matched_text} -> {line_content}")
        
        print(f"\n" + "=" * 60)
        print(f"SEARCH SUMMARY:")
        print(f"Files searched: {total_files}")
        print(f"Files with matches: {files_with_matches}")
        print(f"Total matches found: {total_matches}")
        
        return {
            'summary': {
                'files_searched': total_files,
                'files_with_matches': files_with_matches,
                'total_matches': total_matches
            },
            'matches': self.results
        }

    def save_results(self, output_file: str = "rebrand_search_results.json"):
        """Save results to JSON file"""
        if self.results:
            with open(output_file, 'w', encoding='utf-8') as f:
                json.dump({
                    'summary': {
                        'files_with_matches': len(self.results),
                        'total_matches': sum(len(matches) for matches in self.results.values())
                    },
                    'matches': self.results
                }, f, indent=2, ensure_ascii=False)
            print(f"\nResults saved to: {output_file}")

    def generate_replacement_script(self):
        """Generate a replacement script template"""
        script_content = '''#!/usr/bin/env python3
"""
Auto-generated replacement script for rebranding
Edit the replacement mappings below and run to perform bulk replacements
"""

import re
from pathlib import Path

# Define your replacement mappings
REPLACEMENTS = {
    r'\\bhomelabarr\\b': 'homelabarr-cli',  # Replace with your new name
    r'\\bmrdoob\\b': 'your-new-username',    # Replace with your new username
    r'\\bMrDoob\\b': 'YourNewUsername',      # Replace with your new username (capitalized)
    r'\\bHomelabarr\\b': 'HomelabARR-CLI'    # Replace with your new name (capitalized)
}

def replace_in_file(file_path: Path):
    """Replace terms in a single file"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original_content = content
        for pattern, replacement in REPLACEMENTS.items():
            content = re.sub(pattern, replacement, content, flags=re.IGNORECASE)
        
        if content != original_content:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"Updated: {file_path}")
            return True
    except Exception as e:
        print(f"Error processing {file_path}: {e}")
    
    return False

# Add your file processing logic here
# Remember to test on a backup first!
'''
        
        with open('replace_rebrand_terms.py', 'w', encoding='utf-8') as f:
            f.write(script_content)
        print("Generated replacement script template: replace_rebrand_terms.py")

def main():
    """Main execution function"""
    searcher = RebrandSearch()
    results = searcher.search_repository()
    
    if results['matches']:
        searcher.save_results()
        searcher.generate_replacement_script()
        
        print(f"\nREBRANDING CHECKLIST:")
        print(f"1. Review the search results above")
        print(f"2. Check rebrand_search_results.json for complete details")
        print(f"3. Edit replace_rebrand_terms.py with your new brand terms")
        print(f"4. Test replacement script on a backup copy first")
        print(f"5. Run replacement script to perform bulk updates")
    else:
        print("\nNo rebranding terms found!")

if __name__ == "__main__":
    main()
