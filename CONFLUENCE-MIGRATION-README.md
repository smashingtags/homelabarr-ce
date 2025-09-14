# Confluence to Obsidian Migration Guide

**🎯 Objective**: Migrate your HomelabARR CLI Confluence documentation (July/August 2024 to present) to Obsidian before your Premium expires.

**⏰ Timeline**: Confluence Premium expires in 3 days - execute soon!

## Quick Start (Recommended)

### Step 1: Test MCP Tools
```bash
# Test that MCP Confluence tools are working
./test-confluence-export.sh
```

### Step 2: Run Quick Export
```bash
# Export all recent pages
python3 quick-confluence-export.py
```

### Step 3: Import to Obsidian
1. Copy files from `.claude/confluence-export/` to your Obsidian vault
2. Review the generated `00-export-index.md` for navigation
3. Check individual pages for formatting issues

## Available Migration Scripts

### 1. `test-confluence-export.sh` - Validation Script
**Purpose**: Test MCP tool connectivity and permissions
**Usage**: `./test-confluence-export.sh`

**What it does**:
- ✅ Tests MCP Docker Confluence tools
- ✅ Validates access to HomelabARR CLI space (DO)
- ✅ Creates test output directory
- ✅ Provides next-step guidance

### 2. `quick-confluence-export.py` - Fast Export Tool
**Purpose**: Streamlined export using available MCP tools
**Usage**: `python3 quick-confluence-export.py`

**Features**:
- 🔍 **Search Options**: All pages, recent only, specific terms, or key pages only
- 📄 **Auto-Format**: Creates Obsidian-compatible Markdown files
- 🏷️ **Metadata Preservation**: YAML frontmatter with Confluence details
- 📁 **Organization**: Automatic file naming and structure
- 📊 **Export Index**: Generated navigation file

**Export Options**:
1. **All pages** - Search for "HomelabARR" content
2. **Recent pages** - Content modified since July 2024
3. **Custom search** - Your specific search terms
4. **Key pages only** - Export known critical documentation

### 3. `confluence-to-obsidian-migrator.py` - Full-Featured Migrator
**Purpose**: Comprehensive migration with advanced features
**Usage**: `python3 confluence-to-obsidian-migrator.py`

**Advanced Features**:
- 🗂️ **Smart Categorization**: Auto-organize by content type
- 🔗 **Link Conversion**: Transform Confluence links to Obsidian wikilinks
- 👶 **Child Page Handling**: Process page hierarchies
- 📊 **Detailed Reporting**: Comprehensive migration reports
- 🏷️ **Tag Management**: Enhanced tagging system

## Understanding Your Current Setup

### MCP Tools Available
Based on your `.claude/MCP_TOOLS_REFERENCE.md`:

**✅ Working Confluence Tools**:
- `confluence_search` - Find pages by query/date
- `confluence_get_page` - Get full page content with metadata
- `confluence_get_page_children` - Navigate page hierarchies
- `confluence_create_page` - (for future use)
- `confluence_update_page` - (for future use)

**✅ Target Spaces**: `hlcli` and `HC` (both spaces migrated simultaneously)
**✅ Space Organization**: Separate directory trees for each space
**✅ Cross-Space Linking**: Wikilinks preserved across space boundaries
**✅ Instance**: `your-instance.atlassian.net`

### Known Page IDs (from your docs)
- **Home Page**: 3899503 (HomelabARR CLI Home)
- **Installation**: 3866629 (Installation Guide)
- **Applications**: 3866648 (Application Categories)
- **Project Management**: 3866689 (Project Management)

## Migration Strategy Options

### Option A: Quick Export (Recommended for Time Constraints)
```bash
# 1. Test tools
./test-confluence-export.sh

# 2. Export key pages immediately
python3 quick-confluence-export.py
# Choose option 4 (key pages) for fastest export

# 3. Import to Obsidian and review
```

**Time Required**: 10-15 minutes
**Content**: Core documentation pages
**Risk**: Low - focuses on known critical pages

### Option B: Comprehensive Export
```bash
# 1. Test tools
./test-confluence-export.sh

# 2. Export all recent pages
python3 quick-confluence-export.py
# Choose option 2 (recent pages since July 2024)

# 3. Review and organize in Obsidian
```

