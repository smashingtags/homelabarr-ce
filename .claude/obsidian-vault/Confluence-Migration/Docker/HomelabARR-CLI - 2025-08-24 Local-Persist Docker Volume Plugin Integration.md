---
title: "HomelabARR-CLI : 2025-08-24 Local-Persist Docker Volume Plugin Integration"
confluence_id: "8945690"
confluence_url: "https://your-instance.atlassian.net/wiki/spaces/DO/pages/8945690"
confluence_space: "DO"
category: "Docker"
created_date: "2025-08-24"
updated_date: "2025-08-24"
migrated_date: "2025-09-14"
tags: ['frontend', 'august-2025', 'docker', 'golang', 'storage']
---

# 2025-08-24 Local-Persist Docker Volume Plugin Integration

## Overview

Successfully fixed and integrated the local-persist Docker volume plugin for HomelabARR v2.0. This plugin enables named Docker volumes with custom mountpoints, critical for the HomelabARR persistent storage pattern.
## Container Details

- **Registry**: ghcr.io/smashingtags/local-persist:claude-code
- **GitHub Repository**: github.com/smashingtags/local-persist
- **Original Author**: MatchbookLab
- **Fork Maintainer**: smashingtags
- **Version**: claude-code (fixed version)
## Problem Statement

The original local-persist container was broken: 1. Missing binary in container 2. Incorrect build process 3. Outdated base image 4. No ARM support
## Solution Implemented

### 1. Fixed Dockerfile

```
FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY . .
RUN go mod init local-persist && \
    go mod tidy && \
    go build -o local-persist

FROM alpine:latest
RUN apk --no-cache add ca-certificates
COPY --from=builder /app/local-persist /usr/local/bin/
ENTRYPOINT ["local-persist"]
```