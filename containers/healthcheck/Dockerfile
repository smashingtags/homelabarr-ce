# Docker Mod for Health Check functionality
# Based on LinuxServer.io Docker Mods pattern
FROM ghcr.io/linuxserver/baseimage-alpine:3.19

# Labels for metadata
LABEL maintainer="HomelabARR CLI"
LABEL org.opencontainers.image.title="docker-mod-healthcheck"
LABEL org.opencontainers.image.description="Health check Docker mod for LinuxServer containers"
LABEL org.opencontainers.image.source="https://github.com/smashingtags/homelabarr-cli"
LABEL org.opencontainers.image.documentation="https://github.com/smashingtags/homelabarr-cli/wiki"
LABEL org.opencontainers.image.licenses="MIT"

# Install required packages
RUN apk add --no-cache \
    curl \
    wget \
    netcat-openbsd \
    jq \
    bash

# Create mod directory structure
RUN mkdir -p /docker-mods/healthcheck/etc/services.d/healthcheck

# Add health check script
COPY root/ /

# Set permissions
RUN chmod +x /docker-mods/healthcheck/usr/local/bin/healthcheck.sh \
    && chmod +x /docker-mods/healthcheck/etc/services.d/healthcheck/run

# Health check for the mod itself
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

VOLUME ["/docker-mods"]

WORKDIR /docker-mods