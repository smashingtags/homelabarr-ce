# HomelabARR CE App Catalog Audit
**Generated:** 2026-03-25
**Total Apps:** ~137 unique templates (excluding .config, .sample, .subactions, GPU variants)
**Method:** Image extraction from YAMLs + Docker Hub pull/update data + LSIO fleet API cross-reference

---

## Kill List (Recommend Removal)

These apps have dead/abandoned upstream images, no updates in 12+ months, or are functionally replaced.

| App | Category | Image | Last Updated | Reason |
|-----|----------|-------|-------------|--------|
| **nowshowing** | selfhosted | `ninthwalker/nowshowing:v2.3.85` | 2019-01-22 | Abandoned 7+ years, ancient |
| **dashmachine** | addons | `rmountjoy/dashmachine:latest` | 2020-09-22 | Abandoned 5+ years, replaced by Dashy/Homepage |
| **statping** | system | `statping/statping:latest` | 2020-12-20 | Abandoned 5+ years, replaced by Uptime Kuma |
| **rclone-gui** | system | `d2dyno/rclone-gui:latest` | 2020-09-11 | Abandoned 5+ years, unofficial rclone wrapper |
| **crewlink** | selfhosted | `ottomated/crewlink-server:2.8.4` | 2021-01-10 | Among Us proximity chat, completely dead |
| **moviematch** | selfhosted | `lukechannings/moviematch:v1.13.0` | 2021-08-09 | Abandoned 4+ years |
| **wg-manager** | selfhosted | `perara/wg-manager:v2.4.0` | 2021-03-21 | Abandoned 5+ years, wg-easy is the modern replacement |
| **bliss** | selfhosted | `romancin/bliss:0.0.210` | 2021-10-31 | Music tagger, abandoned 4+ years |
| **alltube** | selfhosted | `rudloff/alltube:3.0.3` | 2021-07-25 | YouTube downloader, abandoned 4+ years |
| **xteve** (both) | mediamanager | `alturismo/xteve` | 2021-08-03 | IPTV proxy, abandoned 4+ years |
| **ferdi** | selfhosted | `getferdi/ferdi-server:1.5.11` | 2022-03-14 | Abandoned, forked as Ferdium (LSIO has it) |
| **gaps** | mediamanager | `housewrecker/gaps:0.10.1` | 2022-04-01 | Movie gap finder, abandoned 4+ years |
| **koel** | selfhosted | `hyzual/koel:7.0.1` | 2022-03-10 | Music streamer, abandoned 4+ years |
| **dim** | mediaserver | `ghcr.io/dusk-labs/dim:dev` | N/A | GitHub archived, project dead |
| **sui** | addons | `jamesread/sui:latest` | N/A (no Hub data) | Simple start page, abandoned, replaced by Homepage/Dashy |
| **muximux** | selfhosted | `lscr.io/linuxserver/muximux` | Deprecated by LSIO | LSIO deprecated this image, ancient |
| **cloud9** | coding | `lscr.io/linuxserver/cloud9` | Deprecated by LSIO | LSIO deprecated, replaced by Code Server |
| **embystat** | mediamanager | `lscr.io/linuxserver/embystat` | Deprecated | EmbyStat project abandoned |
| **kitana** | addons | `pannal/kitana:latest` | 2023-04-07 | Plex dropped plugin support, kitana is useless |
| **plex-utills** | mediamanager | `jkirkcaldy/plex-utills` | 2023-10-11 | Low pulls (343K), mostly replaced by Kometa |
| **yacht** | addons | `selfhostedpro/yacht:latest` | 2023-01-19 | Abandoned 3+ years, replaced by Portainer |
| **deemix** | addons | `registry.gitlab.com/bockiii/deemix-docker` | Unknown | Legally questionable (Deezer ripper), project dead |
| **striparr** | encoder | `mikenye/striparr:1.0.0` | 2023-03-02 | Very niche, abandoned 3+ years |
| **amd** | downloadclients | `randomninjaatk/amd:2.3.1` | N/A (no Hub data) | Automated Music Downloader, abandoned |
| **petio** | request | `ghcr.io/petio-team/petio:1.0.1` | Abandoned | Replaced by Overseerr/Jellyseerr |
| **conreq** | request | `ghcr.io/roxedus/conreq:1.4.2` | Abandoned | Replaced by Overseerr/Jellyseerr |
| **dockupdater** | system | `dockupdater/dockupdater:latest` | Abandoned | Replaced by Watchtower (already in catalog) |
| **local-persist-plugin** | system | `ghcr.io/smashingtags/local-persist:latest` | N/A | Per project notes: already removed from CE, bind mounts used |
| **speedtest** | addons | `henrywhitaker3/speedtest-tracker` | 2023-06-25 | Author abandoned; LSIO maintains the successor |
| **instaloader** | addons | `didc/docker-instaloader:latest` | 2024-07-12 | Very low pulls (79K), niche Instagram scraper |
| **fenrus** | IMAGE_DEFAULTS | `lscr.io/linuxserver/fenrus:latest` | Deprecated by LSIO | LSIO deprecated this dashboard |

