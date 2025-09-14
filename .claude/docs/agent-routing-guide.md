# HomelabARR CLI Agent Routing Guide

## 📋 Overview

This guide explains how to use the auto-router and when to call each specialized agent for HomelabARR CLI development. Each agent is optimized for specific types of tasks and has deep expertise in their domain.

## 🚀 Auto-Router Usage

### Basic Command
```bash
/auto-route [task description]
```

### How It Works
The auto-router analyzes your task description and automatically:
1. **Routes to the most appropriate specialist agent**
2. **Runs validation** on any changed files (YAML, JSON, Shell scripts)
3. **Reports validation results** before implementation
4. **Executes the task** through the specialist agent

### Example Usage
```bash
# Instead of manually choosing an agent, just describe your task:
/auto-route "Add Jellyfin media server with Traefik routing and Authelia protection"

# The router will automatically detect this needs:
# 1. docker-infrastructure-specialist (for Docker Compose setup)
# 2. network-architecture-specialist (for Traefik routing)
# 3. security-authentication-specialist (for Authelia integration)
# 4. media-stack-specialist (for media server configuration)
```

## 🤖 Specialized Agents Reference

### 1. **docker-infrastructure-specialist**
**Expert in**: Docker containerization, Docker Compose orchestration, container optimization

**When to use:**
- Adding new Docker Compose services
- Container resource optimization
- Multi-container environment troubleshooting
- Health check configuration
- Volume and network management

**Real-world examples:**
```bash
# Adding a new application
"Add Radarr container with proper resource limits and health checks"

# Container optimization
"Optimize memory usage for Plex container, it's using too much RAM"

# Troubleshooting
"Sonarr container keeps restarting, need to diagnose the issue"

# Infrastructure scaling
"Configure resource limits for the entire media stack to prevent system overload"
```

**Typical tasks:**
- Docker Compose file creation/modification
- Container networking configuration
- Resource limit optimization
- Health monitoring setup
- Volume mount troubleshooting

---

### 2. **network-architecture-specialist**
**Expert in**: Traefik v3.5.0 routing, DNS management, load balancing, VPN integration

**When to use:**
- Traefik routing configuration
- SSL certificate management
- Load balancing setup
- Network security policies
- DNS configuration with Cloudflare

**Real-world examples:**
```bash
# New service routing
"Configure Traefik routing for new Grafana instance with SSL and custom subdomain"

# SSL issues
"Fix SSL certificate renewal issues for jellyfin.domain.com"

# Load balancing
"Set up load balancing between two Plex instances for redundancy"

# Network troubleshooting
"Debug why Authelia can't reach backend services through Traefik"
```

**Typical tasks:**
- Traefik route configuration
- SSL certificate automation
- Middleware configuration
- Network policy creation
- DNS record management

---

### 3. **security-authentication-specialist**
**Expert in**: Authelia MFA, SSL certificates, security hardening, access control

**When to use:**
- Authentication system configuration
- Security policy implementation
- Access control setup
- SSL/TLS configuration
- Security audit and hardening

**Real-world examples:**
```bash
# MFA setup
"Configure Authelia 2FA for all admin interfaces using TOTP"

# Access control
"Create user groups in Authelia: admin, media-user, and readonly"

# Security hardening
"Audit and harden security for all exposed services"

# SSL management
"Configure automatic SSL certificate generation for new domains"
```

**Typical tasks:**
- Authelia configuration
- User/group management
- Security policy creation
- Certificate management
- Security audit reports

---

### 4. **media-stack-specialist**
**Expert in**: Plex/Jellyfin/Emby, Servarr stack (Sonarr, Radarr, Lidarr, Bazarr), download clients

**When to use:**
- Media server configuration
- Servarr stack setup
- Download client integration
- Quality profile configuration
- Media workflow automation

