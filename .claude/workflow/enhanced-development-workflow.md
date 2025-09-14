# Enhanced HomelabARR CLI Development Workflow

## Overview
Comprehensive development workflow integrating local development, Confluence documentation, Jira project management, GitHub version control, and automated QA processes.

## Complete Workflow Steps

```
Local Notes → Code Changes (with Testing) → Confluence Docs → Jira Updates → GitHub Branch → Create Pull Request → Automated Validation → Move Jira Ticket to QA → {QA Pass: QA Passed} OR {QA Fail: Flopped → Create Bug/Subtask → Fresh Workflow → Both Closed} → Pull Request Merged → Post-Deployment Monitoring → Documentation Validation → Done
```

## Detailed Process

### 1. Local Notes
- **Purpose**: Track implementation details, decisions, and progress
- **Location**: Keep running notes in local files or IDE
- **Content**: Technical decisions, code changes, issues encountered, solutions implemented

### 2. Code Changes (Enhanced)
- **Implementation**: Write and test code locally
- **Testing During Development**:
  - [ ] Unit tests for new functionality (where applicable)
  - [ ] Integration tests for Docker services
  - [ ] Functional testing of modified features
- **Validation Pipeline**: Run comprehensive validation checks
  - [ ] YAML/JSON syntax validation
  - [ ] Shell script syntax checks
  - [ ] Docker Compose configuration validation
  - [ ] Security vulnerability scanning
- **Testing**: Verify functionality and integration
- **Documentation**: Update inline code documentation
- **Performance Check**: Monitor resource usage for new services

### 3. Confluence Documentation
- **Update**: Create or update relevant Confluence pages
- **Content**: Feature descriptions, configuration guides, troubleshooting
- **Cross-reference**: Link to related Jira tickets and GitHub repositories
- **Review**: Ensure documentation accuracy and completeness

### 4. Jira Updates
- **Sprint Validation**: **CRITICAL** - Verify ticket is in current active sprint before starting work
  - [ ] Check active sprint assignments
  - [ ] Confirm ticket is not in backlog
  - [ ] Validate sprint capacity before commitment
- **Task Prioritization**: **MANDATORY** - Always prioritize existing "In Progress" work before starting new tasks
  - [ ] **FIRST**: Check for any tickets currently in "In Progress" status
  - [ ] **PRIORITY**: Continue existing "In Progress" tickets before pulling from "To Do"
  - [ ] **RATIONALE**: Minimize work-in-progress and complete started tasks
  - [ ] Only start new "To Do" tasks when no "In Progress" items exist
- **Story Points Validation**: **REQUIRED** - Ensure proper estimation before work begins
  - [ ] Check if story points are assigned
  - [ ] If missing, estimate using complexity scale (1-8 SP = 8-64 hours)
  - [ ] Add story points to ticket before proceeding
  - [ ] Update sprint capacity tracking

### Story Points Estimation Guide
**Scale: 1 SP = 8 hours of head-down coding time**

- **1 SP (8 hours)**: Simple config changes, minor documentation updates
- **2 SP (16 hours)**: Small feature additions, basic script creation
- **3 SP (24 hours)**: Medium complexity features, systematic audits
- **5 SP (40 hours)**: Complex integrations, comprehensive implementations
- **8 SP (64 hours)**: Large features, major system changes
- **Story Creation**: Create detailed Jira stories with acceptance criteria
- **Epic Linking**: Associate with relevant epics
- **Component Assignment**: Tag appropriate components (infrastructure, security, media, etc.)

### 5. GitHub Branch Creation
- **Branch Naming**: `feature/HL-{number}-{short-description}`
- **Integration**: Auto-create from Jira ticket using GitHub-Jira integration
- **Commit Strategy**: Logical, well-documented commits
- **Push**: Push branch to remote repository

### 6. Create Pull Request
- **Title**: Clear, descriptive PR title
- **Description**: 
  - Link to Jira ticket
  - Summary of changes
  - Test plan
  - Breaking changes (if any)
  - Rollback plan (for significant changes)
- **Reviewers**: Assign appropriate reviewers
- **Labels**: Add relevant labels (feature, bugfix, breaking-change, etc.)

