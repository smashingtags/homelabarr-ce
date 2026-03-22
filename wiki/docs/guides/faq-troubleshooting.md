# HomelabARR CE FAQ & Troubleshooting

## General

**Q: How do I verify HomelabARR CE is running?**  
A: Visit `http://<host-ip>:8084` (or the port you configured). You should see the app catalog dashboard.

**Q: Where are logs stored?**  
A: Container logs are accessible via `docker logs <container-name>` or through Portainer. The backend log is also available at `/opt/appdata/homelabarr-backend/logs/combined.log` inside the backend container.

**Q: How do I update to the latest version?**  
A: If you used the one‑liner installer, re‑run it:
```bash
sudo wget -qO- https://raw.githubusercontent.com/smashingtags/homelabarr-ce/main/install-remote.sh | sudo bash
```
It will pull the latest images and recreate containers. For manual installs, `git pull` and re‑run `docker compose up -d`.

## Installation

**Q: I get “Error response from daemon: Ports are not available” when installing.**  
A: Another service is already using port 3000 (or whichever port you set). Change the port in `.env` or stop the conflicting service.

**Q: The installer says “CORS_ORIGIN is required” and login fails.**  
A: Set `CORS_ORIGIN` in your `.env` to match the exact URL you use to access the dashboard (including protocol and port, no trailing slash). Example: `CORS_ORIGIN=http://192.168.1.100:8084`.

**Q: Docker fails to start containers on Proxmox LXC.**  
A: LXC containers need AppArmor disabled for Docker. Add `lxc.apparmor.profile: unconfined` to the LXC config or disable AppArmor for the container.

## Usage

**Q: How do I add a custom app not in the catalog?**  
A: Use **Build From Source**: clone the repo, add your docker‑compose.yml under `apps/<yourapp>/`, then run the CLI menu → **Install/Remove** → **Custom** (or manually `docker compose up -d` in that folder). See the **Build From Source** section in the docs.

**Q: I changed an app’s environment variables but the container didn’t pick them up.**  
A: After editing the `.env` or app-specific env file, you must recreate the container:
```bash
cd /opt/homelabarr-ce/apps/<yourapp>
docker compose up -d --force-recreate
```
Or use the CLI menu → **Install/Remove** → select the app → **Reinstall**.

**Q: The Traefik dashboard shows 502 errors for an app.**  
A: Verify the app container is healthy (`docker ps`). Check the app logs for startup errors. Ensure the container exposes the correct internal port (as defined in its service). Also confirm the Traefik label `traefik.enable=true` is present.

**Q: How do I enable automatic updates for containers?**  
A: HomelabARR CE uses Watchtower with label‑based opt‑in. To enable auto‑update for a specific app, add the label `com.centurylinklabs.watchtower.enable=true` to its service in `apps/<app>/docker-compose.yml`. Then run `docker compose up -d` to apply.

## Backup & Restore

**Q: What does the backup script actually save?**  
A: The script (`backup.sh`) performs a tar+compress of `/opt/appdata` (contains all app data, configs, and databases) and copies it to your NAS and/or Google Drive via rclone. It does **not** backup the HomelabARR CE application itself (that’s stateless and can be recreated from the repo).

**Q: How do I restore from a backup?**  
A: Extract the archive to a temporary location, then restore the `/opt/appdata` directory (stop containers first). Example:
```bash
sudo systemctl stop homelabarr-ce   # if using service
sudo rm -rf /opt/appdata/*
sudo tar -xzf /path/to/backup/appdata-YYYY-MM-DD.tar.gz -C /
sudo systemctl start homelabarr-ce
```
Refer to the **Backup System** section in the README for details.

## Security

**Q: Is the Docker socket exposed?**  
A: In the CE demo and default installation, the Docker socket is **not** exposed to containers. For local development you can expose it via `docker` service, but production setups mount it read‑only only where needed (e.g., Portainer).  

**Q: How do I harden the installation?**  
A:  
- Enable Authelia 2FA (already included).  
- Keep the host OS and Docker updated.  
- Use non‑root containers where possible (most images already run as non‑root).  
- Restrict Traefik’s exposed services to only those you need via labels.  
- Regularly run `docker scout` or `trivy` on images.

## Development

**Q: I want to contribute a new app template.**  
A: Fork the repo, add your docker‑compose.yml under `apps/<yourapp>/`, add an icon to `apps/<yourapp>/icon.png`, and update `app-metadata.ts` in the wiki source (if you have access). Open a PR with a clear description and test the template locally.

**Q: How do I run the backend locally for debugging?**  
A: Clone the repo, copy `.env.example` to `.env`, adjust settings, then:
```bash
cd server
npm install
npm run dev
```
The backend will run on `http://localhost:8092`. Point the frontend to it by setting `VITE_BACKEND_URL` in `.env` or editing `src/vite.config.ts`.
