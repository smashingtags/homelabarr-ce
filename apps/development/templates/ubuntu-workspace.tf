terraform {
  required_providers {
    coder = {
      source  = "coder/coder"
      version = "~> 0.12.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.0"
    }
  }
}

# CPU allocation parameter
data "coder_parameter" "cpu" {
  name         = "cpu"
  display_name = "CPU Cores"
  description  = "Number of CPU cores to allocate"
  default      = "1"
  type         = "number"
  mutable      = true
  validation {
    min = 1
    max = 4
  }
}

# Memory allocation parameter
data "coder_parameter" "memory" {
  name         = "memory"
  display_name = "Memory (GB)"
  description  = "Amount of memory to allocate in GB"
  default      = "2"
  type         = "number"
  mutable      = true
  validation {
    min = 1
    max = 8
  }
}

# Development tools selection
data "coder_parameter" "dev_tools" {
  name         = "dev_tools"
  display_name = "Development Tools"
  description  = "Select development tools to install"
  default      = "basic"
  type         = "string"
  mutable      = false
  option {
    name        = "Basic Tools"
    description = "Git, Vim, Nano, basic utilities"
    value       = "basic"
  }
  option {
    name        = "Python Development"
    description = "Python 3, pip, venv, common packages"
    value       = "python"
  }
  option {
    name        = "Node.js Development"
    description = "Node.js LTS, npm, yarn"
    value       = "nodejs"
  }
  option {
    name        = "Full Stack"
    description = "Python, Node.js, and additional tools"
    value       = "fullstack"
  }
}

# Docker provider configuration
provider "docker" {
  host = "unix:///var/run/docker.sock"
}

# Workspace agent configuration
data "coder_workspace" "me" {}
data "coder_workspace_owner" "me" {}

# Agent authentication
resource "coder_agent" "main" {
  arch                   = "amd64"
  os                     = "linux"
  startup_script_timeout = 180
  
  # Startup script based on selected tools
  startup_script = templatefile("${path.module}/startup-scripts/ubuntu-${data.coder_parameter.dev_tools.value}.sh", {
    username = "coder"
  })

  # Environment variables
  env = {
    GIT_AUTHOR_NAME     = coalesce(data.coder_workspace_owner.me.full_name, data.coder_workspace_owner.me.name)
    GIT_AUTHOR_EMAIL    = data.coder_workspace_owner.me.email
    GIT_COMMITTER_NAME  = coalesce(data.coder_workspace_owner.me.full_name, data.coder_workspace_owner.me.name)
    GIT_COMMITTER_EMAIL = data.coder_workspace_owner.me.email
    EDITOR              = "vim"
  }

  # Directory for the workspace
  dir = "/home/coder"
  
  # Connection timeout
  connection_timeout = 180
}

# Terminal application
resource "coder_app" "terminal" {
  agent_id     = coder_agent.main.id
  slug         = "terminal"
  display_name = "Terminal"
  icon         = "/icon/terminal.svg"
  command      = "bash"
  share        = "owner"
}

# File manager (if available)
resource "coder_app" "filebrowser" {
  count        = data.coder_parameter.dev_tools.value == "fullstack" ? 1 : 0
  agent_id     = coder_agent.main.id
  slug         = "filebrowser"
  display_name = "File Browser"
  url          = "http://localhost:8081"
  icon         = "/icon/folder.svg"
  subdomain    = false
  share        = "owner"

  healthcheck {
    url       = "http://localhost:8081/health"
    interval  = 3
    threshold = 10
  }
}

# Docker volume for persistent storage
resource "docker_volume" "workspace" {
  name = "coder-${data.coder_workspace.me.id}-workspace"
  lifecycle {
    ignore_changes = all
  }
  labels {
    label = "coder.workspace_id"
    value = data.coder_workspace.me.id
  }
  labels {
    label = "coder.workspace_name"
    value = data.coder_workspace.me.name
  }
  labels {
    label = "coder.workspace_owner"
    value = data.coder_workspace_owner.me.name
  }
}

# Docker container for the workspace
resource "docker_container" "workspace" {
  count = data.coder_workspace.me.start_count
  image = "ubuntu:22.04"
  name  = "coder-${data.coder_workspace_owner.me.name}-${data.coder_workspace.me.name}"
  
  # CPU and memory configuration
  cpu_shares = data.coder_parameter.cpu.value * 1024
  memory     = data.coder_parameter.memory.value * 1024
  
  # Network configuration
  hostname = "coder-${data.coder_workspace.me.name}"
  
  # Volume mounts
  volumes {
    container_path = "/home/coder"
    volume_name    = docker_volume.workspace.name
  }
  
  # Timezone configuration
  volumes {
    container_path = "/etc/localtime"
    host_path      = "/etc/localtime"
    read_only      = true
  }
  
  # Environment variables
  env = [
    "CODER_AGENT_TOKEN=${coder_agent.main.token}",
    "DEBIAN_FRONTEND=noninteractive",
    "TZ=UTC"
  ]
  
  # Keep container running
  command = ["sh", "-c", "sleep infinity"]
  
  # Container lifecycle
  lifecycle {
    ignore_changes = [
      env,
      command,
    ]
  }
  
  # Labels for identification
  labels {
    label = "coder.workspace_id"
    value = data.coder_workspace.me.id
  }
  labels {
    label = "coder.workspace_name"
    value = data.coder_workspace.me.name
  }
  labels {
    label = "coder.workspace_owner"
    value = data.coder_workspace_owner.me.name
  }
}

# Metadata for template information
resource "coder_metadata" "workspace_info" {
  count       = data.coder_workspace.me.start_count
  resource_id = docker_container.workspace[0].id

  item {
    key   = "CPU Cores"
    value = data.coder_parameter.cpu.value
  }
  
  item {
    key   = "Memory"
    value = "${data.coder_parameter.memory.value} GB"
  }
  
  item {
    key   = "Development Tools"
    value = data.coder_parameter.dev_tools.value
  }
  
  item {
    key   = "Container Image"
    value = "ubuntu:22.04"
  }
  
  item {
    key   = "Workspace Type"
    value = "Basic Ubuntu Environment"
  }
}