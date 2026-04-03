# Community App Store

HomelabARR CE includes a community app store with 2,900+ Docker apps originally sourced from the [Unraid Community Applications](https://github.com/Squidly271/AppFeed) catalog, now maintained independently as pre-generated templates.

---

## How It Works

The community store is a JSON index (`community-apps.json`) plus pre-generated Docker Compose YAMLs, all stored in the [templates repo](https://github.com/smashingtags/homelabarr-templates). No database, no external feed — everything is static files served from disk.

### Data Flow

1. The templates repo contains pre-generated YAMLs at `community/<category>/<app>.yml`
2. When you click the **Community** tab, the backend reads the JSON index and serves results
3. When you click **Refresh**, the backend runs `git pull` on the templates directory to fetch the latest catalog
4. When you click **Install**, the backend deploys from the pre-generated YAML — no on-the-fly conversion

### Template Format

All community templates are standard Docker Compose YAMLs with HomelabARR conventions:

| Convention | Example |
|-----------|---------|
| Appdata paths | `/opt/appdata/<app>/` |
| Standard Docker env vars | `PUID`, `PGID`, `TZ` |
| Network modes | `proxy` network or `network_mode: host` |
| Traefik labels | Auto-generated from WebUI port |

You don't need Unraid to use community apps. They're standard Docker containers.

---

## Setup

If you followed the [Quick Start](quick-start.md), the templates repo is already cloned at `/opt/homelabarr/templates`. The community store works out of the box — no database or extra configuration needed.

---

## Updating

### Via the UI (recommended)

1. Click the **Refresh** button in the Community Store (top right, next to sort)
2. The backend runs `git pull` on the templates directory
3. The app list reloads with the latest catalog

Only admins can refresh.

### Manual

```bash
cd /opt/homelabarr/templates
git pull
```

### Contributing New Apps

New community apps are submitted via PR to [smashingtags/homelabarr-templates](https://github.com/smashingtags/homelabarr-templates). Add a YAML to the appropriate `community/<category>/` directory and update the index.

---

## Browsing

Click the **Community** tab in the dashboard to browse. You can:

- **Search** by app name, description, or author (full-text search)
- **Filter** by category (AI, Backup, Downloaders, Media, etc.)
- **Sort** by name, newest, downloads, trending, or stars
- **Page** through results (12 per page)

Each app card shows:

- App icon
- Name and author
- Description
- Category badges
- Download count
- Install button

---

## Installing

Click **Install** on any community app. You'll see the same deploy modal as native apps:

1. Choose a deployment mode (Standard, Traefik, or Traefik + Authelia)
2. Click **Deploy**
3. The app deploys from a pre-generated Docker Compose YAML — no on-the-fly conversion

All 2,900+ community templates are pre-generated and validated against `docker compose config`. Templates are stored at `community/<category>/<app>.yml` in the templates repo.

---

## Template Validation

Every community template was validated with `docker compose config` during generation:

- **2,816** pass validation (99.75%)
- **7** fail due to malformed data (bad ports, volume names with spaces, undefined named volumes)
- **21** skipped (no Docker image)

Failed templates are still included but may not deploy successfully.

---

## Catalog Stats

- **2,900+** Docker apps (blacklisted, deprecated, and plugins filtered out)
- **628** template repositories / authors
- **15** categories
- **563** apps in the Other category (down from 1,355 after cleanup)
- **Full-text search** across names, descriptions, and search terms

---

## Credits

Community app data was originally sourced from the [Unraid Community Applications](https://github.com/Squidly271/AppFeed) project, maintained by [Squidly271](https://github.com/Squidly271) and the Unraid community. The catalog is now maintained independently in the HomelabARR templates repo. Docker images are provided by their respective authors. HomelabARR is not affiliated with or endorsed by Lime Technology (Unraid).
