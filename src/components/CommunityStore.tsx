import { useState, useMemo } from "react";
import { Card, CardHeader, CardTitle, CardDescription, CardContent, CardFooter } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Search, Download, ExternalLink, User } from "lucide-react";
import { CommunityApp } from "../types";

interface CommunityStoreProps {
  apps: CommunityApp[];
  categories: string[];
  onInstall: (app: CommunityApp) => void;
  loading?: boolean;
}

const CATEGORY_MAP: Record<string, string> = {
  "AI:": "AI",
  "Backup:": "Backup",
  "Downloaders:": "Downloads",
  "MediaApp:Video": "Media Apps",
  "MediaApp:Music": "Media Apps",
  "MediaApp:Books": "Media Apps",
  "MediaApp:Photos": "Media Apps",
  "MediaApp:Other": "Media Apps",
  "MediaServer:Video": "Media Servers",
  "MediaServer:Music": "Media Servers",
  "MediaServer:Books": "Media Servers",
  "MediaServer:Other": "Media Servers",
  "Network:VPN": "Networking",
  "Network:DNS": "Networking",
  "Network:Web": "Networking",
  "Network:Proxy": "Networking",
  "Network:Management": "Networking",
  "Network:Other": "Networking",
  "Network:Messenger": "Networking",
  "Tools:Utilities": "Tools",
  "Tools:Profitability": "Tools",
  "Productivity:": "Productivity",
  "GameServers:": "Game Servers",
  "HomeAutomation:": "Home Automation",
  "Cloud:": "Cloud",
  "Security:": "Security",
  "Status:": "Status",
  "Other:": "Other",
};

function cleanCategory(raw: string): string {
  if (CATEGORY_MAP[raw]) return CATEGORY_MAP[raw];

  for (const [pattern, label] of Object.entries(CATEGORY_MAP)) {
    if (raw.startsWith(pattern)) return label;
  }

  const parent = raw.split(":")[0];
  return parent || raw;
}

