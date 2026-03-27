#!/usr/bin/env python3
"""Generate architecture diagrams for HomelabARR CE wiki.
Uses only ASCII/Latin glyphs — no emoji (DejaVu Sans Mono doesn't support them)."""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch
import numpy as np
import os

# ── Color Palette (matches HomelabARR brand) ──
BG = '#0d1117'
CARD_BG = '#161b22'
CARD_BORDER = '#30363d'
PRIMARY = '#00bfa5'
SECONDARY = '#1a237e'
ACCENT = '#ffab00'
TEXT = '#e6edf3'
TEXT_DIM = '#8b949e'
FLOW_COLOR = '#58a6ff'
SUCCESS = '#3fb950'
DANGER = '#f85149'
PURPLE = '#bc8cff'
ORANGE = '#f0883e'


def rounded_box(ax, x, y, w, h, label, sublabel=None, color=PRIMARY,
                fill_alpha=0.15, border_width=2, fontsize=13):
    box = FancyBboxPatch((x, y), w, h, boxstyle="round,pad=0.02",
                         facecolor=color, alpha=fill_alpha,
                         edgecolor=color, linewidth=border_width)
    ax.add_patch(box)
    text_y = y + h/2 + (0.015 if sublabel else 0)
    ax.text(x + w/2, text_y, label, fontsize=fontsize,
            fontweight='bold', color=TEXT, ha='center', va='center',
            fontfamily='monospace')
    if sublabel:
        ax.text(x + w/2, text_y - 0.04, sublabel, fontsize=9,
                color=TEXT_DIM, ha='center', va='center', fontfamily='monospace')


def draw_arrow(ax, start, end, color=FLOW_COLOR, style='->', width=2,
               connectionstyle="arc3,rad=0.0"):
    arrow = FancyArrowPatch(start, end, arrowstyle=style,
                            connectionstyle=connectionstyle,
                            color=color, linewidth=width, mutation_scale=15)
    ax.add_patch(arrow)


def section_label(ax, x, y, text, color=TEXT_DIM, fontsize=10):
    ax.text(x, y, text, fontsize=fontsize, color=color,
            fontweight='bold', ha='left', va='center',
            fontfamily='monospace', style='italic')


def watermark(ax):
    ax.text(0.98, 0.02, 'homelabarr.com  |  Imogen Labs', fontsize=8,
            color=TEXT_DIM, ha='right', fontfamily='monospace', alpha=0.5)


