# Coder Workspace Templates

This directory contains advanced workspace templates for the Coder Platform deployment. Each template provides a complete development environment with pre-configured tools, frameworks, and best practices.

## Available Templates

### 1. Docker Development Environment (`docker-workspace.tf`)

**Purpose**: Full containerized development with Docker-in-Docker support

**Features**:
- Ubuntu 22.04 base with Docker engine
- VS Code Server with Docker extensions
- Multi-language support (Python, Node.js, Go, Rust)
- Docker Compose for orchestration
- Resource configuration (1-8 CPU cores, 1-16GB RAM)
- Docker version selection (latest, 24.0, 23.0)

**Best For**:
- Container-based application development
- Docker Compose orchestration
- Multi-language projects
- DevOps workflows

**Resource Requirements**:
- Minimum: 2 CPU cores, 4GB RAM, 20GB disk
- Recommended: 4 CPU cores, 8GB RAM, 50GB disk

---

### 2. Node.js Development Environment (`nodejs-workspace.tf`)

**Purpose**: Modern JavaScript/TypeScript development with popular frameworks

**Features**:
- Node.js versions: 16 LTS, 18 LTS, 20 LTS, Latest
- Framework stacks:
  - **Full Stack**: React + Express + Next.js + Angular + Vue
  - **Frontend**: React + Vue + Angular + Vite
  - **Backend**: Express + Fastify + NestJS
  - **Minimal**: Node.js + npm only
- Package managers: npm, yarn, pnpm
- Pre-configured project templates
- Testing frameworks (Jest, Mocha, Cypress, Playwright)
- VS Code with JavaScript/TypeScript extensions

**Pre-installed Templates**:
- React TypeScript application
- Express.js API server
- Development server configurations

**Resource Requirements**:
- Minimum: 2 CPU cores, 2GB RAM
- Recommended: 4 CPU cores, 4GB RAM

---

### 3. Python Development Environment (`python-workspace.tf`)

**Purpose**: Comprehensive Python development for web, data science, and ML

**Features**:
- Python versions: 3.9, 3.10, 3.11, 3.12
- Framework stacks:
  - **Data Science**: Pandas, NumPy, Matplotlib, Seaborn, Jupyter
  - **Web Development**: Django, Flask, FastAPI
  - **Machine Learning**: TensorFlow, PyTorch, Scikit-learn
  - **Full Stack**: All frameworks combined
  - **Minimal**: Python + pip only
- Package managers: pip, poetry, conda
- Jupyter Lab integration (optional)
- Pre-configured virtual environments

**Pre-installed Templates**:
- Flask API server
- FastAPI application with OpenAPI docs
- Data Science notebook templates
- Sample analysis scripts

**Resource Requirements**:
- Minimum: 2 CPU cores, 2GB RAM
- ML workloads: 4+ CPU cores, 8GB+ RAM

---

### 4. Go Development Environment (`golang-workspace.tf`)

**Purpose**: Modern Go development for web APIs, microservices, and CLI tools

**Features**:
- Go versions: 1.20, 1.21, 1.22
- Framework stacks:
  - **Web API**: Gin, Echo, Fiber, Gorilla Mux
  - **Microservices**: gRPC, Protobuf, OpenTelemetry
  - **CLI Tools**: Cobra, Viper, Logrus
  - **Full Stack**: All frameworks combined
  - **Minimal**: Go standard library only
- Database support: PostgreSQL, MySQL, MongoDB, Redis
- Development tools: Air (hot reload), Delve (debugger), Wire, Buf

**Pre-installed Templates**:
- Gin REST API server
- CLI application with Cobra
- gRPC microservice (if applicable)
- Protocol buffer definitions

**Resource Requirements**:
- Minimum: 2 CPU cores, 2GB RAM
- Recommended: 4 CPU cores, 4GB RAM

## Template Configuration

### Parameters

Each template supports the following configurable parameters:

#### Resource Configuration
- **CPU Cores**: 1-8 cores (template dependent)
- **Memory**: 1-16GB RAM (template dependent)
- **Disk Size**: 10-100GB persistent storage

#### Framework Selection
- **Technology Stack**: Choose frameworks and tools to pre-install
- **Package Manager**: Select preferred package management tool
- **Development Tools**: Standard vs Extended toolsets

#### Database Integration
- **Database Drivers**: PostgreSQL, MySQL, MongoDB, Redis support
- **ORM/Client Libraries**: Framework-specific database tools

### Template Structure

```
workspace-template.tf
├── Parameters (configurable options)
├── Docker Configuration (container setup)
├── Coder Agent (workspace management)
├── Applications (web interfaces)
└── Metadata (workspace information)
```

## Usage Instructions

### 1. Template Deployment

```bash
# Via Coder CLI
coder templates push <template-name> --directory ./templates/

# Via Web Interface
# Upload template file through Coder dashboard
```

### 2. Workspace Creation

```bash
# Create workspace from template
coder create my-workspace --template nodejs-workspace

# With custom parameters
coder create my-workspace --template python-workspace \
  --parameter python_version=3.11 \
  --parameter framework=data-science \
  --parameter memory=8
```

