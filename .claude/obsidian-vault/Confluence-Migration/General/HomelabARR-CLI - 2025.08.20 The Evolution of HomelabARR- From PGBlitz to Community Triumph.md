---
title: "HomelabARR-CLI : 2025.08.20 The Evolution of HomelabARR: From PGBlitz to Community Triumph"
confluence_id: "6815871"
confluence_url: "https://mjashley.atlassian.net/wiki/spaces/DO/pages/6815871"
confluence_space: "DO"
category: "General"
created_date: ""
updated_date: ""
migrated_date: "2025-09-14"
tags: ['frontend', 'media-server', 'docker', 'traefik', 'golang', 'servarr', 'security', 'authelia', 'monitoring', 'storage']
---

# The Evolution of HomelabARR: From PGBlitz to Community Triumph

## The Complete Story: From PGBlitz to HomelabARR

### Act I: The PGBlitz Era (2017-2019)

PGBlitz emerged as an ambitious project to democratize media server deployment. Created by "Admin," it promised easy setup of Plex, Sonarr, Radarr, and cloud storage integration. The project gained massive popularity by: - Simplifying complex Docker deployments - Integrating Google Drive unlimited storage - Automating media server setup

However, as revealed in Discord logs from January 2021, the pattern was problematic from the start:
> 

"Build community by stealing other people code an renaming it PG. Build Devs to help support. Once that's working great, Admin leaves PG, community becomes insanely toxic, he come back 8 months later."
### Act II: The PlexGuide Transformation (2019-2020)

PGBlitz rebranded to PlexGuide (PG), expanding its scope but maintaining the same leadership issues. The project suffered from: - Admin's repeated disappearances (lasting 8+ months) - Donation-driven availability ("only has it running when people donate") - Multiple "rebirths" with data wipes - Toxic community management
### Act III: The DockServer Fork (2020-2021)

**Enter Ricardo (doob187/MrDoob)**- A skilled developer who initially tried to stabilize PlexGuide. As documented in the Discord logs: - Became frustrated with Admin's constant breaking updates - Did "heavy lifting" working 24/7 on fixes - Eventually earned "admin 2.0 rank" for destructive behavior

The breaking point came when doob187:
> 

"He literally put lines of code into nuke other peoples server Via auto update"

Additionally, he "destroyed the WIKI" and "challenged people to find all the hooks he had left in to auto-update."

DockServer launched as doob187's fork, featuring: - Docker-first architecture - UnionFS/mount-enhanced for cloud storage - Improved container management

**cyb3rgh05t's Contributions**: As a DockServer contributor, cyb3rgh05t created several auxiliary tools including plex-tautulli-dashboard and discord-plex-bot.
### Act IV: The Great Collapse (January 16, 2021)

**The PlexGuide Apocalypse**: On January 16, 2021, PlexGuide suddenly vanished: - Discord server deleted - Forum removed - Website gone - Only GitHub remained

Community member Ramsay noted: "was wondering what changed on my discord list this morning..."
### Act V: The MHA Reconstruction (January-February 2021)

**The Heroes Emerge**:

**Sammykins**- The British server owner who provided stability: - Took ownership of PTS repository to preserve it forever - Self-described with British humor as "a real cunt, the best cunt, 10/10 cunt" -**Pioneered WSL2 support**for Windows users - Philosophy: "I've got no reason to ever remove it because I can't code and I don't even use PTS anymore"

**Hawks**- Primary technical contributor who helped rebuild from ashes

**iDoMnCi**- Created crucial conversion scripts to migrate from PG to MHA

**halomore (Michael)**- Current HomelabARR maintainer, present during the drama but focused on moving forward

**The Month of Reconstruction**: As CDN RAGE asked: "What's the count on them dropping the discord now? 6? More?"

The community spent over a month piecing together: - 189 wiki documentation files - Docker configurations - Traefik settings (v1.x/v2.x era) - Installation scripts

Sammykins provided the philosophical foundation:
> 

"I think PTS is the only thing relating to Plexguide that has ever not just.. vanished and fucked off. And it never will because there's nothing to gain or lose from it vanishing"
### Act VI: The HomelabARR Renaissance (2024-2025)

**Michael's Journey**- From PM to Developer:
> 

"I am actually a Software Development Project Manager by trade, i have never coded but always wanted to learn"

