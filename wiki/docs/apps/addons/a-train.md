![Image of HomelabARR CLI](/img/container_images/docker-homelabarr-cli.png)

<p align="left">
    <a href="https://discord.gg/Pc7mXX786x">
        <img src="https://discord.com/api/guilds/830478558995415100/widget.png?label=Discord%20Server&logo=discord" alt="Join HomelabARR CLI on Discord">
    </a>
        <a href="https://github.com/smashingtags/homelabarr-cli/releases">
        <img src="https://img.shields.io/github/downloads/smashingtags/homelabarr-cli/total?label=Total%20Downloads&logo=github" alt="Total Releases Downloaded from GitHub">
    </a>
    <a href="https://github.com/smashingtags/homelabarr-cli/releases/latest">
        <img src="https://img.shields.io/github/v/release/smashingtags/homelabarr-cli?include_prereleases&label=Latest%20Release&logo=github" alt="Latest Official Release on GitHub">
    </a>
    <a href="https://github.com/smashingtags/homelabarr-cli/blob/main/LICENSE">
        <img src="https://img.shields.io/github/license/smashingtags/homelabarr-cli?label=License&logo=gnu" alt="GNU General Public License">
    </a>
</p>

# A-Train (Deprecated)

> **⚠️ DEPRECATED - Cloud Storage Not Supported**
>
> A-Train was a Google Drive integration component that is **no longer supported** in HomelabARR CLI's NAS-focused architecture. HomelabARR CLI has transitioned from cloud storage to local NAS solutions for better performance and reliability.

## Alternative Solutions for Local NAS

Instead of cloud-based file monitoring, HomelabARR CLI now uses local filesystem integration:

### **1. Native Filesystem Monitoring**
- **Inotify triggers** for real-time local file system changes
- **Direct integration** with download clients (Sonarr, Radarr, Lidarr)
- **No API rate limits** or external dependencies

### **2. Local Storage Benefits**
- **Instant file access** - No download delays
- **Better performance** - Local I/O is faster than cloud transfers
- **Unlimited capacity** - Scale with your NAS hardware
- **Complete privacy** - Files never leave your infrastructure

### **3. Migration Path**
If you previously used A-Train with Google Drive:

1. **Download media files** from Google Drive to your local NAS
2. **Configure mount system** for your NAS storage (UnRAID/TrueNAS)
3. **Update media library paths** in Plex/Jellyfin
4. **Set up local backup** strategies with Restic or Duplicati

### **4. Modern Autoscan Configuration**
For local NAS setups, configure Autoscan with:

```yaml
triggers:
  # Direct integration with download clients
  sonarr:
    - name: sonarr
      priority: 2
      rewrite:
        - from: /downloads/
          to: /mnt/nas/downloads/
        - from: /tv/
          to: /mnt/nas/media/tv/

  radarr:
    - name: radarr  
      priority: 2
      rewrite:
        - from: /downloads/
          to: /mnt/nas/downloads/
        - from: /movies/
          to: /mnt/nas/media/movies/
```

This eliminates the need for external cloud monitoring while providing superior performance.

## Support

Kindly report any issues/broken-parts/bugs on [github](https://github.com/smashingtags/homelabarr-cli/issues) or [discord](https://discord.gg/Pc7mXX786x)

- Join our [![Discord: https://discord.gg/Pc7mXX786x](https://img.shields.io/badge/Discord-gray.svg?style=for-the-badge)](https://discord.gg/Pc7mXX786x) for Support
