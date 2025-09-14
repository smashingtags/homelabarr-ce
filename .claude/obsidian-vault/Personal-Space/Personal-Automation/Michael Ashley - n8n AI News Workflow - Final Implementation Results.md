---
title: "Michael Ashley : n8n AI News Workflow - Final Implementation Results"
confluence_id: "295014"
confluence_url: "https://your-instance.atlassian.net/wiki/spaces/~7012146c1602dd7434196b33ad632a9816e2a/pages/295014"
confluence_space: "Personal"
category: "Personal-Automation"
migrated_date: "2025-09-14"
tags: ['personal', 'workflow', 'ai']
---

# n8n AI News Workflow - Final Implementation Results

## ✅ SOLUTION IMPLEMENTED

The issue has been**RESOLVED**! Here's what was implemented:
### Root Cause Analysis

The original error`articles is not iterable [line 5]`occurred because:
- 

**Two data sources**(NewsAPI + HackerNews) fed into one processing node
- 

**NewsAPI**returns`{articles: [...]}`format
- 

**HackerNews**returns`[123, 456, 789]`(array of story IDs)
- 

The processing code assumed all input had an`articles`property
### Final Solution: Unified Processing Node

Instead of the complex multi-node approach initially planned, I implemented a**single, intelligent processing node**that:
#### 🔍**Auto-Detects Data Source**

```
// Check if this is NewsAPI data (has articles array)
if (inputData && inputData.articles && Array.isArray(inputData.articles)) {
  console.log('Processing NewsAPI data');
  // Handle NewsAPI format...
}
// Check if this is HackerNews data (array of story IDs)  
else if (Array.isArray(inputData)) {
  console.log('Processing HackerNews data');
  // Handle HackerNews format...
}
```