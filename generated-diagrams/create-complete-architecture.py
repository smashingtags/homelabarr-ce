#!/usr/bin/env python3
"""
HomelabARR Complete Repository Architecture
Shows all repositories in the HomelabARR ecosystem
"""

from diagrams import Diagram, Cluster, Edge
from diagrams.onprem.client import User, Users
from diagrams.onprem.vcs import Github
from diagrams.onprem.container import Docker
from diagrams.onprem.network import Traefik, Internet
from diagrams.programming.framework import React
from diagrams.programming.language import NodeJS, Bash, Javascript
from diagrams.onprem.database import Postgresql
from diagrams.generic.storage import Storage
from diagrams.generic.blank import Blank

# Generate the complete architecture diagram
with Diagram("HomelabARR Complete Repository Architecture", 
             show=False, 
             direction="TB", 
             filename="homelabarr-complete-architecture", 
             outformat="png", 
             graph_attr={"fontsize": "14", "bgcolor": "white", "rankdir": "TB"}):
    
    users = Users("HomelabARR Users")
    dev = User("Developer (You)")
    
    with Cluster("HomelabARR GitHub Repositories", graph_attr={"bgcolor": "lightyellow"}):
        
        with Cluster("1. homelabarr (Original Full Stack)", graph_attr={"bgcolor": "lightcoral"}):
            homelabarr = Github("homelabarr")
            homelabarr_desc = Javascript("• Original monorepo\n• Frontend + Backend + API\n• Full stack application\n• Web UI for management")
        
        with Cluster("2. homelabarr-cli (Current Focus)", graph_attr={"bgcolor": "lightblue"}):
            cli = Github("homelabarr-cli")
            cli_desc = Bash("• Shell scripts & installers\n• Docker Compose templates\n• Traefik configurations\n• 100+ app deployments\n• Standalone CLI tool")
        
        with Cluster("3. homelabarr-containers", graph_attr={"bgcolor": "lightgreen"}):
            containers = Github("homelabarr-containers")
            containers_desc = Docker("• Docker container configs\n• Custom container builds\n• Container templates\n• Docker modifications")
        
        with Cluster("4. homelabarr-assets", graph_attr={"bgcolor": "lavender"}):
            assets = Github("homelabarr-assets")
            assets_desc = Storage("• Images & logos\n• Documentation assets\n• UI resources\n• Media files")
        
        with Cluster("5. homelabarr-uploader", graph_attr={"bgcolor": "lightpink"}):
            uploader = Github("homelabarr-uploader")
            uploader_desc = NodeJS("• File upload service\n• Media management\n• Cloud integration\n• Upload automation")
        
        with Cluster("6. homelabarr-site", graph_attr={"bgcolor": "lightsalmon"}):
            site = Github("homelabarr-site")
            site_desc = React("• Marketing website\n• Documentation site\n• Landing pages\n• Public facing site")
        
        with Cluster("7. local-persist (NEEDS RENAME)", graph_attr={"bgcolor": "yellow", "style": "dashed"}):
            persist = Github("local-persist")
            persist_desc = Storage("• Docker volume plugin\n• Persistent storage\n• Local data management\n• NEEDS RENAME to\nhomelabarr-local-persist")
    
    with Cluster("Development Environment", graph_attr={"bgcolor": "lightgray"}):
        with Cluster("Docker Desktop"):
            dev_containers = Docker("Dev Containers")
            mcp = Docker("MCP Servers")
        
        vscode = Javascript("VS Code +\nClaude MCP")
    
    with Cluster("Production Deployment", graph_attr={"bgcolor": "lightsteelblue"}):
        linux = Docker("Linux Server\n192.168.1.49")
        traefik = Traefik("Traefik Proxy")
        apps = Docker("100+ Apps\n(Plex, Sonarr, etc)")
    
    # Development workflow
    dev >> vscode
    vscode >> Edge(label="Manages all repos", style="bold") >> homelabarr
    
    # Repository relationships
    homelabarr >> homelabarr_desc
    cli >> cli_desc
    containers >> containers_desc
    assets >> assets_desc
    uploader >> uploader_desc
    site >> site_desc
    persist >> persist_desc
    
    # How they work together
    homelabarr_desc >> Edge(label="Original full stack", color="blue") >> dev_containers
    cli_desc >> Edge(label="CLI deployment", color="green") >> linux
    containers_desc >> Edge(label="Container configs", style="dashed") >> cli_desc
    assets_desc >> Edge(label="Resources", style="dashed") >> [homelabarr_desc, site_desc]
    uploader_desc >> Edge(label="Upload service", style="dashed") >> homelabarr_desc
    persist_desc >> Edge(label="Volume management", color="orange") >> containers_desc
    
    # Production flow
    cli_desc >> Edge(label="Deploy", color="green", style="bold") >> traefik
    traefik >> apps
    users >> linux >> apps
    
    # Naming convention note
    note = Blank("")
    note >> Edge(label="All repos should follow\nhomelabarr-* naming", color="red", style="bold") >> persist

print("Complete architecture diagram generated as 'homelabarr-complete-architecture.png'")
print("Location: generated-diagrams/homelabarr-complete-architecture.png")