### 6.1. Automated Validation (New)
- **Triggered on PR Creation**: Automated checks run immediately
- **Validation Suite**:
  - [ ] Docker Compose syntax validation
  - [ ] YAML/JSON format validation
  - [ ] Shell script syntax checks
  - [ ] Security vulnerability scanning
  - [ ] Breaking change detection
  - [ ] Performance impact assessment
- **Status Check**: PR blocked until all validations pass
- **Notification**: Auto-comment with validation results

### 7. Move Jira Ticket to QA
- **Status Transition**: In Progress → QA
- **QA Comment**: Add comment with PR link and test instructions
- **Assignment**: Assign to QA reviewer or leave unassigned for team pickup
- **Validation Checklist**:
  - [ ] All acceptance criteria met
  - [ ] Documentation updated
  - [ ] No breaking changes (or marked for manual review)
  - [ ] Automated tests pass
  - [ ] Manual testing completed

### 8. QA Decision Point

#### 8a. QA Passes → QA Passed Status
- **Automated Checks**: All CI/CD checks pass
- **Compatibility**: No breaking changes detected (or properly approved)
- **Implementation Validation**: All acceptance criteria verified
- **Manual Testing**: Functionality confirmed working
- **Action**: Transition to "QA Passed" status
- **Next Phase**: Ready for Documentation Validation

#### 8b. QA Fails → Flopped Status
- **QA Failure Triggers**:
  - Acceptance criteria not met
  - Breaking changes not properly documented
  - Security vulnerabilities detected
  - Performance issues identified
  - Documentation incomplete or inaccurate
  - Integration failures discovered
- **Flopped Process**:
  - **Immediate**: Transition ticket to "Flopped" status
  - **Root Cause**: Document specific QA failure reasons
  - **Remediation**: Create Bug/Subtask for failure resolution
  - **Fresh Start**: Bug/Subtask enters workflow at "To Do" status
  - **Linkage**: Maintain parent-child relationship between original and remediation
- **Resolution Path**: Once Bug/Subtask passes QA → Close both original and remediation tickets

#### 8c. Breaking Changes → Manual Review Required
- **Breaking Change Detection**:
  - Configuration file format changes
  - API endpoint modifications
  - Docker Compose service changes
  - Network configuration updates
  - Security policy changes
- **Manual Review Process**:
  - Senior developer review required
  - Impact assessment
  - Migration plan documentation
  - Staged deployment planning
- **Approval**: Explicit approval required before proceeding

### 8d. Flopped Status Workflow (QA Failure Path)

When QA fails, tickets enter the **Flopped** status for systematic remediation:

#### Immediate Actions Upon QA Failure
1. **Status Transition**: QA → Flopped
2. **Failure Documentation**: Record specific QA failure reasons
3. **Impact Assessment**: Analyze scope of failure and required fixes
4. **Stakeholder Notification**: Alert team of QA failure and remediation plan

#### Remediation Ticket Creation
**Automatic Process**:
- **Bug/Subtask Creation**: System auto-creates linked Bug or Subtask
- **Naming Convention**: "QA Remediation: [Original Ticket Summary]"
- **Parent Linking**: Maintains parent-child relationship with original ticket
- **Failure Analysis**: Detailed description of QA failure reasons

**Required Information in Remediation Ticket**:
```markdown
## QA Failure Remediation for [Parent Ticket]

### Original Ticket Context
- **Parent**: [HL-XX] [Original Summary]
- **Implementation Date**: [Date]
- **QA Failure Date**: [Date]

### QA Failure Analysis
**Failed Criteria:**
- [ ] [Specific acceptance criterion that failed]
- [ ] [Another failed criterion]

**Root Causes:**
1. [Primary cause of failure]
2. [Secondary causes]

**Impact Assessment:**
- Scope: [Limited/Moderate/Extensive]
- Risk Level: [Low/Medium/High]
- Estimated Fix Time: [Story Points]

### Remediation Plan
**Required Changes:**
- [ ] [Specific fix needed]
- [ ] [Another required change]

**Testing Strategy:**
- [ ] [Specific tests to prevent regression]
- [ ] [Additional validation needed]

### Success Criteria
- [ ] All original acceptance criteria met
- [ ] QA failure issues resolved
- [ ] No regression introduced
- [ ] Documentation updated if needed
```

