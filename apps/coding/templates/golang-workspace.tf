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

data "coder_parameter" "go_version" {
  name         = "go_version"
  display_name = "Go Version"
  description  = "Go version to install"
  type         = "string"
  default      = "1.21"
  mutable      = false
  option {
    name  = "Go 1.22"
    value = "1.22"
  }
  option {
    name  = "Go 1.21"
    value = "1.21"
  }
  option {
    name  = "Go 1.20"
    value = "1.20"
  }
}

data "coder_parameter" "framework" {
  name         = "framework"
  display_name = "Framework Stack"
  description  = "Pre-installed Go frameworks and tools"
  type         = "string"
  default      = "web-api"
  mutable      = false
  option {
    name  = "Web API (Gin, Echo, Fiber)"
    value = "web-api"
  }
  option {
    name  = "Microservices (gRPC, Protobuf, Docker)"
    value = "microservices"
  }
  option {
    name  = "CLI Tools (Cobra, Viper, Logrus)"
    value = "cli-tools"
  }
  option {
    name  = "Full Stack (Web + Microservices + CLI)"
    value = "full-stack"
  }
  option {
    name  = "Minimal (Go standard library only)"
    value = "minimal"
  }
}

data "coder_parameter" "database" {
  name         = "database"
  display_name = "Database Support"
  description  = "Database drivers and tools to include"
  type         = "string"
  default      = "postgres"
  mutable      = false
  option {
    name  = "PostgreSQL"
    value = "postgres"
  }
  option {
    name  = "MySQL"
    value = "mysql"
  }
  option {
    name  = "MongoDB"
    value = "mongo"
  }
  option {
    name  = "Redis"
    value = "redis"
  }
  option {
    name  = "All Databases"
    value = "all"
  }
  option {
    name  = "None"
    value = "none"
  }
}

data "coder_parameter" "tools" {
  name         = "tools"
  display_name = "Development Tools"
  description  = "Additional development tools to install"
  type         = "string"
  default      = "standard"
  mutable      = false
  option {
    name  = "Standard (Air, Delve, Mockgen)"
    value = "standard"
  }
  option {
    name  = "Extended (+ Buf, Wire, Swagger)"
    value = "extended"
  }
  option {
    name  = "Minimal (Go toolchain only)"
    value = "minimal"
  }
}

# Docker provider
provider "docker" {}

# Docker image
resource "docker_image" "workspace" {
  name = "golang:${data.coder_parameter.go_version.value}-bullseye"
  keep_locally = true
}

resource "docker_volume" "workspace_data" {
  name = "coder-${data.coder_workspace.me.id}-go-data"
}

