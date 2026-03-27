# Quick Start

Get HomelabARR CE running on your server. Pick one of the two install methods below and follow every step in order.

---

## Before You Start

You need a Linux server with Docker installed. That's it.

**Don't have Docker yet?** Run this on your server:

```bash
curl -fsSL https://get.docker.com | sh
```

Wait for it to finish. Then add your user to the Docker group so you don't need `sudo` for everything:

```bash
sudo usermod -aG docker $USER
```

**Log out and back in** for that to take effect. Then verify it worked:

```bash
docker --version
docker compose version
```

If both commands print a version number, you're good. If not, check the [Docker docs](https://docs.docker.com/engine/install/).

---

## Method 1: Docker Compose (Recommended)

This is the fastest way to get up and running. Copy and paste these commands one at a time.

### Step 1: Download HomelabARR

```bash
git clone https://github.com/smashingtags/homelabarr-ce.git /opt/homelabarr
```

This downloads all the app templates and the compose file to `/opt/homelabarr`.

### Step 2: Go into the folder

```bash
cd /opt/homelabarr
```

### Step 3: Set up your environment

You need to set a few variables before starting. Copy and paste this entire block:

```bash
export JWT_SECRET=$(openssl rand -hex 32)
export DOCKER_GID=$(getent group docker | cut -d: -f3)
export CORS_ORIGIN=http://YOUR-SERVER-IP:8084
```

!!! warning "Replace YOUR-SERVER-IP"
    Change `YOUR-SERVER-IP` to your actual server's IP address. For example: `http://192.168.1.100:8084`
    
    Don't know your IP? Run `hostname -I` and use the first address.

### Step 4: Start HomelabARR

```bash
docker compose -f homelabarr.yml up -d
```

Docker will download the images (this takes a minute or two the first time) and start everything up.

### Step 5: Open the dashboard

Open your web browser and go to:

```
http://YOUR-SERVER-IP:8084
```

You should see the HomelabARR dashboard with 100+ apps ready to deploy.

### Step 6: Log in

Click **Sign In** in the top right corner.

- **Username:** `admin`
- **Password:** `admin`

![Login Modal](../img/screenshots/dark-login-modal.png)

**Change this password right away** — click your username in the top right, then update your credentials.

### Step 7: Deploy your first app

1. Pick any app from the catalog (try **Plex** or **Portainer** to start)
2. Click the blue **Deploy** button
3. Choose **Standard** for the deployment mode (the simplest option)
4. Click **Deploy** and watch it install in real time

![Deploy Modal](../img/screenshots/dark-deploy-modal-auth.png)

That's it. Your app is running. You can find it at `http://YOUR-SERVER-IP:PORT` — the port number is shown in the app card.

---

## Method 2: One-Line Install

If you want a guided installer that does everything for you:

```bash
curl -fsSL https://raw.githubusercontent.com/smashingtags/homelabarr-ce/main/install-remote.sh | sudo bash
```

This downloads HomelabARR, sets up Docker, and walks you through setup with an interactive menu.

→ [More about the CLI](cli-installation.md)

---

## What Now?

You've got HomelabARR running. Here's what to explore next:

- **Browse the dashboard** — check out all 10 categories of apps
- **[Web Dashboard Guide](web-dashboard.md)** — learn what every button does
- **[Configuration](configuration.md)** — customize ports, paths, and settings
- **Want apps on a custom domain with SSL?** → [Traefik & Domain Setup](traefik-setup.md)

---

## Something Not Working?

### I see the dashboard but no apps load

Make sure you cloned the repo in Step 1. The app templates live in the `apps/` folder — without them, the dashboard has nothing to show.

### I get a CORS error or the API won't connect

The `CORS_ORIGIN` variable needs to match **exactly** how you access the dashboard in your browser.

```bash
# If you access it at http://192.168.1.100:8084, set:
export CORS_ORIGIN=http://192.168.1.100:8084

# Then restart:
docker compose -f homelabarr.yml up -d
```

### Containers won't deploy — "Docker socket" error

Make sure `DOCKER_GID` is set correctly:

```bash
# Check your Docker group ID:
getent group docker | cut -d: -f3

# Then set it and restart:
export DOCKER_GID=YOUR_NUMBER_HERE
docker compose -f homelabarr.yml up -d
```

### Permission denied on `/opt/appdata`

Some apps store data in `/opt/appdata`. Create it with the right permissions:

```bash
sudo mkdir -p /opt/appdata
sudo chown -R $USER:$USER /opt/appdata
```

### Running in a Proxmox LXC container?

Docker inside LXC needs AppArmor disabled. On your **Proxmox host** (not inside the container), run:

```bash
echo 'lxc.apparmor.profile: unconfined' >> /etc/pve/lxc/YOUR-VMID.conf
```

Replace `YOUR-VMID` with your container's ID number (like `100` or `999`). Then restart the container from the Proxmox UI.
