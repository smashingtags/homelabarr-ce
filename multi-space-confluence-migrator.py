#!/usr/bin/env python3
"""
Multi-Space Confluence to Obsidian Migration Tool for HomelabARR CLI
=====================================================================

This script handles migration from multiple Confluence spaces to Obsidian
with date-based filtering and space-specific organization.

Targeted Spaces:
- HLCLI space (hlcli) - HomelabARR CLI documentation  
- HC space (HC) - Additional related documentation

Features:
- Date filtering (July/August 2024 onwards)
- Space-specific organization in Obsidian
- Bulk migration with preservation of metadata
- MCP tools integration for automated export

Requirements:
- Confluence Premium access (3 days remaining)
- MCP tools configured with confluence_search and confluence_get_page
- Python 3.8+

Author: HomelabARR CLI Documentation Team
Created: 2025-01-14 (Updated for multi-space migration)
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

class MultiSpaceConfluenceMigrator:
    """Enhanced migration class that handles multiple Confluence spaces."""

    def __init__(self, obsidian_vault_path: str, target_spaces: List[str]):
        """Initialize the migrator for multiple spaces.
        
        Args:
            obsidian_vault_path: Path to Obsidian vault
            target_spaces: List of Confluence space keys to migrate
        """
        self.obsidian_vault_path = Path(obsidian_vault_path)
        self.target_spaces = target_spaces
        self.migration_log = []
        self.processed_pages = set()
        self.space_statistics = {}
        
        # Date filtering configuration
        self.date_filter_enabled = True
        self.filter_start_date = "2024-07-01"  # July/August 2024 onwards
        
        # Setup directory structure
        self.setup_obsidian_directories()

    def setup_obsidian_directories(self):
        """Create organized directory structure for multiple spaces."""
        base_directories = [
            "Confluence Migration",
            "Confluence Migration/_metadata",
            "Confluence Migration/_attachments",
            "Confluence Migration/_exports"
        ]
        
        # Create space-specific directories
        space_directories = []
        for space in self.target_spaces:
            space_name = self.get_space_display_name(space)
            space_directories.extend([
                f"Confluence Migration/{space_name}",
                f"Confluence Migration/{space_name}/Installation",
                f"Confluence Migration/{space_name}/Applications",
                f"Confluence Migration/{space_name}/Project Management",
                f"Confluence Migration/{space_name}/Security",
                f"Confluence Migration/{space_name}/Maintenance", 
                f"Confluence Migration/{space_name}/Troubleshooting",
                f"Confluence Migration/{space_name}/Architecture",
                f"Confluence Migration/{space_name}/Development",
                f"Confluence Migration/{space_name}/User Guides"
            ])
        
        all_directories = base_directories + space_directories
        
        for directory in all_directories:
            (self.obsidian_vault_path / directory).mkdir(parents=True, exist_ok=True)
        
        print(f"✅ Created multi-space Obsidian directory structure at {self.obsidian_vault_path}")
        print(f"📁 Target spaces: {', '.join(self.target_spaces)}")

    def get_space_display_name(self, space_key: str) -> str:
        """Convert space key to display name for organization."""
        space_names = {
            "hlcli": "HomelabARR-CLI",
            "HC": "HomelabARR-Community",
            "DO": "HomelabARR-Documentation"  # Fallback for existing space
        }
        return space_names.get(space_key, space_key.upper())

    def call_mcp_tool(self, tool_name: str, **kwargs) -> Dict:
        """Enhanced MCP tool caller with better error handling and logging."""
        try:
            cmd_args = [f"mcp__MCP_DOCKER__{tool_name}"]
            
            for key, value in kwargs.items():
                if isinstance(value, bool) and value:
                    cmd_args.append(f"--{key}")
                elif isinstance(value, (int, float)):
                    cmd_args.extend([f"--{key}", str(value)])
                elif isinstance(value, str) and value:
                    cmd_args.extend([f"--{key}", value])
            
            print(f"🔍 MCP Call: {' '.join(cmd_args)}")
            
            result = subprocess.run(
                cmd_args,
                capture_output=True,
                text=True,
                timeout=90  # Increased timeout for larger operations
            )
            
            if result.returncode == 0:
                try:
                    return json.loads(result.stdout)
                except json.JSONDecodeError:
                    return {"content": result.stdout, "raw_output": True}
            else:
                error_msg = result.stderr or result.stdout
                print(f"❌ MCP Error: {error_msg}")
                return {"error": error_msg}
                
        except subprocess.TimeoutExpired:
            print(f"⏰ MCP tool timed out: {tool_name}")
            return {"error": "timeout"}
        except Exception as e:
            print(f"❌ MCP Exception: {str(e)}")
            return {"error": str(e)}

    def search_space_pages(self, space_key: str, date_filter: Optional[str] = None) -> List[Dict]:
        """Search pages in a specific Confluence space with date filtering."""
        print(f"🔍 Searching space '{space_key}' for pages...")
        
        # Build search query - use space-specific terms
        search_terms = {
            "hlcli": "HomelabARR CLI docker compose traefik",
            "HC": "HomelabARR community documentation",
            "DO": "HomelabARR documentation"  # Fallback
        }
        
        query = search_terms.get(space_key, "HomelabARR")
        
        # Try both search methods for better coverage
        pages_found = []
        
        # Method 1: Direct search with space filtering
        result = self.call_mcp_tool(
            "confluence_search",
            query=query,
            limit=100,
            spaces=space_key  # Try space filtering if supported
        )
        
        if "error" not in result:
            pages_found.extend(result.get("results", []))
        
        # Method 2: General search and filter by space
        if not pages_found:
            result = self.call_mcp_tool(
                "confluence_search", 
                query=f"space:{space_key}",
                limit=100
            )
            
            if "error" not in result:
                all_pages = result.get("results", [])
                # Filter by space key if not already filtered
                for page in all_pages:
                    page_space = page.get("space", {}).get("key", "")
                    if page_space == space_key:
                        pages_found.append(page)
        
        # Date filtering if enabled
        if date_filter and self.date_filter_enabled:
            filtered_pages = self.apply_date_filter(pages_found, date_filter)
            print(f"📅 Date filter applied: {len(pages_found)} → {len(filtered_pages)} pages")
            pages_found = filtered_pages
        
        print(f"📄 Found {len(pages_found)} pages in space '{space_key}'")
        
        # Store statistics
        self.space_statistics[space_key] = {
            "pages_found": len(pages_found),
            "search_query": query,
            "date_filter": date_filter
        }
        
        return pages_found

    def apply_date_filter(self, pages: List[Dict], date_filter: str) -> List[Dict]:
        """Filter pages by modification date."""
        try:
            filter_date = datetime.fromisoformat(date_filter)
            filtered = []
            
            for page in pages:
                # Try to get modification date from various fields
                page_date = None
                
                # Check version info
                if "version" in page and "when" in page["version"]:
                    page_date_str = page["version"]["when"]
                    try:
                        # Handle various date formats
                        if "T" in page_date_str:
                            page_date = datetime.fromisoformat(page_date_str.replace("Z", "+00:00"))
                        else:
                            page_date = datetime.fromisoformat(page_date_str)
                    except:
                        continue
                
                # Check history field
                elif "history" in page and "lastUpdated" in page["history"]:
                    try:
                        page_date = datetime.fromisoformat(page["history"]["lastUpdated"])
                    except:
                        continue
                
                if page_date and page_date >= filter_date:
                    filtered.append(page)
                elif not page_date:  # Include pages without date info to be safe
                    filtered.append(page)
            
            return filtered
            
        except Exception as e:
            print(f"⚠️ Date filtering error: {str(e)}")
            return pages  # Return all pages if filtering fails

    def get_page_content(self, page_id: str, space_key: str) -> Optional[Dict]:
        """Get full content of a Confluence page with enhanced metadata."""
        print(f"📖 Fetching content for page ID: {page_id} (space: {space_key})")
        
        result = self.call_mcp_tool(
            "confluence_get_page",
            page_id=page_id,
            include_metadata=True
        )
        
        if "error" in result:
            print(f"❌ Error getting page content: {result['error']}")
            return None
        
        # Add space information to the result
        result["source_space"] = space_key
        return result

    def sanitize_filename(self, title: str) -> str:
        """Enhanced filename sanitization."""
        # Remove/replace invalid characters
        sanitized = re.sub(r'[<>:"/\\|?*]', '-', title)
        sanitized = re.sub(r'[\r\n\t]', ' ', sanitized)  # Handle line breaks
        sanitized = re.sub(r'\s+', ' ', sanitized).strip()  # Normalize spaces
        
        # Remove leading/trailing periods and spaces
        sanitized = sanitized.strip('. ')
        
        # Limit length
        if len(sanitized) > 200:
            sanitized = sanitized[:197] + "..."
        
        # Ensure we have a valid filename
        if not sanitized or sanitized == "...":
            sanitized = "Untitled"
        
        return sanitized

    def organize_page_by_content(self, title: str, content: str, space_key: str) -> str:
        """Enhanced content-based categorization with space awareness."""
        title_lower = title.lower()
        content_lower = content.lower()[:5000]  # First 5KB for performance
        space_name = self.get_space_display_name(space_key)
        
        # Enhanced categorization rules
        categories = {
            "Installation": [
                "install", "setup", "ubuntu", "debian", "docker", "prerequisite", 
                "system requirements", "dependencies", "getting started", "quickstart"
            ],
            "Applications": [
                "plex", "sonarr", "radarr", "jellyfin", "application", "container", 
                "compose", "media server", "servarr", "automation", "download"
            ],
            "Project Management": [
                "jira", "sprint", "workflow", "project", "management", "planning", 
                "backlog", "story", "epic", "ticket", "roadmap"
            ],
            "Security": [
                "authelia", "ssl", "certificate", "security", "authentication", 
                "authorization", "mfa", "cloudflare", "firewall", "vpn"
            ],
            "Maintenance": [
                "backup", "maintenance", "cleanup", "optimize", "monitoring", 
                "logs", "performance", "update", "upgrade", "migration"
            ],
            "Troubleshooting": [
                "troubleshoot", "debug", "error", "problem", "issue", "fix", 
                "solution", "resolve", "diagnose", "repair"
            ],
            "Architecture": [
                "architecture", "design", "network", "traefik", "proxy", "infrastructure", 
                "topology", "diagram", "overview", "structure"
            ],
            "Development": [
                "development", "coding", "script", "api", "cli", "automation", 
                "integration", "webhook", "github", "ci/cd"
            ],
            "User Guides": [
                "guide", "tutorial", "how to", "user manual", "documentation", 
                "help", "faq", "reference", "walkthrough"
            ]
        }
        
        # Check categories with weighted scoring
        category_scores = {}
        
        for category, keywords in categories.items():
            score = 0
            for keyword in keywords:
                # Title matches get higher weight
                if keyword in title_lower:
                    score += 3
                # Content matches get lower weight  
                if keyword in content_lower:
                    score += 1
            
            if score > 0:
                category_scores[category] = score
        
        # Select category with highest score
        if category_scores:
            best_category = max(category_scores.keys(), key=lambda k: category_scores[k])
            return f"{space_name}/{best_category}"
        
        # Default to space root
        return space_name

    def convert_confluence_links(self, content: str, page_mapping: Dict[str, str]) -> str:
        """Enhanced Confluence to Obsidian link conversion."""
        # Multiple patterns for different link formats
        patterns = [
            r'\[([^\]]+)\]\(.*?pageId=(\d+).*?\)',  # Standard format
            r'\[([^\]]+)\]\(/wiki/spaces/[^/]+/pages/(\d+)/[^)]*\)',  # Wiki format
            r'href="[^"]*pageId=(\d+)[^"]*"[^>]*>([^<]+)</a>',  # HTML links
        ]
        
        def replace_link(match):
            if len(match.groups()) >= 2:
                if match.lastindex == 2:  # Standard pattern
                    link_text, page_id = match.groups()
                else:  # HTML pattern
                    page_id, link_text = match.groups()
                
                if page_id in page_mapping:
                    obsidian_filename = page_mapping[page_id]
                    return f'[[{obsidian_filename}|{link_text}]]'
                else:
                    return f'[{link_text}](Confluence Page ID: {page_id})'
            return match.group(0)
        
        for pattern in patterns:
            content = re.sub(pattern, replace_link, content)
        
        return content

    def add_obsidian_metadata(self, content: str, page_info: Dict, space_key: str) -> str:
        """Enhanced metadata with space-specific information."""
        metadata = {
            "confluence_page_id": page_info.get("id"),
            "confluence_space": space_key,
            "confluence_space_name": self.get_space_display_name(space_key),
            "original_title": page_info.get("title"),
            "created_date": page_info.get("version", {}).get("when"),
            "last_modified": page_info.get("version", {}).get("when"),
            "confluence_url": page_info.get("_links", {}).get("webui"),
            "migrated_date": datetime.now().isoformat(),
            "migration_tool": "multi-space-confluence-migrator",
            "tags": ["confluence-migration", f"space-{space_key.lower()}", "homelabarr-cli"]
        }
        
        # Add version information
        if "version" in page_info:
            version = page_info["version"]
            metadata["version_number"] = version.get("number")
            if "by" in version:
                metadata["last_author"] = version["by"].get("displayName")
        
        # Add labels as tags
        if "metadata" in page_info and "labels" in page_info["metadata"]:
            labels = page_info["metadata"]["labels"].get("results", [])
            for label in labels:
                label_name = label.get("name", "")
                if label_name:
                    metadata["tags"].append(f"label-{label_name}")
        
        # Create YAML frontmatter
        yaml_frontmatter = "---\n"
        for key, value in metadata.items():
            if value is not None:  # Include None check
                if isinstance(value, list):
                    if value:  # Only include non-empty lists
                        yaml_frontmatter += f"{key}:\n"
                        for item in value:
                            yaml_frontmatter += f"  - {item}\n"
                elif isinstance(value, str):
                    # Escape quotes in values
                    escaped_value = value.replace('"', '\\"')
                    yaml_frontmatter += f'{key}: "{escaped_value}"\n'
                else:
                    yaml_frontmatter += f"{key}: {value}\n"
        yaml_frontmatter += "---\n\n"
        
        return yaml_frontmatter + content

    def save_page_to_obsidian(self, page_info: Dict, content: str, page_mapping: Dict[str, str], space_key: str) -> str:
        """Enhanced page saving with space-specific organization."""
        title = page_info.get("title", "Untitled")
        page_id = page_info.get("id")
        
        # Sanitize filename
        filename = self.sanitize_filename(title) + ".md"
        
        # Determine category/subdirectory
        category = self.organize_page_by_content(title, content, space_key)
        
        # Convert links
        content = self.convert_confluence_links(content, page_mapping)
        
        # Add metadata
        content_with_metadata = self.add_obsidian_metadata(content, page_info, space_key)
        
        # Full file path
        file_path = self.obsidian_vault_path / "Confluence Migration" / category / filename
        
        # Ensure unique filename if conflict exists
        counter = 1
        original_path = file_path
        while file_path.exists():
            stem = original_path.stem
            suffix = original_path.suffix
            file_path = original_path.parent / f"{stem}-{counter}{suffix}"
            counter += 1
            if counter > 100:  # Prevent infinite loop
                break
        
        # Ensure directory exists
        file_path.parent.mkdir(parents=True, exist_ok=True)
        
        try:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content_with_metadata)
            
            print(f"✅ Saved: {file_path}")
            
            # Log successful migration
            self.migration_log.append({
                "page_id": page_id,
                "title": title,
                "filename": filename,
                "category": category,
                "space_key": space_key,
                "file_path": str(file_path),
                "migrated_at": datetime.now().isoformat()
            })
            
            return file_path.stem  # Return filename without extension
            
        except Exception as e:
            print(f"❌ Error saving page '{title}': {str(e)}")
            return ""

    def migrate_all_spaces(self, date_filter: Optional[str] = None) -> bool:
        """Main migration function for all target spaces."""
        print("\n🚀 Starting multi-space Confluence to Obsidian migration...")
        print(f"📁 Target directory: {self.obsidian_vault_path}")
        print(f"🏢 Target spaces: {', '.join(self.target_spaces)}")
        print(f"📅 Date filter: {date_filter or 'None (all pages)'}")
        
        total_pages = 0
        total_successful = 0
        all_pages_by_space = {}
        page_mapping = {}  # Global page ID to filename mapping
        
        # Step 1: Search all spaces and collect pages
        print("\n📋 Phase 1: Searching all target spaces...")
        for space_key in self.target_spaces:
            print(f"\n--- Processing Space: {space_key} ---")
            pages = self.search_space_pages(space_key, date_filter)
            all_pages_by_space[space_key] = pages
            total_pages += len(pages)
        
        if total_pages == 0:
            print("❌ No pages found across all spaces")
            return False
        
        print(f"\n📊 Found {total_pages} total pages across {len(self.target_spaces)} spaces")
        
        # Step 2: Process pages from all spaces
        print("\n📄 Phase 2: Processing and migrating pages...")
        
        current_page = 0
        
        for space_key, pages in all_pages_by_space.items():
            if not pages:
                continue
                
            print(f"\n--- Migrating Space: {space_key} ({len(pages)} pages) ---")
            
            for i, page_summary in enumerate(pages, 1):
                current_page += 1
                page_id = page_summary.get("id")
                title = page_summary.get("title", "Untitled")
                
                print(f"\n📄 [{current_page}/{total_pages}] {title} (Space: {space_key})")
                
                if page_id in self.processed_pages:
                    print(f"⏭️ Skipping already processed page: {page_id}")
                    continue
                
                # Get full page content
                page_content = self.get_page_content(page_id, space_key)
                
                if not page_content:
                    print(f"⚠️ Could not retrieve content for page: {title}")
                    continue
                
                # Extract content
                content = self.extract_page_content(page_content)
                
                # Save to Obsidian
                filename = self.save_page_to_obsidian(page_content, content, page_mapping, space_key)
                
                if filename:
                    page_mapping[page_id] = filename
                    total_successful += 1
                    self.processed_pages.add(page_id)
                
                # Rate limiting
                time.sleep(0.3)
        
        # Step 3: Generate comprehensive report
        self.generate_multi_space_report(total_successful, total_pages)
        
        print(f"\n🎉 Multi-space migration completed!")
        print(f"✅ Successfully migrated: {total_successful}/{total_pages} pages")
        print(f"📊 Space breakdown:")
        for space_key in self.target_spaces:
            space_stats = self.space_statistics.get(space_key, {})
            pages_found = space_stats.get("pages_found", 0)
            print(f"   {space_key}: {pages_found} pages")
        
        return total_successful > 0

    def extract_page_content(self, page_data: Dict) -> str:
        """Enhanced content extraction with fallback methods."""
        content = ""
        
        # Try multiple content sources
        content_sources = [
            ["body", "storage", "value"],
            ["body", "view", "value"],
            ["body", "editor", "value"],
            ["content"],
            ["body"]
        ]
        
        for source_path in content_sources:
            try:
                temp_data = page_data
                for key in source_path:
                    if isinstance(temp_data, dict) and key in temp_data:
                        temp_data = temp_data[key]
                    else:
                        break
                else:
                    if isinstance(temp_data, str) and temp_data.strip():
                        content = temp_data
                        break
            except (KeyError, TypeError):
                continue
        
        if not content:
            content = "*(No content available)*"
        
        # Basic HTML to Markdown conversion for Confluence storage format
        if content.startswith("<") and ">" in content:
            content = self.basic_html_to_markdown(content)
        
        return content

    def basic_html_to_markdown(self, html_content: str) -> str:
        """Basic HTML to Markdown conversion for Confluence content."""
        import html
        
        # Decode HTML entities
        text = html.unescape(html_content)
        
        # Convert common HTML elements
        conversions = [
            (r'<h([1-6])[^>]*>(.*?)</h[1-6]>', lambda m: '#' * int(m.group(1)) + ' ' + m.group(2) + '\n\n'),
            (r'<p[^>]*>(.*?)</p>', r'\1\n\n'),
            (r'<strong[^>]*>(.*?)</strong>', r'**\1**'),
            (r'<b[^>]*>(.*?)</b>', r'**\1**'),
            (r'<em[^>]*>(.*?)</em>', r'*\1*'),
            (r'<i[^>]*>(.*?)</i>', r'*\1*'),
            (r'<code[^>]*>(.*?)</code>', r'`\1`'),
            (r'<pre[^>]*>(.*?)</pre>', r'```\n\1\n```\n'),
            (r'<ul[^>]*>', ''),
            (r'</ul>', ''),
            (r'<ol[^>]*>', ''),
            (r'</ol>', ''),
            (r'<li[^>]*>(.*?)</li>', r'- \1\n'),
            (r'<br[^>]*>', '\n'),
            (r'<hr[^>]*>', '\n---\n'),
        ]
        
        for pattern, replacement in conversions:
            if callable(replacement):
                text = re.sub(pattern, replacement, text, flags=re.DOTALL | re.IGNORECASE)
            else:
                text = re.sub(pattern, replacement, text, flags=re.DOTALL | re.IGNORECASE)
        
        # Remove remaining HTML tags
        text = re.sub(r'<[^>]+>', '', text)
        
        # Clean up whitespace
        text = re.sub(r'\n\s*\n\s*\n', '\n\n', text)
        text = text.strip()
        
        return text

    def generate_multi_space_report(self, successful: int, total: int):
        """Generate comprehensive migration report for multiple spaces."""
        report_content = f"""# Multi-Space Confluence to Obsidian Migration Report

