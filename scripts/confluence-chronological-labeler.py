#!/usr/bin/env python3
"""
Confluence Chronological Label Manager for HomelabARR CLI
Processes all pages from August 14-31, 2025 in date order with comprehensive labeling
"""

import json
import re
from datetime import datetime

# All pages from August 14-31, 2025 organized by date
PAGES_BY_DATE = {
    "2025-08-14": [
        {"id": "3866629", "title": "2025.08.14 Installation Guide"}
    ],
    "2025-08-18": [
        {"id": "5898241", "title": "2025.08.18 Emergency Fix: CORS and Docker Integration Recovery"}
    ],
    "2025-08-19": [
        {"id": "5865475", "title": "2025.08.19 Docker Image Migration Plan - DockServer to HomelabARR"},
        {"id": "6029314", "title": "2025.08.19 HomelabARR Complete Deployment Guide"},
        {"id": "6291460", "title": "2025.08.19 Discord Knowledge Base Initiative - HL-111"},
        {"id": "6389761", "title": "2025.08.19 Ubuntu 24.04 Noble Container Migration Plan - HL-81"},
        {"id": "6389792", "title": "2025.08.19 Git Branch Standardization to Main - HL-82"},
        {"id": "6389822", "title": "2025.08.19 Discord MCP Integration & HomelabARR Server Management Plan"},
        {"id": "6389843", "title": "2025.08.19 HomelabARR SDLC Workflow Implementation Guide"},
        {"id": "6389866", "title": "2025.08.19 Sprint 2 Mid-Sprint Review - August 19, 2025"},
        {"id": "6389888", "title": "2025.08.19 Container Naming Standardization - Migration Guide"},
        {"id": "6422531", "title": "2025.08.19 GitHub Actions Workflow Refactoring - HL-100"},
        {"id": "6455298", "title": "2025.08.19 Discord Webhook Container Image Enhancement - HL-107"},
        {"id": "6455326", "title": "2025.08.19 Container Naming Standardization Plan"},
        {"id": "6455348", "title": "2025.08.19 Container Build Workflow Redesign & ARM64 Fix Plan"},
        {"id": "6520834", "title": "2025.08.19 HomelabARR CLI Security Assessment and Trivy Scan Analysis"},
        {"id": "6553602", "title": "2025.08.19 Container Naming Standardization and Branch Renaming - Implementation Report"},
        {"id": "6586370", "title": "2025.08.19 Docker Build Infrastructure Fixes and GHCR Integration"},
        {"id": "6619137", "title": "HomelabARR CLI Monitoring Stack and Grafana Dashboards"},
        {"id": "6848514", "title": "2025.08.19 Mount and Uploader Container Modernization Plan"}
    ],
    "2025-08-20": [
        {"id": "6946819", "title": "DockServer to HomelabARR Migration - Complete Implementation"},
        {"id": "7536643", "title": "DockServer Reference Cleanup - HL-148"}
    ],
    "2025-08-21": [
        {"id": "7504031", "title": "2025.08.21 Docker Container Display Fix - CLI Integration Complete"},
        {"id": "7602179", "title": "HomelabARR Architecture Deep Dive - Complete Technical Documentation"},
        {"id": "7930025", "title": "2025-08-21 RCA: CLAUDE.md File Deletion Incident"},
        {"id": "7929859", "title": "2025-08-21 HomelabARR Confluence Knowledge Base - Master Index"}
    ],
    "2025-08-22": [
        {"id": "8945666", "title": "2025-08-22 v2.0 Dashboard Integration & API Connectivity"},
        {"id": "8978434", "title": "2025-08-22 v2 POC Docker Integration Implementation"},
        {"id": "9011202", "title": "2025-08-22 HomelabARR v2 POC - Implementation Summary"},
        {"id": "9011229", "title": "2025-08-22 HomelabARR v2 POC - Storage Monitoring & SSE Implementation Guide"}
    ],
    "2025-08-23": [
        {"id": "8945736", "title": "2025-08-23 Container Health Monitoring Implementation - HomelabARR v2.0"},
        {"id": "8945790", "title": "2025-08-23 RCA: App Installation System Failure"},
        {"id": "8978458", "title": "2025-08-23 Fix: SSD/NVMe Drive Detection in v2 POC Dashboard"},
        {"id": "8978486", "title": "2025-08-23 Performance Optimization: App Store 300x Speed Improvement"},
        {"id": "8978514", "title": "2025-08-23 RCA: App Store 20-30s Load Time Performance Issue"},
        {"id": "8978538", "title": "2025-08-23 Storage Categorization Implementation - v2.0"},
        {"id": "9011251", "title": "2025-08-23 HomelabARR v2.0 SnapRAID Implementation - Next Steps"}
    ],
    "2025-08-24": [
        {"id": "8126466", "title": "2025-08-24 HomelabARR v2.0 POC - Go Implementation Analysis"},
        {"id": "8192002", "title": "2025-08-24 HomelabARR v2.0 POC - Microservices Architecture"},
        {"id": "8323074", "title": "2025-08-24 Dashboard Navigation Fix - COMPLETED"},
        {"id": "8388610", "title": "2025-08-24 Dashboard Navigation v2.0 - Sprint Retrospective"},
        {"id": "8421377", "title": "2025-08-24 Debug-First Development Guidelines - HomelabARR CLI"},
        {"id": "8519682", "title": "2025-08-24 HomelabARR v2.0 - Ultimate AI Dashboard Implementation"},
        {"id": "8585222", "title": "2025-08-24 Production File Deletion Recovery - August 2025"},
        {"id": "8585247", "title": "2025-08-24 HomelabARR v2.0 POC - Technical Implementation"},
        {"id": "8781826", "title": "2025-08-24 HomelabARR v2.0 POC - Dashboard Integration Complete"},
        {"id": "8912900", "title": "2025-08-24 HomelabARR v2 POC - Major Dashboard Improvements"},
        {"id": "8912922", "title": "2025-08-24 Dynamic Path Detection Implementation - v2 POC"},
        {"id": "8912947", "title": "2025-08-24 v2.0 App Store Implementation - Icon System"},
        {"id": "8912974", "title": "2025-08-24 v2.0 App Store - Intelligent Categorization System"},
        {"id": "8913004", "title": "2025-08-24 HomelabARR v2.0 - Volume Management Implementation"},
        {"id": "8913028", "title": "2025-08-24 v2.0 Development Session - Volume Management Decision & Health Monitoring"},
        {"id": "8913051", "title": "2025-08-24 Storage Management - SnapRAID and Drive Categorization"},
        {"id": "8913081", "title": "2025-08-24 HL-231: Critical - Settings Configuration Not Implemented"},
        {"id": "8913114", "title": "2025-08-24 RCA: Settings Page Data Overwrite Bug"},
        {"id": "8913136", "title": "2025-08-24 HL-233: Docker Socket Path Platform Detection Fix"},
        {"id": "8945690", "title": "2025-08-24 Local-Persist Docker Volume Plugin Integration"},
        {"id": "8945714", "title": "2025-08-24 HomelabARR v2.0 - Docker Compose Template Catalog"},
        {"id": "8945760", "title": "2025-08-24 Storage Widget Implementation - v2.0"},
        {"id": "8945813", "title": "2025-08-24 RCA: Windows Docker Local-Persist Volume Plugin Compatibility Issue (HL-229)"},
        {"id": "8945840", "title": "2025-08-24 Documentation Index - Master Reference for HomelabARR CLI"},
        {"id": "8946114", "title": "2025-08-24 - Fix for index.html FileServer Directory Listing Issue"},
        {"id": "8978572", "title": "2025-08-24 HomelabARR v2.0 POC - Complete Architecture"},
        {"id": "8978598", "title": "2025-08-24 MergerFS + SnapRAID Storage Architecture Plan"},
        {"id": "8978628", "title": "2025-08-24 Storage Array Implementation Status"},
        {"id": "8978654", "title": "2025-08-24 Working State Documentation"},
        {"id": "8978676", "title": "2025-08-24 HL-230: PR #29 Cleanup - Duplicate Templates Removal"},
        {"id": "8978706", "title": "2025-08-24 HL-231 Settings Implementation - Cross-Platform Traefik Configuration"},
        {"id": "9011291", "title": "2025-08-24 HomelabARR Storage Architecture - SnapRAID + MergerFS Implementation"}
    ],
    "2025-08-25": [
        {"id": "9928708", "title": "Linux-Only Architecture Decision - August 2025"},
        {"id": "9928766", "title": "2025-08-25 - HL-253 Hybrid Storage Implementation in Pure Go"},
        {"id": "9928792", "title": "2025-08-25 - Linux-Only Migration Complete (HL-250)"},
        {"id": "9928817", "title": "2025-08-25 - Native Linux File Sharing Architecture for HomelabARR NAS"},
        {"id": "9994243", "title": "2025-08-25 - SnapRAID Integration Drop-in Replacement Implementation"}
    ],
    "2025-08-26": [
        {"id": "9928853", "title": "2025-08-26 - HomelabARR Project Status Brief"},
        {"id": "9994266", "title": "2025-08-26 - TRaSH Guides Folder Structure Compliance Analysis"},
        {"id": "9994291", "title": "2025-08-26 - Native Linux File Sharing Implementation - COMPLETE"}
    ],
    "2025-08-27": [
        {"id": "9928879", "title": "2025-08-27 - Tomorrow's Action Plan"},
        {"id": "9928901", "title": "2025-08-27 - HomelabARR OS Competitive Analysis and Business Strategy"}
    ],
    "2025-08-30": [
        {"id": "11698178", "title": "2025-08-30 - Agent Handover - HomelabARR OS Evolution"}
    ],
    "2025-08-31": [
        {"id": "12091417", "title": "2025-08-31 - Theme System & App Store Implementation"},
        {"id": "11730981", "title": "2025-08-31 - Complete Development Handoff - React Migration & Theme System"}
    ]
}

