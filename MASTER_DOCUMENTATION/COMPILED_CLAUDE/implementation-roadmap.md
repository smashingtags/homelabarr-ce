# HomelabARR CLI Local Mode Implementation Roadmap

This document outlines the implementation phases for adding local-only installation options to HomelabARR CLI.

## Phase 1: Core Infrastructure (COMPLETED)

### ✅ Menu System Integration
- **File**: `apps/.installer/ubuntu-local.sh`
- **Features**:
  - Enhanced menu with mode selection options
  - Local mode configuration interface
  - Port management menu integration
  - Mode switching interface
  - Warning and information dialogs

### ✅ YAML Template Engine  
- **File**: `apps/.config/template-engine.sh`
- **Features**:
  - Conditional YAML generation based on mode
  - Traefik label stripping for local mode
  - Port mapping injection
  - Environment variable processing
  - Template validation system

### ✅ Port Management System
- **File**: `apps/.config/port-manager.sh` 
- **Features**:
  - Intelligent port allocation by service category
  - Conflict detection and resolution
  - Port registry management
  - Export capabilities (env, JSON, CSV)
  - Category-based port ranges

### ✅ Environment Schema Management
- **File**: `apps/.config/env-schema.sh`
- **Features**:
  - Mode-specific environment templates
  - Variable validation
  - Service-specific environment generation
  - Environment switching capabilities

### ✅ Mode Switching System
- **File**: `apps/.config/mode-switch.sh`
- **Features**:
  - Complete mode switching with backup/rollback
  - Service discovery and management
  - Prerequisites validation
  - Configuration backup system
  - Access information generation

## Phase 2: Service Configuration Templates (COMPLETED)

### ✅ Template Examples
- **Files**: 
  - `apps/.templates/mediaserver/plex.yml`
  - `apps/.templates/downloadclients/qbittorrent.yml`
- **Features**:
  - Conditional configuration sections
  - Mode-specific comments and documentation
  - Port mapping examples
  - Network configuration examples

### ✅ Configuration Examples
- **Files**:
  - `apps/.examples/local-mode-plex.yml`
  - `apps/.examples/proxy-mode-plex.yml`
  - `apps/.examples/local-mode-qbittorrent.yml`
  - `apps/.examples/comparison-guide.md`

## Phase 3: Integration with Existing System (TO DO)

### 🔄 Enhanced Installation Script
```bash
# Modify apps/.installer/ubuntu.sh to detect and use local mode
# Priority: High
# Estimated effort: 2-3 hours
```

**Changes needed**:
1. Import local mode functions from `ubuntu-local.sh`
2. Check for local mode configuration in `runinstall()` function
3. Use template engine instead of direct YAML copy
4. Add port assignment during service installation

### 🔄 Integration with `runinstall()` Function
```bash
# Current location: apps/.installer/ubuntu.sh lines 396-575
# Priority: High  
# Estimated effort: 3-4 hours
```

**Modifications needed**:
1. **Mode Detection** (line ~400):
```bash
# Add after line 400
if [[ -f "/opt/homelabarr-cli/.local_mode" ]]; then
    source "/opt/homelabarr-cli/.local_mode"
    LOCAL_MODE_ENABLED=${LOCAL_MODE_ENABLED:-false}
else
    LOCAL_MODE_ENABLED=false
fi
```

2. **Template Engine Usage** (line ~415):
```bash
# Replace line 415 YAML copy with:
if [[ "$LOCAL_MODE_ENABLED" == "true" ]]; then
    $SCRIPTS_DIR/template-engine.sh generate "$typed" "$appfolder/${section}/${typed}.yml" "$basefolder/$compose"
else
    $(command -v rsync) $appfolder/${section}/${typed}.yml $basefolder/$compose -aqhv
fi
```

3. **Port Assignment** (add after line 442):
```bash
# Add port assignment for local mode
if [[ "$LOCAL_MODE_ENABLED" == "true" ]]; then
    $SCRIPTS_DIR/port-manager.sh assign "$typed"
fi
```

### 🔄 Service Health Verification Enhancement
```bash
# Location: apps/.installer/ubuntu.sh lines 550-570
# Priority: Medium
# Estimated effort: 1-2 hours
```