## Migration Summary
- **Migration Date**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
- **Migration Tool**: multi-space-confluence-migrator.py
- **Target Spaces**: {', '.join(self.target_spaces)}
- **Total Pages Found**: {total}
- **Successfully Migrated**: {successful}
- **Failed Migrations**: {total - successful}
- **Success Rate**: {(successful/total*100):.1f}% if total > 0 else 'N/A'
- **Date Filter**: {self.filter_start_date if self.date_filter_enabled else 'None'}

## Space Statistics

"""
        
        for space_key in self.target_spaces:
            space_name = self.get_space_display_name(space_key)
            stats = self.space_statistics.get(space_key, {})
            space_pages = [log for log in self.migration_log if log['space_key'] == space_key]
            
            report_content += f"""### {space_name} (Space: {space_key})
- **Pages Found**: {stats.get('pages_found', 0)}
- **Pages Migrated**: {len(space_pages)}
- **Search Query**: {stats.get('search_query', 'N/A')}

"""
        
        report_content += "\n## Migrated Pages by Space\n\n"
        
        for space_key in self.target_spaces:
            space_name = self.get_space_display_name(space_key)
            space_pages = [log for log in self.migration_log if log['space_key'] == space_key]
            
            if space_pages:
                report_content += f"\n### {space_name} ({len(space_pages)} pages)\n\n"
                
                for log_entry in space_pages:
                    report_content += f"**{log_entry['title']}**\n"
                    report_content += f"- Page ID: {log_entry['page_id']}\n"
                    report_content += f"- Category: {log_entry['category']}\n"
                    report_content += f"- File: [[{log_entry['filename'].replace('.md', '')}]]\n"
                    report_content += f"- Migrated: {log_entry['migrated_at']}\n\n"
        
        report_content += f"""## Directory Structure

