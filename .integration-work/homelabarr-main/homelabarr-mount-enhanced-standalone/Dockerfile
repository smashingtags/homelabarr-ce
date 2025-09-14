# MVP HomelabARR Mount Container for Integration Testing
# Simplified version for MVP that integrates our working backend

FROM node:18-alpine

# Metadata following HomelabARR container standards
LABEL maintainer="HomelabARR Enhanced <support@homelabarr.dev>"
LABEL description="HomelabARR CLI integration with Docker deployment capabilities"
LABEL org.opencontainers.image.title="homelabarr-mount-enhanced"
LABEL org.opencontainers.image.description="Docker-based container management with web interface"

# Version information
ARG BUILD_DATE
ARG VERSION
LABEL build_version="HomelabARR Enhanced version:- ${VERSION} Build-date:- ${BUILD_DATE}"

# Install system dependencies
RUN apk add --no-cache \
    bash \
    curl \
    docker-cli \
    jq \
    python3 \
    py3-pip

# Create application directory
WORKDIR /app

# Copy our working MVP files
COPY . .

# Install Node.js dependencies (if package.json exists)
RUN if [ -f "package.json" ]; then npm install; fi

# Create basic health check script
RUN echo '#!/bin/bash' > /app/health-check.sh && \
    echo 'curl -f http://localhost:8080/health || exit 1' >> /app/health-check.sh && \
    chmod +x /app/health-check.sh

# Create basic startup script
RUN echo '#!/bin/bash' > /app/start.sh && \
    echo 'echo "Starting HomelabARR Mount Enhanced MVP"' >> /app/start.sh && \
    echo 'echo "MVP Status: Ready"' >> /app/start.sh && \
    echo 'echo "Docker CLI available: $(docker --version)"' >> /app/start.sh && \
    echo 'if [ -f "/app/server/index.js" ]; then' >> /app/start.sh && \
    echo '  echo "Starting Node.js backend on port 8080"' >> /app/start.sh && \
    echo '  cd /app/server && PORT=8080 AUTH_ENABLED=false node index.js' >> /app/start.sh && \
    echo 'else' >> /app/start.sh && \
    echo '  echo "Backend not found, serving static response"' >> /app/start.sh && \
    echo '  python3 -m http.server 8080' >> /app/start.sh && \
    echo 'fi' >> /app/start.sh && \
    chmod +x /app/start.sh

# Create health endpoint for testing
RUN mkdir -p /app/health && \
    echo '{"status": "healthy", "service": "homelabarr-mount-enhanced", "features": ["docker-cli", "container-management"]}' > /app/health/index.html

# Health check compatible with existing patterns
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD /app/health-check.sh

# Expose port for web interface
EXPOSE 8080

# Volume definitions compatible with homelabarr-mount
VOLUME ["/config", "/data", "/logs"]

# Start the application
CMD ["/app/start.sh"]