**Total: 31 apps recommended for removal** (reduces catalog from ~137 to ~106)

---

## Switch to LSIO

These apps currently use non-LSIO images but LinuxServer.io maintains an equivalent with better consistency (PUID/PGID, s6-overlay, regular rebuilds, multi-arch).

| App | Current Image | LSIO Image | Notes |
|-----|---------------|------------|-------|
| **changedetection** | `dgtlmoon/changedetection.io:0.46.04` | `lscr.io/linuxserver/changedetection.io` | Upstream is fine but LSIO adds consistency |
| **fail2ban** | `ghcr.io/crazy-max/fail2ban:1.1.0` | `lscr.io/linuxserver/fail2ban` | LSIO version has better homelab integration |
| **speedtest** | `henrywhitaker3/speedtest-tracker` | `lscr.io/linuxserver/speedtest-tracker` | Old image dead; LSIO maintains the successor |
| **handbrake** | `docker.io/jlesage/handbrake:24.03.1` | `lscr.io/linuxserver/handbrake` | jlesage is solid but LSIO is more consistent |
| **filezilla** | `docker.io/jlesage/filezilla:latest` | `lscr.io/linuxserver/filezilla` | Same reasoning as handbrake |
| **homeassistant** | `homeassistant/home-assistant:2025.1.6` | `lscr.io/linuxserver/homeassistant` | Official is fine; LSIO adds PUID/PGID support |
| **makemkv** | `docker.io/jlesage/makemkv:24.03.1` | *(no LSIO equivalent)* | Keep as-is, jlesage is the standard |
| **organizr** | `organizr/organizr:2.1.2670` | *(no LSIO equivalent)* | Keep but note: last update Dec 2023 |
| **guacamole** | `jasonbean/guacamole:1.5.4` | *(no LSIO equivalent)* | Keep, still updated (Jan 2024) |

**Priority switches:** speedtest (dead upstream), fail2ban, changedetection, handbrake, filezilla

---

## Healthy Apps (No Action Needed)

These are actively maintained with strong pull counts:

| App | Image | Pulls | Last Updated |
|-----|-------|-------|-------------|
| All LSIO *arr apps | `lscr.io/linuxserver/*` | Millions+ | Continuously |
| Plex | `lscr.io/linuxserver/plex` | Millions+ | Continuously |
| Jellyfin | `lscr.io/linuxserver/jellyfin` | Millions+ | Continuously |
| Emby | `lscr.io/linuxserver/emby` | Millions+ | Continuously |
| Portainer | `portainer/portainer-ce` | 1.4B | 2026-03-21 |
| Uptime Kuma | `louislam/uptime-kuma` | 146M | 2026-03-25 |
| Pi-hole | `pihole/pihole` | 948M | 2026-03-24 |
| Dozzle | `amir20/dozzle` | 292M | 2026-03-23 |
| Home Assistant | `homeassistant/home-assistant` | 752M | 2026-03-25 |
| Vaultwarden | `vaultwarden/server` | 267M | 2026-03-23 |
| n8n | `n8nio/n8n` | 196M | 2026-03-25 |
| Netdata | `netdata/netdata` | 509M | 2026-03-25 |
| Watchtower | `ghcr.io/containrrr/watchtower` | Millions+ | Active |
| Gluetun | `qmcgaw/gluetun` | 37M | 2026-03-23 |
| Tdarr | `ghcr.io/haveagitgat/tdarr` | Active | Active |
| Dashy | `ghcr.io/lissy93/dashy` | Active | Active |
| Homepage | `ghcr.io/benphelps/homepage` | Active | Active |
| Kometa | `kometateam/kometa` | 2.5M | 2026-03-15 |
| Recyclarr | `ghcr.io/recyclarr/recyclarr` | Active | Active |
| Whoogle | `benbusby/whoogle-search` | 19.6M | 2026-03-23 |
| Recipes (Tandoor) | `vabene1111/recipes` | 11.3M | 2026-03-24 |
| CloudCmd | `coderaiser/cloudcmd` | 87.5M | 2026-03-24 |
| Changedetection | `dgtlmoon/changedetection.io` | 10M | 2026-03-24 |
| YoutubeDL Material | `tzahi12345/youtubedl-material` | 28.2M | 2025-03-18 |
| Unmanic | `josh5/unmanic` | 14.9M | 2026-03-22 |
| OliveTin | `jamesread/olivetin` | 1M | 2026-03-11 |
| ioBroker | `buanet/iobroker` | 31.3M | 2026-03-25 |
| Coder | `ghcr.io/coder/coder` | Active | Active |
| FlareSolverr | `ghcr.io/flaresolverr/flaresolverr` | Active | Active |
| Cloudflared | `cloudflare/cloudflared` | Active | Active |
| DIUN | `ghcr.io/crazy-max/diun` | Active | Active |
| TubeSync | `ghcr.io/meeb/tubesync` | Active | Active |
| Notifiarr | `golift/notifiarr` | 4.7M | 2026-03-08 |
| WordPress | `wordpress:6.7-apache` | Official | Active |
| All KasmWeb images | `kasmweb/*:1.9.0-rolling` | Active | Consider updating to 1.15+ |
| Grafana/Loki/Prometheus | Official images | Active | Active |
| All databases (MariaDB, PostgreSQL, MySQL, MongoDB, Redis) | Official images | Active | Active |