Your migrated content is organized as follows:

```
Confluence Migration/
├── _metadata/           # Migration reports and logs
├── _attachments/        # File attachments (future)
├── _exports/           # Raw exports (future)
"""
        
        for space_key in self.target_spaces:
            space_name = self.get_space_display_name(space_key)
            report_content += f"""├── {space_name}/
│   ├── Installation/
│   ├── Applications/
│   ├── Project Management/
│   ├── Security/
│   ├── Maintenance/
│   ├── Troubleshooting/
│   ├── Architecture/
│   ├── Development/
│   └── User Guides/
"""
        
        report_content += "```\n\n"
        
        report_content += f"""## Next Steps

### Immediate Actions
1. **Review Content**: Check migrated pages for formatting issues
2. **Validate Links**: Test internal wikilinks between pages
3. **Organize Structure**: Move pages between categories if needed
4. **Update Tags**: Add more specific tags for better organization

### Integration Tasks
1. **Cross-Reference**: Create MOCs (Maps of Content) for each space
2. **Link Building**: Add wikilinks between related pages
3. **Template Creation**: Develop templates for common page types
4. **Search Setup**: Configure Obsidian search for your content

### Quality Assurance
1. **Content Accuracy**: Verify technical information is correct
2. **Link Validation**: Check all Confluence links are converted
3. **Metadata Review**: Ensure tags and categories are appropriate
4. **Duplicate Detection**: Look for duplicate pages across spaces

## Migration Configuration Used
- **Obsidian Vault**: {self.obsidian_vault_path}
- **Target Spaces**: {', '.join(self.target_spaces)}
- **Date Filtering**: {'Enabled' if self.date_filter_enabled else 'Disabled'}
- **Filter Date**: {self.filter_start_date if self.date_filter_enabled else 'N/A'}
- **Preserve Metadata**: Yes
- **Convert Links**: Yes
- **Auto-Categorization**: Yes
- **Space Separation**: Yes

## Troubleshooting

If you encounter issues:

1. **Missing Pages**: Check the original Confluence space permissions
2. **Broken Links**: Some Confluence macro content may not convert perfectly
3. **Formatting Issues**: Complex Confluence layouts may need manual adjustment
4. **Duplicate Content**: Pages appearing in multiple spaces may be duplicated

## Support

- **Project Documentation**: [[00-export-index]]
- **Original Confluence**: https://mjashley.atlassian.net/wiki
- **GitHub Repository**: https://github.com/smashingtags/homelabarr-cli

---
*Generated by HomelabARR CLI Multi-Space Confluence Migration Tool v2.0*
*Migration completed: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}*
"""
        
        # Save report
        report_path = self.obsidian_vault_path / "Confluence Migration" / "_metadata" / "multi-space-migration-report.md"
        
        try:
            with open(report_path, 'w', encoding='utf-8') as f:
                f.write(report_content)
            print(f"📊 Migration report saved: {report_path}")
        except Exception as e:
            print(f"⚠️ Could not save migration report: {str(e)}")
        
        # Also create a summary index
        self.create_migration_index()

    def create_migration_index(self):
        """Create a master index for all migrated content."""
        index_content = f"""# Confluence Migration Index

**Last Updated**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
**Spaces Migrated**: {', '.join(self.target_spaces)}
**Total Pages**: {len(self.migration_log)}

## Quick Navigation

- [[multi-space-migration-report|📊 Full Migration Report]]

## Spaces

"""
        
        for space_key in self.target_spaces:
            space_name = self.get_space_display_name(space_key)
            space_pages = [log for log in self.migration_log if log['space_key'] == space_key]
            
            index_content += f"""### {space_name}
**Space Key**: `{space_key}`
**Pages**: {len(space_pages)}

"""
            
            # Group by category
            categories = {}
            for page in space_pages:
                category = page['category'].split('/')[-1]  # Get just the category name
                if category not in categories:
                    categories[category] = []
                categories[category].append(page)
            
            for category, pages in sorted(categories.items()):
                index_content += f"**{category}** ({len(pages)} pages)\n"
                for page in sorted(pages, key=lambda x: x['title']):
                    filename = page['filename'].replace('.md', '')
                    index_content += f"- [[{filename}|{page['title']}]]\n"
                index_content += "\n"
        
        index_content += f"""## Migration Statistics

| Metric | Value |
|--------|-------|
| Spaces Processed | {len(self.target_spaces)} |
| Pages Migrated | {len(self.migration_log)} |
| Categories Created | {len(set(log['category'] for log in self.migration_log))} |
| Date Filter Applied | {'Yes' if self.date_filter_enabled else 'No'} |

## Tags Overview

Common tags used in this migration:
- `#confluence-migration` - All migrated pages
- `#homelabarr-cli` - Project-related content
- `#space-hlcli` - HomelabARR CLI space content
- `#space-hc` - HomelabARR Community space content

---
*Auto-generated index file*
"""
        
        # Save index
        index_path = self.obsidian_vault_path / "Confluence Migration" / "00-migration-index.md"
        
        try:
            with open(index_path, 'w', encoding='utf-8') as f:
                f.write(index_content)
            print(f"📋 Migration index created: {index_path}")
        except Exception as e:
            print(f"⚠️ Could not create migration index: {str(e)}")

