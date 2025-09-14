# CLAUDE.md

## Project Overview

HomelabARR CLI is a comprehensive Docker-based media server stack with Traefik reverse proxy, Authelia authentication, and Cloudflare protection. It provides automated deployment and management of media server applications like Plex, Radarr, Sonarr, and 100+ other self-hosted applications.

## Architecture

### Core Components
- **Docker Compose Stack**: All applications are containerized using Docker
- **Traefik**: Reverse proxy with automatic SSL certificate management via Let's Encrypt and Cloudflare DNS
- **Authelia**: Authentication and authorization middleware for secure access
- **Cloudflare Integration**: DNS management and DDoS protection

### Directory Structure
- `apps/`: Docker compose files organized by category (mediaserver, downloadclients, addons, etc.)
- `traefik/`: Traefik configuration templates and installation scripts
- `scripts/`: Utility scripts for maintenance, backup, and security
- `wiki/`: MkDocs-based documentation site
- `preinstall/`: System preparation and dependency installation

### Application Categories
- `mediaserver/`: Plex, Jellyfin, Emby media servers
- `mediamanager/`: Radarr, Sonarr, Lidarr, Bazarr for media automation  
- `downloadclients/`: qBittorrent, SABnzbd, NZBGet, Deluge
- `request/`: Overseerr, Petio for media requests
- `addons/`: Monitoring, dashboards, utilities
- `backup/`: Duplicati, Restic backup solutions
- `selfhosted/`: Various self-hosted applications

## Common Development Commands

### Installation and Setup
```bash
# Main installation (Ubuntu/Debian only)
sudo ./install.sh

# Install Traefik stack
sudo ./traefik/install.sh

# Install specific app category
sudo ./apps/install.sh
```

### Maintenance Scripts
```bash
# Docker system cleanup
sudo ./scripts/docker/dockerprune.sh

# Backup all containers
sudo ./backup.sh

# Disk cleanup
sudo ./scripts/disk_cleanup.sh
```

### Plex Specific
```bash
# Empty Plex trash
sudo ./scripts/plex/plex-empty-trash.sh

# Optimize Plex database
sudo ./scripts/plex/plex-optimize-db.sh
```

### Documentation
```bash
# Build wiki documentation (requires Python/MkDocs)
cd wiki && mkdocs build

# Serve documentation locally
cd wiki && mkdocs serve
```

## Configuration Management

### Environment Variables
- All applications use standardized environment variables defined in Docker Compose files
- Common variables: `PUID`, `PGID`, `TZ`, `DOMAIN`, `CLOUDFLARE_EMAIL`, `CLOUDFLARE_API_KEY`

### Template System
- Traefik configurations use Jinja2 templates in `traefik/templates/`
- Application configs support variable substitution

### Network Architecture  
- All containers use the `proxy` bridge network
- Traefik handles all external traffic routing
- Internal service communication via container names

## Security Features

### Authelia Integration
- Multi-factor authentication for all services
- LDAP/file-based user management
- Session management and access control

### Cloudflare Protection
- DNS-based SSL certificate generation
- DDoS protection and WAF rules
- Automatic subdomain management

### Security Scripts
```bash
# Ban malicious IPs
sudo ./scripts/security/badips.sh

# General IP banning
sudo ./scripts/security/bann.sh

# Traefik-specific banning
sudo ./scripts/security/traefik-bann.sh
```

## Development Guidelines

### Adding New Applications
1. Create YAML file in appropriate `apps/` subdirectory
2. Follow existing naming conventions and structure
3. Include Traefik labels for routing and SSL
4. Add documentation to `wiki/docs/apps/`

### Modifying Core Components
- Traefik changes require updating templates in `traefik/templates/`
- Network modifications affect all applications
- Always test changes in isolated environment first

### File Permissions
- All application data uses standardized UID/GID (1000:1000)
- Scripts require executable permissions
- Configuration files should be readable by containers

## Installation (Linux)

### Quick Start
```bash
# Clone and prepare
git clone https://github.com/smashingtags/homelabarr-cli.git
cd homelabarr-cli

# Make scripts executable (CRITICAL)
chmod +x install.sh preinstall/install.sh preinstall/installer/ubuntu.sh
chmod +x .installer/ubuntu.sh .installer/homelabber homelabarr-cli.sh
find scripts/ traefik/ apps/ -name "*.sh" -exec chmod +x {} \;

# Create compatibility symlink
sudo ln -sf "$(pwd)" /opt/homelabarr

# Run installer
sudo ./install.sh
```

### Installation Fixes Applied
The following critical issues were resolved for proper Linux installation:

1. **Path Resolution**: Fixed installer expecting `/opt/homelabarr` when users run from `~/homelabarr-cli`
2. **Missing Scripts**: Created `preinstall/installer/ubuntu.sh` for Docker installation
3. **Infinite Loop**: Fixed installer logic preventing endless preinstall loops
4. **Permissions**: Standardized executable permissions across all shell scripts
5. **Symlink Compatibility**: Automated symlink creation for path compatibility

