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
    min = 2
    max = 16
  }
}

data "coder_parameter" "python_version" {
  name         = "python_version"
  display_name = "Python Version"
  description  = "Python version to use"
  type         = "string"
  default      = "3.11"
  mutable      = false
  option {
    name  = "Python 3.12"
    value = "3.12"
  }
  option {
    name  = "Python 3.11"
    value = "3.11"
  }
  option {
    name  = "Python 3.10"
    value = "3.10"
  }
  option {
    name  = "Python 3.9"
    value = "3.9"
  }
}

data "coder_parameter" "framework" {
  name         = "framework"
  display_name = "Framework Stack"
  description  = "Pre-installed Python frameworks and tools"
  type         = "string"
  default      = "data-science"
  mutable      = false
  option {
    name  = "Data Science (Pandas, NumPy, Jupyter)"
    value = "data-science"
  }
  option {
    name  = "Web Development (Django, Flask, FastAPI)"
    value = "web-dev"
  }
  option {
    name  = "Machine Learning (TensorFlow, PyTorch, Scikit-learn)"
    value = "ml"
  }
  option {
    name  = "Full Stack (Web + Data Science + ML)"
    value = "full-stack"
  }
  option {
    name  = "Minimal (Python + pip only)"
    value = "minimal"
  }
}

data "coder_parameter" "package_manager" {
  name         = "package_manager"
  display_name = "Package Manager"
  description  = "Python package manager preference"
  type         = "string"
  default      = "pip"
  mutable      = true
  option {
    name  = "pip"
    value = "pip"
  }
  option {
    name  = "poetry"
    value = "poetry"
  }
  option {
    name  = "conda"
    value = "conda"
  }
}

data "coder_parameter" "jupyter_enabled" {
  name         = "jupyter_enabled"
  display_name = "Enable Jupyter"
  description  = "Install and configure Jupyter Lab/Notebook"
  type         = "bool"
  default      = true
  mutable      = false
}

# Docker provider
provider "docker" {}

# Docker image
resource "docker_image" "workspace" {
  name = "python:${data.coder_parameter.python_version.value}-bullseye"
  keep_locally = true
}

resource "docker_volume" "workspace_data" {
  name = "coder-${data.coder_workspace.me.id}-python-data"
}

