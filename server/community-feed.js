import fs from 'fs';
import path from 'path';

const FEED_URL = 'https://raw.githubusercontent.com/Squidly271/AppFeed/master/applicationFeed.json';
const CACHE_DIR = path.join(process.cwd(), 'server', 'data');
const CACHE_FILE = path.join(CACHE_DIR, 'community-feed-cache.json');
const CACHE_MAX_AGE_MS = 24 * 60 * 60 * 1000;

let memoryCache = null;

function readCache() {
  try {
    if (!fs.existsSync(CACHE_FILE)) return null;
    const stat = fs.statSync(CACHE_FILE);
    if (Date.now() - stat.mtimeMs > CACHE_MAX_AGE_MS) return null;
    const raw = fs.readFileSync(CACHE_FILE, 'utf-8');
    return JSON.parse(raw);
  } catch {
    return null;
  }
}

function writeCache(data) {
  try {
    if (!fs.existsSync(CACHE_DIR)) {
      fs.mkdirSync(CACHE_DIR, { recursive: true });
    }
    fs.writeFileSync(CACHE_FILE, JSON.stringify(data));
  } catch (err) {
    console.error('Failed to write community feed cache:', err.message);
  }
}

function readStaleCache() {
  try {
    if (!fs.existsSync(CACHE_FILE)) return null;
    const raw = fs.readFileSync(CACHE_FILE, 'utf-8');
    return JSON.parse(raw);
  } catch {
    return null;
  }
}

export async function fetchFeed() {
  if (memoryCache) {
    const age = Date.now() - memoryCache._cachedAt;
    if (age < CACHE_MAX_AGE_MS) return memoryCache;
  }

  const cached = readCache();
  if (cached) {
    cached._cachedAt = Date.now();
    memoryCache = cached;
    return cached;
  }

  try {
    const res = await fetch(FEED_URL);
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    const data = await res.json();
    data._cachedAt = Date.now();
    memoryCache = data;
    writeCache(data);
    return data;
  } catch (err) {
    console.error('Failed to fetch community feed:', err.message);
    const stale = readStaleCache();
    if (stale) {
      stale._cachedAt = Date.now();
      memoryCache = stale;
      return stale;
    }
    return { applist: [], categories: [] };
  }
}

export async function getCommunityApps(options = {}) {
  const { category, search, sort = 'name', page = 1, perPage = 50 } = options;
  const feed = await fetchFeed();
  let apps = (feed.applist || []).filter(app => app.Repository);

  if (category) {
    const cat = category.toLowerCase();
    apps = apps.filter(app =>
      (app.CategoryList || []).some(c => c.toLowerCase().includes(cat))
    );
  }

  if (search) {
    const q = search.toLowerCase();
    apps = apps.filter(app =>
      (app.Name || '').toLowerCase().includes(q) ||
      (app.Overview || '').toLowerCase().includes(q) ||
      (app.Repository || '').toLowerCase().includes(q)
    );
  }

  switch (sort) {
    case 'newest':
      apps.sort((a, b) => (b.FirstSeen || 0) - (a.FirstSeen || 0));
      break;
    case 'updated':
      apps.sort((a, b) => (b.LastUpdateScan || 0) - (a.LastUpdateScan || 0));
      break;
    default:
      apps.sort((a, b) => (a.Name || '').localeCompare(b.Name || ''));
  }

  const total = apps.length;
  const start = (page - 1) * perPage;
  const paged = apps.slice(start, start + perPage);

  return { apps: paged, total, page, perPage, totalPages: Math.ceil(total / perPage) };
}

export async function getCommunityApp(name) {
  const feed = await fetchFeed();
  const q = name.toLowerCase();
  return (feed.applist || []).find(app =>
    app.Repository && (app.Name || '').toLowerCase() === q
  ) || null;
}

export async function getCommunityCategories() {
  const feed = await fetchFeed();
  const apps = (feed.applist || []).filter(app => app.Repository);
  const cats = new Set();
  for (const app of apps) {
    for (const c of (app.CategoryList || [])) {
      cats.add(c);
    }
  }
  return [...cats].sort();
}

export async function getCommunityRepos() {
  const feed = await fetchFeed();
  const apps = (feed.applist || []).filter(app => app.Repository);
  const repos = new Set();
  for (const app of apps) {
    if (app.Repo) repos.add(app.Repo);
  }
  return [...repos].sort();
}