**Real-world examples:**
```bash
# Media server setup
"Configure Jellyfin with hardware transcoding and library optimization"

# Servarr integration
"Set up complete *arr stack with Sonarr, Radarr, Lidarr and configure quality profiles"

# Download automation
"Integrate qBittorrent with Sonarr for automatic episode downloads"

# Troubleshooting
"Fix Radarr not importing downloaded movies, logs show permission errors"
```

**Typical tasks:**
- Media server optimization
- Servarr stack configuration
- Download client setup
- Quality profile management
- Media workflow troubleshooting

---

### 5. **monitoring-alerting-specialist**
**Expert in**: Netdata, Uptime Kuma, Grafana dashboards, Prometheus metrics, automated alerting

**When to use:**
- Monitoring system setup
- Dashboard creation
- Alert configuration
- Performance monitoring
- Health check automation

**Real-world examples:**
```bash
# Monitoring setup
"Set up comprehensive monitoring for the entire HomelabARR stack with Grafana and Prometheus"

# Custom dashboards
"Create Grafana dashboard for Plex performance monitoring with user sessions and transcoding"

# Alerting
"Configure alerts for when any service goes down or uses too much memory"

# Performance monitoring
"Monitor download speeds and disk usage across all services"
```

**Typical tasks:**
- Monitoring stack deployment
- Custom dashboard creation
- Alert rule configuration
- Performance metric collection
- Health check automation

---

### 6. **backup-disaster-recovery-specialist**
**Expert in**: Automated backup solutions, Duplicati/Restic, configuration backup, disaster recovery

**When to use:**
- Backup strategy planning
- Automated backup setup
- Disaster recovery planning
- Data protection implementation
- Backup validation and testing

**Real-world examples:**
```bash
# Backup setup
"Configure automated daily backups for all application configurations and databases"

# Media backup
"Set up incremental backup for 50TB media library using Restic to cloud storage"

# Disaster recovery
"Create disaster recovery plan for complete infrastructure rebuild"

# Configuration backup
"Automate backup of all Docker Compose files and Traefik configurations"
```

**Typical tasks:**
- Backup solution deployment
- Backup scheduling automation
- Disaster recovery planning
- Data restoration procedures
- Backup monitoring and validation

---

### 7. **test-automator**
**Expert in**: Infrastructure testing, Docker container testing, end-to-end validation

**When to use:**
- Automated testing setup
- Container health validation
- Integration testing
- Performance testing
- CI/CD pipeline testing

**Real-world examples:**
```bash
# Test automation
"Create automated tests to validate all services are accessible through Traefik"

# Health testing
"Set up automated health checks for all media services with notification on failure"

# Integration testing
"Test complete workflow from download to media server integration"

# Performance testing
"Create load tests for Plex server to determine maximum concurrent streams"
```

**Typical tasks:**
- Test suite creation
- Automated validation scripts
- Performance benchmarking
- Integration test setup
- CI/CD pipeline configuration

---

### 8. **debugger**
**Expert in**: Systematic troubleshooting, root cause analysis, log analysis, network diagnostics

**When to use:**
- Complex problem diagnosis
- Service failure investigation
- Performance issue analysis
- Network connectivity problems
- Log analysis and correlation

**Real-world examples:**
```bash
# Service failures
"Plex keeps crashing after Docker updates, need systematic diagnosis"

# Network issues
"Can't access Sonarr through Traefik, getting 502 errors intermittently"

# Performance problems
"System becomes unresponsive during peak usage, need root cause analysis"

# Configuration issues
"After Authelia update, some services work but others get authentication errors"
```

**Typical tasks:**
- Systematic problem diagnosis
- Log file analysis
- Network troubleshooting
- Performance bottleneck identification
- Root cause analysis reports

---

### 9. **deployment-engineer**
**Expert in**: Deployment automation, CI/CD pipelines, production deployment strategies

**When to use:**
- Production deployment planning
- CI/CD pipeline setup
- Deployment automation
- Infrastructure as code
- Release management

**Real-world examples:**
```bash
# Deployment automation
"Create automated deployment pipeline for new HomelabARR services"

# Production deployment
"Plan and execute zero-downtime deployment of monitoring stack update"

# CI/CD setup
"Set up GitHub Actions for automated testing and deployment"

# Infrastructure as code
"Convert all manual configurations to automated deployment scripts"
```