**Time Required**: 30-45 minutes
**Content**: All documentation from July/August onwards
**Risk**: Medium - larger dataset to process

### Option C: Full Migration with Advanced Features
```bash
# 1. Test tools
./test-confluence-export.sh

# 2. Run full migrator
python3 confluence-to-obsidian-migrator.py
# Interactive setup with all features

# 3. Review categorized output
```

**Time Required**: 1-2 hours
**Content**: Complete migration with organization
**Risk**: Higher - more complex processing

## Output Structure

Your migrated content will be organized as:

```
.claude/confluence-export/
├── 00-export-index.md                    # Navigation index
├── HomelabARR CLI Home.md               # Main documentation hub
├── Installation Guide.md                # Setup procedures
├── Application Categories.md            # App catalog
├── Project Management.md                # Jira workflows
└── [Additional pages].md               # Other documentation
```

### Obsidian-Compatible Features

**✅ YAML Frontmatter**:
```yaml
---
title: "Page Title"
confluence_page_id: 3899503
confluence_space: DO
migrated_date: 2025-01-14T10:30:00
original_url: https://your-instance.atlassian.net/wiki/...
tags:
  - confluence-migration
  - homelabarr-cli
---
```

**✅ Wikilink Format**: `[[Page Name]]` for internal references
**✅ Markdown Conversion**: HTML content → Clean Markdown
**✅ Tag Inheritance**: Confluence labels → Obsidian tags

## Post-Migration Steps

### 1. Import to Obsidian
1. Open your Obsidian vault
2. Copy files from export directory to vault folder
3. Restart Obsidian to recognize new files
4. Check the `00-export-index.md` for navigation

### 2. Content Review
- **Formatting**: Check for HTML artifacts
- **Links**: Verify internal references work
- **Images**: Note that images may need separate handling
- **Code Blocks**: Ensure syntax highlighting works

### 3. Organization
- **Tags**: Add more specific tags for better organization
- **Folders**: Consider creating folder structure in Obsidian
- **Cross-References**: Add wikilinks between related pages
- **Templates**: Create templates for future documentation

### 4. Backup Original
Keep a backup of your Confluence export data:
```bash
# Create backup
cp -r .claude/confluence-export/ .claude/confluence-backup-$(date +%Y%m%d)/
```

## Troubleshooting

### Common Issues

#### MCP Tools Not Working
```bash
# Check if running in Claude Code with MCP Docker
echo $MCP_DOCKER_SERVER_URL

# Verify Confluence access
curl -H "Authorization: Bearer $CONFLUENCE_TOKEN" \
     "https://your-instance.atlassian.net/wiki/rest/api/space/DO"
```

#### No Pages Found
- Verify space key is correct (`DO` not `HL`)
- Check Confluence Premium is still active
- Try broader search terms ("" for all pages)

#### Export Failures
- Check output directory permissions
- Verify Python 3.8+ is installed
- Run with verbose output for debugging

#### Formatting Issues
- HTML content may need manual cleanup
- Complex tables might not convert perfectly
- Code blocks may need syntax adjustment

### Getting Help

**🔧 Technical Issues**: Check MCP_TOOLS_REFERENCE.md for tool details
**📚 Documentation**: Review your existing Confluence space first
**⏰ Time Critical**: Use Quick Export (Option A) for fastest results

## Security Notes

- **API Tokens**: Scripts use MCP tools (no direct token handling)
- **Local Files**: All exports saved locally first
- **Permissions**: Scripts only read Confluence content
- **Cleanup**: Consider deleting export files after Obsidian import

## Success Metrics

### Minimal Success (3 days to expiry)
- ✅ Key documentation pages exported
- ✅ Content readable in Obsidian
- ✅ Critical procedures preserved

### Full Success (if time permits)
- ✅ All pages from July/August onwards
- ✅ Links working between pages
- ✅ Proper categorization and tags
- ✅ Migration report generated

---

**🚀 Ready to Start?**

1. Run: `./test-confluence-export.sh`
2. If tests pass, run: `python3 quick-confluence-export.py`
3. Import to Obsidian and enjoy your preserved documentation!

**⚠️ Remember**: Confluence Premium expires in 3 days - execute soon to avoid losing access to your valuable documentation.

*Generated by HomelabARR CLI Documentation Specialist*