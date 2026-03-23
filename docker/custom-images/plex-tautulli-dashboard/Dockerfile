# HomelabARR Plex-Tautulli Dashboard
# Based on original work by cyb3rgh05t but rebuilt for HomelabARR independence
FROM node:24-alpine3.23 AS builder

WORKDIR /app

# Install dependencies
RUN apk add --no-cache git python3 make g++

# Clone and build the dashboard (we'll need to fork or recreate this)
# For now, using a placeholder - need to create our own dashboard code
COPY package*.json ./
RUN npm ci --only=production

# Runtime stage
FROM node:24-alpine3.23

# Install runtime dependencies
RUN apk add --no-cache \
    curl \
    tzdata \
    tini

# Create app user
RUN addgroup -g 1000 -S homelabarr && \
    adduser -u 1000 -S homelabarr -G homelabarr

WORKDIR /app

# Copy built application
COPY --from=builder --chown=homelabarr:homelabarr /app .

# Copy our custom configuration
COPY --chown=homelabarr:homelabarr config/ ./config/
COPY --chown=homelabarr:homelabarr themes/ ./themes/

# Environment variables
ENV NODE_ENV=production \
    PORT=3005 \
    API_PORT=3006 \
    PUID=1000 \
    PGID=1000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:${PORT}/health || exit 1

USER homelabarr

EXPOSE 3005 3006

# Use tini to handle signals properly
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["node", "server.js"]

# Labels
LABEL org.opencontainers.image.title="HomelabARR Plex-Tautulli Dashboard" \
      org.opencontainers.image.description="Advanced monitoring dashboard for Plex and Tautulli" \
      org.opencontainers.image.vendor="HomelabARR" \
      org.opencontainers.image.url="https://github.com/smashingtags/homelabarr-cli" \
      org.opencontainers.image.source="https://github.com/smashingtags/homelabarr-cli" \
      org.opencontainers.image.documentation="https://homelabarr.com/docs/addons/plex-dashboard" \
      maintainer="smashingtags"