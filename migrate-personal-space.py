#!/usr/bin/env python3
"""
HomelabARR Personal Confluence Space to Obsidian Migration Script
Processes personal space HTML files and converts them to Obsidian-compatible Markdown
"""

import os
import re
import html
from pathlib import Path
from html.parser import HTMLParser
import datetime
import json

class HTMLToMarkdown(HTMLParser):
    """Simple HTML to Markdown converter"""

    def __init__(self):
        super().__init__()
        self.markdown = []
        self.current_tag = None
        self.list_level = 0
        self.in_pre = False
        self.in_code = False

    def handle_starttag(self, tag, attrs):
        if tag in ['h1', 'h2', 'h3', 'h4', 'h5', 'h6']:
            level = int(tag[1])
            self.markdown.append('\n' + '#' * level + ' ')
        elif tag == 'p':
            self.markdown.append('\n\n')
        elif tag == 'br':
            self.markdown.append('\n')
        elif tag == 'strong' or tag == 'b':
            self.markdown.append('**')
        elif tag == 'em' or tag == 'i':
            self.markdown.append('*')
        elif tag == 'code':
            self.markdown.append('`')
            self.in_code = True
        elif tag == 'pre':
            self.markdown.append('\n```\n')
            self.in_pre = True
        elif tag == 'blockquote':
            self.markdown.append('\n> ')
        elif tag == 'ul' or tag == 'ol':
            self.list_level += 1
        elif tag == 'li':
            indent = '  ' * (self.list_level - 1)
            self.markdown.append(f'\n{indent}- ')
        elif tag == 'a':
            href = dict(attrs).get('href', '')
            if href:
                self.markdown.append('[')
                self.link_href = href

        self.current_tag = tag

    def handle_endtag(self, tag):
        if tag in ['h1', 'h2', 'h3', 'h4', 'h5', 'h6']:
            self.markdown.append('\n')
        elif tag == 'strong' or tag == 'b':
            self.markdown.append('**')
        elif tag == 'em' or tag == 'i':
            self.markdown.append('*')
        elif tag == 'code':
            self.markdown.append('`')
            self.in_code = False
        elif tag == 'pre':
            self.markdown.append('\n```\n')
            self.in_pre = False
        elif tag == 'ul' or tag == 'ol':
            self.list_level -= 1
        elif tag == 'a' and hasattr(self, 'link_href'):
            if 'your-instance.atlassian.net' in self.link_href:
                self.markdown.append(']]')
                text_content = ''.join(self.markdown[-10:])
                if '[' in text_content:
                    idx = text_content.rfind('[')
                    link_text = text_content[idx+1:]
                    self.markdown = self.markdown[:-len(link_text)-1] + [f'[[{link_text}']
            else:
                self.markdown.append(f']({self.link_href})')
            delattr(self, 'link_href')

        self.current_tag = None

    def handle_data(self, data):
        if not self.in_pre and not self.in_code:
            data = re.sub(r'\s+', ' ', data.strip())
        if data:
            self.markdown.append(data)

    def get_markdown(self):
        result = ''.join(self.markdown)
        result = re.sub(r'\n\s*\n\s*\n', '\n\n', result)
        result = result.strip()
        return result

