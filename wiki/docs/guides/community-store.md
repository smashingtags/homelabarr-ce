# Community App Store

HomelabARR CE includes a community app store with 2,900+ Docker apps sourced from the [Unraid Community Applications](https://github.com/Squidly271/AppFeed) catalog.

---

## How It Works

The community store is powered by a local SQLite database. When you click the **Community** tab in the dashboard, you're querying a database of apps, not fetching from the internet. This makes it fast and works offline.

### Data Flow

1. The [unraid-ca-db](https://github.com/smashingtags/homelabarr-templates) import tool downloads the Unraid Community Applications feed
2. It parses 3,400+ apps into a structured SQLite database with full-text search
3. The CE backend reads the database and serves it to the frontend
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

### 1. Import the database

Clone the import tool and run it:

```bash
cd /opt/homelabarr
git clone https://github.com/smashingtags/homelabarr-templates.git templates
cd templates
pip install -r requirements.txt  # if using unraid-ca-db
python3 import.py --stats
```

This creates `data/unraid-ca.db` (~30MB).

### 2. Make the database available to CE

Mount the database into the backend container. Add to your `homelabarr.yml`:

```yaml
backend:
  volumes:
    - /path/to/unraid-ca.db:/app/data/unraid-ca.db:ro
```

Or set the environment variable:

```bash
COMMUNITY_DB_PATH=/app/data/unraid-ca.db
```

### 3. Keep it updated

Set up a daily cron to refresh the data:

```bash
# Add to crontab
0 6 * * * cd /opt/homelabarr/unraid-ca-db && ./refresh.sh
```

---

## Browsing

Click the **Community** tab in the dashboard to browse. You can:

- **Search** by app name, description, or author
- **Filter** by category (AI, Backup, Downloaders, Media, etc.)
- **Sort** by name, newest, downloads, trending, or stars
- **Page** through results (12 per page by default)

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

## Credits

Community app data is provided by the [Unraid Community Applications](https://github.com/Squidly271/AppFeed) project, maintained by [Squidly271](https://github.com/Squidly271) and the Unraid community. Docker images are provided by their respective authors. HomelabARR is not affiliated with or endorsed by Lime Technology (Unraid).