# ═══════════════════════════════════════════════════════════════
# DIAGRAM 1: System Architecture
# ═══════════════════════════════════════════════════════════════
def generate_system_architecture():
    fig, ax = plt.subplots(1, 1, figsize=(16, 11))
    fig.patch.set_facecolor(BG)
    ax.set_facecolor(BG)
    ax.set_xlim(0, 1); ax.set_ylim(0, 1); ax.axis('off')

    ax.text(0.5, 0.96, 'HOMELABARR CE  --  SYSTEM ARCHITECTURE', fontsize=20,
            fontweight='bold', color=PRIMARY, ha='center', fontfamily='monospace')
    ax.text(0.5, 0.93, 'How the pieces fit together', fontsize=11,
            color=TEXT_DIM, ha='center', fontfamily='monospace')

    # Docker Host boundary
    host_box = FancyBboxPatch((0.03, 0.05), 0.94, 0.84, boxstyle="round,pad=0.02",
                              facecolor=CARD_BG, alpha=0.6,
                              edgecolor=CARD_BORDER, linewidth=2, linestyle='--')
    ax.add_patch(host_box)
    ax.text(0.06, 0.87, '[=]  DOCKER HOST', fontsize=12, fontweight='bold',
            color=TEXT_DIM, fontfamily='monospace')

    # Browser
    rounded_box(ax, 0.35, 0.72, 0.30, 0.08, 'BROWSER',
                'http://your-server:8084', color=FLOW_COLOR, fontsize=14)

    # Frontend
    rounded_box(ax, 0.06, 0.52, 0.28, 0.12, 'FRONTEND',
                ':8084  |  nginx + React', color=PRIMARY)
    for i, tech in enumerate(['React 19', 'shadcn/ui', 'Vite', 'Dark/Light']):
        ax.text(0.20, 0.505 - i*0.022, '> ' + tech, fontsize=8,
                color=TEXT_DIM, ha='center', fontfamily='monospace')

    # Backend
    rounded_box(ax, 0.40, 0.42, 0.30, 0.22, 'BACKEND', color=ACCENT)
    ax.text(0.55, 0.615, ':8092  |  Node.js + Express', fontsize=9,
            color=TEXT_DIM, ha='center', va='center', fontfamily='monospace')
    components = [
        ('CLI Bridge', 'Reads app templates'),
        ('Docker SDK', 'Container management'),
        ('JWT + API Keys', 'Authentication'),
        ('SSE Stream', 'Real-time deploy logs'),
    ]
    for i, (comp, desc) in enumerate(components):
        y_pos = 0.575 - i*0.035
        ax.text(0.55, y_pos, '> ' + comp, fontsize=9,
                color=TEXT, ha='center', fontfamily='monospace', fontweight='bold')
        ax.text(0.55, y_pos - 0.015, desc, fontsize=7,
                color=TEXT_DIM, ha='center', fontfamily='monospace')

    # Docker Socket
    rounded_box(ax, 0.42, 0.28, 0.26, 0.07, 'DOCKER SOCKET',
                '/var/run/docker.sock', color=DANGER, fill_alpha=0.12)

    # App Templates
    rounded_box(ax, 0.06, 0.28, 0.28, 0.12, 'APP TEMPLATES',
                'apps/  |  100+ YAML files', color=PURPLE)
    categories = ['ai/', 'media-servers/', 'downloads/', 'self-hosted/',
                  'monitoring/', 'virtual-desktops/', 'backup/', 'system/']
    for i, cat in enumerate(categories):
        col = i % 2; row = i // 2
        ax.text(0.10 + col*0.14, 0.365 - row*0.02, '  ' + cat, fontsize=7,
                color=PURPLE, ha='left', fontfamily='monospace', alpha=0.8)

    # Deployed Containers
    rounded_box(ax, 0.74, 0.42, 0.22, 0.22, 'DEPLOYED',
                'Your running apps', color=SUCCESS, fill_alpha=0.12)
    apps = ['[*] Plex', '[*] Radarr', '[*] Sonarr', '[*] Ollama',
            '[*] Nextcloud', '[*] Grafana', '[*] qBittorrent', '    ...100+ more']
    for i, app in enumerate(apps):
        ax.text(0.85, 0.595 - i*0.025, app, fontsize=8,
                color=TEXT_DIM, ha='center', fontfamily='monospace')

    # Data Storage
    rounded_box(ax, 0.06, 0.08, 0.28, 0.12, 'DATA STORAGE', color='#8b949e',
                fill_alpha=0.1)
    ax.text(0.20, 0.16, '/opt/appdata/', fontsize=9,
            color=TEXT, ha='center', fontfamily='monospace', fontweight='bold')
    ax.text(0.20, 0.14, 'plex/  radarr/  sonarr/', fontsize=8,
            color=TEXT_DIM, ha='center', fontfamily='monospace')
    ax.text(0.20, 0.115, 'homelabarr-data  (Docker vol)', fontsize=8,
            color=TEXT_DIM, ha='center', fontfamily='monospace')

    # CI/CD
    rounded_box(ax, 0.40, 0.08, 0.26, 0.12, 'CI/CD PIPELINE', color=ORANGE,
                fill_alpha=0.12)
    ax.text(0.53, 0.16, 'GitHub Actions -> GHCR', fontsize=9,
            color=TEXT, ha='center', fontfamily='monospace', fontweight='bold')
    ax.text(0.53, 0.14, 'dev -> staging -> main', fontsize=8,
            color=ORANGE, ha='center', fontfamily='monospace')
    ax.text(0.53, 0.115, 'Watchtower auto-updates', fontsize=8,
            color=TEXT_DIM, ha='center', fontfamily='monospace')

    # Traefik
    rounded_box(ax, 0.74, 0.08, 0.22, 0.12, 'TRAEFIK',
                'Optional reverse proxy', color=FLOW_COLOR, fill_alpha=0.1)
    ax.text(0.85, 0.15, 'SSL | Routing | Auth', fontsize=9,
            color=FLOW_COLOR, ha='center', fontfamily='monospace')
    ax.text(0.85, 0.115, 'app.yourdomain.com', fontsize=8,
            color=TEXT_DIM, ha='center', fontfamily='monospace')

    # Arrows
    draw_arrow(ax, (0.42, 0.72), (0.28, 0.64), color=FLOW_COLOR, width=2.5)
    ax.text(0.32, 0.69, 'HTTP', fontsize=8, color=FLOW_COLOR,
            fontfamily='monospace', rotation=25)
    draw_arrow(ax, (0.34, 0.58), (0.40, 0.58), color=PRIMARY, width=2.5)
    ax.text(0.37, 0.595, 'proxy', fontsize=7, color=PRIMARY, fontfamily='monospace')
    draw_arrow(ax, (0.55, 0.42), (0.55, 0.35), color=DANGER, width=2)
    draw_arrow(ax, (0.40, 0.50), (0.34, 0.40), color=PURPLE, width=2,
               connectionstyle="arc3,rad=0.15")
    ax.text(0.35, 0.46, 'reads', fontsize=7, color=PURPLE, fontfamily='monospace')
    draw_arrow(ax, (0.68, 0.32), (0.74, 0.50), color=SUCCESS, width=2,
               connectionstyle="arc3,rad=-0.2")
    ax.text(0.73, 0.38, 'manages', fontsize=7, color=SUCCESS, fontfamily='monospace')
    draw_arrow(ax, (0.74, 0.50), (0.34, 0.17), color='#8b949e', width=1.5,
               connectionstyle="arc3,rad=0.3")
    draw_arrow(ax, (0.85, 0.42), (0.85, 0.20), color=FLOW_COLOR, width=1.5)

    watermark(ax)
    plt.tight_layout()
    plt.savefig(os.path.join(os.path.dirname(__file__), 'system-architecture.png'),
                dpi=180, facecolor=BG, bbox_inches='tight', pad_inches=0.3)
    plt.close()
    print("[+] system-architecture.png")