resource "docker_container" "workspace" {
  count = data.coder_workspace.me.start_count
  image = docker_image.workspace.image_id
  name  = "coder-${data.coder_workspace.me.owner}-${data.coder_workspace.me.name}-go"
  
  # Resource configuration
  memory = data.coder_parameter.memory.value * 1024
  cpus   = data.coder_parameter.cpu.value
  
  # Network configuration
  hostname = "${data.coder_workspace.me.name}-go"
  
  # Volumes
  volumes {
    container_path = "/home/coder"
    volume_name    = docker_volume.workspace_data.name
  }
  
  # Environment variables
  env = [
    "CODER_AGENT_TOKEN=${coder_agent.main.token}",
    "GO_VERSION=${data.coder_parameter.go_version.value}",
    "FRAMEWORK_STACK=${data.coder_parameter.framework.value}",
    "DATABASE_SUPPORT=${data.coder_parameter.database.value}",
    "DEV_TOOLS=${data.coder_parameter.tools.value}",
    "GOPATH=/home/coder/go",
    "GOROOT=/usr/local/go",
    "CGO_ENABLED=1",
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
      gcc \
      libc6-dev \
      sqlite3 \
      libsqlite3-dev \
      postgresql-client \
      libpq-dev \
      mysql-client \
      libmysqlclient-dev \
      redis-tools \
      protobuf-compiler \
      jq \
      tree \
      ripgrep \
      fd-find
    
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
    test     = ["CMD", "go", "version"]
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
    mkdir -p /home/coder/go/{bin,src,pkg}
    mkdir -p /home/coder/.local/bin
    mkdir -p /home/coder/.config
    mkdir -p /home/coder/projects
    
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
    
    # Install VS Code extensions for Go development
    code-server --install-extension golang.go
    code-server --install-extension ms-vscode.vscode-json
    code-server --install-extension ms-vscode.vscode-yaml
    code-server --install-extension redhat.vscode-xml
    code-server --install-extension ms-azuretools.vscode-docker
    code-server --install-extension ms-vscode.makefile-tools
    code-server --install-extension zxh404.vscode-proto3
    
    # Set up Go environment
    export GOPATH=/home/coder/go
    export GOROOT=/usr/local/go
    export PATH=$GOROOT/bin:$GOPATH/bin:$PATH
    
    # Install development tools based on selection
    case "${data.coder_parameter.tools.value}" in
      "standard"|"extended")
        echo "Installing standard Go development tools..."
        go install github.com/cosmtrek/air@latest
        go install github.com/go-delve/delve/cmd/dlv@latest
        go install golang.org/x/tools/cmd/goimports@latest
        go install golang.org/x/tools/cmd/godoc@latest
        go install golang.org/x/lint/golint@latest
        go install github.com/golang/mock/mockgen@latest
        go install honnef.co/go/tools/cmd/staticcheck@latest
        go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
        ;;
    esac
    
    if [ "${data.coder_parameter.tools.value}" = "extended" ]; then
      echo "Installing extended Go development tools..."
      go install github.com/google/wire/cmd/wire@latest
      go install github.com/bufbuild/buf/cmd/buf@latest
      go install github.com/swaggo/swag/cmd/swag@latest
      go install github.com/sqlc-dev/sqlc/cmd/sqlc@latest
      go install github.com/pressly/goose/v3/cmd/goose@latest
    fi
    
    # Install framework-specific packages
    case "${data.coder_parameter.framework.value}" in
      "web-api"|"full-stack")
        echo "Installing Web API frameworks..."
        go mod init workspace-setup
        go get github.com/gin-gonic/gin
        go get github.com/labstack/echo/v4
        go get github.com/gofiber/fiber/v2
        go get github.com/gorilla/mux
        go get github.com/gorilla/websocket
        go get github.com/rs/cors
        ;;
      "microservices"|"full-stack")
        echo "Installing Microservices tools..."
        go mod init workspace-setup
        go get google.golang.org/grpc
        go get google.golang.org/protobuf/proto
        go get github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-grpc-gateway
        go get github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2
        go get go.opentelemetry.io/otel
        go get github.com/hashicorp/consul/api
        ;;
      "cli-tools"|"full-stack")
        echo "Installing CLI development tools..."
        go mod init workspace-setup
        go get github.com/spf13/cobra
        go get github.com/spf13/viper
        go get github.com/sirupsen/logrus
        go get github.com/urfave/cli/v2
        go get github.com/fatih/color
        go get github.com/schollz/progressbar/v3
        ;;
    esac
    
    # Install database drivers based on selection
    case "${data.coder_parameter.database.value}" in
      "postgres"|"all")
        echo "Installing PostgreSQL driver..."
        go get github.com/lib/pq
        go get gorm.io/driver/postgres
        go get gorm.io/gorm
        ;;
    esac
    
    case "${data.coder_parameter.database.value}" in
      "mysql"|"all")
        echo "Installing MySQL driver..."
        go get github.com/go-sql-driver/mysql
        go get gorm.io/driver/mysql
        ;;
    esac
    
    case "${data.coder_parameter.database.value}" in
      "mongo"|"all")
        echo "Installing MongoDB driver..."
        go get go.mongodb.org/mongo-driver/mongo
        ;;
    esac
    
    case "${data.coder_parameter.database.value}" in
      "redis"|"all")
        echo "Installing Redis client..."
        go get github.com/go-redis/redis/v8
        ;;
    esac
    
    # Set up Git configuration
    git config --global init.defaultBranch main
    git config --global core.editor "code-server --wait"
    
    # Create project templates
    mkdir -p /home/coder/templates
    
    # Gin Web API Template
    cd /home/coder/templates
    mkdir gin-api-template
    cd gin-api-template
    go mod init gin-api-template
    
    cat > main.go <<'EOF'
