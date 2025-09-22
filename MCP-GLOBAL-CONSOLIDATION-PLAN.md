# MCP Global Consolidation Plan - URGENT

**Date**: September 15, 2025
**Status**: MUST COMPLETE BEFORE COMPACTION

## Problem
- MCP tools scattered across multiple configs
- LinkedIn MCP keeps fucking up other tools
- Tools lost when switching between projects/folders
- No version control of MCP configs

## Solution: Move ALL to Global Config

### Current Global MCP Servers (keep these):
```json
"mcpServers": {
  "MCP_DOCKER": {
    "type": "stdio",
    "command": "docker.exe",
    "args": ["mcp", "gateway", "run"]
  },
  "Jam": {
    "type": "http",
    "url": "https://mcp.jam.dev/mcp"
  }
}
```

### Move These 3 to Global (from project-specific):
```json
"shadcn": {
  "type": "http",
  "url": "https://www.shadcn.io/api/mcp"
},
"n8n-mcp": {
  "command": "docker",
  "args": [
    "run", "-i", "--rm", "--init",
    "-e", "MCP_MODE=stdio",
    "-e", "LOG_LEVEL=error",
    "-e", "DISABLE_CONSOLE_OUTPUT=true",
    "-e", "N8N_API_URL=http://192.168.1.154:5678",
    "-e", "N8N_API_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIwMWYxMDVhZi1kZTgyLTQ1MGItYTE2MC05MzM4NWEzYmIwOWIiLCJpc3MiOiJuOG4iLCJhdWQiOiJwdWJsaWMtYXBpIiwiaWF0IjoxNzMwNjg3MzYwfQ.hgdr1ODyev-L-bzrwG2hrmVSb-FqxWJ3-BhauRQRfjE",
    "ghcr.io/czlonkowski/n8n-mcp:latest"
  ]
},
"discord": {
  "type": "http",
  "url": "http://127.0.0.1:8099/mcp"
}
```

## Final Global MCP Tool List

### Docker Desktop MCP Toolkit (MCP_DOCKER):
- Jira project management
- Confluence documentation
- Obsidian notes
- GitHub repository management
- Notion integration
- Desktop Commander (file system)
- All other Docker Desktop MCP tools

### Standalone MCP Servers:
- **Jam**: Bug analysis (https://mcp.jam.dev/mcp)
- **shadcn/ui**: UI components (https://www.shadcn.io/api/mcp)
- **n8n-mcp**: Workflow automation (Docker container)
- **Discord**: Server management (http://127.0.0.1:8099/mcp)

## Actions Required:
1. Add shadcn, n8n-mcp, discord to global mcpServers in /home/michael/.claude.json
2. Remove all project-specific mcpServers sections
3. Delete LinkedIn MCP completely
4. Clean up empty project configs

## Result:
ALL MCP tools work in ANY folder/project - homelabarr-ce, homelabarr-p, etc.

## ✅ CONSOLIDATION COMPLETE - Final Global MCP Tool List

### Global MCP Servers (Available Everywhere):

#### Docker Desktop MCP Toolkit (`MCP_DOCKER`):
- **Jira**: Full project management (create, update, transition issues, sprints)
- **Confluence**: Documentation management (create, update, search pages)
- **Obsidian**: Local notes and knowledge management
- **GitHub**: Repository management, PRs, issues, workflows
- **Notion**: Database and page management
- **Desktop Commander**: File system access (if enabled)
- All other Docker Desktop MCP tools

#### Standalone HTTP MCP Servers:
- **Jam**: Bug analysis and debugging (https://mcp.jam.dev/mcp)
- **shadcn/ui**: UI component management (https://www.shadcn.io/api/mcp)
- **Discord**: Server management (http://127.0.0.1:8099/mcp)

#### Workflow Automation:
- **n8n-mcp**: Workflow automation via Docker container (ghcr.io/czlonkowski/n8n-mcp:latest)

### Configuration Location:
- **Global**: `/home/michael/.claude.json` - mcpServers section
- **Project-specific**: Removed from all projects (empty mcpServers: {})
- **LinkedIn MCP**: Completely removed (was causing conflicts)

### Multi-Machine Support:
This configuration is now version-controlled and can be replicated across:
- Windows machines
- Mac laptops
- Virtual machines
- Mac Studio
- Any development environment

Simply copy the mcpServers section from the global configuration to any new machine's `/home/michael/.claude.json` file.