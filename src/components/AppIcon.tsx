import { useState } from 'react';
import { getAppIconPath } from '../utils/iconMap';

interface AppIconProps {
  appName: string;
  size?: number;
  className?: string;
}

export function AppIcon({ appName, size = 32, className = '' }: AppIconProps) {
  const [imgFailed, setImgFailed] = useState(false);
  const iconPath = getAppIconPath(appName, 'light');

  if (!iconPath || imgFailed) {
    // Letter circle fallback
    const letter = appName.charAt(0).toUpperCase();
    return (
      <div
        className={`flex items-center justify-center rounded-lg bg-muted text-muted-foreground font-semibold ${className}`}
        style={{ width: size, height: size, fontSize: size * 0.45 }}
      >
        {letter}
      </div>
    );
  }

  return (
    <img
      src={iconPath}
      alt={`${appName} icon`}
      className={`rounded-lg object-contain ${className}`}
      style={{ width: size, height: size }}
      onError={() => setImgFailed(true)}
    />
  );
}