**Add local mode URL generation**:
```bash
if [[ "$LOCAL_MODE_ENABLED" == "true" ]]; then
    SERVICE_PORT=$($SCRIPTS_DIR/port-manager.sh get "$typed")
    SERVER_IP=$(hostname -I | awk '{print $1}')
    printf "
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    ${typed} has successfully deployed => http://${SERVER_IP}:${SERVICE_PORT}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
"
fi
```

## Phase 4: Template Conversion (TO DO)

### 🔄 Convert Existing YAML Files
```bash
# Priority: Medium
# Estimated effort: 4-6 hours
```

**Automated conversion process**:
1. Run template conversion tool:
```bash
cd /opt/homelabarr-cli/apps/.config
./template-engine.sh convert-all
```

2. **Services to prioritize** (in order):
   - **Media Servers**: plex, jellyfin, emby
   - **Download Clients**: qbittorrent, sabnzbd, nzbget, deluge
   - **Media Management**: radarr, sonarr, lidarr, bazarr, prowlarr
   - **Request Apps**: overseerr, petio
   - **Popular Addons**: heimdall, tautulli, dozzle

3. **Template validation**:
```bash
# Validate each converted template
for template in apps/.templates/*/*.yml; do
    ./template-engine.sh validate "$template"
done
```

### 🔄 Service-Specific Port Mappings
```bash
# Priority: Medium
# Estimated effort: 2-3 hours
```

**Enhanced port mapping in template engine**:
1. **Plex**: Full port range (32400, 3005, 8324, 32469, 1900, 32410-32414)
2. **qBittorrent**: Web UI (8080) + torrent ports (6881 TCP/UDP)
3. **Deluge**: Web UI (8112) + daemon (58846) + torrent ports
4. **SABnzbd**: Single web port (8080)
5. **Media Management**: Single web ports (API access critical)

## Phase 5: Enhanced Features (TO DO)

### 🔄 Advanced Port Management
```bash
# Priority: Low
# Estimated effort: 3-4 hours
```

**Features to add**:
1. **Dynamic Port Range Assignment**:
   - Auto-expand ranges when conflicts occur
   - Service priority-based allocation
   - Custom port range configuration per category

2. **Port Usage Analytics**:
   - Historical port usage tracking
   - Conflict frequency analysis
   - Optimization recommendations

3. **Integration with Docker Networks**:
   - Custom bridge network creation
   - Network isolation options
   - Inter-service communication mapping

### 🔄 Enhanced Template Engine
```bash
# Priority: Low
# Estimated effort: 2-3 hours
```

**Advanced templating features**:
1. **Conditional Blocks**:
```yaml
# IF_LOCAL_MODE
ports:
  - "8080:8080"
# END_IF_LOCAL_MODE

# IF_PROXY_MODE  
labels:
  - "traefik.enable=true"
# END_IF_PROXY_MODE
```

2. **Variable Substitution**:
```yaml
environment:
  - "ADVERTISE_IP={{LOCAL_MODE ? 'http://' + LOCAL_SERVER_IP + ':' + SERVICE_PORT : 'http://' + SERVICE_NAME + '.' + DOMAIN + ':443'}}"
```

3. **Template Inheritance**:
   - Base templates for common configurations
   - Service-specific template overrides
   - Category-based template inheritance

### 🔄 Web Interface Integration
```bash
# Priority: Low
# Estimated effort: 6-8 hours
```

**If HomelabARR CLI has a web interface**:
1. Mode selection toggle
2. Port management interface
3. Service status dashboard with access links
4. Configuration backup/restore interface

## Phase 6: Testing and Documentation (TO DO)

### 🔄 Comprehensive Testing
```bash
# Priority: High
# Estimated effort: 4-6 hours
```

**Test scenarios**:
1. **Fresh Installation Tests**:
   - Local mode from scratch
   - Proxy mode from scratch
   - Mode switching after initial setup

2. **Migration Tests**:
   - Proxy → Local with running services
   - Local → Proxy with running services
   - Rollback functionality

