# Docker Mount Container for Cloud Storage
# Provides mounting capabilities for various cloud storage providers
FROM ghcr.io/linuxserver/baseimage-alpine:3.19

# Labels for metadata
LABEL maintainer="HomelabARR CLI"
LABEL org.opencontainers.image.title="docker-mount"
LABEL org.opencontainers.image.description="Docker container for mounting cloud storage"
LABEL org.opencontainers.image.source="https://github.com/smashingtags/homelabarr-cli"
LABEL org.opencontainers.image.documentation="https://github.com/smashingtags/homelabarr-cli/wiki"
LABEL org.opencontainers.image.licenses="MIT"

# Install required packages
RUN apk add --no-cache \
    rclone \
    fuse3 \
    fuse3-dev \
    unionfs-fuse \
    mergerfs \
    curl \
    wget \
    bash \
    jq \
    coreutils \
    util-linux \
    ca-certificates

# Create necessary directories
RUN mkdir -p \
    /app \
    /config \
    /mnt \
    /scripts \
    /logs

# Copy application files
COPY root/ /

# Set permissions
RUN chmod +x /app/mount.sh \
    && chmod +x /etc/services.d/*/run \
    && chmod +x /etc/cont-init.d/*

# Expose port for web interface
EXPOSE 5572

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:5572/health || exit 1

# Volumes
VOLUME ["/config", "/mnt"]

WORKDIR /app