---
title: "HomelabARR-CLI : 2025.08.20 n8n-MCP Integration"
confluence_id: "7503925"
confluence_url: "https://your-instance.atlassian.net/wiki/spaces/DO/pages/7503925"
confluence_space: "DO"
category: "General"
created_date: ""
updated_date: ""
migrated_date: "2025-09-14"
tags: ['monitoring', 'docker', 'traefik', 'project-management', 'epic']
---

# n8n-MCP Integration

## Overview

n8n-MCP (Model Context Protocol) server provides AI assistants with comprehensive access to n8n workflow automation node documentation and operations. This integration brings n8n-MCP into the HomelabARR ecosystem as a managed container.
## Container Details

- **Name**: homelabarr-n8n-mcp
- **Registry**: ghcr.io/smashingtags/homelabarr-n8n-mcp
- **Source**: Fork of czlonkowski/n8n-mcp
- **Coverage**: 532 n8n nodes with 99% property coverage
## Deployment

### Docker Compose

Deploy using the HomelabARR template at`/opt/homelabarr/apps/addons/n8n-mcp.yml`
### Environment Variables

- MCP_MODE: Operation mode (http/stdio)
- PORT: HTTP server port (default 3000)
- N8N_API_URL: Optional n8n instance URL
- N8N_API_KEY: Optional n8n API key
## Features

- Node documentation retrieval
- Workflow validation
- Incremental workflow updates
- AI assistant integration
- 263 AI-capable nodes
## Access

- Direct:[http://localhost:3333](http://localhost:3333)
- Traefik:[https://n8n-mcp.yourdomain.com](https://n8n-mcp.yourdomain.com)
## Health Monitoring[[Jira Ticket HL-151]]
- [GitHub Fork](https://github.com/smashingtags/n8n-mcp)