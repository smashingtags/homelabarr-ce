#!/bin/bash
set -e

echo "Setting up Full Stack Development Environment..."

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

# Install Node.js (Latest LTS)
curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
apt-get install -y nodejs

# Install Yarn
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
apt-get update
apt-get install -y yarn

# Install Go (latest stable)
GO_VERSION=$(curl -s https://api.github.com/repos/golang/go/releases/latest | grep -oP '"tag_name": "\K[^"]*' | sed 's/go//')
wget -c "https://golang.org/dl/go${GO_VERSION}.linux-amd64.tar.gz" -O go.tar.gz
tar -C /usr/local -xzf go.tar.gz
rm go.tar.gz

# Install additional development tools
apt-get install -y \
  docker.io \
  docker-compose \
  postgresql-client \
  mysql-client \
  redis-tools

# Create user if it doesn't exist
if ! id "${username}" &>/dev/null; then
  useradd -m -s /bin/bash "${username}"
  usermod -aG sudo "${username}"
  usermod -aG docker "${username}"
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
  jupyter \
  django \
  flask \
  fastapi \
  sqlalchemy

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
  prettier \
  webpack \
  parcel \
  vite

# Configure Git basics
sudo -u "${username}" git config --global init.defaultBranch main
sudo -u "${username}" git config --global pull.rebase false

# Create development directories
sudo -u "${username}" mkdir -p "/home/${username}/workspace"
sudo -u "${username}" mkdir -p "/home/${username}/projects"
sudo -u "${username}" mkdir -p "/home/${username}/python_projects"
sudo -u "${username}" mkdir -p "/home/${username}/node_projects"
sudo -u "${username}" mkdir -p "/home/${username}/go_projects"
sudo -u "${username}" mkdir -p "/home/${username}/venvs"

# Create a default Python virtual environment
sudo -u "${username}" python3 -m venv "/home/${username}/venvs/default"

# Set npm global directory
sudo -u "${username}" mkdir -p "/home/${username}/.npm-global"
sudo -u "${username}" npm config set prefix "/home/${username}/.npm-global"

# Add paths to bashrc
echo 'export PATH="$HOME/.local/bin:$PATH"' >> "/home/${username}/.bashrc"
echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> "/home/${username}/.bashrc"
echo 'export PATH="/usr/local/go/bin:$PATH"' >> "/home/${username}/.bashrc"
echo 'export GOPATH="$HOME/go_projects"' >> "/home/${username}/.bashrc"
echo 'export PATH="$GOPATH/bin:$PATH"' >> "/home/${username}/.bashrc"
echo 'alias activate="source ~/venvs/default/bin/activate"' >> "/home/${username}/.bashrc"

# Install File Browser for web-based file management
wget -O filebrowser.tar.gz https://github.com/filebrowser/filebrowser/releases/latest/download/linux-amd64-filebrowser.tar.gz
tar -xzf filebrowser.tar.gz
mv filebrowser /usr/local/bin/
rm filebrowser.tar.gz

# Create File Browser service script
cat > "/home/${username}/start-filebrowser.sh" << 'EOF'
#!/bin/bash
cd /home/coder
filebrowser -a 0.0.0.0 -p 8081 -r /home/coder --noauth
EOF
chmod +x "/home/${username}/start-filebrowser.sh"

# Set proper ownership
chown -R "${username}:${username}" "/home/${username}"

echo "Full Stack Development Environment Ready!"
echo "Node.js Version: $(node --version)"
echo "Python Version: $(python3 --version)"
echo "Go Version: $(go version 2>/dev/null || echo 'Go installed, restart terminal')"
echo "Docker Version: $(docker --version)"
echo "File Browser available at: http://localhost:8081"
echo "Python virtual environment: ~/venvs/default"
echo "Use 'activate' command to activate the Python virtual environment"
echo "Run './start-filebrowser.sh' to start the file browser"
