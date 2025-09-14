---
title: "HomelabARR-CLI : 2025-08-24 - Fix for index.html FileServer Directory Listing Issue"
confluence_id: "8946114"
confluence_url: "https://mjashley.atlassian.net/wiki/spaces/DO/pages/8946114"
confluence_space: "DO"
category: "Troubleshooting"
created_date: "2025-08-24"
updated_date: "2024-08-24"
migrated_date: "2025-09-14"
tags: ['frontend', 'august-2025', 'golang']
---

# Problem Statement

When renaming`dashboard-unified.html`to`index.html`to follow web standards, the Go http.FileServer was showing a directory listing instead of serving the index.html file at the root path.
## Root Cause Analysis

The custom file serving implementation was interfering with Go's built-in FileServer behavior. Our code was trying to manually handle the root path, which prevented FileServer from using its automatic index.html serving logic.
## Solution

### Before (Incorrect Implementation)

```
// This custom handling broke FileServer's index.html logic
http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
    if r.URL.Path == "/" {
        http.ServeFile(w, r, "./web/index.html")
        return
    }
    http.FileServer(http.Dir("./web/")).ServeHTTP(w, r)
})
```