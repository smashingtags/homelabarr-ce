---
title: "HomelabARR-CLI : 2025-01-17 - Epic Required Fields Configuration"
confluence_id: "15204484"
confluence_url: "https://mjashley.atlassian.net/wiki/spaces/DO/pages/15204484"
confluence_space: "DO"
category: "Frontend"
created_date: "2025-01-17"
updated_date: "2025-01-17"
migrated_date: "2025-09-14"
tags: ['frontend', 'docker', 'golang', 'project-management', 'epic']
---

# Epic Required Fields Configuration

## Purpose

Standardize Epic creation to match Story discipline and ensure consistent workflow governance across all ticket types.
## Current State Analysis

### Stories (Already Standardized)

**Required Fields:**- Project Key:`HL`- Work Type/Issue Type:`Story`- Summary: Descriptive title - Labels: Comprehensive labeling for organization - Priority:`High`,`Medium`,`Low`- Story Points:`customfield_10016`(numeric value)

**Current Working Command:**
```
mcp__MCP_DOCKER__jira_create_issue \
  --project_key "HL" \
  --issue_type "Story" \
  --summary "Story title" \
  --additional_fields '{"labels": ["epic-name"], "priority": {"name": "Medium"}, "customfield_10016": 2}'
```