resource "docker_container" "workspace" {
  count = data.coder_workspace.me.start_count
  image = docker_image.workspace.image_id
  name  = "coder-${data.coder_workspace.me.owner}-${data.coder_workspace.me.name}-python"
  
  # Resource configuration
  memory = data.coder_parameter.memory.value * 1024
  cpus   = data.coder_parameter.cpu.value
  
  # Network configuration
  hostname = "${data.coder_workspace.me.name}-python"
  
  # Volumes
  volumes {
    container_path = "/home/coder"
    volume_name    = docker_volume.workspace_data.name
  }
  
  # Environment variables
  env = [
    "CODER_AGENT_TOKEN=${coder_agent.main.token}",
    "PYTHON_VERSION=${data.coder_parameter.python_version.value}",
    "FRAMEWORK_STACK=${data.coder_parameter.framework.value}",
    "PACKAGE_MANAGER=${data.coder_parameter.package_manager.value}",
    "JUPYTER_ENABLED=${data.coder_parameter.jupyter_enabled.value}",
    "PYTHONUNBUFFERED=1",
    "PIP_NO_CACHE_DIR=1",
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
      build-essential \
      pkg-config \
      libffi-dev \
      libssl-dev \
      zlib1g-dev \
      libjpeg-dev \
      libpng-dev \
      libfreetype6-dev \
      libblas-dev \
      liblapack-dev \
      gfortran \
      sqlite3 \
      libsqlite3-dev \
      postgresql-client \
      libpq-dev \
      redis-tools \
      jq \
      tree \
      ripgrep \
      fd-find
    
    # Upgrade pip
    python -m pip install --upgrade pip setuptools wheel
    
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
    test     = ["CMD", "python", "--version"]
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
    mkdir -p /home/coder/projects
    mkdir -p /home/coder/notebooks
    
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
    
    # Install VS Code extensions for Python development
    code-server --install-extension ms-python.python
    code-server --install-extension ms-python.pylint
    code-server --install-extension ms-python.flake8
    code-server --install-extension ms-python.black-formatter
    code-server --install-extension ms-python.isort
    code-server --install-extension ms-toolsai.jupyter
    code-server --install-extension njpwerner.autodocstring
    code-server --install-extension ms-python.debugpy
    code-server --install-extension charliermarsh.ruff
    
    # Install package manager
    case "${data.coder_parameter.package_manager.value}" in
      "poetry")
        echo "Installing Poetry..."
        curl -sSL https://install.python-poetry.org | python3 -
        export PATH="$HOME/.local/bin:$PATH"
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
        ;;
      "conda")
        echo "Installing Miniconda..."
        wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
        bash Miniconda3-latest-Linux-x86_64.sh -b -p $HOME/miniconda
        export PATH="$HOME/miniconda/bin:$PATH"
        echo 'export PATH="$HOME/miniconda/bin:$PATH"' >> ~/.bashrc
        conda init bash
        ;;
      *)
        echo "Using pip as package manager..."
        python -m pip install --upgrade pip setuptools wheel
        ;;
    esac
    
    # Install framework-specific packages
    case "${data.coder_parameter.framework.value}" in
      "data-science")
        echo "Installing Data Science stack..."
        pip install \
          pandas \
          numpy \
          matplotlib \
          seaborn \
          plotly \
          scipy \
          statsmodels \
          openpyxl \
          xlsxwriter \
          beautifulsoup4 \
          requests \
          sqlalchemy \
          psycopg2-binary \
          pymongo
        ;;
      "web-dev")
        echo "Installing Web Development stack..."
        pip install \
          django \
          flask \
          fastapi \
          uvicorn \
          gunicorn \
          celery \
          redis \
          requests \
          httpx \
          sqlalchemy \
          alembic \
          psycopg2-binary \
          python-multipart \
          jinja2 \
          wtforms
        ;;
      "ml")
        echo "Installing Machine Learning stack..."
        pip install \
          scikit-learn \
          tensorflow \
          torch \
          torchvision \
          transformers \
          xgboost \
          lightgbm \
          catboost \
          joblib \
          mlflow \
          wandb \
          optuna \
          shap \
          lime
        ;;
      "full-stack")
        echo "Installing Full Stack (all frameworks)..."
        pip install \
          pandas numpy matplotlib seaborn plotly scipy statsmodels \
          django flask fastapi uvicorn gunicorn \
          scikit-learn tensorflow torch torchvision \
          requests httpx sqlalchemy psycopg2-binary \
          beautifulsoup4 celery redis jinja2 \
          transformers xgboost lightgbm \
          openpyxl xlsxwriter
        ;;
      "minimal")
        echo "Installing minimal Python tools..."
        pip install \
          requests \
          python-dotenv
        ;;
    esac
    
    # Install common development tools
    pip install \
      black \
      flake8 \
      isort \
      mypy \
      pytest \
      pytest-cov \
      pytest-mock \
      ipython \
      ipdb \
      python-dotenv \
      click \
      typer \
      rich \
      tqdm
    
    # Install Jupyter if enabled
    if [ "${data.coder_parameter.jupyter_enabled.value}" = "true" ]; then
      echo "Installing Jupyter Lab..."
      pip install \
        jupyterlab \
        jupyter \
        notebook \
        jupyterlab-git \
        ipywidgets \
        jupyterlab-lsp \
        python-lsp-server
      
      # Configure Jupyter
      jupyter lab --generate-config
      cat >> ~/.jupyter/jupyter_lab_config.py <<'EOF'
c.ServerApp.ip = '0.0.0.0'
c.ServerApp.port = 8888
c.ServerApp.open_browser = False
c.ServerApp.token = ''
c.ServerApp.password = ''
c.ServerApp.allow_root = True
c.ServerApp.allow_origin = '*'
c.ServerApp.disable_check_xsrf = True
EOF
    fi
    
    # Set up Git configuration
    git config --global init.defaultBranch main
    git config --global core.editor "code-server --wait"
    
    # Create project templates
    mkdir -p /home/coder/templates
    
    # Flask Template
    cd /home/coder/templates
    mkdir flask-template
    cd flask-template
    
    cat > app.py <<'EOF'
