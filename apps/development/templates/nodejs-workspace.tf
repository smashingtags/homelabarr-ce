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
    max = 6
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
    min = 2
    max = 12
  }
}

data "coder_parameter" "node_version" {
  name         = "node_version"
  display_name = "Node.js Version"
  description  = "Node.js version to install"
  type         = "string"
  default      = "20"
  mutable      = false
  option {
    name  = "Node.js 20 LTS"
    value = "20"
  }
  option {
    name  = "Node.js 18 LTS"
    value = "18"
  }
  option {
    name  = "Node.js 16 LTS"
    value = "16"
  }
  option {
    name  = "Latest"
    value = "latest"
  }
}

data "coder_parameter" "framework" {
  name         = "framework"
  display_name = "Framework Stack"
  description  = "Pre-installed framework and tools"
  type         = "string"
  default      = "full-stack"
  mutable      = false
  option {
    name  = "Full Stack (React + Express + Next.js)"
    value = "full-stack"
  }
  option {
    name  = "Frontend Only (React + Vue + Angular)"
    value = "frontend"
  }
  option {
    name  = "Backend Only (Express + Fastify + NestJS)"
    value = "backend"
  }
  option {
    name  = "Minimal (Node.js + npm only)"
    value = "minimal"
  }
}

data "coder_parameter" "package_manager" {
  name         = "package_manager"
  display_name = "Package Manager"
  description  = "Preferred package manager"
  type         = "string"
  default      = "npm"
  mutable      = true
  option {
    name  = "npm"
    value = "npm"
  }
  option {
    name  = "yarn"
    value = "yarn"
  }
  option {
    name  = "pnpm"
    value = "pnpm"
  }
}

# Docker provider
provider "docker" {}

# Docker image
resource "docker_image" "workspace" {
  name = "node:${data.coder_parameter.node_version.value}-bullseye"
  keep_locally = true
}

resource "docker_volume" "workspace_data" {
  name = "coder-${data.coder_workspace.me.id}-nodejs-data"
}

