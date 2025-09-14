# Auto-Route Command

## Overview
Automatically routes tasks to specialized agents and validates code changes. The auto-router analyzes your task description and selects the most appropriate specialist agent(s) to handle the work, while automatically running validation pipelines.

## Usage
```bash
/auto-route [detailed task description]
```

### Example Commands
```bash
# Complex multi-domain task
/auto-route "Add Jellyfin media server with Traefik routing, Authelia protection, and monitoring dashboards"

# Infrastructure optimization
/auto-route "Optimize Docker resource usage for the entire media stack"

# Security enhancement
/auto-route "Implement 2FA for all admin interfaces and audit security policies"

# Troubleshooting
/auto-route "Debug why Sonarr can't connect to qBittorrent after recent updates"

# Story creation with automatic domain expert estimation
/auto-route create-story "Add Dozzle log viewer with centralized logging for all containers"

# Continue work on existing ticket (bypass In Progress validation)
/auto-route continue HL-123
```

## Agent Routing Logic

### Primary Routing Rules
| Task Keywords/Context | → | Specialist Agent |
|----------------------|---|------------------|
| Docker, container, compose, resource | → | `docker-infrastructure-specialist` |
| Traefik, routing, SSL, network, proxy | → | `network-architecture-specialist` |
| Authelia, security, auth, SSL, users | → | `security-authentication-specialist` |
| Plex, Jellyfin, Sonarr, Radarr, media | → | `media-stack-specialist` |
| Grafana, monitoring, alerts, metrics, dashboard | → | `monitoring-alerting-specialist` |
| Backup, restore, recovery, data protection | → | `backup-disaster-recovery-specialist` |
| Test, validate, check, verify | → | `test-automator` |
| Deploy, production, CI/CD, release | → | `deployment-engineer` |
| Debug, troubleshoot, error, diagnose | → | `debugger` |
| Document, wiki, confluence, API, guide | → | `documentation-specialist` |
| Sprint, story, backlog, user stories | → | `project-manager` |
| Team, coordination, process, blockers | → | `scrum-master` |
| Review, audit, quality, standards | → | `code-reviewer` |
| Research, evaluate, investigate | → | `technical-researcher` |

### Multi-Agent Coordination
For complex tasks, the router may engage multiple agents in sequence:
1. **Planning** (project-manager) → **Implementation** (domain specialist) → **Testing** (test-automator) → **Documentation** (documentation-specialist)

### Routing Examples
```bash
# Single agent routing
"Fix Plex transcoding issues" → media-stack-specialist

# Multi-agent routing  
"Add new media server with security" → 
  1. docker-infrastructure-specialist (container setup)
  2. network-architecture-specialist (Traefik routing)
  3. security-authentication-specialist (Authelia protection)
  4. test-automator (validation)
```

## Validation Pipeline
1. **File Detection**: Scan for changed files
2. **YAML Validation**: `docker-compose config --quiet`
3. **JSON Validation**: `python -c "import json; json.load(open('file.json'))"`
4. **Lint Check**: Language-specific linters
5. **Prettier Check**: Format validation for supported files

## Implementation Process

### Automatic Task Analysis
The auto-router performs intelligent analysis:

1. **Task Parsing**: Analyzes task description for keywords and context
2. **Agent Selection**: Selects primary and secondary agents based on task complexity
3. **Validation Pipeline**: Automatically runs relevant validation checks
4. **Execution**: Routes to specialist agent(s) with context and requirements
5. **Result Validation**: Verifies implementation meets requirements

### Smart Routing Features
- **Context Awareness**: Understands HomelabARR CLI project structure
- **Multi-Agent Coordination**: Can involve multiple specialists for complex tasks
- **Validation Integration**: Automatically runs appropriate validation tests
- **Error Handling**: Routes to debugger agent if issues are detected
- **Documentation**: Automatically updates relevant documentation

### Routing Decision Tree
```
Task Input
    |
    v
[Analyze Keywords & Context]
    |
    v
[Determine Complexity]
    |
    +-- Simple Task → Single Agent
    |
    +-- Complex Task → Multi-Agent Sequence
    |
    +-- Debug Task → Debugger + Domain Expert
    |
    v
[Execute with Validation]
```

## Enhanced Development Workflow Integration

### Complete Workflow Process
```
Local Notes → Code Changes → Confluence Docs → Jira Updates → GitHub Branch → Create Pull Request → Move Jira Ticket to QA → If No Breaking Changes Merge Pull Request if Breaking Mark For Manual Review → Pull Request Merged → Close Jira Ticket/Move to Done on Kanban board
```

