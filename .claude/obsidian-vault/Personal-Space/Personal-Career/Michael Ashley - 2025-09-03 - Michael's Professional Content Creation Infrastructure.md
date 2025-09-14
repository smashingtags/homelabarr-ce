---
title: "Michael Ashley : 2025-09-03 - Michael's Professional Content Creation Infrastructure"
confluence_id: "11731368"
confluence_url: "https://your-instance.atlassian.net/wiki/spaces/~7012146c1602dd7434196b33ad632a9816e2a/pages/11731368"
confluence_space: "Personal"
category: "Personal-Career"
migrated_date: "2025-09-14"
tags: ['personal', 'infrastructure', 'documentation', 'career', 'content-creation', 'ai', 'workflow', 'windows']
---

# Michael's Professional Content Creation Infrastructure

## Executive Summary

This document provides comprehensive documentation of Michael Ashley's professional content creation and development infrastructure - a sophisticated multi-platform environment optimized for software development, video editing, content creation, and homelab operations. The setup represents a best-in-class example of professional creator infrastructure and serves as the primary development/testing environment for HomelabARR CLI.
## 🏢**Complete Infrastructure Overview**

### **Core Computing Systems**

#### **Windows Development Workstation**

**Purpose**: Primary development environment for HomelabARR CLI -**CPU**: AMD Ryzen 9 3900X (12 cores, 24 threads, 3.8GHz base, 4.6GHz boost) -**GPU Primary**: NVIDIA RTX 2080 (professional graphics workloads) -**GPU Secondary**: Intel Arc A380 (dedicated AV1 hardware encoding) -**Memory**: 64GB RAM (optimal for Docker development, virtualization) -**OS**: Windows 11 (latest development environment) -**Networking**: 10GbE connectivity -**Cooling**: 360mm liquid cooling + 10-fan configuration
#### **Mac Studio M2 Ultra**(Content Creation Powerhouse)

**Purpose**: Primary video editing and content creation workstation -**CPU/GPU**: M2 Ultra (24-core CPU, 60/76-core GPU, 32-core Neural Engine) -**Memory**: Up to 192GB unified memory (800GB/s bandwidth) -**Storage**: Configurable up to 8TB SSD -**Video**: 22 streams of 8K ProRes playback capability -**Connectivity**: 6x Thunderbolt 4, 10GbE, multiple display outputs -**Professional Features**: Hardware-accelerated ProRes, 8K HDMI output
#### **MacBook Pro M1 Max**(Mobile Development/Editing)

**Purpose**: Mobile development and content creation -**CPU/GPU**: M1 Max (10-core CPU, 32-core GPU, 16-core Neural Engine)
-**Memory**: 32GB unified memory (400GB/s bandwidth) -**Storage**: 512GB SSD (external storage workflow) -**Professional Features**: ProRes accelerators, 16-core Neural Engine -**Connectivity**: Thunderbolt 4, optimized for professional workflows
### **Storage & NAS Systems**

#### **UGREEN DXP8800 Plus**(Primary NAS)

**Purpose**: Central storage hub, currently running Unraid -**CPU**: Intel i5-1235U (10 cores, 12 threads, up to 4.4GHz) -**Memory**: 8GB DDR5-4800 (expandable to 64GB) -**Storage**: 8x SATA bays + 2x M.2 NVMe (up to 256TB capacity) -**Networking**: Dual 10GbE (aggregate 20Gb, up to 2.5GB/s) -**Expansion**: 2x Thunderbolt 4, PCIe 4.0 x16 slot -**Video**: 8K HDMI output capability -**Current State**: Running Unraid (migration target for HomelabARR CLI + ZFS)
#### **Minisforum MS-01**(Homelab Server)

**Purpose**: Download automation, Docker workloads, network services -**CPU**: Intel i9-12900H (14 cores, 20 threads, up to 5.0GHz) -**Memory**: 96GB RAM (massive Docker capacity) -**Networking**: Dual 10GbE SFP+ + Dual 2.5GbE RJ45 -**Storage**: 3x M.2/U.2 NVMe slots (up to 24TB) -**Enterprise**: Intel vPro, AMT remote management -**Expansion**: PCIe 4.0 x16 slot for additional cards
### **Network Infrastructure**

