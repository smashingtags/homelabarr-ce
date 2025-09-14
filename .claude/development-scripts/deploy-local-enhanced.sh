#!/bin/bash

# Enhanced homelabarr-cli Local Mode Deployment
# Shows all apps organized by category with folder structure

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APPS_DIR="$(dirname "$SCRIPT_DIR")"

# Port assignments organized by category
declare -A MEDIA_SERVERS=(
    ["plex"]="32400"
    ["jellyfin"]="8096"
    ["emby"]="8097"
)

declare -A MEDIA_MANAGERS=(
    ["radarr"]="7878"
    ["sonarr"]="8989"
    ["lidarr"]="8686"
    ["bazarr"]="6767"
    ["prowlarr"]="9696"
    ["readarr"]="8787"
)

declare -A DOWNLOAD_CLIENTS=(
    ["qbittorrent"]="8082"
    ["sabnzbd"]="8085"
    ["nzbget"]="6789"
    ["deluge"]="8112"
    ["aria"]="6800"
)

declare -A REQUEST_MANAGEMENT=(
    ["overseerr"]="5055"
    ["petio"]="7777"
    ["ombi"]="3579"
    ["jellyseerr"]="5056"
)

declare -A MONITORING=(
    ["tautulli"]="8181"
    ["grafana"]="3000"
    ["netdata"]="19999"
    ["uptime-kuma"]="3001"
)

declare -A UTILITIES=(
    ["organizr"]="9983"
    ["heimdall"]="8089"
    ["dashy"]="4000"
    ["homepage"]="3002"
)

# Check if app has template or can be auto-converted
check_app_availability() {
    local app="$1"
    local category="$2"
    
    # Check if template exists
    if [[ -f "$SCRIPT_DIR/${app}-local-template.yml" ]]; then
        echo "template"
        return 0
    fi
    
    # Check if original app exists for auto-conversion
    if find "$APPS_DIR" -name "${app}.yml" -not -path "*/.config/*" -not -path "*/.templates/*" | grep -q .; then
        echo "convert"
        return 0
    fi
    
    echo "unavailable"
    return 1
}

# Display category menu with app status
show_category_menu() {
    local category="$1"
    local -n apps_ref=$2
    local category_display="$3"
    
    echo -e "\n${BOLD}${BLUE}📁 $category_display${NC}"
    echo -e "${BLUE}================================${NC}"
    
    local count=1
    for app in $(printf '%s\n' "${!apps_ref[@]}" | sort); do
        local port="${apps_ref[$app]}"
        local status=$(check_app_availability "$app" "$category")
        
        case $status in
            "template")
                echo -e "${count}) ${GREEN}✅ $app${NC} - Port $port - ${GREEN}Ready${NC}"
                ;;
            "convert") 
                echo -e "${count}) ${YELLOW}🔄 $app${NC} - Port $port - ${YELLOW}Auto-convert${NC}"
                ;;
            "unavailable")
                echo -e "${count}) ${RED}❌ $app${NC} - Port $port - ${RED}Not Available${NC}"
                ;;
        esac
        ((count++))
    done
}

# Main menu display
show_main_menu() {
    clear
    echo -e "${BOLD}${CYAN}"
    cat << "EOF"
    ____             __   _____                          
   / __ \____  _____/ /__/ ___/___  ______   _____  _____
  / / / / __ \/ ___/ //_/\__ \/ _ \/ ___/ | / / _ \/ ___/
 / /_/ / /_/ / /__/ ,<  ___/ /  __/ /   | |/ /  __/ /    
/_____/\____/\___/_/|_|/____/\___/_/    |___/\___/_/     

EOF
    echo -e "${NC}${BOLD}homelabarr-cli Local Mode Deployment${NC}"
    echo -e "${BLUE}Organized by Application Categories${NC}"
    echo
    
    # Show all categories with their apps
    show_category_menu "mediaserver" MEDIA_SERVERS "Media Servers"
    show_category_menu "mediamanager" MEDIA_MANAGERS "Media Management"  
    show_category_menu "downloadclients" DOWNLOAD_CLIENTS "Download Clients"
    show_category_menu "request" REQUEST_MANAGEMENT "Request Management"
    show_category_menu "monitoring" MONITORING "Monitoring & Analytics" 
    show_category_menu "utilities" UTILITIES "Dashboards & Utilities"
    
    echo
    echo -e "${BOLD}${YELLOW}📋 Bulk Operations${NC}"
    echo -e "${YELLOW}================================${NC}"
    echo -e "97) ${GREEN}Deploy Popular Stack${NC} (Plex + Radarr + Sonarr + qBittorrent + Overseerr)"
    echo -e "98) ${GREEN}Deploy Media Server Stack${NC} (All Media Servers + Management)"
    echo -e "99) ${GREEN}Deploy All Available${NC} (All apps with templates/auto-convert)"
    echo
    echo -e "${BOLD}${BLUE}🛠️ Management${NC}"
    echo -e "${BLUE}================================${NC}"
    echo -e "s)  ${CYAN}Show Running Containers${NC}"
    echo -e "l)  ${CYAN}View Logs${NC}"
    echo -e "r)  ${RED}Remove All Containers${NC}"
    echo -e "h)  ${YELLOW}Show Help${NC}"
    echo -e "0)  ${RED}Exit${NC}"
    echo
}