### 3. Access Methods

**VS Code Server**: Primary development interface
- URL: `http://localhost:8080` (local) or `https://workspace.coder.domain` (full mode)
- Features: Full VS Code experience with extensions

**Terminal Access**: Command-line interface
- SSH: `coder ssh workspace-name`
- Web Terminal: Available through Coder dashboard

**Application Servers**: Framework-specific servers
- Node.js: `http://localhost:3000`
- Python Flask: `http://localhost:5000`
- Python FastAPI: `http://localhost:8000`
- Go Gin: `http://localhost:8080`
- Jupyter Lab: `http://localhost:8888`

## Security Considerations

### Docker Socket Access

⚠️ **Security Warning**: All templates requiring Docker access mount the Docker socket (`/var/run/docker.sock`). This provides full Docker daemon access and should only be used in trusted environments.

**Security Measures**:
- Container isolation with security options
- Resource limits and quotas
- Health check monitoring
- Network isolation (proxy network)

### Authentication Integration

**Full Mode** (Production):
- Traefik reverse proxy with SSL/TLS
- Authelia authentication middleware
- Wildcard SSL certificates via Cloudflare
- Session management and timeout controls

**Local Mode** (Development):
- Direct port access without authentication
- Suitable for isolated development environments only

## Resource Planning

### Template Resource Usage

| Template | Min CPU | Min RAM | Min Disk | Typical Usage |
|----------|---------|---------|----------|---------------|
| Docker   | 2 cores | 4GB     | 20GB     | 4 cores, 8GB  |
| Node.js  | 1 core  | 2GB     | 10GB     | 2 cores, 4GB  |
| Python   | 2 cores | 2GB     | 15GB     | 4 cores, 6GB  |
| Go       | 1 core  | 2GB     | 10GB     | 2 cores, 4GB  |

### Scaling Considerations

**Single User**: 2-4 CPU cores, 4-8GB RAM per workspace
**Team Environment**: Plan for 80% concurrent usage
**Resource Overcommit**: 1.5x CPU, 1.2x memory allocation
**Storage**: Plan for 50-100GB per active workspace

## Template Customization

### Adding New Templates

1. **Create Template File**: `new-template.tf`
2. **Define Parameters**: User-configurable options
3. **Configure Container**: Base image and setup
4. **Install Tools**: Framework-specific installations
5. **Create Templates**: Project scaffolding
6. **Test Deployment**: Validate functionality

### Modifying Existing Templates

```bash
# Update template
vim templates/nodejs-workspace.tf

# Push changes
coder templates push nodejs-workspace --directory ./templates/

# Update existing workspaces (optional)
coder workspaces update --template nodejs-workspace
```

### Best Practices

1. **Version Control**: Keep templates in Git with semantic versioning
2. **Testing**: Validate templates in staging environment
3. **Documentation**: Document all parameters and features
4. **Security**: Regular security updates and reviews
5. **Performance**: Monitor resource usage and optimize
6. **Backup**: Regular template and workspace backups

## Troubleshooting

### Common Issues

#### Template Deployment Failures
```bash
# Check template syntax
coder templates validate ./templates/template-name.tf

# View template logs
coder templates logs template-name
```

#### Workspace Creation Failures
```bash
# Check workspace logs
coder workspaces logs workspace-name

# Rebuild workspace
coder workspaces rebuild workspace-name
```

#### Application Connectivity Issues
```bash
# Check container health
docker exec workspace-container health-check

# Verify port forwarding
coder port-forward workspace-name 8080:8080
```

### Performance Optimization

#### Template Optimization
- Use multi-stage Docker builds
- Implement proper caching strategies
- Minimize image layers and size
- Optimize startup script performance

#### Resource Tuning
- Monitor CPU and memory usage
- Adjust container resource limits
- Implement auto-scaling policies
- Use resource quotas per user/team

## Support and Documentation

### Additional Resources

- **Coder Documentation**: [coder.com/docs](https://coder.com/docs)
- **Template Examples**: [github.com/coder/coder/examples](https://github.com/coder/coder/examples)
- **Community Templates**: [github.com/coder/awesome-coder](https://github.com/coder/awesome-coder)

### Template Versioning

Current template versions (HL-51 Phase 2):
- `docker-workspace.tf`: v2.0.0 (Enhanced multi-language support)
- `nodejs-workspace.tf`: v2.0.0 (Full framework stack)
- `python-workspace.tf`: v2.0.0 (ML/Data Science integration)
- `golang-workspace.tf`: v2.0.0 (Microservices support)

### Changelog

**v2.0.0** (HL-51 Phase 2):
- Added advanced workspace templates
- Implemented framework selection
- Added database driver support
- Enhanced development tool integration
- Improved resource configuration
- Added comprehensive documentation

**v1.0.0** (HL-51 Phase 1):
- Basic Coder platform deployment
- PostgreSQL database integration
- Traefik reverse proxy support
- Health monitoring implementation