### Enhanced Workflow Steps:
1. **Track locally** - Keep running notes of implementation in local files
2. **Story creation** - project-manager creates user story structure with acceptance criteria
3. **Technical estimation** - Domain specialist provides story point estimate with technical reasoning
4. **Sprint planning** - Story added to backlog with proper priority and estimation
5. **Code changes** - Implement and validate features with comprehensive testing
6. **Confluence docs** - Use local notes to write proper documentation
7. **GitHub branch** - Auto-create from Jira ticket with proper naming (feature/HL-{number}-{description})
8. **Create Pull Request** - Include Jira link, summary, test plan, breaking changes
9. **Move to QA** - Transition Jira ticket to QA status with PR link
10. **QA Decision Point**:
    - **No Breaking Changes** → Auto-merge eligible
    - **Breaking Changes** → Manual review required
11. **Pull Request Merged** - Branch cleanup and deployment triggers
12. **Close Jira Ticket** - Transition to Done with standardized completion comment

### Auto-Router QA Integration

#### Breaking Change Detection
The auto-router automatically scans for potential breaking changes:

- **Configuration Changes**: Docker Compose structure, environment variables
- **Network Changes**: Port mappings, Traefik routing, network configurations
- **Security Changes**: Authelia settings, SSL configurations, authentication flows
- **API Changes**: Service endpoints, data formats, external integrations
- **Storage Changes**: Volume mounts, data persistence configurations
- **Dependency Changes**: New services, version upgrades, external dependencies

#### Sprint Validation (Critical)
```bash
# Auto-router validates sprint assignment and story points before routing
echo "🔍 Validating sprint assignment and story points..."

# FIRST: Check for In Progress tickets (MANDATORY PRIORITY)
IN_PROGRESS_TICKETS=$(jira_get_in_progress_tickets)
if [[ -n "$IN_PROGRESS_TICKETS" ]]; then
    echo "⚠️ PRIORITY WARNING: Found tickets in 'In Progress' status"
    echo "📋 In Progress Tickets: $IN_PROGRESS_TICKETS"
    echo "🎯 MANDATORY: Complete 'In Progress' tasks before starting new work"
    echo "❌ Auto-router will not start new tasks while others are in progress"
    echo ""
    echo "💡 To continue with In Progress ticket, specify: /auto-route continue HL-XX"
    exit 1
fi

# Check if ticket is in active sprint
SPRINT_STATUS=$(jira_get_active_sprint_tickets)
if [[ ! $SPRINT_STATUS =~ $TICKET_ID ]]; then
    echo "❌ ERROR: Ticket not in active sprint - routing to backlog review"
    echo "⚠️ Current Sprint: Check active sprint assignments first"
    echo "📋 Available Sprint Tickets: [list active sprint items]"
    exit 1
fi

# Enhanced Story Point Validation with Domain Expert Estimation
STORY_POINTS=$(jira_get_story_points $TICKET_ID)
if [[ -z "$STORY_POINTS" || "$STORY_POINTS" == "null" ]]; then
    echo "⚠️ WARNING: No story points assigned to $TICKET_ID"
    echo "🎯 Routing to domain specialist for technical estimation..."
    
    # Analyze ticket content to determine domain
    TICKET_CONTENT=$(jira_get_issue_details $TICKET_ID)
    DOMAIN_AGENT=$(determine_estimation_agent "$TICKET_CONTENT")
    
    echo "📋 Technical Domain Identified: $DOMAIN_AGENT"
    echo "🔄 Requesting estimation from domain specialist..."
    
    # Route to domain specialist for estimation
    ESTIMATION_RESULT=$(route_to_agent_for_estimation $DOMAIN_AGENT $TICKET_ID "$TICKET_CONTENT")
    ESTIMATED_SP=$(extract_story_points "$ESTIMATION_RESULT")
    ESTIMATION_REASONING=$(extract_reasoning "$ESTIMATION_RESULT")
    
    echo "📊 Domain Expert Estimation: $ESTIMATED_SP SP (${ESTIMATED_SP}×8 = $((ESTIMATED_SP * 8)) hours)"
    echo "💡 Technical Reasoning: $ESTIMATION_REASONING"
    echo "🔄 Adding story points to ticket..."
    
    # Add estimation details to ticket
    jira_update_story_points $TICKET_ID $ESTIMATED_SP
    jira_add_comment $TICKET_ID "📊 **STORY POINT ESTIMATION**

**Estimated by**: $DOMAIN_AGENT (Domain Specialist)
**Story Points**: $ESTIMATED_SP SP (${ESTIMATED_SP}×8 = $((ESTIMATED_SP * 8)) hours)

**Technical Analysis**:
$ESTIMATION_REASONING

**Estimation Scale** (1 SP = 8 hours head-down coding):
- 1 SP: Simple config changes, minor documentation
- 2 SP: Container additions, basic integrations
- 3 SP: Complex configurations, service integrations  
- 5 SP: Multi-service features, architectural changes
- 8 SP: Major infrastructure changes, complex implementations

Ready for sprint work."
    
    echo "✅ Story points added: $ESTIMATED_SP SP (estimated by $DOMAIN_AGENT)"
else
    echo "✅ Story points validated: $STORY_POINTS SP ($((STORY_POINTS * 8)) hours estimated)"
fi

echo "✅ Sprint and story points validation passed - proceeding with agent routing"
```

