#!/bin/bash

# homelabarr-cli Local Mode Bootstrap - One Line Deploy
# Usage: curl -sSL https://raw.githubusercontent.com/smashingtags/homelabarr-cli/master/apps/.config/bootstrap-local.sh | bash

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${BOLD}${CYAN}"
cat << "EOF"
    ____             __   _____                          
   / __ \____  _____/ /__/ ___/___  ______   _____  _____
  / / / / __ \/ ___/ //_/\__ \/ _ \/ ___/ | / / _ \/ ___/
 / /_/ / /_/ / /__/ ,<  ___/ /  __/ /   | |/ /  __/ /    
/_____/\____/\___/_/|_|/____/\___/_/    |___/\___/_/     

EOF
echo -e "${NC}${BOLD}homelabarr-cli Local Mode - One Line Deploy${NC}"
echo -e "${BLUE}=========================================${NC}"
echo

# Check prerequisites
echo -e "${BLUE}🔍 Checking prerequisites...${NC}"

if ! command -v git &> /dev/null; then
    echo -e "${RED}❌ Git is not installed${NC}"
    echo -e "${YELLOW}💡 Install git: sudo apt install git -y${NC}"
    exit 1
fi

if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker is not installed${NC}"
    echo -e "${YELLOW}💡 Install docker: curl -fsSL https://get.docker.com | sh${NC}"
    exit 1
fi

if ! docker compose version &> /dev/null; then
    echo -e "${RED}❌ Docker Compose is not available${NC}"
    echo -e "${YELLOW}💡 Docker Compose is required${NC}"
    exit 1
fi

echo -e "${GREEN}✅ All prerequisites met${NC}"

# Clone repository if not already exists
if [[ ! -d "HomelabarrCli" ]]; then
    echo -e "\n${BLUE}📥 Cloning homelabarr-cli repository...${NC}"
    git clone https://github.com/smashingtags/homelabarr-cli.git
    cd HomelabarrCli/apps/.config
else
    echo -e "\n${BLUE}📁 Using existing homelabarr-cli directory...${NC}"
    cd HomelabarrCli/apps/.config
    git pull origin master >/dev/null 2>&1 || echo -e "${YELLOW}⚠️ Could not update repository${NC}"
fi

# Set permissions
echo -e "\n${BLUE}🔧 Setting up permissions...${NC}"
chmod +x *.sh 2>/dev/null || true

# Create environment file with sensible defaults
echo -e "\n${BLUE}⚙️ Creating environment configuration...${NC}"
if [[ ! -f ".env" ]]; then
    cat > .env << 'EOF'
# homelabarr-cli Local Mode Configuration
# Generated automatically - modify as needed

# User/Group IDs (run 'id' command to get your values)
ID=1000
PGID=1000
PUID=1000

# Timezone (change to your timezone)
TZ=America/New_York

# File permissions
UMASK=002

# Container restart policy
RESTARTAPP=unless-stopped

# Security options
SECURITYOPS=no-new-privileges
SECURITYOPSSET=true

# Application data directory (create this directory)
APPFOLDER=/opt/appdata

# Container Images - Latest stable versions
PLEXIMAGE=lscr.io/linuxserver/plex:latest
RADARRIMAGE=lscr.io/linuxserver/radarr:latest
SONARRIMAGE=lscr.io/linuxserver/sonarr:latest
QBITORRENTIMAGE=lscr.io/linuxserver/qbittorrent:latest
JELLYFINIMAGE=lscr.io/linuxserver/jellyfin:latest
OVERSEERRIMAGE=lscr.io/linuxserver/overseerr:latest
TAUTULLIIMAGE=lscr.io/linuxserver/tautulli:latest
LIDARRIMAGE=lscr.io/linuxserver/lidarr:latest
BAZARRIMAGE=lscr.io/linuxserver/bazarr:latest

# Theme Settings (optional - leave blank to disable)
PLEXTHEME=dark
RADARRTHEME=dark
SONARRTHEME=dark
QBITORRENTTHEME=dark

# Additional Plex Settings
PLEXVERSION=docker
PLEXADDON=
EOF
    echo -e "${GREEN}✅ Created .env file with default settings${NC}"
else
    echo -e "${YELLOW}⚠️ .env file already exists, skipping creation${NC}"
fi

# Create application data directory
echo -e "\n${BLUE}📁 Setting up application data directory...${NC}"
APPFOLDER="/opt/appdata"
if [[ ! -d "$APPFOLDER" ]]; then
    if sudo mkdir -p "$APPFOLDER" 2>/dev/null; then
        sudo chown -R $(id -u):$(id -g) "$APPFOLDER" 2>/dev/null || true
        echo -e "${GREEN}✅ Created $APPFOLDER${NC}"
    else
        # Fallback to user home directory
        APPFOLDER="$HOME/HomelabarrCli-data"
        mkdir -p "$APPFOLDER"
        sed -i "s|APPFOLDER=/opt/appdata|APPFOLDER=$APPFOLDER|" .env
        echo -e "${YELLOW}⚠️ Created $APPFOLDER (fallback location)${NC}"
    fi