from flask import Flask, jsonify, request
import os

app = Flask(__name__)

@app.route('/')
def home():
    return jsonify({
        'message': '🐍 Welcome to your Python Flask API!',
        'framework': '${data.coder_parameter.framework.value}',
        'python_version': '${data.coder_parameter.python_version.value}',
        'package_manager': '${data.coder_parameter.package_manager.value}',
        'jupyter_enabled': '${data.coder_parameter.jupyter_enabled.value}'
    })

@app.route('/health')
def health():
    return jsonify({'status': 'OK', 'framework': 'Flask'})

@app.route('/api/data')
def get_data():
    return jsonify({
        'data': [1, 2, 3, 4, 5],
        'message': 'Sample data from Python API'
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
EOF
    
    cat > requirements.txt <<'EOF'
Flask==3.0.0
requests==2.31.0
python-dotenv==1.0.0
EOF
    
    # FastAPI Template
    cd /home/coder/templates
    mkdir fastapi-template
    cd fastapi-template
    
    cat > main.py <<'EOF'
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List, Optional
import uvicorn

app = FastAPI(
    title="Python FastAPI Template",
    description="FastAPI template for Coder workspace",
    version="1.0.0"
)

class Item(BaseModel):
    id: int
    name: str
    description: Optional[str] = None

# Sample data
items = [
    {"id": 1, "name": "Item 1", "description": "First item"},
    {"id": 2, "name": "Item 2", "description": "Second item"},
]

@app.get("/")
async def root():
    return {
        "message": "🚀 FastAPI Python Workspace",
        "framework": "${data.coder_parameter.framework.value}",
        "python_version": "${data.coder_parameter.python_version.value}",
        "docs": "/docs"
    }

@app.get("/health")
async def health():
    return {"status": "OK", "framework": "FastAPI"}

@app.get("/items", response_model=List[Item])
async def get_items():
    return items

@app.get("/items/{item_id}", response_model=Item)
async def get_item(item_id: int):
    for item in items:
        if item["id"] == item_id:
            return item
    raise HTTPException(status_code=404, detail="Item not found")

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
EOF
    
    cat > requirements.txt <<'EOF'
fastapi==0.104.1
uvicorn[standard]==0.24.0
pydantic==2.5.0
EOF
    
    # Data Science Template (if enabled)
    if [ "${data.coder_parameter.framework.value}" = "data-science" ] || [ "${data.coder_parameter.framework.value}" = "full-stack" ]; then
      cd /home/coder/templates
      mkdir data-science-template
      cd data-science-template
      
      cat > analysis.py <<'EOF'
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns

# Sample data analysis
def create_sample_data():
    """Create sample dataset for analysis"""
    np.random.seed(42)
    data = {
        'name': [f'Item_{i}' for i in range(100)],
        'value': np.random.normal(50, 15, 100),
        'category': np.random.choice(['A', 'B', 'C'], 100),
        'date': pd.date_range('2023-01-01', periods=100, freq='D')
    }
    return pd.DataFrame(data)

def analyze_data(df):
    """Perform basic data analysis"""
    print("📊 Dataset Overview:")
    print(f"Shape: {df.shape}")
    print(f"Columns: {list(df.columns)}")
    print("\n📈 Summary Statistics:")
    print(df.describe())
    
    # Create visualization
    plt.figure(figsize=(12, 4))
    
    plt.subplot(1, 2, 1)
    df['value'].hist(bins=20, alpha=0.7)
    plt.title('Value Distribution')
    plt.xlabel('Value')
    plt.ylabel('Frequency')
    
    plt.subplot(1, 2, 2)
    sns.boxplot(data=df, x='category', y='value')
    plt.title('Value by Category')
    
    plt.tight_layout()
    plt.savefig('/home/coder/workspace/sample_analysis.png', dpi=150, bbox_inches='tight')
    plt.show()

if __name__ == "__main__":
    df = create_sample_data()
    analyze_data(df)
    print("✅ Analysis complete! Check /home/coder/workspace/sample_analysis.png")
EOF
      
      # Create sample Jupyter notebook
      cat > sample_notebook.ipynb <<'EOF'
{
 "cells": [
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "# Python Data Science Workspace\n",
    "\n",
    "Welcome to your Python data science environment!\n",
    "\n",
    "## Environment Info\n",
    "- Framework: ${data.coder_parameter.framework.value}\n",
    "- Python: ${data.coder_parameter.python_version.value}\n",
    "- Package Manager: ${data.coder_parameter.package_manager.value}"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "import pandas as pd\n",
    "import numpy as np\n",
    "import matplotlib.pyplot as plt\n",
    "import seaborn as sns\n",
    "\n",
    "# Set style\n",
    "plt.style.use('default')\n",
    "sns.set_palette('husl')\n",
    "\n",
    "print('📊 Libraries loaded successfully!')\n",
    "print(f'Pandas: {pd.__version__}')\n",
    "print(f'NumPy: {np.__version__}')"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# Create sample data\n",
    "np.random.seed(42)\n",
    "data = pd.DataFrame({\n",
    "    'x': np.random.randn(100),\n",
    "    'y': np.random.randn(100),\n",
    "    'category': np.random.choice(['A', 'B', 'C'], 100)\n",
    "})\n",
    "\n",
    "print('📈 Sample data created:')\n",
    "data.head()"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# Create visualization\n",
    "plt.figure(figsize=(10, 6))\n",
    "sns.scatterplot(data=data, x='x', y='y', hue='category', alpha=0.7)\n",
    "plt.title('Sample Data Visualization')\n",
    "plt.grid(True, alpha=0.3)\n",
    "plt.show()"
   ]
  }
 ],
 "metadata": {
  "kernelspec": {
   "display_name": "Python 3",
   "language": "python",
   "name": "python3"
  },
  "language_info": {
   "name": "python",
   "version": "${data.coder_parameter.python_version.value}"
  }
 },
 "nbformat": 4,
 "nbformat_minor": 4
}
EOF
    fi
    
    # Configure environment
    cat > /home/coder/.bashrc <<'EOF'
