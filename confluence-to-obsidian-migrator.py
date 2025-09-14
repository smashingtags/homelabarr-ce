#!/usr/bin/env python3
"""
Confluence to Obsidian Migration Tool for HomelabARR CLI
========================================================

This script automates the migration of Confluence documentation to Obsidian
using available MCP Confluence tools. It preserves metadata, dating, and
organizes content in a structured way.

Requirements:
- Confluence Premium access (MCP Confluence tools)
- Python 3.8+
- Access to HomelabARR CLI Confluence space (DO)

Author: HomelabARR CLI Team
Created: 2025-01-14
"""

import json
import os
import re
import subprocess
import sys
from datetime import datetime, timedelta
from pathlib import Path
from typing import Dict, List, Optional, Tuple
import time

class ConfluenceToObsidianMigrator:
    """Main migration class that handles the complete workflow."""

    def __init__(self, obsidian_vault_path: str, confluence_space: str = "DO"):
        """Initialize the migrator with target paths."""
        self.obsidian_vault_path = Path(obsidian_vault_path)
        self.confluence_space = confluence_space
        self.migration_log = []
        self.processed_pages = set()

        # Create base directory structure
        self.setup_obsidian_directories()

    def setup_obsidian_directories(self):
        """Create the Obsidian vault directory structure."""
        directories = [
            "Confluence Migration",
            "Confluence Migration/HomelabARR CLI",
            "Confluence Migration/HomelabARR CLI/Installation",
            "Confluence Migration/HomelabARR CLI/Applications",
            "Confluence Migration/HomelabARR CLI/Project Management",
            "Confluence Migration/HomelabARR CLI/Security",
            "Confluence Migration/HomelabARR CLI/Maintenance",
            "Confluence Migration/HomelabARR CLI/Troubleshooting",
            "Confluence Migration/_attachments",
            "Confluence Migration/_metadata"
        ]

        for directory in directories:
            (self.obsidian_vault_path / directory).mkdir(parents=True, exist_ok=True)

        print(f"✅ Created Obsidian directory structure at {self.obsidian_vault_path}")

    def call_mcp_tool(self, tool_name: str, **kwargs) -> Dict:
        """Call MCP tools via subprocess to get Confluence data."""
        try:
            # Build the MCP command
            cmd_args = [f"mcp__MCP_DOCKER__{tool_name}"]

            for key, value in kwargs.items():
                if isinstance(value, bool):
                    cmd_args.append(f"--{key}")
                elif isinstance(value, (int, float)):
                    cmd_args.extend([f"--{key}", str(value)])
                elif isinstance(value, str):
                    cmd_args.extend([f"--{key}", value])

            print(f"🔍 Calling MCP tool: {' '.join(cmd_args)}")

            # Execute the command
            result = subprocess.run(
                cmd_args,
                capture_output=True,
                text=True,
                timeout=60
            )

            if result.returncode == 0:
                # Parse JSON response if possible
                try:
                    return json.loads(result.stdout)
                except json.JSONDecodeError:
                    return {"content": result.stdout, "raw_output": True}
            else:
                print(f"❌ MCP tool error: {result.stderr}")
                return {"error": result.stderr}

        except subprocess.TimeoutExpired:
            print(f"⏰ MCP tool timed out: {tool_name}")
            return {"error": "timeout"}
        except Exception as e:
            print(f"❌ Error calling MCP tool: {str(e)}")
            return {"error": str(e)}

    def search_confluence_pages(self, date_filter: Optional[str] = None) -> List[Dict]:
        """Search for Confluence pages with optional date filtering."""
        print("🔍 Searching for Confluence pages...")

        # Build JQL-style query for Confluence
        query = f"space = {self.confluence_space}"

        if date_filter:
            query += f" AND lastModified >= {date_filter}"

        # Use MCP Confluence search
        result = self.call_mcp_tool(
            "confluence_search",
            query=query,
            limit=100,
            spaces_filter=self.confluence_space
        )

        if "error" in result:
            print(f"❌ Error searching Confluence: {result['error']}")
            return []

        pages = result.get("results", [])
        print(f"📄 Found {len(pages)} pages in Confluence space '{self.confluence_space}'")

        return pages

    def get_page_content(self, page_id: str) -> Optional[Dict]:
        """Get the full content of a Confluence page."""
        print(f"📖 Fetching content for page ID: {page_id}")

        result = self.call_mcp_tool(
            "confluence_get_page",
            page_id=page_id,
            convert_to_markdown=True,
            include_metadata=True
        )

        if "error" in result:
            print(f"❌ Error getting page content: {result['error']}")
            return None

        return result

    def get_page_children(self, page_id: str) -> List[Dict]:
        """Get child pages of a parent page."""
        print(f"👶 Fetching child pages for page ID: {page_id}")

        result = self.call_mcp_tool(
            "confluence_get_page_children",
            page_id=page_id
        )

        if "error" in result:
            print(f"❌ Error getting child pages: {result['error']}")
            return []

        return result.get("results", [])

    def sanitize_filename(self, title: str) -> str:
        """Sanitize page title for use as filename."""
        # Remove/replace invalid characters for filenames
        sanitized = re.sub(r'[<>:"/\\|?*]', '-', title)
        sanitized = re.sub(r'\s+', ' ', sanitized)  # Normalize spaces
        sanitized = sanitized.strip()

        # Limit length to avoid filesystem issues
        if len(sanitized) > 200:
            sanitized = sanitized[:200] + "..."

        return sanitized

    def convert_confluence_links(self, content: str, page_mapping: Dict[str, str]) -> str:
        """Convert Confluence internal links to Obsidian wikilinks."""
        # Pattern for Confluence page links
        confluence_link_pattern = r'\[([^\]]+)\]\(.*?pageId=(\d+).*?\)'

        def replace_link(match):
            link_text = match.group(1)
            page_id = match.group(2)

            if page_id in page_mapping:
                obsidian_filename = page_mapping[page_id]
                return f'[[{obsidian_filename}|{link_text}]]'
            else:
                return f'[{link_text}](Confluence Page ID: {page_id})'

        return re.sub(confluence_link_pattern, replace_link, content)

    def add_obsidian_metadata(self, content: str, page_info: Dict) -> str:
        """Add Obsidian-style YAML frontmatter with Confluence metadata."""
        metadata = {
            "confluence_page_id": page_info.get("id"),
            "confluence_space": page_info.get("space", {}).get("key"),
            "original_title": page_info.get("title"),
            "created_date": page_info.get("version", {}).get("when"),
            "last_modified": page_info.get("version", {}).get("when"),
            "confluence_url": page_info.get("_links", {}).get("webui"),
            "migrated_date": datetime.now().isoformat(),
            "tags": ["confluence-migration", "homelabarr-cli"]
        }

        # Add labels as tags if available
        if "metadata" in page_info and "labels" in page_info["metadata"]:
            labels = page_info["metadata"]["labels"].get("results", [])
            for label in labels:
                metadata["tags"].append(f"confluence-{label.get('name', '')}")

        # Create YAML frontmatter
        yaml_frontmatter = "---\n"
        for key, value in metadata.items():
            if value:  # Only include non-empty values
                if isinstance(value, list):
                    yaml_frontmatter += f"{key}:\n"
                    for item in value:
                        yaml_frontmatter += f"  - {item}\n"
                else:
                    yaml_frontmatter += f"{key}: {value}\n"
        yaml_frontmatter += "---\n\n"

        return yaml_frontmatter + content

    def organize_page_by_content(self, title: str, content: str) -> str:
        """Determine the appropriate subdirectory based on content analysis."""
        title_lower = title.lower()
        content_lower = content.lower()

        # Define categorization rules
        categories = {
            "Installation": ["install", "setup", "ubuntu", "debian", "docker", "prerequisite"],
            "Applications": ["plex", "sonarr", "radarr", "jellyfin", "application", "container", "compose"],
            "Project Management": ["jira", "sprint", "workflow", "project", "management", "planning"],
            "Security": ["authelia", "ssl", "certificate", "security", "authentication", "authorization"],
            "Maintenance": ["backup", "maintenance", "cleanup", "optimize", "monitoring"],
            "Troubleshooting": ["troubleshoot", "debug", "error", "problem", "issue", "fix"]
        }

        for category, keywords in categories.items():
            if any(keyword in title_lower or keyword in content_lower for keyword in keywords):
                return f"HomelabARR CLI/{category}"

        # Default category
        return "HomelabARR CLI"

    def save_page_to_obsidian(self, page_info: Dict, content: str, page_mapping: Dict[str, str]) -> str:
        """Save a single page to Obsidian vault."""
        title = page_info.get("title", "Untitled")
        page_id = page_info.get("id")

        # Sanitize filename
        filename = self.sanitize_filename(title) + ".md"

        # Determine category/subdirectory
        category = self.organize_page_by_content(title, content)

        # Convert Confluence links to Obsidian wikilinks
        content = self.convert_confluence_links(content, page_mapping)

        # Add Obsidian metadata
        content_with_metadata = self.add_obsidian_metadata(content, page_info)

        # Full file path
        file_path = self.obsidian_vault_path / "Confluence Migration" / category / filename

        # Ensure directory exists
        file_path.parent.mkdir(parents=True, exist_ok=True)

        # Write file
        try:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content_with_metadata)

            print(f"✅ Saved: {file_path}")
            self.migration_log.append({
                "page_id": page_id,
                "title": title,
                "filename": filename,
                "category": category,
                "file_path": str(file_path),
                "migrated_at": datetime.now().isoformat()
            })

            return filename

        except Exception as e:
            print(f"❌ Error saving page '{title}': {str(e)}")
            return ""

    def migrate_pages(self, date_filter: Optional[str] = None) -> bool:
        """Main migration function."""
        print("🚀 Starting Confluence to Obsidian migration...")
        print(f"📁 Target directory: {self.obsidian_vault_path}")
        print(f"🏢 Confluence space: {self.confluence_space}")

        # Step 1: Search for pages
        pages = self.search_confluence_pages(date_filter)

        if not pages:
            print("❌ No pages found to migrate")
            return False

        # Step 2: Build page mapping for link conversion
        print("🗺️ Building page ID to filename mapping...")
        page_mapping = {}

        # Step 3: Process each page
        successful_migrations = 0

        for i, page_summary in enumerate(pages, 1):
            page_id = page_summary.get("id")
            title = page_summary.get("title", "Untitled")

            print(f"\n📄 Processing page {i}/{len(pages)}: {title}")

            if page_id in self.processed_pages:
                print(f"⏭️ Skipping already processed page: {page_id}")
                continue

            # Get full page content
            page_content = self.get_page_content(page_id)

            if not page_content:
                print(f"⚠️ Could not retrieve content for page: {title}")
                continue

            # Extract markdown content
            content = page_content.get("body", {}).get("storage", {}).get("value", "")
            if not content:
                content = page_content.get("content", "No content available")

            # Save to Obsidian
            filename = self.save_page_to_obsidian(page_content, content, page_mapping)

            if filename:
                page_mapping[page_id] = filename.replace(".md", "")
                successful_migrations += 1
                self.processed_pages.add(page_id)

            # Small delay to avoid API rate limits
            time.sleep(0.5)

        # Step 4: Generate migration report
        self.generate_migration_report(successful_migrations, len(pages))

        print(f"\n🎉 Migration completed!")
        print(f"✅ Successfully migrated: {successful_migrations}/{len(pages)} pages")

        return successful_migrations > 0

    def generate_migration_report(self, successful: int, total: int):
        """Generate a detailed migration report."""
        report_content = f"""# Confluence to Obsidian Migration Report

## Migration Summary
- **Migration Date**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
- **Confluence Space**: {self.confluence_space}
- **Total Pages Found**: {total}
- **Successfully Migrated**: {successful}
- **Failed Migrations**: {total - successful}

## Migrated Pages

"""

        for log_entry in self.migration_log:
            report_content += f"### {log_entry['title']}\n"
            report_content += f"- **Page ID**: {log_entry['page_id']}\n"
            report_content += f"- **Category**: {log_entry['category']}\n"
            report_content += f"- **Filename**: {log_entry['filename']}\n"
            report_content += f"- **Migrated**: {log_entry['migrated_at']}\n\n"

        report_content += f"""## Next Steps

1. **Review Content**: Check migrated pages for formatting issues
2. **Update Links**: Some Confluence links may need manual adjustment
3. **Organize Structure**: Consider reorganizing pages within Obsidian
4. **Add Cross-References**: Create additional wikilinks between related pages
5. **Update Tags**: Add more specific tags for better organization

## Migration Settings Used
- **Obsidian Vault**: {self.obsidian_vault_path}
- **Confluence Space**: {self.confluence_space}
- **Preserve Metadata**: Yes
- **Convert Links**: Yes
- **Auto-Categorization**: Yes

---
*Generated by HomelabARR CLI Confluence Migration Tool*
"""

        # Save report
        report_path = self.obsidian_vault_path / "Confluence Migration" / "_metadata" / "migration-report.md"

        try:
            with open(report_path, 'w', encoding='utf-8') as f:
                f.write(report_content)
            print(f"📊 Migration report saved: {report_path}")
        except Exception as e:
            print(f"⚠️ Could not save migration report: {str(e)}")

