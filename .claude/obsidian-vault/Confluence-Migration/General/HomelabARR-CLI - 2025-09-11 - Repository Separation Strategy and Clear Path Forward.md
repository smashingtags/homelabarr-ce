---
title: "HomelabARR-CLI : 2025-09-11 - Repository Separation Strategy and Clear Path Forward"
confluence_id: "18055170"
confluence_url: "https://mjashley.atlassian.net/wiki/spaces/DO/pages/18055170"
confluence_space: "DO"
category: "General"
created_date: "2025-09-11"
updated_date: "2025-09-11"
migrated_date: "2025-09-14"
tags: ['frontend', 'golang', 'project-management', 'september-2025', 'storage']
---

# Repository Separation Strategy and Clear Path Forward

## Current Situation (As of September 11, 2025)

- **Working Code**: Currently in`homelabarr-cli`repository on`fix/storage-modal-cors-issues`branch
- **Status**: Application is FUNCTIONAL with Bootstrap CSS providing modal overlays
- **Problem**: Need clear separation of commercial (PE) and community (CE) versions
## Proposed Repository Structure

### 1. HomelabARR-PE (Professional Edition)

- **Purpose**: Commercial version for sale
- **Location**:`/f/Coding Projects/homelabarr-pe`
- **Content**: Current working code from homelabarr-cli
- **Status**: Already exists but needs updated code
### 2. HomelabARR-CE (Community Edition)

- **Purpose**: Free community version
- **Location**:`/f/Coding Projects/homelabarr-ce`(TO BE CREATED)
- **Content**: Sanitized version without proprietary features
- **History**: Fresh start, no git history
### 3. HomelabARR-CLI (Archive)

- **Purpose**: Historical reference and git commit archive
- **Location**:`/f/Coding Projects/homelabarr-cli`(CURRENT)
- **Status**: Will become read-only archive
- **Value**: Preserves all development history and decisions
## Step-by-Step Migration Plan

### Phase 1: Preparation

- **DOCUMENT EVERYTHING**before any action
- Commit current working state in homelabarr-cli
- Tag the working version:`git tag WORKING-PRE-SEPARATION`
- Create comprehensive backup
### Phase 2: Update HomelabARR-PE

- Copy working code from homelabarr-cli/v2-poc to homelabarr-pe
- Ensure Bootstrap CSS is included (temporary until shadcn migration)
- Test all functionality works
- Verify modals display as overlays
- Commit with clear message about working state
### Phase 3: Create HomelabARR-CE

- Create new repository homelabarr-ce
- Copy sanitized code (remove commercial features)
- Start with fresh git history (`git init`)
- Add appropriate open-source license
- Document community vs professional features
### Phase 4: Archive HomelabARR-CLI

- Add README explaining this is now an archive
- Set repository to read-only (if using GitHub)
- Keep available for historical reference
- Document where active development moved to
## Critical Success Factors

### What MUST Be Preserved

- Working modal overlays (Bootstrap CSS)
- Theme system (HomelabARR Dark/Light, purple gradient)
- All current functionality
- Backend/frontend integration on correct ports
### What MUST Be Documented

- Which features are PE-only vs CE
- Bootstrap to shadcn migration plan
- Current dependencies and versions
- Port requirements (8080 backend, 5173 frontend)
## Communication Gap Prevention

### Problems We've Had

- Working in wrong repository
- Changes not being tracked properly
- Confusion about what's done vs not done
- Bootstrap removal breaking modals
### Solutions Going Forward

- ONE repository for active development (PE)
- Update Jira ticket DESCRIPTIONS, not comments
- Check Confluence documentation BEFORE starting work
- Test EVERYTHING after dependency changes
## Current Working State Checklist

### Verified Working Components

- [x] Backend server on port 8080
- [x] Frontend server on port 5173
- [x] Modal overlays (with Bootstrap CSS)
- [x] Theme system
- [x] Container management
- [x] Storage configuration
- [x] App installation
### Known Issues

- [ ] Bootstrap classes need migration to shadcn/ui (cosmetic, not blocking)
- [ ] 6 files still using Bootstrap classes
- [ ] Modal positioning depends on Bootstrap CSS
## Next Actions Required

### Before ANY Code Changes

- **WAIT for explicit approval**of this plan
- **Document current working state**with screenshots
- **Create backup**of working version
- **Update Jira tickets**with current status
### Repository Commands (DO NOT RUN YET)

```
# Tag current working version
cd /f/Coding\ Projects/homelabarr-cli
git add -A
git commit -m "WORKING STATE: Modals functional with Bootstrap CSS"
git tag WORKING-PRE-SEPARATION

# These will be run ONLY after approval
# Create homelabarr-ce
# Copy to homelabarr-pe
# Archive homelabarr-cli
```