# Get app by number across all categories  
get_app_by_number() {
    local choice="$1"
    local current=1
    
    for category in MEDIA_SERVERS MEDIA_MANAGERS DOWNLOAD_CLIENTS REQUEST_MANAGEMENT MONITORING UTILITIES; do
        local -n category_ref=$category
        for app in $(printf '%s\n' "${!category_ref[@]}" | sort); do
            if [[ $current -eq $choice ]]; then
                echo "$app"
                return 0
            fi
            ((current++))
        done
    done
    return 1
}

# Deploy single app
deploy_app() {
    local app="$1"
    local port="$2"
    
    echo -e "\n${BLUE}Deploying $app on port $port...${NC}"
    
    local template_file="${app}-local-template.yml"
    local env_file=".env"
    
    # Check if template exists
    if [[ -f "$template_file" ]]; then
        echo -e "${GREEN}✅ Using existing template: $template_file${NC}"
    else
        echo -e "${YELLOW}🔄 Creating template from original app...${NC}"
        # Auto-convert logic would go here
        echo -e "${RED}❌ Auto-conversion not implemented yet${NC}"
        return 1
    fi
    
    # Deploy with environment file
    if [[ -f "$env_file" ]]; then
        echo -e "${BLUE}Starting $app container...${NC}"
        if docker compose -f "$template_file" --env-file "$env_file" up -d; then
            echo -e "${GREEN}✅ $app deployed successfully!${NC}"
            echo -e "${CYAN}🌐 Access at: http://localhost:$port${NC}"
            
            # Health check
            sleep 3
            if docker compose -f "$template_file" ps | grep -q "Up"; then
                echo -e "${GREEN}✅ Container is running${NC}"
            else
                echo -e "${YELLOW}⚠️ Container may still be starting...${NC}"
            fi
        else
            echo -e "${RED}❌ Failed to deploy $app${NC}"
            return 1
        fi
    else
        echo -e "${RED}❌ Environment file .env not found${NC}"
        echo -e "${YELLOW}💡 Copy .env.example to .env and configure it${NC}"
        return 1
    fi
}

# Popular stack deployment
deploy_popular_stack() {
    echo -e "\n${BOLD}${GREEN}🚀 Deploying Popular Stack${NC}"
    echo -e "${BLUE}This will deploy: Plex, Radarr, Sonarr, qBittorrent, Overseerr${NC}"
    
    local apps=("plex:32400" "radarr:7878" "sonarr:8989" "qbittorrent:8082" "overseerr:5055")
    
    for app_port in "${apps[@]}"; do
        IFS=':' read -r app port <<< "$app_port"
        if ! deploy_app "$app" "$port"; then
            echo -e "${YELLOW}⚠️ Continuing with remaining apps...${NC}"
        fi
        sleep 2
    done
    
    echo -e "\n${BOLD}${GREEN}🎉 Popular Stack Deployment Complete!${NC}"
    show_access_urls
}