#### Fresh Workflow for Remediation
**Complete Restart**: Bug/Subtask enters workflow at **To Do** status
- **Sprint Assignment**: Prioritize in current or next sprint
- **Story Points**: Estimate effort for remediation work
- **Full Process**: Goes through entire workflow (Local Notes → Code Changes → Confluence → etc.)
- **Independent QA**: Must pass QA independently of original ticket

#### Dual Closure Process
**When Remediation Passes QA**:
1. **Remediation Ticket**: Transition to Done with completion comment
2. **Original Ticket**: Transition from Flopped to Done with resolution comment
3. **Epic Updates**: Update epic progress for both tickets
4. **Documentation**: Ensure all documentation reflects final state

#### Flopped Status Management
**Monitoring**: Track time in Flopped status for performance metrics
**Escalation**: Flopped tickets requiring > 2 sprints trigger escalation
**Learning**: Conduct retrospective on patterns causing QA failures

### 9. QA Passed Status
- **Status Meaning**: Implementation validated and working, awaiting documentation completion
- **Entry Criteria**: All QA validation passed, implementation confirmed functional
- **Visibility**: Clear indicator that technical work is complete
- **Context Preservation**: Maintains state during documentation phase or session interruptions
- **Priority**: High priority for documentation completion
- **Exit Criteria**: Documentation validation complete

#### Benefits of QA Passed Status
- **State Clarity**: Distinguishes between "needs QA" and "needs documentation"
- **Work Continuity**: Easy to resume after session cutoffs or compaction
- **Process Integrity**: Prevents incomplete tickets from reaching Done
- **Parallel Processing**: Others can identify QA-approved work ready for documentation
- **Quality Assurance**: Implementation is validated before documentation effort

### 10. Pull Request Merged
- **Merge Strategy**: Squash and merge (default) or merge commit for complex features
- **Branch Cleanup**: Automatically delete feature branch after merge
- **Deployment**: Trigger automated deployment pipeline (if configured)
- **Post-Deployment Monitoring**:
  - [ ] Verify services start successfully
  - [ ] Check health endpoints for new services
  - [ ] Monitor resource usage for 24 hours
  - [ ] Validate integration with existing services
- **Notification**: Automatic notifications to relevant stakeholders
- **Rollback Plan**: Document rollback procedure if issues arise

### 11. Documentation Validation (MANDATORY)
- **Trigger**: Automatically triggered when ticket reaches "QA Passed" status
- **Status Transition**: QA Passed → Documentation Validation (in progress)
- **Documentation Validation**: **MANDATORY** - Confirm all documentation is complete before final closure
  - [ ] **Local Documentation**: Verify updates to local README, CLAUDE.md, or relevant local files
  - [ ] **Confluence Documentation**: Confirm all related Confluence pages are updated
  - [ ] **Technical Documentation**: Ensure API docs, configuration guides, or troubleshooting docs are current
  - [ ] **Cross-References**: Validate all links between documentation sources work correctly
  - [ ] **Documentation Review**: Verify documentation accuracy reflects final implementation
- **Validation Process**: Systematic review of all documentation requirements
- **Quality Gate**: Cannot proceed to Done without complete documentation validation

### 12. Close Jira Ticket/Move to Done
- **Status Transition**: Documentation Validation Complete → Done
- **Prerequisites**: All documentation validation requirements met
- **Completion Comment**: Add standardized completion comment (see template below)
- **Epic Update**: Update epic progress if applicable
- **Labels**: Add "completed", "deployed", "documented" labels
- **Kanban Movement**: Automatically moves to Done column

## Completion Comment Template

```markdown
✅ **Implementation Complete**

**GitHub Integration:**
- Branch: feature/HL-{number}-{description}
- PR: [Link to merged pull request]
- Commit: [Final commit SHA]

**Deployment Status:**
- Environment: [Production/Staging/Local]
- Validation: ✅ All acceptance criteria verified
- Performance: [Performance impact notes]

**Documentation Validation:**
- Local Documentation: ✅ [README/CLAUDE.md/Local files updated]
- Confluence: ✅ [Relevant pages updated and linked]
- Technical Documentation: ✅ [API docs/guides/troubleshooting current]
- Cross-References: ✅ [All documentation links validated]
- Documentation Review: ✅ [Accuracy verified against final implementation]

**QA Process:**
- QA Status: [Auto-merged/Manual review completed]
- Breaking Changes: [None/Documented and approved]
- Test Results: ✅ All tests pass

**Acceptance Criteria Verification:**
[List each AC with ✅ confirmation]

**Notes:**
[Any additional implementation notes, known issues, or future considerations]

---
Completed on: {date}
Total Development Time: {story points} SP
QA Process: [Automated/Manual Review]
```

