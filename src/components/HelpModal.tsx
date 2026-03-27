import {
  HelpCircle, Rocket, Layout, Shield, PlayCircle, Terminal,
  RefreshCw, Trash2, BarChart3, BookOpen,
  ExternalLink, Zap, Server, Film, Download, HardDrive,
  Activity, Code, Globe, FolderOpen, Monitor
} from "lucide-react";
import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/components/ui/dialog";
import { ScrollArea } from "@/components/ui/scroll-area";
import { Badge } from "@/components/ui/badge";

interface HelpModalProps {
  isOpen: boolean;
  onClose: () => void;
}

const categories = [
  { name: "Self-hosted", icon: Globe, count: 37, desc: "Dashboards, wikis, bookmarks, and utilities", color: "text-emerald-500 dark:text-emerald-400" },
  { name: "Media Management", icon: Film, count: 16, desc: "Sonarr, Radarr, Bazarr, Lidarr, Overseerr", color: "text-blue-500 dark:text-blue-400" },
  { name: "Downloads", icon: Download, count: 14, desc: "Torrent and Usenet clients", color: "text-red-500 dark:text-red-400" },
  { name: "AI & Machine Learning", icon: Zap, count: 14, desc: "Ollama, ComfyUI, Stable Diffusion, and more", color: "text-rose-500 dark:text-rose-400" },
  { name: "System", icon: Monitor, count: 13, desc: "Traefik, Portainer, Watchtower, and more", color: "text-gray-500 dark:text-gray-400" },
  { name: "Virtual Desktops", icon: Layout, count: 10, desc: "Browser-based desktop environments via Kasm", color: "text-indigo-500 dark:text-indigo-400" },
  { name: "Monitoring", icon: Activity, count: 6, desc: "Uptime Kuma, Netdata, Grafana, and alerting", color: "text-green-500 dark:text-green-400" },
  { name: "Transcoding", icon: Code, count: 5, desc: "Tdarr, Handbrake, MakeMKV, Unmanic", color: "text-yellow-500 dark:text-yellow-400" },
  { name: "Media Servers", icon: Server, count: 5, desc: "Plex, Jellyfin, Emby", color: "text-orange-500 dark:text-orange-400" },
  { name: "Backup", icon: HardDrive, count: 3, desc: "Duplicati, Restic, Rsnapshot", color: "text-amber-500 dark:text-amber-400" },
];

const actions = [
  { icon: PlayCircle, label: "Start / Stop", desc: "Toggle containers on or off", color: "text-green-500" },
  { icon: RefreshCw, label: "Restart", desc: "Restart a running container", color: "text-blue-500" },
  { icon: Terminal, label: "Logs", desc: "View real-time container logs", color: "text-purple-500" },
  { icon: BarChart3, label: "Stats", desc: "Monitor CPU, memory, and network", color: "text-orange-500" },
  { icon: Trash2, label: "Remove", desc: "Stop and remove a container", color: "text-red-500" },
];