### Installation Menu
After running installer, main menu shows:
- **Option 1**: HomelabARR CLI - Traefik + Authelia (run first)
- **Option 2**: HomelabARR CLI - Applications (after Traefik setup)

### Critical Commands for Installation Issues
```bash
# Fix permission errors
chmod +x install.sh
find . -name "*.sh" -exec chmod +x {} \;

# Fix path compatibility
sudo ln -sf "$(pwd)" /opt/homelabarr

# Verify Docker installation
docker --version && docker-compose --version
```

## Important Notes

- **Platform Support**: Ubuntu/Debian Linux only, no ARM support
- **Minimum Requirements**: 2 CPU cores, 4GB RAM, 20GB disk
- **Dependencies**: Docker, Docker Compose, Git
- **Domain Requirement**: Valid domain with Cloudflare DNS management
- **No Package.json**: This is a shell script/Docker Compose based project, not a Node.js application
- **Installation Documentation**: Complete guide available at `wiki/docs/install/linux-installation.md`

## Development Workflow

### Complete Development Workflow
```
Local Notes → Jira Story Creation → GitHub Branch → Code Changes → QA → [MERGE] → Publish → Confluence Docs → Close Jira Ticket
```

### Step-by-Step Process:
1. **Track locally** - Brainstorm and keep initial notes in `.claude/local-notes/` about what needs to be implemented
2. **Jira Story Creation** - Use local notes to create formal ticket with story points & detailed acceptance criteria
3. **GitHub Branch** - Auto-create from Jira ticket with proper naming (feature/TICKET-ID-description)
4. **Code changes** - Implement and validate features thoroughly based on acceptance criteria
5. **QA Validation** - Run comprehensive testing before merge
6. **QA Passed** - Transition Jira ticket to QA Passed status
7. **Merge** - Merge feature branch to main
8. **Publish** - Push changes to remote repository
9. **Clean up** - Delete feature branch
10. **Confluence docs** - Write proper documentation using local notes (only after successful publish)
11. **Close Jira** - Transition to Done with detailed completion comment

### Jira Status Flow:
```
[LOCAL BRAINSTORM] → [CREATE STORY] → To Do → In Progress → QA → QA Passed → [MERGE + PUBLISH] → [DOCUMENT] → Done
```

### Key Rules:
- **Start with brainstorming** - Capture initial thoughts locally before formalizing
- **Define before coding** - Clear acceptance criteria prevent scope creep
- **QA gates** - No merging without validation
- **Documentation protection** - Only document successful deployments to prevent rework
- **Never mark Done until**: Full workflow complete including documentation
- **Every ticket MUST have**: Story points (0.25 increments) and detailed acceptance criteria
- **Branch naming**: Auto-generated from ticket for traceability

### Story Point Scale (Technical PM Estimation)
- **0.25 SP (2h)**: Minor config tweaks, documentation fixes, single line changes
- **0.5 SP (4h)**: Simple environment updates, basic label additions, minor script modifications
- **0.75 SP (6h)**: Small feature toggles, basic health check additions, simple configurations
- **1 SP (8h)**: Standard container configuration, basic service integration, routine maintenance
- **1.5 SP (12h)**: Service integration with minor complexity, configuration template updates
- **2 SP (16h)**: Container additions with standard complexity, basic integrations, script creation
- **2.5 SP (20h)**: Complex container configurations, moderate service integrations
- **3 SP (24h)**: Complex configurations, service integrations, automation setup
- **5 SP (40h)**: Multi-service features, architectural changes, complex implementations
- **8 SP (64h)**: Major infrastructure changes, complete system overhauls

**Estimation Process**: Technical PM with HomelabARR CLI domain expertise provides story point estimates with technical reasoning, then auto-router routes implementation to appropriate domain specialist.

## MCP Integration & SDLC Automation

### IMPORTANT: Jira & Confluence Configuration
**Jira Instance**: your-instance.atlassian.net  
**Jira Project**: HomelabARR-CLI (HL)  
**Confluence Space**: DO (HomelabARR-CLI)  

**MCP Tool Usage Notes**:
- Use simple fields only to avoid errors
- Avoid custom fields except story points (customfield_10016)
- Keep descriptions concise - complex formatting often fails
- For priority, use: {"priority": {"name": "High"}} format
- Issue types: "Bug", "Task", "Story" (case-sensitive)
- Assignee: Use email "user@example.com" or omit field

### Jira MCP Commands for SDLC Workflow

#### Sprint Management
```bash
# Move issue from backlog to active sprint
mcp__MCP_DOCKER__jira_update_issue --issue_key "HL-5" --fields '{"customfield_10020": 1}'

# Move issue to future sprint for planning
mcp__MCP_DOCKER__jira_update_issue --issue_key "HL-53" --fields '{"customfield_10020": 34}'

# Get active sprints
mcp__MCP_DOCKER__jira_get_sprints_from_board --board_id "34" --state "active"

# Get future sprints for planning
mcp__MCP_DOCKER__jira_get_sprints_from_board --board_id "34" --state "future"
```

