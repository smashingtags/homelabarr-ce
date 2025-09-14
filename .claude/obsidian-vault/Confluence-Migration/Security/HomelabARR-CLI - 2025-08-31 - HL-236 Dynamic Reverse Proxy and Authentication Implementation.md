---
title: "HomelabARR-CLI : 2025-08-31 - HL-236 Dynamic Reverse Proxy and Authentication Implementation"
confluence_id: "11731306"
confluence_url: "https://your-instance.atlassian.net/wiki/spaces/DO/pages/11731306"
confluence_space: "DO"
category: "Security"
created_date: "2025-01-31"
updated_date: "2025-01-31"
migrated_date: "2025-09-14"
tags: ['frontend', 'august-2025', 'traefik', 'security', 'authelia', 'epic']
---

# HL-236: Dynamic Reverse Proxy and Authentication System

## Overview

Implemented a comprehensive dynamic configuration system for reverse proxy and authentication providers in HomelabARR CLI v2.0, enabling users to configure and manage Traefik, Nginx, SWAG proxies and Authelia, Authentik, Keycloak authentication through the React dashboard.
## Technical Implementation

### 1. Frontend - React Dashboard Integration

**File**:`v2-poc/web/homelabarr-dashboard/src/pages/Settings/Settings.tsx`
#### Network Configuration Form

- 

Proxy type selector (Traefik, Nginx, SWAG, None)
- 

SSL provider options (Cloudflare, Let's Encrypt, Self-Signed, None)
- 

Conditional Cloudflare credential fields
- 

Domain configuration
- 

Authentication provider selection
```
interface NetworkSettings {
  domain?: string;
  proxyType?: string;
  sslProvider?: string;
  cloudflareEnabled?: boolean;
  cloudflareEmail?: string;
  cloudflareAPIKey?: string;
  cloudflareZoneID?: string;
}
```