package main

import (
    "net/http"
    "github.com/gin-gonic/gin"
)

type Response struct {
    Message       string `json:"message"`
    Framework     string `json:"framework"`
    GoVersion     string `json:"go_version"`
    DatabaseSupport string `json:"database_support"`
}

func main() {
    r := gin.Default()
    
    // Middleware
    r.Use(gin.Logger())
    r.Use(gin.Recovery())
    
    // Routes
    r.GET("/", func(c *gin.Context) {
        c.JSON(http.StatusOK, Response{
            Message:       "🚀 Welcome to your Go Gin API!",
            Framework:     "${data.coder_parameter.framework.value}",
            GoVersion:     "${data.coder_parameter.go_version.value}",
            DatabaseSupport: "${data.coder_parameter.database.value}",
        })
    })
    
    r.GET("/health", func(c *gin.Context) {
        c.JSON(http.StatusOK, gin.H{
            "status": "OK",
            "framework": "Gin",
        })
    })
    
    r.GET("/api/users", func(c *gin.Context) {
        users := []map[string]interface{}{
            {"id": 1, "name": "John Doe", "email": "john@example.com"},
            {"id": 2, "name": "Jane Smith", "email": "jane@example.com"},
        }
        c.JSON(http.StatusOK, gin.H{"users": users})
    })
    
    r.Run(":8080")
}
EOF
    
    go get github.com/gin-gonic/gin
    go mod tidy
    
    # CLI Tool Template
    cd /home/coder/templates
    mkdir cli-tool-template
    cd cli-tool-template
    go mod init cli-tool-template
    
    cat > main.go <<'EOF'
package main

import (
    "fmt"
    "os"
    "github.com/spf13/cobra"
    "github.com/spf13/viper"
)

var rootCmd = &cobra.Command{
    Use:   "cli-tool",
    Short: "A sample CLI tool built with Go",
    Long:  "A sample CLI tool template for Go development in Coder workspace",
    Run: func(cmd *cobra.Command, args []string) {
        fmt.Println("🚀 Go CLI Tool Template")
        fmt.Printf("Framework: %s\n", "${data.coder_parameter.framework.value}")
        fmt.Printf("Go Version: %s\n", "${data.coder_parameter.go_version.value}")
        fmt.Printf("Tools: %s\n", "${data.coder_parameter.tools.value}")
    },
}

var versionCmd = &cobra.Command{
    Use:   "version",
    Short: "Print the version number",
    Run: func(cmd *cobra.Command, args []string) {
        fmt.Println("CLI Tool v1.0.0")
    },
}

var configCmd = &cobra.Command{
    Use:   "config",
    Short: "Show configuration",
    Run: func(cmd *cobra.Command, args []string) {
        fmt.Println("Configuration:")
        fmt.Printf("  Framework: %s\n", viper.GetString("framework"))
        fmt.Printf("  Go Version: %s\n", viper.GetString("go_version"))
    },
}

func init() {
    rootCmd.AddCommand(versionCmd)
    rootCmd.AddCommand(configCmd)
    
    // Set default config values
    viper.SetDefault("framework", "${data.coder_parameter.framework.value}")
    viper.SetDefault("go_version", "${data.coder_parameter.go_version.value}")
}

