# CLI Development Guide

## Overview

HomelabARR CE is undergoing modernization from shell scripts to a modern Go application with Bubble Tea TUI framework. This guide covers the development of the new CLI interface.

## Current CLI Architecture

### Existing Shell-Based CLI
```bash
# Current installation methods
./install.sh           # Full Mode installation
./install-local.sh     # Local Mode installation

# Current maintenance scripts
./scripts/backup.sh    # Backup functionality
./scripts/update.sh    # Update system
```

### Planned Go CLI Architecture
```
homelabarr-ce/
├── cmd/
│   ├── root.go          # Root command
│   ├── install.go       # Installation commands
│   ├── deploy.go        # Deployment commands
│   ├── manage.go        # Management commands
│   └── tui.go          # Terminal UI commands
├── internal/
│   ├── config/         # Configuration management
│   ├── docker/         # Docker integration
│   ├── installer/      # Installation logic
│   ├── tui/           # Bubble Tea components
│   └── utils/          # Utility functions
├── pkg/
│   ├── applications/   # Application definitions
│   ├── compose/        # Docker Compose handling
│   └── network/        # Network management
└── main.go            # Entry point
```

## Development Environment Setup

### Prerequisites
```bash
# Install Go 1.21+
wget https://go.dev/dl/go1.21.0.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.21.0.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin

# Verify installation
go version
```

### Development Dependencies
```bash
# Core dependencies
go mod init github.com/homelabarr/cli
go get github.com/spf13/cobra@latest
go get github.com/charmbracelet/bubbletea@latest
go get github.com/charmbracelet/lipgloss@latest
go get github.com/docker/docker/client@latest
go get gopkg.in/yaml.v3@latest

# Development tools
go install golang.org/x/tools/cmd/goimports@latest
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
```

## CLI Command Structure

### Root Command Design
```go
// cmd/root.go
package cmd

import (
    "github.com/spf13/cobra"
)

var rootCmd = &cobra.Command{
    Use:   "homelabarr",
    Short: "HomelabARR CE - Self-hosted media server stack",
    Long: `HomelabARR CE provides tools for deploying and managing
a comprehensive Docker-based media server stack.`,
    Version: "2.0.0",
}

func Execute() error {
    return rootCmd.Execute()
}

func init() {
    rootCmd.AddCommand(installCmd)
    rootCmd.AddCommand(deployCmd)
    rootCmd.AddCommand(manageCmd)
    rootCmd.AddCommand(tuiCmd)
}
```

### Installation Commands
```go
// cmd/install.go
var installCmd = &cobra.Command{
    Use:   "install",
    Short: "Install HomelabARR CE",
    Long:  `Install and configure HomelabARR CE components.`,
}

var installFullCmd = &cobra.Command{
    Use:   "full",
    Short: "Install Full Mode (Traefik + Authelia)",
    Run: func(cmd *cobra.Command, args []string) {
        installer.InstallFullMode()
    },
}

var installLocalCmd = &cobra.Command{
    Use:   "local",
    Short: "Install Local Mode (Direct Access)",
    Run: func(cmd *cobra.Command, args []string) {
        installer.InstallLocalMode()
    },
}

func init() {
    installCmd.AddCommand(installFullCmd)
    installCmd.AddCommand(installLocalCmd)
}
```

### Deployment Commands
```go
// cmd/deploy.go
var deployCmd = &cobra.Command{
    Use:   "deploy",
    Short: "Deploy applications",
    Long:  `Deploy and manage containerized applications.`,
}

var deployAppCmd = &cobra.Command{
    Use:   "app [application]",
    Short: "Deploy specific application",
    Args:  cobra.ExactArgs(1),
    Run: func(cmd *cobra.Command, args []string) {
        deployer.DeployApplication(args[0])
    },
}

var deployStackCmd = &cobra.Command{
    Use:   "stack [stack-name]",
    Short: "Deploy application stack",
    Args:  cobra.ExactArgs(1),
    Run: func(cmd *cobra.Command, args []string) {
        deployer.DeployStack(args[0])
    },
}
```

## Bubble Tea TUI Development

