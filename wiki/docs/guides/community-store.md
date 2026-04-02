# Community App Store

HomelabARR CE includes a community app store with 2,900+ Docker apps sourced from the [Unraid Community Applications](https://github.com/Squidly271/AppFeed) catalog.

---

## How It Works

The community store is powered by a local SQLite database that ships with the [templates repo](https://github.com/smashingtags/homelabarr-templates). When you click the **Community** tab, you're querying a local database — fast and works offline.

### Data Flow

1. A [GitHub Action](https://github.com/smashingtags/homelabarr-templates/actions) refreshes the database daily at 6 AM UTC
2. When you click **Refresh** in the Community Store, the backend runs `git pull` on the templates directory to fetch the latest database
3. The CE backend queries the SQLite database and serves results to the frontend
4. When you click **Install**, the backend auto-generates a Docker Compose file from the app's config and deploys it

### What Gets Translated

Unraid templates use a different format than HomelabARR. The backend handles the translation automatically:

| Unraid Format | HomelabARR Format |
|--------------|-------------------|
| XML template with `[IP]:[PORT:xxx]` | Docker Compose YAML |
| `/mnt/user/appdata/` paths | `/opt/appdata/` paths |
| Unraid-specific env vars | Standard Docker env vars |
| `Network=bridge` / `Network=host` | `proxy` network or `network_mode: host` |

You don't need Unraid to use community apps. They're standard Docker containers.

---

## Setup

If you followed the [Quick Start](quick-start.md), the templates repo (including the community database) is already cloned at `/opt/homelabarr/templates`. The community store works out of the box.

### Database location

The backend looks for the database in these locations (first match wins):

1. `COMMUNITY_DB_PATH` environment variable
2. `data/unraid-ca.db` inside the app directory
3. `server/data/unraid-ca.db` inside the app directory
4. `/app/data/unraid-ca.db` (Docker container default)

If you mounted the templates repo at `/opt/homelabarr/templates`, the database is at `/opt/homelabarr/templates/data/unraid-ca.db`. Make sure this path is accessible to the backend container — either via the existing templates volume mount or a separate mount:

```yaml
backend:
  volumes:
    - /opt/homelabarr/templates/data/unraid-ca.db:/app/data/unraid-ca.db:ro
```

---

## Updating

### Automatic (recommended)

A GitHub Action on the templates repo refreshes the database daily at 6 AM UTC. To get the update:

1. Click the **Refresh** button in the Community Store (top right, next to sort)
2. The backend runs `git pull` on the templates directory
3. The app list reloads with the latest data

Only admins can refresh.

### Manual

If you prefer to update manually:

```bash
cd /opt/homelabarr/templates
git pull
```

The backend picks up the new database automatically.

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
3. The backend generates a Docker Compose file from the app's config and deploys it

The translation handles ports, volumes, environment variables, and network mode automatically.

---

## Database Stats

- **2,900+** Docker apps (blacklisted, deprecated, and plugins filtered out)
- **628** template repositories / authors
- **15** categories
- **25,000+** config entries (ports, volumes, env vars)
- **Full-text search** across names, descriptions, and search terms

---

## Credits

Community app data is provided by the [Unraid Community Applications](https://github.com/Squidly271/AppFeed) project, maintained by [Squidly271](https://github.com/Squidly271) and the Unraid community. Docker images are provided by their respective authors. HomelabARR is not affiliated with or endorsed by Lime Technology (Unraid).
