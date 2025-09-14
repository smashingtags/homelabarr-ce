# Claude Sessions - SDLC Integration

## Purpose
Organized storage for Claude Code session continuation files, enabling seamless development workflow transitions and zero context loss.

## Structure
```
.claude-sessions/
├── README.md                    # This file
├── YYYY-MM-DD/                  # Daily session folders
│   ├── SESSION_CONTINUATION_*.md    # Handoff documents
│   ├── DECISIONS_MADE_*.md          # Key architectural decisions
│   └── TECHNICAL_CONTEXT_*.md       # Technical state snapshots
└── templates/                   # Template files for consistency
    └── session_template.md
```

## Usage

### For Session Handoffs
1. When approaching context limits (~15-20% remaining)
2. Generate continuation file in appropriate date folder
3. Drag file into new Claude Code session
4. Say: "This is where we were - ready to continue!"

### File Naming Convention
- `SESSION_CONTINUATION_YYYY-MM-DD_HHMMSS.md` - Complete handoff packages
- `DECISIONS_YYYY-MM-DD_TOPIC.md` - Key architectural decisions  
- `CONTEXT_YYYY-MM-DD_FEATURE.md` - Technical context snapshots

## Benefits
- ✅ Zero context loss during development
- ✅ Complete audit trail of decisions
- ✅ Seamless team collaboration
- ✅ Historical context preservation
- ✅ Integrated with HomelabARR SDLC

## Integration with TodoWrite Tool
Session files should capture current TodoWrite status and transfer to new sessions for continuity.

## Quality Gates
- [ ] All session files include technical context
- [ ] Key decisions are documented with evidence
- [ ] Next priorities clearly defined
- [ ] Blockers and dependencies identified
- [ ] MCP tool status preserved