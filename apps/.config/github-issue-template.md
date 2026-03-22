# 🐛 Bug Report: HomelabARR CLI Local Mode Bulk Converted Apps Issues

## 📋 Summary
Critical issues discovered in the 171 bulk-converted applications for HomelabARR CLI Local Mode that prevent proper deployment.

## 🔍 Issues Identified

### 1. **Malformed YAML Port Definitions**
**Severity**: 🔴 Critical  
**Affected**: ~161/171 apps  
**Problem**: Port definitions are incorrectly formatted during bulk conversion
```yaml
# ❌ Current (broken):
ports:      - "32400:32400"

# ✅ Should be:
ports:
  - "32400:32400"
```

### 2. **Volume Driver Incompatibility** 
**Severity**: 🟡 Medium  
**Affected**: ~100+ apps with unionfs volumes  
**Problem**: Apps reference `native bind mount` plugin but use `driver: local`
```yaml
# Original design (requires native bind mount driver):
unionfs:
  driver: local
  driver_opts:
    mountpoint: /mnt

# Current fix (works but may lose functionality):
unionfs:
  driver: local
```

### 3. **Missing Environment Variables**
**Severity**: 🟡 Medium  
**Affected**: Apps like NextCloud, database-dependent services  
**Problem**: Missing required vars like `MARIADB_ROOT_PASSWORD`, `PORTBLOCK`

## 🧪 Reproduction Steps

1. Deploy any bulk-converted app:
   ```bash
   cd apps/local-mode-apps
   docker-compose -f plex.yml --env-file ../.config/.env up -d
   ```

2. **Expected**: App starts with port mapping  
   **Actual**: YAML parse error or no port access

## 💥 Impact

- **171 bulk-converted apps cannot deploy properly**
- **Only 8 curated templates work correctly** 
- **Port conflicts when multiple apps attempt same ports**
- **User frustration with "one-line deploy" promise**

## 🛠️ Proposed Solutions

### Phase 1: YAML Formatting Fix
- [x] Create automated YAML formatter script
- [ ] Fix all malformed port definitions
- [ ] Validate YAML syntax across all 171 files

### Phase 2: Port Conflict Resolution  
- [x] Create port conflict detector script
- [ ] Implement automatic port assignment (8200+ range)
- [ ] Generate port registry for documentation

### Phase 3: Volume Driver Strategy
- [ ] **Option A**: Install native bind mount driver properly
- [ ] **Option B**: Create volume mapping strategy for standard Docker
- [ ] **Option C**: Hybrid approach with fallback

## 🔧 Technical Details

**Environment:**
- OS: Windows 11 with WSL2
- Docker: Latest with Compose V2
- Repository: HomelabARR CLI Local Mode branch

**Files Affected:**
- `apps/local-mode-apps/*.yml` (171 files)
- `apps/.config/.env` (environment variables)
- Port assignments across all services

## 📊 Analysis Results

From quick port scan:
```
TOTAL APPS: 161 bulk converted
CONFLICTS: Multiple (TBD after YAML fix)
APPS WITH NO PORTS: ~90% (due to YAML formatting)
WORKING APPS: 8 curated templates only
```

## 🎯 Acceptance Criteria

- [ ] All 171 apps have valid YAML syntax
- [ ] All apps have unique, working port assignments  
- [ ] Volume strategy is consistent and documented
- [ ] Zero port conflicts in bulk deployment
- [ ] Documentation updated with port registry
- [ ] Migration path for existing deployments

## 🔗 Related Files

- `apps/.config/port-conflict-analyzer.sh`
- `apps/.config/volume-driver-fix.sh` 
- `apps/.config/quick-port-scan.sh`
- Backup directories with original files

---

**Priority**: High - Blocks advertised "179+ applications" functionality  
**Assignee**: Development team  
**Labels**: `bug`, `local-mode`, `yaml`, `ports`, `volumes`
