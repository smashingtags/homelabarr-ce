---
title: "HomelabARR-CLI : 2025-09-11 - Sprint 6 Bootstrap Migration Risk Assessment and Strategy"
confluence_id: "17858587"
confluence_url: "https://your-instance.atlassian.net/wiki/spaces/DO/pages/17858587"
confluence_space: "DO"
category: "Project-Management"
created_date: "2025-09-11"
updated_date: "2025-09-11"
migrated_date: "2025-09-14"
tags: ['frontend', 'epic', 'golang', 'project-management', 'september-2025', 'monitoring', 'storage']
---

# Sprint 6 Bootstrap Migration Risk Assessment and Strategy

## 🚨 CRITICAL FINDINGS

### Current State vs Sprint Tickets

The Sprint 6 tickets accurately reflect the REAL problem -**290+ Bootstrap classes still active across 35 files**. The tickets are well-scoped but underestimate the breaking change potential.
## 📊 Sprint 6 Ticket Analysis

### High Risk Tickets (Will Break Current Functionality)

#### HL-363: InstallationWizard Modal (5 SP) ⚠️**CRITICAL**

- **Current State**: Bootstrap modal structure without CSS = partially broken
- **Breaking Changes**:
- Modal currently renders but not as overlay
- Multi-step wizard state management may break
- Form validation tied to Bootstrap
- **Risk**: HIGH - Core app installation feature
#### HL-361: ContainerDetailsModal (5 SP) ⚠️**CRITICAL**

- **Current State**: 53 Bootstrap classes across modal and forms
- **Breaking Changes**:
- Container management UI will break
- Form editing functionality at risk
- Modal z-index stacking issues
- **Risk**: HIGH - Essential container operations
#### HL-359: StorageSetupWizard Modal (3 SP) ⚠️**HIGH**

- **Current State**: Already broken - appears at bottom of page
- **Breaking Changes**:
- Already non-functional as modal
- Wizard flow needs complete rebuild
- **Risk**: MEDIUM - Already broken, can't get worse
### Medium Risk Tickets

#### HL-360: Network Page Grid System (2 SP) ⚠️**MEDIUM**

- **Current State**: 43 Bootstrap grid classes (row, col-*)
- **Breaking Changes**:
- Layout will completely collapse
- Responsive breakpoints will fail
- Side-by-side components will stack
- **Risk**: MEDIUM - Visual only, functionality intact
#### HL-362: Settings Forms (3 SP) ⚠️**MEDIUM**

- **Current State**: 30 form-related Bootstrap classes
- **Breaking Changes**:
- Form styling will break
- Validation may fail
- Select dropdowns won't style correctly
- **Risk**: MEDIUM - Forms still function, just ugly
#### HL-364: QuickStartModal (2 SP) ⚠️**LOW**

- **Current State**: 20 Bootstrap modal classes
- **Breaking Changes**:
- Modal won't overlay properly
- Close button styling broken
- **Risk**: LOW - Non-critical feature
## 🔴 What's NOT in Sprint but CRITICAL

### Storage Components -**COMPLETELY UNMIGRATED**

- `MergerFSStatus.tsx`- Heavy Bootstrap usage
- `DiskHealth.tsx`- Bootstrap grid throughout
- `SnapRAIDStatus.tsx`- Bootstrap buttons and layout
- **Impact**: Storage page will be severely broken
### Main Navigation -**PARTIAL MIGRATION**

- `MainLayout.tsx`- 16 nav-item/nav-link classes
- **Impact**: Navigation may lose styling/functionality
## ⚠️ ACTUAL BREAKING CHANGES EXPECTED

### Immediate Breaks (Upon Bootstrap Removal):

- **All Modals**- Won't display as overlays
- **All Grids**- Layouts will collapse
- **All Forms**- Will lose styling and alignment
- **All Buttons**- Will appear as plain text
- **Navigation**- May lose structure
### Functionality Loss:

- Container management (can't edit containers)
- App installation (wizard broken)
- Storage configuration (wizard broken)
- Network monitoring (layout broken)
- Settings changes (forms broken)
## ✅ RECOMMENDED MIGRATION STRATEGY

### Phase 1: Critical Path First (Week 1)

- **DO NOT REMOVE BOOTSTRAP YET**
- Migrate modals first (they're already partially broken)
- Test each modal thoroughly before moving on
- Keep both frameworks running simultaneously
### Phase 2: Layout Migration (Week 2)

- Replace grid systems page by page
- Start with less critical pages (Network)
- Move to critical pages (Storage, Containers)
- Verify responsive breakpoints work
### Phase 3: Form Migration (Week 3)

- Migrate form components incrementally
- Ensure validation still works
- Test all CRUD operations
### Phase 4: Final Cleanup (Week 4)

- Remove Bootstrap dependencies
- Full regression testing
- Performance validation
- Bundle size verification
## 🛡️ Risk Mitigation

### Safeguards:

- **Feature Flag System**: Toggle between Bootstrap/shadcn per component
- **Parallel Development**: Keep Bootstrap branch as fallback
- **Incremental Deployment**: Deploy one page at a time
- **Visual Regression Testing**: Screenshot comparisons
- **Rollback Plan**: Git tags at each stable point
### Testing Requirements:

- Manual testing of EVERY migrated component
- Cross-browser validation (Chrome, Firefox, Safari)
- Mobile responsive testing
- Dark mode compatibility
- Accessibility compliance (WCAG)
## 📈 Realistic Timeline

### Current Sprint 6 Capacity: 20 SP

### Actual Work Required: ~30-35 SP

**Recommendation**: Split into 2 sprints -**Sprint 6A**: Critical modals + high-risk components (15 SP) -**Sprint 6B**: Remaining components + cleanup (15 SP)
## 🎯 Success Criteria

### Sprint 6 Success =

- All modals working as overlays ✅
- No functionality regression ✅
- Both frameworks coexisting ✅
- Zero user-facing breaks ✅
### NOT Success Criteria:

- ❌ Complete Bootstrap removal (too risky)
- ❌ 100% migration (unrealistic in one sprint)
- ❌ Performance improvements (secondary goal)
## 💡 Key Insight

**The tickets are accurate but optimistic**. The scope is correct - these components DO need migration. However, the tickets assume: 1. Clean migration paths (reality: tangled dependencies) 2. No breaking changes (reality: everything breaks) 3. Simple class replacement (reality: structural changes needed)
## 🚀 Recommended Next Steps

- **Update all ticket descriptions**with breaking change warnings
- **Add rollback instructions**to each ticket
- **Create test checklist**for each component
- **Document current working state**before changes
- **Implement feature flags**for gradual rollout
## Final Assessment

**Can we complete Sprint 6?**YES, but... - Not all tickets in one sprint - Keep Bootstrap running during migration - Focus on fixing already-broken components first - Prepare for 2-sprint migration minimum

**Current functional system > Broken migrated system**

The good news: shadcn/ui IS properly installed and working. We just need systematic, careful migration without breaking everything at once.