#### Domain Expert Estimation Functions
```bash
# Determine which domain specialist should estimate the story
determine_estimation_agent() {
    local ticket_content="$1"
    
    # Analyze ticket content for technical domain keywords
    case "$ticket_content" in
        *docker*|*container*|*compose*|*resource*|*health*)
            echo "docker-infrastructure-specialist"
            ;;
        *traefik*|*routing*|*SSL*|*network*|*proxy*|*DNS*)
            echo "network-architecture-specialist"
            ;;
        *authelia*|*security*|*auth*|*SSL*|*users*|*MFA*)
            echo "security-authentication-specialist"
            ;;
        *plex*|*jellyfin*|*sonarr*|*radarr*|*media*|*servarr*)
            echo "media-stack-specialist"
            ;;
        *grafana*|*monitoring*|*alerts*|*metrics*|*prometheus*)
            echo "monitoring-alerting-specialist"
            ;;
        *backup*|*restore*|*recovery*|*data\ protection*)
            echo "backup-disaster-recovery-specialist"
            ;;
        *test*|*validate*|*check*|*verify*)
            echo "test-automator"
            ;;
        *deploy*|*production*|*CI/CD*|*release*)
            echo "deployment-engineer"
            ;;
        *debug*|*troubleshoot*|*error*|*diagnose*)
            echo "debugger"
            ;;
        *)
            # Default to docker specialist for infrastructure tasks
            echo "docker-infrastructure-specialist"
            ;;
    esac
}

# Route to domain specialist specifically for estimation
route_to_agent_for_estimation() {
    local agent_name="$1"
    local ticket_id="$2"
    local ticket_content="$3"
    
    echo "🎯 Routing estimation request to $agent_name..."
    
    # Create estimation prompt for domain specialist
    local estimation_prompt="ESTIMATION REQUEST for ticket $ticket_id:

Please provide a story point estimate for this ticket using our 1 SP = 8 hours scale:

**Ticket Content:**
$ticket_content

**Your Estimation Should Include:**
1. Story point estimate (1, 2, 3, 5, or 8)
2. Technical reasoning for the estimate
3. Key complexity factors identified
4. Dependencies or risks that affect effort

**Estimation Scale:**
- 1 SP (8 hours): Simple config changes, minor documentation
- 2 SP (16 hours): Container additions, basic integrations
- 3 SP (24 hours): Complex configurations, service integrations
- 5 SP (40 hours): Multi-service features, architectural changes
- 8 SP (64 hours): Major infrastructure changes, complex implementations

Please respond with: ESTIMATE: [number] SP - [reasoning]"

    # Route to the domain specialist for estimation
    $agent_name "$estimation_prompt"
}

# Extract story points from estimation response
extract_story_points() {
    local estimation_response="$1"
    echo "$estimation_response" | grep -o "ESTIMATE: [0-9]* SP" | grep -o "[0-9]*"
}

# Extract reasoning from estimation response
extract_reasoning() {
    local estimation_response="$1"
    echo "$estimation_response" | sed -n 's/.*ESTIMATE: [0-9]* SP - \(.*\)/\1/p'
}
```

#### Story Creation Enhancement
```bash
# Enhanced story creation workflow with automatic estimation
create_story_with_estimation() {
    local story_description="$1"
    
    echo "📝 Creating user story with domain expert estimation..."
    
    # Step 1: Create story structure with project-manager
    echo "🔄 Step 1: Creating story structure..."
    project-manager "Create user story for: $story_description"
    
    # Step 2: Get the created ticket ID
    NEW_TICKET_ID=$(get_latest_created_ticket)
    
    # Step 3: Route for technical estimation
    echo "🔄 Step 2: Routing for technical estimation..."
    TICKET_CONTENT=$(jira_get_issue_details $NEW_TICKET_ID)
    DOMAIN_AGENT=$(determine_estimation_agent "$TICKET_CONTENT")
    
    echo "📋 Domain identified: $DOMAIN_AGENT"
    ESTIMATION_RESULT=$(route_to_agent_for_estimation $DOMAIN_AGENT $NEW_TICKET_ID "$TICKET_CONTENT")
    
    # Step 4: Apply estimation to ticket
    ESTIMATED_SP=$(extract_story_points "$ESTIMATION_RESULT")
    ESTIMATION_REASONING=$(extract_reasoning "$ESTIMATION_RESULT")
    
    jira_update_story_points $NEW_TICKET_ID $ESTIMATED_SP
    jira_add_comment $NEW_TICKET_ID "📊 **TECHNICAL ESTIMATION COMPLETE**

**Domain Specialist**: $DOMAIN_AGENT
**Story Points**: $ESTIMATED_SP SP (${ESTIMATED_SP}×8 = $((ESTIMATED_SP * 8)) hours)

**Technical Analysis**:
$ESTIMATION_REASONING

Story is ready for sprint planning."

    echo "✅ Story created and estimated: $NEW_TICKET_ID ($ESTIMATED_SP SP)"
    return $NEW_TICKET_ID
}
```

