---
title: "HomelabARR-CLI : 2025-09-04 - HomelabARR v2.0 Active File Architecture & Build Process"
confluence_id: "13369397"
confluence_url: "https://your-instance.atlassian.net/wiki/spaces/DO/pages/13369397"
confluence_space: "DO"
category: "Frontend"
created_date: "2025-09-04"
updated_date: "2025-09-04"
migrated_date: "2025-09-14"
tags: ['frontend', 'september-2025', 'golang']
---

# HomelabARR v2.0 Active File Architecture & Build Process

## Overview

This document defines the CURRENT working architecture of HomelabARR v2.0, which files are actively used, and the proper build process.**Update this document at the end of every development session.**
## Current Working Stack (2025-09-04)

### ✅ ACTIVE BACKEND FILES

These are the Go files that work together to create the complete API server:
#### Primary Server File

- **`simple-server.go`**(159KB) - Main API server with all endpoints
- Contains cache mover implementation
- Imports functions from other modules
- Contains main() function that starts HTTP server on port 8080
#### Required Dependencies

- **`settings-handler.go`**- Real settings management with file I/O and encryption
- **`cloudflare-handler.go`**- Cloudflare API validation and DNS management
- **`encryption.go`**- Encryption/decryption for sensitive settings
- **`service-manager.go`**- Service lifecycle management
- **`template-processor.go`**- YAML template processing
#### Build Command That Works

```
go build -o server-with-cache-mover.exe \
  simple-server.go \
  settings-handler.go \
  cloudflare-handler.go \
  encryption.go \
  service-manager.go \
  template-processor.go
```