def extract_technologies_from_title(title):
    """Extract technology keywords from page title"""
    technologies = set()
    
    # Technology patterns to detect
    tech_patterns = {
        'docker': r'\b(docker|container|compose|ghcr)\b',
        'react': r'\b(react|jsx|component|frontend)\b',
        'go': r'\b(go|golang|pure go)\b',
        'storage': r'\b(storage|snapraid|mergerfs|raid|disk|drive|ssd|nvme|hdd)\b',
        'monitoring': r'\b(monitoring|grafana|prometheus|netdata|health)\b',
        'api': r'\b(api|rest|endpoint|connectivity)\b',
        'security': r'\b(security|trivy|vulnerability|rca|authelia|ssl)\b',
        'traefik': r'\b(traefik|proxy|reverse-proxy|routing)\b',
        'migration': r'\b(migration|migrate|upgrade|standardization)\b',
        'architecture': r'\b(architecture|microservices|design|pattern)\b',
        'ci-cd': r'\b(github actions|workflow|ci/cd|pipeline|build)\b',
        'dashboard': r'\b(dashboard|ui|interface|navigation|widget)\b',
        'theme': r'\b(theme|theming|css|style)\b',
        'performance': r'\b(performance|optimization|speed|improvement)\b',
        'nas': r'\b(nas|file sharing|smb|nfs|samba)\b',
        'linux': r'\b(linux|ubuntu|debian)\b',
        'windows': r'\b(windows|wsl)\b',
        'kubernetes': r'\b(kubernetes|k8s|kubectl|helm)\b',
        'discord': r'\b(discord|webhook)\b',
        'jira': r'\b(jira|hl-\d+|sprint|epic)\b',
        'documentation': r'\b(documentation|docs|guide|index|rca)\b',
        'poc': r'\b(poc|proof of concept|v2)\b',
        'volume': r'\b(volume|local-persist|mount)\b',
        'app-store': r'\b(app store|app-store|catalog|template)\b'
    }
    
    title_lower = title.lower()
    for tech, pattern in tech_patterns.items():
        if re.search(pattern, title_lower):
            technologies.add(tech)
    
    return technologies

