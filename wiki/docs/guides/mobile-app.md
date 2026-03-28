# Mobile App

HomelabARR Mobile puts your dashboard in your pocket. It's a native app for iOS and Android that connects to your HomelabARR CE server — same dashboard, same 100+ apps, but on your phone.

![HomelabARR Mobile](../img/screenshots/dark-dashboard.png)

## What It Does

- **Browse and deploy** all 100+ container templates from your phone
- **Monitor** running containers with real-time status
- **Dark and light mode** that follows your system preference
- **Works everywhere** — local IP, Tailscale, Cloudflare Tunnel, any URL
- **Pull-to-refresh**, back navigation, and haptic feedback
- **Secure** — your server URL and API key stay on your device

!!! tip "It's your CE dashboard, just native"
    The app connects to whatever CE instance you're already running. Same apps, same configs, same login. It just makes it easier to check on things without opening a laptop.

## Getting It

| Platform | Status | Price |
|---|---|---|
| **iOS** (App Store) | Available on TestFlight, App Store submission pending | $4.99 one-time |
| **Android** (Google Play) | APK available, Play Store submission pending | $4.99 one-time |
| **Build from source** | Always free | [github.com/smashingtags/homelabarr-mobile](https://github.com/smashingtags/homelabarr-mobile) |

!!! info "Why $4.99?"
    HomelabARR CE is free and always will be. The mobile app is a convenience — compiled, signed, auto-updated through the store. Power users can always build it themselves from the open source repo.

## Setup

When you first open the app, you'll see the setup screen with the HomelabARR octopus logo. Enter two things:

### 1. Your Server URL

This is whatever URL you use to access your CE dashboard in a browser:

| Setup | Example URL |
|---|---|
| Local network | `http://192.168.1.100:8084` |
| Tailscale | `http://100.x.x.x:8084` |
| Traefik + domain | `https://homelabarr.yourdomain.com` |
| Cloudflare Tunnel | `https://homelabarr.yourdomain.com` |

!!! warning "Use the right URL"
    The app needs to reach your CE server. If you're on the same WiFi as your server, use the local IP. If you're away from home, you'll need Tailscale, a Cloudflare Tunnel, or a domain pointed at your server.

### 2. Your API Key (Optional)

If your CE instance has API key authentication enabled, enter your key. You can generate one from the CE dashboard:

1. Open your CE dashboard in a browser
2. Click your username → **API Keys**
3. Click **Generate New Key**
4. Copy the `hlr_` key and paste it into the app

If you're using the default admin/admin setup without API keys, you can skip this field.

### 3. Tap Connect

The app validates your server URL, checks the connection, and loads your dashboard. That's it.

## Using the App

Once connected, it's your full CE dashboard:

- **Swipe between categories** — Media & Entertainment, Downloads, AI & Machine Learning, all 11 tabs
- **Tap Deploy** on any app to open the deployment modal
- **Pull down to refresh** the app list
- **Tap the back button** to navigate within the dashboard
- **Toggle dark/light mode** — follows your phone's system setting

## Troubleshooting

### "Connection failed"
- Make sure your CE server is running (`docker ps` should show the frontend and backend containers)
- Check that the URL is reachable from your phone — try it in your phone's browser first
- If you're on cellular, you need Tailscale or a public URL — local IPs won't work outside your home network

### Dashboard loads but shows "Failed to load applications"
- Your backend container might not be running. Check: `docker ps | grep backend`
- If using API keys, make sure the key you entered is valid

### App is slow
- The app loads your full dashboard over the network. If your server is remote (not local), performance depends on your connection speed
- Pull-to-refresh forces a full reload

## Technical Details

- **Built with:** React Native + Expo
- **WebView:** Connects to your CE frontend (same as your browser)
- **Storage:** Server URL and API key stored locally on device via AsyncStorage
- **Platforms:** iOS 15+ and Android 10+
- **Source:** [github.com/smashingtags/homelabarr-mobile](https://github.com/smashingtags/homelabarr-mobile)

## Try the Demo

Don't have a CE server yet? Connect to the demo:

- **URL:** `https://ce-demo.homelabarr.com`
- **Login:** `admin` / `admin`

This is a live CE instance with 100+ apps you can browse (deploys disabled on demo).
