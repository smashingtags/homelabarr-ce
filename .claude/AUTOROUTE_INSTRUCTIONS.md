# Autoroute Instructions for HomelabARR CLI

## How to Use /autoroute

When the user calls `/autoroute`, follow these steps:

### 1. Analyze the Task
- Identify the primary domain (Jira, Docker, GitHub, etc.)
- Determine complexity level
- Check if specialized knowledge is needed

### 2. Select the Appropriate Agent

#### Task-to-Agent Mapping:

| Task Type | Agent to Use | MCP Tools Needed |
|-----------|--------------|------------------|
| Jira ticket creation/management | `jira-project-manager` | Jira tools suite |
| Sprint planning | `jira-project-manager` or `scrum-master` | Jira agile tools |
| Documentation writing | `documentation-specialist` | Confluence tools |
| Docker configuration | `docker-infrastructure-specialist` | Docker Hub, curl |
| Traefik/routing issues | `network-architecture-specialist` | curl, Docker tools |
| Container debugging | `debugger` | Docker, curl, logs |
| GitHub PR/branch work | `deployment-engineer` | GitHub tools |
| Code review | `code-reviewer` | GitHub, Git tools |
| Monitoring setup | `monitoring-alerting-specialist` | Grafana tools |
| Security/auth issues | `security-authentication-specialist` | Authelia knowledge |
| MCP tool problems | `mcp-backend-engineer` | MCP internals |
| **UI/Frontend development** | `**frontend-developer**` | **shadcn/ui MCP tools** |
| Complex planning | `context-manager` | All tools |

### 3. Provide Agent with Context

When launching the agent, include:

```
You are working on the HomelabARR CLI project.

Available MCP tools for this task:
- [List relevant tools from MCP_TOOLS_REFERENCE.md]

Key project details:
- Jira Project: HL (your-instance.atlassian.net)
- Confluence Space: DO
- GitHub Repo: homelabarr-cli
- Main branch: main

Known issues with tools:
- [Include relevant issues from MCP_TOOLS_REFERENCE.md]

Task: [User's specific request]

Refer to .claude/MCP_TOOLS_REFERENCE.md for complete tool documentation.
```

### 4. Example Autoroute Scenarios

#### Scenario 1: User asks about Jira ticket
```
/autoroute "Create a Jira ticket for adding health checks"
→ Route to: jira-project-manager
→ Provide: Jira tools, project HL info
```

#### Scenario 2: User has Docker container issue
```
/autoroute "My Plex container won't start"
→ Route to: debugger
→ Provide: Docker tools, curl for testing
```

#### Scenario 3: User needs documentation
```
/autoroute "Document the v2.0 architecture"
→ Route to: documentation-specialist
→ Provide: Confluence tools, diagram generator
```

#### Scenario 4: Frontend UI Development
```
/autoroute "Add shadcn/ui components for settings dashboard"
→ Route to: frontend-developer
→ Provide: shadcn/ui MCP tools, React knowledge
```

#### Scenario 5: Complex multi-domain task
```
/autoroute "Create ticket, implement feature, document it"
→ Route to: context-manager
→ Provide: All tools, coordinate multiple agents
```

### 5. Special Considerations

#### Tool Overlap Prevention
- Don't give agents redundant tools
- Example: If using GitHub Official, don't also provide GitHub Chat

#### Performance Optimization
- Only provide tools the agent actually needs
- Reduces token usage and confusion

#### Error Handling
- If agent reports MCP tool errors, check MCP_TOOLS_REFERENCE.md
- Common fix: Use simple field formats for Jira

### 6. Post-Task Actions

After agent completes task:
1. Verify deliverables
2. Update any tracking (Jira status, etc.)
3. If documentation created, provide links
4. Check if follow-up agents needed

## Quick Agent Reference

### High-Frequency Agents for HomelabARR:
1. **jira-project-manager** - Most SDLC tasks
2. **docker-infrastructure-specialist** - Container configs
3. **deployment-engineer** - GitHub/deployment work
4. **documentation-specialist** - Confluence docs
5. **debugger** - Troubleshooting

### Specialized Agents (Use When Needed):
- **network-architecture-specialist** - Traefik routing
- **security-authentication-specialist** - Authelia setup
- **monitoring-alerting-specialist** - Grafana/Prometheus
- **mcp-backend-engineer** - MCP tool issues
- **context-manager** - Complex multi-step tasks

## MCP Tools Health Check

Before routing, verify these are active:
- ✅ MCP_DOCKER container running
- ✅ Memory server initialized
- ✅ Atlassian credentials set (if using Jira/Confluence)
- ✅ GitHub authentication active

## Reference Documents
- **Tool List**: `.claude/MCP_TOOLS_REFERENCE.md`
- **Project Context**: `CLAUDE.md`
- **SDLC Workflow**: See Development Workflow section in CLAUDE.md

---
*Use this guide when /autoroute is called to efficiently delegate tasks to specialized agents*