# ═══════════════════════════════════════════════════════════════
# DIAGRAM 2: Deployment Flow
# ═══════════════════════════════════════════════════════════════
def generate_deployment_flow():
    fig, ax = plt.subplots(1, 1, figsize=(16, 9))
    fig.patch.set_facecolor(BG)
    ax.set_facecolor(BG)
    ax.set_xlim(0, 1); ax.set_ylim(0, 1); ax.axis('off')

    ax.text(0.5, 0.95, 'DEPLOYMENT FLOW  --  WHAT HAPPENS WHEN YOU CLICK DEPLOY',
            fontsize=18, fontweight='bold', color=PRIMARY, ha='center',
            fontfamily='monospace')

    steps = [
        {'x': 0.05, 'num': '1', 'label': 'CLICK', 'sub': 'Pick an app\nChoose a mode',
         'color': FLOW_COLOR},
        {'x': 0.20, 'num': '2', 'label': 'LOAD', 'sub': 'Backend reads\nYAML template',
         'color': PURPLE},
        {'x': 0.35, 'num': '3', 'label': 'TRANSFORM', 'sub': 'Apply mode\nInject config',
         'color': ACCENT},
        {'x': 0.50, 'num': '4', 'label': 'COMPOSE', 'sub': 'docker compose\nup -d',
         'color': SUCCESS},
        {'x': 0.65, 'num': '5', 'label': 'STREAM', 'sub': 'SSE events\nReal-time logs',
         'color': ORANGE},
        {'x': 0.80, 'num': '6', 'label': 'RUNNING', 'sub': 'App is live\nAccess it now',
         'color': PRIMARY},
    ]

    step_y = 0.72; step_w = 0.13; step_h = 0.15

    for i, step in enumerate(steps):
        box = FancyBboxPatch((step['x'], step_y), step_w, step_h,
                             boxstyle="round,pad=0.015",
                             facecolor=step['color'], alpha=0.15,
                             edgecolor=step['color'], linewidth=2.5)
        ax.add_patch(box)

        # Number circle
        circle = plt.Circle((step['x'] + step_w/2, step_y + step_h - 0.025),
                            0.018, facecolor=step['color'], alpha=0.3,
                            edgecolor=step['color'], linewidth=1.5)
        ax.add_patch(circle)
        ax.text(step['x'] + step_w/2, step_y + step_h - 0.025, step['num'],
                fontsize=11, fontweight='bold', color=TEXT, ha='center',
                va='center', fontfamily='monospace')

        ax.text(step['x'] + step_w/2, step_y + step_h/2 + 0.005,
                step['label'], fontsize=12, fontweight='bold',
                color=TEXT, ha='center', va='center', fontfamily='monospace')
        ax.text(step['x'] + step_w/2, step_y + 0.025,
                step['sub'], fontsize=8, color=TEXT_DIM,
                ha='center', va='center', fontfamily='monospace', linespacing=1.4)

        if i < len(steps) - 1:
            draw_arrow(ax, (step['x'] + step_w + 0.005, step_y + step_h/2),
                       (steps[i+1]['x'] - 0.005, step_y + step_h/2),
                       color=step['color'], width=2.5)

    # Mode cards
    mode_y = 0.12; mode_h = 0.42
    section_label(ax, 0.05, mode_y + mode_h + 0.03,
                  'DEPLOYMENT MODES  --  WHAT CHANGES IN STEP 3', color=TEXT, fontsize=11)

    modes = [
        {'x': 0.05, 'name': 'STANDARD', 'color': SUCCESS,
         'desc': 'Direct port access',
         'transforms': ['[-] Strip Traefik labels', '[-] Remove ext networks',
                        '[~] Set network = bridge', '[+] Map host port directly'],
         'result': 'http://server:PORT'},
        {'x': 0.36, 'name': 'TRAEFIK', 'color': FLOW_COLOR,
         'desc': 'Reverse proxy + SSL',
         'transforms': ['[+] Keep Traefik labels', '[+] Join proxy network',
                        '[+] Auto SSL via LE', '[+] Route by hostname'],
         'result': 'https://app.domain.com'},
        {'x': 0.67, 'name': 'TRAEFIK + AUTHELIA', 'color': ACCENT,
         'desc': 'Proxy + Auth + MFA',
         'transforms': ['[+] Keep Traefik labels', '[+] Join proxy network',
                        '[+] Auto SSL via LE', '[+] Add auth middleware'],
         'result': 'https://app.domain.com [locked]'},
    ]

    for mode in modes:
        card = FancyBboxPatch((mode['x'], mode_y), 0.28, mode_h,
                              boxstyle="round,pad=0.015",
                              facecolor=CARD_BG, alpha=0.8,
                              edgecolor=mode['color'], linewidth=2)
        ax.add_patch(card)
        ax.text(mode['x'] + 0.14, mode_y + mode_h - 0.04, mode['name'],
                fontsize=14, fontweight='bold', color=mode['color'],
                ha='center', fontfamily='monospace')
        ax.text(mode['x'] + 0.14, mode_y + mode_h - 0.075, mode['desc'],
                fontsize=9, color=TEXT_DIM, ha='center', fontfamily='monospace')
        for i, t in enumerate(mode['transforms']):
            ax.text(mode['x'] + 0.03, mode_y + mode_h - 0.13 - i*0.06, t,
                    fontsize=9, color=TEXT, fontfamily='monospace')
        ax.plot([mode['x'] + 0.03, mode['x'] + 0.25],
                [mode_y + 0.09, mode_y + 0.09], color=CARD_BORDER, linewidth=1)
        ax.text(mode['x'] + 0.14, mode_y + 0.05, mode['result'],
                fontsize=10, fontweight='bold', color=mode['color'],
                ha='center', fontfamily='monospace')
        ax.text(mode['x'] + 0.14, mode_y + 0.025, 'Result',
                fontsize=8, color=TEXT_DIM, ha='center', fontfamily='monospace')

    watermark(ax)
    plt.tight_layout()
    plt.savefig(os.path.join(os.path.dirname(__file__), 'deployment-flow.png'),
                dpi=180, facecolor=BG, bbox_inches='tight', pad_inches=0.3)
    plt.close()
    print("[+] deployment-flow.png")


