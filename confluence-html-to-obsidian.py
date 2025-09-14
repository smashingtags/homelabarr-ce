#!/usr/bin/env python3
"""
HomelabARR Confluence HTML to Obsidian Migration Script
Processes 238+ HTML files and converts them to Obsidian-compatible Markdown
"""

import os
import re
import html
from pathlib import Path
from bs4 import BeautifulSoup, Comment
from urllib.parse import unquote
import datetime
import json

class ConfluenceToObsidian:
    def __init__(self, source_dir, output_dir):
        self.source_dir = Path(source_dir)
        self.output_dir = Path(output_dir)
        self.processed_count = 0
        self.errors = []
        self.migration_log = []

    def extract_page_info(self, html_content, filename):
        """Extract page metadata from HTML content"""
        soup = BeautifulSoup(html_content, 'html.parser')

        # Extract title
        title_elem = soup.find('title')
        title = title_elem.text.strip() if title_elem else filename.replace('.html', '')

        # Clean up title
        title = title.replace(' - HomelabARR-CLI - Confluence', '')
        title = title.replace(' - Confluence', '')

        # Extract page ID from filename if available
        page_id = None
        id_match = re.search(r'(\d+)\.html$', filename)
        if id_match:
            page_id = id_match.group(1)

        # Extract confluence URL pattern
        confluence_url = f"https://mjashley.atlassian.net/wiki/spaces/DO/pages/{page_id}" if page_id else ""

        # Look for breadcrumbs or navigation to extract hierarchy
        breadcrumbs = []
        breadcrumb_elem = soup.find('ol', {'id': 'breadcrumbs'}) or soup.find('nav', class_='aui-navgroup')
        if breadcrumb_elem:
            for link in breadcrumb_elem.find_all('a'):
                if link.text.strip() and link.text.strip() not in ['HomelabARR-CLI', 'Confluence']:
                    breadcrumbs.append(link.text.strip())

        # Extract dates from content
        created_date = ""
        updated_date = ""

        # Look for date patterns in content
        date_patterns = [
            r'Created:\s*(\d{4}-\d{2}-\d{2})',
            r'Last modified:\s*(\d{4}-\d{2}-\d{2})',
            r'Date:\s*(\d{4}-\d{2}-\d{2})',
            r'(\d{4}-\d{2}-\d{2})',  # Generic date pattern
        ]

        content_text = soup.get_text()
        for pattern in date_patterns:
            matches = re.findall(pattern, content_text)
            if matches:
                if not created_date and any(word in content_text.lower() for word in ['created', 'date']):
                    created_date = matches[0]
                if not updated_date and any(word in content_text.lower() for word in ['updated', 'modified']):
                    updated_date = matches[-1]

        # Extract tags from content
        tags = []

        # Look for HomelabARR-related terms
        content_lower = content_text.lower()
        if 'docker' in content_lower:
            tags.append('docker')
        if any(term in content_lower for term in ['traefik', 'reverse proxy']):
            tags.append('traefik')
        if 'authelia' in content_lower:
            tags.append('authelia')
        if any(term in content_lower for term in ['plex', 'jellyfin', 'emby']):
            tags.append('media-server')
        if any(term in content_lower for term in ['sonarr', 'radarr', 'lidarr', 'bazarr']):
            tags.append('servarr')
        if 'monitoring' in content_lower or 'grafana' in content_lower:
            tags.append('monitoring')
        if any(term in content_lower for term in ['storage', 'snapraid', 'mergerfs', 'zfs']):
            tags.append('storage')
        if any(term in content_lower for term in ['react', 'frontend', 'ui']):
            tags.append('frontend')
        if 'go' in content_lower or 'golang' in content_lower:
            tags.append('golang')
        if 'sprint' in content_lower or 'jira' in content_lower:
            tags.append('project-management')
        if any(term in content_lower for term in ['security', 'authentication', 'ssl']):
            tags.append('security')

        # Add date-based tags
        if re.search(r'2025-08', title) or re.search(r'2025-08', content_text):
            tags.append('august-2025')
        if re.search(r'2025-09', title) or re.search(r'2025-09', content_text):
            tags.append('september-2025')
        if 'epic' in content_lower or 'hl-' in content_lower:
            tags.append('epic')

        return {
            'title': title,
            'page_id': page_id,
            'confluence_url': confluence_url,
            'breadcrumbs': breadcrumbs,
            'created_date': created_date,
            'updated_date': updated_date,
            'tags': list(set(tags)),  # Remove duplicates
        }

    def clean_html_content(self, soup):
        """Clean and convert HTML content to Markdown"""

        # Remove Confluence-specific elements
        for elem in soup.find_all(['script', 'style', 'meta', 'link']):
            elem.decompose()

        # Remove comments
        for comment in soup.find_all(string=lambda text: isinstance(text, Comment)):
            comment.extract()

        # Remove Confluence navigation and sidebar elements
        for selector in ['.aui-header', '.aui-sidebar', '.aui-navgroup', '#breadcrumbs',
                        '.confluence-information-macro', '.footer', '.header']:
            for elem in soup.select(selector):
                elem.decompose()

        # Find main content area
        main_content = None
        for selector in ['#main-content', '.wiki-content', '.page-content', 'main', 'article']:
            main_content = soup.select_one(selector)
            if main_content:
                break

        if not main_content:
            # Use body if no specific content area found
            main_content = soup.find('body') or soup

        return main_content

    def html_to_markdown(self, html_elem):
        """Convert HTML elements to Markdown"""
        if not html_elem:
            return ""

        markdown_lines = []

        for elem in html_elem.descendants:
            if elem.name == 'h1':
                markdown_lines.append(f"\n# {elem.get_text().strip()}\n")
            elif elem.name == 'h2':
                markdown_lines.append(f"\n## {elem.get_text().strip()}\n")
            elif elem.name == 'h3':
                markdown_lines.append(f"\n### {elem.get_text().strip()}\n")
            elif elem.name == 'h4':
                markdown_lines.append(f"\n#### {elem.get_text().strip()}\n")
            elif elem.name == 'h5':
                markdown_lines.append(f"\n##### {elem.get_text().strip()}\n")
            elif elem.name == 'h6':
                markdown_lines.append(f"\n###### {elem.get_text().strip()}\n")
            elif elem.name == 'p' and elem.get_text().strip():
                markdown_lines.append(f"\n{elem.get_text().strip()}\n")
            elif elem.name == 'strong' or elem.name == 'b':
                markdown_lines.append(f"**{elem.get_text().strip()}**")
            elif elem.name == 'em' or elem.name == 'i':
                markdown_lines.append(f"*{elem.get_text().strip()}*")
            elif elem.name == 'code':
                markdown_lines.append(f"`{elem.get_text().strip()}`")
            elif elem.name == 'pre':
                code_content = elem.get_text().strip()
                markdown_lines.append(f"\n```\n{code_content}\n```\n")
            elif elem.name == 'blockquote':
                quote_text = elem.get_text().strip()
                quote_lines = quote_text.split('\n')
                for line in quote_lines:
                    markdown_lines.append(f"> {line}")
                markdown_lines.append("")
            elif elem.name == 'ul':
                for li in elem.find_all('li', recursive=False):
                    markdown_lines.append(f"- {li.get_text().strip()}")
            elif elem.name == 'ol':
                for i, li in enumerate(elem.find_all('li', recursive=False), 1):
                    markdown_lines.append(f"{i}. {li.get_text().strip()}")
            elif elem.name == 'a' and elem.get('href'):
                link_text = elem.get_text().strip()
                link_url = elem.get('href')
                # Convert Confluence internal links to wikilinks where possible
                if 'mjashley.atlassian.net' in link_url:
                    markdown_lines.append(f"[[{link_text}]]")
                else:
                    markdown_lines.append(f"[{link_text}]({link_url})")

        # Clean up the markdown
        markdown_text = '\n'.join(markdown_lines)

        # Clean up extra whitespace
        markdown_text = re.sub(r'\n\s*\n\s*\n', '\n\n', markdown_text)
        markdown_text = re.sub(r'^\s*\n', '', markdown_text)
        markdown_text = re.sub(r'\n\s*$', '', markdown_text)

        return markdown_text

    def determine_category(self, page_info, content):
        """Determine the category folder for the page"""
        title = page_info['title'].lower()
        content_lower = content.lower()

        # Category mapping
        if any(term in title for term in ['installation', 'setup', 'guide']):
            return 'Installation'
        elif any(term in title for term in ['monitoring', 'grafana', 'prometheus']):
            return 'Monitoring'
        elif any(term in title for term in ['storage', 'snapraid', 'mergerfs', 'zfs']):
            return 'Storage'
        elif any(term in title for term in ['security', 'authelia', 'authentication']):
            return 'Security'
        elif any(term in title for term in ['docker', 'container']):
            return 'Docker'
        elif any(term in title for term in ['traefik', 'proxy', 'routing']):
            return 'Networking'
        elif any(term in title for term in ['react', 'frontend', 'ui', 'dashboard']):
            return 'Frontend'
        elif any(term in title for term in ['media', 'plex', 'jellyfin', 'sonarr', 'radarr']):
            return 'Media-Stack'
        elif any(term in title for term in ['project', 'sprint', 'jira', 'management']):
            return 'Project-Management'
        elif any(term in title for term in ['architecture', 'design', 'implementation']):
            return 'Architecture'
        elif any(term in title for term in ['epic', 'hl-']):
            return 'Epics'
        elif 'retrospective' in title or 'sprint' in title:
            return 'Retrospectives'
        elif any(term in title for term in ['fix', 'bug', 'troubleshoot', 'rca']):
            return 'Troubleshooting'
        elif any(term in title for term in ['documentation', 'guide', 'reference']):
            return 'Documentation'
        else:
            return 'General'

    def create_obsidian_file(self, page_info, content, category):
        """Create the final Obsidian markdown file"""

        # Create safe filename
        safe_title = re.sub(r'[<>:"/\\|?*]', '-', page_info['title'])
        safe_title = re.sub(r'-+', '-', safe_title).strip('-')
        filename = f"{safe_title}.md"

        # Create category directory
        category_dir = self.output_dir / category
        category_dir.mkdir(parents=True, exist_ok=True)

        # Create YAML frontmatter
        frontmatter = f"""---
title: "{page_info['title']}"
confluence_id: "{page_info['page_id'] or 'unknown'}"
confluence_url: "{page_info['confluence_url']}"
confluence_space: "DO"
category: "{category}"
created_date: "{page_info['created_date']}"
updated_date: "{page_info['updated_date']}"
migrated_date: "{datetime.date.today()}"
tags: {page_info['tags']}
breadcrumbs: {page_info['breadcrumbs']}
---

"""

        # Combine frontmatter and content
        full_content = frontmatter + content

        # Write file
        file_path = category_dir / filename
        try:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(full_content)

            return file_path, True
        except Exception as e:
            self.errors.append(f"Error writing {filename}: {str(e)}")
            return file_path, False

    def process_file(self, html_file):
        """Process a single HTML file"""
        try:
            print(f"Processing: {html_file.name}")

            # Read HTML file
            with open(html_file, 'r', encoding='utf-8') as f:
                html_content = f.read()

            # Parse HTML
            soup = BeautifulSoup(html_content, 'html.parser')

            # Extract page information
            page_info = self.extract_page_info(html_content, html_file.name)

            # Clean and convert content
            main_content = self.clean_html_content(soup)
            markdown_content = self.html_to_markdown(main_content)

            # Determine category
            category = self.determine_category(page_info, markdown_content)

            # Create Obsidian file
            file_path, success = self.create_obsidian_file(page_info, markdown_content, category)

            if success:
                self.processed_count += 1
                log_entry = {
                    'source_file': html_file.name,
                    'title': page_info['title'],
                    'category': category,
                    'output_file': str(file_path.relative_to(self.output_dir)),
                    'page_id': page_info['page_id'],
                    'tags': page_info['tags'],
                    'status': 'success'
                }
            else:
                log_entry = {
                    'source_file': html_file.name,
                    'title': page_info['title'],
                    'status': 'failed'
                }

            self.migration_log.append(log_entry)

        except Exception as e:
            error_msg = f"Error processing {html_file.name}: {str(e)}"
            print(f"ERROR: {error_msg}")
            self.errors.append(error_msg)

            self.migration_log.append({
                'source_file': html_file.name,
                'status': 'error',
                'error': str(e)
            })

    def create_master_index(self):
        """Create master navigation index"""
        index_content = f"""---
title: "HomelabARR CLI Documentation - Master Index"
type: "index"
migrated_date: "{datetime.date.today()}"
total_pages: {self.processed_count}
source: "Confluence DO Space"
tags: [index, homelabarr, documentation]
---

# HomelabARR CLI Documentation - Master Index

**Migration Complete**: {datetime.date.today()}
**Total Pages Migrated**: {self.processed_count}
**Source**: Confluence DO Space (formerly HLCLI)

## 📁 Categories

"""

        # List categories and their contents
        categories = {}
        for entry in self.migration_log:
            if entry['status'] == 'success':
                category = entry['category']
                if category not in categories:
                    categories[category] = []
                categories[category].append(entry)

        for category, entries in sorted(categories.items()):
            index_content += f"\n### {category} ({len(entries)} pages)\n\n"

            # Sort entries by title
            sorted_entries = sorted(entries, key=lambda x: x['title'])

            for entry in sorted_entries:
                title = entry['title']
                file_path = entry['output_file']
                page_id = entry['page_id']

                index_content += f"- [[{title}]] - ID: {page_id}\n"

        # Add migration statistics
        index_content += f"""

## 📊 Migration Statistics

- **Total Files Processed**: {len(self.migration_log)}
- **Successfully Migrated**: {self.processed_count}
- **Errors**: {len(self.errors)}
- **Categories Created**: {len(categories)}

## 🔗 Original Source

All content migrated from: **Confluence DO Space**
Original URL: `https://mjashley.atlassian.net/wiki/spaces/DO/`

## 🏷️ Most Common Tags

"""

        # Count tags
        tag_counts = {}
        for entry in self.migration_log:
            if entry['status'] == 'success' and 'tags' in entry:
                for tag in entry['tags']:
                    tag_counts[tag] = tag_counts.get(tag, 0) + 1

        # Show top tags
        for tag, count in sorted(tag_counts.items(), key=lambda x: x[1], reverse=True)[:20]:
            index_content += f"- `{tag}`: {count} pages\n"

        index_content += f"""

---

*Migration completed on {datetime.date.today()} using Confluence HTML export.*
*Ready for import into Obsidian vault.*
"""

        # Write index file
        index_path = self.output_dir / "00-Master-Index.md"
        with open(index_path, 'w', encoding='utf-8') as f:
            f.write(index_content)

        print(f"✅ Master index created: {index_path}")

    def create_migration_report(self):
        """Create detailed migration report"""
        report_path = self.output_dir / "_migration-report.json"

        report_data = {
            'migration_date': str(datetime.date.today()),
            'total_files': len(self.migration_log),
            'successful_migrations': self.processed_count,
            'errors': len(self.errors),
            'error_details': self.errors,
            'files': self.migration_log
        }

        with open(report_path, 'w', encoding='utf-8') as f:
            json.dump(report_data, f, indent=2, ensure_ascii=False)

        print(f"📋 Migration report created: {report_path}")

    def run_migration(self):
        """Run the complete migration process"""
        print(f"🚀 Starting HomelabARR Confluence to Obsidian migration...")
        print(f"Source: {self.source_dir}")
        print(f"Output: {self.output_dir}")

        # Create output directory
        self.output_dir.mkdir(parents=True, exist_ok=True)

        # Find all HTML files
        html_files = list(self.source_dir.glob("*.html"))
        print(f"Found {len(html_files)} HTML files to process")

        # Process each file
        for html_file in html_files:
            self.process_file(html_file)

        # Create master index
        self.create_master_index()

        # Create migration report
        self.create_migration_report()

        # Print summary
        print(f"\n✅ Migration Complete!")
        print(f"📊 Processed: {self.processed_count}/{len(html_files)} files")
        print(f"❌ Errors: {len(self.errors)}")
        print(f"📁 Output directory: {self.output_dir}")

        if self.errors:
            print(f"\n⚠️ Errors encountered:")
            for error in self.errors[:10]:  # Show first 10 errors
                print(f"  - {error}")
            if len(self.errors) > 10:
                print(f"  ... and {len(self.errors) - 10} more (see migration report)")


def main():
    """Main execution function"""
    source_dir = "/mnt/f/Coding Projects/homelabarr-ce/DO"
    output_dir = "/mnt/f/Coding Projects/homelabarr-ce/.claude/obsidian-vault/Confluence Migration"

    migrator = ConfluenceToObsidian(source_dir, output_dir)
    migrator.run_migration()


if __name__ == "__main__":
    main()