#### QA Pathway Determination
```bash
# Auto-router determines QA pathway based on change analysis and QA results
echo "🔍 Analyzing changes and determining QA pathway..."

# Check for breaking changes
if [breaking_changes_detected]; then
    echo "⚠️ Manual review required - Breaking changes detected"
    # Route to manual review process
    # Add "breaking-change" label to PR
    # Assign senior developer for review
    QA_PATHWAY="manual_review"
else
    echo "✅ Auto-merge eligible - No breaking changes"
    # Route to automated merge process
    # Add "auto-merge-eligible" label to PR
    QA_PATHWAY="auto_merge"
fi

# QA Decision Point Handler
handle_qa_result() {
    local qa_status=$1
    local ticket_id=$2
    
    case $qa_status in
        "PASS")
            echo "✅ QA PASSED - Transitioning to QA Passed status"
            jira_transition_to_qa_passed $ticket_id
            add_qa_passed_comment $ticket_id
            echo "📋 Ready for Documentation Validation phase"
            ;;
        "FAIL")
            echo "❌ QA FAILED - Moving to Flopped status"
            jira_transition_to_flopped $ticket_id
            create_remediation_ticket $ticket_id
            ;;
        *)
            echo "⚠️ Unknown QA status: $qa_status"
            exit 1
            ;;
    esac
}

# QA Failure Handler
create_remediation_ticket() {
    local parent_ticket=$1
    local failure_reasons=$(get_qa_failure_reasons $parent_ticket)
    
    echo "🔄 Creating remediation Bug/Subtask for $parent_ticket"
    
    # Create bug/subtask with failure analysis
    REMEDIATION_TICKET=$(jira_create_bug \
        --parent "$parent_ticket" \
        --summary "QA Remediation: $parent_ticket" \
        --description "Remediation for QA failures in $parent_ticket\\n\\nFailure Reasons:\\n$failure_reasons" \
        --link-type "fixes")
    
    echo "📋 Created remediation ticket: $REMEDIATION_TICKET"
    echo "🔄 Remediation ticket will start fresh workflow from To Do"
    
    # Link tickets
    jira_link_issues $parent_ticket $REMEDIATION_TICKET "is fixed by"
    
    return $REMEDIATION_TICKET
}

# Documentation Validation Handler
validate_documentation_complete() {
    local ticket_id=$1
    
    echo "📋 Validating documentation completeness for $ticket_id"
    
    # Get ticket information
    local ticket_summary=$(jira_get_summary $ticket_id)
    local affected_components=$(jira_get_components $ticket_id)
    
    echo "🔍 Checking documentation requirements..."
    
    # Local documentation validation
    echo "📁 Local Documentation:"
    local local_docs_complete=false
    
    # Check if README updates are needed
    if requires_readme_update $ticket_id; then
        if validate_readme_updated $ticket_id; then
            echo "  ✅ README.md updated"
            local_docs_complete=true
        else
            echo "  ❌ README.md requires updates"
            local_docs_complete=false
        fi
    else
        echo "  ✅ README.md - no updates required"
        local_docs_complete=true
    fi
    
    # Check CLAUDE.md updates
    if requires_claude_md_update $ticket_id; then
        if validate_claude_md_updated $ticket_id; then
            echo "  ✅ CLAUDE.md updated"
        else
            echo "  ❌ CLAUDE.md requires updates"
            local_docs_complete=false
        fi
    else
        echo "  ✅ CLAUDE.md - no updates required"
    fi
    
    # Confluence documentation validation
    echo "🌐 Confluence Documentation:"
    local confluence_docs_complete=false
    
    # Check if ticket affects documented features
    if requires_confluence_update $ticket_id; then
        if validate_confluence_updated $ticket_id; then
            echo "  ✅ Confluence pages updated"
            confluence_docs_complete=true
        else
            echo "  ❌ Confluence documentation requires updates"
            confluence_docs_complete=false
        fi
    else
        echo "  ✅ Confluence - no updates required"
        confluence_docs_complete=true
    fi
    
    # Technical documentation validation
    echo "📖 Technical Documentation:"
    local tech_docs_complete=false
    
    if requires_technical_docs_update $ticket_id; then
        if validate_technical_docs_updated $ticket_id; then
            echo "  ✅ Technical documentation updated"
            tech_docs_complete=true
        else
            echo "  ❌ Technical documentation requires updates"
            tech_docs_complete=false
        fi
    else
        echo "  ✅ Technical docs - no updates required"
        tech_docs_complete=true
    fi
    
    # Cross-reference validation
    echo "🔗 Cross-Reference Validation:"
    if validate_documentation_links $ticket_id; then
        echo "  ✅ All documentation links validated"
    else
        echo "  ❌ Documentation links require fixes"
        return 1
    fi
    
    # Overall validation
    if [[ "$local_docs_complete" == true && "$confluence_docs_complete" == true && "$tech_docs_complete" == true ]]; then
        echo "✅ Documentation validation PASSED - All requirements met"
        
        # Add documentation validation comment to ticket
        jira_add_comment $ticket_id "📋 **DOCUMENTATION VALIDATION COMPLETE**
        
**Local Documentation:** ✅ All local files updated as required
**Confluence Documentation:** ✅ All relevant pages updated and linked
**Technical Documentation:** ✅ All guides and references current
**Cross-References:** ✅ All documentation links validated
**Review Status:** ✅ Documentation accuracy verified

Ready for final completion."
        
        return 0
    else
        echo "❌ Documentation validation FAILED - Missing required updates"
        
        # Add documentation failure comment
        jira_add_comment $ticket_id "❌ **DOCUMENTATION VALIDATION FAILED**
        
**Status:** Cannot complete ticket - documentation requirements not met

**Required Actions:**
- Local Docs: $([ "$local_docs_complete" == true ] && echo "✅ Complete" || echo "❌ Updates needed")
- Confluence: $([ "$confluence_docs_complete" == true ] && echo "✅ Complete" || echo "❌ Updates needed")  
- Technical Docs: $([ "$tech_docs_complete" == true ] && echo "✅ Complete" || echo "❌ Updates needed")

**Next Steps:** Complete missing documentation before transitioning to Done"
        
        return 1
    fi
}

# QA Passed Status Handler
add_qa_passed_comment() {
    local ticket_id=$1
    
    echo "📋 Adding QA Passed status comment to $ticket_id"
    
    jira_add_comment $ticket_id "✅ **QA VALIDATION COMPLETE**
    
**Implementation Status:**
- ✅ All acceptance criteria verified
- ✅ Automated checks passed
- ✅ Manual testing completed
- ✅ No breaking changes (or properly approved)
- ✅ Implementation confirmed working

**Next Phase:**
🔄 **Documentation Validation Required**
- [ ] Local documentation updates
- [ ] Confluence documentation updates  
- [ ] Technical documentation updates
- [ ] Cross-reference validation
- [ ] Documentation accuracy review

**Status:** Ready for Documentation Validation phase
**Priority:** High - QA approved implementation awaiting documentation completion"
}

# Documentation Validation Trigger
trigger_documentation_validation() {
    local ticket_id=$1
    
    echo "📋 Triggering documentation validation for $ticket_id"
    
    # Validate documentation completeness
    if validate_documentation_complete $ticket_id; then
        echo "✅ Documentation validation PASSED - Transitioning to Done"
        jira_transition_to_done $ticket_id
        add_completion_comment $ticket_id
    else
        echo "❌ Documentation validation FAILED - Remaining in QA Passed"
        jira_add_comment $ticket_id "❌ **DOCUMENTATION VALIDATION INCOMPLETE**
        
**Status:** Cannot transition to Done - Documentation requirements not met

**Action Required:** Complete missing documentation before final completion
**Current State:** Implementation validated, awaiting documentation completion"
    fi
}

# Handle QA Passed to Done transition
complete_qa_passed_ticket() {
    local ticket_id=$1
    
    echo "🔄 Processing QA Passed ticket completion for $ticket_id"
    
    # Trigger documentation validation
    trigger_documentation_validation $ticket_id
}
```

