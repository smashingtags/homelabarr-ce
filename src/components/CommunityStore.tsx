import { useState, useEffect, useCallback } from "react";
import { Card, CardHeader, CardTitle, CardDescription, CardContent, CardFooter } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Search, ExternalLink, RefreshCw, Loader2 } from "lucide-react";
import { CommunityApp } from "../types";
import { getCommunityApps, getCommunityCategories } from "../lib/api";

interface CommunityStoreProps {
  onInstall: (app: CommunityApp) => void;
  onRefresh?: () => void;
  refreshing?: boolean;
}

const CATEGORY_MAP: Record<string, string> = {
  "AI:": "AI",
  "Backup:": "Backup",
  "Cloud:": "Cloud",
  "Crypto Currency": "Crypto",
  "Downloaders:": "Downloads",
  "Drivers:": "Drivers",
  "Game Servers": "Games",
  "Home Automation": "Home Auto",
  "Media Applications": "Media Apps",
  "Media Servers": "Media Servers",
  "Network Services": "Networking",
  "Other:": "Other",
  "Productivity:": "Productivity",
  "Security:": "Security",
  "Tools / Utilities": "Tools",
};

function cleanCategory(raw: string): string {
  if (CATEGORY_MAP[raw]) return CATEGORY_MAP[raw];
  const parts = raw.replace(/:$/, "").split(":");
  return parts[parts.length - 1] || raw;
}

function getAuthor(repo: string): string {
  if (!repo) return "Unknown";
  const parts = repo.split("'");
  if (parts.length >= 2) return parts[0].trim();
  return repo;
}

