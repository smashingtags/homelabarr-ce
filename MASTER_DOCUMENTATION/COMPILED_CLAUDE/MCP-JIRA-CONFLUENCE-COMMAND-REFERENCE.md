# MCP Jira & Confluence Command Reference Guide

## Overview
This document provides a comprehensive reference for all MCP (Model Context Protocol) commands for Jira and Confluence integration, specifically tested and validated for the HomelabARR CLI project SDLC workflow.

**Last Updated**: August 17, 2025  
**Project**: HomelabARR CLI  
**Jira Instance**: your-instance.atlassian.net  
**Project Key**: HL  

## Jira Integration Commands

### Sprint Management ✅ TESTED

#### Move Issue to Sprint
```bash
# Move issue from backlog to active sprint (HL Sprint 1 = ID 1)
mcp__MCP_DOCKER__jira_update_issue \
  --issue_key "HL-5" \
  --fields '{"customfield_10020": 1}'

# Move issue to future sprint (HL Sprint 2 = ID 34)  
mcp__MCP_DOCKER__jira_update_issue \
  --issue_key "HL-53" \
  --fields '{"customfield_10020": 34}'
```

**Key Field**: `customfield_10020` = Sprint field
**Tested Results**: ✅ HL-5 → HL Sprint 1, HL-53 → HL Sprint 2

#### Get Sprint Information
```bash
# Get active sprints for board
mcp__MCP_DOCKER__jira_get_sprints_from_board \
  --board_id "34" \
  --state "active"

# Get future sprints for planning
mcp__MCP_DOCKER__jira_get_sprints_from_board \
  --board_id "34" \
  --state "future"

# Get closed sprints for retrospectives
mcp__MCP_DOCKER__jira_get_sprints_from_board \
  --board_id "34" \
  --state "closed"
```

#### Sprint Issue Management
```bash
# Get issues in specific sprint
mcp__MCP_DOCKER__jira_get_sprint_issues \
  --sprint_id "1" \
  --fields "summary,status,assignee" \
  --limit 10

# Get issues in sprint with full details
mcp__MCP_DOCKER__jira_get_sprint_issues \
  --sprint_id "1" \
  --fields "*all" \
  --limit 5
```

### Backlog Management ✅ TESTED

#### Get Backlog Issues
```bash
# Get all backlog issues (not in any sprint)
mcp__MCP_DOCKER__jira_get_board_issues \
  --board_id "34" \
  --jql "project = HL AND sprint is EMPTY" \
  --limit 10

# Get backlog issues ordered by rank
mcp__MCP_DOCKER__jira_get_board_issues \
  --board_id "34" \
  --jql "project = HL AND sprint is EMPTY ORDER BY rank ASC" \
  --fields "summary,priority" \
  --limit 5
```

#### Search and Filter Issues
```bash
# Search by status and priority
mcp__MCP_DOCKER__jira_search \
  --jql "project = HL AND status = 'To Do' AND priority = High" \
  --fields "summary,status,priority" \
  --limit 10

# Search for epics
mcp__MCP_DOCKER__jira_search \
  --jql "project = HL AND issuetype = Epic AND status != Done" \
  --fields "summary,status" \
  --limit 5

# Search recently updated issues
mcp__MCP_DOCKER__jira_search \
  --jql "project = HL AND updated >= -7d ORDER BY updated DESC" \
  --fields "summary,updated" \
  --limit 10
```

### Issue Management ✅ TESTED

#### Create Issues
```bash
# Create basic task
mcp__MCP_DOCKER__jira_create_issue \
  --project_key "HL" \
  --summary "New Feature Implementation" \
  --issue_type "Task" \
  --description "Detailed implementation requirements"

# Create issue with epic link
mcp__MCP_DOCKER__jira_create_issue \
  --project_key "HL" \
  --summary "Subtask Implementation" \
  --issue_type "Task" \
  --assignee "user@example.com" \
  --additional_fields '{"parent": "HL-3"}'

# Create story with components
mcp__MCP_DOCKER__jira_create_issue \
  --project_key "HL" \
  --summary "User Story Title" \
  --issue_type "Story" \
  --components "Frontend,Backend" \
  --additional_fields '{"priority": {"name": "High"}}'
```

