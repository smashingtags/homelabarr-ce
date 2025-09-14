#!/usr/bin/env python3
"""
Confluence Bulk Label Manager for HomelabARR CLI
Efficiently adds comprehensive labels to multiple Confluence pages
"""

import json
from datetime import datetime
import re

# Configuration
SPACE_KEY = "DO"
DATE_PATTERN = r"(\d{4}[-.]?\d{2}[-.]?\d{2})"

def extract_date_from_title(title):
    """Extract date from page title in various formats"""
    match = re.search(DATE_PATTERN, title)
    if match:
        date_str = match.group(1).replace(".", "-")
        return date_str
    return None

def generate_labels_for_page(title, content=""):
    """Generate comprehensive labels based on page title and content"""
    labels = set()
    
    # Add date label if found
    date = extract_date_from_title(title)
    if date:
        labels.add(date)
    
    # Technology labels based on keywords
    tech_keywords = {
        'docker': ['docker', 'container', 'compose'],
        'traefik': ['traefik', 'proxy', 'reverse-proxy'],
        'authelia': ['authelia', 'authentication', 'auth', '2fa'],
        'react': ['react', 'frontend', 'jsx', 'component'],
        'go': ['golang', 'go ', 'backend'],
        'storage': ['storage', 'snapraid', 'mergerfs', 'disk', 'drive'],
        'installation': ['install', 'setup', 'guide'],
        'migration': ['migration', 'migrate', 'upgrade'],
        'rca': ['rca', 'root cause', 'analysis', 'incident'],
        'documentation': ['documentation', 'docs', 'guide'],
        'api': ['api', 'rest', 'endpoint'],
        'monitoring': ['monitoring', 'metrics', 'grafana', 'prometheus'],
        'backup': ['backup', 'restore', 'disaster recovery'],
        'security': ['security', 'ssl', 'https', 'certificate'],
        'cloudflare': ['cloudflare', 'dns', 'cdn'],
        'network': ['network', 'networking', 'port', 'ip'],
        'kubernetes': ['kubernetes', 'k8s', 'kubectl', 'helm'],
        'ansible': ['ansible', 'playbook', 'automation'],
        'terraform': ['terraform', 'infrastructure', 'iac'],
        'ci-cd': ['ci/cd', 'pipeline', 'github actions', 'jenkins'],
        'testing': ['test', 'testing', 'qa', 'quality'],
        'performance': ['performance', 'optimization', 'speed'],
        'troubleshooting': ['troubleshoot', 'fix', 'error', 'issue'],
        'architecture': ['architecture', 'design', 'pattern'],
        'database': ['database', 'db', 'sql', 'postgres', 'mysql'],
        'redis': ['redis', 'cache', 'session'],
        'elasticsearch': ['elasticsearch', 'elastic', 'search'],
        'homelabarr-cli': ['homelabarr', 'hlcli', 'homelabARR'],
        'plex': ['plex', 'media server'],
        'jellyfin': ['jellyfin', 'emby'],
        'sonarr': ['sonarr', 'tv shows'],
        'radarr': ['radarr', 'movies'],
        'lidarr': ['lidarr', 'music'],
        'bazarr': ['bazarr', 'subtitles'],
        'overseerr': ['overseerr', 'request'],
        'tautulli': ['tautulli', 'plexpy'],
        'qbittorrent': ['qbittorrent', 'torrent'],
        'sabnzbd': ['sabnzbd', 'usenet', 'nzb'],
        'nzbget': ['nzbget', 'usenet'],
        'theme': ['theme', 'theming', 'css', 'style'],
        'dashboard': ['dashboard', 'ui', 'interface'],
        'nas': ['nas', 'storage', 'file sharing'],
        'smb': ['smb', 'samba', 'cifs'],
        'nfs': ['nfs', 'network file'],
        'iscsi': ['iscsi', 'san'],
        'zfs': ['zfs', 'filesystem'],
        'btrfs': ['btrfs', 'filesystem'],
        'raid': ['raid', 'redundancy'],
        'gpu': ['gpu', 'nvidia', 'transcoding'],
        'virtualization': ['vm', 'virtual', 'proxmox', 'esxi'],
        'unraid': ['unraid'],
        'truenas': ['truenas', 'freenas'],
        'openmediavault': ['openmediavault', 'omv']
    }
    
    # Check title and content for keywords
    combined_text = (title + " " + content).lower()
    for label, keywords in tech_keywords.items():
        if any(keyword in combined_text for keyword in keywords):
            labels.add(label)
    
    # Add process/type labels
    process_keywords = {
        'installation': ['install', 'setup guide'],
        'migration': ['migration', 'migrate'],
        'configuration': ['config', 'configure', 'settings'],
        'troubleshooting': ['troubleshoot', 'fix', 'issue', 'error'],
        'guide': ['guide', 'how to', 'tutorial'],
        'rca': ['rca', 'root cause', 'incident'],
        'architecture': ['architecture', 'design'],
        'planning': ['plan', 'planning', 'roadmap'],
        'release': ['release', 'version', 'changelog'],
        'feature': ['feature', 'enhancement'],
        'bug': ['bug', 'defect', 'issue'],
        'documentation': ['documentation', 'docs'],
        'poc': ['poc', 'proof of concept'],
        'handoff': ['handoff', 'handover', 'transition'],
        'sprint': ['sprint', 'agile', 'scrum'],
        'epic': ['epic', 'milestone'],
        'sdlc': ['sdlc', 'development', 'lifecycle']
    }
    
    for label, keywords in process_keywords.items():
        if any(keyword in combined_text for keyword in keywords):
            labels.add(label)
    
    # Add year label
    if date:
        year = date.split("-")[0]
        labels.add(year)
    
    # Add month label
    months = {
        '01': 'january', '02': 'february', '03': 'march',
        '04': 'april', '05': 'may', '06': 'june',
        '07': 'july', '08': 'august', '09': 'september',
        '10': 'october', '11': 'november', '12': 'december'
    }
    if date and len(date.split("-")) >= 2:
        month_num = date.split("-")[1]
        if month_num in months:
            labels.add(months[month_num])
    
    return list(labels)

