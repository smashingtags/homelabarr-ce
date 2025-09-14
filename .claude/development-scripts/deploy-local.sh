#!/bin/bash

# homelabarr-cli Local Mode Deployment Script
# Quick deployment helper for local mode applications

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo -e "${BLUE}homelabarr-cli Local Mode Deployment${NC}"
echo "================================="

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    echo -e "${YELLOW}Warning: Running as root. Some file permissions may need adjustment.${NC}"
fi

# Check for environment file
if [ ! -f ".env" ]; then
    echo -e "${YELLOW}Environment file not found. Creating from example...${NC}"
    if [ -f ".env.example" ]; then
        cp .env.example .env
        echo -e "${GREEN}Created .env file from template.${NC}"
        echo -e "${YELLOW}Please edit .env file with your settings before continuing.${NC}"
        exit 1
    else
        echo -e "${RED}No .env.example found. Please create a .env file manually.${NC}"
        exit 1
    fi
fi

# Available applications
declare -A APPS
APPS[1]="plex:plex-local-template.yml:32400:Plex Media Server"
APPS[2]="radarr:radarr-local-template.yml:7878:Radarr Movie Manager"
APPS[3]="qbittorrent:qbittorrent-local-template.yml:8082:qBittorrent Download Client"

# Function to show menu
show_menu() {
    echo ""
    echo "Available Local Mode Applications:"
    echo "=================================="
    for key in $(echo "${!APPS[@]}" | tr ' ' '\n' | sort -n); do
        IFS=':' read -r name file port description <<< "${APPS[$key]}"
        echo -e "$key) ${GREEN}$description${NC}"
        echo -e "   Access: ${BLUE}http://localhost:$port${NC}"
    done
    echo ""
    echo "4) Deploy All Applications"
    echo "5) Stop All Applications"
    echo "6) View Running Containers"
    echo "7) View Logs"
    echo "0) Exit"
    echo ""
}

# Function to deploy application
deploy_app() {
    local app_info="$1"
    IFS=':' read -r name file port description <<< "$app_info"
    
    echo -e "${BLUE}Deploying $description...${NC}"
    
    if [ ! -f "$file" ]; then
        echo -e "${RED}Template file $file not found!${NC}"
        return 1
    fi
    
    # Check if port is already in use
    if ss -tuln | grep -q ":$port "; then
        echo -e "${YELLOW}Warning: Port $port appears to be in use${NC}"
        read -p "Continue anyway? (y/N): " continue_deploy
        if [[ ! $continue_deploy =~ ^[Yy]$ ]]; then
            return 1
        fi
    fi
    
    # Deploy the application
    docker compose -f "$file" --env-file .env up -d
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Successfully deployed $description${NC}"
        echo -e "Access at: ${BLUE}http://localhost:$port${NC}"
        
        # Wait a moment then check if container is healthy
        sleep 5
        if docker compose -f "$file" ps | grep -q "Up"; then
            echo -e "${GREEN}Container is running successfully${NC}"
        else
            echo -e "${YELLOW}Container may be starting up. Check with 'docker logs $name'${NC}"
        fi
    else
        echo -e "${RED}Failed to deploy $description${NC}"
        return 1
    fi
}

# Function to stop application
stop_app() {
    local app_info="$1"
    IFS=':' read -r name file port description <<< "$app_info"
    
    echo -e "${YELLOW}Stopping $description...${NC}"
    docker compose -f "$file" down
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Successfully stopped $description${NC}"
    else
        echo -e "${RED}Failed to stop $description${NC}"
    fi
}

# Function to deploy all applications
deploy_all() {
    echo -e "${BLUE}Deploying all applications...${NC}"
    for key in $(echo "${!APPS[@]}" | tr ' ' '\n' | sort -n); do
        deploy_app "${APPS[$key]}"
        echo ""
    done
}

# Function to stop all applications
stop_all() {
    echo -e "${YELLOW}Stopping all applications...${NC}"
    for key in $(echo "${!APPS[@]}" | tr ' ' '\n' | sort -n); do
        stop_app "${APPS[$key]}"
    done
}

# Function to show running containers
show_containers() {
    echo -e "${BLUE}Running homelabarr-cli containers:${NC}"
    echo "=============================="
    docker ps --filter "label=dockupdater.enable=true" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
}

# Function to show logs
show_logs() {
    echo ""
    echo "Select application for logs:"
    for key in $(echo "${!APPS[@]}" | tr ' ' '\n' | sort -n); do
        IFS=':' read -r name file port description <<< "${APPS[$key]}"
        echo "$key) $description"
    done
    echo ""
    read -p "Enter choice (1-3): " log_choice
    
    if [[ $log_choice =~ ^[1-3]$ ]] && [[ -n "${APPS[$log_choice]}" ]]; then
        IFS=':' read -r name file port description <<< "${APPS[$log_choice]}"
        echo -e "${BLUE}Showing logs for $description (Ctrl+C to exit):${NC}"
        docker compose -f "$file" logs -f
    else
        echo -e "${RED}Invalid choice${NC}"
    fi
}

# Main loop
while true; do
    show_menu
    read -p "Enter your choice: " choice
    
    case $choice in
        [1-3])
            if [[ -n "${APPS[$choice]}" ]]; then
                deploy_app "${APPS[$choice]}"
            else
                echo -e "${RED}Invalid choice${NC}"
            fi
            ;;
        4)
            deploy_all
            ;;
        5)
            stop_all
            ;;
        6)
            show_containers
            ;;
        7)
            show_logs
            ;;
        0)
            echo -e "${GREEN}Goodbye!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid choice. Please try again.${NC}"
            ;;
    esac
    
    echo ""
    read -p "Press Enter to continue..."
done
