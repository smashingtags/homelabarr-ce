---
title: "HomelabARR-CLI : 2025-09-06 - HomelabARR v2.0 Go Build Process Documentation"
confluence_id: "15269912"
confluence_url: "https://mjashley.atlassian.net/wiki/spaces/DO/pages/15269912"
confluence_space: "DO"
category: "Frontend"
created_date: "2025-09-06"
updated_date: "2025-09-06"
migrated_date: "2025-09-14"
tags: ['frontend', 'september-2025', 'golang']
---

# HomelabARR v2.0 Go Build Process - Critical Reference Documentation

## Executive Summary

This document provides the**definitive build instructions**for the HomelabARR v2.0 server that MUST be used every time we rebuild the system. This documentation was created because we repeatedly encounter build failures when using incomplete build commands that omit required Go handler modules.
### 🚨**CRITICAL**: Always Use Complete Multi-File Build Command

The HomelabARR v2.0 server requires**ALL handler modules**to be compiled together. Using incomplete build commands will result in undefined function errors.
## Complete Build Command (COPY AND PASTE)

### Windows PowerShell/Command Prompt

```
cd "F:\Coding Projects\homelabarr-cli\v2-poc"
go build -o server-with-cache-mover.exe simple-server.go settings-handler.go encryption.go template-processor.go cloudflare-handler.go service-manager.go
```