func main() {
    if err := rootCmd.Execute(); err != nil {
        fmt.Println(err)
        os.Exit(1)
    }
}
EOF
    
    go get github.com/spf13/cobra
    go get github.com/spf13/viper
    go mod tidy
    
    # Microservice Template (if applicable)
    if [ "${data.coder_parameter.framework.value}" = "microservices" ] || [ "${data.coder_parameter.framework.value}" = "full-stack" ]; then
      cd /home/coder/templates
      mkdir microservice-template
      cd microservice-template
      go mod init microservice-template
      
      # Create proto file
      mkdir -p proto
      cat > proto/service.proto <<'EOF'
syntax = "proto3";

package service;

option go_package = "./proto";

service GreeterService {
    rpc SayHello (HelloRequest) returns (HelloResponse);
    rpc GetHealth (HealthRequest) returns (HealthResponse);
}

message HelloRequest {
    string name = 1;
}

message HelloResponse {
    string message = 1;
    string framework = 2;
    string go_version = 3;
}

message HealthRequest {}

message HealthResponse {
    string status = 1;
    string timestamp = 2;
}
EOF
      
      cat > main.go <<'EOF'
package main

import (
    "context"
    "log"
    "net"
    "time"
    "google.golang.org/grpc"
    pb "./proto"
)

type server struct {
    pb.UnimplementedGreeterServiceServer
}

func (s *server) SayHello(ctx context.Context, req *pb.HelloRequest) (*pb.HelloResponse, error) {
    return &pb.HelloResponse{
        Message:   "Hello " + req.Name + "!",
        Framework: "${data.coder_parameter.framework.value}",
        GoVersion: "${data.coder_parameter.go_version.value}",
    }, nil
}

func (s *server) GetHealth(ctx context.Context, req *pb.HealthRequest) (*pb.HealthResponse, error) {
    return &pb.HealthResponse{
        Status:    "OK",
        Timestamp: time.Now().Format(time.RFC3339),
    }, nil
}

func main() {
    lis, err := net.Listen("tcp", ":50051")
    if err != nil {
        log.Fatalf("Failed to listen: %v", err)
    }
    
    s := grpc.NewServer()
    pb.RegisterGreeterServiceServer(s, &server{})
    
    log.Println("🚀 gRPC server listening on :50051")
    if err := s.Serve(lis); err != nil {
        log.Fatalf("Failed to serve: %v", err)
    }
}
EOF
      
      go get google.golang.org/grpc
      go get google.golang.org/protobuf/proto
      go mod tidy
    fi
    
    # Configure environment
    cat > /home/coder/.bashrc <<'EOF'
# Go Development Environment
export GOPATH=/home/coder/go
export GOROOT=/usr/local/go
export PATH=$GOROOT/bin:$GOPATH/bin:$HOME/.local/bin:$PATH
export GO111MODULE=on
export CGO_ENABLED=1

# Workspace configuration
export GO_VERSION=${data.coder_parameter.go_version.value}
export FRAMEWORK_STACK=${data.coder_parameter.framework.value}
export DATABASE_SUPPORT=${data.coder_parameter.database.value}
export DEV_TOOLS=${data.coder_parameter.tools.value}

# Go specific aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'

# Development aliases
alias gobuild='go build'
alias gorun='go run'
alias gotest='go test'
alias gofmt='go fmt'
alias gomod='go mod'
alias gotidy='go mod tidy'
alias goget='go get'
alias goclean='go clean'

# Testing aliases
alias test='go test ./...'
alias testv='go test -v ./...'
alias testcover='go test -cover ./...'
alias bench='go test -bench=.'

# Build aliases
alias build='go build -o bin/'
alias install='go install'
alias cross-build='GOOS=linux GOARCH=amd64 go build'

# Linting and formatting
alias lint='golangci-lint run'
alias fmt='gofmt -s -w .'
alias imports='goimports -w .'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit -m'
alias gp='git push'
alias gl='git pull'

# Development server aliases
alias air='air'  # Hot reload
alias serve='go run main.go'

# Protocol buffers (if applicable)
if [ "$FRAMEWORK_STACK" = "microservices" ] || [ "$FRAMEWORK_STACK" = "full-stack" ]; then
  alias protoc-gen='protoc --go_out=. --go-grpc_out=. proto/*.proto'
