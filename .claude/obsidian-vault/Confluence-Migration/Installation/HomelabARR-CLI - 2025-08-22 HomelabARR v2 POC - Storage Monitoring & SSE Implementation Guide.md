---
title: "HomelabARR-CLI : 2025-08-22 HomelabARR v2 POC - Storage Monitoring & SSE Implementation Guide"
confluence_id: "9011229"
confluence_url: "https://your-instance.atlassian.net/wiki/spaces/DO/pages/9011229"
confluence_space: "DO"
category: "Installation"
created_date: "2025-08-22"
updated_date: "2025-08-22"
migrated_date: "2025-09-14"
tags: ['frontend', 'august-2025', 'golang', 'monitoring', 'storage']
---

# HomelabARR v2 POC - Storage Monitoring & SSE Implementation Guide

## Overview

This guide documents the implementation of real-time storage monitoring and Server-Sent Events (SSE) in the HomelabARR v2 POC, replacing mock data with live system integration and eliminating external Go dependencies.
## Storage Monitoring Implementation

### Windows Storage Detection

**Challenge**: Detect real Windows drives instead of using hardcoded mock data**Solution**: WMIC-based drive detection with type classification
#### Technical Implementation

```
func getWindowsStorageInfo() []StorageDevice {
// Execute WMIC command for drive information
cmd := exec.Command("wmic", "logicaldisk", "get", "Size,FreeSpace,DeviceID", "/format:csv")
output, err := cmd.Output()
if err != nil {
return mockStorageData() // Fallback to mock data
}
// Parse WMIC output and classify drive types
lines := strings.Split(string(output), "\n")
for _, line := range lines[1:] { // Skip header
fields := strings.Split(line, ",")
if len(fields) >= 4 {
device := parseStorageDevice(fields)
devices = append(devices, device)
}
}
return classifyDriveTypes(devices)
}
func classifyDriveTypes(devices []StorageDevice) []StorageDevice {
for i, device := range devices {
// NVMe detection
if strings.Contains(device.Name, "NVMe") {
devices[i].Type = "NVMe SSD"
devices[i].Icon = "nvme-icon"
}
// SSD detection
else if isSSD(device.DeviceID) {
devices[i].Type = "SSD"
devices[i].Icon = "ssd-icon"
}
// HDD fallback
else {
devices[i].Type = "HDD"
devices[i].Icon = "hdd-icon"
}
}
return devices
}
```