#!/usr/bin/env node

/**
 * Pre-generates Docker Compose YAML templates from the community apps database.
 * Run after import.py refreshes the database. Output goes to the templates
 * repo under community/<category>/<app>.yml
 *
 * Usage:
 *   node server/generate-community-templates.js --db /path/to/unraid-ca.db --out /path/to/templates/community
 */

import Database from 'better-sqlite3';
import { generateCompose } from './template-generator.js';
import fs from 'fs';
import path from 'path';

const args = process.argv.slice(2);
const dbPath = args.includes('--db') ? args[args.indexOf('--db') + 1] : null;
const outDir = args.includes('--out') ? args[args.indexOf('--out') + 1] : null;

if (!dbPath || !outDir) {
  console.error('Usage: node generate-community-templates.js --db <path-to-unraid-ca.db> --out <output-dir>');
  process.exit(1);
}

if (!fs.existsSync(dbPath)) {
  console.error(`Database not found: ${dbPath}`);
  process.exit(1);
}

const db = new Database(dbPath, { readonly: true });

// Category code → clean directory name
const CATEGORY_MAP = {
  'AI': 'ai',
  'Backup': 'backup',
  'Cloud': 'cloud',
  'Crypto Currency': 'crypto',
  'Downloaders': 'downloads',
  'Drivers': 'drivers',
  'Game Servers': 'game-servers',
  'Home Automation': 'home-automation',
  'Media Applications': 'media-management',
  'Media Servers': 'media-servers',
  'Network Services': 'networking',
  'Other': 'other',
  'Productivity': 'productivity',
  'Security': 'security',
  'Tools / Utilities': 'tools',
};

function sanitizeName(name) {
  return (name || 'unknown').toLowerCase().replace(/[^a-z0-9_-]/g, '-').replace(/-+/g, '-').replace(/^-|-$/g, '');
}

const apps = db.prepare(`
  SELECT a.*, r.title as author_name
  FROM apps a
  LEFT JOIN repositories r ON a.repository_id = r.id
  WHERE a.is_blacklisted = 0 AND a.is_deprecated = 0 AND a.is_plugin = 0 AND a.docker_image IS NOT NULL
`).all();

const configs = db.prepare('SELECT * FROM app_configs WHERE app_id = ?');
const appCats = db.prepare(`
  SELECT c.description FROM app_categories ac
  JOIN categories c ON ac.category = c.code
  WHERE ac.app_id = ?
`);

let generated = 0;
let skipped = 0;
let errors = 0;

for (const app of apps) {
  const appConfigs = configs.all(app.id);
  const categories = appCats.all(app.id).map(r => r.description);
  const primaryCategory = categories[0] || 'Other';
  const dirName = CATEGORY_MAP[primaryCategory] || sanitizeName(primaryCategory);

  // Build the feed-format object that template-generator expects
  const feedApp = {
    Name: app.name,
    Repository: app.docker_image,
    Network: app.network_mode || 'bridge',
    Privileged: app.privileged ? 'true' : 'false',
    WebUI: app.web_ui_pattern || '',
    Config: appConfigs.map(c => ({
      '@attributes': {
        Name: c.name || '',
        Target: c.target || '',
        Default: c.default_val || '',
        Mode: c.mode || '',
        Type: c.type || '',
        Description: c.description || ''
      }
    }))
  };

  try {
    const yaml = generateCompose(feedApp);
    if (!yaml) {
      skipped++;
      continue;
    }

    const categoryDir = path.join(outDir, dirName);
    if (!fs.existsSync(categoryDir)) {
      fs.mkdirSync(categoryDir, { recursive: true });
    }

    const fileName = sanitizeName(app.name) + '.yml';
    fs.writeFileSync(path.join(categoryDir, fileName), yaml);
    generated++;
  } catch (err) {
    errors++;
  }
}

db.close();

console.log(`Generated: ${generated}`);
console.log(`Skipped: ${skipped} (no image or empty)`);
console.log(`Errors: ${errors}`);
console.log(`Output: ${outDir}`);