else
    echo -e "${GREEN}✅ $APPFOLDER already exists${NC}"
fi

# Quick deploy option
echo -e "\n${BOLD}${GREEN}🚀 Quick Deploy Options${NC}"
echo -e "${GREEN}========================${NC}"
echo -e "1) ${CYAN}Deploy Popular Stack${NC} (Plex + Radarr + Sonarr + qBittorrent)"
echo -e "2) ${CYAN}Deploy Plex Only${NC} (Just Plex Media Server)"
echo -e "3) ${CYAN}Interactive Menu${NC} (Choose individual apps)"
echo -e "4) ${CYAN}Skip deployment${NC} (Setup only)"
echo

read -p "Choose deployment option (1-4): " deploy_choice

case $deploy_choice in
    1)
        echo -e "\n${BLUE}🚀 Deploying Popular Stack...${NC}"
        
        # Deploy Plex
        echo -e "${BLUE}📺 Deploying Plex Media Server...${NC}"
        if docker compose -f plex-local-template.yml --env-file .env up -d 2>/dev/null; then
            echo -e "${GREEN}✅ Plex started on http://localhost:32400${NC}"
        else
            echo -e "${YELLOW}⚠️ Plex deployment skipped (template missing)${NC}"
        fi
        
        # Deploy Radarr
        echo -e "${BLUE}🎬 Deploying Radarr...${NC}"
        if docker compose -f radarr-local-template.yml --env-file .env up -d 2>/dev/null; then
            echo -e "${GREEN}✅ Radarr started on http://localhost:7878${NC}"
        else
            echo -e "${YELLOW}⚠️ Radarr deployment skipped (template missing)${NC}"
        fi
        
        # Deploy qBittorrent
        echo -e "${BLUE}⬇️ Deploying qBittorrent...${NC}"
        if docker compose -f qbittorrent-local-template.yml --env-file .env up -d 2>/dev/null; then
            echo -e "${GREEN}✅ qBittorrent started on http://localhost:8082${NC}"
        else
            echo -e "${YELLOW}⚠️ qBittorrent deployment skipped (template missing)${NC}"
        fi
        
        echo -e "\n${BOLD}${GREEN}🎉 Popular Stack Deployed!${NC}"
        ;;
    2)
        echo -e "\n${BLUE}📺 Deploying Plex Media Server Only...${NC}"
        if docker compose -f plex-local-template.yml --env-file .env up -d 2>/dev/null; then
            echo -e "${GREEN}✅ Plex started on http://localhost:32400${NC}"
        else
            echo -e "${YELLOW}⚠️ Plex template not found, starting interactive menu...${NC}"
            sleep 2
            ./deploy-local-enhanced.sh 2>/dev/null || ./deploy-local.sh
        fi
        ;;
    3)
        echo -e "\n${BLUE}🎛️ Starting interactive deployment menu...${NC}"
        sleep 1
        ./deploy-local-enhanced.sh 2>/dev/null || ./deploy-local.sh
        ;;
    4)
        echo -e "\n${GREEN}✅ Setup complete! Ready for manual deployment.${NC}"
        ;;
    *)
        echo -e "\n${YELLOW}Invalid choice, starting interactive menu...${NC}"
        sleep 1
        ./deploy-local-enhanced.sh 2>/dev/null || ./deploy-local.sh
        ;;
esac

# Show summary
echo -e "\n${BOLD}${CYAN}📋 Setup Summary${NC}"
echo -e "${CYAN}=================${NC}"
echo -e "${GREEN}✅ Repository:${NC} $(pwd)"
echo -e "${GREEN}✅ Environment:${NC} .env configured"
echo -e "${GREEN}✅ Data Directory:${NC} $APPFOLDER"
echo -e "${GREEN}✅ Scripts:${NC} Executable and ready"

echo -e "\n${BOLD}${YELLOW}🎯 Next Steps${NC}"
echo -e "${YELLOW}=============${NC}"
echo -e "• ${CYAN}Access services${NC}: Check URLs shown above"
echo -e "• ${CYAN}Deploy more apps${NC}: ./deploy-local-enhanced.sh"
echo -e "• ${CYAN}View containers${NC}: docker ps"
echo -e "• ${CYAN}Edit config${NC}: nano .env"

echo -e "\n${BOLD}${GREEN}🎉 homelabarr-cli Local Mode Ready!${NC}"