# Python Development Environment
export PYTHON_VERSION=${data.coder_parameter.python_version.value}
export FRAMEWORK_STACK=${data.coder_parameter.framework.value}
export PACKAGE_MANAGER=${data.coder_parameter.package_manager.value}
export JUPYTER_ENABLED=${data.coder_parameter.jupyter_enabled.value}

# Add local bin to PATH
export PATH="$HOME/.local/bin:$PATH"

# Conda setup (if using conda)
if [ "${data.coder_parameter.package_manager.value}" = "conda" ]; then
  export PATH="$HOME/miniconda/bin:$PATH"
fi

# Python specific aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'

# Development aliases
alias py='python'
alias py3='python3'
alias pip='python -m pip'
alias serve='python -m http.server 8000'
alias test='python -m pytest'
alias lint='flake8'
alias format='black .'
alias sort='isort .'

# Virtual environment aliases
alias venv='python -m venv'
alias activate='source venv/bin/activate'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit -m'
alias gp='git push'
alias gl='git pull'

# Jupyter aliases (if enabled)
if [ "$JUPYTER_ENABLED" = "true" ]; then
  alias jupyter-lab='jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root'
  alias notebook='jupyter notebook --ip=0.0.0.0 --port=8888 --no-browser --allow-root'
fi

# Package manager specific aliases
case "$PACKAGE_MANAGER" in
  "poetry")
    alias install='poetry install'
    alias add='poetry add'
    alias remove='poetry remove'
    alias shell='poetry shell'
    ;;
  "conda")
    alias install='conda install'
    alias add='conda install'
    alias remove='conda remove'
    alias env-list='conda env list'
    ;;
  *)
    alias install='pip install'
    alias add='pip install'
    alias remove='pip uninstall'
    alias freeze='pip freeze'
    ;;
esac

# Welcome message
echo "🐍 Python Development Workspace"
echo "==============================="
echo "Python: $(python --version)"
echo "pip: $(pip --version)"
echo "Framework Stack: $FRAMEWORK_STACK"
echo "Package Manager: $PACKAGE_MANAGER"
if [ "$JUPYTER_ENABLED" = "true" ]; then
  echo "Jupyter: Enabled"