resource "docker_container" "workspace" {
  count = data.coder_workspace.me.start_count
  image = docker_image.workspace.image_id
  name  = "coder-${data.coder_workspace.me.owner}-${data.coder_workspace.me.name}-nodejs"
  
  # Resource configuration
  memory = data.coder_parameter.memory.value * 1024
  cpus   = data.coder_parameter.cpu.value
  
  # Network configuration
  hostname = "${data.coder_workspace.me.name}-nodejs"
  
  # Volumes
  volumes {
    container_path = "/home/coder"
    volume_name    = docker_volume.workspace_data.name
  }
  
  # Environment variables
  env = [
    "CODER_AGENT_TOKEN=${coder_agent.main.token}",
    "NODE_VERSION=${data.coder_parameter.node_version.value}",
    "FRAMEWORK_STACK=${data.coder_parameter.framework.value}",
    "PACKAGE_MANAGER=${data.coder_parameter.package_manager.value}",
    "NODE_ENV=development",
  ]
  
  # Working directory
  working_dir = "/home/coder"
  
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
      ca-certificates \
      gnupg \
      build-essential \
      python3 \
      python3-pip \
      jq \
      tree \
      ripgrep \
      fd-find
    
    # Install package managers
    npm install -g yarn pnpm @pnpm/exe
    
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
    test     = ["CMD", "node", "--version"]
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
    
    # Ensure proper permissions
    sudo chown -R coder:root /home/coder
    
    # Create workspace directories
    mkdir -p /home/coder/workspace
    mkdir -p /home/coder/.local/bin
    mkdir -p /home/coder/.config
    
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
    
    # Install VS Code extensions for Node.js development
    code-server --install-extension ms-vscode.vscode-typescript-next
    code-server --install-extension ms-vscode.vscode-javascript
    code-server --install-extension esbenp.prettier-vscode
    code-server --install-extension dbaeumer.vscode-eslint
    code-server --install-extension bradlc.vscode-tailwindcss
    code-server --install-extension ms-vscode.vscode-json
    code-server --install-extension formulahendry.auto-rename-tag
    code-server --install-extension christian-kohler.path-intellisense
    code-server --install-extension ms-vscode.vscode-typescript-next
    code-server --install-extension ms-playwright.playwright
    
    # Framework-specific installations
    case "${data.coder_parameter.framework.value}" in
      "full-stack")
        echo "Installing Full Stack tools..."
        npm install -g \
          create-react-app \
          create-next-app \
          @angular/cli \
          @vue/cli \
          express-generator \
          nodemon \
          concurrently \
          typescript \
          ts-node \
          @types/node
        ;;
      "frontend")
        echo "Installing Frontend tools..."
        npm install -g \
          create-react-app \
          create-next-app \
          @angular/cli \
          @vue/cli \
          @vitejs/create-app \
          typescript \
          webpack \
          parcel
        ;;
      "backend")
        echo "Installing Backend tools..."
        npm install -g \
          express-generator \
          @nestjs/cli \
          fastify-cli \
          nodemon \
          pm2 \
          typescript \
          ts-node \
          @types/node
        ;;
      "minimal")
        echo "Installing minimal Node.js tools..."
        npm install -g \
          nodemon \
          typescript \
          ts-node
        ;;
    esac
    
    # Install additional development tools based on package manager
    case "${data.coder_parameter.package_manager.value}" in
      "yarn")
        echo "Setting up Yarn as default..."
        npm install -g yarn
        echo 'alias npm="yarn"' >> ~/.bashrc
        ;;
      "pnpm")
        echo "Setting up pnpm as default..."
        npm install -g pnpm
        echo 'alias npm="pnpm"' >> ~/.bashrc
        ;;
    esac
    
    # Install common testing frameworks
    npm install -g \
      jest \
      mocha \
      chai \
      cypress \
      @playwright/test
    
    # Install utility tools
    npm install -g \
      dotenv-cli \
      cross-env \
      rimraf \
      http-server \
      live-server \
      json-server
    
    # Set up Git configuration
    git config --global init.defaultBranch main
    git config --global core.editor "code-server --wait"
    
    # Create project templates
    mkdir -p /home/coder/templates
    
    # React Template
    cd /home/coder/templates
    npx create-react-app react-template --template typescript
    cd react-template
    npm install @types/react @types/react-dom
    
    # Express Template
    cd /home/coder/templates
    mkdir express-template
    cd express-template
    npm init -y
    npm install express cors helmet morgan
    npm install -D @types/express @types/cors @types/helmet @types/morgan typescript ts-node nodemon
    
    cat > app.js <<'EOF'
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(helmet());
app.use(cors());
app.use(morgan('combined'));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Routes
app.get('/', (req, res) => {
  res.json({ 
    message: 'Node.js Express API',
    framework: '${data.coder_parameter.framework.value}',
    node_version: process.version,
    package_manager: '${data.coder_parameter.package_manager.value}'
  });
});

app.get('/health', (req, res) => {
  res.json({ status: 'OK', timestamp: new Date().toISOString() });
});

// Error handling
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Something went wrong!' });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Server running on http://localhost:$${PORT}`);
});
EOF
    
    # Update package.json with scripts
    cat > package.json <<'EOF'
{
  "name": "express-template",
  "version": "1.0.0",
  "description": "Express.js template for Coder workspace",
  "main": "app.js",
  "scripts": {
    "start": "node app.js",
    "dev": "nodemon app.js",
    "test": "jest"
  },
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5",
    "helmet": "^7.1.0",
    "morgan": "^1.10.0"
  },
  "devDependencies": {
    "@types/express": "^4.17.21",
    "@types/cors": "^2.8.17",
    "@types/helmet": "^4.0.0",
    "@types/morgan": "^1.9.9",
    "typescript": "^5.3.3",
    "ts-node": "^10.9.2",
    "nodemon": "^3.0.2",
    "jest": "^29.7.0"
  }
}
EOF
    
    # Configure environment
    cat > /home/coder/.bashrc <<'EOF'
