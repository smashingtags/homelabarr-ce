#!/bin/bash
#####################################
# HomelabARR CE — One-Line Installer
# Usage: sudo wget -qO- https://raw.githubusercontent.com/smashingtags/homelabarr-ce/main/install-remote.sh | sudo bash
#####################################

set -e

REPO="https://github.com/smashingtags/homelabarr-ce.git"
INSTALL_DIR="/opt/homelabarr"
BIN_NAME="homelabarr-cli"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "    🚀 HomelabARR CE — One-Line Installer"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check root
if [[ $EUID -ne 0 ]]; then
  echo "⛔ This script must be run as root (use sudo)"
  exit 1
fi

# Install git if missing
if ! command -v git &>/dev/null; then
  echo "📦 Installing git..."
  apt-get update -qq && apt-get install -y -qq git >/dev/null 2>&1
fi

# Clone or update repo
if [[ -d "$INSTALL_DIR" ]]; then
  echo "📂 Updating existing installation at $INSTALL_DIR..."
  cd "$INSTALL_DIR" && git pull --ff-only 2>/dev/null || true
else
  echo "📥 Cloning HomelabARR CE to $INSTALL_DIR..."
  git clone "$REPO" "$INSTALL_DIR"
fi

cd "$INSTALL_DIR"

# Make all scripts executable
echo "🔧 Setting permissions..."
find . -name "*.sh" -exec chmod +x {} \;
chmod +x .installer/homelabber 2>/dev/null || true

# Install the CLI command system-wide
echo "🔗 Installing $BIN_NAME command..."
cp .installer/homelabber /usr/local/bin/$BIN_NAME 2>/dev/null || true
chmod +x /usr/local/bin/$BIN_NAME 2>/dev/null || true

# Also install to /bin for compatibility
cp .installer/homelabber /bin/$BIN_NAME 2>/dev/null || true
chmod +x /bin/$BIN_NAME 2>/dev/null || true

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "    ✅ HomelabARR CE installed successfully!"
echo ""
echo "    Run the installer:  sudo homelabarr-cli -i"
echo "    Or start directly:  cd $INSTALL_DIR && sudo ./install.sh"
echo ""
echo "    Wiki: https://smashingtags.github.io/homelabarr-ce/"
echo "    Discord: https://discord.gg/Pc7mXX786x"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
