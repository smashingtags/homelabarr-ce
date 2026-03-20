#!/bin/bash
set -e

echo "Setting up Basic Ubuntu Development Environment..."

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
  software-properties-common

# Create user if it doesn't exist
if ! id "${username}" &>/dev/null; then
  useradd -m -s /bin/bash "${username}"
  usermod -aG sudo "${username}"
  echo "${username} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
fi

# Configure Git basics
sudo -u "${username}" git config --global init.defaultBranch main
sudo -u "${username}" git config --global pull.rebase false

# Create basic directories
sudo -u "${username}" mkdir -p "/home/${username}/workspace"
sudo -u "${username}" mkdir -p "/home/${username}/projects"

# Set proper ownership
chown -R "${username}:${username}" "/home/${username}"

echo "Basic Ubuntu Environment Ready!"
echo "Available tools: git, vim, nano, htop, tree"
