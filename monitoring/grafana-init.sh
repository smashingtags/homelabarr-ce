#!/bin/sh
# Star all provisioned dashboards so they appear on Grafana home
# Runs after Grafana starts — waits for API to be ready

GRAFANA_URL="http://localhost:3000"
GRAFANA_AUTH="admin:${GRAFANA_ADMIN_PASSWORD:-admin}"
MAX_WAIT=30
WAITED=0

# Wait for Grafana to be ready
while [ $WAITED -lt $MAX_WAIT ]; do
  if curl -sf "$GRAFANA_URL/api/health" > /dev/null 2>&1; then
    break
  fi
  sleep 1
  WAITED=$((WAITED + 1))
done

if [ $WAITED -ge $MAX_WAIT ]; then
  echo "Grafana not ready after ${MAX_WAIT}s, skipping dashboard starring"
  exit 0
fi

# Star all dashboards for the anonymous org
DASHBOARDS=$(curl -sf -u "$GRAFANA_AUTH" "$GRAFANA_URL/api/search?type=dash-db" 2>/dev/null)
if [ -z "$DASHBOARDS" ]; then
  exit 0
fi

echo "$DASHBOARDS" | python3 -c "
import json, sys, urllib.request
dashboards = json.load(sys.stdin)
for d in dashboards:
    uid = d.get('uid', '')
    title = d.get('title', '')
    try:
        import base64
        auth = base64.b64encode('${GRAFANA_AUTH}'.encode()).decode()
        req = urllib.request.Request(
            '${GRAFANA_URL}/api/user/stars/dashboard/uid/' + uid,
            method='POST',
            headers={'Content-Type': 'application/json', 'Authorization': 'Basic ' + auth}
        )
        urllib.request.urlopen(req)
        print(f'Starred: {title}')
    except Exception as e:
        print(f'Skip: {title} ({e})')
" 2>/dev/null || echo "Dashboard starring skipped (python3 not available)"