### TUI Architecture
```go
// internal/tui/model.go
package tui

import (
    "github.com/charmbracelet/bubbletea"
    "github.com/charmbracelet/lipgloss"
)

type Model struct {
    currentView string
    apps        []Application
    selected    int
    width       int
    height      int
}

type Application struct {
    Name        string
    Category    string
    Description string
    Status      string
    URL         string
}

func (m Model) Init() tea.Cmd {
    return tea.EnterAltScreen
}

func (m Model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
    switch msg := msg.(type) {
    case tea.KeyMsg:
        return m.handleKeyPress(msg)
    case tea.WindowSizeMsg:
        m.width = msg.Width
        m.height = msg.Height
        return m, nil
    }
    return m, nil
}

func (m Model) View() string {
    switch m.currentView {
    case "main":
        return m.renderMainMenu()
    case "apps":
        return m.renderApplicationList()
    case "deploy":
        return m.renderDeploymentView()
    }
    return "Unknown view"
}
```

### Main Menu Implementation
```go
// internal/tui/main_menu.go
func (m Model) renderMainMenu() string {
    title := titleStyle.Render("HomelabARR CE")
    
    options := []string{
        "1. Install HomelabARR",
        "2. Deploy Applications",
        "3. Manage Services",
        "4. System Status",
        "5. Backup & Restore",
        "6. Settings",
        "q. Quit",
    }
    
    menu := strings.Join(options, "\n")
    
    return lipgloss.JoinVertical(
        lipgloss.Center,
        title,
        "",
        menu,
    )
}
```

### Application List View
```go
// internal/tui/app_list.go
func (m Model) renderApplicationList() string {
    var rows []string
    
    header := fmt.Sprintf("%-20s %-15s %-10s %s",
        "Application", "Category", "Status", "URL")
    rows = append(rows, headerStyle.Render(header))
    
    for i, app := range m.apps {
        style := itemStyle
        if i == m.selected {
            style = selectedStyle
        }
        
        row := fmt.Sprintf("%-20s %-15s %-10s %s",
            app.Name, app.Category, app.Status, app.URL)
        rows = append(rows, style.Render(row))
    }
    
    return lipgloss.JoinVertical(lipgloss.Left, rows...)
}
```

## Docker Integration

### Docker Client Setup
```go
// internal/docker/client.go
package docker

import (
    "context"
    "github.com/docker/docker/client"
    "github.com/docker/docker/api/types"
)

type Client struct {
    cli *client.Client
    ctx context.Context
}

func NewClient() (*Client, error) {
    cli, err := client.NewClientWithOpts(client.FromEnv)
    if err != nil {
        return nil, err
    }
    
    return &Client{
        cli: cli,
        ctx: context.Background(),
    }, nil
}

func (c *Client) ListContainers() ([]types.Container, error) {
    return c.cli.ContainerList(c.ctx, types.ContainerListOptions{})
}

func (c *Client) GetContainerLogs(containerID string) (string, error) {
    logs, err := c.cli.ContainerLogs(c.ctx, containerID, types.ContainerLogsOptions{
        ShowStdout: true,
        ShowStderr: true,
        Tail:       "50",
    })
    if err != nil {
        return "", err
    }
    defer logs.Close()
    
    // Read and return logs
    // Implementation details...
    return "", nil
}
```

### Compose Integration
```go
// internal/compose/manager.go
package compose

import (
    "os/exec"
    "gopkg.in/yaml.v3"
)

type Manager struct {
    projectPath string
    envFile     string
}

func NewManager(projectPath, envFile string) *Manager {
    return &Manager{
        projectPath: projectPath,
        envFile:     envFile,
    }
}

func (m *Manager) Deploy(composeFile string) error {
    cmd := exec.Command("docker", "compose",
        "-f", composeFile,
        "--env-file", m.envFile,
        "up", "-d")
    
    return cmd.Run()
}

func (m *Manager) Stop(composeFile string) error {
    cmd := exec.Command("docker", "compose",
        "-f", composeFile,
        "--env-file", m.envFile,
        "down")
    
    return cmd.Run()
}
```

## Configuration Management

### Configuration Structure
```go
// internal/config/config.go
package config

type Config struct {
    Mode         string            `yaml:"mode"`         // "full" or "local"
    Domain       string            `yaml:"domain"`
    AppFolder    string            `yaml:"app_folder"`
    Environment  map[string]string `yaml:"environment"`
    Applications []AppConfig       `yaml:"applications"`
}

type AppConfig struct {
    Name     string            `yaml:"name"`
    Enabled  bool              `yaml:"enabled"`
    Image    string            `yaml:"image"`
    Port     int               `yaml:"port"`
    Env      map[string]string `yaml:"env"`
}

func Load(configPath string) (*Config, error) {
    // Load and parse YAML configuration
    return nil, nil
}

func (c *Config) Save(configPath string) error {
    // Save configuration to YAML file
    return nil
}
```

## Application Definitions

