---
title: "HomelabARR-CLI : 2025.08.20 Legacy Docker Base Directory Cleanup - HL-147"
confluence_id: "7503874"
confluence_url: "https://mjashley.atlassian.net/wiki/spaces/DO/pages/7503874"
confluence_space: "DO"
category: "Docker"
created_date: "2025-08-20"
updated_date: "2025-08-20"
migrated_date: "2025-09-14"
tags: ['frontend', 'epic', 'docker']
---

# Legacy Docker Base Directory Cleanup

## Overview

This document provides the technical implementation details for cleaning up legacy docker-*base directories after the successful migration to homelabarr-*[[HL-147]]
## Background

After completing the container naming standardization (docker-*→ homelabarr-*), we have duplicate base directories that need to be safely removed. This cleanup will: - Reduce repository size - Prevent confusion between old and new naming - Ensure consistency across the codebase
## Directory Mapping
Old DirectoryNew DirectoryStatusbase/docker-alpinebase/homelabarr-alpine✅ Migratedbase/docker-alpine-v3base/homelabarr-alpine-v3✅ Migratedbase/docker-configbase/homelabarr-config✅ Migratedbase/docker-createbase/homelabarr-create✅ Migratedbase/docker-dockserverbase/homelabarr-legacy-base✅ Migratedbase/docker-ubuntu-focalbase/homelabarr-ubuntu-focal✅ Migratedbase/docker-ubuntu-jammybase/homelabarr-ubuntu-jammy✅ Migratedbase/docker-ubuntu-noblebase/homelabarr-ubuntu-noble✅ Migratedbase/docker-uibase/homelabarr-ui✅ Migrated