#### Update Issues
```bash
# Update multiple fields
mcp__MCP_DOCKER__jira_update_issue \
  --issue_key "HL-5" \
  --fields '{"assignee": {"name": "user@example.com"}, "priority": {"name": "High"}}'

# Add to sprint and update status
mcp__MCP_DOCKER__jira_update_issue \
  --issue_key "HL-7" \
  --fields '{"customfield_10020": 1}'

# Update description and labels
mcp__MCP_DOCKER__jira_update_issue \
  --issue_key "HL-10" \
  --fields '{"description": "Updated requirements", "labels": ["enhancement", "priority"]}'
```

#### Issue Transitions
```bash
# Get available transitions for issue
mcp__MCP_DOCKER__jira_get_transitions \
  --issue_key "HL-5"

# Transition to In Progress
mcp__MCP_DOCKER__jira_transition_issue \
  --issue_key "HL-5" \
  --transition_id "21" \
  --comment "Starting implementation"

# Transition to QA with resolution
mcp__MCP_DOCKER__jira_transition_issue \
  --issue_key "HL-5" \
  --transition_id "31" \
  --fields '{"resolution": {"name": "Fixed"}}' \
  --comment "Ready for QA validation"
```

#### Comments and Collaboration
```bash
# Add implementation comment
mcp__MCP_DOCKER__jira_add_comment \
  --issue_key "HL-5" \
  --comment "🚀 **Implementation Started**

**Phase 1**: Port analysis and mapping complete
**Phase 2**: Configuration updates in progress  
**Timeline**: Expected completion in 24 hours

**Technical Notes**: Found 15 port conflicts requiring resolution"

# Add completion comment with details
mcp__MCP_DOCKER__jira_add_comment \
  --issue_key "HL-7" \
  --comment "✅ **Feature Complete**

**Summary**: Health checks implemented for all 100+ containers
**Testing**: Validated across media server, download clients, and monitoring stack
**Documentation**: Updated in Confluence with implementation details"
```

### Advanced Issue Operations

#### Get Issue Details
```bash
# Get issue with sprint and rank information
mcp__MCP_DOCKER__jira_get_issue \
  --issue_key "HL-5" \
  --fields "summary,status,customfield_10020,customfield_10019,assignee,priority"

# Get issue with full details and comments
mcp__MCP_DOCKER__jira_get_issue \
  --issue_key "HL-5" \
  --fields "*all" \
  --expand "changelog,renderedFields" \
  --comment_limit 5
```

#### Worklog Management
```bash
# Add work log entry
mcp__MCP_DOCKER__jira_add_worklog \
  --issue_key "HL-5" \
  --time_spent "4h" \
  --comment "Port conflict analysis and Docker Compose updates"

# Add worklog with specific start time
mcp__MCP_DOCKER__jira_add_worklog \
  --issue_key "HL-7" \
  --time_spent "2h 30m" \
  --started "2025-08-17T09:00:00.000+0000" \
  --comment "Health check implementation for media servers"

# Get worklog entries
mcp__MCP_DOCKER__jira_get_worklog \
  --issue_key "HL-5"
```

## Board and Project Operations

### Board Management
```bash
# Get all agile boards for project
mcp__MCP_DOCKER__jira_get_agile_boards \
  --project_key "HL"

# Get board by name search
mcp__MCP_DOCKER__jira_get_agile_boards \
  --board_name "DS board" \
  --board_type "scrum"

# Get board issues with custom JQL
mcp__MCP_DOCKER__jira_get_board_issues \
  --board_id "34" \
  --jql "assignee = currentUser() AND status != Done" \
  --fields "summary,status,priority"
```

### Project Information
```bash
# Get all project issues
mcp__MCP_DOCKER__jira_get_project_issues \
  --project_key "HL" \
  --limit 20

# Get project versions for release planning
mcp__MCP_DOCKER__jira_get_project_versions \
  --project_key "HL"
```

## Confluence Integration Commands

### Page Management ✅ TESTED

