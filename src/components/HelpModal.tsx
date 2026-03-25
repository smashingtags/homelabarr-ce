import { HelpCircle } from "lucide-react";
import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/components/ui/dialog";
import { ScrollArea } from "@/components/ui/scroll-area";

interface HelpModalProps {
  isOpen: boolean;
  onClose: () => void;
}

export function HelpModal({ isOpen, onClose }: HelpModalProps) {
  return (
    <Dialog open={isOpen} onOpenChange={(open) => { if (!open) onClose(); }}>
      <DialogContent className="max-w-4xl h-[90vh] flex flex-col">
        <DialogHeader>
          <DialogTitle className="flex items-center gap-2">
            <HelpCircle className="w-6 h-6 text-blue-600 dark:text-blue-400" />
            Help & Documentation
          </DialogTitle>
        </DialogHeader>

        <ScrollArea className="flex-1 pr-4">
          <div className="prose dark:prose-invert max-w-none">
            <h3>Quick Start Guide</h3>
            <ol>
              <li>Browse available applications in the categories above</li>
              <li>Click "Deploy" on your chosen application</li>
              <li>Fill in the required configuration</li>
              <li>Click "Deploy" to start the container</li>
            </ol>

            <h3>Managing Applications</h3>
            <ul>
              <li><strong>Start/Stop:</strong> Use the play/stop buttons</li>
              <li><strong>Restart:</strong> Click the refresh button</li>
              <li><strong>Remove:</strong> Click the trash button</li>
              <li><strong>Logs:</strong> Click the terminal button</li>
              <li><strong>Stats:</strong> Click the expand button</li>
            </ul>

            <h3>Application Categories</h3>
            <ul>
              <li><strong>Infrastructure:</strong> Core services like Traefik and Homepage</li>
              <li><strong>Security:</strong> Authentication and password management</li>
              <li><strong>Media:</strong> Streaming servers and media management</li>
              <li><strong>Downloads:</strong> Torrent and Usenet clients</li>
              <li><strong>Storage:</strong> File synchronization and document management</li>
              <li><strong>Monitoring:</strong> System and service monitoring</li>
              <li><strong>Automation:</strong> Media automation tools</li>
              <li><strong>Development:</strong> Development tools and services</li>
              <li><strong>Productivity:</strong> Notes and collaboration tools</li>
              <li><strong>Communication:</strong> Chat and email servers</li>
            </ul>

            <h3>Troubleshooting</h3>
            <h4>Common Issues</h4>
            <ul>
              <li><strong>Container won&apos;t start:</strong> Check logs for errors</li>
              <li><strong>Network issues:</strong> Verify Traefik configuration</li>
              <li><strong>Permission errors:</strong> Check volume permissions</li>
            </ul>

            <h3>Security Best Practices</h3>
            <ul>
              <li>Use strong passwords for all services</li>
              <li>Keep containers updated regularly</li>
              <li>Enable authentication for sensitive services</li>
              <li>Use SSL/TLS encryption</li>
              <li>Regular backups of important data</li>
            </ul>

            <h3>Need More Help?</h3>
            <p>
              For detailed documentation, please visit the{" "}
              <a
                href="https://wiki.homelabarr.com"
                target="_blank"
                rel="noopener noreferrer"
                className="text-blue-600 dark:text-blue-400 hover:underline"
              >
                HomelabARR Wiki
              </a>.
            </p>
          </div>
        </ScrollArea>
      </DialogContent>
    </Dialog>
  );
}