---

## New: AI & Machine Learning Category

Suggested apps for a new `ai-ml` category. All include NVIDIA GPU runtime config where applicable.

| App | Image | GPU Required | Description |
|-----|-------|-------------|-------------|
| **Ollama** | `ollama/ollama:latest` | Recommended (CPU fallback) | Local LLM inference server. Run Llama, Mistral, Gemma locally. |
| **Open WebUI** | `ghcr.io/open-webui/open-webui:main` | No (connects to Ollama) | ChatGPT-style web UI for Ollama and OpenAI-compatible APIs. |
| **LocalAI** | `localai/localai:latest-gpu-nvidia-cuda-12` | Recommended | OpenAI-compatible local AI API. Supports LLMs, image gen, TTS, STT. |
| **ComfyUI** | `ghcr.io/ai-dock/comfyui:latest` | Yes | Node-based Stable Diffusion workflow editor for image generation. |
| **Stable Diffusion WebUI** | `ghcr.io/ai-dock/stable-diffusion-webui:latest` | Yes | AUTOMATIC1111's popular Stable Diffusion image generator. |
| **text-generation-webui** | `atinoda/text-generation-webui:default-nvidia` | Yes | Oobabooga's LLM interface. Supports GGUF, GPTQ, AWQ models. |
| **Faster Whisper** | `lscr.io/linuxserver/faster-whisper` | Recommended (CPU fallback) | Speech-to-text transcription server. LSIO maintained! |
| **LiteLLM** | `ghcr.io/berriai/litellm:main-latest` | No | Unified proxy for 100+ LLM providers. OpenAI-compatible API. |
| **Flowise** | `flowiseai/flowise:latest` | No | Drag-and-drop LLM workflow/chatbot builder. |
| **Dify** | `langgenius/dify-api:latest` | No | Open-source LLMOps platform for building AI apps. |
| **Jan** | `ghcr.io/janhq/jan:latest` | Recommended (CPU fallback) | Offline-first ChatGPT alternative. Run LLMs locally. |
| **InvokeAI** | `ghcr.io/invoke-ai/invokeai:latest` | Yes | Professional Stable Diffusion toolkit with advanced inpainting. |
| **Fooocus** | `ghcr.io/lllyasviel/fooocus:latest` | Yes | Simplified Stable Diffusion. Midjourney-like ease of use. |
| **GPT4All** | `nomic-ai/gpt4all:latest` | Recommended (CPU fallback) | Privacy-focused local chatbot. Runs on consumer hardware. |

### GPU Runtime Configuration

All GPU-enabled templates should include this deploy block:

```yaml
deploy:
  resources:
    reservations:
      devices:
        - driver: nvidia
          count: all
          capabilities: [gpu]
```

### Additional environment variables for GPU apps:
```yaml
environment:
  - NVIDIA_VISIBLE_DEVICES=all
  - NVIDIA_DRIVER_CAPABILITIES=compute,utility
```

### Notes on AI/ML Category:
1. **n8n is already in the catalog** (addons category) — don't duplicate, but consider cross-referencing it as AI-adjacent
2. **Faster Whisper has an LSIO image** (`lscr.io/linuxserver/faster-whisper`) — use it!
3. **Ollama + Open WebUI** is the most popular combo — consider a bundled template
4. **ComfyUI and SD WebUI** need significant VRAM (8GB+ recommended)
5. **LiteLLM and Flowise** are lightweight and don't need GPUs
6. **Dify** requires PostgreSQL + Redis (multi-container compose)
7. **Docker must have NVIDIA Container Toolkit installed** — add a pre-check or note in the UI

---

## Summary

| Action | Count |
|--------|-------|
| **Remove (dead/deprecated)** | 31 apps |
| **Switch to LSIO** | 5 priority switches |
| **New AI/ML apps** | 14 suggested |
| **Healthy (no action)** | ~100 apps |
| **Post-cleanup catalog size** | ~120 apps (106 existing + 14 new) |

### Quick Wins
1. Remove the 31 dead apps — instant catalog quality improvement
2. Switch speedtest to LSIO version — dead upstream
3. Add Ollama + Open WebUI as first AI apps — huge demand
4. Update KasmWeb images from 1.9.0 to latest (1.15+)
5. Add Faster Whisper (already has LSIO image!)

### Kasmworkspace Note
All 10 Kasm images are pinned to `1.9.0-rolling` which is very outdated. Current Kasm is 1.15+. These should be version-bumped even if not removed.