#### Create Pages
```bash
# Create basic page
mcp__MCP_DOCKER__confluence_create_page \
  --space_key "HL" \
  --title "Feature Implementation Guide" \
  --content "# Implementation Details

## Overview
Comprehensive guide for implementing new features in HomelabARR CLI.

## Architecture
- Docker Compose based
- Traefik reverse proxy integration
- Authelia authentication required"

# Create child page under parent
mcp__MCP_DOCKER__confluence_create_page \
  --space_key "HL" \
  --title "Docker Health Checks Implementation" \
  --parent_id "4784253" \
  --content "# Health Check Implementation

## Technical Specifications
- Container health monitoring
- Docker Compose health check syntax
- Integration with monitoring stack"
```

#### Update Pages
```bash
# Update existing page content
mcp__MCP_DOCKER__confluence_update_page \
  --page_id "4784253" \
  --title "Updated Feature Documentation" \
  --content "# Updated Implementation Guide

## Recent Changes
- Added ARM64 support documentation
- Updated container requirements
- Enhanced security guidelines" \
  --version_comment "Updated with ARM64 support and security enhancements"

# Minor edit update
mcp__MCP_DOCKER__confluence_update_page \
  --page_id "4784253" \
  --title "Feature Documentation" \
  --content "# Implementation Guide

## Quick Update
Fixed typos and updated links." \
  --is_minor_edit true
```

#### Get Page Content
```bash
# Get page with metadata
mcp__MCP_DOCKER__confluence_get_page \
  --page_id "4784253" \
  --include_metadata true \
  --convert_to_markdown true

# Get page by title and space
mcp__MCP_DOCKER__confluence_get_page \
  --title "HomelabARR CLI Architecture" \
  --space_key "HL" \
  --include_metadata false

# Get page in raw HTML format
mcp__MCP_DOCKER__confluence_get_page \
  --page_id "4784253" \
  --convert_to_markdown false
```

#### Search Pages
```bash
# Simple text search
mcp__MCP_DOCKER__confluence_search \
  --query "Docker compose" \
  --limit 10

# CQL search for recent content
mcp__MCP_DOCKER__confluence_search \
  --query "space = HL AND lastModified >= startOfWeek()" \
  --limit 5

# Search with space filter
mcp__MCP_DOCKER__confluence_search \
  --query "health checks" \
  --spaces_filter "HL,DEV" \
  --limit 15
```

### Page Organization

#### Labels and Metadata
```bash
# Add labels to page
mcp__MCP_DOCKER__confluence_add_label \
  --page_id "4784253" \
  --name "docker"

mcp__MCP_DOCKER__confluence_add_label \
  --page_id "4784253" \
  --name "implementation"

# Get page labels
mcp__MCP_DOCKER__confluence_get_labels \
  --page_id "4784253"
```

#### Comments and Collaboration
```bash
# Add comment to page
mcp__MCP_DOCKER__confluence_add_comment \
  --page_id "4784253" \
  --content "## Review Feedback

**Technical Review**: Implementation looks solid, recommend adding error handling section.

**Documentation**: Consider adding troubleshooting guide for common deployment issues."

# Get page comments
mcp__MCP_DOCKER__confluence_get_comments \
  --page_id "4784253"
```

#### Page Hierarchy
```bash
# Get child pages
mcp__MCP_DOCKER__confluence_get_page_children \
  --parent_id "4784253" \
  --include_content false \
  --limit 10

# Get child pages with content
mcp__MCP_DOCKER__confluence_get_page_children \
  --parent_id "4784253" \
  --include_content true \
  --convert_to_markdown true \
  --limit 5
```

## Key Configuration Values

### Jira Configuration
- **Instance URL**: your-instance.atlassian.net
- **Project Key**: HL (HomelabARR-CLI)
- **Board ID**: 34
- **Sprint Field**: customfield_10020
- **Rank Field**: customfield_10019

### Sprint IDs
- **HL Sprint 1** (Active): 1
- **HL Sprint 2** (Future): 34

### Confluence Configuration
- **Space Key**: HL
- **Main Page ID**: 4784253 (Comprehensive Rebranding Documentation)

