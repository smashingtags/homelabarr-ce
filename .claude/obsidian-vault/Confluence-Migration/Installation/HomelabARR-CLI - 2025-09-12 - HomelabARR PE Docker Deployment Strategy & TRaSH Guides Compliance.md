---
title: "HomelabARR-CLI : 2025-09-12 - HomelabARR PE Docker Deployment Strategy & TRaSH Guides Compliance"
confluence_id: "18219010"
confluence_url: "https://your-instance.atlassian.net/wiki/spaces/DO/pages/18219010"
confluence_space: "DO"
category: "Installation"
created_date: "2025-09-12"
updated_date: "2025-09-12"
migrated_date: "2025-09-14"
tags: ['frontend', 'september-2025', 'storage', 'docker']
---

# HomelabARR PE Docker Deployment Strategy

## Executive Summary

HomelabARR PE operates as a**dual-layer platform**: -**Layer 1**: NAS Operating System (SnapRAID, MergerFS, Cache Mover) -**Layer 2**: Container Orchestration (deploys user apps via Docker)
## Current Docker Configuration

### docker-compose.yml (WORKING)

```
# HomelabARR PE - Development/Testing Deployment
# NO VERSION TAG - Following current Docker Compose Specification

services:
  homelabarr-server:
    build: .
    container_name: homelabarr-server
    restart: unless-stopped
    ports:
      - "8080:8080"  # API server
    volumes:
      - ./config:/opt/homelabarr/config
      - ./templates:/opt/homelabarr/templates
      - /data:/data  # TRaSH Guides compliant
      - /var/run/docker.sock:/var/run/docker.sock
      - /mnt:/mnt
    environment:
      - NODE_ENV=production
      - SERVER_PORT=8080
      - CORS_ORIGIN=http://localhost:5173
      - PUID=1000
      - PGID=1000
    networks:
      - proxy  # CRITICAL: Same network as deployed apps

  homelabarr-frontend:
    image: node:20-alpine
    container_name: homelabarr-frontend
    working_dir: /app
    command: sh -c "npm install && npm run dev -- --host 0.0.0.0 --port 5173"
    restart: unless-stopped
    ports:
      - "5173:5173"  # React dev server
    volumes:
      - ./web/homelabarr-dashboard:/app
      - /app/node_modules
    environment:
      - NODE_ENV=development
      - VITE_API_URL=http://localhost:8080
    networks:
      - proxy  # CRITICAL: Same network as deployed apps

networks:
  proxy:
    external: true
    name: proxy
  # Create with: docker network create proxy
```