# Pages to process - based on search results
pages_to_label = [
    {
        "id": "3866629",
        "title": "2025.08.14 Installation Guide",
        "existing_labels": ["ubuntu", "debian", "installation", "homelabarr-cli", "guide", "docker", "traefik", "authelia", "cloudflare", "setup", "documentation", "2025-08-14"]
    },
    # Add more pages here as needed
]

def get_pages_needing_labels():
    """Return a list of pages that need comprehensive labeling"""
    # This would normally query Confluence API
    # For now, returning pages identified from earlier search
    return [
        {"id": "5898241", "title": "Emergency Fix: CORS and Docker Integration Recovery - 2025-08-19"},
        {"id": "7930025", "title": "2025-08-21 RCA: CLAUDE.md File Deletion Incident"},
        {"id": "7536643", "title": "HomelabARR Reference Cleanup - HL-148"},
        {"id": "6946819", "title": "HomelabARR to HomelabARR Migration - Complete Implementation"},
        {"id": "7602179", "title": "HomelabARR Architecture Deep Dive - Complete Technical Documentation"},
        {"id": "9928708", "title": "Linux-Only Architecture Decision - August 2025"},
        {"id": "8945840", "title": "2025-08-24 Documentation Index - Master Reference for HomelabARR CLI"},
        {"id": "8945813", "title": "2025-08-24 RCA: Windows Docker Local-Persist Volume Plugin Compatibility Issue (HL-229)"},
        {"id": "8945790", "title": "2025-08-23 RCA: App Installation System Failure"},
        {"id": "8945736", "title": "2025-08-23 Container Health Monitoring Implementation - HomelabARR v2.0"},
        {"id": "8945714", "title": "2025-08-24 HomelabARR v2.0 - Docker Compose Template Catalog"},
        {"id": "8978538", "title": "2025-08-23 Storage Categorization Implementation - v2.0"},
        {"id": "8978628", "title": "2025-08-24 Storage Array Implementation Status"},
        {"id": "8126466", "title": "2025-08-24 HomelabARR v2.0 POC - Go Implementation Analysis"},
        {"id": "8585222", "title": "2025-08-24 Production File Deletion Recovery - August 2025"},
        {"id": "8913051", "title": "2025-08-24 Storage Management - SnapRAID and Drive Categorization"},
        {"id": "8519682", "title": "2025-08-24 HomelabARR v2.0 - Ultimate AI Dashboard Implementation"},
        {"id": "8192002", "title": "2025-08-24 HomelabARR v2.0 POC - Microservices Architecture"},
        {"id": "8585247", "title": "2025-08-24 HomelabARR v2.0 POC - Technical Implementation"},
        {"id": "8978572", "title": "2025-08-24 HomelabARR v2.0 POC - Complete Architecture"},
        {"id": "8978706", "title": "2025-08-24 HL-231 Settings Implementation - Cross-Platform Traefik Configuration"},
        {"id": "8945690", "title": "2025-08-24 Local-Persist Docker Volume Plugin Integration"},
        {"id": "9928879", "title": "2025-08-27 - Tomorrow's Action Plan"},
        {"id": "8912900", "title": "2025-08-24 HomelabARR v2 POC - Major Dashboard Improvements"},
        {"id": "9994266", "title": "2025-08-26 - TRaSH Guides Folder Structure Compliance Analysis"},
        {"id": "9928901", "title": "2025-08-27 - HomelabARR OS Competitive Analysis and Business Strategy"},
        {"id": "11698178", "title": "2025-08-30 - Agent Handover - HomelabARR OS Evolution"},
        {"id": "12091417", "title": "2025-08-31 - Theme System & App Store Implementation"},
        {"id": "11730981", "title": "2025-08-31 - Complete Development Handoff - React Migration & Theme System"}
    ]

if __name__ == "__main__":
    print("Confluence Bulk Label Manager for HomelabARR CLI")
    print("=" * 50)
    
    pages = get_pages_needing_labels()
    print(f"Found {len(pages)} pages to process")
    print()
    
    # Generate label recommendations
    for page in pages:
        labels = generate_labels_for_page(page["title"])
        print(f"Page: {page['title']}")
        print(f"ID: {page['id']}")
        print(f"Suggested labels: {', '.join(sorted(labels))}")
        print(f"MCP Command to add labels:")
        for label in sorted(labels):
            print(f'  mcp__MCP_DOCKER__confluence_add_label --page_id "{page["id"]}" --name "{label}"')
        print()
    
    print("\nTo execute all label additions, run the generated MCP commands above.")
    print("Or use the batch processing approach with proper error handling.")