Starting with "yml files for the projects," Michael evolved through: - bolt.new, bolt.diy - Claude Desktop, ChatGPT, Copilot - DeepSeek, Ollama, open source models - AWS Kiro - Finally settling on Claude: "I found you and liked you so much i pay $200 USD per month to talk to you"

**The Technical Evolution**: - Migrated from Traefik v1.x/v2.x to v3.5.0 - Replaced basic auth with Authelia SSO - Implemented Cloudflare DNS challenges - Added health checks to all containers - Created comprehensive monitoring stack
### Act VII: The Go Rewrite Vision (Future)

As Michael notes: "we plan to do a full rewrite anyway but needed an mvp bones and working structure... the plan is a complete rewrite to Go."
## Community Testimonies

**Piltover | Vander/DP**(January 2021):
> 

"Me and others revived what he tried to destroy, and we did just that. Moved On."

**DrgnFyre**(January 2021):
> 

"and we appreciate you giving it a home."

**Xployt**(SudoBox founder, January 2021):
> 

"I enjoyed PTS and loved the 'snippet tips'. Keep up the good work."
## Technical Heritage

From the 189 MHA-Team wiki files, we preserve: - Container configurations - Port mappings - Volume structures - Environment variables

But we modernize with: - Traefik v3.5.0 (breaking changes from v1.x/v2.x) - Authelia SSO integration - Prometheus/Grafana monitoring - OpenTelemetry tracing - Modern security practices
## Lessons from History

- **"Trust is earned slowly, lost quickly"**- Doob187's destructive exit poisoned future collaborations
- **"Single ownership is dangerous"**- Projects can vanish overnight
- **"Community ownership is key"**- Distributed control prevents abuse
- **"Documentation must be preserved"**- Wiki destruction hurt many users
- **"Forced auto-updates are hostile"**- Users must control their systems
## The Philosophy

HomelabARR embodies the lessons learned: -**No forced updates**- Users control when and how -**Complete transparency**- All code open source -**Community first**- No single point of failure -**Preserved knowledge**- Documentation from PTS/MHA maintained -**Stability over features**- Reliable deployment matters most
## Credits

### The Survivors

- **Sammykins**- Repository guardian, WSL2 pioneer, Discord host
- **Hawks**- Technical reconstruction lead
- **iDoMnCi**- Conversion script creator
- **Piltover | Vander/DP**- Community advocate
- **DrgnFyre**- Documentation supporter
### The Current Team

- **Michael (halomore)**- Project maintainer, evolved from PM to developer
- **Claude**- AI pair programmer ("$200 USD per month to talk to you")
- **The Community**- Continuous supporters and contributors
### The Cautionary Tales

- **Admin**- PlexGuide creator whose pattern of abandonment taught us about reliability
- **doob187/MrDoob**- Brilliant coder whose destructive exit taught us about trust
- **cyb3rgh05t**- DockServer contributor whose work we acknowledge but don't depend upon
## Technical Specifications

### Current Stack (2025)

- **Traefik**: v3.5.0 (major breaking changes from PTS era)
- **Authelia**: v4.38.17 (SSO replacing basic auth)
- **Docker Compose**: v2 specification
- **Cloudflare**: DNS challenges for SSL
- **Container Count**: 100+ supported applications
### Migration Path

- PGBlitz → PlexGuide → DockServer → MHA/PTS → HomelabARR
- Traefik v1.x → v2.x → v3.5.0
- Basic Auth → Authelia SSO
- HTTP Challenge → DNS Challenge
- Manual Updates → Controlled Updates
## The Future

HomelabARR continues to evolve with: - Planned Go rewrite for performance - Enhanced monitoring and observability - Expanded application support - Community-driven development - Preserved institutional knowledge

As Michael states: "We already had a nice document about the pgblitz mha admin mrdoob the whole backstory of this thing."

This is that story, preserved for future generations.

*"Just keep it alive forever and people can fork, pull or whatever on it forever"*- Sammykins

*Last Updated: January 2025*
*Version: The Complete History with Discord Evidence*
## Appendix: Primary Sources

- **MHA-Team PTS Wiki**: 189 documentation files preserved
- **Discord Logs**: January 2021 community discussions
- **GitHub Repositories**: MHA-Team/PTS-Team (12 repositories)
- **Community Testimonies**: Direct quotes from participants
- **Technical Documentation**: Traefik migration guides and container configurations