### Common JQL Patterns
```sql
-- Backlog issues
project = HL AND sprint is EMPTY

-- Current sprint issues
project = HL AND sprint = "HL Sprint 1"

-- My assigned issues
project = HL AND assignee = currentUser() AND status != Done

-- Recent updates
project = HL AND updated >= -7d ORDER BY updated DESC

-- Epics and their children
project = HL AND issuetype = Epic
project = HL AND parent = "HL-3"

-- Issues ready for QA
project = HL AND status = "QA" AND assignee = currentUser()
```

## SDLC Integration Patterns

### Complete Feature Implementation Workflow
```bash
# 1. Create feature issue
mcp__MCP_DOCKER__jira_create_issue \
  --project_key "HL" \
  --summary "Implement ARM64 Support" \
  --issue_type "Story" \
  --description "Add ARM64 architecture support for broader hardware compatibility"

# 2. Move to active sprint
mcp__MCP_DOCKER__jira_update_issue \
  --issue_key "HL-NEW" \
  --fields '{"customfield_10020": 1}'

# 3. Start implementation
mcp__MCP_DOCKER__jira_transition_issue \
  --issue_key "HL-NEW" \
  --transition_id "21" \
  --comment "Starting ARM64 implementation"

# 4. Track progress
mcp__MCP_DOCKER__jira_add_comment \
  --issue_key "HL-NEW" \
  --comment "✅ **Phase 1 Complete**: Architecture analysis finished"

# 5. Complete and document
mcp__MCP_DOCKER__jira_transition_issue \
  --issue_key "HL-NEW" \
  --transition_id "31" \
  --comment "Implementation complete, ready for QA"

mcp__MCP_DOCKER__confluence_create_page \
  --space_key "HL" \
  --title "ARM64 Support Implementation" \
  --content "# ARM64 Support Documentation..."
```

### Sprint Planning Automation
```bash
# 1. Review backlog
mcp__MCP_DOCKER__jira_get_board_issues \
  --board_id "34" \
  --jql "project = HL AND sprint is EMPTY ORDER BY priority DESC, rank ASC"

# 2. Move high-priority items to next sprint
mcp__MCP_DOCKER__jira_update_issue \
  --issue_key "HL-PRIORITY" \
  --fields '{"customfield_10020": 34}'

# 3. Add sprint planning notes
mcp__MCP_DOCKER__jira_add_comment \
  --issue_key "HL-PRIORITY" \
  --comment "📋 **Sprint Planning**: Moved to Sprint 2 for Q4 delivery"
```

## Error Handling and Troubleshooting

### Common Issues
1. **Sprint Field Not Found**: Verify `customfield_10020` is correct sprint field
2. **Permission Denied**: Ensure proper Jira permissions for issue updates
3. **Board ID Invalid**: Use `jira_get_agile_boards` to find correct board ID
4. **Transition Failed**: Check available transitions with `jira_get_transitions`

### Validation Commands
```bash
# Verify issue was moved to sprint
mcp__MCP_DOCKER__jira_get_issue \
  --issue_key "HL-5" \
  --fields "customfield_10020"

# Check sprint contents
mcp__MCP_DOCKER__jira_get_sprint_issues \
  --sprint_id "1" \
  --fields "summary" \
  --limit 5

# Verify page creation
mcp__MCP_DOCKER__confluence_search \
  --query "title:\"New Page Title\"" \
  --limit 1
```

## Best Practices

### Jira Issue Management
1. **Always add meaningful comments** when transitioning issues
2. **Use consistent sprint assignment** for planning visibility
3. **Include story points and acceptance criteria** in issue descriptions
4. **Link related issues** to maintain traceability

### Confluence Documentation
1. **Create documentation after successful implementation** only
2. **Use consistent page hierarchy** for organization
3. **Add appropriate labels** for searchability
4. **Include technical details and troubleshooting** in implementation guides

### Workflow Integration
1. **Follow SDLC gates**: Local Notes → Jira → Implementation → QA → Documentation
2. **Validate each step** before proceeding to next phase
3. **Use automation** for repetitive tasks like sprint management
4. **Maintain audit trail** through comments and transitions

---

**This reference guide is living documentation** - update as new MCP capabilities are added or workflows are refined.