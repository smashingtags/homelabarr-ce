terraform {
  required_providers {
    coder = {
      source  = "coder/coder"
      version = "~> 0.22.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.0"
    }
  }
}

# Configuration
locals {
  username = data.coder_workspace.me.owner
}

data "coder_provisioner" "me" {
}

data "coder_workspace" "me" {
}

# Parameters
data "coder_parameter" "cpu" {
  name         = "cpu"
  display_name = "CPU Cores"
  description  = "Number of CPU cores for the workspace"
  type         = "number"
  default      = 2
  mutable      = true
  validation {
    min = 1
    max = 8
  }
}

data "coder_parameter" "memory" {
  name         = "memory"
  display_name = "Memory (GB)"
  description  = "Amount of memory in GB"
  type         = "number"
  default      = 4
  mutable      = true
  validation {
    min = 1
    max = 16
  }
}

data "coder_parameter" "disk_size" {
  name         = "disk_size"
  display_name = "Disk Size (GB)"
  description  = "Persistent disk size in GB"
  type         = "number"
  default      = 20
  mutable      = false
  validation {
    min = 10
    max = 100
  }
}

data "coder_parameter" "docker_version" {
  name         = "docker_version"
  display_name = "Docker Version"
  description  = "Docker version to install"
  type         = "string"
  default      = "latest"
  mutable      = false
  option {
    name  = "Latest"
    value = "latest"
  }
  option {
    name  = "24.0"
    value = "24.0"
  }
  option {
    name  = "23.0"
    value = "23.0"
  }
}

# Docker provider
provider "docker" {}

# Main container
resource "docker_image" "workspace" {
  name = "ubuntu:22.04"
  keep_locally = true
}

resource "docker_volume" "workspace_data" {
  name = "coder-${data.coder_workspace.me.id}-data"
}

resource "docker_container" "workspace" {
  count = data.coder_workspace.me.start_count
  image = docker_image.workspace.image_id
  name  = "coder-${data.coder_workspace.me.owner}-${data.coder_workspace.me.name}"
  
  # Resource configuration
  memory = data.coder_parameter.memory.value * 1024
  cpus   = data.coder_parameter.cpu.value
  
  # Network configuration
  hostname = data.coder_workspace.me.name
  
  # Volumes
  volumes {
    container_path = "/home/coder"
    volume_name    = docker_volume.workspace_data.name
  }
  
  volumes {
    container_path = "/var/run/docker.sock"
    host_path      = "/var/run/docker.sock"
  }
  
  # Environment variables
  env = [
    "CODER_AGENT_TOKEN=${coder_agent.main.token}",
    "DOCKER_VERSION=${data.coder_parameter.docker_version.value}",
    "WORKSPACE_CPU=${data.coder_parameter.cpu.value}",
    "WORKSPACE_MEMORY=${data.coder_parameter.memory.value}",
  ]
  
  # Keep container running
  command = [
    "sh", "-c",
    <<-EOT
    # Create coder user
    useradd --create-home --shell=/bin/bash --uid=1000 --gid=0 coder
    echo "coder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/coder
    
    # Install essential packages
    apt-get update && apt-get install -y \
      curl \
      wget \
      git \
      vim \
      nano \
      htop \
      unzip \
      software-properties-common \
      apt-transport-https \
      ca-certificates \
      gnupg \
      lsb-release \
      build-essential \
      python3 \
      python3-pip \
      nodejs \
      npm \
      jq
    
    # Install Docker
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    usermod -aG docker coder
    
    # Install Docker Compose
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    
    # Install additional development tools
    npm install -g yarn pnpm
    pip3 install docker-compose
    
    # Start Coder agent
    sudo -u coder --preserve-env=CODER_AGENT_TOKEN -- bash -c '
      cd /home/coder
      while true; do
        coder agent
        sleep 1
      done
    ' &
    
    # Keep container running
    sleep infinity
    EOT
  ]
  
  # Health check
  healthcheck {
    test     = ["CMD", "curl", "-f", "http://localhost:8080/healthz"]
    interval = "30s"
    timeout  = "10s"
    retries  = 3
  }
}