# ═══════════════════════════════════════════════════════════════
# DIAGRAM 3: Network Topology
# ═══════════════════════════════════════════════════════════════
def generate_network_topology():
    fig, ax = plt.subplots(1, 1, figsize=(16, 10))
    fig.patch.set_facecolor(BG)
    ax.set_facecolor(BG)
    ax.set_xlim(0, 1); ax.set_ylim(0, 1); ax.axis('off')

    ax.text(0.5, 0.96, 'NETWORK TOPOLOGY  --  THREE WAYS TO ACCESS YOUR APPS',
            fontsize=18, fontweight='bold', color=PRIMARY, ha='center',
            fontfamily='monospace')

    # ── Mode 1: Standard ──
    section_label(ax, 0.05, 0.88, 'MODE 1  ==  STANDARD (Local Network)',
                  color=SUCCESS, fontsize=12)

    rounded_box(ax, 0.05, 0.73, 0.15, 0.08, 'YOU',
                'Browser on LAN', color=SUCCESS, fontsize=11, fill_alpha=0.1)
    draw_arrow(ax, (0.20, 0.77), (0.33, 0.77), color=SUCCESS, width=3)
    ax.text(0.265, 0.79, 'http://192.168.1.x:PORT', fontsize=8,
            color=SUCCESS, ha='center', fontfamily='monospace')
    rounded_box(ax, 0.33, 0.73, 0.15, 0.08, 'SERVER',
                'Direct port access', color=SUCCESS, fontsize=11, fill_alpha=0.1)
    draw_arrow(ax, (0.48, 0.77), (0.55, 0.77), color=SUCCESS, width=2)

    apps_standard = ['Plex :32400', 'Radarr :7878', 'Sonarr :8989', 'Portainer :9000']
    for i, app in enumerate(apps_standard):
        y = 0.82 - i*0.035
        rounded_box(ax, 0.55, y, 0.18, 0.03, app, color=SUCCESS,
                    fontsize=8, fill_alpha=0.08, border_width=1)

    ax.text(0.82, 0.78, '+ Simple, no setup', fontsize=9, color=SUCCESS,
            fontfamily='monospace')
    ax.text(0.82, 0.755, '+ LAN only', fontsize=9, color=SUCCESS,
            fontfamily='monospace')
    ax.text(0.82, 0.73, '- No SSL', fontsize=9, color=TEXT_DIM,
            fontfamily='monospace')

    ax.plot([0.05, 0.95], [0.68, 0.68], color=CARD_BORDER, linewidth=1,
            linestyle=':', alpha=0.5)

    # ── Mode 2: Traefik ──
    section_label(ax, 0.05, 0.64, 'MODE 2  ==  TRAEFIK (Domain + SSL)',
                  color=FLOW_COLOR, fontsize=12)

    nodes_traefik = [
        {'x': 0.05, 'y': 0.46, 'w': 0.12, 'h': 0.10, 'label': 'INTERNET',
         'sub': 'plex.your.com'},
        {'x': 0.22, 'y': 0.46, 'w': 0.14, 'h': 0.10, 'label': 'CLOUDFLARE',
         'sub': 'DNS + CDN'},
        {'x': 0.42, 'y': 0.46, 'w': 0.14, 'h': 0.10, 'label': 'TRAEFIK',
         'sub': 'SSL + Routing'},
        {'x': 0.62, 'y': 0.46, 'w': 0.14, 'h': 0.10, 'label': 'CONTAINER',
         'sub': 'proxy network'},
    ]
    for node in nodes_traefik:
        rounded_box(ax, node['x'], node['y'], node['w'], node['h'],
                    node['label'], node['sub'], color=FLOW_COLOR,
                    fontsize=10, fill_alpha=0.12)

    draw_arrow(ax, (0.17, 0.51), (0.22, 0.51), color=FLOW_COLOR, width=2.5)
    draw_arrow(ax, (0.36, 0.51), (0.42, 0.51), color=FLOW_COLOR, width=2.5)
    draw_arrow(ax, (0.56, 0.51), (0.62, 0.51), color=FLOW_COLOR, width=2.5)

    # SSL badge
    ssl_box = FancyBboxPatch((0.44, 0.57), 0.10, 0.03, boxstyle="round,pad=0.005",
                             facecolor=SUCCESS, alpha=0.2, edgecolor=SUCCESS, linewidth=1)
    ax.add_patch(ssl_box)
    ax.text(0.49, 0.585, 'AUTO SSL', fontsize=8, color=SUCCESS,
            ha='center', fontfamily='monospace', fontweight='bold')

    ax.text(0.82, 0.54, '+ Custom domains', fontsize=9, color=FLOW_COLOR,
            fontfamily='monospace')
    ax.text(0.82, 0.515, '+ Free SSL certs', fontsize=9, color=FLOW_COLOR,
            fontfamily='monospace')
    ax.text(0.82, 0.49, '+ Access from anywhere', fontsize=9, color=FLOW_COLOR,
            fontfamily='monospace')
    ax.text(0.82, 0.465, '- Needs domain ($10/yr)', fontsize=9, color=TEXT_DIM,
            fontfamily='monospace')

    ax.plot([0.05, 0.95], [0.41, 0.41], color=CARD_BORDER, linewidth=1,
            linestyle=':', alpha=0.5)

    # ── Mode 3: Traefik + Authelia ──
    section_label(ax, 0.05, 0.37, 'MODE 3  ==  TRAEFIK + AUTHELIA (Domain + SSL + Auth)',
                  color=ACCENT, fontsize=12)

    nodes_auth = [
        {'x': 0.05, 'y': 0.19, 'w': 0.12, 'h': 0.10, 'label': 'INTERNET',
         'sub': 'radarr.your.com', 'color': ACCENT},
        {'x': 0.22, 'y': 0.19, 'w': 0.14, 'h': 0.10, 'label': 'CLOUDFLARE',
         'sub': 'DNS + CDN', 'color': ACCENT},
        {'x': 0.42, 'y': 0.19, 'w': 0.14, 'h': 0.10, 'label': 'TRAEFIK',
         'sub': 'SSL + Routing', 'color': ACCENT},
        {'x': 0.62, 'y': 0.19, 'w': 0.14, 'h': 0.10, 'label': 'AUTHELIA',
         'sub': 'Login + MFA', 'color': DANGER},
        {'x': 0.82, 'y': 0.19, 'w': 0.14, 'h': 0.10, 'label': 'CONTAINER',
         'sub': 'Protected', 'color': ACCENT},
    ]
    for node in nodes_auth:
        rounded_box(ax, node['x'], node['y'], node['w'], node['h'],
                    node['label'], node['sub'], color=node.get('color', ACCENT),
                    fontsize=10, fill_alpha=0.12)

    draw_arrow(ax, (0.17, 0.24), (0.22, 0.24), color=ACCENT, width=2.5)
    draw_arrow(ax, (0.36, 0.24), (0.42, 0.24), color=ACCENT, width=2.5)
    draw_arrow(ax, (0.56, 0.24), (0.62, 0.24), color=ACCENT, width=2.5)
    draw_arrow(ax, (0.76, 0.24), (0.82, 0.24), color=ACCENT, width=2.5)

    auth_box = FancyBboxPatch((0.63, 0.30), 0.12, 0.03, boxstyle="round,pad=0.005",
                              facecolor=DANGER, alpha=0.2, edgecolor=DANGER, linewidth=1)
    ax.add_patch(auth_box)
    ax.text(0.69, 0.315, 'SSO + 2FA', fontsize=8, color=DANGER,
            ha='center', fontfamily='monospace', fontweight='bold')

    ax.text(0.05, 0.13, '+ Everything in Mode 2, plus:', fontsize=9,
            color=ACCENT, fontfamily='monospace')
    ax.text(0.05, 0.105, '+ Single sign-on across all apps', fontsize=9,
            color=ACCENT, fontfamily='monospace')
    ax.text(0.05, 0.08, '+ Optional two-factor authentication', fontsize=9,
            color=ACCENT, fontfamily='monospace')
    ax.text(0.05, 0.055, '+ Per-user access control', fontsize=9,
            color=ACCENT, fontfamily='monospace')

    watermark(ax)
    plt.tight_layout()
    plt.savefig(os.path.join(os.path.dirname(__file__), 'network-topology.png'),
                dpi=180, facecolor=BG, bbox_inches='tight', pad_inches=0.3)
    plt.close()
    print("[+] network-topology.png")


