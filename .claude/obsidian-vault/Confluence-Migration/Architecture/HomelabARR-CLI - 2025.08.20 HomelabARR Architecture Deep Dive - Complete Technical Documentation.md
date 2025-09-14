---
title: "HomelabARR-CLI : 2025.08.20 HomelabARR Architecture Deep Dive - Complete Technical Documentation"
confluence_id: "7602179"
confluence_url: "https://mjashley.atlassian.net/wiki/spaces/DO/pages/7602179"
confluence_space: "DO"
category: "Architecture"
created_date: ""
updated_date: ""
migrated_date: "2025-09-14"
tags: ['docker']
---

# HomelabARR Architecture Deep Dive

## Complete Technical Documentation - August 2025

## Executive Summary

This document captures the complete technical architecture and evolution of HomelabARR, including all lessons learned during the migration from Dockserver, implementation of semantic versioning, container standardization, and strategic positioning with AI tools integration.
## 1. Project Evolution

### From Dockserver to HomelabARR

HomelabARR evolved from the Dockserver project through a complete rebranding and modernization effort:AspectBefore (Dockserver)After (HomelabARR)**Brand**DockserverHomelabARR**Containers**docker-* naminghomelabarr-* naming**Registry**Mixed locationsGHCR primary**Versioning**SHA tagsSemantic versioning**References**3,321 dockserver refsFully cleaned