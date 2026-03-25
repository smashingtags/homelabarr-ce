// Map of normalized app names to icon filenames
// Most names just lowercase and use the filename directly, but handle edge cases

const nameToIconFile: Record<string, string> = {
  'home-assistant': 'homeassistant',
  'calibre-web': 'calibre-web',
  'cloudflare-ddns': 'cloudflare-ddns',
  'wg-easy': 'wg-easy',
  'wg-manager': 'wg-manager',
  'n8n-mcp': 'n8n-mcp',
  'chrome': 'google-chrome',
  'cloudflared': 'cloudflare',
  'ferdi': 'ferdium',
  'joplin-server': 'joplin',
  'rclone-gui': 'rclone',
  'pihole-cloudflared': 'pi-hole',
  'pihole-unbound': 'pi-hole',
  'traktarr': 'trakt',
  'traktarr4k': 'trakt',
  'traktarrhdr': 'trakt',
  'youtubedl-material': 'youtube',
  'grafana-loki-prometheus': 'grafana',
  'loki-config': 'loki',
  'wiki': 'bookstack',
};

// Set of icons that only have a light variant (no dark counterpart)
const lightOnlyIcons = new Set([
  'dashy', 'deemix', 'diun', 'fail2ban', 'fenrus', 'firefox',
  'handbrake', 'homepage', 'lazylibrarian', 'muximux', 'nzbhydra',
  'organizr', 'petio', 'restic', 'sui', 'tdarr', 'unmanic',
  'webtop', 'whoogle'
]);

// Set of all available local icon names (light variants)
const availableIcons = new Set([
  'amd', 'autoscan', 'backup', 'bazarr', 'bazarr4k', 'bitwarden',
  'calibre-web', 'changedetection', 'cloudbeaver', 'cloudflare-ddns',
  'coder', 'conreq', 'dashy', 'deemix', 'deluge', 'discord', 'diun',
  'dozzle', 'duplicati', 'emby', 'embystats', 'fail2ban', 'fenrus',
  'filerun', 'filezilla', 'firefox', 'flaresolverr', 'freshrss', 'gaps',
  'gluetun', 'gluetun-socks5', 'gotify', 'guacamole', 'handbrake',
  'homeassistant', 'homepage', 'iobroker', 'jackett', 'jellyfin', 'kitana',
  'koel', 'kometa', 'komga', 'krusader', 'lazylibrarian', 'lidarr',
  'makemkv', 'mariadb', 'moviematch', 'muximux', 'n8n', 'n8n-mcp',
  'netbox', 'netdata', 'nextcloud', 'notifiarr', 'nowshowing', 'nzbget',
  'nzbhydra', 'olivetin', 'onlyoffice', 'organizr', 'overseerr', 'petio',
  'pihole', 'plex', 'plex-gluetun', 'plex-test', 'plex-utills', 'portainer',
  'projectsend', 'prometheus', 'prowlarr', 'prowlarr4k', 'prowlarrhdr',
  'qbittorrent', 'qbittorrent-gluetun', 'qbittorrentvpn', 'radarr',
  'radarr4k', 'radarrhdr', 'readarr', 'recyclarr', 'remmina', 'restic',
  'sabnzbd', 'signal', 'snapdrop', 'sonarr', 'sonarr4k', 'sonarrhdr',
  'speedtest', 'steam', 'striparr', 'sui', 'tauticord', 'tautulli', 'tdarr',
  'teamspeak', 'telegram', 'tor', 'tubesync', 'unbound', 'unmanic',
  'uptime-kuma', 'watchtower', 'webtop', 'wg-easy', 'wg-manager',
  'whoogle', 'wireguard', 'wordpress', 'yacht'
]);

function normalizeAppName(name: string): string {
  const lower = name.toLowerCase().replace(/\s+/g, '-');
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