# ═══════════════════════════════════════════════════════════════
# DIAGRAM 4: Request Lifecycle
# ═══════════════════════════════════════════════════════════════
def generate_request_lifecycle():
    fig, ax = plt.subplots(1, 1, figsize=(16, 8))
    fig.patch.set_facecolor(BG)
    ax.set_facecolor(BG)
    ax.set_xlim(0, 1); ax.set_ylim(0, 1); ax.axis('off')

    ax.text(0.5, 0.95, 'API REQUEST LIFECYCLE', fontsize=18,
            fontweight='bold', color=PRIMARY, ha='center', fontfamily='monospace')
    ax.text(0.5, 0.91, 'Every request through the stack', fontsize=11,
            color=TEXT_DIM, ha='center', fontfamily='monospace')

    # Read path
    section_label(ax, 0.05, 0.83, 'READ PATH  (GET /applications)',
                  color=SUCCESS, fontsize=11)

    read_steps = [
        ('Browser', 'GET /api/applications', FLOW_COLOR, 0.75),
        ('nginx', 'Strip /api prefix -> proxy to :8092', PRIMARY, 0.63),
        ('Express', 'Route -> auth middleware (optional)', ACCENT, 0.51),
        ('CLI Bridge', 'Return cached app catalog', PURPLE, 0.39),
        ('Response', '200 OK + JSON (123 apps)', SUCCESS, 0.27),
    ]

    for i, (label, desc, color, y) in enumerate(read_steps):
        box = FancyBboxPatch((0.05, y), 0.40, 0.09, boxstyle="round,pad=0.012",
                             facecolor=color, alpha=0.12,
                             edgecolor=color, linewidth=2)
        ax.add_patch(box)
        ax.text(0.08, y + 0.058, label, fontsize=11, fontweight='bold',
                color=TEXT, fontfamily='monospace')
        ax.text(0.08, y + 0.025, desc, fontsize=8, color=TEXT_DIM,
                fontfamily='monospace')
        if i < len(read_steps) - 1:
            draw_arrow(ax, (0.25, y), (0.25, y - 0.03), color=color, width=2)

    # Deploy path
    section_label(ax, 0.55, 0.83, 'DEPLOY PATH  (POST /deploy)',
                  color=ORANGE, fontsize=11)

    write_steps = [
        ('Browser', 'POST /api/deploy { appId, mode }', FLOW_COLOR, 0.75),
        ('Express', 'Auth check -> validate payload', ACCENT, 0.63),
        ('CLI Bridge', 'Load YAML -> transform -> inject env', PURPLE, 0.51),
        ('Docker SDK', 'docker compose up -d  (via socket)', DANGER, 0.39),
        ('SSE Stream', 'Real-time events -> browser', ORANGE, 0.27),
    ]

    for i, (label, desc, color, y) in enumerate(write_steps):
        box = FancyBboxPatch((0.55, y), 0.40, 0.09, boxstyle="round,pad=0.012",
                             facecolor=color, alpha=0.12,
                             edgecolor=color, linewidth=2)
        ax.add_patch(box)
        ax.text(0.58, y + 0.058, label, fontsize=11, fontweight='bold',
                color=TEXT, fontfamily='monospace')
        ax.text(0.58, y + 0.025, desc, fontsize=8, color=TEXT_DIM,
                fontfamily='monospace')
        if i < len(write_steps) - 1:
            draw_arrow(ax, (0.75, y), (0.75, y - 0.03), color=color, width=2)

    # Auth methods
    ax.plot([0.05, 0.95], [0.22, 0.22], color=CARD_BORDER, linewidth=1,
            linestyle=':', alpha=0.5)
    section_label(ax, 0.05, 0.18, 'AUTHENTICATION METHODS', color=TEXT, fontsize=11)

    auth_methods = [
        ('JWT Token', 'POST /auth/login -> Bearer eyJhb...', ACCENT, 0.05),
        ('API Key', 'Bearer hlr_a1b2c3... (permanent)', PURPLE, 0.35),
        ('No Auth', 'When AUTH_ENABLED=false', TEXT_DIM, 0.65),
    ]
    for label, desc, color, x in auth_methods:
        box = FancyBboxPatch((x, 0.06), 0.27, 0.08, boxstyle="round,pad=0.01",
                             facecolor=color, alpha=0.1,
                             edgecolor=color, linewidth=1.5)
        ax.add_patch(box)
        ax.text(x + 0.135, 0.115, label, fontsize=10, fontweight='bold',
                color=TEXT, ha='center', fontfamily='monospace')
        ax.text(x + 0.135, 0.085, desc, fontsize=7, color=TEXT_DIM,
                ha='center', fontfamily='monospace')

    watermark(ax)
    plt.tight_layout()
    plt.savefig(os.path.join(os.path.dirname(__file__), 'request-lifecycle.png'),
                dpi=180, facecolor=BG, bbox_inches='tight', pad_inches=0.3)
    plt.close()
    print("[+] request-lifecycle.png")


if __name__ == '__main__':
    generate_system_architecture()
    generate_deployment_flow()
    generate_network_topology()
    generate_request_lifecycle()
    print("\nAll diagrams generated!")
