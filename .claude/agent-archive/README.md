# Agent Archive

This directory contains specialized agents that are temporarily archived to reduce context overhead while maintaining ability to reactivate them when needed.

## Archived Agents

### Low-Frequency Specialists
- **`rebrand-migration-specialist.md`** - One-time use for rebranding projects
- **`mcp-backend-engineer.md`** - Model Context Protocol specialist (infrequent usage)

### Overlapping Functionality (Already Archived)
- **`confluence-manager.md`** - Covered by documentation-specialist
- **`documentation-engineer.md`** - Duplicate of documentation-specialist
- **`jira-project-manager.md`** - Specialized Jira vs general project-manager
- **`product-owner-jira.md`** - Overlaps with project-manager functionality

## Reactivation Process

To reactivate an agent, simply move it back to `.claude/agents/`:

```bash
# Example: Reactivate rebrand specialist for major rebranding work
mv .claude/agent-archive/rebrand-migration-specialist.md .claude/agents/

# Or for MCP development work
mv .claude/agent-archive/mcp-backend-engineer.md .claude/agents/
```

## Active Agent Roster (Post-Cleanup)

### Core Infrastructure (High Usage)
- `docker-infrastructure-specialist` - Primary Docker/container management
- `network-architecture-specialist` - Traefik routing, SSL, networking
- `security-authentication-specialist` - Authelia security, authentication
- `media-stack-specialist` - Plex/Jellyfin/Servarr media automation
- `monitoring-alerting-specialist` - Grafana dashboards, alerting
- `backup-disaster-recovery-specialist` - Data protection strategies

### Development Workflow (Medium-High Usage)
- `test-automator` - Infrastructure testing, validation
- `deployment-engineer` - CI/CD, production deployments
- `debugger` - System troubleshooting, diagnostics
- `project-manager` - Story creation, sprint management
- `technical-researcher` - Technology evaluation, research

### Documentation & Quality (Medium Usage)
- `documentation-specialist` - Technical documentation, APIs
- `code-reviewer` - Configuration review, security audits
- `context-manager` - Large project coordination

### Development Environment (Preserved)
- `statusline-setup` - Claude Code UI customization
- `output-style-setup` - Claude Code styling

### Under Review (Decision Pending)
- `scrum-master` - Team coordination (vs project-manager)
- `jira-project-manager` - Specialized Jira workflow (vs project-manager)

## Context Savings

**Before**: 20+ agents consuming context space
**After**: ~15 active agents (25% reduction)
**Archived**: 6 agents ready for reactivation when needed