fi
echo ""
echo "🔧 Available Templates:"
echo "- Flask API: /home/coder/templates/flask-template"
echo "- FastAPI: /home/coder/templates/fastapi-template"
if [ "$FRAMEWORK_STACK" = "data-science" ] || [ "$FRAMEWORK_STACK" = "full-stack" ]; then
  echo "- Data Science: /home/coder/templates/data-science-template"
fi
echo ""
echo "🌐 Services:"
echo "- VS Code Server: http://localhost:8080"
if [ "$JUPYTER_ENABLED" = "true" ]; then
  echo "- Jupyter Lab: http://localhost:8888"
fi
echo "- Flask/FastAPI: http://localhost:5000 or :8000 (when running)"
echo ""
echo "📁 Workspace: /home/coder/workspace"
echo "📓 Notebooks: /home/coder/notebooks"
EOF
    
    # Start code-server in background
    nohup code-server --bind-addr 0.0.0.0:8080 /home/coder/workspace > /tmp/code-server.log 2>&1 &
    
    # Start Jupyter Lab in background (if enabled)
    if [ "${data.coder_parameter.jupyter_enabled.value}" = "true" ]; then
      nohup jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root --notebook-dir=/home/coder/notebooks > /tmp/jupyter.log 2>&1 &
    fi
    
    # Create welcome project
    cd /home/coder/workspace
    mkdir -p hello-python
    cd hello-python
    
    cat > main.py <<'EOF'
#!/usr/bin/env python3
"""
Welcome to your Python Workspace!
"""

def main():
    print("🐍 Welcome to your Python Workspace!")
    print("=" * 40)
    print(f"Framework: ${data.coder_parameter.framework.value}")
    print(f"Python: ${data.coder_parameter.python_version.value}")
    print(f"Package Manager: ${data.coder_parameter.package_manager.value}")
    print(f"Jupyter: ${data.coder_parameter.jupyter_enabled.value}")
    print()
    print("🔧 Quick commands:")
    print("- Run Flask: cd /home/coder/templates/flask-template && python app.py")
    print("- Run FastAPI: cd /home/coder/templates/fastapi-template && python main.py")
    if "${data.coder_parameter.jupyter_enabled.value}" == "true":
        print("- Start Jupyter: jupyter-lab")
    print()
    print("📁 Your workspace is ready at /home/coder/workspace")

if __name__ == "__main__":
    main()
EOF
    
    chmod +x main.py
    
    echo "✅ Python workspace setup complete!"
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

# Jupyter Lab app (conditional)
resource "coder_app" "jupyter" {
  count        = data.coder_parameter.jupyter_enabled.value ? 1 : 0
  agent_id     = coder_agent.main.id
  slug         = "jupyter"
  display_name = "Jupyter Lab"
  url          = "http://localhost:8888"
  icon         = "/icon/jupyter.svg"
  subdomain    = false
  share        = "owner"
  
  healthcheck {
    url       = "http://localhost:8888"
    interval  = 30
    threshold = 5
  }
}

# Flask dev server app
resource "coder_app" "flask-server" {
  agent_id     = coder_agent.main.id
  slug         = "flask-server"
  display_name = "Flask Server"
  url          = "http://localhost:5000"
  icon         = "/icon/flask.svg"
  subdomain    = false
  share        = "owner"
  
  healthcheck {
    url       = "http://localhost:5000/health"
    interval  = 30
    threshold = 5
  }
}

# FastAPI server app
resource "coder_app" "fastapi-server" {
  agent_id     = coder_agent.main.id
  slug         = "fastapi-server"
  display_name = "FastAPI Server"
  url          = "http://localhost:8000"
  icon         = "/icon/fastapi.svg"
  subdomain    = false
  share        = "owner"
  
  healthcheck {
    url       = "http://localhost:8000/health"
    interval  = 30
    threshold = 5
  }
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
    key   = "Python Version"
    value = data.coder_parameter.python_version.value
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
    key   = "Jupyter Enabled"
    value = data.coder_parameter.jupyter_enabled.value
  }
  
  item {
    key   = "Container ID"
    value = docker_container.workspace[0].id
  }
}