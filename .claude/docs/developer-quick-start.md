# HomelabARR CLI Developer Quick Start

## 🚀 New Developer? Start Here!

This quick start guide gets you up and running with the HomelabARR CLI project's agent-based development workflow.

### 📋 Essential Commands

```bash
# Use the auto-router for most tasks (recommended for new developers)
/auto-route "your task description here"

# Call specific agents directly when you know exactly what you need
[agent-name] "specific task for this agent"
```

### 🎯 Quick Agent Reference

| I need to... | Use this agent | Example |
|--------------|----------------|---------|
| **Add new Docker service** | `docker-infrastructure-specialist` | "Add Jellyfin container with health checks" |
| **Configure Traefik routing** | `network-architecture-specialist` | "Set up SSL routing for new service" |
| **Set up authentication** | `security-authentication-specialist` | "Add Authelia protection to admin panel" |
| **Fix media server issues** | `media-stack-specialist` | "Debug Plex transcoding problems" |
| **Create monitoring dashboards** | `monitoring-alerting-specialist` | "Add Grafana dashboard for new service" |
| **Set up backups** | `backup-disaster-recovery-specialist` | "Configure automated backups" |
| **Test something** | `test-automator` | "Validate all services are working" |
| **Debug problems** | `debugger` | "Find why service keeps crashing" |
| **Deploy to production** | `deployment-engineer` | "Deploy changes safely" |
| **Update documentation** | `documentation-specialist` | "Document new feature" |
| **Manage project tasks** | `project-manager` | "Plan next sprint" |
| **Review code** | `code-reviewer` | "Check my configurations" |

### 🔄 Standard Development Workflow

```
1. 📝 Plan (project-manager)
   ↓
2. 🛠️ Implement (domain specialist)  
   ↓
3. 🔒 Secure (security-authentication-specialist)
   ↓
4. 🧪 Test (test-automator)
   ↓
5. 📚 Document (documentation-specialist)
   ↓
6. ✅ Review (code-reviewer)
```

### 💡 Pro Tips for New Developers

#### 1. **Start with Auto-Router**
When unsure which agent to use:
```bash
/auto-route "I want to add a new media server with proper security and monitoring"
# The router will coordinate multiple agents automatically
```

#### 2. **Use Descriptive Task Descriptions**
Good: `"Add Radarr container with Traefik routing, Authelia protection, and resource limits"`
Bad: `"Add Radarr"`

#### 3. **Follow the Validation Pipeline**
All agents automatically run validation:
- ✅ YAML syntax checking
- ✅ JSON validation  
- ✅ Docker configuration verification
- ✅ Security policy compliance

#### 4. **Document as You Go**
Always include `documentation-specialist` for significant changes:
```bash
# After implementing something new
documentation-specialist "Document the new Jellyfin setup process with screenshots and troubleshooting"
```

### 🆘 Common Scenarios

#### Adding a New Service
```bash
# Let auto-router handle the complexity
/auto-route "Add Sonarr container with Traefik SSL routing and Authelia protection"

# Or step by step:
# 1. Container setup
docker-infrastructure-specialist "Create Sonarr Docker Compose with health checks"

# 2. Network routing  
network-architecture-specialist "Configure Traefik routing for sonarr.domain.com"

# 3. Security
security-authentication-specialist "Add Authelia protection to Sonarr"

# 4. Test
test-automator "Validate Sonarr is accessible and functional"
```

#### Fixing a Problem
```bash
# Start with debugger for complex issues
debugger "Plex keeps crashing during transcoding, need root cause analysis"

# Or auto-route for simpler issues
/auto-route "Fix Radarr not downloading movies"
```

#### Project Planning
```bash
# Plan new features or improvements
project-manager "Plan Q4 infrastructure improvements with monitoring and backup focus"
```

### 📁 Important File Locations

```
.claude/
├── agents/              # Individual agent documentation
├── commands/            # Auto-router and command reference
├── docs/               # Developer guides (THIS FILE)
├── local-notes/        # Implementation tracking
└── workflow/           # Process documentation

apps/                   # All application Docker Compose files
├── monitoring/         # Monitoring stack configurations
├── mediaserver/        # Media server configurations  
├── downloadclients/    # Download client configurations
└── ...

wiki/                   # MkDocs documentation site
```

### 🔧 Local Development Setup

1. **Clone the repository**
2. **Read CLAUDE.md** for project context
3. **Check .claude/docs/** for developer guides
4. **Use auto-router** for your first task
5. **Follow the validation pipeline** 

### 📚 Learn More

- **Complete Agent Guide**: `.claude/docs/agent-routing-guide.md`
- **Auto-Router Documentation**: `.claude/commands/auto-route.md`
- **Confluence Documentation**: [Agent Routing Guide](https://mjashley.atlassian.net/wiki/spaces/DO/pages/4587654)
- **Project Board**: [Jira HL Project](https://mjashley.atlassian.net/jira/software/projects/HL/boards/34)

### ❓ Need Help?

1. **Check documentation** in `.claude/docs/`
2. **Ask in Discord**: [discord.gg/Pc7mXX786x](https://discord.gg/Pc7mXX786x)
3. **Create Jira ticket** for bugs/features
4. **Use auto-router** when unsure: `/auto-route "I need help with..."`

---

**Welcome to the HomelabARR CLI development team! 🎉**

*The agent-based workflow ensures high-quality, secure, and well-documented infrastructure changes. When in doubt, use the auto-router - it's designed to help new developers succeed quickly.*