def main():
    """Enhanced main function for multi-space migration."""
    print("=" * 70)
    print("HomelabARR CLI: Multi-Space Confluence to Obsidian Migrator")
    print("=" * 70)
    print("\n🎯 Target Spaces: HLCLI + HC")
    print("📅 Date Filtering: July/August 2024 onwards")
    print("⏰ Premium Expires: 3 days remaining")
    
    # Configuration
    DEFAULT_OBSIDIAN_PATH = "/mnt/f/Coding Projects/homelabarr-ce/.claude/obsidian-vault"
    TARGET_SPACES = ["hlcli", "HC"]  # Both spaces as specified
    
    # Get user input
    obsidian_path = input(f"\nEnter Obsidian vault path [{DEFAULT_OBSIDIAN_PATH}]: ").strip()
    if not obsidian_path:
        obsidian_path = DEFAULT_OBSIDIAN_PATH
    
    # Confirm target spaces
    print(f"\n🏢 Target Spaces: {', '.join(TARGET_SPACES)}")
    custom_spaces = input("Use different spaces? (comma-separated, or press Enter to continue): ").strip()
    if custom_spaces:
        TARGET_SPACES = [s.strip() for s in custom_spaces.split(',') if s.strip()]
    
    # Date filtering options
    print("\n📅 Date Filtering Options:")
    print("1. July 2024 onwards (recommended)")
    print("2. August 2024 onwards")
    print("3. All pages (no date filter)")
    print("4. Custom date (YYYY-MM-DD)")
    
    choice = input("Choose an option [1]: ").strip() or "1"
    date_filter = None
    
    if choice == "1":
        date_filter = "2024-07-01"
    elif choice == "2":
        date_filter = "2024-08-01"
    elif choice == "3":
        date_filter = None
    elif choice == "4":
        custom_date = input("Enter date (YYYY-MM-DD): ").strip()
        if custom_date:
            try:
                datetime.fromisoformat(custom_date)
                date_filter = custom_date
            except ValueError:
                print("⚠️ Invalid date format, proceeding without date filter")
                date_filter = None
    
    # Final configuration summary
    print(f"\n🔧 Migration Configuration:")
    print(f"   Obsidian Vault: {obsidian_path}")
    print(f"   Target Spaces: {', '.join(TARGET_SPACES)}")
    print(f"   Date Filter: {date_filter or 'None (all pages)'}")
    print(f"   Estimated Time: 5-15 minutes per space")
    
    # Confirm before proceeding
    print("\n⚠️ IMPORTANT NOTES:")
    print("   - This will create/overwrite files in your Obsidian vault")
    print("   - Confluence Premium expires in 3 days")
    print("   - Migration cannot be easily undone")
    print("   - Backup your existing Obsidian vault if needed")
    
    confirm = input("\n🚀 Proceed with multi-space migration? [y/N]: ").strip().lower()
    if confirm != 'y':
        print("❌ Migration cancelled")
        return
    
    # Initialize and run migration
    print("\n" + "=" * 50)
    print("🚀 STARTING MIGRATION")
    print("=" * 50)
    
    try:
        migrator = MultiSpaceConfluenceMigrator(obsidian_path, TARGET_SPACES)
        success = migrator.migrate_all_spaces(date_filter)
        
        print("\n" + "=" * 50)
        if success:
            print("🎉 MIGRATION COMPLETED SUCCESSFULLY!")
            print("=" * 50)
            print(f"📁 Check your Obsidian vault at:")
            print(f"   {obsidian_path}")
            print(f"\n📋 Key files created:")
            print(f"   - 00-migration-index.md (master index)")
            print(f"   - _metadata/multi-space-migration-report.md (detailed report)")
            print(f"\n📖 Next steps:")
            print(f"   1. Open Obsidian and navigate to your vault")
            print(f"   2. Review the migration index for navigation")
            print(f"   3. Check individual pages for formatting")
            print(f"   4. Add additional wikilinks between related pages")
            print(f"\n💡 The migration preserved all metadata and organized content by space and category.")
        else:
            print("❌ MIGRATION FAILED")
            print("=" * 50)
            print(f"   No content was migrated successfully")
            print(f"   Check the error messages above for details")
            print(f"   Common issues:")
            print(f"   - MCP tools not properly configured")
            print(f"   - Confluence Premium expired")
            print(f"   - Network connectivity issues")
            print(f"   - Invalid space keys or permissions")
    
    except KeyboardInterrupt:
        print("\n\n⏹️ Migration interrupted by user")
        print("   Partial migration may have occurred")
        print("   Check your Obsidian vault for any migrated content")
    except Exception as e:
        print(f"\n\n❌ Migration failed with error:")
        print(f"   {str(e)}")
        print(f"\n🔧 Troubleshooting:")
        print(f"   - Verify MCP Docker tools are working")
        print(f"   - Check Confluence access and permissions")
        print(f"   - Ensure sufficient disk space")
        print(f"   - Try running with fewer spaces or smaller date range")

if __name__ == "__main__":
    main()