## Branch Naming Conventions

### Standard Format
```
feature/HL-{number}-{short-description}
bugfix/HL-{number}-{short-description}
hotfix/HL-{number}-{short-description}
```

### Examples
```
feature/HL-50-dozzle-monitoring-dashboard-automation
bugfix/HL-23-traefik-ssl-certificate-renewal
hotfix/HL-45-plex-memory-leak-fix
```

## QA Criteria

### Automated Checks
- [ ] Docker Compose validation passes
- [ ] YAML/JSON syntax validation passes
- [ ] Shell script syntax validation passes
- [ ] No security vulnerabilities detected
- [ ] Performance impact within acceptable limits

### Manual Review Triggers
- [ ] Breaking changes detected
- [ ] Security-related modifications
- [ ] Infrastructure changes affecting multiple services
- [ ] New external dependencies
- [ ] Database schema changes

### Breaking Change Categories
1. **Configuration Changes**: Docker Compose structure, environment variables
2. **Network Changes**: Port mappings, network configurations
3. **Security Changes**: Authentication, authorization, SSL configurations
4. **API Changes**: Service endpoints, data formats
5. **Storage Changes**: Volume mounts, data persistence
6. **Dependency Changes**: New required services, version upgrades

## Automation Opportunities

### GitHub Actions Integration
```yaml
name: HomelabARR QA Pipeline
on:
  pull_request:
    branches: [main, master]

jobs:
  qa-checks:
    runs-on: ubuntu-latest
    steps:
      - name: Validate Docker Compose
      - name: Check for breaking changes
      - name: Update Jira ticket status
      - name: Auto-merge if eligible
```

### Jira Automation Rules
1. **PR Created** → Move ticket to QA
2. **PR Merged** → Move ticket to Done + Add completion comment
3. **Breaking Changes Detected** → Add "manual-review-required" label
4. **All Checks Pass** → Add "auto-merge-eligible" label

## Tools Integration

### Required Tools
- **Jira**: Project management and issue tracking
- **Confluence**: Documentation and knowledge management
- **GitHub**: Version control and pull request management
- **Docker**: Containerization and validation
- **Claude Code**: AI-assisted development and automation

### Optional Enhancements
- **GitHub Actions**: Automated testing and deployment
- **Slack/Discord**: Notifications and team communication
- **Monitoring**: Grafana/Prometheus for deployment validation
- **Security Scanning**: Automated vulnerability detection

## Rollback Procedures (New)

### When to Rollback
- **Service Failures**: Any service fails to start after deployment
- **Performance Degradation**: Resource usage exceeds acceptable limits
- **Integration Issues**: Existing services affected negatively
- **Security Concerns**: New vulnerabilities introduced

### Rollback Process
1. **Immediate Actions**:
   - [ ] Stop affected services: `docker-compose down`
   - [ ] Revert to previous working commit: `git revert {commit-sha}`
   - [ ] Restart services: `docker-compose up -d`
   - [ ] Verify system stability

2. **Post-Rollback**:
   - [ ] Update Jira ticket with rollback reason
   - [ ] Document issue in Confluence
   - [ ] Create new ticket for fix investigation
   - [ ] Notify stakeholders of rollback

### Rollback Prevention
- **Pre-deployment Testing**: Comprehensive validation in staging
- **Gradual Deployment**: Deploy to subset of services first
- **Health Monitoring**: Continuous monitoring for 24 hours post-deployment
- **Automated Rollback**: Trigger rollback on critical failures

## Workflow Validation

### Success Metrics
- Time from code complete to production deployment
- Number of breaking changes caught in QA
- Documentation completeness rate
- Automated vs manual review ratio
- Rollback frequency and time-to-recovery

### Quality Gates
1. All automated tests pass
2. Documentation updated and reviewed
3. No breaking changes (or properly documented and approved)
4. Performance impact assessed and acceptable
5. Security implications reviewed and mitigated
6. Rollback plan documented for significant changes

---

*This workflow ensures comprehensive quality control while maintaining development velocity through intelligent automation and clear decision points.*
