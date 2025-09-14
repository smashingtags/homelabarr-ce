# MCP Tools Reference Guide for HomelabARR CLI

## Active MCP Servers

### 1. MCP_DOCKER (Docker Desktop Gateway)
**Status**: ✅ ACTIVE  
**Purpose**: Main gateway providing access to all integrated tools

### 2. Memory Server
**Status**: ✅ ACTIVE  
**Purpose**: Context persistence between sessions  
**Path**: `F:\Coding Projects\homelabarr-cli\.claude\memory.json`

## Available MCP Tools by Category

### 📋 PROJECT MANAGEMENT - Atlassian Suite

#### Jira Tools (Project: HL, Instance: your-instance.atlassian.net)
- `jira_create_issue` - Create new issues (use simple fields only)
- `jira_update_issue` - Update existing issues  
- `jira_transition_issue` - Move through workflow states
- `jira_get_issue` - Get issue details
- `jira_search` - Search with JQL queries
- `jira_add_comment` - Add comments to issues
- `jira_get_agile_boards` - Get board info (Board ID: 34)
- `jira_get_sprints_from_board` - List sprints
- `jira_get_sprint_issues` - Get issues in sprint
- `jira_create_sprint` - Create new sprint
- `jira_update_sprint` - Update sprint details
- `jira_link_to_epic` - Link issue to epic
- `jira_get_transitions` - Get available status transitions

**Known Issues**:
- Avoid complex custom fields except story points (customfield_10016)
- Use simple field formats: `{"priority": {"name": "High"}}`
- Issue types are case-sensitive: "Bug", "Task", "Story"
- Assignee: Use email "user@example.com"

#### Confluence Tools (Space: DO)
- `confluence_create_page` - Create documentation
- `confluence_update_page` - Update existing pages
- `confluence_search` - Search documentation
- `confluence_get_page` - Get page content
- `confluence_add_label` - Add page labels

**Known Issues**:
- Use space "DO" not "HL" for HomelabARR documentation
- Keep markdown formatting simple

### 💻 DEVELOPMENT - GitHub Tools

#### Repository Management
- `create_repository` - Create new repo
- `fork_repository` - Fork existing repo
- `get_file_contents` - Read files from repo
- `create_or_update_file` - Modify repo files
- `delete_file` - Remove files

#### Branch & PR Management  
- `create_branch` - Create feature branches
- `list_branches` - List all branches
- `create_pull_request` - Open new PR
- `update_pull_request` - Modify PR
- `merge_pull_request` - Merge PR
- `get_pull_request` - Get PR details
- `list_pull_requests` - List all PRs

#### Issue Management
- `create_issue` - Create GitHub issue
- `update_issue` - Update issue
- `get_issue` - Get issue details
- `list_issues` - List repository issues
- `search_issues` - Search with GitHub syntax

#### Code & Search
- `search_code` - Search code across GitHub
- `search_repositories` - Find repositories
- `get_commit` - Get commit details
- `list_commits` - List commit history

#### Workflow & Actions
- `run_workflow` - Trigger GitHub Actions
- `get_workflow_run` - Get run status
- `rerun_failed_jobs` - Retry failed jobs
- `list_workflow_runs` - List workflow history

### 🐳 DOCKER - Container Management

#### Docker Hub Tools
- `search` - Search Docker Hub for images
- `getRepositoryInfo` - Get repository details
- `listRepositoryTags` - List available tags
- `createRepository` - Create new repository
- `checkRepository` - Verify repository exists
- `dockerHardenedImages` - List DHI images

**Known Issues**:
- Use "library" namespace for official images
- Always check if repository exists before operations

### 🔍 RESEARCH & DOCUMENTATION

#### Reference Tools
- `ref_search_documentation` - Search technical docs
- `ref_read_url` - Read and convert URLs to markdown
- `resolve-library-id` - Get Context7 library IDs
- `get-library-docs` - Fetch library documentation

**Best Practices**:
- Use ref_search_documentation for best practices research
- Use Context7 for specific library/framework docs

### 🛠️ UTILITIES

#### Git Operations
- `git_status` - Check repository status
- `git_add` - Stage changes
- `git_commit` - Commit changes
- `git_diff` - Show differences
- `git_log` - View commit history
- `git_create_branch` - Create local branch