export function CommunityStore({ onInstall, onRefresh, refreshing = false }: CommunityStoreProps) {
  const [apps, setApps] = useState<CommunityApp[]>([]);
  const [categories, setCategories] = useState<string[]>([]);
  const [total, setTotal] = useState(0);
  const [loading, setLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState("");
  const [activeCategory, setActiveCategory] = useState<string | null>(null);
  const [sortBy, setSortBy] = useState<"name" | "newest" | "downloads" | "trending">("name");
  const [currentPage, setCurrentPage] = useState(1);
  const perPage = 12;

  const fetchApps = useCallback(async () => {
    setLoading(true);
    try {
      const data = await getCommunityApps({
        search: searchQuery || undefined,
        category: activeCategory || undefined,
        sort: sortBy,
        page: currentPage,
        perPage,
      });
      setApps(data.apps || []);
      setTotal(data.total || 0);
    } catch {
      setApps([]);
      setTotal(0);
    } finally {
      setLoading(false);
    }
  }, [searchQuery, activeCategory, sortBy, currentPage]);

  useEffect(() => {
    fetchApps();
  }, [fetchApps]);

  useEffect(() => {
    getCommunityCategories()
      .then(data => setCategories(data.categories || []))
      .catch(() => {});
  }, []);

  const totalPages = Math.max(1, Math.ceil(total / perPage));

  function handleCategoryClick(category: string) {
    setActiveCategory(prev => prev === category ? null : category);
    setCurrentPage(1);
  }

  function handleSearch(value: string) {
    setSearchQuery(value);
    setCurrentPage(1);
  }

  let searchTimer: ReturnType<typeof setTimeout>;
  function handleSearchDebounced(value: string) {
    clearTimeout(searchTimer);
    searchTimer = setTimeout(() => handleSearch(value), 300);
  }

  return (
    <div className="flex gap-6">
      {/* Category sidebar — desktop */}
      <div className="hidden lg:block w-48 shrink-0">
        <h3 className="text-sm font-semibold mb-3 text-muted-foreground uppercase tracking-wider">Categories</h3>
        <div className="space-y-1">
          {categories.map(cat => (
            <button
              key={cat}
              onClick={() => handleCategoryClick(cat)}
              className={`block w-full text-left text-sm px-2 py-1.5 rounded transition-colors ${
                activeCategory === cat
                  ? "bg-orange-500/20 text-orange-300 font-medium"
                  : "text-zinc-400 hover:text-zinc-200 hover:bg-white/5"
              }`}
            >
              {cleanCategory(cat)}
            </button>
          ))}
        </div>
      </div>

      {/* Main content */}
      <div className="flex-1 min-w-0">
        {/* Top bar */}
        <div className="flex flex-col sm:flex-row gap-3 mb-6">
          <div className="relative flex-1">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
            <Input
              placeholder="Search community apps..."
              defaultValue={searchQuery}
              onChange={(e) => handleSearchDebounced(e.target.value)}
              className="pl-9"
            />
          </div>
          <select
            value={sortBy}
            onChange={(e) => { setSortBy(e.target.value as typeof sortBy); setCurrentPage(1); }}
            className="h-9 rounded-md border border-input bg-background px-3 text-sm ring-offset-background focus:outline-none focus:ring-2 focus:ring-ring"
          >
            <option value="name">Sort: A-Z</option>
            <option value="newest">Sort: Newest</option>
            <option value="downloads">Sort: Downloads</option>
            <option value="trending">Sort: Trending</option>
          </select>
          <span className="text-sm text-muted-foreground self-center whitespace-nowrap">
            {total.toLocaleString()} apps
          </span>
          {onRefresh && (
            <Button variant="outline" size="sm" onClick={onRefresh} disabled={refreshing} className="whitespace-nowrap">
              <RefreshCw className={`w-4 h-4 mr-1 ${refreshing ? 'animate-spin' : ''}`} />
              {refreshing ? 'Refreshing...' : 'Refresh'}
            </Button>
          )}
        </div>

        {/* Mobile category bar */}
        <div className="flex gap-2 overflow-x-auto pb-3 mb-4 lg:hidden scrollbar-none">
          {categories.slice(0, 10).map(cat => (
            <Badge
              key={cat}
              variant={activeCategory === cat ? "default" : "outline"}
              className={`cursor-pointer whitespace-nowrap ${
                activeCategory === cat ? "bg-orange-500 text-white" : ""
              }`}
              onClick={() => handleCategoryClick(cat)}
            >
              {cleanCategory(cat)}
            </Badge>
          ))}
        </div>

        {/* Loading */}
        {loading ? (
          <div className="flex items-center justify-center py-24">
            <Loader2 className="w-8 h-8 animate-spin text-muted-foreground" />
          </div>
        ) : apps.length === 0 ? (
          <div className="text-center py-16 text-muted-foreground">
            <Search className="w-10 h-10 mx-auto mb-3 opacity-30" />
            <p className="text-lg">No apps found</p>
            <p className="text-sm mt-1">Try a different search or category</p>
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4">
            {apps.map((app) => (
              <CommunityAppCard key={app.Name + app.Repository} app={app} onInstall={onInstall} />
            ))}
          </div>
        )}

        {/* Pagination */}
        {totalPages > 1 && !loading && (
          <div className="flex items-center justify-center gap-2 mt-8">
            <Button variant="outline" size="sm" disabled={currentPage <= 1} onClick={() => setCurrentPage(p => p - 1)}>
              Previous
            </Button>
            <span className="text-sm text-muted-foreground">
              Page {currentPage} of {totalPages}
            </span>
            <Button variant="outline" size="sm" disabled={currentPage >= totalPages} onClick={() => setCurrentPage(p => p + 1)}>
              Next
            </Button>
          </div>
        )}

        {/* Credits */}
        <div className="mt-8 pt-6 border-t border-white/10 text-center text-xs text-zinc-500">
          <p>
            Community app data provided by the{' '}
            <a href="https://github.com/Squidly271/AppFeed" className="text-indigo-400 hover:underline" target="_blank" rel="noopener noreferrer">
              Unraid Community Applications
            </a>{' '}
            project, maintained by{' '}
            <a href="https://github.com/Squidly271" className="text-indigo-400 hover:underline" target="_blank" rel="noopener noreferrer">
              Squidly271
            </a>{' '}
            and the Unraid community. Docker images are provided by their respective authors.
          </p>
        </div>
      </div>
    </div>
  );
}

function CommunityAppCard({ app, onInstall }: { app: CommunityApp; onInstall: (app: CommunityApp) => void }) {
  const author = getAuthor(app.Repo);
  const displayCategories = [...new Set((Array.isArray(app.CategoryList) ? app.CategoryList : []).map(cleanCategory))].slice(0, 3);

  return (
    <Card className="group relative overflow-hidden transition-all duration-300 hover:shadow-2xl hover:shadow-orange-500/10 dark:hover:shadow-orange-500/20 hover:translate-y-[-3px] flex flex-col h-full border-0 ring-1 ring-gray-200 dark:ring-white/[0.08] hover:ring-orange-400/50 dark:hover:ring-orange-500/40 bg-white dark:bg-[hsl(222,28%,10%)]">
      <div className="absolute top-0 left-0 right-0 h-1 bg-gradient-to-r from-orange-500 via-amber-500 to-yellow-500 opacity-60 group-hover:opacity-100 transition-opacity" />

      <CardHeader className="flex flex-row items-center gap-4 pt-5 pb-3">
        <div className="p-2 bg-gradient-to-br from-orange-50 to-amber-50 dark:from-orange-900/30 dark:to-amber-900/20 rounded-xl ring-1 ring-orange-100 dark:ring-orange-800/30 w-12 h-12 flex items-center justify-center overflow-hidden">
          {app.Icon ? (
            <img
              src={app.Icon}
              alt={app.Name}
              className="w-8 h-8 object-contain"
              onError={(e) => {
                e.currentTarget.style.display = "none";
                const letter = document.createElement("span");
                letter.className = "text-orange-400 font-bold text-lg";
                letter.textContent = (app.Name || "?")[0].toUpperCase();
                e.currentTarget.parentElement?.appendChild(letter);
              }}
            />
          ) : (
            <span className="text-orange-400 font-bold text-lg">{(app.Name || "?")[0].toUpperCase()}</span>
          )}
        </div>
        <div className="min-w-0 flex-1">
          <CardTitle className="text-base font-semibold truncate">{app.Name}</CardTitle>
          <CardDescription className="truncate text-xs mt-0.5">by {author}</CardDescription>
        </div>
      </CardHeader>

      <CardContent className="flex-grow pb-3">
        <p className="text-sm text-muted-foreground leading-relaxed line-clamp-2 mb-4">
          {app.Overview || "Docker application"}
        </p>
        <div className="flex flex-wrap gap-1.5">
          <Badge className="bg-orange-100 text-orange-700 dark:bg-orange-900/40 dark:text-orange-300 border-orange-200 dark:border-orange-800/50" variant="outline">
            Community
          </Badge>
          {displayCategories.map(cat => (
            <Badge key={cat} variant="outline" className="text-xs capitalize">
              {cat}
            </Badge>
          ))}
          {app.downloads ? (
            <Badge variant="outline" className="text-xs">
              {app.downloads >= 1000000 ? `${(app.downloads / 1000000).toFixed(1)}M` : app.downloads >= 1000 ? `${(app.downloads / 1000).toFixed(0)}K` : app.downloads} pulls
            </Badge>
          ) : null}
        </div>
      </CardContent>

      <CardFooter className="pt-0 pb-4 gap-2">
        <Button
          onClick={() => onInstall(app)}
          className="flex-1 bg-gradient-to-r from-orange-500 to-amber-600 hover:from-orange-600 hover:to-amber-700 text-white font-medium shadow-md shadow-orange-500/20 hover:shadow-lg hover:shadow-orange-500/30 transition-all duration-200"
          size="default"
        >
          Install
        </Button>
        {app.Project && (
          <Button variant="outline" size="icon" asChild>
            <a href={app.Project} target="_blank" rel="noopener noreferrer">
              <ExternalLink className="w-4 h-4" />
            </a>
          </Button>
        )}
      </CardFooter>
    </Card>
  );
}