#### **UniFi Dream Machine Pro**(Core Router/Gateway)

**Purpose**: Enterprise-grade network management and routing -**CPU**: Quad ARM Cortex-A57 @ 1.7GHz -**Memory**: 4GB DDR4 system memory -**Ports**: 8x 1GbE LAN + 1x 1GbE WAN + 2x 10GbE SFP+ -**Performance**: 3.5Gbps IDS/IPS routing -**Features**: Enterprise security, NVR storage capability -**Management**: Comprehensive UniFi network orchestration
#### **UniFi 8-Port 10GbE Aggregate Switch**

**Purpose**: High-speed backbone for professional workloads -**Ports**: 8x 10GbE SFP+ ports -**Layer**: Layer 2 switching with aggregation support -**Performance**: Full wire-speed 10Gb across all ports -**Integration**: Seamless UniFi ecosystem management
#### **Internet Connection**

- **Provider**: AT&T Fiber
- **Speed**: 1Gb symmetric (1000/1000 Mbps)
- **Reliability**: Enterprise-grade fiber infrastructure
## 🎯**Performance Analysis & Capabilities**

### **Development Environment Excellence**

**Windows Workstation Capabilities**: -**HomelabARR CLI Development**: Full Go development environment -**Container Orchestration**: 64GB RAM supports extensive Docker workloads -**AV1 Encoding**: Hardware-accelerated streaming/transcoding with Arc A380 -**10GbE Performance**: Direct high-speed access to storage systems
### **Content Creation Powerhouse**

**Mac Studio M2 Ultra Performance**: -**8K Video Editing**: Real-time timeline scrubbing of 8K ProRes footage -**Professional Workflows**: 22 simultaneous 8K ProRes streams -**Memory Bandwidth**: 800GB/s unified memory eliminates bottlenecks -**Storage Integration**: Direct 10GbE/Thunderbolt access to NAS systems
### **Network Performance Metrics**

**10GbE Infrastructure Capabilities**: -**Aggregate Bandwidth**: 20Gb+ total network capacity -**Mac Studio ↔ Storage**: Direct 10GbE for editing workflows -**Development ↔ Containers**: High-speed Docker image transfers -**Content Creation**: Simultaneous 4K/8K workflows without bottlenecks
## 🚀**HomelabARR CLI Optimization Opportunities**

### **Current Pain Points Identified**

#### **UGREEN DXP8800 Plus Limitations**

- **Unraid Write Speed**: Limited to ~200MB/s (parity drive bottleneck)
- **Professional Workflow Impact**: Timeline stuttering on complex 4K/8K edits
- **10GbE Underutilization**: Network achieving only ~400MB/s vs potential 1.25GB/s
- **No Snapshot Capabilities**: Missing point-in-time recovery for professional projects
#### **Multi-System Management Complexity**

- **Fragmented Interfaces**: Different management systems across platforms
- **No Unified Storage Strategy**: Inconsistent approaches between systems
- **Manual Optimization**: Lack of automated performance tuning
### **HomelabARR CLI Integration Strategy**

#### **Phase 1: ZFS Migration (Primary Impact)**

**UGREEN DXP8800 Plus Transformation**:
```
# Professional Video Editing Pool
zpool create video-edit raidz2 /dev/sda /dev/sdb /dev/sdc /dev/sdd /dev/sde /dev/sdf
zpool add video-edit cache /dev/nvme0n1    # L2ARC for Mac Studio
zpool add video-edit log /dev/nvme1n1      # SLOG for write optimization

# Expected Performance Improvements
- Write Speed: 200MB/s → 1.5GB/s+ (750% improvement)
- Read Speed: 200MB/s → 2.5GB/s+ (1250% improvement)  
- 10GbE Utilization: 400MB/s → 1.25GB/s+ (full bandwidth)
- Timeline Performance: Stuttering → smooth 8K playback
```