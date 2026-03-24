import { AppTemplate, CLIApplication } from "../types";
import { Shield, Network, Monitor } from "lucide-react";
import { Card, CardHeader, CardTitle, CardDescription, CardContent, CardFooter } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";

interface AppCardProps {
  app: AppTemplate;
  onDeploy: (app: AppTemplate) => void;
}

export function AppCard({ app, onDeploy }: AppCardProps) {
  const Icon = app.logo;
  const cliApp = (app as any)._cliApp as CLIApplication | undefined;

  return (
    <Card className="group relative overflow-hidden transition-all duration-300 hover:shadow-2xl hover:shadow-indigo-500/10 dark:hover:shadow-indigo-500/20 hover:translate-y-[-3px] flex flex-col h-full border-0 ring-1 ring-gray-200 dark:ring-white/[0.08] hover:ring-indigo-400/50 dark:hover:ring-indigo-500/40 bg-white dark:bg-[hsl(222,28%,10%)]">
      {/* Category accent stripe */}
      <div className="absolute top-0 left-0 right-0 h-1 bg-gradient-to-r from-indigo-500 via-blue-500 to-purple-500 opacity-60 group-hover:opacity-100 transition-opacity" />

      <CardHeader className="flex flex-row items-center gap-4 pt-5 pb-3">
        <div className="p-3 bg-gradient-to-br from-indigo-50 to-blue-50 dark:from-indigo-900/30 dark:to-blue-900/20 rounded-xl ring-1 ring-indigo-100 dark:ring-indigo-800/30 transition-all duration-300 group-hover:scale-110 group-hover:shadow-lg group-hover:shadow-indigo-500/20">
          <Icon className="w-7 h-7 text-indigo-600 dark:text-indigo-400" />
        </div>
        <div className="min-w-0 flex-1">
          <CardTitle className="text-base font-semibold truncate">{app.name}</CardTitle>
          {cliApp && (
            <CardDescription className="truncate text-xs mt-0.5">
              {cliApp.image.split(":")[0]}
            </CardDescription>
          )}
        </div>
      </CardHeader>

      <CardContent className="flex-grow pb-3">
        <p className="text-sm text-muted-foreground leading-relaxed line-clamp-2 mb-4">
          {app.description}
        </p>
        <div className="flex flex-wrap gap-1.5">
          {cliApp?.requiresTraefik && (
            <Badge className="bg-emerald-100 text-emerald-700 dark:bg-emerald-900/40 dark:text-emerald-300 border-emerald-200 dark:border-emerald-800/50" variant="outline">
              <Network className="w-3 h-3 mr-1" />
              Traefik
            </Badge>
          )}
          {cliApp?.requiresAuthelia && (
            <Badge className="bg-purple-100 text-purple-700 dark:bg-purple-900/40 dark:text-purple-300 border-purple-200 dark:border-purple-800/50" variant="outline">
              <Shield className="w-3 h-3 mr-1" />
              Auth
            </Badge>
          )}
          {!cliApp && app.deploymentModes && app.deploymentModes.map(mode => {
            const styles: Record<string, string> = {
              traefik: "bg-emerald-100 text-emerald-700 dark:bg-emerald-900/40 dark:text-emerald-300 border-emerald-200 dark:border-emerald-800/50",
              authelia: "bg-purple-100 text-purple-700 dark:bg-purple-900/40 dark:text-purple-300 border-purple-200 dark:border-purple-800/50",
              local: "bg-sky-100 text-sky-700 dark:bg-sky-900/40 dark:text-sky-300 border-sky-200 dark:border-sky-800/50",
            };
            const icons: Record<string, typeof Network> = { traefik: Network, authelia: Shield, local: Monitor };
            const labels: Record<string, string> = { traefik: "Traefik", authelia: "Authelia", local: "Local" };
            const ModeIcon = icons[mode] || Monitor;
            return (
              <Badge key={mode} variant="outline" className={styles[mode] || ""}>
                <ModeIcon className="w-3 h-3 mr-1" />
                {labels[mode] || mode}
              </Badge>
            );
          })}
          <Badge variant="secondary" className="capitalize text-xs">
            {cliApp?.category || app.category}
          </Badge>
        </div>
      </CardContent>

      <CardFooter className="pt-0 pb-4">
        <Button
          onClick={() => onDeploy(app)}
          className="w-full bg-gradient-to-r from-indigo-500 to-blue-600 hover:from-indigo-600 hover:to-blue-700 text-white font-medium shadow-md shadow-indigo-500/20 hover:shadow-lg hover:shadow-indigo-500/30 transition-all duration-200"
          size="default"
        >
          Deploy
        </Button>
      </CardFooter>
    </Card>
  );
}
