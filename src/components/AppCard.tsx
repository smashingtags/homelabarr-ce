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

  const deploymentModeInfo: Record<string, { icon: typeof Network; label: string }> = {
    traefik: { icon: Network, label: "Traefik" },
    authelia: { icon: Shield, label: "Authelia" },
    local: { icon: Monitor, label: "Local" },
  };

  return (
    <Card className="group hover:shadow-xl hover:shadow-indigo-500/10 transition-all duration-200 border-t-2 border-t-indigo-500/60 hover:translate-y-[-2px] flex flex-col h-full">
      <CardHeader className="flex flex-row items-center gap-3">
        <div className="p-2 bg-indigo-50 dark:bg-indigo-900/20 rounded-lg transition-transform duration-200 group-hover:scale-110">
          <Icon className="w-6 h-6 text-indigo-600 dark:text-indigo-400" />
        </div>
        <div className="min-w-0 flex-1">
          <CardTitle className="text-sm truncate">{app.name}</CardTitle>
          {cliApp && (
            <CardDescription className="truncate">
              {cliApp.image.split(":")[0]}
            </CardDescription>
          )}
        </div>
      </CardHeader>

      <CardContent className="flex-grow">
        <p className="text-sm text-muted-foreground leading-relaxed line-clamp-2 mb-3">
          {app.description}
        </p>
        <div className="flex flex-wrap gap-1.5">
          {cliApp?.requiresTraefik && (
            <Badge variant="secondary">Traefik</Badge>
          )}
          {cliApp?.requiresAuthelia && (
            <Badge variant="secondary">Auth</Badge>
          )}
          {!cliApp && app.deploymentModes && app.deploymentModes.map(mode => {
            const modeInfo = deploymentModeInfo[mode];
            if (!modeInfo) return null;
            const ModeIcon = modeInfo.icon;
            return (
              <Badge variant="secondary" key={mode}>
                <ModeIcon className="w-3 h-3 mr-1" />
                {modeInfo.label}
              </Badge>
            );
          })}
          <Badge variant="outline" className="capitalize">
            {cliApp?.category || app.category}
          </Badge>
        </div>
      </CardContent>

      <CardFooter>
        <Button
          onClick={() => onDeploy(app)}
          className="w-full bg-gradient-to-r from-indigo-500 to-blue-600 hover:from-indigo-600 hover:to-blue-700 text-white"
        >
          Deploy
        </Button>
      </CardFooter>
    </Card>
  );
}
