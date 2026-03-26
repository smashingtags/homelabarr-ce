# HomelabARR CE Frontend
# Multi-stage build: React + TypeScript + Vite → nginx

# Build stage  
FROM node:24-alpine3.23 AS builder
WORKDIR /app
RUN apk add --no-cache git python3 make g++
COPY package.json package-lock.json ./
RUN npm ci --no-audit --loglevel=error --no-fund && npm cache clean --force
COPY tsconfig*.json vite.config.ts tailwind.config.js postcss.config.js eslint.config.js index.html ./
COPY src/ ./src/
COPY public/ ./public/
ENV NODE_ENV=production
RUN npm run build

# Production stage
FROM nginx:1.29.6-alpine3.23-slim
RUN apk upgrade --no-cache

# Non-root user
RUN addgroup -g 1001 -S homelabarr &&     adduser -S homelabarr -u 1001 -G homelabarr

# Copy built frontend
COPY --from=builder /app/dist /usr/share/nginx/html

# Copy nginx template and entrypoint
COPY nginx.conf.template /etc/nginx/templates/nginx.conf.template
COPY docker-entrypoint.sh /docker-entrypoint.sh

# Create dirs and set permissions
RUN mkdir -p /var/cache/nginx/client_temp              /var/cache/nginx/proxy_temp              /var/cache/nginx/fastcgi_temp              /var/cache/nginx/uwsgi_temp              /var/cache/nginx/scgi_temp              /var/run /var/log/nginx              /etc/nginx/templates &&     sed -i 's|/run/nginx.pid|/tmp/nginx.pid|g' /etc/nginx/nginx.conf &&     chown -R homelabarr:homelabarr /var/cache/nginx /var/run /var/log/nginx       /usr/share/nginx/html /etc/nginx/conf.d /etc/nginx/templates &&     chmod -R 755 /var/cache/nginx /var/run /var/log/nginx /usr/share/nginx/html &&     chmod +x /docker-entrypoint.sh

USER homelabarr
EXPOSE 8080

# BACKEND_URL — override to point at your backend service
# Default: http://backend:8092 (matches docker-compose.yml service name)
ENV BACKEND_URL=http://backend:8092

HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3   CMD wget --no-verbose --tries=1 --spider http://localhost:8080/health || exit 1

LABEL org.opencontainers.image.title="HomelabARR CE Frontend"
LABEL org.opencontainers.image.description="React frontend for HomelabARR CE container management"
LABEL org.opencontainers.image.vendor="Imogen Labs"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.source="https://github.com/smashingtags/homelabarr-ce"

ENTRYPOINT ["/docker-entrypoint.sh"]
