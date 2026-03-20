#!/bin/bash
#
# HomelabARR CLI Auto-Dashboard Generator
# Generates Grafana dashboards for all installed applications
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON_SCRIPT="$SCRIPT_DIR/auto-dashboard-generator.py"

echo "🚀 HomelabARR CLI Auto-Dashboard Generator"
echo "=========================================="

# Check if Python script exists
if [[ ! -f "$PYTHON_SCRIPT" ]]; then
    echo "❌ Error: Python script not found at $PYTHON_SCRIPT"
    exit 1
fi

# Check for Python 3
if ! command -v python3 &> /dev/null; then
    echo "❌ Error: Python 3 is required but not installed"
    exit 1
fi

# Check for required Python modules
echo "🔍 Checking Python dependencies..."
if ! python3 -c "import requests" 2>/dev/null; then
    echo "📦 Installing required Python modules..."
    pip3 install requests || {
        echo "❌ Error: Failed to install requests module"
        echo "💡 Try: sudo apt-get install python3-pip && pip3 install requests"
        exit 1
    }
fi

# Check if Docker is running
if ! docker info &> /dev/null; then
    echo "❌ Error: Docker is not running or not accessible"
    exit 1
fi

# Set environment variables if not set
export GRAFANA_URL="${GRAFANA_URL:-http://grafana:3000}"

# Display configuration
echo "⚙️  Configuration:"
echo "   Grafana URL: $GRAFANA_URL"
echo "   Grafana Token: $([ -n "${GRAFANA_TOKEN:-}" ] && echo "✅ Set" || echo "❌ Not Set (will save to files)")"
echo

# Run the Python script
echo "🏃 Running dashboard generator..."
python3 "$PYTHON_SCRIPT"

echo
echo "✅ Dashboard generation complete!"
echo "📖 Check the monitoring dashboards in Grafana at: $GRAFANA_URL"
