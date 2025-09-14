---
title: "Michael Ashley : Windows MCP Tool - Comprehensive Documentation"
confluence_id: "294942"
confluence_url: "https://your-instance.atlassian.net/wiki/spaces/~7012146c1602dd7434196b33ad632a9816e2a/pages/294942"
confluence_space: "Personal"
category: "Personal-Tools"
migrated_date: "2025-09-14"
tags: ['personal', 'documentation', 'mcp', 'ai', 'windows']
---

# Windows MCP Tool - Comprehensive Documentation

## Overview

The Windows MCP (Model Context Protocol) Tool is a powerful automation framework that enables programmatic interaction with Windows desktop applications, system components, and UI elements. It provides a comprehensive set of tools for desktop automation, testing, and productivity enhancement.
## Table of Contents

- 

[Getting Started](#getting-started)
- 

[Core Tools Reference](#core-tools-reference)
- 

[Common Use Cases](#common-use-cases)
- 

[Best Practices](#best-practices)
- 

[Troubleshooting](#troubleshooting)
- 

[Examples & Recipes](#examples--recipes)
## Getting Started

### Prerequisites

- 

Windows 10/11 operating system
- 

MCP-compatible client (Claude Desktop, etc.)
- 

Administrator privileges may be required for certain operations
### Installation

The Windows MCP Tool is typically installed as part of an MCP client package. Ensure your MCP client has the Windows MCP server configured and running.
### Basic Concepts

**Coordinates System**: All UI interactions use screen coordinates (x, y) where (0,0) is the top-left corner of the primary display.

**Element Detection**: The State Tool provides lists of interactive, informative, and scrollable elements with their coordinates and properties.

**Application Context**: Tools can interact with any visible application window or system component.
## Core Tools Reference

### 1. State Tool

**Function**:`Windows-MCP:State-Tool`

Captures comprehensive desktop state including focused applications, opened applications, and interactive UI elements.

**Parameters**:
- 

`use_vision`(boolean, default: false): Include visual screenshot when true

**Returns**:
- 

Focused application information
- 

List of opened applications with status and dimensions
- 

Interactive elements (buttons, text fields, menus)
- 

Informative content (labels, text, status indicators)
- 

Scrollable areas

**Example Usage**:
```
# Get current desktop state
state = windows_mcp.state_tool(use_vision=False)
```