### Application Registry
```go
// pkg/applications/registry.go
package applications

type Application struct {
    Name        string   `yaml:"name"`
    Category    string   `yaml:"category"`
    Description string   `yaml:"description"`
    Image       string   `yaml:"image"`
    Port        int      `yaml:"port"`
    Tags        []string `yaml:"tags"`
    Dependencies []string `yaml:"dependencies"`
}

var Registry = map[string]Application{
    "plex": {
        Name:        "Plex Media Server",
        Category:    "mediaserver",
        Description: "Stream your media collection",
        Image:       "plexinc/pms-docker:latest",
        Port:        32400,
        Tags:        []string{"media", "streaming"},
    },
    "radarr": {
        Name:        "Radarr",
        Category:    "mediamanager",
        Description: "Movie collection manager",
        Image:       "lscr.io/linuxserver/radarr:latest",
        Port:        7878,
        Tags:        []string{"movies", "automation"},
        Dependencies: []string{},
    },
}

func GetApplication(name string) (Application, bool) {
    app, exists := Registry[name]
    return app, exists
}

func ListByCategory(category string) []Application {
    var apps []Application
    for _, app := range Registry {
        if app.Category == category {
            apps = append(apps, app)
        }
    }
    return apps
}
```

## Build and Distribution

### Makefile
```makefile
# Makefile
.PHONY: build test clean install

GO_VERSION = 1.21
BINARY_NAME = homelabarr
VERSION = 2.0.0

build:
	go build -ldflags "-X main.version=$(VERSION)" -o $(BINARY_NAME) .

test:
	go test ./...

lint:
	golangci-lint run

clean:
	rm -f $(BINARY_NAME)

install:
	go install -ldflags "-X main.version=$(VERSION)" .

build-all:
	GOOS=linux GOARCH=amd64 go build -ldflags "-X main.version=$(VERSION)" -o $(BINARY_NAME)-linux-amd64 .
	GOOS=linux GOARCH=arm64 go build -ldflags "-X main.version=$(VERSION)" -o $(BINARY_NAME)-linux-arm64 .
	GOOS=darwin GOARCH=amd64 go build -ldflags "-X main.version=$(VERSION)" -o $(BINARY_NAME)-darwin-amd64 .
	GOOS=windows GOARCH=amd64 go build -ldflags "-X main.version=$(VERSION)" -o $(BINARY_NAME)-windows-amd64.exe .
```

### GitHub Actions CI/CD
```yaml
# .github/workflows/cli-build.yml
name: CLI Build and Release

on:
  push:
    branches: [ main, develop ]
    tags: [ 'v*' ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    
    - name: Set up Go
      uses: actions/setup-go@v4
      with:
        go-version: '1.21'
    
    - name: Test
      run: go test ./...
    
    - name: Lint
      uses: golangci/golangci-lint-action@v3
    
    - name: Build
      run: make build-all
    
    - name: Upload artifacts
      uses: actions/upload-artifact@v3
      with:
        name: binaries
        path: homelabarr-*
```

## Migration Strategy

### Phase 1: Parallel Development
- Develop Go CLI alongside existing shell scripts
- Implement core commands (install, deploy, manage)
- Maintain backward compatibility

### Phase 2: Feature Parity
- Implement all existing functionality in Go
- Add TUI interface for enhanced user experience
- Comprehensive testing and validation

### Phase 3: Replacement
- Deprecate shell scripts gradually
- Update documentation for new CLI
- Provide migration guides for users

## Testing Strategy

### Unit Tests
```go
// internal/config/config_test.go
package config

import (
    "testing"
    "github.com/stretchr/testify/assert"
)

func TestLoadConfig(t *testing.T) {
    config, err := Load("testdata/config.yml")
    assert.NoError(t, err)
    assert.Equal(t, "local", config.Mode)
    assert.Equal(t, "/opt/appdata", config.AppFolder)
}
```

### Integration Tests
```go
// integration/cli_test.go
package integration

import (
    "os/exec"
    "testing"
)

func TestCLIVersion(t *testing.T) {
    cmd := exec.Command("./homelabarr", "--version")
    output, err := cmd.Output()
    if err != nil {
        t.Fatal(err)
    }
    
    // Verify version output
}
```

## Documentation

### CLI Help System
```go
// Cobra automatically generates help
// Additional custom help templates can be added
rootCmd.SetHelpTemplate(customHelpTemplate)
```

### Man Pages
```bash
# Generate man pages
go run scripts/generate-man-pages.go
```

---

**The new CLI will provide a modern, user-friendly interface while maintaining all the power and flexibility of the current HomelabARR CE system.**
