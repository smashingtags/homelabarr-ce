import { AppTemplate, CLIApplication } from '../types';
import { Shield, Network, Monitor } from 'lucide-react';

interface AppCardProps {
  app: AppTemplate;
  onDeploy: (app: AppTemplate) => void;
}

export function AppCard({ app, onDeploy }: AppCardProps) {
  const Icon = app.logo;
  const cliApp = (app as any)._cliApp as CLIApplication | undefined;

  // Deployment mode icons and labels
  const deploymentModeInfo = {
    traefik: { icon: Network, label: 'Traefik', color: 'text-green-600 bg-green-50' },
    authelia: { icon: Shield, label: 'Authelia', color: 'text-purple-600 bg-purple-50' },
    local: { icon: Monitor, label: 'Local', color: 'text-blue-600 bg-blue-50' }
  };

  return (
    <div className="bg-white dark:bg-gray-800 rounded-lg shadow-md p-4 hover:shadow-lg transition-all duration-200 border border-gray-200 dark:border-gray-700 hover:border-blue-300 dark:hover:border-blue-600 flex flex-col">
      <div className="flex items-center mb-3">
        <div className="p-2 bg-blue-50 dark:bg-blue-900/20 rounded-lg">
          <Icon className="w-6 h-6 text-blue-600 dark:text-blue-400" />
        </div>
        <div className="ml-3 flex-1 min-w-0">
          <h3 className="font-semibold text-gray-900 dark:text-white truncate">{app.name}</h3>
          {cliApp && (
            <p className="text-xs text-gray-500 dark:text-gray-400 truncate">
              {cliApp.image.split(':')[0]}
            </p>
          )}
        </div>
      </div>

      <p className="text-gray-600 dark:text-gray-300 mb-3 text-sm leading-relaxed line-clamp-2 flex-grow">
        {app.description}
      </p>

      {/* Deployment Mode Badges */}
      <div className="mb-3">
        <div className="flex flex-wrap gap-1.5">
          {cliApp?.requiresTraefik && (
            <span className="px-2 py-0.5 text-xs font-medium bg-blue-100 text-blue-700 dark:bg-blue-900 dark:text-blue-300 rounded">
              Traefik
            </span>
          )}
          {cliApp?.requiresAuthelia && (
            <span className="px-2 py-0.5 text-xs font-medium bg-purple-100 text-purple-700 dark:bg-purple-900 dark:text-purple-300 rounded">
              Auth
            </span>
          )}
          {!cliApp && app.deploymentModes && app.deploymentModes.map(mode => {
            const modeInfo = deploymentModeInfo[mode];
            if (!modeInfo) return null;
            const ModeIcon = modeInfo.icon;
            return (
              <div
                key={mode}
                className={`flex items-center px-2 py-0.5 rounded text-xs font-medium ${modeInfo.color} dark:bg-gray-700 dark:text-gray-300`}
              >
                <ModeIcon className="w-3 h-3 mr-1" />
                {modeInfo.label}
              </div>
            );
          })}
          <span className="inline-block px-2 py-0.5 text-xs font-medium bg-gray-100 dark:bg-gray-700 text-gray-600 dark:text-gray-300 rounded capitalize">
            {cliApp?.category || app.category}
          </span>
        </div>
      </div>

      <button
        onClick={() => onDeploy(app)}
        className="w-full bg-gradient-to-r from-blue-600 to-blue-700 hover:from-blue-700 hover:to-blue-800 text-white py-2 px-4 rounded-md transition-all duration-200 font-medium shadow-sm hover:shadow-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 dark:focus:ring-offset-gray-800 text-sm"
      >
        Deploy
      </button>
    </div>
  );
}
