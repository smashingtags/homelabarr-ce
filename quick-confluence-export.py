#!/usr/bin/env python3
"""
Quick Confluence Export for HomelabARR CLI
==========================================

A simplified version that directly uses available MCP tools to export
Confluence pages to Obsidian-compatible Markdown format.

This script works with the current MCP Docker setup and available
Confluence tools as documented in MCP_TOOLS_REFERENCE.md
"""

import json
import os
import re
import subprocess
import sys
from datetime import datetime
from pathlib import Path
from typing import Dict, List

def run_mcp_command(command_parts: List[str]) -> Dict:
    """Run MCP command and return parsed result."""
    try:
        print(f"🔧 Running: {' '.join(command_parts)}")

        result = subprocess.run(
            command_parts,
            capture_output=True,
            text=True,
            shell=False,
            timeout=30
        )

        if result.returncode == 0:
            try:
                return json.loads(result.stdout)
            except json.JSONDecodeError:
                return {"content": result.stdout, "success": True}
        else:
            print(f"❌ Error: {result.stderr}")
            return {"error": result.stderr}

    except Exception as e:
        print(f"❌ Exception: {str(e)}")
        return {"error": str(e)}

def search_confluence_pages(space_key: str = "DO", query: str = "") -> List[Dict]:
    """Search Confluence pages using MCP tool."""
    print(f"🔍 Searching Confluence space '{space_key}' for: '{query}'")

    # Use the documented MCP Confluence search tool
    command = [
        "mcp__MCP_DOCKER__confluence_search",
        "--query", query or "HomelabARR",
        "--limit", "50"
    ]

    result = run_mcp_command(command)

    if "error" in result:
        print(f"❌ Search failed: {result['error']}")
        return []

    pages = result.get("results", [])
    print(f"📄 Found {len(pages)} pages")
    return pages

def get_page_content(page_id: str) -> Dict:
    """Get page content using MCP tool."""
    print(f"📖 Fetching page content for ID: {page_id}")

    command = [
        "mcp__MCP_DOCKER__confluence_get_page",
        "--page_id", page_id,
        "--include_metadata", "true"
    ]

    result = run_mcp_command(command)
    return result

def sanitize_filename(title: str) -> str:
    """Create a safe filename from page title."""
    # Remove invalid characters
    safe_title = re.sub(r'[<>:"/\\|?*]', '-', title)
    safe_title = re.sub(r'\s+', ' ', safe_title).strip()

    # Limit length
    if len(safe_title) > 200:
        safe_title = safe_title[:200] + "..."

    return safe_title

def create_obsidian_note(page_data: Dict, output_dir: Path) -> str:
    """Create an Obsidian-compatible note from Confluence page data."""

    title = page_data.get("title", "Untitled")
    page_id = page_data.get("id", "unknown")

    # Get content from various possible locations
    content = ""

    if "body" in page_data:
        if "storage" in page_data["body"]:
            content = page_data["body"]["storage"].get("value", "")
        elif "view" in page_data["body"]:
            content = page_data["body"]["view"].get("value", "")
    elif "content" in page_data:
        content = page_data["content"]

    if not content:
        content = "*(No content available)*"

    # Create YAML frontmatter
    frontmatter = f"""---
title: "{title}"
confluence_page_id: {page_id}
confluence_space: DO
migrated_date: {datetime.now().isoformat()}
original_url: {page_data.get('_links', {}).get('webui', 'N/A')}
tags:
  - confluence-migration
  - homelabarr-cli
---

"""

    # Clean up HTML content for Markdown
    if content.startswith("<!DOCTYPE html>") or "<html" in content:
        # Try to extract readable content from HTML
        content = extract_text_from_html(content)

    # Combine frontmatter and content
    full_content = frontmatter + f"# {title}\n\n" + content

    # Create filename
    filename = sanitize_filename(title) + ".md"
    filepath = output_dir / filename

    # Write file
    try:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(full_content)

        print(f"✅ Created: {filepath}")
        return str(filepath)

    except Exception as e:
        print(f"❌ Failed to write {filename}: {str(e)}")
        return ""

