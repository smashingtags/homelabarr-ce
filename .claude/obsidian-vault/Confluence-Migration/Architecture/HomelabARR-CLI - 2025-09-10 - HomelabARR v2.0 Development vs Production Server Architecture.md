---
title: "HomelabARR-CLI : 2025-09-10 - HomelabARR v2.0 Development vs Production Server Architecture"
confluence_id: "17399810"
confluence_url: "https://mjashley.atlassian.net/wiki/spaces/DO/pages/17399810"
confluence_space: "DO"
category: "Architecture"
created_date: "2025-09-10"
updated_date: "2025-09-10"
migrated_date: "2025-09-14"
tags: ['frontend', 'september-2025', 'golang']
---

# HomelabARR v2.0 Development vs Production Server Architecture

## 🚨 CRITICAL: Port Confusion Prevention Guide

This document exists because we keep getting confused about which server we're looking at and whether changes are actually integrated.
## The Two Different Workflows

### 1. Development Workflow (Live Editing)

**What runs:**-**Frontend**: Port 5173 (Vite dev server - hot reload, live editing) -**Backend**: Port 8080 (Go API server only)

**Commands to start:**
```
# Terminal 1: Start Go backend
cd "F:\Coding Projects\homelabarr-cli\v2-poc"
./server-with-cache-mover.exe

# Terminal 2: Start React frontend  
cd "F:\Coding Projects\homelabarr-cli\v2-poc\web\homelabarr-dashboard"
npm run dev
```