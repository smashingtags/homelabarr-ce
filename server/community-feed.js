import Database from 'better-sqlite3';
import path from 'path';
import fs from 'fs';

const DB_PATHS = [
  process.env.COMMUNITY_DB_PATH,
  path.join(process.cwd(), 'data', 'unraid-ca.db'),
  path.join(process.cwd(), 'server', 'data', 'unraid-ca.db'),
  '/app/data/unraid-ca.db'
].filter(Boolean);

let db = null;

function getDb() {
  if (db) return db;
  for (const p of DB_PATHS) {
    if (fs.existsSync(p)) {
      db = new Database(p, { readonly: true });
      console.log(`Community feed: using database at ${p}`);
      return db;
    }
  }
  console.warn('Community feed: no database found. Run import.py from unraid-ca-db to populate.');
  return null;
}

export async function getCommunityApps(options = {}) {
  const { category, search, sort = 'name', page = 1, perPage = 50 } = options;
  const conn = getDb();
  if (!conn) return { apps: [], total: 0, page, perPage, totalPages: 0 };

  let where = 'WHERE a.is_blacklisted = 0 AND a.is_deprecated = 0 AND a.is_plugin = 0 AND a.docker_image IS NOT NULL';
  const params = [];

  if (category) {
    where += ' AND a.id IN (SELECT app_id FROM app_categories ac JOIN categories c ON ac.category = c.code WHERE c.description LIKE ?)';
    params.push(`%${category}%`);
  }

  if (search) {
    where += ' AND a.id IN (SELECT rowid FROM apps_fts WHERE apps_fts MATCH ?)';
    params.push(`${search}*`);
  }

  let orderBy;
  switch (sort) {
    case 'newest': orderBy = 'a.first_seen DESC'; break;
    case 'downloads': orderBy = 'COALESCE(a.downloads, 0) DESC'; break;
    case 'trending': orderBy = 'COALESCE(a.trending_score, 0) DESC'; break;
    case 'stars': orderBy = 'COALESCE(a.stars, 0) DESC'; break;
    default: orderBy = 'a.name COLLATE NOCASE ASC';
  }

  const countRow = conn.prepare(`SELECT COUNT(*) as total FROM apps a ${where}`).get(...params);
  const total = countRow?.total || 0;
  const offset = (page - 1) * perPage;

  const rows = conn.prepare(`
    SELECT a.*, r.title as author_name, r.profile_url as author_url
    FROM apps a
    LEFT JOIN repositories r ON a.repository_id = r.id
    ${where}
    ORDER BY ${orderBy}
    LIMIT ? OFFSET ?
  `).all(...params, perPage, offset);

  const apps = rows.map(row => formatApp(conn, row));

  return { apps, total, page, perPage, totalPages: Math.ceil(total / perPage) };
}

export async function getCommunityApp(name) {
  const conn = getDb();
  if (!conn) return null;

  const row = conn.prepare(`
    SELECT a.*, r.title as author_name, r.profile_url as author_url
    FROM apps a
    LEFT JOIN repositories r ON a.repository_id = r.id
    WHERE LOWER(a.name) = LOWER(?) AND a.is_blacklisted = 0 AND a.is_deprecated = 0 AND a.docker_image IS NOT NULL
  `).get(name);

  if (!row) return null;

  const app = formatApp(conn, row);
  app.Config = getAppConfigs(conn, row.id);
  return app;
}

export async function getCommunityCategories() {
  const conn = getDb();
  if (!conn) return [];

  const rows = conn.prepare(`
    SELECT c.description, COUNT(DISTINCT ac.app_id) as count
    FROM categories c
    JOIN app_categories ac ON ac.category = c.code
    JOIN apps a ON a.id = ac.app_id
    WHERE a.is_blacklisted = 0 AND a.is_deprecated = 0 AND a.is_plugin = 0 AND a.docker_image IS NOT NULL
    GROUP BY c.description
    ORDER BY count DESC
  `).all();

  return rows.map(r => r.description);
}

export async function getCommunityRepos() {
  const conn = getDb();
  if (!conn) return [];

  const rows = conn.prepare(`
    SELECT r.title as name, COUNT(a.id) as app_count, r.profile_url
    FROM repositories r
    JOIN apps a ON a.repository_id = r.id
    WHERE a.is_blacklisted = 0 AND a.is_deprecated = 0 AND a.is_plugin = 0 AND a.docker_image IS NOT NULL
    GROUP BY r.id
    ORDER BY app_count DESC
  `).all();

  return rows.map(r => ({ name: r.name, appCount: r.app_count, profileUrl: r.profile_url }));
}

function getAppConfigs(conn, appId) {
  const rows = conn.prepare('SELECT * FROM app_configs WHERE app_id = ?').all(appId);
  return rows.map(r => ({
    '@attributes': {
      Name: r.name || '',
      Target: r.target || '',
      Default: r.default_val || '',
      Mode: r.mode || '',
      Type: r.type || '',
      Description: r.description || ''
    }
  }));
}

function getAppCategories(conn, appId) {
  const rows = conn.prepare(`
    SELECT c.description FROM app_categories ac
    JOIN categories c ON ac.category = c.code
    WHERE ac.app_id = ?
  `).all(appId);
  return rows.map(r => r.description);
}

function formatApp(conn, row) {
  return {
    Name: row.name,
    Repository: row.docker_image,
    Registry: row.registry_url || '',
    Network: row.network_mode || 'bridge',
    Privileged: row.privileged ? 'true' : 'false',
    Support: row.support_url || '',
    Project: row.project_url || '',
    Overview: row.overview || '',
    WebUI: row.web_ui_pattern || '',
    Icon: row.icon_url || '',
    Repo: row.author_name || row.repo_name || '',
    CategoryList: getAppCategories(conn, row.id),
    LastUpdateScan: row.last_update_scan || 0,
    FirstSeen: row.first_seen || 0,
    downloads: row.downloads || 0,
    stars: row.stars || 0,
    trending: row.trending_score || 0,
    author: row.author_name || row.repo_name || '',
    authorUrl: row.author_url || ''
  };
}
