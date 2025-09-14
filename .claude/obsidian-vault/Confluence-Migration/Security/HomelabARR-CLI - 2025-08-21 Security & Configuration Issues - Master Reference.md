---
title: "HomelabARR-CLI : 2025-08-21 Security & Configuration Issues - Master Reference"
confluence_id: "7995420"
confluence_url: "https://your-instance.atlassian.net/wiki/spaces/DO/pages/7995420"
confluence_space: "DO"
category: "Security"
created_date: "2025-08-21"
updated_date: "2025-08-21"
migrated_date: "2025-09-14"
tags: ['august-2025', 'security']
---

# 2025-08-21 Security & Configuration Issues - Master Reference

## Table of Contents

{toc:minLevel=2|maxLevel=3}
## 2025-08-21 - Discord Token Security Breach

### Critical Security Issue

Discord bot token exposed in .vscode/mcp.json and committed to git history.
### Immediate Actions Taken

- Removed hardcoded token from repository
- Updated to use environment variable ${DISCORD_TOKEN}
- Created .env.example for documentation
- Force pushed clean history
### Lessons Learned

- Always use environment variables for sensitive data
- Review all configuration files before committing
- Add security checks to CI/CD pipeline
- Implement pre-commit hooks for secret scanning