#!/bin/bash
set -e

echo "Setting up Node.js Development Environment..."

# Update package lists
apt-get update

# Install essential tools
apt-get install -y \
  curl \
  wget \
  git \
  vim \
  nano \
  htop \
  tree \
  unzip \
  zip \
  ca-certificates \
  gnupg \
  lsb-release \
  software-properties-common \
  build-essential

# Install Node.js (Latest LTS)
curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
apt-get install -y nodejs

# Install Yarn
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
apt-get update
apt-get install -y yarn

# Create user if it doesn't exist
if ! id "${username}" &>/dev/null; then
  useradd -m -s /bin/bash "${username}"
  usermod -aG sudo "${username}"
  echo "${username} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
fi

# Install global npm packages
sudo -u "${username}" npm install -g \
  @angular/cli \
  @vue/cli \
  create-react-app \
  express-generator \
  nodemon \
  pm2 \
  typescript \
  ts-node \
  eslint \
  prettier

# Configure Git basics
sudo -u "${username}" git config --global init.defaultBranch main
sudo -u "${username}" git config --global pull.rebase false

# Create development directories
sudo -u "${username}" mkdir -p "/home/${username}/workspace"
sudo -u "${username}" mkdir -p "/home/${username}/projects"
sudo -u "${username}" mkdir -p "/home/${username}/node_projects"

# Set npm global directory
sudo -u "${username}" mkdir -p "/home/${username}/.npm-global"
sudo -u "${username}" npm config set prefix "/home/${username}/.npm-global"

# Add npm global path to bashrc
echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> "/home/${username}/.bashrc"

# Set proper ownership
chown -R "${username}:${username}" "/home/${username}"

echo "Node.js Development Environment Ready!"
echo "Node.js Version: $(node --version)"
echo "NPM Version: $(npm --version)"
echo "Yarn Version: $(yarn --version)"
echo "Global packages installed: Angular CLI, Vue CLI, React CLI, Express, TypeScript"
