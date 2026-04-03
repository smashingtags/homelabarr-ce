import fs from 'fs';
import path from 'path';

const PREFS_FILE = path.join(process.cwd(), 'server', 'config', 'preferences.json');

const configDir = path.dirname(PREFS_FILE);
if (!fs.existsSync(configDir)) {
  fs.mkdirSync(configDir, { recursive: true });
}

function loadPreferences() {
  try {
    if (!fs.existsSync(PREFS_FILE)) return {};
    return JSON.parse(fs.readFileSync(PREFS_FILE, 'utf8'));
  } catch {
    return {};
  }
}

function savePreferences(prefs) {
  try {
    fs.writeFileSync(PREFS_FILE, JSON.stringify(prefs, null, 2));
    return true;
  } catch (err) {
    console.error('Error saving preferences:', err);
    return false;
  }
}

export function getUserPreferences(userId) {
  const prefs = loadPreferences();
  return prefs[userId] || { hiddenCategories: [] };
}

export function setHiddenCategories(userId, categories) {
  const prefs = loadPreferences();
  if (!prefs[userId]) prefs[userId] = {};
  prefs[userId].hiddenCategories = categories;
  if (!savePreferences(prefs)) throw new Error('Failed to save preferences');
  return prefs[userId];
}

export function resetPreferences(userId) {
  const prefs = loadPreferences();
  delete prefs[userId];
  if (!savePreferences(prefs)) throw new Error('Failed to save preferences');
}

const MONITORING_KEY = '_monitoring';

export function getMonitoringPreferences() {
  const prefs = loadPreferences();
  return prefs[MONITORING_KEY] || { enabled: false, enableLogs: false, grafanaPort: 3000 };
}

export function setMonitoringPreferences(monitoringPrefs) {
  const prefs = loadPreferences();
  prefs[MONITORING_KEY] = { ...getMonitoringPreferences(), ...monitoringPrefs };
  if (!savePreferences(prefs)) throw new Error('Failed to save monitoring preferences');
  return prefs[MONITORING_KEY];
}
