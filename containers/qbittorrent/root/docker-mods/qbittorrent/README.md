# qBittorrent Docker Mod

This Docker mod provides enhanced functionality for qBittorrent containers.

## Features

- Enhanced logging and monitoring
- Automatic configuration optimization
- Custom scripts for download management
- Integration with HomelabARR CLI stack

## Usage

Add this mod to your qBittorrent container:

```yaml
environment:
  - "DOCKER_MODS=ghcr.io/themepark-dev/theme.park:qbittorrent|ghcr.io/smashingtags/docker-mod-qbittorrent:v1.0.0"
```

## Configuration

The mod will automatically apply optimizations when the container starts.
Custom configurations can be placed in `/config/custom/` directory.
