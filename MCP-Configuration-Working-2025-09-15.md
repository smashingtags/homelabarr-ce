# MCP Server Configuration - Complete Working Setup

**Date:** September 15, 2025
**Status:** ✅ ALL MCP TOOLS WORKING
**Project:** HomelabARR CLI

## WORKING MCP CONFIGURATION

### Claude Code Configuration File: `/home/michael/.claude.json`

```json
{
  "mcpServers": {
    "shadcn": {
      "type": "http",
      "url": "https://www.shadcn.io/api/mcp"
    },
    "n8n-mcp": {
      "command": "docker",
      "args": [
        "run",
        "-i",
        "--rm",
        "--init",
        "-e", "MCP_MODE=stdio",
        "-e", "LOG_LEVEL=error",
        "-e", "DISABLE_CONSOLE_OUTPUT=true",
        "-e", "N8N_API_URL=http://192.168.1.x:5678",
        "-e", "N8N_API_KEY=REDACTED_N8N_API_KEY",
        "ghcr.io/czlonkowski/n8n-mcp:latest"
      ]
    },
    "discord": {
      "type": "http",
      "url": "http://127.0.0.1:8099/mcp"
    }
  }
}
```

### Docker Desktop MCP Configuration

**Additional MCP Servers via Docker Desktop:**
- **MCP_DOCKER**: Full Docker management toolkit
- **Jam**: Bug analysis and debugging tools
- **Jira**: Project management integration
- **Confluence**: Documentation management
- **Obsidian**: Local knowledge management
- **Discord** (if configured): Discord bot management

## CRITICAL: FAILED CONFIGURATIONS (DO NOT USE)

### ❌ BROKEN n8n-mcp Config (npx approach):
```json
"n8n-mcp": {
  "command": "npx",
  "args": ["n8n-mcp"],
  "env": {
    "MCP_MODE": "stdio",
    "LOG_LEVEL": "error",
    "DISABLE_CONSOLE_OUTPUT": "true",
    "N8N_API_URL": "http://192.168.1.x:5678",
    "N8N_API_KEY": "REDACTED_N8N_API_KEY"
  }
}
```

**Why npx FAILS:**
- Node.js version mismatch (v24.6.0 vs compiled v127)
- Environment variables not passed correctly to npx subprocess
- better-sqlite3 compilation errors

## WORKING MCP TOOLS VERIFIED

### ✅ n8n-mcp (24 tools available)
- **search_nodes()** - Find n8n nodes
- **list_nodes()** - List available nodes
- **get_node_info()** - Get node details
- **validate_workflow()** - Validate workflows
- **n8n_create_workflow()** - Create workflows
- **tools_documentation()** - Get tool help
- And 18 more workflow management tools

### ✅ shadcn/ui (2 tools available)
- **getComponents()** - List all available components
- **getComponent()** - Get specific component details

### ✅ Jira (25+ tools available)
- **jira_search()** - Search issues with JQL
- **jira_create_issue()** - Create new issues
- **jira_get_issue()** - Get issue details
- **jira_update_issue()** - Update existing issues
- **jira_transition_issue()** - Change issue status
- And 20+ more project management tools

### ✅ Confluence (10+ tools available)
- **confluence_search()** - Search documentation
- **confluence_create_page()** - Create new pages
- **confluence_get_page()** - Get page content
- **confluence_update_page()** - Update existing pages
- And 6+ more documentation tools

### ✅ Obsidian (15+ tools available)
- **obsidian_simple_search()** - Search vault content
- **obsidian_get_file_contents()** - Read vault files
- **obsidian_append_content()** - Add content to files
- **obsidian_list_files_in_vault()** - List vault files
- And 11+ more knowledge management tools

### ✅ Jam (5+ tools available)
- **getDetails()** - Get jam details
- **getConsoleLogs()** - Extract console logs
- **getUserEvents()** - Get user interactions
- **getNetworkRequests()** - Analyze network activity
- **analyzeVideo()** - Analyze jam recordings

### ✅ Docker (via MCP_DOCKER)
- Full Docker container management
- Image management
- Network management
- Volume management

## n8n Server Configuration

### Production n8n Instance
- **URL:** http://192.168.1.x:5678
- **API Key:** REDACTED_N8N_API_KEY
- **Status:** ✅ Operational
- **Key Generated:** From n8n WebUI → Settings → n8n API → Create API Key

## Discord Bot Configuration (if applicable)

### Discord MCP Server
**Location:** Docker Desktop MCP Toolkit
**Status:** Available through MCP_DOCKER gateway
**Capabilities:** Discord server management, message handling, bot interactions

## Setup Instructions for New Machines

### 1. Prerequisites
```bash
# Verify Docker is running
docker --version
docker ps

# Verify Claude Code installed
claude --version
```

### 2. Create Configuration File
```bash
# Edit Claude configuration
nano /home/michael/.claude.json
```

### 3. Copy EXACT Configuration
Use the complete JSON configuration from the "WORKING MCP CONFIGURATION" section above.

**CRITICAL:** Use Docker approach for n8n-mcp, NOT npx.

### 4. Restart Claude Code
```bash
# Exit current session
/exit

# Start new session
claude
```

### 5. Verify All Tools
```bash
# Check MCP status
/mcp

# Test n8n-mcp
search_nodes("slack")

# Test shadcn/ui
getComponents()

# Test Jira
jira_search --jql "project = HL" --limit 1

# Test other tools
confluence_search --query "test"
obsidian_list_files_in_vault()
```

## Troubleshooting

### If n8n-mcp Shows "Failed"
1. **Check Docker:** `docker ps`
2. **Pull latest image:** `docker pull ghcr.io/czlonkowski/n8n-mcp:latest`
3. **Test n8n API:** `curl http://192.168.1.x:5678/api/v1/workflows -H "X-N8N-API-KEY: REDACTED_N8N_API_KEY"`
4. **Validate JSON:** `cat /home/michael/.claude.json | jq .`

### Common Error Solutions
- **"Node.js version mismatch"** → Use Docker config (not npx)
- **"n8n API: not configured"** → Use `-e` flags in Docker args
- **"Connection refused"** → Verify n8n server running
- **"Invalid JSON"** → Check JSON syntax

## Configuration Backup

### Critical Files to Backup
```bash
# Backup main Claude config
cp /home/michael/.claude.json ~/backups/claude-config-$(date +%Y%m%d).json

# Backup project MCP config (if exists)
cp .mcp.json ~/backups/project-mcp-$(date +%Y%m%d).json
```

---

**✅ STATUS: ALL MCP TOOLS OPERATIONAL**
**Last Verified:** September 15, 2025
**Total MCP Tools Available:** 80+ across all servers

**Key Success Factors:**
1. Docker approach for n8n-mcp (not npx)
2. Proper environment variable handling with `-e` flags
3. Docker Desktop MCP toolkit for additional servers
4. Correct API keys and server URLs