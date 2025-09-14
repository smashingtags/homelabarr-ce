---
title: "HomelabARR-CLI : 2025-09-04 - SDLC Story Point Management Best Practices"
confluence_id: "14385164"
confluence_url: "https://your-instance.atlassian.net/wiki/spaces/DO/pages/14385164"
confluence_space: "DO"
category: "Project-Management"
created_date: "2025-09-04"
updated_date: "2025-09-04"
migrated_date: "2025-09-14"
tags: ['project-management', 'september-2025']
---

# SDLC Story Point Management Best Practices

## Core Principle

**Story points represent original effort estimation, NOT remaining work**
## During Active Sprint - DO NOT CHANGE STORY POINTS

### ✅ Correct Behavior

- Keep story points at**original estimates**throughout sprint
- Move tickets through workflow: To Do → In Progress → QA → Done
- Team gets**full velocity credit**for completed tickets at original estimates
- Story points serve as historical record of original planning
### ❌ Incorrect Behavior (What I Did Wrong)

- Reducing story points to 0 when ticket is Done
- Adjusting points during development when work is easier/harder than expected
- Changing estimates mid-sprint based on actual effort
## Between Sprints - Sprint Planning Re-estimation

### When Re-estimation Occurs

- **Only during sprint planning sessions**
- **Only for incomplete/carryover tickets**
- **Based on remaining work, not original effort**
### Example Workflow

- **Sprint 1**: 8-point ticket started but not finished
- **Sprint 1 End**: Team gets credit for attempting 8 points (shows in velocity)
- **Sprint 2 Planning**: Re-estimate remaining work (e.g., 1.5 points)
- **Sprint 2**: Plan 1.5 points for completion
## Velocity Tracking Benefits

### Accurate Metrics

- **Sprint Velocity**: Based on original estimates of completed work
- **Burndown Charts**: Show progress against original commitments
- **Capacity Planning**: Historical velocity helps predict future sprints
- **Estimation Improvement**: Compare original vs actual effort over time
### Business Value

- **Stakeholder Trust**: Consistent velocity reporting
- **Planning Accuracy**: Better sprint commitment predictions
- **Team Performance**: Fair measurement not skewed by mid-sprint adjustments
## Implementation in JIRA

### Story Point Field (customfield_10016)

- **During Sprint**: Never modify completed tickets
- **Sprint Planning**: Only adjust incomplete carryover tickets
- **Completed Tickets**: Always retain original estimate
### Sprint Reports

- **Velocity Chart**: Shows original estimates for completed work
- **Burndown**: Tracks against original sprint commitment
- **Sprint Health**: Measures actual vs planned completion
## Key Takeaways

- **Story Points = Original Estimate**(always)
- **Velocity Credit = Full Original Points**(for completed work)
- **Re-estimation = Sprint Planning Only**(for carryover work)
- **Mid-Sprint Changes = Workflow Status Only**(never story points)

This maintains the integrity of agile metrics and enables accurate sprint planning and team performance measurement.

*This page documents the correct SDLC story point workflow to prevent future estimation errors and maintain accurate agile metrics.*