class PersonalSpaceToObsidian:
    def __init__(self, source_dir, output_dir):
        self.source_dir = Path(source_dir)
        self.output_dir = Path(output_dir)
        self.processed_count = 0
        self.errors = []
        self.migration_log = []

    def extract_title_from_html(self, html_content):
        """Extract title from HTML using regex"""
        title_match = re.search(r'<title[^>]*>(.*?)</title>', html_content, re.IGNORECASE | re.DOTALL)
        if title_match:
            title = html.unescape(title_match.group(1).strip())
            title = title.replace(' - Space ~7012146c1602dd7434196b33ad632a9816e2a - Confluence', '')
            title = title.replace(' - Confluence', '')
            return title
        return "Untitled"

    def extract_page_id_from_filename(self, filename):
        """Extract page ID from filename"""
        id_match = re.search(r'(\d+)\.html$', filename)
        return id_match.group(1) if id_match else None

    def extract_tags_from_content(self, title, content):
        """Extract relevant tags from title and content"""
        tags = ['personal']  # All personal space content gets this tag

        title_lower = title.lower()
        content_lower = content.lower()

        # Technology tags
        if 'mcp' in content_lower:
            tags.append('mcp')
        if 'workflow' in content_lower or 'n8n' in content_lower:
            tags.append('workflow')
        if 'windows' in content_lower:
            tags.append('windows')
        if 'ai' in content_lower or 'artificial intelligence' in content_lower:
            tags.append('ai')
        if 'infrastructure' in content_lower:
            tags.append('infrastructure')
        if 'documentation' in content_lower:
            tags.append('documentation')
        if 'career' in content_lower or 'professional' in content_lower:
            tags.append('career')
        if 'content creation' in content_lower:
            tags.append('content-creation')

        return list(set(tags))

    def determine_category(self, title, content):
        """Determine the category folder for the page"""
        title_lower = title.lower()
        content_lower = content.lower()

        if any(term in title_lower for term in ['career', 'professional', 'termination']):
            return 'Personal-Career'
        elif any(term in title_lower for term in ['mcp', 'tool', 'windows']):
            return 'Personal-Tools'
        elif any(term in title_lower for term in ['workflow', 'n8n', 'ai']):
            return 'Personal-Automation'
        elif any(term in title_lower for term in ['infrastructure', 'content creation']):
            return 'Personal-Infrastructure'
        elif any(term in title_lower for term in ['getting started', 'overview', 'confluence']):
            return 'Personal-Meta'
        else:
            return 'Personal-General'

    def clean_html_for_conversion(self, html_content):
        """Clean HTML content for conversion"""
        # Remove script and style tags
        html_content = re.sub(r'<script[^>]*>.*?</script>', '', html_content, flags=re.DOTALL | re.IGNORECASE)
        html_content = re.sub(r'<style[^>]*>.*?</style>', '', html_content, flags=re.DOTALL | re.IGNORECASE)

        # Remove comments
        html_content = re.sub(r'<!--.*?-->', '', html_content, flags=re.DOTALL)

        # Try to extract main content
        for pattern in [
            r'<div[^>]*id=["\']main-content["\'][^>]*>(.*?)</div>',
            r'<div[^>]*class=["\'][^"\']*wiki-content[^"\']*["\'][^>]*>(.*?)</div>',
            r'<div[^>]*class=["\'][^"\']*page-content[^"\']*["\'][^>]*>(.*?)</div>',
            r'<main[^>]*>(.*?)</main>',
            r'<article[^>]*>(.*?)</article>',
        ]:
            match = re.search(pattern, html_content, re.DOTALL | re.IGNORECASE)
            if match:
                return match.group(1)

        # If no specific content area found, try to extract body content
        body_match = re.search(r'<body[^>]*>(.*?)</body>', html_content, re.DOTALL | re.IGNORECASE)
        if body_match:
            body_content = body_match.group(1)
            # Remove navigation and sidebar elements
            for nav_pattern in [
                r'<nav[^>]*>.*?</nav>',
                r'<div[^>]*class=["\'][^"\']*sidebar[^"\']*["\'][^>]*>.*?</div>',
                r'<div[^>]*class=["\'][^"\']*navigation[^"\']*["\'][^>]*>.*?</div>',
                r'<header[^>]*>.*?</header>',
                r'<footer[^>]*>.*?</footer>',
            ]:
                body_content = re.sub(nav_pattern, '', body_content, flags=re.DOTALL | re.IGNORECASE)
            return body_content

        return html_content

    def process_file(self, html_file):
        """Process a single HTML file"""
        try:
            print(f"Processing: {html_file.name}")

            # Read HTML file
            with open(html_file, 'r', encoding='utf-8', errors='ignore') as f:
                html_content = f.read()

            # Extract basic information
            title = self.extract_title_from_html(html_content)
            page_id = self.extract_page_id_from_filename(html_file.name)

            # Clean HTML for conversion
            clean_html = self.clean_html_for_conversion(html_content)

            # Convert to Markdown
            converter = HTMLToMarkdown()
            converter.feed(clean_html)
            markdown_content = converter.get_markdown()

            # Extract tags and determine category
            tags = self.extract_tags_from_content(title, markdown_content)
            category = self.determine_category(title, markdown_content)

            # Create page info
            page_info = {
                'title': title,
                'page_id': page_id or 'unknown',
                'confluence_url': f"https://your-instance.atlassian.net/wiki/spaces/~7012146c1602dd7434196b33ad632a9816e2a/pages/{page_id}" if page_id else "",
                'tags': tags,
                'category': category
            }

            # Create Obsidian file
            success = self.create_obsidian_file(page_info, markdown_content, category)

            if success:
                self.processed_count += 1
                log_entry = {
                    'source_file': html_file.name,
                    'title': title,
                    'category': category,
                    'page_id': page_id,
                    'tags': tags,
                    'status': 'success'
                }
            else:
                log_entry = {
                    'source_file': html_file.name,
                    'title': title,
                    'status': 'failed'
                }

            self.migration_log.append(log_entry)

        except Exception as e:
            error_msg = f"Error processing {html_file.name}: {str(e)}"
            print(f"ERROR: {error_msg}")
            self.errors.append(error_msg)

    def create_obsidian_file(self, page_info, content, category):
        """Create the final Obsidian markdown file"""
        try:
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
confluence_id: "{page_info['page_id']}"
confluence_url: "{page_info['confluence_url']}"
confluence_space: "Personal"
category: "{category}"
migrated_date: "{datetime.date.today()}"
tags: {page_info['tags']}
---

