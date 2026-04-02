import fs from 'fs';
import path from 'path';

const INDEX_PATHS = [
  process.env.COMMUNITY_INDEX_PATH,
  path.join(process.env.TEMPLATES_PATH || '', 'community-index.json'),
  path.join(process.cwd(), 'apps', 'community-index.json'),
  path.join(process.cwd(), 'templates', 'community-index.json'),
  '/app/templates/community-index.json',
  '/app/apps/community-index.json'
].filter(Boolean);

let cache = null;
let cacheTime = 0;
const CACHE_TTL = 5 * 60 * 1000; // 5 minutes

function loadIndex() {
  if (cache && Date.now() - cacheTime < CACHE_TTL) return cache;

  for (const p of INDEX_PATHS) {
    if (fs.existsSync(p)) {
      try {
        cache = JSON.parse(fs.readFileSync(p, 'utf8'));
        cacheTime = Date.now();
        console.log(`Community feed: loaded index from ${p} (${cache.apps?.length || 0} apps)`);
        return cache;
      } catch {}
    }
  }

  console.warn('Community feed: no community-index.json found.');
  return { apps: [], categories: [] };
}

export function resetDb() {
  cache = null;
  cacheTime = 0;
}

export async function getCommunityApps(options = {}) {
  const { category, search, sort = 'name', page = 1, perPage = 12 } = options;
  const index = loadIndex();
  let apps = index.apps || [];

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
      (app.Repo || '').toLowerCase().includes(q) ||
      (app.author || '').toLowerCase().includes(q)
    );
  }

  switch (sort) {
    case 'newest': apps.sort((a, b) => (b.FirstSeen || 0) - (a.FirstSeen || 0)); break;
    case 'downloads': apps.sort((a, b) => (b.downloads || 0) - (a.downloads || 0)); break;
    case 'trending': apps.sort((a, b) => (b.trending || 0) - (a.trending || 0)); break;
    case 'stars': apps.sort((a, b) => (b.stars || 0) - (a.stars || 0)); break;
    default: apps.sort((a, b) => (a.Name || '').localeCompare(b.Name || ''));
  }

  const total = apps.length;
  const offset = (page - 1) * perPage;
  const paged = apps.slice(offset, offset + perPage);

  return { apps: paged, total, page, perPage, totalPages: Math.ceil(total / perPage), categories: index.categories || [] };
}

export async function getCommunityApp(name) {
  const index = loadIndex();
  const q = name.toLowerCase();
  return (index.apps || []).find(app => (app.Name || '').toLowerCase() === q) || null;
}

export async function getCommunityCategories() {
  const index = loadIndex();
  return index.categories || [];
}

export async function getCommunityRepos() {
  const index = loadIndex();
  const repos = {};
  for (const app of (index.apps || [])) {
    const author = app.author || app.Repo || 'Unknown';
    if (!repos[author]) repos[author] = { name: author, appCount: 0 };
    repos[author].appCount++;
  }
  return Object.values(repos).sort((a, b) => b.appCount - a.appCount);
}
