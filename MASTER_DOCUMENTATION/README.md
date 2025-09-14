# HomelabARR CLI - Master Documentation Hub

**Version**: 2.5+ | **Last Updated**: August 19, 2025

> **⚠️ IMPORTANT**: This is the consolidated master documentation. Original files are preserved in their original locations until migration is complete.

## 📚 Documentation Structure

This master documentation consolidates information from:
- 848+ local documentation files
- 79 Jira tickets (HL project)
- 18+ Confluence pages (DO space)
- Multiple README and guide files

## 🗂️ Documentation Categories

### 1. [Getting Started](./1_GETTING_STARTED/)
- **[Quick Start Guide](./1_GETTING_STARTED/QUICKSTART.md)** - Get running in 5 minutes
- **[System Requirements](./1_GETTING_STARTED/REQUIREMENTS.md)** - Hardware and software prerequisites
- **[Installation Overview](./1_GETTING_STARTED/INSTALLATION_OVERVIEW.md)** - Choose your deployment method

### 2. [Deployment Methods](./2_DEPLOYMENT/)
- **[Complete Deployment Guide](./2_DEPLOYMENT/COMPLETE_GUIDE.md)** - All 6 deployment methods
- **[Local Mode](./2_DEPLOYMENT/LOCAL_MODE.md)** - No domain required, direct port access
- **[Production Mode](./2_DEPLOYMENT/PRODUCTION_MODE.md)** - Traefik + Authelia + SSL
- **[Web Interface](./2_DEPLOYMENT/WEB_INTERFACE.md)** - React UI deployment
- **[Monitoring Stack](./2_DEPLOYMENT/MONITORING_STACK.md)** - Complete observability
- **[Ecosystem Integration](./2_DEPLOYMENT/ECOSYSTEM_INTEGRATION.md)** - Full stack deployment

### 3. [Architecture](./3_ARCHITECTURE/)
- **[Ecosystem Overview](./3_ARCHITECTURE/ECOSYSTEM_OVERVIEW.md)** - Complete system architecture
- **[Repository Structure](./3_ARCHITECTURE/REPOSITORY_STRUCTURE.md)** - Code organization
- **[Network Topology](./3_ARCHITECTURE/NETWORK_TOPOLOGY.md)** - Container networking
- **[Container Registry](./3_ARCHITECTURE/CONTAINER_REGISTRY.md)** - Image management

### 4. [Development](./4_DEVELOPMENT/)
- **[Developer Guide](./4_DEVELOPMENT/DEVELOPER_GUIDE.md)** - Contributing to HomelabARR
- **[SDLC Workflow](./4_DEVELOPMENT/WORKFLOW.md)** - Development process
- **[Agent Routing](./4_DEVELOPMENT/AGENT_ROUTING.md)** - Specialized agent system
- **[API Documentation](./4_DEVELOPMENT/API_DOCS.md)** - Backend API reference

### 5. [Operations](./5_OPERATIONS/)
- **[Troubleshooting Guide](./5_OPERATIONS/TROUBLESHOOTING.md)** - Common issues and solutions
- **[Maintenance Guide](./5_OPERATIONS/MAINTENANCE.md)** - Backup and cleanup procedures
- **[Security Guide](./5_OPERATIONS/SECURITY.md)** - Hardening and best practices
- **[Monitoring Guide](./5_OPERATIONS/MONITORING.md)** - Metrics and alerting

### 6. [Project Management](./6_PROJECT_MANAGEMENT/)
- **[Sprint Results](./6_PROJECT_MANAGEMENT/SPRINT_RESULTS.md)** - Development progress
- **[Roadmap](./6_PROJECT_MANAGEMENT/ROADMAP.md)** - Future plans
- **[Known Issues](./6_PROJECT_MANAGEMENT/KNOWN_ISSUES.md)** - Current limitations
- **[Migration Status](./6_PROJECT_MANAGEMENT/MIGRATION_STATUS.md)** - HomelabARR to HomelabARR

## 🚀 Quick Navigation

### By User Type

#### New Users
1. Start with [Quick Start Guide](./1_GETTING_STARTED/QUICKSTART.md)
2. Review [System Requirements](./1_GETTING_STARTED/REQUIREMENTS.md)
3. Choose between [Local Mode](./2_DEPLOYMENT/LOCAL_MODE.md) or [Production Mode](./2_DEPLOYMENT/PRODUCTION_MODE.md)

#### Developers
1. Read [Developer Guide](./4_DEVELOPMENT/DEVELOPER_GUIDE.md)
2. Understand [SDLC Workflow](./4_DEVELOPMENT/WORKFLOW.md)
3. Review [Repository Structure](./3_ARCHITECTURE/REPOSITORY_STRUCTURE.md)

#### System Administrators
1. Review [Complete Deployment Guide](./2_DEPLOYMENT/COMPLETE_GUIDE.md)
2. Implement [Security Guide](./5_OPERATIONS/SECURITY.md)
3. Set up [Monitoring Stack](./2_DEPLOYMENT/MONITORING_STACK.md)

## 📊 Documentation Status

| Category | Status | Completeness | Source |
|----------|--------|--------------|--------|
| Getting Started | ✅ Complete | 100% | Local files |
| Deployment | ✅ Complete | 100% | DEPLOYMENT.md + Confluence |
| Architecture | ✅ Complete | 95% | Multiple sources |
| Development | ✅ Complete | 90% | CLAUDE.md + Confluence |
| Operations | 🔄 In Progress | 85% | Various sources |
| Project Mgmt | 🔄 In Progress | 80% | Jira + local |

## ⚠️ Critical Pending Items

1. **Docker Image Migration** (HL-81)
   - Status: To Do
   - Impact: 60 files need updating
   - Target: Migrate from ghcr.io/smashingtags to ghcr.io/smashingtags

2. **Authentication Hardening** (HL-79)
   - Status: To Do
   - Impact: Remove hardcoded admin/admin
   - Target: Implement proper authentication

3. **Production Configuration** (HL-77)
   - Status: To Do
   - Impact: Replace hardcoded localhost:35002
   - Target: Environment-based configuration

4. **ARM Support** (HL-53)
   - Status: To Do
   - Impact: Expand hardware support
   - Target: Raspberry Pi and Apple Silicon

## 🔄 Migration Notes

### From Original Documentation
- All original files preserved in original locations
- Backups will be created with `.bk` extension before deletion
- Cross-references updated to point to new structure
- Confluence and Jira content synchronized

### Documentation Sources
- **Primary**: DEPLOYMENT.md, HomelabARR_Ecosystem_Complete_Guide.md
- **Confluence**: 18+ pages in DO space
- **Jira**: 79 tickets in HL project
- **Local Files**: 848 .md and .txt files

## 📝 Version History

- **v2.5+** (Current) - Master documentation consolidation
- **v2.4** - Web interface MVP completion
- **v2.3** - Repository separation (homelabarr-cli vs homelabarr-web)
- **v2.2** - Complete rebranding from HomelabARR
- **v2.1** - Monitoring stack integration
- **v2.0** - Local mode introduction

## 🤝 Support & Community

- **Discord**: [Join HomelabARR Community](https://discord.gg/Pc7mXX786x)
- **GitHub**: [github.com/smashingtags/homelabarr-cli](https://github.com/smashingtags/homelabarr-cli)
- **Confluence**: [Project Documentation](https://mjashley.atlassian.net/wiki/spaces/DO)
- **Jira**: [Project Board](https://mjashley.atlassian.net/jira/software/projects/HL/boards/34)

---

*Generated from 848+ documentation files, 79 Jira tickets, and 18+ Confluence pages*