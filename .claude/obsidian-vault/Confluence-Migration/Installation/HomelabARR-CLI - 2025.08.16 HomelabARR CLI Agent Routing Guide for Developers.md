---
title: "HomelabARR-CLI : 2025.08.16 HomelabARR CLI Agent Routing Guide for Developers"
confluence_id: "4587654"
confluence_url: "https://your-instance.atlassian.net/wiki/spaces/DO/pages/4587654"
confluence_space: "DO"
category: "Installation"
created_date: ""
updated_date: ""
migrated_date: "2025-09-14"
tags: ['frontend', 'epic', 'media-server', 'docker', 'traefik', 'servarr', 'security', 'authelia', 'monitoring']
---

# HomelabARR CLI Agent Routing Guide for Developers

## 📋 Overview

This comprehensive guide explains how to use the auto-router and when to call each specialized agent for HomelabARR CLI development. Each agent is optimized for specific types of tasks and has deep expertise in their domain, ensuring efficient and high-quality implementation of features and fixes.
## 🚀 Auto-Router Usage

### Basic Command Syntax

```
`/auto-route [detailed task description]
`
```
[[HL-123]]
`
```

### How the Auto-Router Works

The auto-router is an intelligent system that: 1.**Analyzes your task description**using keyword recognition and context understanding 2.**Routes to the most appropriate specialist agent(s)**based on domain expertise 3.**🆕 Routes estimation requests to domain experts**for accurate story point estimates 4.**Runs comprehensive validation**on any changed files (YAML, JSON, Shell scripts) 5.**Reports validation results**before and after implementation 6.**Coordinates multiple agents**for complex multi-domain tasks 7.**Executes the task**through the specialist agent with full context
## 🎯 Enhanced Story Point Estimation

### 🆕 Domain Expert Estimation

**NEW FEATURE**: Story points are now estimated by domain specialists who understand the actual technical complexity, not project managers guessing effort.
#### How It Works

```
`1. project-manager → Creates story structure with acceptance criteria
2. auto-router → Analyzes technical domain from story content  
3. [domain-specialist] → Provides technical estimation with reasoning
4. project-manager → Updates story with expert estimate and adds to backlog
`
```

#### Domain Routing for Estimation
**Keywords****Domain Specialist****Estimation Expertise**docker, container, composedocker-infrastructure-specialistContainer complexity, resource managementtraefik, routing, SSL, networknetwork-architecture-specialistNetwork complexity, SSL challengesauthelia, security, auth, MFAsecurity-authentication-specialistSecurity implementation complexityplex, jellyfin, sonarr, radarrmedia-stack-specialistMedia server complexity, integration effortgrafana, monitoring, alertsmonitoring-alerting-specialistMonitoring setup complexitybackup, restore, recoverybackup-disaster-recovery-specialistBackup implementation effort