def generate_comprehensive_labels(title, date):
    """Generate comprehensive labels for a page"""
    labels = set()
    
    # Add date label
    labels.add(date)
    
    # Add year and month
    year, month, day = date.split("-")
    labels.add(year)
    
    # Month names
    months = {
        '08': 'august'
    }
    if month in months:
        labels.add(months[month])
    
    # Add technology labels from title
    technologies = extract_technologies_from_title(title)
    labels.update(technologies)
    
    # Add process type labels based on keywords
    if 'rca' in title.lower():
        labels.add('rca')
        labels.add('incident')
    if 'implementation' in title.lower():
        labels.add('implementation')
    if 'fix' in title.lower() or 'fixed' in title.lower():
        labels.add('bug-fix')
    if 'complete' in title.lower() or 'completed' in title.lower():
        labels.add('completed')
    if 'plan' in title.lower():
        labels.add('planning')
    if 'guide' in title.lower():
        labels.add('guide')
    if 'handoff' in title.lower() or 'handover' in title.lower():
        labels.add('handoff')
    if 'sprint' in title.lower():
        labels.add('sprint')
    if 'epic' in title.lower():
        labels.add('epic')
    
    # Always add homelabarr-cli label
    labels.add('homelabarr-cli')
    
    return sorted(list(labels))

def main():
    print("=" * 80)
    print("HomelabARR CLI Confluence Pages - Chronological Labeling")
    print("Processing pages from August 14-31, 2025")
    print("=" * 80)
    print()
    
    total_pages = sum(len(pages) for pages in PAGES_BY_DATE.values())
    print(f"Total pages to process: {total_pages}")
    print()
    
    # Process each date in order
    for date in sorted(PAGES_BY_DATE.keys()):
        pages = PAGES_BY_DATE[date]
        if not pages:
            continue
            
        print(f"\n{'=' * 60}")
        print(f"Date: {date} ({len(pages)} pages)")
        print(f"{'=' * 60}")
        
        for page in pages:
            labels = generate_comprehensive_labels(page['title'], date)
            
            print(f"\nPage: {page['title']}")
            print(f"ID: {page['id']}")
            print(f"Labels ({len(labels)}): {', '.join(labels)}")
            print(f"MCP Commands:")
            for label in labels:
                print(f'  mcp__MCP_DOCKER__confluence_add_label --page_id "{page["id"]}" --name "{label}"')
    
    print(f"\n{'=' * 80}")
    print("Summary Statistics:")
    print(f"- Total Pages: {total_pages}")
    print(f"- Date Range: August 14-31, 2025")
    print(f"- Days with Documentation: {len(PAGES_BY_DATE)}")
    
    # Count pages by day
    for date in sorted(PAGES_BY_DATE.keys()):
        count = len(PAGES_BY_DATE[date])
        if count > 0:
            bar = "█" * min(count, 50)
            print(f"  {date}: {count:2d} pages {bar}")

if __name__ == "__main__":
    main()