# Wiki Audit Report — March 27, 2026

Audited every wiki page against the live ce-dev instance and repo source code on staging branch.

## Reality Check (Source of Truth)

- **Actual app categories in `apps/`:** ai, backup, downloads, media-management, media-servers, monitoring, myapps, self-hosted, system, transcoding, virtual-desktops (+ legacy, excluded from count)
- **Actual app count:** 133 YML files (excluding legacy), UI shows 123 (some multi-service YMLs)
- **Actual UI category tabs:** Deployed Apps, Media & Entertainment, Downloads & Automation, Monitoring & Analytics, Virtual Desktops, Backup & Storage, System & Utilities, Self-hosted, AI & Machine Learning, My Apps, All Apps
- **API key auth exists:** `hlr_` prefixed, POST/GET/DELETE at `/auth/api-keys`
- **Screenshots exist:** 8 files in wiki/docs/img/screenshots/ (dark/light for dashboard, deploy-modal-auth, downloads-category, login-modal)
- **homelabarr.yml exists:** valid compose file, uses GHCR images
- **install-remote.sh exists:** valid
- **.env.example exists:** valid

---

## CRITICAL Issues (Wrong/Misleading Information)

### 1. index.md (Home Page)
- ❌ Says "123+ apps across 11 categories" — should be **10 active categories** (legacy doesn't count)
- ❌ Pre-Install section references old Cloudflare setup for CLI method but reads as if required for all methods
- ⚠️ Quick Start box is good but should match quick-start.md exactly

### 2. quick-start.md
- ❌ **"Browse the app catalog (157+ apps)"** — should be 123
- ❌ Method 2 is labeled "Build From Source" but is actually for developers — fine, but `POST /auth/register` endpoint in API docs says "register" while quick-start says nothing about user creation
- ❌ Method 3 (CLI) — `sudo homelabarr-cli -i` command: need to verify this actually works with current install-remote.sh
- ⚠️ Proxmox LXC AppArmor note is useful but untested

### 3. web-dashboard.md
- ❌ Says "100+ self-hosted applications" — should be 123
- ❌ **Category tabs completely wrong.** Lists: Deployed Apps, Media, Downloads, Management, Requests, Monitoring, Self-Hosted, AI Tools, System, All Apps, Leaderboard. Reality: Deployed Apps, Media & Entertainment, Downloads & Automation, Monitoring & Analytics, Virtual Desktops, Backup & Storage, System & Utilities, Self-hosted, AI & Machine Learning, My Apps, All Apps. **No "Leaderboard" exists. No "Requests" tab. No "Management" tab.**
- ❌ Deploy modal documentation says 3 modes: Local/Standard, Traefik, Traefik+Authelia — need to verify ce-dev actually shows these options
- ❌ "Container Management" section references screenshots that may be outdated
- ❌ **No mention of API key auth** (new feature on staging/dev)
- ⚠️ Search description says "100+ apps" — should be 123
- ⚠️ Port Manager description is vague — needs actual UI description

### 4. api-reference.md
- ❌ **Missing API key endpoints entirely:** `POST /auth/api-keys`, `GET /auth/api-keys`, `DELETE /auth/api-keys/:keyId` — these are live on ce-dev
- ❌ GET /applications response example shows old categories (`"mediaserver"`, `"downloadclients"`, `"mediamanager"`) and `"totalApps": 112` — should be current categories and 123
- ❌ POST /auth/register path is `/auth/register` in docs but actual code shows `/auth/users` (POST, admin-only) AND a separate `/auth/register` — duplicate routes exist, docs only show register
- ⚠️ Enhanced Mount Manager endpoints are documented but labeled "experimental" — are they functional on ce-dev?

### 5. cli-bridge.md
- ❌ Directory structure example shows `request/` and `file-sharing/` categories — **these don't exist in the actual `apps/` directory**
- ❌ Lists "15 known category directories" but actual bridge scans only the 11 that exist
- ❌ Shows `development/` category — doesn't exist (was renamed/removed)
- ⚠️ Category list at bottom says "Only these category directories are scanned" but lists wrong ones

### 6. deployment-guide.md
- ❌ **Says "287+ containers"** — wildly wrong, it's 123-133
- ❌ References "Yacht" and "Flame" containers — not in current catalog
- ❌ References `.env.test` file — may not exist on staging
- ❌ References `scripts/fix-all-issues.sh` and `scripts/validate-yml.sh` — may not exist
- ❌ Says "6/6 Category 1 containers deployed successfully" — refers to old testing, not current state
- ❌ Branch reference: `yaml-fixes-systematic-testing` — old branch, not relevant

### 7. architecture.md
- ❌ **Last updated August 25, 2025** — 7 months stale
- ❌ References "Jinja2 templates" — the backend is Node.js, not Python
- ❌ Application Categories section lists "Request Management: Overseerr, Petio" — Overseerr yml is missing (commented out in nav), and these aren't separate categories anymore
- ❌ Future Architecture section references org migration to `homelabarr/*` — not happening
- ⚠️ SnapRAID architecture diagram references PE features mixed into CE docs
- ⚠️ "287 YAML files" reference in deployment guide contradicts everything

### 8. local-mode.md
- ❌ Says only 3 apps have local mode templates (Plex, Radarr, qBittorrent) — the web dashboard handles local mode for ALL apps now via the Standard deployment mode
- ❌ References `apps/.config/` directory for local templates — this path doesn't match current structure
- ❌ References `deploy-local.sh` script — need to verify exists
- ❌ "What's Next?" section lists Sonarr, Jellyfin as "planned additions" — they've been available for months

### 9. mkdocs.yml (Navigation)
- ❌ **Nav structure uses dead categories:** Add-ons (19 apps listed), Development (2 apps), Requests (2 apps), File Sharing (3 apps), Encoding → Transcoding rename incomplete
- ❌ Apps are listed under `apps/addons/`, `apps/coding/`, `apps/request/`, `apps/encoder/`, `apps/kasmworkspace/` — **none of these directories exist in the apps/ folder anymore**
- ❌ Missing apps: many new apps in catalog have no wiki page (AI category apps, newer self-hosted apps)
- ❌ Radarr wiki page is commented out (`#- Radarr`), Overseerr commented out, Uploader commented out
- ⚠️ 80+ individual app .md files exist but reference old directory structures

### 10. PE Pages (pe/*.md)
- ❌ overview.md says "137+ app templates" — should be 123 active
- ❌ licensing.md says "137+ app templates" — same issue
- ❌ installation.md says "137+ Docker Compose templates" — same
- ❌ Pricing tiers ($39/$79/$149) don't match LemonSqueezy store (Early Adopter $19, Starter $39, Pro $79, Lifetime $149)
- ❌ `releases.homelabarr.com` download URL — does this domain/path exist?
- ❌ `./homelabarr --license YOUR-LICENSE-KEY` — PE binary doesn't exist yet as downloadable
- ⚠️ PE pages describe a product that isn't fully built/released — could mislead potential customers

### 11. Other Pages
- ❌ changelog.md, version-history.md — likely outdated (didn't audit in detail)
- ❌ install/linux-installation.md — references old CLI installation method
- ❌ commands/*.md — reference old CLI commands that may not work with web dashboard
- ❌ scripts/*.md — reference scripts that may not exist on staging

---

## MODERATE Issues (Outdated but Not Harmful)

1. **Ko-fi link** (ko-fi.com/homelabarr) — still valid? Or should point to LemonSqueezy?
2. **Docker social link** points to `github.com/orgs/smashingtags/packages/` — works but could be more specific
3. **Copyright says 2021-2026 @homelabarr** — should be Imogen Labs?
4. **Contributors section** — still accurate but could note this is now community-maintained
5. **Google Analytics** property `G-00QEDJW2TS` — is this still active?
6. **YAML Cleanup Tool** and **YAML Standardization** docs — refer to old migration work, may confuse new users
7. **"No ARM Support"** in requirements — is this still true for the Docker images?

---

## What's CORRECT (No Changes Needed)

1. ✅ Quick Start Method 1 (Docker Compose) — instructions work, homelabarr.yml is valid
2. ✅ CORS_ORIGIN warning — critical and accurate
3. ✅ Default credentials (admin/admin) — correct
4. ✅ Port 8084 for frontend — correct
5. ✅ Port 8092 for backend — correct
6. ✅ JWT auth flow — accurately documented
7. ✅ SSE streaming for deployment progress — accurately documented
8. ✅ Container management API endpoints — all exist in code
9. ✅ Ports API — exists and works
10. ✅ Health endpoint — exists
11. ✅ Most environment variables table — accurate
12. ✅ Screenshots exist (8 files, dark/light)

---

## Recommended Fix Priority

### P0 — Fix Immediately (Users Will Hit These)
1. App count: change all "157+", "287+", "137+", "112", "100+" references to "123+"
2. Category names in web-dashboard.md
3. API key auth endpoints in api-reference.md
4. cli-bridge.md directory structure

### P1 — Fix This Week
5. mkdocs.yml nav restructure (align with actual `apps/` categories)
6. PE pricing alignment with LemonSqueezy
7. deployment-guide.md full rewrite (remove testing references)
8. local-mode.md — rewrite to reflect web dashboard's built-in local mode

### P2 — Fix Soon
9. architecture.md modernize (remove Jinja2, update categories, remove PE SnapRAID)
10. Individual app pages — decide: keep, update, or remove?
11. Old CLI docs (commands/, scripts/) — flag as legacy or remove
12. PE pages — either complete the product or mark as "coming soon"

---

## Counts Summary

| Metric | Wiki Says | Reality |
|--------|-----------|---------|
| Total apps | 100-287 (varies by page) | 123 (UI) / 133 (YML files) |
| Categories | 12-15 (varies) | 10 active + 1 legacy |
| PE app templates | 137+ | N/A (PE not shipped) |
| Deployment modes | 3 (correct) | 3 ✅ |
| API auth endpoints | 8 | 11 (missing 3 api-key endpoints) |