#### Backlog Organization
```bash
# Get backlog issues (not in any sprint)
mcp__MCP_DOCKER__jira_get_board_issues --board_id "34" --jql "project = HL AND sprint is EMPTY"

# Search issues by status and priority
mcp__MCP_DOCKER__jira_search --jql "project = HL AND status = 'To Do' AND priority = High"

# Get sprint issues
mcp__MCP_DOCKER__jira_get_sprint_issues --sprint_id "1" --fields "summary,status"
```

#### Issue Management
```bash
# Create new issue with epic link
mcp__MCP_DOCKER__jira_create_issue --project_key "HL" --summary "New Task" --issue_type "Task" --additional_fields '{"parent": "HL-3"}'

# Update issue status and assignee
mcp__MCP_DOCKER__jira_update_issue --issue_key "HL-5" --fields '{"assignee": {"name": "user@example.com"}}'

# Transition issue to different status
mcp__MCP_DOCKER__jira_transition_issue --issue_key "HL-5" --transition_id "31" --comment "Moving to In Progress"

# Add detailed comments
mcp__MCP_DOCKER__jira_add_comment --issue_key "HL-5" --comment "Implementation started with technical analysis complete"
```

#### Project Discovery
```bash
# Get project boards
mcp__MCP_DOCKER__jira_get_agile_boards --project_key "HL"

# Search for specific issues
mcp__MCP_DOCKER__jira_search --jql "project = HL AND issuetype = Epic AND status != Done"

# Get issue details with custom fields
mcp__MCP_DOCKER__jira_get_issue --issue_key "HL-5" --fields "summary,status,customfield_10020,assignee"
```

### Key MCP Integration Points

#### Jira Instance Configuration
- **Instance**: your-instance.atlassian.net
- **Project**: HomelabARR-CLI (HL)
- **Board ID**: 34
- **Sprint Field**: customfield_10020
- **Rank Field**: customfield_10019

#### Sprint ID Reference
- **HL Sprint 1** (Active): ID = 1
- **HL Sprint 2** (Future): ID = 34

#### API Endpoints Used
- **Sprint Management**: `/rest/agile/1.0/sprint/{sprintId}/issue` (POST)
- **Issue Ranking**: `/rest/agile/1.0/issue/rank` (PUT)
- **Issue Updates**: `/rest/api/2/issue/{issueKey}` (PUT)
- **Board Issues**: `/rest/agile/1.0/board/{boardId}/issue`

### Example: Creating Jira Issues (Simplified)
```python
# WORKING EXAMPLE - Use this format
mcp__MCP_DOCKER__jira_create_issue(
    project_key="HL",
    summary="Short descriptive title",
    issue_type="Bug",  # or "Task" or "Story"
    description="Simple text description without complex formatting"
)

# AVOID - Complex fields that cause errors
# - additional_fields with nested custom fields
# - Complex markdown in descriptions
# - assignee field with account IDs
```

### Confluence MCP Commands

#### Documentation Management
```bash
# Create new page (USE SPACE "DO" NOT "HL")
mcp__MCP_DOCKER__confluence_create_page --space_key "DO" --title "Feature Documentation" --content "# Implementation Details"

# Update existing page
mcp__MCP_DOCKER__confluence_update_page --page_id "4784253" --title "Updated Title" --content "# New Content"

# Search for pages
mcp__MCP_DOCKER__confluence_search --query "Docker compose" --limit 10

# Get page content
mcp__MCP_DOCKER__confluence_get_page --page_id "4784253" --include_metadata true
```

### SDLC Automation Workflows

#### Complete Issue Creation Workflow
1. **Create Local Notes**: Document in `.claude/local-notes/`
2. **Create Jira Issue**: `jira_create_issue` with detailed acceptance criteria
3. **Move to Sprint**: `jira_update_issue` with sprint field
4. **Track Progress**: `jira_transition_issue` through workflow states
5. **Document Completion**: `confluence_create_page` for technical documentation

#### Sprint Planning Automation
1. **Review Backlog**: `jira_get_board_issues` for unassigned items
2. **Organize by Priority**: Move high-priority items to active sprint
3. **Capacity Planning**: Assign appropriate story points and sprint slots
4. **Sprint Kickoff**: Transition issues to "In Progress" as work begins

#### Quality Gates Integration
1. **Code Review**: Use `jira_add_comment` to track review feedback
2. **QA Validation**: Transition to "QA" status with validation notes
3. **Documentation**: Create Confluence pages for completed features
4. **Release Notes**: Update documentation with feature descriptions

- After finishing sdlc always output me thine links to the new pages in confluence and jira