# Node.js Development Environment
export NODE_ENV=development
export NODE_VERSION=${data.coder_parameter.node_version.value}
export FRAMEWORK_STACK=${data.coder_parameter.framework.value}
export PACKAGE_MANAGER=${data.coder_parameter.package_manager.value}

# Add local bin to PATH
export PATH="$HOME/.local/bin:$PATH"

# Node.js specific aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'

# Development aliases
alias serve='npx http-server -p 8000'
alias dev='npm run dev'
alias build='npm run build'
alias test='npm test'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit -m'
alias gp='git push'
alias gl='git pull'

# Package manager specific aliases
case "$PACKAGE_MANAGER" in
  "yarn")
    alias install='yarn install'
    alias add='yarn add'
    alias remove='yarn remove'
    ;;
  "pnpm")
    alias install='pnpm install'
    alias add='pnpm add'
    alias remove='pnpm remove'
    ;;
  *)
    alias install='npm install'
    alias add='npm install'
    alias remove='npm uninstall'
    ;;
esac

# Welcome message
echo "🚀 Node.js Development Workspace"
echo "==============================="
echo "Node.js: $(node --version)"
echo "npm: $(npm --version)"
echo "Framework Stack: $FRAMEWORK_STACK"
echo "Package Manager: $PACKAGE_MANAGER"
echo ""
echo "🔧 Available Templates:"
echo "- React TypeScript: /home/coder/templates/react-template"
echo "- Express API: /home/coder/templates/express-template"
echo ""
echo "🌐 Services:"
echo "- VS Code Server: http://localhost:8080"
echo "- Development Server: http://localhost:3000 (when running)"
echo ""
echo "📁 Workspace: /home/coder/workspace"
EOF
    
    # Start code-server in background
    nohup code-server --bind-addr 0.0.0.0:8080 /home/coder/workspace > /tmp/code-server.log 2>&1 &
    
    # Create welcome project
    cd /home/coder/workspace
    mkdir -p hello-node
    cd hello-node
    npm init -y
    npm install express
    
    cat > index.js <<'EOF'
const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.json({
    message: '🚀 Welcome to your Node.js Workspace!',
    framework: '${data.coder_parameter.framework.value}',
    node_version: process.version,
    package_manager: '${data.coder_parameter.package_manager.value}',
    cpu_cores: '${data.coder_parameter.cpu.value}',
    memory: '${data.coder_parameter.memory.value}GB'
  });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`🌐 Server running on http://localhost:$${PORT}`);
});
EOF
    
    echo "✅ Node.js workspace setup complete!"
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

# Development server app
resource "coder_app" "dev-server" {
  agent_id     = coder_agent.main.id
  slug         = "dev-server"
  display_name = "Development Server"
  url          = "http://localhost:3000"
  icon         = "/icon/node.svg"
  subdomain    = false
  share        = "owner"
  
  healthcheck {
    url       = "http://localhost:3000"
    interval  = 30
    threshold = 5
  }
}

# Package manager app
resource "coder_app" "package-manager" {
  agent_id     = coder_agent.main.id
  slug         = "package-info"
  display_name = "Package Info"
  command      = "${data.coder_parameter.package_manager.value} --version"
  icon         = "/icon/package.svg"
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
    key   = "Node.js Version"
    value = data.coder_parameter.node_version.value
  }
  
  item {
    key   = "Framework Stack"
    value = data.coder_parameter.framework.value
  }
  
  item {
    key   = "Package Manager"
    value = data.coder_parameter.package_manager.value
  }
  
  item {
    key   = "Container ID"
    value = docker_container.workspace[0].id
  }
}