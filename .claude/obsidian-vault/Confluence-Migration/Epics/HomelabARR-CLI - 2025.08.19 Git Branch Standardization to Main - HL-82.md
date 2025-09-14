---
title: "HomelabARR-CLI : 2025.08.19 Git Branch Standardization to Main - HL-82"
confluence_id: "6389792"
confluence_url: "https://mjashley.atlassian.net/wiki/spaces/DO/pages/6389792"
confluence_space: "DO"
category: "Epics"
created_date: "2020-07-27"
updated_date: "2020-07-27"
migrated_date: "2025-09-14"
tags: ['frontend', 'epic']
---

# Git Branch Standardization to Main

## Executive Summary

Standardize all HomelabARR repositories to use`main`as the default branch instead of`master`for consistency with modern Git practices and GitHub defaults.[[HL-82]]- Standardize HomelabARR repositories to use 'main' branch**Total Effort**: 6 Story Points**Priority**: Medium**Risk Level**: Low (with proper migration steps)
## Current State Analysis

### Repository Branch Status
RepositoryCurrent DefaultHas MainHas MasterAction Requiredhomelabarr-climaster✅ Yes✅ YesRemove master, set main as defaulthomelabarr-containersmaster❌ No✅ YesCreate main, migrate, remove master