export function HelpModal({ isOpen, onClose }: HelpModalProps) {
  return (
    <Dialog open={isOpen} onOpenChange={(open) => { if (!open) onClose(); }}>
      <DialogContent className="max-w-2xl h-[85vh] flex flex-col p-0">
        <DialogHeader className="px-6 pt-6 pb-4 border-b border-border">
          <DialogTitle className="flex items-center gap-2 text-xl">
            <HelpCircle className="w-6 h-6 text-blue-600 dark:text-blue-400" />
            Help & Documentation
          </DialogTitle>
          <p className="text-sm text-muted-foreground mt-1">
            Everything you need to manage your self-hosted Docker stack.
          </p>
        </DialogHeader>

        <ScrollArea className="flex-1">
          <div className="px-6 py-5 space-y-8">

            {/* Quick Start */}
            <section>
              <div className="flex items-center gap-2 mb-3">
                <Rocket className="w-5 h-5 text-indigo-500" />
                <h3 className="font-semibold text-base">Quick Start</h3>
              </div>
              <div className="grid gap-2">
                {["Browse apps by category or search by name",
                  "Click Deploy on any application",
                  "Configure ports, volumes, and environment variables",
                  "Hit Deploy — your container is live"
                ].map((step, i) => (
                  <div key={i} className="flex items-start gap-3 p-2.5 rounded-lg bg-muted/50 dark:bg-white/[0.03]">
                    <span className="flex-shrink-0 w-6 h-6 rounded-full bg-indigo-100 dark:bg-indigo-900/40 text-indigo-600 dark:text-indigo-400 text-xs font-bold flex items-center justify-center">
                      {i + 1}
                    </span>
                    <span className="text-sm text-foreground">{step}</span>
                  </div>
                ))}
              </div>
            </section>

            {/* Managing Containers */}
            <section>
              <div className="flex items-center gap-2 mb-3">
                <Layout className="w-5 h-5 text-emerald-500" />
                <h3 className="font-semibold text-base">Managing Containers</h3>
              </div>
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-2">
                {actions.map((a) => (
                  <div key={a.label} className="flex items-center gap-3 p-2.5 rounded-lg bg-muted/50 dark:bg-white/[0.03] border border-transparent dark:border-white/[0.04]">
                    <a.icon className={`w-4 h-4 flex-shrink-0 ${a.color}`} />
                    <div>
                      <span className="text-sm font-medium">{a.label}</span>
                      <p className="text-xs text-muted-foreground">{a.desc}</p>
                    </div>
                  </div>
                ))}
              </div>
            </section>

            {/* App Categories */}
            <section>
              <div className="flex items-center justify-between mb-3">
                <div className="flex items-center gap-2">
                  <FolderOpen className="w-5 h-5 text-amber-500" />
                  <h3 className="font-semibold text-base">App Categories</h3>
                </div>
                <Badge variant="outline" className="text-xs">
                  123 apps
                </Badge>
              </div>
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-2">
                {categories.map((cat) => (
                  <div key={cat.name} className="flex items-center gap-3 p-2.5 rounded-lg bg-muted/50 dark:bg-white/[0.03] border border-transparent dark:border-white/[0.04]">
                    <cat.icon className={`w-4 h-4 flex-shrink-0 ${cat.color}`} />
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center justify-between">
                        <span className="text-sm font-medium">{cat.name}</span>
                        <span className="text-xs text-muted-foreground ml-2">{cat.count}</span>
                      </div>
                      <p className="text-xs text-muted-foreground truncate">{cat.desc}</p>
                    </div>
                  </div>
                ))}
              </div>
            </section>

            {/* Troubleshooting */}
            <section>
              <div className="flex items-center gap-2 mb-3">
                <Shield className="w-5 h-5 text-red-500" />
                <h3 className="font-semibold text-base">Troubleshooting</h3>
              </div>
              <div className="space-y-2">
                {[
                  { q: "Container won't start", a: "Check the Logs tab for error messages. Common causes: port conflicts, missing volumes, or incorrect environment variables." },
                  { q: "Can't access via domain", a: "Verify Traefik labels are correct and DNS points to your server. Check Traefik dashboard for routing errors." },
                  { q: "Permission denied errors", a: "Ensure PUID/PGID match your host user. Check volume mount permissions with ls -la." },
                ].map((item) => (
                  <div key={item.q} className="p-3 rounded-lg bg-muted/50 dark:bg-white/[0.03] border border-transparent dark:border-white/[0.04]">
                    <p className="text-sm font-medium text-foreground">{item.q}</p>
                    <p className="text-xs text-muted-foreground mt-1">{item.a}</p>
                  </div>
                ))}
              </div>
            </section>

            {/* Links */}
            <section className="pb-2">
              <div className="flex items-center gap-2 mb-3">
                <BookOpen className="w-5 h-5 text-blue-500" />
                <h3 className="font-semibold text-base">Resources</h3>
              </div>
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-2">
                {[
                  { label: "Wiki & Docs", href: "https://wiki.homelabarr.com", desc: "Full documentation" },
                  { label: "GitHub", href: "https://github.com/smashingtags/homelabarr-ce", desc: "Source code & issues" },
                  { label: "Discord Community", href: "https://discord.gg/Pc7mXX786x", desc: "Get help & chat" },
                  { label: "Reddit", href: "https://reddit.com/r/homelabarr", desc: "r/homelabarr" },
                ].map((link) => (
                  <a
                    key={link.label}
                    href={link.href}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="flex items-center gap-3 p-2.5 rounded-lg bg-muted/50 dark:bg-white/[0.03] border border-transparent dark:border-white/[0.04] hover:border-indigo-400/50 dark:hover:border-indigo-500/30 transition-colors group"
                  >
                    <ExternalLink className="w-4 h-4 text-muted-foreground group-hover:text-indigo-500 transition-colors flex-shrink-0" />
                    <div>
                      <span className="text-sm font-medium group-hover:text-indigo-500 dark:group-hover:text-indigo-400 transition-colors">{link.label}</span>
                      <p className="text-xs text-muted-foreground">{link.desc}</p>
                    </div>
                  </a>
                ))}
              </div>
            </section>

            {/* Credit */}            <div className="pt-4 mt-4 border-t border-border/40 dark:border-white/[0.06] text-center">              <p className="text-xs text-muted-foreground">                HomelabARR is built and maintained by{" "}                <a href="https://imogenlabs.ai" target="_blank" rel="noopener noreferrer" className="font-medium text-indigo-600 dark:text-indigo-400 underline decoration-indigo-400/50 hover:decoration-indigo-500 transition-colors">Imogen Labs AI</a>                {" "}· © 2026              </p>            </div>
          </div>
        </ScrollArea>
      </DialogContent>
    </Dialog>
  );
}
