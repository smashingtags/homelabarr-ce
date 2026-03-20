#!/bin/bash
set -e

echo "Setting up Python Development Environment..."

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

# Install Python and development tools
apt-get install -y \
  python3 \
  python3-pip \
  python3-venv \
  python3-dev \
  python3-setuptools \
  python3-wheel

# Create user if it doesn't exist
if ! id "${username}" &>/dev/null; then
  useradd -m -s /bin/bash "${username}"
  usermod -aG sudo "${username}"
  echo "${username} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
fi

# Install common Python packages
sudo -u "${username}" python3 -m pip install --user --upgrade pip
sudo -u "${username}" python3 -m pip install --user \
  setuptools \
  wheel \
  virtualenv \
  pipenv \
  poetry \
  requests \
  numpy \
  pandas \
  matplotlib \
  jupyter

# Configure Git basics
sudo -u "${username}" git config --global init.defaultBranch main
sudo -u "${username}" git config --global pull.rebase false

# Create development directories
sudo -u "${username}" mkdir -p "/home/${username}/workspace"
sudo -u "${username}" mkdir -p "/home/${username}/projects"
sudo -u "${username}" mkdir -p "/home/${username}/venvs"

# Create a default virtual environment
sudo -u "${username}" python3 -m venv "/home/${username}/venvs/default"

# Add Python path to bashrc
echo 'export PATH="$HOME/.local/bin:$PATH"' >> "/home/${username}/.bashrc"
echo 'alias activate="source ~/venvs/default/bin/activate"' >> "/home/${username}/.bashrc"

# Set proper ownership
chown -R "${username}:${username}" "/home/${username}"

echo "Python Development Environment Ready!"
echo "Python Version: $(python3 --version)"
echo "Pip Version: $(python3 -m pip --version)"
echo "Virtual environment created at: ~/venvs/default"
echo "Use 'activate' command to activate the default virtual environment"