3. **Service-Specific Tests**:
   - Mobile app connectivity (Plex, Jellyfin)
   - API access (Radarr, Sonarr integration)
   - Cross-service communication (Prowlarr → Radarr)

4. **Port Conflict Tests**:
   - System service conflicts
   - Docker container conflicts
   - Automatic resolution validation

### 🔄 User Documentation
```bash
# Priority: Medium
# Estimated effort: 3-4 hours
```

**Documentation to create**:
1. **User Guide**: Step-by-step local mode setup
2. **Migration Guide**: Converting existing installations
3. **Troubleshooting Guide**: Common issues and solutions
4. **API Documentation**: For advanced users and integrations

## Implementation Timeline

### Week 1: Core Integration
- [ ] Integrate with existing `ubuntu.sh` installer
- [ ] Test basic local mode installation flow
- [ ] Validate template engine with core services

### Week 2: Service Templates
- [ ] Convert priority services to templates
- [ ] Test service-specific configurations
- [ ] Validate port assignments and conflicts

### Week 3: Enhanced Features
- [ ] Implement advanced port management
- [ ] Add template engine enhancements
- [ ] Create comprehensive testing suite

### Week 4: Testing and Documentation
- [ ] Full system testing
- [ ] Create user documentation
- [ ] Performance testing and optimization

## File Structure Summary

```
/opt/homelabarr-cli/
├── .local_mode                    # Mode configuration
├── .port_registry                 # Port assignments
├── .port_config                   # Port management settings
├── .env-schema/                   # Environment variable schemas
├── .env.local                     # Local mode environment template
├── .env.proxy                     # Proxy mode environment template
├── .mode-switch-backups/          # Configuration backups
└── apps/
    ├── .installer/
    │   ├── ubuntu.sh              # Original installer (TO MODIFY)
    │   └── ubuntu-local.sh        # Enhanced installer with local mode
    ├── .config/
    │   ├── template-engine.sh     # YAML template processor
    │   ├── port-manager.sh        # Port management system
    │   ├── env-schema.sh          # Environment management
    │   └── mode-switch.sh         # Mode switching system
    ├── .templates/                # Service templates
    │   ├── mediaserver/
    │   ├── downloadclients/
    │   ├── mediamanager/
    │   └── ...
    └── .examples/                 # Configuration examples
        ├── local-mode-*.yml
        ├── proxy-mode-*.yml
        ├── comparison-guide.md
        └── implementation-roadmap.md
```

## Backward Compatibility

### Proxy Mode (Default)
- **No changes** to existing proxy mode functionality
- All existing installations continue to work unchanged
- Traefik and Authelia integration remains identical

### Migration Path
- Existing users can switch to local mode via menu option
- Automatic backup before any mode changes
- Rollback capability to previous configuration
- No data loss during mode switching

## Success Metrics

### Technical Metrics
- [ ] 100% of core services work in local mode
- [ ] Zero port conflicts after auto-resolution
- [ ] Mode switching completes in <5 minutes
- [ ] Template engine processes 100+ services without errors

### User Experience Metrics
- [ ] Clear menu navigation and options
- [ ] Comprehensive error messages and guidance
- [ ] Complete access information provided
- [ ] Rollback functionality works reliably

### Performance Metrics
- [ ] Local mode services start 30% faster than proxy mode
- [ ] Template generation completes in <10 seconds
- [ ] Port conflict detection runs in <5 seconds
- [ ] Mode switching preserves all application data

## Risk Mitigation

### Technical Risks
1. **Port Conflicts**: Comprehensive detection and auto-resolution
2. **Service Dependencies**: Careful dependency mapping and validation
3. **Data Loss**: Mandatory backups before any changes
4. **Network Issues**: Fallback network configurations

### User Experience Risks
1. **Confusion**: Clear documentation and guided workflows
2. **Failed Migrations**: Robust rollback mechanisms
3. **Access Issues**: Comprehensive access information generation
4. **Support Burden**: Self-diagnostic tools and troubleshooting guides

This roadmap provides a structured approach to implementing local mode functionality while maintaining the reliability and usability that HomelabARR CLI users expect.