fi

# Welcome message
echo "🐹 Go Development Workspace"
echo "=========================="
echo "Go: $(go version | cut -d' ' -f3)"
echo "GOPATH: $GOPATH"
echo "GOROOT: $GOROOT"
echo "Framework Stack: $FRAMEWORK_STACK"
echo "Database Support: $DATABASE_SUPPORT"
echo "Dev Tools: $DEV_TOOLS"
echo ""
echo "🔧 Available Templates:"
echo "- Gin Web API: /home/coder/templates/gin-api-template"
echo "- CLI Tool: /home/coder/templates/cli-tool-template"
if [ "$FRAMEWORK_STACK" = "microservices" ] || [ "$FRAMEWORK_STACK" = "full-stack" ]; then
  echo "- Microservice (gRPC): /home/coder/templates/microservice-template"
fi
echo ""
echo "🌐 Services:"
echo "- VS Code Server: http://localhost:8080"
echo "- Gin API: http://localhost:8080 (when running)"
if [ "$FRAMEWORK_STACK" = "microservices" ] || [ "$FRAMEWORK_STACK" = "full-stack" ]; then
  echo "- gRPC Server: localhost:50051 (when running)"
fi
echo ""
echo "📁 Workspace: /home/coder/workspace"
echo "📦 Go Path: /home/coder/go"
EOF
    
    # Start code-server in background
    nohup code-server --bind-addr 0.0.0.0:8080 /home/coder/workspace > /tmp/code-server.log 2>&1 &
    
    # Create welcome project
    cd /home/coder/workspace
    mkdir -p hello-go
    cd hello-go
    go mod init hello-go
    
    cat > main.go <<'EOF'
package main

import (
    "fmt"
    "runtime"
)

func main() {
    fmt.Println("🐹 Welcome to your Go Workspace!")
    fmt.Println("================================")
    fmt.Printf("Go Version: %s\n", runtime.Version())
    fmt.Printf("Framework: %s\n", "${data.coder_parameter.framework.value}")
    fmt.Printf("Database: %s\n", "${data.coder_parameter.database.value}")
    fmt.Printf("Tools: %s\n", "${data.coder_parameter.tools.value}")
    fmt.Printf("GOOS: %s\n", runtime.GOOS)
    fmt.Printf("GOARCH: %s\n", runtime.GOARCH)
    fmt.Printf("NumCPU: %d\n", runtime.NumCPU())
    fmt.Println()
    fmt.Println("🔧 Quick commands:")
    fmt.Println("- Run Gin API: cd /home/coder/templates/gin-api-template && go run main.go")
    fmt.Println("- Build CLI: cd /home/coder/templates/cli-tool-template && go build -o cli-tool")
    fmt.Println()
    fmt.Println("📁 Your workspace is ready at /home/coder/workspace")
}
EOF
    
    echo "✅ Go workspace setup complete!"
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

# Go development server app
resource "coder_app" "go-server" {
  agent_id     = coder_agent.main.id
  slug         = "go-server"
  display_name = "Go Server"
  url          = "http://localhost:8080"
  icon         = "/icon/go.svg"
  subdomain    = false
  share        = "owner"
  
  healthcheck {
    url       = "http://localhost:8080/health"
    interval  = 30
    threshold = 5
  }
}

# Go documentation app
resource "coder_app" "godoc" {
  agent_id     = coder_agent.main.id
  slug         = "godoc"
  display_name = "Go Documentation"
  command      = "godoc -http=:6060"
  icon         = "/icon/book.svg"
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
    key   = "Go Version"
    value = data.coder_parameter.go_version.value
  }
  
  item {
    key   = "Framework Stack"
    value = data.coder_parameter.framework.value
  }
  
  item {
    key   = "Database Support"
    value = data.coder_parameter.database.value
  }
  
  item {
    key   = "Development Tools"
    value = data.coder_parameter.tools.value
  }
  
  item {
    key   = "Container ID"
    value = docker_container.workspace[0].id
  }
}