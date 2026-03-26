#!/bin/sh
# Substitute BACKEND_URL into nginx config at container startup
# Default: http://backend:8092 (matches docker-compose service name)
BACKEND_URL=${BACKEND_URL:-http://backend:8092}

sed "s|BACKEND_URL_PLACEHOLDER|${BACKEND_URL}|g"   /etc/nginx/templates/nginx.conf.template > /etc/nginx/conf.d/default.conf

echo "HomelabARR frontend starting (backend: ${BACKEND_URL})"
exec nginx -g 'daemon off;'