def main():
    """Main function to run the migration."""
    print("=" * 60)
    print("HomelabARR CLI: Confluence to Obsidian Migrator")
    print("=" * 60)

    # Configuration
    DEFAULT_OBSIDIAN_PATH = "/mnt/f/Coding Projects/homelabarr-ce/.claude/obsidian-vault"
    DEFAULT_SPACE = "DO"

    # Get user input
    obsidian_path = input(f"Enter Obsidian vault path [{DEFAULT_OBSIDIAN_PATH}]: ").strip()
    if not obsidian_path:
        obsidian_path = DEFAULT_OBSIDIAN_PATH

    confluence_space = input(f"Enter Confluence space key [{DEFAULT_SPACE}]: ").strip()
    if not confluence_space:
        confluence_space = DEFAULT_SPACE

    # Date filtering option
    print("\n📅 Date Filtering Options:")
    print("1. All pages (no date filter)")
    print("2. Pages modified since July 2024")
    print("3. Pages modified since August 2024")
    print("4. Custom date (YYYY-MM-DD)")

    choice = input("Choose an option [1]: ").strip()
    date_filter = None

    if choice == "2":
        date_filter = "2024-07-01"
    elif choice == "3":
        date_filter = "2024-08-01"
    elif choice == "4":
        custom_date = input("Enter date (YYYY-MM-DD): ").strip()
        if custom_date:
            date_filter = custom_date

    # Confirm settings
    print(f"\n🔧 Migration Settings:")
    print(f"   Obsidian Vault: {obsidian_path}")
    print(f"   Confluence Space: {confluence_space}")
    print(f"   Date Filter: {date_filter or 'None (all pages)'}")

    confirm = input("\nProceed with migration? [y/N]: ").strip().lower()
    if confirm != 'y':
        print("❌ Migration cancelled")
        return

    # Initialize and run migration
    try:
        migrator = ConfluenceToObsidianMigrator(obsidian_path, confluence_space)
        success = migrator.migrate_pages(date_filter)

        if success:
            print("\n🎉 Migration completed successfully!")
            print(f"📁 Check your Obsidian vault at: {obsidian_path}")
        else:
            print("\n❌ Migration failed or no content found")

    except KeyboardInterrupt:
        print("\n\n⏹️ Migration interrupted by user")
    except Exception as e:
        print(f"\n❌ Migration failed with error: {str(e)}")

if __name__ == "__main__":
    main()