# Show access URLs for running containers
show_access_urls() {
    echo -e "\n${BOLD}${CYAN}🌐 Access URLs for Running Services:${NC}"
    echo -e "${CYAN}=====================================${NC}"
    
    # Get running containers and show their access URLs
    local containers=$(docker ps --format "table {{.Names}}\t{{.Ports}}" | grep -E "(plex|radarr|sonarr|qbittorrent|overseerr)" | tail -n +2)
    
    if [[ -n "$containers" ]]; then
        while IFS=$'\t' read -r name ports; do
            if [[ "$ports" =~ 0\.0\.0\.0:([0-9]+) ]]; then
                local port="${BASH_REMATCH[1]}"
                echo -e "${GREEN}✅ ${name}${NC}: http://localhost:${port}"
            fi
        done <<< "$containers"
    else
        echo -e "${YELLOW}⚠️ No homelabarr-cli containers currently running${NC}"
    fi
}

# Main execution
main() {
    # Check prerequisites
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}❌ Docker is not installed${NC}"
        exit 1
    fi
    
    if ! docker compose version &> /dev/null; then
        echo -e "${RED}❌ Docker Compose is not available${NC}" 
        exit 1
    fi
    
    # Main loop
    while true; do
        show_main_menu
        echo -n "Enter your choice: "
        read -r choice
        
        case $choice in
            [1-9][0-9]|[1-9])
                if [[ $choice -ge 1 && $choice -le 96 ]]; then
                    local app=$(get_app_by_number "$choice")
                    if [[ -n "$app" ]]; then
                        # Get port for app
                        local port=""
                        for category in MEDIA_SERVERS MEDIA_MANAGERS DOWNLOAD_CLIENTS REQUEST_MANAGEMENT MONITORING UTILITIES; do
                            local -n category_ref=$category
                            if [[ -n "${category_ref[$app]}" ]]; then
                                port="${category_ref[$app]}"
                                break
                            fi
                        done
                        
                        if [[ -n "$port" ]]; then
                            deploy_app "$app" "$port"
                            echo -e "\n${YELLOW}Press Enter to continue...${NC}"
                            read -r
                        fi
                    else
                        echo -e "${RED}❌ Invalid selection${NC}"
                        sleep 1
                    fi
                fi
                ;;
            "97")
                deploy_popular_stack
                echo -e "\n${YELLOW}Press Enter to continue...${NC}"
                read -r
                ;;
            "s")
                echo -e "\n${BLUE}🐳 Running homelabarr-cli Containers:${NC}"
                docker ps --filter "name=plex\|radarr\|sonarr\|qbittorrent\|overseerr" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
                echo -e "\n${YELLOW}Press Enter to continue...${NC}"
                read -r
                ;;
            "l")
                echo -e "\n${BLUE}Available containers for log viewing:${NC}"
                docker ps --filter "name=plex\|radarr\|sonarr\|qbittorrent\|overseerr" --format "{{.Names}}"
                echo -n "Enter container name: "
                read -r container_name
                if [[ -n "$container_name" ]]; then
                    docker logs -f "$container_name"
                fi
                ;;
            "r")
                echo -e "${RED}⚠️ This will remove all homelabarr-cli containers. Continue? (y/N)${NC}"
                read -r confirm
                if [[ "$confirm" =~ ^[Yy]$ ]]; then
                    docker ps -a --filter "name=plex\|radarr\|sonarr\|qbittorrent\|overseerr" -q | xargs -r docker rm -f
                    echo -e "${GREEN}✅ All containers removed${NC}"
                fi
                sleep 2
                ;;
            "h")
                echo -e "\n${BOLD}${CYAN}📖 homelabarr-cli Local Mode Help${NC}"
                echo -e "${CYAN}==============================${NC}"
                echo -e "${GREEN}✅ Ready${NC}      - Template exists, can deploy immediately"
                echo -e "${YELLOW}🔄 Auto-convert${NC} - Will convert from original homelabarr-cli app"  
                echo -e "${RED}❌ Not Available${NC} - App not found in HomelabarrCli"
                echo -e "\n${BOLD}Requirements:${NC}"
                echo -e "• Docker and Docker Compose installed"
                echo -e "• .env file configured (copy from .env.example)"
                echo -e "• Ports available (check with 'netstat -tulpn')"
                echo -e "\n${YELLOW}Press Enter to continue...${NC}"
                read -r
                ;;
            "0")
                echo -e "${GREEN}👋 Goodbye!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}❌ Invalid option${NC}"
                sleep 1
                ;;
        esac
    done
}

# Run if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
