// Map of normalized app names to icon filenames
// Most names just lowercase and use the filename directly, but handle edge cases

const nameToIconFile: Record<string, string> = {
  'home-assistant': 'homeassistant',
  'calibre-web': 'calibre-web',
  'cloudflare-ddns': 'cloudflare-ddns',
  'wg-easy': 'wg-easy',
  'wg-manager': 'wg-manager',
  'n8n-mcp': 'n8n-mcp',
};

// Set of icons that only have a light variant (no dark counterpart)
const lightOnlyIcons = new Set([
  'dashy', 'diun', 'fail2ban', 'fenrus', 'homepage',
  'lazylibrarian', 'muximux', 'nzbhydra', 'organizr',
  'petio', 'restic', 'sui', 'webtop', 'whoogle'
]);

// Set of all available local icon names (light variants)
const availableIcons = new Set([
  'amd', 'autoscan', 'backup', 'bazarr', 'bazarr4k', 'bitwarden',
  'calibre-web', 'changedetection', 'cloudbeaver', 'cloudflare-ddns',
  'coder', 'conreq', 'dashy', 'deluge', 'diun', 'dozzle', 'duplicati',
  'emby', 'embystats', 'fail2ban', 'fenrus', 'filezilla', 'flaresolverr',
  'freshrss', 'gaps', 'gluetun', 'gluetun-socks5', 'gotify', 'guacamole',
  'homeassistant', 'homepage', 'iobroker', 'jackett', 'jellyfin', 'kitana',
  'koel', 'kometa', 'komga', 'krusader', 'lazylibrarian', 'lidarr',
  'mariadb', 'moviematch', 'muximux', 'n8n', 'n8n-mcp', 'netbox',
  'netdata', 'notifiarr', 'nowshowing', 'nzbget', 'nzbhydra', 'olivetin',
  'organizr', 'overseerr', 'petio', 'pihole', 'plex', 'plex-gluetun',
  'plex-test', 'plex-utills', 'portainer', 'prowlarr', 'prowlarr4k',
  'prowlarrhdr', 'qbittorrent', 'qbittorrent-gluetun', 'qbittorrentvpn',
  'radarr', 'radarr4k', 'radarrhdr', 'readarr', 'recyclarr', 'remmina',
  'restic', 'sabnzbd', 'snapdrop', 'sonarr', 'sonarr4k', 'sonarrhdr',
  'speedtest', 'sui', 'tauticord', 'tautulli', 'teamspeak', 'tubesync',
  'unbound', 'webtop', 'wg-easy', 'wg-manager', 'wireguard', 'wordpress', 'yacht'
]);

function normalizeAppName(name: string): string {
  const lower = name.toLowerCase().replace(/\s+/g, '');
  return nameToIconFile[lower] || lower;
}

/**
 * Get the icon path for an app, with theme awareness and fallbacks:
 * 1. Local icon in requested theme
 * 2. Local light icon (if dark requested but unavailable)
 * 3. selfh.st CDN URL
 */
export function getAppIconPath(appName: string, theme: 'light' | 'dark'): string {
  const normalized = normalizeAppName(appName);

  if (!availableIcons.has(normalized)) {
    return `https://cdn.jsdelivr.net/gh/selfhst/icons/png/${normalized}.png`;
  }

  if (theme === 'dark' && lightOnlyIcons.has(normalized)) {
    return `/icons/apps/light/${normalized}.png`;
  }

  return `/icons/apps/${theme}/${normalized}.png`;
}

/**
 * Get the CDN fallback URL for onError handling
 */
export function getCdnFallbackUrl(appName: string): string {
  const normalized = normalizeAppName(appName);
  return `https://cdn.jsdelivr.net/gh/selfhst/icons/png/${normalized}.png`;
}

export { availableIcons };
