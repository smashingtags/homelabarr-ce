# HomelabARR CLI Local-Persist Container Submission

## Overview

This document outlines the submission of the official HomelabARR CLI Local-Persist container to the HomelabARR CLI container repository.

## Container Details

### **docker-local-persist**
- **Purpose**: Docker volume plugin for local volumes with custom mountpoints
- **Base**: LinuxServer.io Alpine with s6-overlay v3.2.1.0  
- **Size**: ~56MB
- **Architecture**: Multi-platform (linux/amd64, linux/arm64)

### **Key Features**
- ✅ **HomelabARR CLI Branding**: Official headers, licensing, and donate screens
- ✅ **Enhanced Reliability**: S6-overlay process management 
- ✅ **Health Checks**: Monitoring integration for HomelabARR CLI ecosystem
- ✅ **Environment Variables**: PUID, PGID, TZ support
- ✅ **Security Optimized**: Proper user mapping and permissions

## Files to Submit

### **Container Structure**
```
container/apps/docker-local-persist/
├── Dockerfile                    # Multi-stage build with Alpine base
├── release.json                  # HomelabARR CLI metadata and versioning  
├── package.txt                   # Package inventory
└── root/
    ├── donate.txt               # HomelabARR CLI branding
    └── etc/s6-overlay/s6-rc.d/  # Service management
        └── svc-local-persist/   # Local-persist service definition
```

### **Registry Entry**
- Update `container.json` with docker-local-persist entry
- Add container image: `./images/docker-local-persist.png`

## Integration Points

### **HomelabARR CLI Core Integration**
The container replaces the current `cwspear/docker-local-persist-volume-plugin` usage in:

1. **Preinstall Scripts** (`preinstall/installer/ubuntu.sh`)
2. **System Compose** (`system/local-persist.yml`) 
3. **Management Scripts** (`scripts/manage-local-persist.sh`)
4. **Documentation** (`preinstall/README.md`)

### **Expected Registry Path**
```
ghcr.io/smashingtags/homelabarr-cli/docker-local-persist:latest
```

## Benefits to HomelabARR CLI Ecosystem

### **Standardization**
- ✅ **Consistent branding** across all HomelabARR CLI components
- ✅ **Unified monitoring** through health checks
- ✅ **Standard environment** variables (PUID, PGID, TZ)

### **Reliability Improvements**
- ✅ **S6-overlay management** vs simple binary execution
- ✅ **Proper restart handling** and graceful shutdowns
- ✅ **Enhanced logging** and error reporting

### **Community Benefits**
- ✅ **Official support** from HomelabARR CLI team
- ✅ **Automated updates** through GHCR pipeline
- ✅ **Documentation integration** in official docs

## Testing Results

### **Build Status**
- ✅ **Successful build**: 56.2MB final image
- ✅ **Multi-stage optimization**: Alpine builder + LinuxServer runtime
- ✅ **Health check validation**: Socket creation verified

### **Integration Testing**
- ✅ **Preinstall compatibility**: Drop-in replacement
- ✅ **Volume creation**: `docker volume create -d local-persist` working
- ✅ **HomelabARR CLI environment**: Full compatibility maintained

## Submission Checklist

### **Container Repository**
- [ ] Fork `https://github.com/smashingtags/homelabarr-cli/container`
- [ ] Add `apps/docker-local-persist/` directory structure
- [ ] Update `container.json` registry
- [ ] Add container image to `images/`
- [ ] Submit pull request with detailed description

### **Documentation**
- [ ] Container usage documentation
- [ ] Migration notes from cwspear image
- [ ] Health check and monitoring setup
- [ ] Environment variable reference

### **Testing**
- [ ] Multi-platform build verification
- [ ] Integration testing with existing HomelabARR CLI stack
- [ ] Performance comparison with previous solution
- [ ] Rollback procedures documented

## Post-Submission

### **GHCR Publication**
Once merged, the container will be available at:
```
ghcr.io/smashingtags/homelabarr-cli/docker-local-persist:latest
```

### **HomelabARR CLI Core Updates**
All HomelabARR CLI installations will automatically use the official container through:
- Preinstall scripts
- System compose files  
- Management utilities
- User documentation

## Contact

- **Implementation**: Enhanced local-persist containerization
- **Testing**: Comprehensive integration validation
- **Documentation**: Complete usage and migration guides
- **Benefits**: Official HomelabARR CLI ecosystem integration

---

*This container represents a significant improvement in HomelabARR CLI's local-persist plugin reliability and standardization.*