#### Validation Pipeline Enhancement
```bash
# Enhanced validation with QA integration
echo "🔍 Running comprehensive validation pipeline..."

# Standard validation
validate_yaml_files
validate_json_files  
validate_shell_scripts
run_prettier_checks
run_lint_checks

# Monitoring Dashboard Validation (NEW)
validate_monitoring_dashboards

# Breaking change analysis
detect_breaking_changes
assess_impact_scope
generate_qa_checklist

# QA pathway routing
if [no_breaking_changes]; then
    prepare_auto_merge
    create_standard_pr
else
    prepare_manual_review
    create_breaking_change_pr
    notify_senior_reviewers
fi
```

#### Flopped Workflow Automation
```bash
# Handle QA failures with automatic remediation ticket creation
handle_flopped_workflow() {
    local original_ticket=$1
    local qa_failure_reasons="$2"
    
    echo "❌ QA FAILED - Initiating Flopped workflow for $original_ticket"
    
    # Transition to Flopped status
    jira_transition_issue $original_ticket "Flopped"
    
    # Document QA failure
    jira_add_comment $original_ticket "❌ **QA FAILURE DOCUMENTED**
    
**Failure Analysis:**
$qa_failure_reasons

**Next Steps:**
- ✅ Ticket moved to Flopped status
- 🔄 Remediation Bug/Subtask will be created
- 📋 Remediation will start fresh workflow from To Do
- 🎯 Both tickets will be closed upon successful remediation"
    
    # Create remediation ticket
    create_remediation_ticket $original_ticket "$qa_failure_reasons"
    
    echo "✅ Flopped workflow initiated - remediation ticket created"
}

# Dual closure for successful remediation
handle_remediation_success() {
    local original_ticket=$1
    local remediation_ticket=$2
    
    echo "✅ Remediation successful - Closing both tickets"
    
    # Close remediation ticket with completion comment
    jira_transition_issue $remediation_ticket "Done"
    jira_add_comment $remediation_ticket "✅ **REMEDIATION COMPLETE**
    
**Resolution:**
- All QA failure issues resolved
- Original acceptance criteria met
- No regression introduced
- Ready for dual closure"
    
    # Close original ticket from Flopped
    jira_transition_issue $original_ticket "Done"
    jira_add_comment $original_ticket "✅ **ORIGINAL TICKET RESOLVED**
    
**Resolution Path:**
- QA failures remediated via $remediation_ticket
- All original acceptance criteria now met
- Implementation successfully completed
- Dual closure complete"
    
    echo "✅ Dual closure complete - Both tickets resolved"
}
```

