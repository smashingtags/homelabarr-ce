# HomelabARR Architecture - How 3 Repositories Work Together

## Visual Architecture Diagram

```mermaid
graph TB
    subgraph "THREE SEPARATE GITHUB REPOSITORIES"
        subgraph "1. homelabarr-cli (THIS REPO)"
            CLI[Main CLI Repository<br/>Shell Scripts & Docker Compose]
            CLI_FILES[• install.sh scripts<br/>• Docker Compose files<br/>• Traefik configs<br/>• 100+ app templates<br/>• NO frontend/backend code]
        end
        
        subgraph "2. homelabarr-web-app"
            WEB[Frontend Repository<br/>React/Next.js]
            WEB_FILES[• React/Next.js UI<br/>• Runs on port 3000<br/>• User interface<br/>• Calls backend API<br/>• SEPARATE REPO]
        end
        
        subgraph "3. homelabarr-backend"
            BACKEND[Backend Repository<br/>Node.js API]
            BACKEND_FILES[• Node.js API server<br/>• Runs on port 38083<br/>• Docker management<br/>• Container control<br/>• SEPARATE REPO]
        end
    end
    
    subgraph "YOUR DEVELOPMENT MACHINE"
        DEV[You - Developer]
        subgraph "Docker Desktop"
            FRONTEND_CONTAINER[Frontend Container<br/>localhost:3000]
            BACKEND_CONTAINER[Backend Container<br/>localhost:38083]
            MCP[MCP Servers<br/>For Claude]
        end
    end
    
    subgraph "PRODUCTION LINUX SERVER"
        subgraph "Docker Engine"
            TRAEFIK[Traefik Proxy]
            APPS[Plex, Sonarr, Radarr<br/>Jellyfin, and 95+ more]
        end
    end
    
    %% Development workflow
    DEV -->|1. Edit CLI scripts| CLI
    DEV -->|2. Edit frontend| WEB
    DEV -->|3. Edit backend| BACKEND
    
    %% Container connections
    WEB_FILES -->|npm run dev| FRONTEND_CONTAINER
    BACKEND_FILES -->|npm start| BACKEND_CONTAINER
    CLI_FILES -->|MCP config| MCP
    
    %% Communication
    FRONTEND_CONTAINER -->|API calls| BACKEND_CONTAINER
    BACKEND_CONTAINER -.->|Docker socket<br/>BROKEN in WSL| MCP
    
    %% Production
    CLI_FILES -->|Deploy via SSH| TRAEFIK
    TRAEFIK --> APPS
    
    %% Important note
    NOTE[Frontend & Backend are OPTIONAL!<br/>CLI works standalone without them!]
    NOTE -.->|Important| CLI
    
    style CLI fill:#lightblue
    style WEB fill:#lightgreen
    style BACKEND fill:#lightcoral
    style NOTE fill:#yellow,stroke:#red,stroke-width:3px
```

## Quick Summary

### What's in Each Repository:

1. **homelabarr-cli** (Current repository - where you are now)
   - The CORE product - fully functional standalone
   - All installation scripts
   - Docker Compose templates for 100+ applications
   - Traefik configuration
   - **NO frontend or backend code lives here**

2. **homelabarr-web-app** (Separate repository)
   - Optional web UI frontend
   - React/Next.js application
   - Runs on port 3000
   - Provides a graphical interface to manage the CLI

3. **homelabarr-backend** (Separate repository)
   - Optional API backend
   - Node.js server on port 38083
   - Bridges frontend with Docker
   - Manages containers programmatically

### Key Points:

- ✅ **CLI works perfectly on Linux** without any frontend/backend
- ✅ **Frontend/Backend are OPTIONAL** additions for web-based management
- ❌ **WSL Docker socket issue** only affects the optional web UI
- ✅ **Production servers** run the CLI standalone without issues

### File Locations:

```
F:\Coding Projects\
├── homelabarr-cli\          <-- YOU ARE HERE
│   ├── apps\                <-- Docker compose files
│   ├── traefik\             <-- Traefik configs
│   ├── scripts\             <-- Utility scripts
│   └── install.sh           <-- Main installer
│
├── homelabarr-web-app\      <-- SEPARATE REPO (Frontend)
│   ├── src\
│   ├── components\
│   └── package.json
│
└── homelabarr-backend\      <-- SEPARATE REPO (Backend)
    ├── src\
    ├── api\
    └── package.json
```

## View This Diagram

You can view this diagram in several ways:

1. **VS Code**: Install the "Markdown Preview Mermaid Support" extension
2. **GitHub**: This will render automatically when pushed to GitHub
3. **Online**: Copy the mermaid code to https://mermaid.live
4. **Generate PNG**: Run the Python script in this folder (requires `diagrams` package)

## Python Diagram Generator

To generate a high-quality PNG diagram:

```bash
# Install the diagrams package
pip install diagrams

# Run the generator
python generated-diagrams/create-architecture-diagram.py
```

This will create `homelabarr-architecture.png` in the generated-diagrams folder.