def extract_text_from_html(html_content: str) -> str:
    """Extract readable text from HTML content."""
    # Simple HTML tag removal (not perfect but functional)
    import html

    # Decode HTML entities
    text = html.unescape(html_content)

    # Remove script and style elements
    text = re.sub(r'<(script|style)[^>]*>.*?</\1>', '', text, flags=re.DOTALL | re.IGNORECASE)

    # Convert common HTML elements to Markdown
    text = re.sub(r'<h([1-6])[^>]*>(.*?)</h[1-6]>', lambda m: '#' * int(m.group(1)) + ' ' + m.group(2) + '\n', text)
    text = re.sub(r'<p[^>]*>(.*?)</p>', r'\1\n\n', text)
    text = re.sub(r'<strong[^>]*>(.*?)</strong>', r'**\1**', text)
    text = re.sub(r'<em[^>]*>(.*?)</em>', r'*\1*', text)
    text = re.sub(r'<code[^>]*>(.*?)</code>', r'`\1`', text)
    text = re.sub(r'<pre[^>]*>(.*?)</pre>', r'```\n\1\n```', text, flags=re.DOTALL)

    # Remove remaining HTML tags
    text = re.sub(r'<[^>]+>', '', text)

    # Clean up whitespace
    text = re.sub(r'\n\s*\n\s*\n', '\n\n', text)
    text = text.strip()

    return text

def main():
    """Main function."""
    print("=" * 60)
    print("HomelabARR CLI: Quick Confluence Export")
    print("=" * 60)

    # Setup output directory
    default_output = "/mnt/f/Coding Projects/homelabarr-ce/.claude/confluence-export"
    output_path = input(f"Output directory [{default_output}]: ").strip()
    if not output_path:
        output_path = default_output

    output_dir = Path(output_path)
    output_dir.mkdir(parents=True, exist_ok=True)

    print(f"📁 Output directory: {output_dir}")

    # Get search parameters
    print("\n🔍 Search Options:")
    print("1. All pages (search for 'HomelabARR')")
    print("2. Recent pages (search for recent content)")
    print("3. Specific search term")
    print("4. Just export known key pages")

    choice = input("Choose option [1]: ").strip()

    if choice == "2":
        search_query = "lastModified >= 2024-07-01"
    elif choice == "3":
        search_query = input("Enter search term: ").strip()
    elif choice == "4":
        # Export specific key pages
        key_pages = [
            "3899503",  # HomelabARR CLI Home
            "3866629",  # Installation Guide
            "3866648",  # Application Categories
            "3866689"   # Project Management
        ]

        print(f"📋 Exporting {len(key_pages)} key pages...")

        successful = 0
        for page_id in key_pages:
            page_data = get_page_content(page_id)
            if "error" not in page_data:
                if create_obsidian_note(page_data, output_dir):
                    successful += 1
            else:
                print(f"❌ Failed to get page {page_id}: {page_data.get('error')}")

        print(f"\n🎉 Exported {successful}/{len(key_pages)} key pages")
        return
    else:
        search_query = "HomelabARR"

    # Search for pages
    pages = search_confluence_pages("DO", search_query)

    if not pages:
        print("❌ No pages found")
        return

    # Export each page
    print(f"\n📤 Exporting {len(pages)} pages...")
    successful = 0

    for i, page_summary in enumerate(pages, 1):
        page_id = page_summary.get("id")
        title = page_summary.get("title", f"Page {i}")

        print(f"\n[{i}/{len(pages)}] Processing: {title}")

        # Get full page content
        page_data = get_page_content(page_id)

        if "error" in page_data:
            print(f"❌ Failed to get content: {page_data['error']}")
            continue

        # Create Obsidian note
        if create_obsidian_note(page_data, output_dir):
            successful += 1

    print(f"\n🎉 Export completed!")
    print(f"✅ Successfully exported: {successful}/{len(pages)} pages")
    print(f"📁 Files saved to: {output_dir}")

    # Create an index file
    create_index_file(output_dir, successful, len(pages))

def create_index_file(output_dir: Path, successful: int, total: int):
    """Create an index file for the exported content."""

    index_content = f"""# Confluence Export Index

**Export Date**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
**Total Pages**: {total}
**Successfully Exported**: {successful}
**Export Location**: {output_dir}

## Exported Files

"""

    # List all .md files in the directory
    md_files = sorted(output_dir.glob("*.md"))

    for md_file in md_files:
        if md_file.name != "00-export-index.md":
            # Remove .md extension for cleaner wikilink
            page_name = md_file.stem
            index_content += f"- [[{page_name}]]\n"

    index_content += f"""

## Usage Instructions

1. **Import to Obsidian**: Copy these files to your Obsidian vault
2. **Review Content**: Check pages for formatting issues
3. **Update Links**: Some internal links may need manual adjustment
4. **Add Tags**: Consider adding more specific tags for organization

## Original Source

These pages were exported from the HomelabARR CLI Confluence space (DO).
Original documentation: https://your-instance.atlassian.net/wiki/spaces/DO/overview

---
*Generated by HomelabARR CLI Confluence Export Tool*
"""

    index_file = output_dir / "00-export-index.md"

    try:
        with open(index_file, 'w', encoding='utf-8') as f:
            f.write(index_content)
        print(f"📊 Index file created: {index_file}")
    except Exception as e:
        print(f"⚠️ Could not create index file: {str(e)}")

if __name__ == "__main__":
    main()