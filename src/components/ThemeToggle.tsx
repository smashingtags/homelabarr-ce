import React from 'react';
import { Sun, Moon } from 'lucide-react';
import { Theme, setTheme, getTheme } from '../lib/theme';
import { Button } from "@/components/ui/button";

export function ThemeToggle() {
  const [theme, setCurrentTheme] = React.useState<Theme>(getTheme);

  const toggleTheme = () => {
    const newTheme = theme === 'light' ? 'dark' : 'light';
    setTheme(newTheme);
    setCurrentTheme(newTheme);
  };

  return (
    <Button
      variant="ghost"
      size="icon"
      onClick={toggleTheme}
      aria-label="Toggle theme"
    >
      {theme === 'light' ? (
        <Moon className="w-5 h-5 text-gray-600 dark:text-gray-400" />
      ) : (
        <Sun className="w-5 h-5 text-gray-600 dark:text-gray-400" />
      )}
    </Button>
  );
}