### Branch Naming Convention Enforcement
```bash
# Auto-router enforces proper branch naming
BRANCH_PATTERN="^(feature|bugfix|hotfix)/HL-[0-9]+-[a-z0-9-]+$"

if [[ ! $BRANCH_NAME =~ $BRANCH_PATTERN ]]; then
    echo "❌ Invalid branch name. Use: feature/HL-{number}-{description}"
    exit 1
fi
```

### Completion Comment Template
The auto-router generates standardized completion comments:

```markdown
✅ **Implementation Complete**

**Story Management:**
- Original Estimate: {story_points} SP ({estimated_hours} hours)
- Estimated by: {domain_agent} (Domain Specialist)
- Actual Effort: {actual_hours} hours
- Estimation Accuracy: {percentage}%

**GitHub Integration:**
- Branch: {branch_name}
- PR: {pr_link}
- Commit: {commit_sha}

**QA Process:**
- Breaking Changes: {none/documented_and_approved}
- Validation: ✅ All checks passed
- Review Type: {auto_merge/manual_review}

**Agent Routing:**
- Estimation Agent: {domain_agent}
- Primary Agent: {agent_name}
- Secondary Agents: {additional_agents}
- Validation Pipeline: ✅ Complete

**Documentation:**
- Confluence: ✅ Updated
- Technical docs: ✅ Complete
- README updates: {if_applicable}

---
Auto-routed and completed via enhanced workflow with domain expert estimation
Story Point Accuracy: {estimation_feedback}
```

### Monitoring Dashboard Integration