**Typical tasks:**
- Deployment pipeline creation
- Automation script development
- Production deployment execution
- Release planning and management
- Infrastructure automation

---

### 10. **documentation-specialist**
**Expert in**: Technical documentation, Confluence management, API documentation, developer guides

**When to use:**
- Documentation creation/updates
- Confluence page management
- API documentation generation
- Technical writing and organization
- Cross-platform documentation linking

**Real-world examples:**
```bash
# Documentation updates
"Update all Confluence pages with new Dozzle monitoring integration details"

# Technical documentation
"Create comprehensive API documentation for container management endpoints"

# Knowledge organization
"Reorganize documentation structure for better developer onboarding"

# Cross-platform linking
"Create comprehensive cross-references between Jira tickets and Confluence docs"
```

**Typical tasks:**
- Confluence page creation and updates
- Technical documentation writing
- API documentation generation
- Documentation workflow automation
- Cross-reference management

---

### 11. **project-manager**
**Expert in**: User stories, backlog management, sprint planning, story point estimation, technical prioritization

**When to use:**
- Project planning and management
- User story creation with acceptance criteria
- Sprint organization and capacity planning
- Story point estimation and prioritization
- Technical dependency management

**Real-world examples:**
```bash
# Sprint planning
"Plan next sprint considering Traefik upgrade dependencies and team capacity"

# Story creation
"Create user stories for new backup automation feature with proper story points"

# Backlog management
"Reorganize backlog with technical dependencies and business value prioritization"

# Project tracking
"Update project status and create reports for infrastructure improvements"
```

**Typical tasks:**
- User story creation and refinement
- Sprint planning and execution
- Story point estimation (1 SP = 8 hours)
- Backlog organization and prioritization
- Technical dependency management

---

### 12. **scrum-master**
**Expert in**: Sprint management, team coordination, process improvement, blocker resolution

**When to use:**
- Sprint execution and monitoring
- Team coordination and communication
- Process improvement initiatives
- Blocker identification and resolution
- Agile methodology implementation

**Real-world examples:**
```bash
# Sprint management
"Review current sprint progress and update the board with blockers"

# Team coordination
"Several tickets are stuck in review, need to identify and resolve blockers"

# Process improvement
"Analyze team velocity and suggest workflow improvements"

# Documentation updates
"Update sprint documentation and retrospective outcomes"
```

**Typical tasks:**
- Sprint progress monitoring
- Team coordination and communication
- Blocker identification and resolution
- Process improvement implementation
- Agile ceremony facilitation

---

### 13. **code-reviewer**
**Expert in**: Code quality review, security analysis, best practices enforcement

**When to use:**
- Code review before merging
- Security audit of configurations
- Best practices validation
- Quality assurance
- Standards compliance checking

**Real-world examples:**
```bash
# Code review
"Review new Docker Compose configurations for security and best practices"

# Security audit
"Audit all Traefik configurations for security vulnerabilities"

# Standards compliance
"Review shell scripts for coding standards and error handling"

# Quality assurance
"Review monitoring dashboard configurations for performance and accuracy"
```

**Typical tasks:**
- Code quality reviews
- Security audits
- Best practices enforcement
- Configuration validation
- Standards compliance checking

## 🔄 Workflow Integration

### Complete Development Workflow
```
1. Local Notes → 2. Code Changes → 3. Confluence Docs → 4. Jira Updates → 5. GitHub Branch → 6. [MERGE] → 7. Close Jira
```

### Agent Workflow Examples

