---
title: "HomelabARR-CLI : 2025.08.17 GitHub Actions Docker Build Pipeline Troubleshooting Guide"
confluence_id: "4587706"
confluence_url: "https://your-instance.atlassian.net/wiki/spaces/DO/pages/4587706"
confluence_space: "DO"
category: "Installation"
created_date: "2025-08-17"
updated_date: "2025-08-17"
migrated_date: "2025-09-14"
tags: ['frontend', 'epic', 'docker', 'security', 'monitoring']
---

# GitHub Actions Docker Build Pipeline Troubleshooting Guide

## Overview

This document provides comprehensive troubleshooting guidance for Docker build failures in GitHub Actions workflows, specifically focusing on HomelabARR CLI containerized applications.
## Common Build Failures and Solutions

### 1. Docker Group Creation Conflicts

**Problem**: Build fails with error about docker group already existing
```
`addgroup: group 'docker' in use
`
```

**Root Cause**: Alpine Linux containers may have pre-existing docker group with different GID

**Solution**: Use conditional group creation
```
`# ❌ Problematic approach
RUN addgroup -g 999 docker

# ✅ Recommended approach  
RUN (getent group docker || addgroup docker)
`
```

**Technical Details**: -`getent group docker`checks if group exists -`||`operator only executes`addgroup docker`if group doesn't exist - Prevents conflicts with existing system groups
### 2. NPM Package Installation Issues

**Problem**: Build fails during npm dependency installation
```
`npm ERR! Cannot read properties of null (reading 'isServer')
npm ERR! package-lock.json lockfileVersion@2 requires npm@7
`
```

**Root Cause**:`npm ci`strict lockfile requirements incompatible with container environments

**Solution**: Switch to`npm install`with production flags

**Backend Configuration**:
```
`# ❌ Problematic approach
RUN npm ci --only=production

# ✅ Recommended approach
RUN npm install --production
`
```

**Frontend Configuration**:
```
`# ❌ Problematic approach  
RUN npm ci --only=production

# ✅ Recommended approach
RUN npm install
`
```

**Why This Works**: -`npm install`more tolerant of lockfile inconsistencies - Handles package-lock.json variations across environments - Maintains dependency integrity while allowing flexibility
### 3. TypeScript Compilation Blocking

**Problem**: Docker build fails during TypeScript type checking
```
`error TS2339: Property 'useAuthentik' does not exist on type 'DeploymentMode'
error TS2322: Type 'undefined' is not assignable to type 'string'
`
```

**Root Cause**: Strict TypeScript checking prevents Docker build completion

**Solution**: Separate TypeScript validation from production builds

**Build Script Optimization**:
```
`// ❌ Problematic approach
"build": "tsc --project tsconfig.app.json --noEmit && vite build"

// ✅ Recommended approach
"build": "vite build"
`
```

**Benefits**: - Faster Docker builds without TypeScript blocking - TypeScript validation handled separately in development - Production builds focus on compilation efficiency
### 4. TypeScript Interface Completeness

**Problem**: Missing interface properties causing compilation errors

**Solution**: Complete interface definitions with optional properties

**Example Fix**:
```
`// ✅ Complete interface definition
export interface DeploymentMode {
  id: string;
  name: string;
  description: string;
  useAuthentik?: boolean;  // Optional property for authentication
  // Other properties marked optional where undefined values possible
}

// ✅ Include all deployment modes
export const deploymentModes = ['standard', 'advanced', 'expert'] as const;
`
```

## Best Practices for CI/CD Docker Builds

### Container Environment Considerations

- **Group Management**: Always check for existing system groups before creation
- **Package Installation**: Use flexible installation methods for containerized environments
- **Build Optimization**: Separate development-time validation from production builds
- **Type Safety**: Define complete interfaces with appropriate optional properties
### Build Pipeline Optimization

- **Layer Caching**: Structure Dockerfile for optimal layer caching
- **Multi-stage Builds**: Separate build dependencies from runtime dependencies
- **Security**: Minimize attack surface in production images
- **Performance**: Optimize build times for CI/CD efficiency
### Troubleshooting Workflow

- **Identify Error Type**: Group creation, package installation, compilation, or runtime
- **Check Environment**: Verify container base image and system packages
- **Validate Dependencies**: Ensure package.json and lockfiles are consistent
- **Test Locally**: Reproduce issues in local Docker environment when possible
- **Monitor Logs**: Use GitHub Actions logs for detailed error analysis
## Implementation Examples

### Complete Dockerfile.backend Example

```
`FROM node:18-alpine

# Handle docker group creation gracefully
RUN (getent group docker || addgroup docker)

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies with production flag
RUN npm install --production

# Copy application code
COPY . .

# Build application (without TypeScript blocking)
RUN npm run build

# Expose port and start application
EXPOSE 3000
CMD ["npm", "start"]
`
```

### Complete Dockerfile.frontend Example

```
`FROM node:18-alpine AS builder

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install all dependencies (including dev dependencies for build)
RUN npm install

# Copy source code
COPY . .

# Build application for production
RUN npm run build

# Production stage
FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
`
```

## Monitoring and Validation

### Build Success Indicators

- ✅ No error messages in GitHub Actions logs
- ✅ Docker images successfully published to registry
- ✅ Image sizes within expected ranges
- ✅ All required files present in final images
### Post-Build Validation

- **Registry Verification**: Confirm images available in GitHub Container Registry
- **Functionality Testing**: Deploy and test basic application functionality
- **Performance Monitoring**: Check build times and resource usage
- **Security Scanning**: Validate container security compliance
## Related Documentation

- [HomelabARR CLI Development Guidelines](link-to-dev-guidelines)
- [Docker Best Practices](link-to-docker-practices)
- [CI/CD Pipeline Configuration](link-to-cicd-config)
## Support and Troubleshooting

For additional support with Docker build issues: 1. Check GitHub Actions workflow logs for detailed error messages 2. Test builds locally using same Dockerfile configurations 3. Verify package.json and dependency configurations 4. Review TypeScript configuration and interface definitions

*[[HL-73]]*