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

### Central Catalog (Current State)
- The catalog is fully independent — no upstream Unraid feed, no database, no nightly refresh from an external source
- All 2,900+ apps exist as pre-generated Docker Compose YAMLs in the templates repo under `community/<category>/<app>.yml`
- A JSON index (`community-apps.json`) provides metadata for browsing and search
- New apps are submitted via PR to `smashingtags/homelabarr-templates`
- Clicking **Refresh** in the UI runs `git pull` on the templates directory
- The catalog was originally seeded from Unraid Community Applications data, then cleaned up and frozen as static files

### Central Feed (Future)
- We maintain a feed file (like Unraid's `applicationFeed.json`) that indexes all registered repos
- Feed is hosted on GitHub, fetched/cached by CE backend
- Repos register by submitting a PR to add their repo URL to a registry file
- Feed is rebuilt periodically (GitHub Action) by scanning all registered repos

### Backend
- `GET /community/apps` — returns catalog from JSON index (cached in memory)
- `GET /community/repos` — returns repository list
- `POST /community/install/:appId` — deploys from pre-generated YAML
- Refresh endpoint runs `git pull` on templates directory

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

## Phases

### Phase 1 (done): Foundation
- community-apps.json index for our 116 official templates
- Official/Community badges, author display, tag search
- Community tab

### Phase 2 (done): Independent Catalog
- 2,900+ apps as pre-generated Docker Compose YAMLs in the templates repo
- JSON index for browsing and search
- Category sidebar, search, sort, pagination
- No database, no external feed dependency
- New apps added via PRs to the templates repo

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

## Credits & Attribution
The Community App Store was originally seeded with data from the [Unraid Community Applications](https://github.com/Squidly271/AppFeed) project, maintained by [Squidly271](https://github.com/Squidly271) and the Unraid community. We are grateful for their work in curating the largest self-hosted application catalog in the homelab ecosystem. The catalog is now maintained independently in the HomelabARR templates repo. Docker images are provided by their respective authors and maintainers. HomelabARR is not affiliated with or endorsed by Lime Technology (Unraid).