#### Automatic Grafana Dashboard Generation
```bash
# Monitoring dashboard validation and auto-generation
validate_monitoring_dashboards() {
    echo "📊 Validating monitoring dashboards..."
    
    # Check if task involves container deployment or modification
    local changed_files=$(git diff --name-only)
    local container_changes=$(echo "$changed_files" | grep -E "\.(yml|yaml)$" | grep -v "template")
    
    if [[ -n "$container_changes" ]]; then
        echo "🔍 Container configuration changes detected"
        echo "📋 Analyzing: $container_changes"
        
        # Extract container names from Docker Compose files
        local containers_to_check=()
        for file in $container_changes; do
            if [[ -f "$file" ]]; then
                local services=$(grep -E "^  [a-z]" "$file" | grep -v "^  #" | awk '{print $1}' | sed 's/:$//')
                containers_to_check+=($services)
            fi
        done
        
        echo "🐳 Containers to validate: ${containers_to_check[@]}"
        
        # Check each container for existing Grafana dashboard
        for container in "${containers_to_check[@]}"; do
            check_and_create_dashboard "$container"
        done
        
        # Check if Grafana dashboard directory was modified
        local dashboard_changes=$(echo "$changed_files" | grep "apps/monitoring/dashboards/")
        if [[ -n "$dashboard_changes" ]]; then
            echo "📊 Dashboard files modified: $dashboard_changes"
            validate_dashboard_json_syntax "$dashboard_changes"
        fi
    else
        echo "✅ No container changes detected - dashboard validation skipped"
    fi
}

# Check for existing dashboard and create if missing
check_and_create_dashboard() {
    local container_name="$1"
    local dashboard_file="apps/monitoring/dashboards/${container_name}-dashboard.json"
    
    echo "🔍 Checking dashboard for container: $container_name"
    
    # Skip system containers and monitoring stack itself
    if [[ "$container_name" =~ ^(traefik|authelia|cf-companion|prometheus|grafana|loki|cadvisor|node-exporter|promtail|portainer|dozzle)$ ]]; then
        echo "  ⏭️  Skipping system container: $container_name"
        return 0
    fi
    
    # Check if dashboard already exists
    if [[ -f "$dashboard_file" ]]; then
        echo "  ✅ Dashboard exists: $dashboard_file"
        validate_dashboard_json_syntax "$dashboard_file"
        return 0
    fi
    
    echo "  📊 Dashboard missing for $container_name - generating automatically"
    
    # Route to monitoring-alerting-specialist for dashboard creation
    local dashboard_request="AUTO-DASHBOARD GENERATION REQUEST for container: $container_name

Please create a comprehensive Grafana dashboard for the $container_name container using the auto-dashboard-generator.py script or manual creation.

**Requirements:**
1. Container status monitoring (up/down)
2. Resource usage (CPU, Memory, Network I/O)
3. Application-specific metrics (if available)
4. Container logs panel
5. Health check status
6. Error/warning log filtering

**Target File:** $dashboard_file

**Integration:** Ensure dashboard integrates with existing Prometheus/Loki/Grafana stack

Please either:
1. Run the auto-dashboard generator: python3 apps/monitoring/scripts/auto-dashboard-generator.py
2. Create a custom dashboard specifically optimized for $container_name

Respond with dashboard creation status and any specific considerations for this container type."

    echo "🔄 Routing dashboard creation to monitoring-alerting-specialist..."
    
    # Route to monitoring specialist (would be actual agent call in implementation)
    echo "📋 Dashboard creation request sent for $container_name"
    echo "⏳ Dashboard generation in progress..."
    
    # In actual implementation, this would be:
    # monitoring-alerting-specialist "$dashboard_request"
    
    # Placeholder for dashboard creation validation
    echo "  🔄 Dashboard creation routed to monitoring-alerting-specialist"
    echo "  📊 Expected output: $dashboard_file"
    
    return 0
}

# Validate dashboard JSON syntax
validate_dashboard_json_syntax() {
    local dashboard_files="$1"
    
    echo "🔍 Validating dashboard JSON syntax..."
    
    for file in $dashboard_files; do
        if [[ -f "$file" && "$file" =~ \.json$ ]]; then
            echo "  📋 Validating: $file"
            
            # Check JSON syntax
            if python3 -c "import json; json.load(open('$file'))" 2>/dev/null; then
                echo "    ✅ Valid JSON syntax"
                
                # Validate Grafana dashboard structure
                if validate_grafana_dashboard_structure "$file"; then
                    echo "    ✅ Valid Grafana dashboard structure"
                else
                    echo "    ⚠️  Dashboard structure validation warnings (non-critical)"
                fi
            else
                echo "    ❌ Invalid JSON syntax in $file"
                echo "    🔧 Fix required before proceeding"
                return 1
            fi
        fi
    done
    
    echo "✅ Dashboard JSON validation complete"
    return 0
}

# Validate Grafana dashboard structure
validate_grafana_dashboard_structure() {
    local dashboard_file="$1"
    
    # Check for required Grafana dashboard fields
    local required_fields=("title" "panels" "uid" "version")
    local validation_passed=true
    
    for field in "${required_fields[@]}"; do
        if ! grep -q "\"$field\":" "$dashboard_file"; then
            echo "    ⚠️  Missing required field: $field"
            validation_passed=false
        fi
    done
    
    # Check for data sources
    if grep -q "\"datasource\":" "$dashboard_file"; then
        echo "    ✅ Data sources configured"
    else
        echo "    ⚠️  No data sources found"
        validation_passed=false
    fi
    
    # Check for panels
    local panel_count=$(grep -c "\"id\":" "$dashboard_file" 2>/dev/null || echo "0")
    if [[ $panel_count -gt 0 ]]; then
        echo "    ✅ Dashboard has $panel_count panels"
    else
        echo "    ⚠️  No panels found in dashboard"
        validation_passed=false
    fi
    
    return $([ "$validation_passed" = true ] && echo 0 || echo 1)
}

# Enhanced container detection for dashboard generation
detect_containers_needing_dashboards() {
    echo "🔍 Scanning for containers requiring dashboard creation..."
    
    # Find all Docker Compose files
    local compose_files=$(find apps/ -name "*.yml" -o -name "*.yaml" | grep -v template | grep -v ".local")
    
    echo "📋 Found Docker Compose files:"
    echo "$compose_files"
    
    local containers_found=()
    
    # Extract service names from all compose files
    for file in $compose_files; do
        if [[ -f "$file" ]]; then
            echo "  🔍 Scanning: $file"
            local services=$(grep -E "^  [a-z]" "$file" | grep -v "^  #" | awk '{print $1}' | sed 's/:$//')
            
            for service in $services; do
                # Skip system containers
                if [[ ! "$service" =~ ^(traefik|authelia|cf-companion|prometheus|grafana|loki|cadvisor|node-exporter|promtail|portainer|dozzle|networks|volumes)$ ]]; then
                    containers_found+=("$service")
                    echo "    📦 Found container: $service"
                fi
            done
        fi
    done
    
    # Remove duplicates and return unique container list
    local unique_containers=($(printf "%s\n" "${containers_found[@]}" | sort -u))
    
    echo "📊 Total containers requiring dashboard validation: ${#unique_containers[@]}"
    echo "🐳 Containers: ${unique_containers[@]}"
    
    # Check dashboard status for each container
    local missing_dashboards=()
    for container in "${unique_containers[@]}"; do
        local dashboard_file="apps/monitoring/dashboards/${container}-dashboard.json"
        if [[ ! -f "$dashboard_file" ]]; then
            missing_dashboards+=("$container")
        fi
    done
    
    if [[ ${#missing_dashboards[@]} -gt 0 ]]; then
        echo "❌ Missing dashboards for: ${missing_dashboards[@]}"
        echo "🔄 Automatic dashboard generation will be triggered"
        
        # Trigger dashboard generation for missing dashboards
        for container in "${missing_dashboards[@]}"; do
            check_and_create_dashboard "$container"
        done
    else
        echo "✅ All containers have dashboards"
    fi
}

# Integration with existing validation pipeline
trigger_monitoring_validation() {
    echo "📊 MONITORING VALIDATION PHASE"
    echo "=================================="
    
    # Step 1: Validate existing dashboards
    validate_monitoring_dashboards
    
    # Step 2: Comprehensive container scan
    detect_containers_needing_dashboards
    
    # Step 3: Validate monitoring stack health
    validate_monitoring_stack_health
    
    echo "✅ Monitoring validation complete"
}

# Monitoring stack health validation
validate_monitoring_stack_health() {
    echo "🏥 Validating monitoring stack health..."
    
    # Check if monitoring stack is deployed
    local monitoring_file="apps/monitoring/grafana-loki-prometheus.yml"
    if [[ -f "$monitoring_file" ]]; then
        echo "  ✅ Monitoring stack configuration found"
        
        # Validate monitoring stack configuration
        if docker-compose -f "$monitoring_file" config --quiet 2>/dev/null; then
            echo "  ✅ Monitoring stack configuration valid"
        else
            echo "  ❌ Monitoring stack configuration has errors"
            return 1
        fi
    else
        echo "  ⚠️  Monitoring stack not found - dashboards will be saved locally"
    fi
    
    # Check dashboard directory
    local dashboard_dir="apps/monitoring/dashboards"
    if [[ ! -d "$dashboard_dir" ]]; then
        echo "  📁 Creating dashboard directory: $dashboard_dir"
        mkdir -p "$dashboard_dir"
    fi
    
    echo "  ✅ Dashboard storage ready"
    return 0
}
```

