#!/usr/bin/env python3
"""
Remove Claude Code attributions from git commits and files
This script removes the attribution footer from git commit messages and any files
"""

import os
import re
import subprocess
import sys
from pathlib import Path

def run_git_command(command, cwd=None):
    """Run a git command and return the output"""
    try:
        result = subprocess.run(command, shell=True, capture_output=True, text=True, cwd=cwd)
        if result.returncode != 0:
            print(f"Git command failed: {command}")
            print(f"Error: {result.stderr}")
            return None
        return result.stdout.strip()
    except Exception as e:
        print(f"Error running git command: {e}")
        return None

def remove_attributions_from_files(repo_path):
    """Remove Claude attributions from any files that contain them"""
    print("Searching for files with Claude attributions...")
    
    claude_patterns = [
        r'🤖 Generated with \[Claude Code\]\(https://claude\.ai/code\)',
        r'Co-Authored-By: Claude <noreply@anthropic\.com>',
        r'\n\n🤖 Generated with \[Claude Code\].*?\n\nCo-Authored-By: Claude <noreply@anthropic\.com>',
        r'🤖 Generated with \[Claude Code\].*?Co-Authored-By: Claude <noreply@anthropic\.com>',
    ]
    
    files_modified = 0
    
    # Search through all text files in the repository
    for root, dirs, files in os.walk(repo_path):
        # Skip .git directory and backup directories
        if '.git' in root or 'backup' in root.lower():
            continue
            
        for file in files:
            file_path = os.path.join(root, file)
            
            # Only process text files
            if not file.endswith(('.md', '.txt', '.py', '.sh', '.yml', '.yaml', '.json', '.xml')):
                continue
                
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                original_content = content
                
                # Apply all patterns
                for pattern in claude_patterns:
                    content = re.sub(pattern, '', content, flags=re.DOTALL | re.MULTILINE)
                
                # Clean up any double newlines that might be left
                content = re.sub(r'\n\n\n+', '\n\n', content)
                content = content.rstrip() + '\n' if content.rstrip() else ''
                
                # Only write if content changed
                if content != original_content:
                    with open(file_path, 'w', encoding='utf-8') as f:
                        f.write(content)
                    
                    rel_path = os.path.relpath(file_path, repo_path)
                    print(f"  Cleaned: {rel_path}")
                    files_modified += 1
                    
            except (UnicodeDecodeError, PermissionError):
                # Skip binary files or files we can't read
                continue
            except Exception as e:
                print(f"Error processing {file_path}: {e}")
                continue
    
    print(f"Modified {files_modified} files")
    return files_modified > 0

def amend_last_commit(repo_path):
    """Amend the last commit to remove Claude attribution"""
    print("Checking last commit for Claude attribution...")
    
    # Get the last commit message
    last_commit_msg = run_git_command("git log -1 --pretty=format:%B", repo_path)
    
    if not last_commit_msg:
        print("Could not get last commit message")
        return False
    
    # Check if it contains Claude attribution
    claude_patterns = [
        r'🤖 Generated with \[Claude Code\].*?Co-Authored-By: Claude <noreply@anthropic\.com>',
        r'🤖 Generated with \[Claude Code\]\(https://claude\.ai/code\)',
        r'Co-Authored-By: Claude <noreply@anthropic\.com>',
    ]
    
    has_attribution = False
    for pattern in claude_patterns:
        if re.search(pattern, last_commit_msg, re.DOTALL | re.MULTILINE):
            has_attribution = True
            break
    
    if not has_attribution:
        print("Last commit does not contain Claude attribution")
        return True
    
    print("Found Claude attribution in last commit, removing...")
    
    # Clean the commit message
    cleaned_msg = last_commit_msg
    for pattern in claude_patterns:
        cleaned_msg = re.sub(pattern, '', cleaned_msg, flags=re.DOTALL | re.MULTILINE)
    
    # Clean up whitespace
    cleaned_msg = re.sub(r'\n\n\n+', '\n\n', cleaned_msg)
    cleaned_msg = cleaned_msg.rstrip()
    
    # Write cleaned message to temp file
    temp_msg_file = os.path.join(repo_path, 'temp_commit_msg.txt')
    try:
        with open(temp_msg_file, 'w', encoding='utf-8') as f:
            f.write(cleaned_msg)
        
        # Amend the commit with the cleaned message
        amend_cmd = f'git commit --amend -F "{temp_msg_file}"'
        result = run_git_command(amend_cmd, repo_path)
        
        if result is not None:
            print("Successfully amended last commit")
            return True
        else:
            print("Failed to amend last commit")
            return False
            
    finally:
        # Clean up temp file
        if os.path.exists(temp_msg_file):
            os.remove(temp_msg_file)

def main():
    """Main function to remove Claude attributions"""
    repo_path = os.getcwd()
    
    print("Claude Attribution Removal Tool")
    print("=" * 50)
    print(f"Working directory: {repo_path}")
    
    # Check if we're in a git repository
    if not os.path.exists(os.path.join(repo_path, '.git')):
        print("Error: Not in a git repository")
        sys.exit(1)
    
    # Auto-proceed since we're in non-interactive mode
    print("\nWARNING: This script will modify files and potentially amend the last commit!")
    print("Proceeding automatically...")
    print("Backup available in git history if needed.")
    
    success = True
    
    # Remove attributions from files
    print("\nStep 1: Removing attributions from files...")
    files_changed = remove_attributions_from_files(repo_path)
    
    if files_changed:
        # Stage the changes
        run_git_command("git add .", repo_path)
        print("Staged file changes")
        
        # Amend the last commit if it has attribution
        print("\nStep 2: Checking and cleaning last commit...")
        if not amend_last_commit(repo_path):
            success = False
    else:
        # Still check the last commit even if no files changed
        print("\nStep 2: Checking and cleaning last commit...")
        if not amend_last_commit(repo_path):
            success = False
    
    if success:
        print("\nSuccessfully removed Claude attributions!")
        if files_changed:
            print("Note: Changes have been staged and last commit amended.")
            print("Use 'git push --force-with-lease' if you need to update a remote repository.")
    else:
        print("\nSome operations failed. Check the output above for details.")
    
    return success

if __name__ == "__main__":
    main()
