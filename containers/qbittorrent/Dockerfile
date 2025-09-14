# Docker Mod for qBittorrent enhancements
FROM ghcr.io/linuxserver/baseimage-alpine:3.19

# Labels for metadata
LABEL maintainer="HomelabARR CLI"
LABEL org.opencontainers.image.title="docker-mod-qbittorrent"
LABEL org.opencontainers.image.description="qBittorrent Docker mod for enhanced functionality"
LABEL org.opencontainers.image.source="https://github.com/smashingtags/homelabarr-cli"
LABEL org.opencontainers.image.documentation="https://github.com/smashingtags/homelabarr-cli/wiki"
LABEL org.opencontainers.image.licenses="MIT"

# Install required packages
RUN apk add --no-cache \
    curl \
    wget \
    jq \
    bash

# Create mod directory structure
RUN mkdir -p /docker-mods/qbittorrent

# Add mod files
COPY root/ /

# Set permissions
RUN find /docker-mods -type f -name "*.sh" -exec chmod +x {} \;

VOLUME ["/docker-mods"]
WORKDIR /docker-mods