#### Integration Points

The monitoring dashboard integration hooks into the auto-route workflow at several key points:

1. **Pre-Validation**: Before standard validation, check containers for dashboard requirements
2. **During Validation**: Validate dashboard JSON syntax and structure  
3. **Post-Implementation**: Generate missing dashboards for newly deployed containers
4. **QA Integration**: Include dashboard verification in QA checklist

#### Monitoring-Alerting-Specialist Enhancement

The enhanced `monitoring-alerting-specialist` agent now handles:
- **Automatic Dashboard Generation**: Creates dashboards using the auto-dashboard-generator.py script
- **Container Analysis**: Determines appropriate monitoring metrics based on container type
- **Dashboard Optimization**: Customizes panels for specific application requirements
- **Integration Validation**: Ensures dashboards work with existing Prometheus/Loki/Grafana stack

#### Usage Examples

```bash
# Automatic dashboard validation during normal workflow
/auto-route "Add Jellyfin media server with monitoring"
# → Deploys Jellyfin → Automatically creates Jellyfin dashboard

# Comprehensive monitoring scan
/auto-route "Audit all containers for monitoring dashboard coverage"
# → Scans all containers → Creates missing dashboards → Validates existing ones

# Dashboard-specific work
/auto-route "Create advanced monitoring dashboard for Plex with transcoding metrics"
# → Routes to monitoring-alerting-specialist → Creates custom Plex dashboard
```
