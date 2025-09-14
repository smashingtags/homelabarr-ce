import { AppTemplate } from '../types';
import { 
  Video, 
  Radio,
  Network,
  Lock,
  Download,
  Tv2,
  Rss,
  BookOpenCheck,
  Gauge,
  FileSearch,
  Scan,
  Home,
  MessageSquarePlus,
  GitBranch,
  Key,
  Activity,
  FileText,
  RefreshCw,
  Image,
  Calendar,
  NotebookPen,
  Mail,
  Headphones,
  Library,
  Files,
  Container as ContainerIcon,
  ScrollText,
  LayoutDashboard,
  MonitorSmartphone,
  AppWindow,
  Book,
  Link,
  LineChart,
  Bell,
  BarChart2,
  Activity as ActivityIcon,
  Network as NetworkIcon,
  MessageCircle,
  Users,
  Webhook,
  Music,
  Subtitles,
  Search,
  Shield,
  Zap,
  Eye,
  Database,
  Server,
  Wifi,
  Code2,
  Archive,
  Globe,
  Cloud
} from 'lucide-react';

export const appTemplates: AppTemplate[] = [
  // Infrastructure
  {
    id: 'traefik',
    name: 'Traefik',
    description: 'Modern reverse proxy and load balancer',
    category: 'system-utilities',
    logo: Network,
    deploymentModes: ['traefik'],
    defaultPorts: {
      web: 80,
      websecure: 443,
      admin: 8080
    },
    requiredPorts: ['web', 'websecure', 'admin'],
    configFields: [
      {
        name: 'domain',
        label: 'Domain',
        type: 'text',
        required: true,
        placeholder: 'example.com'
      },
      {
        name: 'email',
        label: 'Email (for Let\'s Encrypt)',
        type: 'text',
        required: true
      },
      {
        name: 'dashboard_port',
        label: 'Dashboard Port',
        type: 'number',
        required: true,
        defaultValue: '8080'
      }
    ]
  },
  {
    id: 'homepage',
    name: 'Homepage',
    description: 'Modern and clean dashboard for your homelab',
    category: 'system-utilities',
    logo: Home,
    deploymentModes: ['traefik'],
    defaultPorts: {
      web: 3000
    },
    requiredPorts: ['web'],
    configFields: [
      {
        name: 'domain',
        label: 'Domain',
        type: 'text',
        required: true,
        placeholder: 'example.com'
      }
    ]
  },
  {
    id: 'fenrus',
    name: 'Fenrus',
    description: 'Simple and modern dashboard',
    category: 'system-utilities',
    logo: LayoutDashboard,
    deploymentModes: ['traefik'],
    defaultPorts: {
      web: 3000
    },
    requiredPorts: ['web'],
    configFields: [
      {
        name: 'domain',
        label: 'Domain',
        type: 'text',
        required: true,
        placeholder: 'example.com'
      }
    ]
  },
  {
    id: 'heimdall',
    name: 'Heimdall',
    description: 'Application dashboard and launcher',
    category: 'system-utilities',
    logo: AppWindow,
    deploymentModes: ['traefik'],
    configFields: [
      {
        name: 'domain',
        label: 'Domain',
        type: 'text',
        required: true,
        placeholder: 'example.com'
      }
    ]
  },

  // Security
  {
    id: 'authelia',
    name: 'Authelia',
    description: 'Full-featured authentication server',
    category: 'system-utilities',
    logo: Lock,
    deploymentModes: ['traefik'],
    defaultPorts: {
      web: 9091
    },
    requiredPorts: ['web'],
    configFields: [
      {
        name: 'domain',
        label: 'Domain',
        type: 'text',
        required: true,
        placeholder: 'example.com'
      }
    ]
  },
  {
    id: 'authentik',
    name: 'Authentik',
    description: 'Identity provider & access management',
    category: 'system-utilities',
    logo: Lock,
    deploymentModes: ['traefik'],
    defaultPorts: {
      web: 9000,
      websecure: 9443
    },
    requiredPorts: ['web', 'websecure'],
    configFields: [
      {
        name: 'domain',
        label: 'Domain',
        type: 'text',
        required: true,
        placeholder: 'example.com'
      },
      {
        name: 'admin_email',
        label: 'Admin Email',
        type: 'text',
        required: true
      },
      {
        name: 'admin_password',
        label: 'Admin Password',
        type: 'password',
        required: true
      }
    ]
  },
  {
    id: 'vaultwarden',
    name: 'Vaultwarden',
    description: 'Lightweight Bitwarden server',
    category: 'system-utilities',
    logo: Key,
    deploymentModes: ['traefik'],
    configFields: [
      {
        name: 'domain',
        label: 'Domain',
        type: 'text',
        required: true,
        placeholder: 'example.com'
      },
      {
        name: 'admin_token',
        label: 'Admin Token',
        type: 'password',
        required: true
      }
    ]
  },

  // Monitoring
  {
    id: 'dozzle',
    name: 'Dozzle',
    description: 'Real-time Docker log viewer',
    category: 'monitoring',
    logo: ScrollText,
    deploymentModes: ['traefik'],
    configFields: [
      {
        name: 'domain',
        label: 'Domain',
        type: 'text',
        required: true,
        placeholder: 'example.com'
      }
    ]
  },
  {
    id: 'glances',
    name: 'Glances',
    description: 'System monitoring tool',
    category: 'monitoring',
    logo: MonitorSmartphone,
    deploymentModes: ['traefik'],
    configFields: [
      {
        name: 'domain',
        label: 'Domain',
        type: 'text',
        required: true,
        placeholder: 'example.com'
      }
    ]
  },
  {
    id: 'netdata',
    name: 'Netdata',
    description: 'Real-time performance monitoring',
    category: 'monitoring',
    logo: LineChart,
    deploymentModes: ['traefik'],
    configFields: [
      {
        name: 'domain',
        label: 'Domain',
        type: 'text',
        required: true,
        placeholder: 'example.com'
      }
    ]
  },
  {
    id: 'tautulli',
    name: 'Tautulli',
    description: 'Plex Media Server monitoring',
    category: 'monitoring',
    logo: BarChart2,
    deploymentModes: ['traefik'],
    configFields: [
      {
        name: 'domain',
        label: 'Domain',
        type: 'text',
        required: true,
        placeholder: 'example.com'
      },
      {
        name: 'plex_logs',
        label: 'Plex Logs Path',
        type: 'text',
        required: true,
        placeholder: '/path/to/plex/logs'
      }
    ]
  },
  {
    id: 'vnstat',
    name: 'vnStat',
    description: 'Network traffic monitor',
    category: 'monitoring',
    logo: NetworkIcon,
    deploymentModes: ['traefik'],
    configFields: [
      {
        name: 'domain',
        label: 'Domain',
        type: 'text',
        required: true,
        placeholder: 'example.com'
      }
    ]
  },
  {
    id: 'uptime-kuma',
    name: 'Uptime Kuma',
    description: 'Self-hosted uptime monitoring tool',
    category: 'monitoring',
    logo: Activity,
    deploymentModes: ['traefik'],
    configFields: [
      {
        name: 'domain',
        label: 'Domain',
        type: 'text',
        required: true,
        placeholder: 'example.com'
      }
    ]
  },
  {
    id: 'grafana',
    name: 'Grafana',
    description: 'Analytics and monitoring',
    category: 'monitoring',
    logo: Gauge,
    deploymentModes: ['traefik'],
    configFields: [
      {
        name: 'domain',
        label: 'Domain',
        type: 'text',
        required: true,
        placeholder: 'example.com'
      },
      {
        name: 'admin_password',
        label: 'Admin Password',
        type: 'password',
        required: true
      }
    ]
  },

  // Media
  {
    id: 'audiobookshelf',
    name: 'Audiobookshelf',
    description: 'Self-hosted audiobook server',
    category: 'media',
    logo: Headphones,
    deploymentModes: ['traefik'],
    configFields: [
      {
        name: 'domain',
        label: 'Domain',
        type: 'text',
        required: true,
        placeholder: 'example.com'
      },
      {
        name: 'audiobooks_path',
        label: 'Audiobooks Path',
        type: 'text',
        required: true,
        placeholder: '/path/to/audiobooks'
      },
      {
        name: 'metadata_path',
        label: 'Metadata Path',
        type: 'text',
        required: true,
        placeholder: '/path/to/metadata'
      }
    ]
  },
  {
    id: 'calibre-web',
    name: 'Calibre Web',
    description: 'Web app for accessing your Calibre library',
    category: 'media',
    logo: Library,
    deploymentModes: ['traefik'],
    configFields: [
      {
        name: 'domain',
        label: 'Domain',
        type: 'text',
        required: true,
        placeholder: 'example.com'
      },
      {
        name: 'books_path',
        label: 'Books Path',
        type: 'text',
        required: true,
        placeholder: '/path/to/books'
      }
    ]
  },
  {
    id: 'kometa',
    name: 'Kometa',
    description: 'Modern manga server and reader',
    category: 'media',
    logo: Book,
    deploymentModes: ['traefik'],
    configFields: [
      {
        name: 'domain',
        label: 'Domain',
        type: 'text',
        required: true,
        placeholder: 'example.com'
      }
    ]
  },
  {
    id: 'plex',
    name: 'Plex',
    description: 'Stream your media anywhere',
    category: 'media',
    logo: Video,
    deploymentModes: ['traefik'],
    defaultPorts: {
      web: 32400,
      dlna: 1900,
      gdm1: 32410,
      gdm2: 32412,
      gdm3: 32413,
      gdm4: 32414
    },
    requiredPorts: ['web', 'dlna', 'gdm1', 'gdm2', 'gdm3', 'gdm4'],
    configFields: [
      {
        name: 'domain',
        label: 'Domain',
        type: 'text',
        required: true,
        placeholder: 'example.com'
      },
      {
        name: 'claim_token',
        label: 'Plex Claim Token',
        type: 'text',
        required: true
      },
      {
        name: 'media_path',
        label: 'Media Library Path',
        type: 'text',
        required: true,
        placeholder: '/path/to/media'
      }
    ]
  },
  {
    id: 'jellyfin',
    name: 'Jellyfin',
    description: 'Open source media system',
    category: 'media',
    logo: Radio,
    deploymentModes: ['traefik'],
    defaultPorts: {
      web: 8096,
      https: 8920,
      dlna: 1900
    },
    requiredPorts: ['web', 'https', 'dlna'],
    configFields: [
      {
        name: 'domain',
        label: 'Domain',
        type: 'text',
        required: true,
        placeholder: 'example.com'
      },
      {
        name: 'media_path',
        label: 'Media Library Path',
        type: 'text',
        required: true,
        placeholder: '/path/to/media'
      }
    ]
  },
  {
    id: 'emby',
    name: 'Emby',
    description: 'Personal media server',
    category: 'media',
    logo: Tv2,
    deploymentModes: ['traefik'],
    defaultPorts: {
      web: 8096,
      https: 8920
    },
    requiredPorts: ['web', 'https'],
    configFields: [
      {
        name: 'domain',
        label: 'Domain',
        type: 'text',
        required: true,
        placeholder: 'example.com'
      },
      {
        name: 'media_path',
        label: 'Media Library Path',
        type: 'text',
        required: true,
        placeholder: '/path/to/media'
      }
    ]
  },
  {
    id: 'overseerr',
    name: 'Overseerr',
    description: 'Request management for Plex',
    category: 'media',
    logo: MessageSquarePlus,
    deploymentModes: ['traefik'],
    configFields: [
      {
        name: 'domain',
        label: 'Domain',
        type: 'text',
        required: true,
        placeholder: 'example.com'
      }
    ]
  },

  // Downloads
  {
    id: 'qbittorrent',
    name: 'qBittorrent',
    description: 'Feature-rich torrent client',
    category: 'downloads',
    logo: Download,
    deploymentModes: ['traefik'],
    defaultPorts: {
      web: 8080,
      tcp: 6881,
      udp: 6881
    },
    requiredPorts: ['web', 'tcp', 'udp'],
    configFields: [
      {
        name: 'domain',
        label: 'Domain',
        type: 'text',
        required: true,
        placeholder: 'example.com'
      },
      {
        name: 'webui_port',
        label: 'WebUI Port',
        type: 'number',
        required: true,
        defaultValue: '8080'
      },
      {
        name: 'downloads_path',
        label: 'Downloads Path',
        type: 'text',
        required: true,
        placeholder: '/path/to/downloads'
      }
    ]
  },
  {
    id: 'nzbget',
    name: 'NZBGet',
    description: 'Efficient Usenet downloader',
    category: 'downloads',
    logo: Download,
    deploymentModes: ['traefik'],
    defaultPorts: {
      web: 6789
    },
    requiredPorts: ['web'],
    configFields: [
      {
        name: 'domain',
        label: 'Domain',
        type: 'text',
        required: true,
        placeholder: 'example.com'
      },
      {
        name: 'downloads_path',
        label: 'Downloads Path',
        type: 'text',
        required: true,
        placeholder: '/path/to/downloads'
      },
      {
        name: 'control_password',
        label: 'Control Password',
        type: 'password',
        required: true
      }
    ]
  },
  {
    id: 'nzbhydra2',
    name: 'NZBHydra2',
    description: 'Meta search for NZB indexers',
    category: 'downloads',
    logo: Download,
    deploymentModes: ['traefik'],
    defaultPorts: {
      web: 5076
    },
    requiredPorts: ['web'],
    configFields: [
      {
        name: 'domain',
        label: 'Domain',
        type: 'text',
        required: true,
        placeholder: 'example.com'
      },
      {
        name: 'config_path',
        label: 'Config Path',
        type: 'text',
        required: true,
        placeholder: '/path/to/config'
      }
    ]
  },

  // Development
  {
    id: 'cloudcmd',
    name: 'Cloud Commander',
    description: 'Web file manager',
    category: 'development',
    logo: Files,
    deploymentModes: ['traefik'],
    configFields: [
      {
        name: 'domain',
        label: 'Domain',
        type: 'text',
        required: true,
        placeholder: 'example.com'
      },
      {
        name: 'files_path',
        label: 'Files Path',
        type: 'text',
        required: true,
        placeholder: '/path/to/files'
      }
    ]
  },
  {
    id: 'cloudflare-ddns',
    name: 'Cloudflare DDNS',
    description: 'Dynamic DNS updater for Cloudflare',
    category: 'system-utilities',
    logo: Network,
    deploymentModes: ['traefik'],
    configFields: [
      {
        name: 'api_token',
        label: 'Cloudflare API Token',
        type: 'password',
        required: true
      },
      {
        name: 'zone_id',
        label: 'Zone ID',
        type: 'text',
        required: true
      },
      {
        name: 'domain',
        label: 'Domain',
        type: 'text',
        required: true,
        placeholder: 'example.com'
      }
    ]
  },
  {
    id: 'dockge',
    name: 'Dockge',
    description: 'Docker compose stack manager',
    category: 'development',
    logo: ContainerIcon,
    deploymentModes: ['traefik'],
    configFields: [
      {
        name: 'domain',
        label: 'Domain',
        type: 'text',
        required: true,
        placeholder: 'example.com'
      },
      {
        name: 'stacks_path',
        label: 'Stacks Path',
        type: 'text',
        required: true,
        placeholder: '/path/to/stacks'
      }
    ]
  },
  {
    id: 'postgres',
    name: 'PostgreSQL',
    description: 'Advanced open source database',
    category: 'development',
    logo: ContainerIcon,
    deploymentModes: ['traefik'],
    defaultPorts: {
      db: 5432
    },
    requiredPorts: ['db'],
    configFields: [
      {
        name: 'postgres_user',
        label: 'Database User',
        type: 'text',
        required: true
      },
      {
        name: 'postgres_password',
        label: 'Database Password',
        type: 'password',
        required: true
      },
      {
        name: 'data_path',
        label: 'Data Path',
        type: 'text',
        required: true,
        placeholder: '/path/to/data'
      }
    ]
  },
  {
    id: 'portainer',
    name: 'Portainer',
    description: 'Container management and monitoring',
    category: 'development',
    logo: ContainerIcon,
    deploymentModes: ['traefik'],
    configFields: [
      {
        name: 'port',
        label: 'Web UI Port',
        type: 'number',
        required: true,
        defaultValue: '9000'
      }
    ]
  },
  {
    id: 'guacamole',
    name: 'Apache Guacamole',
    description: 'Clientless remote desktop gateway',
    category: 'development',
    logo: MonitorSmartphone,
    deploymentModes: ['traefik'],
    configFields: [
      {
        name: 'domain',
        label: 'Domain',
        type: 'text',
        required: true,
        placeholder: 'example.com'
      },
      {
        name: 'mysql_password',
        label: 'MySQL Password',
        type: 'password',
        required: true
      }
    ]
  },
  {
    id: 'it-tools',
    name: 'IT Tools',
    description: 'Collection of handy tools for developers',
    category: 'development',
    logo: ActivityIcon,
    deploymentModes: ['traefik'],
    configFields: [
      {
        name: 'domain',
        label: 'Domain',
        type: 'text',
        required: true,
        placeholder: 'example.com'
      }
    ]
  },
  {
    id: 'yacht',
    name: 'Yacht',
    description: 'Container management UI',
    category: 'development',
    logo: ContainerIcon,
    deploymentModes: ['traefik'],
    configFields: [
      {
        name: 'domain',
        label: 'Domain',
        type: 'text',
        required: true,
        placeholder: 'example.com'
      },
      {
        name: 'admin_email',
        label: 'Admin Email',
        type: 'text',
        required: true
      },
      {
        name: 'admin_password',
        label: 'Admin Password',
        type: 'password',
        required: true
      }
    ]
  },
  {
    id: 'gitea',
    name: 'Gitea',
    description: 'Lightweight self-hosted Git service',
    category: 'development',
    logo: GitBranch,
    deploymentModes: ['traefik'],
    defaultPorts: {
      web: 3000,
      ssh: 22
    },
    requiredPorts: ['web', 'ssh'],
    configFields: [
      {
        name: 'domain',
        label: 'Domain',
        type: 'text',
        required: true,
        placeholder: 'example.com'
      },
      {
        name: 'db_password',
        label: 'Database Password',
        type: 'password',
        required: true
      }
    ]
  },

  // Storage
  {
    id: 'linkwarden',
    name: 'Linkwarden',
    description: 'Self-hosted bookmark manager',
    category: 'backup-storage',
    logo: Link,
    deploymentModes: ['traefik'],
    configFields: [
      {
        name: 'domain',
        label: 'Domain',
        type: 'text',
        required: true,
        placeholder: 'example.com'
      },
      {
        name: 'db_user',
        label: 'Database User',
        type: 'text',
        required: true
      },
      {
        name: 'db_password',
        label: 'Database Password',
        type: 'password',
        required: true
      },
      {
        name: 'auth_secret',
        label: 'Auth Secret',
        type: 'password',
        required: true
      }
    ]
  },
  {
    id: 'syncthing',
    name: 'Syncthing',
    description: 'Continuous file synchronization',
    category: 'backup-storage',
    logo: RefreshCw,
    deploymentModes: ['traefik'],
    configFields: [
      {
        name: 'domain',
        label: 'Domain',
        type: 'text',
        required: true,
        placeholder: 'example.com'
      },
      {
        name: 'data_path',
        label: 'Data Path',
        type: 'text',
        required: true,
        placeholder: '/path/to/data'
      }
    ]
  },
  {
    id: 'paperless',
    name: 'Paperless-ngx',
    description: 'Document management system',
    category: 'backup-storage',
    logo: FileText,
    deploymentModes: ['traefik'],
    configFields: [
      {
        name: 'domain',
        label: 'Domain',
        type: 'text',
        required: true,
        placeholder: 'example.com'
      },
      {
        name: 'secret_key',
        label: 'Secret Key',
        type: 'password',
        required: true
      },
      {
        name: 'admin_user',
        label: 'Admin Username',
        type: 'text',
        required: true
      },
      {
        name: 'admin_password',
        label: 'Admin Password',
        type: 'password',
        required: true
      }
    ]
  },
  {
    id: 'immich',
    name: 'Immich',
    description: 'Self-hosted photo and video backup solution',
    category: 'backup-storage',
    logo: Image,
    deploymentModes: ['traefik'],
    configFields: [
      {
        name: 'domain',
        label: 'Domain',
        type: 'text',
        required: true,
        placeholder: 'example.com'
      },
      {
        name: 'db_password',
        label: 'Database Password',
        type: 'password',
        required: true
      }
    ]
  },

  // Automation
  {
    id: 'notifiarr',
    name: 'Notifiarr',
    description: 'Notification and request management',
    category: 'home-automation',
    logo: Bell,
    deploymentModes: ['traefik'],
    configFields: [
      {
        name: 'domain',
        label: 'Domain',
        type: 'text',
        required: true,
        placeholder: 'example.com'
      },
      {
        name: 'api_key',
        label: 'API Key',
        type: 'password',
        required: true
      }
    ]
  },
  {
    id: 'sonarr',
    name: 'Sonarr',
    description: 'TV series management',
    category: 'home-automation',
    logo: Rss,
    deploymentModes: ['traefik'],
    defaultPorts: {
      web: 8989
    },
    requiredPorts: ['web'],
    configFields: [
      {
        name: 'domain',
        label: 'Domain',
        type: 'text',
        required: true,
        placeholder: 'example.com'
      },
      {
        name: 'tv_path',
        label: 'TV Shows Path',
        type: 'text',
        required: true,
        placeholder: '/path/to/tv'
      },
      {
        name: 'downloads_path',
        label: 'Downloads Path',
        type: 'text',
        required: true,
        placeholder: '/path/to/downloads'
      }
    ]
  },
  {
    id: 'radarr',
    name: 'Radarr',
    description: 'Movie collection manager',
    category: 'home-automation',
    logo: BookOpenCheck,
    deploymentModes: ['traefik'],
    defaultPorts: {
      web: 7878
    },
    requiredPorts: ['web'],
    configFields: [
      {
        name: 'domain',
        label: 'Domain',
        type: 'text',
        required: true,
        placeholder: 'example.com'
      },
      {
        name: 'movies_path',
        label: 'Movies Path',
        type: 'text',
        required: true,
        placeholder: '/path/to/movies'
      },
      {
        name: 'downloads_path',
        label: 'Downloads Path',
        type: 'text',
        required: true,
        placeholder: '/path/to/downloads'
      }
    ]
  },
  {
    id: 'prowlarr',
    name: 'Prowlarr',
    description: 'Indexer manager/proxy',
    category: 'home-automation',
    logo: FileSearch,
    deploymentModes: ['traefik'],
    defaultPorts: {
      web: 9696
    },
    requiredPorts: ['web'],
    configFields: [
      {
        name: 'domain',
        label: 'Domain',
        type: 'text',
        required: true,
        placeholder: 'example.com'
      },
      {
        name: 'config_path',
        label: 'Config Path',
        type: 'text',
        required: true,
        placeholder: '/path/to/prowlarr/config'
      }
    ]
  },
  {
    id: 'autoscan',
    name: 'Autoscan',
    description: 'Media file system events monitor',
    category: 'home-automation',
    logo: Scan,
    deploymentModes: ['traefik'],
    configFields: [
      {
        name: 'domain',
        label: 'Domain',
        type: 'text',
        required: true,
        placeholder: 'example.com'
      },
      {
        name: 'config_path',
        label: 'Config Path',
        type: 'text',
        required: true,
        placeholder: '/path/to/autoscan/config'
      },
      {
        name: 'plex_url',
        label: 'Plex URL',
        type: 'text',
        required: true,
        placeholder: 'http://plex:32400'
      },
      {
        name: 'plex_token',
        label: 'Plex Token',
        type: 'password',
        required: true
      }
    ]
  },
  {
    id: 'bazarr',
    name: 'Bazarr',
    description: 'Subtitle management for Sonarr and Radarr',
    category: 'home-automation',
    logo: Subtitles,
    deploymentModes: ['traefik'],
    defaultPorts: {
      web: 6767
    },
    requiredPorts: ['web'],
    configFields: [
      {
        name: 'domain',
        label: 'Domain',
        type: 'text',
        required: true,
        placeholder: 'example.com'
      },
      {
        name: 'movies_path',
        label: 'Movies Path',
        type: 'text',
        required: true,
        placeholder: '/path/to/movies'
      },
      {
        name: 'tv_path',
        label: 'TV Shows Path',
        type: 'text',
        required: true,
        placeholder: '/path/to/tv'
      }
    ]
  },
  {
    id: 'lidarr',
    name: 'Lidarr',
    description: 'Music collection manager',
    category: 'home-automation',
    logo: Music,
    deploymentModes: ['traefik'],
    defaultPorts: {
      web: 8686
    },
    requiredPorts: ['web'],
    configFields: [
      {
        name: 'domain',
        label: 'Domain',
        type: 'text',
        required: true,
        placeholder: 'example.com'
      },
      {
        name: 'music_path',
        label: 'Music Path',
        type: 'text',
        required: true,
        placeholder: '/path/to/music'
      },
      {
        name: 'downloads_path',
        label: 'Downloads Path',
        type: 'text',
        required: true,
        placeholder: '/path/to/downloads'
      }
    ]
  },
  {
    id: 'readarr',
    name: 'Readarr',
    description: 'Book collection manager',
    category: 'home-automation',
    logo: Book,
    deploymentModes: ['traefik'],
    defaultPorts: {
      web: 8787
    },
    requiredPorts: ['web'],
    configFields: [
      {
        name: 'domain',
        label: 'Domain',
        type: 'text',
        required: true,
        placeholder: 'example.com'
      },
      {
        name: 'books_path',
        label: 'Books Path',
        type: 'text',
        required: true,
        placeholder: '/path/to/books'
      },
      {
        name: 'downloads_path',
        label: 'Downloads Path',
        type: 'text',
        required: true,
        placeholder: '/path/to/downloads'
      }
    ]
  },
  {
    id: 'whisparr',
    name: 'Whisparr',
    description: 'Adult content collection manager',
    category: 'home-automation',
    logo: Eye,
    deploymentModes: ['traefik'],
    defaultPorts: {
      web: 6969
    },
    requiredPorts: ['web'],
    configFields: [
      {
        name: 'domain',
        label: 'Domain',
        type: 'text',
        required: true,
        placeholder: 'example.com'
      },
      {
        name: 'adult_path',
        label: 'Adult Content Path',
        type: 'text',
        required: true,
        placeholder: '/path/to/adult'
      },
      {
        name: 'downloads_path',
        label: 'Downloads Path',
        type: 'text',
        required: true,
        placeholder: '/path/to/downloads'
      }
    ]
  },
  {
    id: 'flaresolverr',
    name: 'FlareSolverr',
    description: 'Proxy server to bypass Cloudflare protection',
    category: 'downloads',
    logo: Shield,
    deploymentModes: ['traefik'],
    defaultPorts: {
      web: 8191
    },
    requiredPorts: ['web'],
    configFields: [
      {
        name: 'log_level',
        label: 'Log Level',
        type: 'select',
        required: false,
        defaultValue: 'info',
        options: ['debug', 'info', 'warning', 'error']
      },
      {
        name: 'log_html',
        label: 'Log HTML',
        type: 'select',
        required: false,
        defaultValue: 'false',
        options: ['true', 'false']
      },
      {
        name: 'captcha_solver',
        label: 'Captcha Solver',
        type: 'select',
        required: false,
        defaultValue: 'none',
        options: ['none', '2captcha', 'anticaptcha']
      }
    ]
  },
  {
    id: 'jackett',
    name: 'Jackett',
    description: 'API support for torrent trackers',
    category: 'downloads',
    logo: Search,
    deploymentModes: ['traefik'],
    defaultPorts: {
      web: 9117
    },
    requiredPorts: ['web'],
    configFields: [
      {
        name: 'domain',
        label: 'Domain',
        type: 'text',
        required: true,
        placeholder: 'example.com'
      },
      {
        name: 'downloads_path',
        label: 'Downloads Path',
        type: 'text',
        required: true,
        placeholder: '/path/to/downloads'
      }
    ]
  },
  {
    id: 'sabnzbd',
    name: 'SABnzbd',
    description: 'Binary newsreader for Usenet',
    category: 'downloads',
    logo: Download,
    deploymentModes: ['traefik'],
    defaultPorts: {
      web: 8080
    },
    requiredPorts: ['web'],
    configFields: [
      {
        name: 'domain',
        label: 'Domain',
        type: 'text',
        required: true,
        placeholder: 'example.com'
      },
      {
        name: 'downloads_path',
        label: 'Downloads Path',
        type: 'text',
        required: true,
        placeholder: '/path/to/downloads'
      },
      {
        name: 'incomplete_path',
        label: 'Incomplete Downloads Path',
        type: 'text',
        required: true,
        placeholder: '/path/to/incomplete'
      }
    ]
  },
  {
    id: 'transmission',
    name: 'Transmission',
    description: 'Fast, easy, and free BitTorrent client',
    category: 'downloads',
    logo: Download,
    deploymentModes: ['traefik'],
    defaultPorts: {
      web: 9091,
      tcp: 51413,
      udp: 51413
    },
    requiredPorts: ['web', 'tcp', 'udp'],
    configFields: [
      {
        name: 'domain',
        label: 'Domain',
        type: 'text',
        required: true,
        placeholder: 'example.com'
      },
      {
        name: 'transmission_user',
        label: 'Username',
        type: 'text',
        required: false,
        defaultValue: 'admin'
      },
      {
        name: 'transmission_password',
        label: 'Password',
        type: 'password',
        required: true
      },
      {
        name: 'downloads_path',
        label: 'Downloads Path',
        type: 'text',
        required: true,
        placeholder: '/path/to/downloads'
      },
      {
        name: 'watch_path',
        label: 'Watch Path',
        type: 'text',
        required: true,
        placeholder: '/path/to/watch'
      }
    ]
  },
  {
    id: 'deluge',
    name: 'Deluge',
    description: 'Lightweight BitTorrent client',
    category: 'downloads',
    logo: Download,
    deploymentModes: ['traefik'],
    defaultPorts: {
      web: 8112,
      tcp: 6881,
      udp: 6881,
      daemon: 58846
    },
    requiredPorts: ['web', 'tcp', 'udp', 'daemon'],
    configFields: [
      {
        name: 'domain',
        label: 'Domain',
        type: 'text',
        required: true,
        placeholder: 'example.com'
      },
      {
        name: 'downloads_path',
        label: 'Downloads Path',
        type: 'text',
        required: true,
        placeholder: '/path/to/downloads'
      }
    ]
  },
  {
    id: 'rutorrent',
    name: 'ruTorrent',
    description: 'Popular rtorrent client with web interface',
    category: 'downloads',
    logo: Download,
    deploymentModes: ['traefik'],
    defaultPorts: {
      web: 80,
      scgi: 5000,
      tcp: 51413,
      udp: 6881
    },
    requiredPorts: ['web', 'scgi', 'tcp', 'udp'],
    configFields: [
      {
        name: 'domain',
        label: 'Domain',
        type: 'text',
        required: true,
        placeholder: 'example.com'
      },
      {
        name: 'downloads_path',
        label: 'Downloads Path',
        type: 'text',
        required: true,
        placeholder: '/path/to/downloads'
      }
    ]
  },
  {
    id: 'ombi',
    name: 'Ombi',
    description: 'Request management and media discovery',
    category: 'media',
    logo: MessageSquarePlus,
    deploymentModes: ['traefik'],
    defaultPorts: {
      web: 3579
    },
    requiredPorts: ['web'],
    configFields: [
      {
        name: 'domain',
        label: 'Domain',
        type: 'text',
        required: true,
        placeholder: 'example.com'
      }
    ]
  },
  {
    id: 'requestrr',
    name: 'Requestrr',
    description: 'Discord bot for media requests',
    category: 'media',
    logo: MessageSquarePlus,
    deploymentModes: ['traefik'],
    defaultPorts: {
      web: 4545
    },
    requiredPorts: ['web'],
    configFields: [
      {
        name: 'domain',
        label: 'Domain',
        type: 'text',
        required: true,
        placeholder: 'example.com'
      }
    ]
  },
  {
    id: 'organizr',
    name: 'Organizr',
    description: 'HTPC/Homelab services organizer',
    category: 'system-utilities',
    logo: LayoutDashboard,
    deploymentModes: ['traefik'],
    defaultPorts: {
      web: 80
    },
    requiredPorts: ['web'],
    configFields: [
      {
        name: 'domain',
        label: 'Domain',
        type: 'text',
        required: true,
        placeholder: 'example.com'
      }
    ]
  },
  {
    id: 'homarr',
    name: 'Homarr',
    description: 'Customizable browser homepage',
    category: 'system-utilities',
    logo: Home,
    deploymentModes: ['traefik'],
    defaultPorts: {
      web: 7575
    },
    requiredPorts: ['web'],
    configFields: [
      {
        name: 'domain',
        label: 'Domain',
        type: 'text',
        required: true,
        placeholder: 'example.com'
      }
    ]
  },
  {
    id: 'dashy',
    name: 'Dashy',
    description: 'Feature-rich homepage for your homelab',
    category: 'system-utilities',
    logo: LayoutDashboard,
    deploymentModes: ['traefik'],
    defaultPorts: {
      web: 4000
    },
    requiredPorts: ['web'],
    configFields: [
      {
        name: 'domain',
        label: 'Domain',
        type: 'text',
        required: true,
        placeholder: 'example.com'
      }
    ]
  },
  {
    id: 'flame',
    name: 'Flame',
    description: 'Self-hosted startpage for your server',
    category: 'system-utilities',
    logo: Home,
    deploymentModes: ['traefik'],
    defaultPorts: {
      web: 5005
    },
    requiredPorts: ['web'],
    configFields: [
      {
        name: 'domain',
        label: 'Domain',
        type: 'text',
        required: true,
        placeholder: 'example.com'
      },
      {
        name: 'admin_password',
        label: 'Admin Password',
        type: 'password',
        required: true
      }
    ]
  },
  {
    id: 'homer',
    name: 'Homer',
    description: 'Static homepage for your server',
    category: 'system-utilities',
    logo: Home,
    deploymentModes: ['traefik'],
    defaultPorts: {
      web: 8080
    },
    requiredPorts: ['web'],
    configFields: [
      {
        name: 'domain',
        label: 'Domain',
        type: 'text',
        required: true,
        placeholder: 'example.com'
      }
    ]
  },
  {
    id: 'watchtower',
    name: 'Watchtower',
    description: 'Automatic Docker container updates',
    category: 'home-automation',
    logo: Zap,
    deploymentModes: ['traefik'],
    configFields: [
      {
        name: 'poll_interval',
        label: 'Poll Interval (seconds)',
        type: 'number',
        required: false,
        defaultValue: '86400',
        placeholder: '86400'
      },
      {
        name: 'notifications',
        label: 'Notification Type',
        type: 'select',
        required: false,
        defaultValue: 'shoutrrr',
        options: ['shoutrrr', 'email', 'slack', 'gotify']
      },
      {
        name: 'notification_url',
        label: 'Notification URL',
        type: 'text',
        required: false,
        placeholder: 'discord://token@id'
      }
    ]
  },
  {
    id: 'diun',
    name: 'Diun',
    description: 'Docker image update notifier',
    category: 'home-automation',
    logo: Bell,
    deploymentModes: ['traefik'],
    configFields: [
      {
        name: 'domain',
        label: 'Domain',
        type: 'text',
        required: true,
        placeholder: 'example.com'
      }
    ]
  },
  {
    id: 'prometheus',
    name: 'Prometheus',
    description: 'Monitoring system and time series database',
    category: 'monitoring',
    logo: BarChart2,
    deploymentModes: ['traefik'],
    defaultPorts: {
      web: 9090
    },
    requiredPorts: ['web'],
    configFields: [
      {
        name: 'domain',
        label: 'Domain',
        type: 'text',
        required: true,
        placeholder: 'example.com'
      }
    ]
  },
  {
    id: 'node-exporter',
    name: 'Node Exporter',
    description: 'Prometheus exporter for hardware and OS metrics',
    category: 'monitoring',
    logo: Server,
    deploymentModes: ['traefik'],
    defaultPorts: {
      web: 9100
    },
    requiredPorts: ['web'],
    configFields: [
      {
        name: 'domain',
        label: 'Domain',
        type: 'text',
        required: true,
        placeholder: 'example.com'
      }
    ]
  },
  {
    id: 'cadvisor',
    name: 'cAdvisor',
    description: 'Container resource usage and performance analysis',
    category: 'monitoring',
    logo: ContainerIcon,
    deploymentModes: ['traefik'],
    defaultPorts: {
      web: 8080
    },
    requiredPorts: ['web'],
    configFields: [
      {
        name: 'domain',
        label: 'Domain',
        type: 'text',
        required: true,
        placeholder: 'example.com'
      }
    ]
  },
  {
    id: 'loki',
    name: 'Loki',
    description: 'Log aggregation system',
    category: 'monitoring',
    logo: ScrollText,
    deploymentModes: ['traefik'],
    defaultPorts: {
      web: 3100
    },
    requiredPorts: ['web'],
    configFields: [
      {
        name: 'domain',
        label: 'Domain',
        type: 'text',
        required: true,
        placeholder: 'example.com'
      }
    ]
  },
  {
    id: 'promtail',
    name: 'Promtail',
    description: 'Log shipping agent for Loki',
    category: 'monitoring',
    logo: ScrollText,
    deploymentModes: ['traefik'],
    configFields: [
      {
        name: 'domain',
        label: 'Domain',
        type: 'text',
        required: true,
        placeholder: 'example.com'
      }
    ]
  },
  {
    id: 'alertmanager',
    name: 'Alertmanager',
    description: 'Alert handling for Prometheus',
    category: 'monitoring',
    logo: Bell,
    deploymentModes: ['traefik'],
    defaultPorts: {
      web: 9093
    },
    requiredPorts: ['web'],
    configFields: [
      {
        name: 'domain',
        label: 'Domain',
        type: 'text',
        required: true,
        placeholder: 'example.com'
      }
    ]
  },
  {
    id: 'speedtest-tracker',
    name: 'Speedtest Tracker',
    description: 'Internet speed test tracker',
    category: 'monitoring',
    logo: Zap,
    deploymentModes: ['traefik'],
    defaultPorts: {
      web: 80,
      websecure: 443
    },
    requiredPorts: ['web', 'websecure'],
    configFields: [
      {
        name: 'domain',
        label: 'Domain',
        type: 'text',
        required: true,
        placeholder: 'example.com'
      },
      {
        name: 'app_key',
        label: 'Application Key',
        type: 'password',
        required: true
      }
    ]
  },
  {
    id: 'librespeed',
    name: 'LibreSpeed',
    description: 'Self-hosted speedtest service',
    category: 'monitoring',
    logo: Zap,
    deploymentModes: ['traefik'],
    defaultPorts: {
      web: 80
    },
    requiredPorts: ['web'],
    configFields: [
      {
        name: 'domain',
        label: 'Domain',
        type: 'text',
        required: true,
        placeholder: 'example.com'
      },
      {
        name: 'admin_password',
        label: 'Admin Password',
        type: 'password',
        required: true
      }
    ]
  },
  {
    id: 'pihole',
    name: 'Pi-hole',
    description: 'Network-wide ad blocking',
    category: 'system-utilities',
    logo: Shield,
    deploymentModes: ['traefik'],
    defaultPorts: {
      dns_tcp: 53,
      dns_udp: 53,
      web: 80
    },
    requiredPorts: ['dns_tcp', 'dns_udp', 'web'],
    configFields: [
      {
        name: 'domain',
        label: 'Domain',
        type: 'text',
        required: true,
        placeholder: 'example.com'
      },
      {
        name: 'admin_password',
        label: 'Admin Password',
        type: 'password',
        required: true
      }
    ]
  },
  {
    id: 'adguard',
    name: 'AdGuard Home',
    description: 'Network-wide software for blocking ads',
    category: 'system-utilities',
    logo: Shield,
    deploymentModes: ['traefik'],
    defaultPorts: {
      dns_tcp: 53,
      dns_udp: 53,
      web: 3000,
      dns_tls: 853,
      dns_quic: 784,
      dns_https: 8853,
      dnscrypt_tcp: 5443,
      dnscrypt_udp: 5443
    },
    requiredPorts: ['dns_tcp', 'dns_udp', 'web'],
    configFields: [
      {
        name: 'domain',
        label: 'Domain',
        type: 'text',
        required: true,
        placeholder: 'example.com'
      }
    ]
  },
  {
    id: 'unbound',
    name: 'Unbound',
    description: 'Recursive DNS resolver',
    category: 'system-utilities',
    logo: Globe,
    deploymentModes: ['traefik'],
    defaultPorts: {
      dns_tcp: 5053,
      dns_udp: 5053
    },
    requiredPorts: ['dns_tcp', 'dns_udp'],
    configFields: [
      {
        name: 'domain',
        label: 'Domain',
        type: 'text',
        required: true,
        placeholder: 'example.com'
      }
    ]
  },
  {
    id: 'wireguard',
    name: 'WireGuard',
    description: 'Modern VPN tunnel',
    category: 'system-utilities',
    logo: Wifi,
    deploymentModes: ['traefik'],
    defaultPorts: {
      vpn: 51820
    },
    requiredPorts: ['vpn'],
    configFields: [
      {
        name: 'server_url',
        label: 'Server URL',
        type: 'text',
        required: true,
        placeholder: 'vpn.example.com'
      },
      {
        name: 'server_port',
        label: 'Server Port',
        type: 'number',
        required: false,
        defaultValue: '51820'
      },
      {
        name: 'peers',
        label: 'Number of Peers',
        type: 'number',
        required: false,
        defaultValue: '10'
      }
    ]
  },
  {
    id: 'openvpn',
    name: 'OpenVPN',
    description: 'Open source VPN solution',
    category: 'system-utilities',
    logo: Wifi,
    deploymentModes: ['traefik'],
    defaultPorts: {
      vpn: 1194
    },
    requiredPorts: ['vpn'],
    configFields: [
      {
        name: 'domain',
        label: 'Domain',
        type: 'text',
        required: true,
        placeholder: 'example.com'
      }
    ]
  },
  {
    id: 'code-server',
    name: 'Code Server',
    description: 'VS Code in the browser',
    category: 'development',
    logo: Code2,
    deploymentModes: ['traefik'],
    defaultPorts: {
      web: 8443
    },
    requiredPorts: ['web'],
    configFields: [
      {
        name: 'domain',
        label: 'Domain',
        type: 'text',
        required: true,
        placeholder: 'example.com'
      },
      {
        name: 'admin_password',
        label: 'Password',
        type: 'password',
        required: true
      },
      {
        name: 'workspace_path',
        label: 'Workspace Path',
        type: 'text',
        required: true,
        placeholder: '/path/to/workspace'
      }
    ]
  },
  {
    id: 'filebrowser',
    name: 'File Browser',
    description: 'Web file manager',
    category: 'backup-storage',
    logo: Files,
    deploymentModes: ['traefik'],
    defaultPorts: {
      web: 80
    },
    requiredPorts: ['web'],
    configFields: [
      {
        name: 'domain',
        label: 'Domain',
        type: 'text',
        required: true,
        placeholder: 'example.com'
      },
      {
        name: 'files_path',
        label: 'Files Path',
        type: 'text',
        required: true,
        placeholder: '/path/to/files'
      }
    ]
  },
  {
    id: 'duplicati',
    name: 'Duplicati',
    description: 'Backup client with encryption',
    category: 'backup-storage',
    logo: Archive,
    deploymentModes: ['traefik'],
    defaultPorts: {
      web: 8200
    },
    requiredPorts: ['web'],
    configFields: [
      {
        name: 'domain',
        label: 'Domain',
        type: 'text',
        required: true,
        placeholder: 'example.com'
      },
      {
        name: 'backups_path',
        label: 'Backups Path',
        type: 'text',
        required: true,
        placeholder: '/path/to/backups'
      },
      {
        name: 'source_path',
        label: 'Source Path',
        type: 'text',
        required: true,
        placeholder: '/path/to/source'
      }
    ]
  },
  {
    id: 'restic',
    name: 'Restic',
    description: 'Fast, secure backup program',
    category: 'backup-storage',
    logo: Archive,
    deploymentModes: ['traefik'],
    configFields: [
      {
        name: 'repository_path',
        label: 'Repository Path',
        type: 'text',
        required: true,
        placeholder: '/path/to/repository'
      },
      {
        name: 'repository_password',
        label: 'Repository Password',
        type: 'password',
        required: true
      },
      {
        name: 'backup_source',
        label: 'Backup Source Path',
        type: 'text',
        required: true,
        placeholder: '/path/to/data'
      }
    ]
  },
  {
    id: 'mysql',
    name: 'MySQL',
    description: 'Popular relational database',
    category: 'development',
    logo: Database,
    deploymentModes: ['traefik'],
    defaultPorts: {
      db: 3306
    },
    requiredPorts: ['db'],
    configFields: [
      {
        name: 'root_password',
        label: 'Root Password',
        type: 'password',
        required: true
      },
      {
        name: 'database_name',
        label: 'Database Name',
        type: 'text',
        required: false,
        defaultValue: 'homelab'
      },
      {
        name: 'mysql_user',
        label: 'MySQL User',
        type: 'text',
        required: false,
        defaultValue: 'user'
      },
      {
        name: 'mysql_password',
        label: 'MySQL Password',
        type: 'password',
        required: true
      }
    ]
  },
  {
    id: 'mariadb',
    name: 'MariaDB',
    description: 'Open source relational database',
    category: 'development',
    logo: Database,
    deploymentModes: ['traefik'],
    defaultPorts: {
      db: 3306
    },
    requiredPorts: ['db'],
    configFields: [
      {
        name: 'root_password',
        label: 'Root Password',
        type: 'password',
        required: true
      },
      {
        name: 'database_name',
        label: 'Database Name',
        type: 'text',
        required: false,
        defaultValue: 'homelab'
      },
      {
        name: 'mysql_user',
        label: 'MySQL User',
        type: 'text',
        required: false,
        defaultValue: 'user'
      },
      {
        name: 'mysql_password',
        label: 'MySQL Password',
        type: 'password',
        required: true
      }
    ]
  },
  {
    id: 'redis',
    name: 'Redis',
    description: 'In-memory data structure store',
    category: 'development',
    logo: Database,
    deploymentModes: ['traefik'],
    defaultPorts: {
      db: 6379
    },
    requiredPorts: ['db'],
    configFields: [
      {
        name: 'redis_password',
        label: 'Redis Password',
        type: 'password',
        required: true
      }
    ]
  },
  {
    id: 'mongodb',
    name: 'MongoDB',
    description: 'Document-oriented database',
    category: 'development',
    logo: Database,
    deploymentModes: ['traefik'],
    defaultPorts: {
      db: 27017
    },
    requiredPorts: ['db'],
    configFields: [
      {
        name: 'mongo_user',
        label: 'MongoDB User',
        type: 'text',
        required: false,
        defaultValue: 'admin'
      },
      {
        name: 'mongo_password',
        label: 'MongoDB Password',
        type: 'password',
        required: true
      }
    ]
  },
  {
    id: 'influxdb',
    name: 'InfluxDB',
    description: 'Time series database',
    category: 'development',
    logo: Database,
    deploymentModes: ['traefik'],
    defaultPorts: {
      db: 8086
    },
    requiredPorts: ['db'],
    configFields: [
      {
        name: 'influx_user',
        label: 'InfluxDB User',
        type: 'text',
        required: false,
        defaultValue: 'admin'
      },
      {
        name: 'influx_password',
        label: 'InfluxDB Password',
        type: 'password',
        required: true
      },
      {
        name: 'influx_org',
        label: 'Organization',
        type: 'text',
        required: false,
        defaultValue: 'homelab'
      },
      {
        name: 'influx_bucket',
        label: 'Default Bucket',
        type: 'text',
        required: false,
        defaultValue: 'default'
      },
      {
        name: 'influx_token',
        label: 'Admin Token',
        type: 'password',
        required: true
      }
    ]
  },

  // Productivity
  {
    id: 'nextcloud',
    name: 'Nextcloud',
    description: 'Self-hosted productivity platform with files, calendar, and more',
    category: 'web-productivity',
    logo: Calendar,
    deploymentModes: ['traefik'],
    defaultPorts: {
      web: 80,
      websecure: 443
    },
    requiredPorts: ['web', 'websecure'],
    configFields: [
      {
        name: 'domain',
        label: 'Domain',
        type: 'text',
        required: true,
        placeholder: 'example.com'
      },
      {
        name: 'admin_user',
        label: 'Admin Username',
        type: 'text',
        required: true
      },
      {
        name: 'admin_password',
        label: 'Admin Password',
        type: 'password',
        required: true
      },
      {
        name: 'data_path',
        label: 'Data Path',
        type: 'text',
        required: true,
        placeholder: '/path/to/data'
      }
    ]
  },
  {
    id: 'joplin',
    name: 'Joplin Server',
    description: 'Your self-hosted note-taking and to-do application',
    category: 'web-productivity',
    logo: NotebookPen,
    deploymentModes: ['traefik'],
    configFields: [
      {
        name: 'domain',
        label: 'Domain',
        type: 'text',
        required: true,
        placeholder: 'example.com'
      },
      {
        name: 'admin_password',
        label: 'Admin Password',
        type: 'password',
        required: true
      }
    ]
  },

  // Communication
  {
    id: 'mailcow',
    name: 'Mailcow',
    description: 'Complete email server solution with antispam and webmail',
    category: 'web-productivity',
    logo: Mail,
    deploymentModes: ['traefik'],
    defaultPorts: {
      web: 443,
      smtp: 25,
      smtps: 465,
      submission: 587,
      imaps: 993
    },
    requiredPorts: ['web', 'smtp', 'smtps', 'submission', 'imaps'],
    configFields: [
      {
        name: 'domain',
        label: 'Domain',
        type: 'text',
        required: true,
        placeholder: 'example.com'
      },
      {
        name: 'admin_password',
        label: 'Admin Password',
        type: 'password',
        required: true
      }
    ]
  },
  {
    id: 'rocketchat',
    name: 'Rocket.Chat',
    description: 'Team chat solution with video conferencing and file sharing',
    category: 'web-productivity',
    logo: MessageCircle,
    deploymentModes: ['traefik'],
    defaultPorts: {
      web: 3000
    },
    requiredPorts: ['web'],
    configFields: [
      {
        name: 'domain',
        label: 'Domain',
        type: 'text',
        required: true,
        placeholder: 'example.com'
      },
      {
        name: 'admin_email',
        label: 'Admin Email',
        type: 'text',
        required: true
      },
      {
        name: 'admin_password',
        label: 'Admin Password',
        type: 'password',
        required: true
      }
    ]
  },
  {
    id: 'mattermost',
    name: 'Mattermost',
    description: 'Open source platform for secure collaboration',
    category: 'web-productivity',
    logo: Users,
    deploymentModes: ['traefik'],
    defaultPorts: {
      web: 8065
    },
    requiredPorts: ['web'],
    configFields: [
      {
        name: 'domain',
        label: 'Domain',
        type: 'text',
        required: true,
        placeholder: 'example.com'
      },
      {
        name: 'admin_password',
        label: 'Admin Password',
        type: 'password',
        required: true
      }
    ]
  },
  {
    id: 'matrix',
    name: 'Matrix Synapse',
    description: 'Decentralized communication server',
    category: 'web-productivity',
    logo: Webhook,
    deploymentModes: ['traefik'],
    defaultPorts: {
      web: 8008,
      federation: 8448
    },
    requiredPorts: ['web', 'federation'],
    configFields: [
      {
        name: 'domain',
        label: 'Domain',
        type: 'text',
        required: true,
        placeholder: 'example.com'
      },
      {
        name: 'admin_password',
        label: 'Admin Password',
        type: 'password',
        required: true
      }
    ]
  },
  {
    id: 'homelabarr-mount-enhanced',
    name: 'Enhanced Cloud Mount',
    description: 'Multi-provider cloud storage with cost tracking and modern interface',
    category: 'backup-storage',
    logo: Cloud,
    deploymentModes: ['traefik'],
    defaultPorts: {
      web: 8080,
      metrics: 9090
    },
    requiredPorts: ['web'],
    configFields: [
      {
        name: 'multi_provider',
        label: 'Enable Multi-Provider Support',
        type: 'select',
        options: ['true', 'false'],
        defaultValue: 'true',
        required: false
      },
      {
        name: 'cost_tracking',
        label: 'Enable Cost Tracking',
        type: 'select',
        options: ['true', 'false'],
        defaultValue: 'true',
        required: false
      },
      // Major Cloud Providers
      {
        name: 'gdrive_enabled',
        label: 'Google Drive',
        type: 'select',
        options: ['true', 'false'],
        defaultValue: 'true',
        required: false
      },
      {
        name: 'onedrive_enabled',
        label: 'Microsoft OneDrive',
        type: 'select',
        options: ['true', 'false'],
        defaultValue: 'false',
        required: false
      },
      {
        name: 'dropbox_enabled',
        label: 'Dropbox',
        type: 'select',
        options: ['true', 'false'],
        defaultValue: 'false',
        required: false
      },
      {
        name: 'box_enabled',
        label: 'Box',
        type: 'select',
        options: ['true', 'false'],
        defaultValue: 'false',
        required: false
      },
      {
        name: 'pcloud_enabled',
        label: 'pCloud',
        type: 'select',
        options: ['true', 'false'],
        defaultValue: 'false',
        required: false
      },
      {
        name: 'mega_enabled',
        label: 'MEGA',
        type: 'select',
        options: ['true', 'false'],
        defaultValue: 'false',
        required: false
      },
      // Enterprise Cloud Providers
      {
        name: 'amazon_s3_enabled',
        label: 'Amazon S3',
        type: 'select',
        options: ['true', 'false'],
        defaultValue: 'false',
        required: false
      },
      {
        name: 'google_cloud_enabled',
        label: 'Google Cloud Storage',
        type: 'select',
        options: ['true', 'false'],
        defaultValue: 'false',
        required: false
      },
      {
        name: 'azure_blob_enabled',
        label: 'Azure Blob Storage',
        type: 'select',
        options: ['true', 'false'],
        defaultValue: 'false',
        required: false
      },
      {
        name: 'backblaze_enabled',
        label: 'Backblaze B2',
        type: 'select',
        options: ['true', 'false'],
        defaultValue: 'false',
        required: false
      },
      // Additional Popular Providers
      {
        name: 'yandex_enabled',
        label: 'Yandex Disk',
        type: 'select',
        options: ['true', 'false'],
        defaultValue: 'false',
        required: false
      },
      {
        name: 'jottacloud_enabled',
        label: 'Jottacloud',
        type: 'select',
        options: ['true', 'false'],
        defaultValue: 'false',
        required: false
      },
      {
        name: 'koofr_enabled',
        label: 'Koofr',
        type: 'select',
        options: ['true', 'false'],
        defaultValue: 'false',
        required: false
      },
      {
        name: 'seafile_enabled',
        label: 'Seafile',
        type: 'select',
        options: ['true', 'false'],
        defaultValue: 'false',
        required: false
      },
      // Protocol-based Providers
      {
        name: 'webdav_enabled',
        label: 'WebDAV',
        type: 'select',
        options: ['true', 'false'],
        defaultValue: 'false',
        required: false
      },
      {
        name: 'sftp_enabled',
        label: 'SFTP',
        type: 'select',
        options: ['true', 'false'],
        defaultValue: 'false',
        required: false
      },
      {
        name: 'ftp_enabled',
        label: 'FTP',
        type: 'select',
        options: ['true', 'false'],
        defaultValue: 'false',
        required: false
      },
      {
        name: 'upload_concurrency',
        label: 'Upload Concurrency',
        type: 'number',
        defaultValue: '4',
        placeholder: '1-8 concurrent uploads',
        required: false
      },
      {
        name: 'vfs_cache_mode',
        label: 'VFS Cache Mode',
        type: 'select',
        options: [
          'minimal',
          'writes',
          'full'
        ],
        defaultValue: 'writes',
        required: false
      },
      {
        name: 'vfs_cache_size',
        label: 'VFS Cache Size',
        type: 'text',
        defaultValue: '100GB',
        placeholder: 'e.g., 100GB, 500MB',
        required: false
      },
      {
        name: 'cost_limit_monthly',
        label: 'Monthly Budget (USD)',
        type: 'number',
        defaultValue: '50',
        placeholder: 'Monthly spending limit',
        required: false
      },
      {
        name: 'provider_selection',
        label: 'Provider Selection Strategy',
        type: 'select',
        options: [
          'auto',
          'cheapest',
          'fastest',
          'balanced'
        ],
        defaultValue: 'auto',
        required: false
      },
      {
        name: 'config_path',
        label: 'Configuration Path',
        type: 'text',
        defaultValue: './mount-enhanced-config',
        placeholder: 'Local config directory',
        required: false
      },
      {
        name: 'unionfs_path',
        label: 'Union Mount Path',
        type: 'text',
        defaultValue: './mount-enhanced-unionfs',
        placeholder: 'Local unionfs directory',
        required: false
      }
    ]
  }
];
