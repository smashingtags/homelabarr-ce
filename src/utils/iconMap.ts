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

// Set of all available local icon names (light variants)
const availableIcons = new Set(["alltube", "amd", "autoscan", "backup", "bazarr", "bazarr4k", "bitwarden", "calibre-web", "changedetection", "chrome", "cloud9", "cloudbeaver", "cloudcmd", "cloudflare-ddns", "cloudflared", "code-server", "coder", "comfyui", "conreq", "dashboard", "dashy", "deemix", "deluge", "dim", "discord", "diun", "dockupdater", "dozzle", "duplicati", "emby", "embystats", "fail2ban", "fenrus", "ferdi", "filerun", "filezilla", "firefox", "flaresolverr", "flowise", "freshrss", "gaps", "gluetun", "gluetun-socks5", "gotify", "guacamole", "handbrake", "homeassistant", "homelabarr-uploader", "homepage", "invokeai", "iobroker", "jackett", "jellyfin", "joplin-server", "kasmdesktop", "kitana", "koel", "kometa", "komga", "krusader", "lazylibrarian", "lidarr", "litellm", "localai", "makemkv", "mariadb", "moviematch", "mstream", "muximux", "n8n", "n8n-mcp", "netbox", "netdata", "nextcloud", "notifiarr", "nowshowing", "nzbget", "nzbhydra", "olivetin", "ollama", "onlyoffice", "open-webui", "organizr", "overseerr", "petio", "pihole", "pihole-cloudflared", "pihole-unbound", "plex", "plex-gluetun", "plex-local", "plex-test", "plex-utills", "portainer", "projectsend", "prometheus", "prowlarr", "prowlarr4k", "prowlarrhdr", "qbittorrent", "qbittorrent-gluetun", "qbittorrentvpn", "radarr", "radarr-local", "radarr4k", "radarrhdr", "rclone-gui", "readarr", "recipes", "recyclarr", "remmina", "restic", "sabnzbd", "signal", "snapdrop", "sonarr", "sonarr4k", "sonarrhdr", "speedtest", "stable-diffusion-webui", "statping", "steam", "striparr", "sui", "tauticord", "tautulli", "tdarr", "teamspeak", "telegram", "tor", "traktarr", "traktarr4k", "traktarrhdr", "tubesync", "unbound", "unifi-controller", "unmanic", "uptime-kuma", "watchtower", "webtop", "wg-easy", "wg-manager", "whoogle", "wiki", "wireguard", "wordpress", "xteve", "xteve-gluetun", "yacht", "youtubedl-material"  "aria",
  "cf-companion",
  "dify",
  "endlessh",
  "faster-whisper",
  "fooocus",
  "gpt4all",
  "grafana-loki-prometheus",
  "jan",
  "loki-config",
  "nabarr",
  "promtail-config",
  "rsnapshot",
  "text-generation-webui",
  "vlc",
  "vnstat",
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
export function getAppIconPath(appName: string, _theme: 'light' | 'dark'): string {
  const normalized = normalizeAppName(appName);

  if (!availableIcons.has(normalized)) {
    return `https://cdn.jsdelivr.net/gh/selfhst/icons/png/${normalized}.png`;
  }

  // Always use light icons — they pop better on both backgrounds
  return `/icons/apps/light/${normalized}.png`;
}

/**
 * Get the CDN fallback URL for onError handling
 */
export function getCdnFallbackUrl(appName: string): string {
  const normalized = normalizeAppName(appName);
  return `https://cdn.jsdelivr.net/gh/selfhst/icons/png/${normalized}.png`;
}

export { availableIcons };