#### Example 1: Adding New Media Server
```bash
# Step 1: Plan with jira-project-manager
"Create epic and stories for Jellyfin implementation with resource planning"

# Step 2: Implementation with docker-infrastructure-specialist
"Create Jellyfin Docker Compose with optimized settings and health checks"

# Step 3: Security with security-authentication-specialist  
"Configure Authelia protection for Jellyfin with appropriate user groups"

# Step 4: Network with network-architecture-specialist
"Set up Traefik routing for jellyfin.domain.com with SSL automation"

# Step 5: Testing with test-automator
"Create automated tests to validate Jellyfin accessibility and functionality"

# Step 6: Documentation with confluence-manager
"Document complete Jellyfin setup process and configuration details"

# Step 7: Review with code-reviewer
"Review all configurations for security, performance, and best practices"
```

#### Example 2: Infrastructure Problem Resolution
```bash
# Step 1: Diagnosis with debugger
"Investigate why multiple services are failing after system update"

# Step 2: Fix with appropriate specialist (determined by debugger)
"Apply Docker infrastructure fixes identified during diagnosis"

# Step 3: Validation with test-automator
"Run comprehensive tests to ensure all services are functioning properly"

# Step 4: Monitoring with monitoring-alerting-specialist
"Implement additional monitoring to prevent similar issues"

# Step 5: Documentation with confluence-manager
"Document incident, root cause, and prevention measures"
```

## 🎯 Best Practices

### When to Use Auto-Router
- **Complex multi-domain tasks**: Let router coordinate multiple specialists
- **Unclear task scope**: Router will analyze and route appropriately
- **New developers**: Reduces need to know which agent to call
- **Validation needed**: Automatic validation pipeline execution

### When to Call Agents Directly
- **Single-domain expertise needed**: You know exactly which specialist you need
- **Follow-up tasks**: Continuing work with same agent
- **Specialized requirements**: Need specific agent's deep expertise
- **Time-sensitive**: Skip routing analysis for urgent tasks

### Agent Coordination Tips
1. **Start with planning agents** (project-manager) for complex projects
2. **Use infrastructure agents first** (docker-infrastructure-specialist, network-architecture-specialist)
3. **Add security early** (security-authentication-specialist)
4. **Test thoroughly** (test-automator)
5. **Document everything** (documentation-specialist)
6. **Review before deployment** (code-reviewer)

## 🔧 Validation Pipeline

### Automatic Validation (via auto-router)
1. **File Detection**: Scans for changed files
2. **YAML Validation**: `docker-compose config --quiet`
3. **JSON Validation**: Python JSON syntax checking
4. **Shell Script Validation**: Bash syntax checking
5. **Prettier Formatting**: Code formatting validation

### Manual Validation Commands
```bash
# Docker Compose validation
docker-compose -f app.yml config --quiet

# JSON validation
python -c "import json; json.load(open('dashboard.json'))"

# YAML syntax check
python -c "import yaml; yaml.safe_load(open('config.yml'))"

# Shell script validation
bash -n script.sh
```

## 📚 Quick Reference

### Agent Selection Flowchart
```
Task Type → Recommended Agent
─────────────────────────────
Docker/Containers → docker-infrastructure-specialist
Traefik/Networking → network-architecture-specialist
Security/Auth → security-authentication-specialist
Media Services → media-stack-specialist
Monitoring → monitoring-alerting-specialist
Backups → backup-disaster-recovery-specialist
Testing → test-automator
Debugging → debugger
Deployment → deployment-engineer
Documentation → documentation-specialist
Project Management → project-manager
Sprint Management → scrum-master
Code Review → code-reviewer
```

### Common Task Patterns
| Task | Primary Agent | Secondary Agent | Validation Agent |
|------|---------------|-----------------|------------------|
| New Service | docker-infrastructure-specialist | network-architecture-specialist | test-automator |
| Security Update | security-authentication-specialist | code-reviewer | test-automator |
| Performance Issue | debugger | monitoring-alerting-specialist | test-automator |
| Feature Development | project-manager | [domain-specific] | code-reviewer |
| Production Deployment | deployment-engineer | test-automator | monitoring-alerting-specialist |

---

*This guide provides comprehensive coverage of agent usage for HomelabARR CLI development. For specific implementation examples, see individual agent documentation in `.claude/agents/` directory.*