#### UI Development - shadcn/ui MCP Server
**Status**: ✅ ACTIVE (Successfully integrated by Michael)
**Purpose**: UI component management for React/Next.js development
**Resources**: [Lobe Hub Guide](https://lobehub.com/mcp/jpisnice-shadcn-ui-mcp-server) | [Official Docs](https://ui.shadcn.com/docs/mcp)

**Available Commands**:
- `add_component` - Add shadcn/ui components to project
- `list_components` - List available shadcn/ui components
- `init_project` - Initialize shadcn/ui in existing project
- `update_component` - Update existing components
- `remove_component` - Remove components from project
- `get_component_info` - Get detailed component information

**Integration Benefits**:
- Automated component installation and configuration
- Consistent UI component management across projects
- Direct integration with HomelabARR CLI frontend development
- Streamlined React/TypeScript development workflow

**Usage in HomelabARR Context**:
- Frontend dashboard component development
- Configuration UI enhancements
- Admin interface improvements
- Consistent design system implementation

#### System Tools
- `curl` - Make HTTP requests for testing
- `generate_diagram` - Create architecture diagrams
- `list_icons` - List available diagram icons

**Diagram Tool Notes**:
- Despite name "AWS Diagram", works for all architectures
- Supports Docker, Kubernetes, on-premise diagrams
- Use `list_icons` first to see available components

### 📊 MONITORING (Optional - Enable When Needed)

#### Grafana Tools
- Various dashboard and datasource management tools
- Enable only when actively working on monitoring features

## ⚠️ CRITICAL KNOWN QUIRKS - READ BEFORE USING

### 🔴 Jira Field Limits & Formatting Rules

#### Character Limits
- **Summary**: 255 characters MAX
- **Description**: 32,767 characters MAX  
- **Comment**: 32,767 characters MAX
- **Sprint Name**: 255 characters MAX
- **Epic Name**: 255 characters MAX

#### Required Field Formats (MUST USE EXACTLY)
```python
# ✅ CORRECT - Simple formats that work
jira_create_issue(
    project_key="HL",
    summary="Short title under 255 chars",
    issue_type="Task",  # EXACT case: "Task", "Bug", "Story"
    description="Plain text, avoid complex markdown"
)

# ❌ WRONG - These will fail
issue_type="task"  # Wrong case
issue_type="Sub-task"  # Should be "Subtask"
assignee={"accountId": "123"}  # Too complex
priority="High"  # Wrong format
```

#### Working Field Examples
```python
# Priority (use name format)
fields={"priority": {"name": "High"}}  # ✅
fields={"priority": "High"}  # ❌

# Assignee (use email only)
fields={"assignee": "user@example.com"}  # ✅
fields={"assignee": {"accountId": "..."}}  # ❌

# Story Points
additional_fields={"customfield_10016": 2.5}  # ✅

# Labels (simple array)
fields={"labels": ["backend", "urgent"]}  # ✅

# Components (names only)
components="Frontend,Backend"  # ✅
```

### 🔴 Confluence Content Limits

#### Character Limits
- **Page Title**: 255 characters MAX
- **Page Content**: 2,097,152 characters (2MB) MAX
- **Space Key**: 255 characters (but use short ones like "DO")

#### Content Formatting Rules
```python
# ✅ CORRECT - Simple markdown
confluence_create_page(
    space_key="DO",  # Use DO, not HL
    title="Title under 255 chars",
    content="# Simple Markdown\n\nBasic **bold** and *italic*"
)

# ❌ AVOID - Complex formatting often fails
- HTML tables with nested elements
- Complex code blocks with syntax highlighting
- Embedded macros
- Large images inline
```

### 🔴 GitHub API Limits

#### Field Limits
- **PR Title**: 256 characters MAX
- **PR Body**: 65,536 characters MAX
- **Issue Title**: 256 characters MAX
- **Issue Body**: 65,536 characters MAX
- **Commit Message**: First line 72 chars (recommended)
- **Branch Name**: 255 characters MAX

#### Rate Limits
- **Authenticated**: 5,000 requests/hour
- **Search API**: 30 requests/minute

### 🔴 Common Failure Patterns & Fixes

#### 1. Jira Issue Creation Failures
```python
# ❌ FAILS: Complex nested fields
jira_create_issue(
    additional_fields={
        "customfield_10010": {"id": "10000", "value": "Epic"}
    }
)

# ✅ WORKS: Simple field format
jira_create_issue(
    additional_fields={"parent": "HL-3"}  # Link to epic
)
```

#### 2. Confluence Page Creation Failures
```python
# ❌ FAILS: Wrong space
confluence_create_page(space_key="HL", ...)  # HL is Jira, not Confluence

# ✅ WORKS: Correct space
confluence_create_page(space_key="DO", ...)
```

#### 3. Sprint Field Updates
```python
# ❌ FAILS: Wrong sprint field
fields={"sprint": 1}

# ✅ WORKS: Correct custom field
fields={"customfield_10020": 1}  # Sprint field for HL project
```

### 🔴 Windows-Specific Issues

#### Docker Command
```bash
# ❌ FAILS on Windows
docker ps

# ✅ WORKS on Windows
docker.exe ps
```

#### Path Formats
```python
# ❌ FAILS: Linux paths on Windows
file_path="/home/user/file.txt"

# ✅ WORKS: Windows paths
file_path="F:\\Coding Projects\\homelabarr-cli\\file.txt"
```

### 🔴 MCP Tool Timeouts

- **Default timeout**: 30 seconds
- **Long operations**: May timeout (use background tasks)
- **Large responses**: Truncated at 30,000 characters

### 🟡 Field Validation Checklist

Before running any Atlassian command:
- [ ] Summary/Title under 255 characters?
- [ ] Using correct issue type case? ("Task" not "task")
- [ ] Using simple field formats? (no nested objects)
- [ ] Using correct space? (DO for Confluence, HL for Jira)
- [ ] Description under 32KB?
- [ ] Using email for assignee? (not account ID)

### 🟢 Quick Reference - What Always Works

```python
# Jira - Minimal working example
jira_create_issue(
    project_key="HL",
    summary="Fix Docker integration",
    issue_type="Task"
)

# Confluence - Minimal working example  
confluence_create_page(
    space_key="DO",
    title="Docker Setup Guide",
    content="# Guide\n\nContent here"
)

# GitHub - Minimal working example
create_pull_request(
    owner="smashingtags",
    repo="homelabarr-cli",
    title="Fix: Docker integration",
    head="feature/fix",
    base="main"
)
```

## Known Global Issues & Workarounds

### 1. Discord MCP Login
**Issue**: Session doesn't persist, multiple containers spawn  
**Workaround**: Avoid Discord tools for now

### 2. Windows/WSL Docker Access
**Fix**: Use `docker.exe` instead of `docker` on Windows
```bash
export DOCKER_CMD="docker.exe"
```

### 3. Jira Custom Fields
**Issue**: Complex custom fields cause errors  
**Fix**: Use only simple fields, avoid nested objects

### 4. Multiple Similar Tools
**Issue**: Ref vs Fetch vs Perplexity confusion  
**Fix**: Disabled redundant tools, use Ref + Context7 only

## Autoroute Agent Selection Guide

### When to Route to Specific Agents:

#### **jira-project-manager**
- Creating/updating Jira issues
- Sprint planning and management
- Moving issues through workflow

#### **documentation-specialist**  
- Creating Confluence pages
- Updating project documentation
- Writing technical guides

#### **docker-infrastructure-specialist**
- Docker Compose configuration
- Container optimization
- Docker Hub operations

#### **deployment-engineer**
- CI/CD pipeline work
- GitHub Actions setup
- Deployment automation

#### **debugger**
- Troubleshooting container failures
- Investigating Traefik routing issues
- Debugging authentication problems

#### **code-reviewer**
- Reviewing Docker Compose files
- Checking YAML configurations
- Security review of scripts

#### **mcp-backend-engineer**
- MCP tool implementation
- Fixing MCP connectivity issues
- Adding new MCP capabilities

## Quick Reference Commands

### Most Used MCP Commands
```python
# Jira
mcp__MCP_DOCKER__jira_search(jql="project = HL AND status = 'To Do'")
mcp__MCP_DOCKER__jira_create_issue(project_key="HL", summary="...", issue_type="Task")

# Confluence
mcp__MCP_DOCKER__confluence_create_page(space_key="DO", title="...", content="...")

# GitHub
mcp__MCP_DOCKER__create_branch(owner="...", repo="homelabarr-cli", branch="feature/...")
mcp__MCP_DOCKER__create_pull_request(owner="...", repo="...", title="...", head="...", base="main")

# Docker Hub
mcp__MCP_DOCKER__search(query="traefik")
mcp__MCP_DOCKER__getRepositoryInfo(namespace="library", repository="nginx")

# Reference
mcp__MCP_DOCKER__ref_search_documentation(query="Docker best practices")

# shadcn/ui Development
mcp__MCP_DOCKER__add_component(component="button")
mcp__MCP_DOCKER__list_components()
mcp__MCP_DOCKER__init_project(framework="react")
mcp__MCP_DOCKER__get_component_info(component="dialog")

# Utilities
mcp__MCP_DOCKER__curl(args=["http://localhost:8080/health"])
mcp__MCP_DOCKER__generate_diagram(code="with Diagram(...)")
```

## Environment Variables
- **Jira Project**: HL
- **Jira Board ID**: 34  
- **Confluence Space**: DO
- **GitHub Repo**: homelabarr-cli
- **Docker Command**: docker.exe (Windows) or docker (Linux)

## Support Links
- Jira: https://your-instance.atlassian.net
- Confluence: https://your-instance.atlassian.net/wiki/spaces/DO
- GitHub: https://github.com/smashingtags/homelabarr-cli

---
*Last Updated: 2025-01-14 - Added shadcn/ui MCP server integration*
*Use this reference when routing tasks to specialized agents*