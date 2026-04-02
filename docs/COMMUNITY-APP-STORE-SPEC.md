# Community App Store — Architecture Spec

## Vision
Like Unraid's Community Applications. Decentralized template repos maintained by community members, aggregated into a browsable, searchable app store in the CE dashboard.

## Unraid's Model (reference)
- 614 template repositories maintained by community members
- 3,439 apps aggregated from those repos
- Central feed (`applicationFeed.json`) indexes everything
- Users browse by category or by repository/author
- App cards show: icon, name, author, description, category badges, install button, download count
- Home page: Recently Added, Spotlight Apps, Top Trending
- Categories: AI (98), Backup, Cloud, Downloaders, Game Servers, Home Automation, Media Apps, Media Servers, Network, Productivity, Security, Tools, etc.

## Our Model

### Repository System
- Community members maintain their own GitHub repos with HomelabARR YAML templates
- Each repo has a `homelabarr-templates.json` manifest:
  ```json
  {
    "name": "John's Templates",
    "author": "johndoe",
    "description": "Media and AI templates",
    "icon": "https://github.com/johndoe.png",
    "templates": [
      {
        "name": "my-app",
        "file": "my-app.yml",
        "category": "ai",
        "description": "...",
        "icon": "...",
        "tags": ["ai", "llm"]
      }
    ]
  }
  ```
- Official templates repo (`smashingtags/homelabarr-templates`) is one of many repos

### Central Feed
- We maintain a feed file (like Unraid's `applicationFeed.json`) that indexes all registered repos
- Feed is hosted on GitHub, fetched/cached by CE backend
- Repos register by submitting a PR to add their repo URL to a registry file
- Feed is rebuilt periodically (GitHub Action) by scanning all registered repos

### Unraid Feed Ingestion
- Import Unraid's 3,439 apps as a compatibility layer
- Auto-generate HomelabARR YAML from Unraid XML templates
- Translation: Unraid `[IP]:[PORT:xxx]` → our `${DOMAIN}`, `/mnt/user/appdata/` → `${APPFOLDER}/`
- Filter out Unraid plugins (not Docker containers)
- Mark as "Unraid Community" source

### Backend
- `GET /community/apps` — returns aggregated feed (cached)
- `GET /community/repos` — returns repository list
- `POST /community/install/:appId` — generates YAML from feed data and deploys
- Feed cache refreshed daily or on-demand
- Translation layer converts Unraid config format → Docker Compose YAML on the fly

### Frontend
- Community Store tab (separate from the bundled catalog)
- Browse by category (left sidebar like Unraid)
- Browse by repository/author
- Search across all apps (name, description, tags, author)
- Sort: name, date added, downloads, trending
- App card: icon, name, author, description, category badges, source badge (Official/Community/Unraid), Install button
- Home sections: Recently Added, Trending, Spotlight
- Pagination

### App Card Design
- Large icon (from feed `Icon` URL or fallback)
- App name
- Author/repo name
- 2-line description
- Category badges (colored)
- Source badge: Official (blue), Community (green), Unraid (orange)
- GPU badge (if applicable)
- Install button → same deploy modal

## Data Sources

### Unraid Feed (already downloaded)
- `/tmp/applicationFeed.json` — 23MB, 3,439 apps
- Fields: Name, Repository (Docker image), Config (ports/volumes/envs), Overview, Icon, CategoryList, WebUI, Project, Support
- Categories: AI, Backup, Cloud, Crypto, Downloaders, Drivers, Game Servers, Home Automation, Language, Media Apps, Media Servers, Network, Other, Plugins, Productivity, Security, Tools

### Translation Rules (Unraid → HomelabARR)
- `Repository` → `image` in compose
- `Config[Type=Port]` → `ports` mapping
- `Config[Type=Path]` → `volumes`, rewrite `/mnt/user/appdata/` to `${APPFOLDER}/`
- `Config[Type=Variable]` → `environment` vars
- `Network=bridge` → our default
- `Network=host` → `network_mode: host`
- `Privileged=true` → `privileged: true`
- `WebUI` → extract port for Traefik label generation
- Skip entries with no `Repository` (plugins, not containers)

## Phases

### Phase 1 (current PR #109): Foundation
- community-apps.json index for our 116 official templates
- Official/Community badges, author display, tag search
- Community tab

### Phase 2: Unraid Feed Ingestion
- Backend fetches and caches Unraid feed
- Translation layer generates Docker Compose on the fly
- Community Store view with 3,000+ apps
- Category sidebar, search, sort, pagination

### Phase 3: Decentralized Repos
- Repository registration system
- Per-author template repos
- Feed aggregation from multiple repos
- Repository browser view

### Phase 4: Social Features
- Install counts
- Trending/popularity
- User reviews
- Spotlight/featured apps