# Coder agent
resource "coder_agent" "main" {
  arch           = data.coder_provisioner.me.arch
  os             = data.coder_provisioner.me.os
  startup_script_behavior = "blocking"
  startup_script = <<-EOT
    #!/bin/bash
    set -e
    
    # Update package list
    sudo apt-get update
    
    # Ensure proper permissions
    sudo chown -R coder:root /home/coder
    
    # Create workspace directories
    mkdir -p /home/coder/workspace
    mkdir -p /home/coder/.local/bin
    
    # Install code-server (VS Code in browser)
    curl -fsSL https://code-server.dev/install.sh | sh
    
    # Configure code-server
    mkdir -p ~/.config/code-server
    cat > ~/.config/code-server/config.yaml <<EOF
bind-addr: 0.0.0.0:8080
auth: none
password: ""
cert: false
EOF
    
    # Install VS Code extensions
    code-server --install-extension ms-python.python
    code-server --install-extension ms-vscode.vscode-typescript-next
    code-server --install-extension ms-azuretools.vscode-docker
    code-server --install-extension golang.go
    code-server --install-extension rust-lang.rust-analyzer
    
    # Start code-server in background
    nohup code-server --bind-addr 0.0.0.0:8080 /home/coder/workspace > /tmp/code-server.log 2>&1 &
    
    # Install Go
    wget https://go.dev/dl/go1.21.5.linux-amd64.tar.gz
    sudo tar -C /usr/local -xzf go1.21.5.linux-amd64.tar.gz
    echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
    
    # Install Rust
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source ~/.cargo/env
    
    # Configure development environment
    echo 'export WORKSPACE_CPU=${data.coder_parameter.cpu.value}' >> ~/.bashrc
    echo 'export WORKSPACE_MEMORY=${data.coder_parameter.memory.value}' >> ~/.bashrc
    echo 'export DOCKER_VERSION=${data.coder_parameter.docker_version.value}' >> ~/.bashrc
    
    # Create welcome script
    cat > /home/coder/welcome.sh <<'EOF'
#!/bin/bash
echo "🚀 Docker Development Workspace"
echo "================================"
echo "CPU Cores: $WORKSPACE_CPU"
echo "Memory: ${WORKSPACE_MEMORY}GB"
echo "Docker: $DOCKER_VERSION"
echo ""
echo "🔧 Available Tools:"
echo "- Docker & Docker Compose"
echo "- Node.js $(node --version) & npm"
echo "- Python $(python3 --version)"
echo "- Go $(go version 2>/dev/null || echo 'Installing...')"
echo "- Rust $(rustc --version 2>/dev/null || echo 'Installing...')"
echo ""
echo "🌐 Services:"
echo "- VS Code Server: http://localhost:8080"
echo ""
echo "📁 Workspace: /home/coder/workspace"
echo "🐳 Docker socket: Available for container management"
EOF
    chmod +x /home/coder/welcome.sh
    
    # Run welcome script
    /home/coder/welcome.sh
  EOT
}

# VS Code Server app
resource "coder_app" "code-server" {
  agent_id     = coder_agent.main.id
  slug         = "code-server"
  display_name = "VS Code Server"
  url          = "http://localhost:8080?folder=/home/coder/workspace"
  icon         = "/icon/code.svg"
  subdomain    = false
  share        = "owner"
  
  healthcheck {
    url       = "http://localhost:8080/healthz"
    interval  = 30
    threshold = 5
  }
}

# Terminal app
resource "coder_app" "terminal" {
  agent_id     = coder_agent.main.id
  slug         = "terminal"
  display_name = "Terminal"
  command      = "bash"
  icon         = "/icon/terminal.svg"
  share        = "owner"
}

# Docker management app
resource "coder_app" "docker" {
  agent_id     = coder_agent.main.id
  slug         = "docker"
  display_name = "Docker Status"
  command      = "docker ps"
  icon         = "/icon/docker.svg"
  share        = "owner"
}

# Metadata
resource "coder_metadata" "workspace_info" {
  count       = data.coder_workspace.me.start_count
  resource_id = docker_container.workspace[0].id
  
  item {
    key   = "CPU Cores"
    value = data.coder_parameter.cpu.value
  }
  
  item {
    key   = "Memory"
    value = "${data.coder_parameter.memory.value}GB"
  }
  
  item {
    key   = "Disk Size"
    value = "${data.coder_parameter.disk_size.value}GB"
  }
  
  item {
    key   = "Docker Version"
    value = data.coder_parameter.docker_version.value
  }
  
  item {
    key   = "Container ID"
    value = docker_container.workspace[0].id
  }
}