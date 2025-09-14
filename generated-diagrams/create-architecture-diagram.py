#!/usr/bin/env python3
"""
HomelabARR Architecture Diagram Generator
This script creates a visual diagram showing how the 3 separate repositories work together
"""

from diagrams import Diagram, Cluster, Edge
from diagrams.onprem.client import User, Users
from diagrams.onprem.vcs import Github
from diagrams.onprem.container import Docker
from diagrams.onprem.network import Traefik, Internet
from diagrams.programming.framework import React
from diagrams.programming.language import NodeJS, Bash
from diagrams.generic.blank import Blank

# Generate the architecture diagram
with Diagram("HomelabARR - How 3 Separate Repositories Work Together", 
             show=False, 
             direction="TB", 
             filename="homelabarr-architecture", 
             outformat="png", 
             graph_attr={"fontsize": "14", "bgcolor": "white"}):
    
    users = Users("End Users")
    dev = User("You (Developer)")
    
    with Cluster("THREE SEPARATE GITHUB REPOSITORIES", graph_attr={"bgcolor": "lightyellow"}):
        
        with Cluster("1. homelabarr-cli (THIS REPO)", graph_attr={"bgcolor": "lightblue"}):
            cli = Github("Main CLI Repository")
            cli_items = Bash("• install.sh scripts\n• Docker Compose files\n• Traefik configs\n• 100+ app templates\n• NO frontend/backend code")
        
        with Cluster("2. homelabarr-web-app", graph_attr={"bgcolor": "lightgreen"}):
            web = Github("Frontend Repository")
            web_items = React("• React/Next.js UI\n• Runs on port 3000\n• User interface\n• Calls backend API\n• SEPARATE REPO")
        
        with Cluster("3. homelabarr-backend", graph_attr={"bgcolor": "lightcoral"}):
            backend = Github("Backend Repository")
            backend_items = NodeJS("• Node.js API server\n• Runs on port 38083\n• Docker management\n• Container control\n• SEPARATE REPO")
    
    Blank("height=0.5")
    
    with Cluster("DEVELOPMENT ENVIRONMENT (Your Machine)", graph_attr={"bgcolor": "lavender"}):
        with Cluster("Docker Desktop"):
            dev_frontend = Docker("Frontend\nContainer\n:3000")
            dev_backend = Docker("Backend\nContainer\n:38083")
            dev_mcp = Docker("MCP Servers\n(for Claude)")
    
    with Cluster("PRODUCTION LINUX SERVER", graph_attr={"bgcolor": "lightgray"}):
        internet = Internet("Internet")
        with Cluster("Docker Engine"):
            traefik = Traefik("Traefik Proxy")
            
            with Cluster("Deployed Apps"):
                plex = Docker("Plex")
                sonarr = Docker("Sonarr")
                radarr = Docker("Radarr")
                jellyfin = Docker("Jellyfin")
                others = Docker("95+ more apps")
    
    # Development workflow
    dev >> Edge(label="1. Edits CLI scripts", style="bold") >> cli
    dev >> Edge(label="2. Edits frontend", style="bold") >> web
    dev >> Edge(label="3. Edits backend", style="bold") >> backend
    
    # Repository connections
    cli >> cli_items
    web >> web_items
    backend >> backend_items
    
    # Local development
    web_items >> Edge(label="npm run dev", style="dashed") >> dev_frontend
    backend_items >> Edge(label="npm start", style="dashed") >> dev_backend
    cli_items >> Edge(label="MCP config", style="dashed") >> dev_mcp
    
    # How they work together
    dev_frontend >> Edge(label="API calls", color="blue") >> dev_backend
    dev_backend >> Edge(label="Docker socket\n(broken in WSL)", color="red", style="dashed") >> dev_mcp
    
    # Production deployment
    cli_items >> Edge(label="Deploy to Linux\n(SSH + install.sh)", color="green", style="bold") >> traefik
    users >> internet >> traefik
    traefik >> [plex, sonarr, radarr, jellyfin, others]
    
    # Important note
    note = Blank("")
    note >> Edge(label="Frontend & Backend are\nOPTIONAL web UI.\nCLI works standalone!", color="purple", style="bold") >> cli_items

print("Diagram generated successfully as 'homelabarr-architecture.png'")
print("You can find it in the generated-diagrams folder")