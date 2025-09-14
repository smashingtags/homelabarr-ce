---
title: "HomelabARR-CLI : 2025-09-05 - Container Shell Access Implementation"
confluence_id: "15106051"
confluence_url: "https://mjashley.atlassian.net/wiki/spaces/DO/pages/15106051"
confluence_space: "DO"
category: "Docker"
created_date: "2025-09-05"
updated_date: "2025-09-05"
migrated_date: "2025-09-14"
tags: ['frontend', 'media-server', 'docker', 'golang', 'september-2025', 'epic']
---

# Container Shell Access Implementation[[HL-157]]- HomelabARR v2.0 Web GUI Implementation
**Implementation Date**: September 5, 2025
**Status**: ✅**COMPLETED**
## Overview

Successfully implemented web-based container shell access for HomelabARR v2.0, providing terminal functionality directly through the React dashboard. This brings HomelabARR to feature parity with industry standards like Portainer, Yacht, and Docker Desktop.
## Research Findings

### Initial Complexity Assessment vs Reality

**Before Research**: Estimated 3 SP (24 hours) assuming complex xterm.js integration
**After Research**:**Actually 1 SP (8 hours)**using simple WebSocket + shadcn/ui approach
### Industry Implementation Patterns

Research showed that**all major Docker management platforms**use the same simple approach:
- **Portainer**: WebSocket endpoints`/api/websocket/exec`+ basic HTML terminal
- **Azure Container Apps**:`az containerapp exec`with simple console UI
- **Docker Desktop**: "Open in terminal" using WebSocket + textarea/pre elements
- **Yacht**: Similar implementation approach (Container CLI feature)

**Key Insight**: No need for complex terminal libraries - WebSocket + HTML elements work perfectly.
## Technical Implementation

### Backend WebSocket Handler

**Location**:`simple-server.go:1582-1716`
**Endpoint**:`/api/containers/shell/{id}`
```
func containerShellHandler(w http.ResponseWriter, r *http.Request) {
    // WebSocket upgrade using existing upgrader
    conn, err := upgrader.Upgrade(w, r, nil)

    // Interactive docker exec with pipes
    cmd := exec.Command("docker", "exec", "-it", containerID, "/bin/bash")

    // Real-time stdin/stdout/stderr streaming via WebSocket
    // Concurrent goroutines for bidirectional communication
}
```