function getAuthor(repo: string): string {
  const parts = repo.replace(/^https?:\/\//, "").split("/");
  if (parts.length >= 2) return parts[parts.length - 2];
  return repo;
}

export function CommunityStore({ apps, categories: _categories, onInstall, loading = false }: CommunityStoreProps) {
  const [searchQuery, setSearchQuery] = useState("");
  const [activeCategory, setActiveCategory] = useState<string | null>(null);
  const [sortBy, setSortBy] = useState<"name" | "newest">("name");
  const [currentPage, setCurrentPage] = useState(1);
  const perPage = 12;

  const cleanedCategories = useMemo(() => {
    const counts: Record<string, number> = {};
    for (const app of apps) {
      const seen = new Set<string>();
      for (const raw of app.CategoryList) {
        const clean = cleanCategory(raw);
        if (!seen.has(clean)) {
          seen.add(clean);
          counts[clean] = (counts[clean] || 0) + 1;
        }
      }
    }
    return Object.entries(counts).sort((a, b) => b[1] - a[1]);
  }, [apps]);

  const filteredApps = useMemo(() => {
    const q = searchQuery.toLowerCase();

    let result = apps.filter((app) => {
      if (activeCategory) {
        const appCategories = app.CategoryList.map(cleanCategory);
        if (!appCategories.includes(activeCategory)) return false;
      }
      if (q) {
        return (
          app.Name.toLowerCase().includes(q) ||
          app.Overview.toLowerCase().includes(q) ||
          app.Repo.toLowerCase().includes(q)
        );
      }
      return true;
    });

    result.sort((a, b) => {
      if (sortBy === "newest") return b.FirstSeen - a.FirstSeen;
      return a.Name.localeCompare(b.Name);
    });

    return result;
  }, [apps, searchQuery, activeCategory, sortBy]);

  const totalPages = Math.max(1, Math.ceil(filteredApps.length / perPage));
  const safeCurrentPage = Math.min(currentPage, totalPages);
  const paginatedApps = filteredApps.slice(
    (safeCurrentPage - 1) * perPage,
    safeCurrentPage * perPage
  );

  function handleCategoryClick(category: string) {
    setActiveCategory((prev) => (prev === category ? null : category));
    setCurrentPage(1);
  }

  function handleSearch(value: string) {
    setSearchQuery(value);
    setCurrentPage(1);
  }

  if (loading) {
    return (
      <div className="flex items-center justify-center py-24">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-indigo-500" />
        <span className="ml-3 text-muted-foreground">Loading community apps...</span>
      </div>
    );
  }

  return (
    <div className="flex gap-6 min-h-[600px]">
      {/* Category sidebar */}
      <aside className="w-56 shrink-0 hidden lg:block">
        <h3 className="text-sm font-semibold text-muted-foreground uppercase tracking-wide mb-3">
          Categories
        </h3>
        <div className="space-y-0.5">
          <button
            onClick={() => { setActiveCategory(null); setCurrentPage(1); }}
            className={`w-full text-left px-3 py-1.5 rounded-md text-sm transition-colors ${
              activeCategory === null
                ? "bg-indigo-500/20 text-indigo-300 font-medium"
                : "text-muted-foreground hover:text-foreground hover:bg-white/5"
            }`}
          >
            All Apps
            <span className="float-right text-xs opacity-60">{apps.length}</span>
          </button>
          {cleanedCategories.map(([category, count]) => (
            <button
              key={category}
              onClick={() => handleCategoryClick(category)}
              className={`w-full text-left px-3 py-1.5 rounded-md text-sm transition-colors ${
                activeCategory === category
                  ? "bg-indigo-500/20 text-indigo-300 font-medium"
                  : "text-muted-foreground hover:text-foreground hover:bg-white/5"
              }`}
            >
              {category}
              <span className="float-right text-xs opacity-60">{count}</span>
            </button>
          ))}
        </div>
      </aside>

      {/* Main content */}
      <div className="flex-1 min-w-0">
        {/* Top bar */}
        <div className="flex flex-col sm:flex-row gap-3 mb-6">
          <div className="relative flex-1">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
            <Input
              placeholder="Search community apps..."
              value={searchQuery}
              onChange={(e) => handleSearch(e.target.value)}
              className="pl-9"
            />
          </div>
          <select
            value={sortBy}
            onChange={(e) => setSortBy(e.target.value as "name" | "newest")}
            className="h-9 rounded-md border border-input bg-background px-3 text-sm ring-offset-background focus:outline-none focus:ring-2 focus:ring-ring"
          >
            <option value="name">Sort: A-Z</option>
            <option value="newest">Sort: Newest</option>
          </select>
          <span className="text-sm text-muted-foreground self-center whitespace-nowrap">
            {filteredApps.length} apps
          </span>
        </div>

        {/* Mobile category bar */}
        <div className="flex gap-2 overflow-x-auto pb-3 mb-4 lg:hidden scrollbar-none">
          <Badge
            onClick={() => { setActiveCategory(null); setCurrentPage(1); }}
            className={`cursor-pointer shrink-0 ${
              activeCategory === null
                ? "bg-indigo-500 text-white"
                : "bg-white/5 text-muted-foreground hover:text-foreground"
            }`}
            variant="outline"
          >
            All
          </Badge>
          {cleanedCategories.slice(0, 12).map(([category]) => (
            <Badge
              key={category}
              onClick={() => handleCategoryClick(category)}
              className={`cursor-pointer shrink-0 ${
                activeCategory === category
                  ? "bg-indigo-500 text-white"
                  : "bg-white/5 text-muted-foreground hover:text-foreground"
              }`}
              variant="outline"
            >
              {category}
            </Badge>
          ))}
        </div>

        {/* App grid */}
        {paginatedApps.length === 0 ? (
          <div className="text-center py-16 text-muted-foreground">
            <Search className="w-10 h-10 mx-auto mb-3 opacity-30" />
            <p className="text-lg">No apps found</p>
            <p className="text-sm mt-1">Try a different search or category</p>
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4">
            {paginatedApps.map((app) => (
              <CommunityAppCard key={app.Name + app.Repository} app={app} onInstall={onInstall} />
            ))}
          </div>
        )}

        {/* Pagination */}
        {totalPages > 1 && (
          <div className="flex items-center justify-center gap-2 mt-8">
            <Button
              variant="outline"
              size="sm"
              disabled={safeCurrentPage <= 1}
              onClick={() => setCurrentPage((p) => Math.max(1, p - 1))}
            >
              Previous
            </Button>
            {generatePageNumbers(safeCurrentPage, totalPages).map((page, i) =>
              page === null ? (
                <span key={`ellipsis-${i}`} className="px-1 text-muted-foreground">...</span>
              ) : (
                <Button
                  key={page}
                  variant={page === safeCurrentPage ? "default" : "outline"}
                  size="sm"
                  className={page === safeCurrentPage ? "bg-indigo-500 hover:bg-indigo-600" : ""}
                  onClick={() => setCurrentPage(page)}
                >
                  {page}
                </Button>
              )
            )}
            <Button
              variant="outline"
              size="sm"
              disabled={safeCurrentPage >= totalPages}
              onClick={() => setCurrentPage((p) => Math.min(totalPages, p + 1))}
            >
              Next
            </Button>
          </div>
        )}
      </div>
    </div>
  );
}

function CommunityAppCard({ app, onInstall }: { app: CommunityApp; onInstall: (app: CommunityApp) => void }) {
  const author = getAuthor(app.Repo);
  const displayCategories = [...new Set(app.CategoryList.map(cleanCategory))].slice(0, 3);

  return (
    <Card className="group relative overflow-hidden transition-all duration-300 hover:shadow-2xl hover:shadow-indigo-500/10 dark:hover:shadow-indigo-500/20 hover:translate-y-[-3px] flex flex-col h-full border-0 ring-1 ring-gray-200 dark:ring-white/[0.08] hover:ring-indigo-400/50 dark:hover:ring-indigo-500/40 bg-white dark:bg-[hsl(222,28%,10%)]">
      <div className="absolute top-0 left-0 right-0 h-1 bg-gradient-to-r from-orange-500 via-amber-500 to-yellow-500 opacity-60 group-hover:opacity-100 transition-opacity" />

      <CardHeader className="flex flex-row items-center gap-3 pt-5 pb-2">
        <div className="w-12 h-12 shrink-0 rounded-xl ring-1 ring-orange-200 dark:ring-orange-800/30 bg-gradient-to-br from-orange-50 to-amber-50 dark:from-orange-900/20 dark:to-amber-900/10 flex items-center justify-center overflow-hidden transition-all duration-300 group-hover:scale-110 group-hover:shadow-lg group-hover:shadow-orange-500/20">
          {app.Icon ? (
            <img
              src={app.Icon}
              alt={app.Name}
              className="w-8 h-8 object-contain"
              loading="lazy"
              onError={(e) => {
                const target = e.currentTarget;
                target.style.display = "none";
                const letter = document.createElement("span");
                letter.className = "w-8 h-8 flex items-center justify-center rounded-md bg-orange-500/20 text-orange-300 text-sm font-bold";
                letter.textContent = (app.Name || "?")[0].toUpperCase();
                target.parentElement?.appendChild(letter);
              }}
            />
          ) : (
            <span className="text-lg font-bold text-orange-400">
              {(app.Name || "?")[0].toUpperCase()}
            </span>
          )}
        </div>
        <div className="min-w-0 flex-1">
          <CardTitle className="text-base font-semibold truncate">{app.Name}</CardTitle>
          <CardDescription className="truncate text-xs mt-0.5 flex items-center gap-1">
            <User className="w-3 h-3" />
            {author}
          </CardDescription>
        </div>
      </CardHeader>

      <CardContent className="flex-grow pb-3">
        <p className="text-sm text-muted-foreground leading-relaxed line-clamp-2 mb-3">
          {app.Overview || "No description available."}
        </p>
        <div className="flex flex-wrap gap-1.5">
          {displayCategories.map((cat) => (
            <Badge
              key={cat}
              variant="outline"
              className="text-xs bg-indigo-50 text-indigo-600 dark:bg-indigo-900/30 dark:text-indigo-300 border-indigo-200 dark:border-indigo-800/40"
            >
              {cat}
            </Badge>
          ))}
          <Badge
            variant="outline"
            className="text-xs bg-orange-50 text-orange-600 dark:bg-orange-900/30 dark:text-orange-300 border-orange-200 dark:border-orange-800/40"
          >
            Unraid Community
          </Badge>
        </div>
      </CardContent>

      <CardFooter className="pt-0 pb-4 gap-2">
        <Button
          onClick={() => onInstall(app)}
          className="flex-1 bg-gradient-to-r from-indigo-500 to-blue-600 hover:from-indigo-600 hover:to-blue-700 text-white font-medium shadow-md shadow-indigo-500/20 hover:shadow-lg hover:shadow-indigo-500/30 transition-all duration-200"
          size="default"
        >
          <Download className="w-4 h-4 mr-2" />
          Install
        </Button>
        {app.Project && (
          <Button
            variant="outline"
            size="icon"
            asChild
            className="shrink-0"
          >
            <a href={app.Project} target="_blank" rel="noopener noreferrer">
              <ExternalLink className="w-4 h-4" />
            </a>
          </Button>
        )}
      </CardFooter>
    </Card>
  );
}

function generatePageNumbers(current: number, total: number): (number | null)[] {
  if (total <= 7) return Array.from({ length: total }, (_, i) => i + 1);

  const pages: (number | null)[] = [1];

  if (current > 3) pages.push(null);

  const start = Math.max(2, current - 1);
  const end = Math.min(total - 1, current + 1);

  for (let i = start; i <= end; i++) pages.push(i);

  if (current < total - 2) pages.push(null);

  pages.push(total);

  return pages;
}