"""

            # Combine frontmatter and content
            full_content = frontmatter + content

            # Write file
            file_path = category_dir / filename
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(full_content)

            return True

        except Exception as e:
            self.errors.append(f"Error writing {page_info['title']}: {str(e)}")
            return False

    def create_personal_index(self):
        """Create personal space navigation index"""
        index_content = f"""---
title: "Michael's Personal Confluence Space - Index"
type: "personal-index"
migrated_date: "{datetime.date.today()}"
total_pages: {self.processed_count}
source: "Personal Confluence Space"
tags: [index, personal, confluence]
---

# Michael's Personal Confluence Space - Index

**Migration Complete**: {datetime.date.today()}
**Total Pages Migrated**: {self.processed_count}
**Source**: Personal Confluence Space (~7012146c1602dd7434196b33ad632a9816e2a)

## 📁 Personal Categories

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
            index_content += f"\n### {category.replace('Personal-', '')} ({len(entries)} pages)\n\n"

            # Sort entries by title
            sorted_entries = sorted(entries, key=lambda x: x['title'])

            for entry in sorted_entries:
                title = entry['title']
                page_id = entry['page_id']
                index_content += f"- [[{title}]] - ID: {page_id}\n"

        # Add migration info
        index_content += f"""

## 📋 About This Space

This is Michael Ashley's personal Confluence space containing:
- Career development and professional content
- Personal tools and MCP documentation
- Workflow automation with n8n and AI
- Infrastructure and content creation setup
- Meta documentation about Confluence usage

## 🔗 Original Source

Personal Space URL: `https://your-instance.atlassian.net/wiki/spaces/~7012146c1602dd7434196b33ad632a9816e2a/`

---

*Migration completed on {datetime.date.today()} using Confluence HTML export.*
*Personal content ready for Obsidian import.*
"""

        # Write index file
        index_path = self.output_dir / "00-Personal-Space-Index.md"
        with open(index_path, 'w', encoding='utf-8') as f:
            f.write(index_content)

        print(f"✅ Personal index created: {index_path}")

    def run_migration(self):
        """Run the complete migration process"""
        print(f"🚀 Starting Personal Space migration...")
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

        # Create personal index
        self.create_personal_index()

        # Print summary
        print(f"\n✅ Personal Space Migration Complete!")
        print(f"📊 Processed: {self.processed_count}/{len(html_files)} files")
        print(f"❌ Errors: {len(self.errors)}")
        print(f"📁 Output directory: {self.output_dir}")

        if self.errors:
            print(f"\n⚠️ Errors:")
            for error in self.errors:
                print(f"  - {error}")


def main():
    """Main execution function"""
    source_dir = "/mnt/f/Coding Projects/homelabarr-ce/7012146c1602dd7434196b33ad632a9816e2a"
    output_dir = "/mnt/f/Coding Projects/homelabarr-ce/.claude/obsidian-vault/Personal-Space"

    migrator = PersonalSpaceToObsidian(source_dir, output_dir)
    migrator.run_migration()


if __name__ == "__main__":
    main()