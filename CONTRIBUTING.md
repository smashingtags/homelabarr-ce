# Contributing to HomelabARR CE

Thanks for your interest in making HomelabARR better! Here's how we work.

## How Features Get Built

1. **Ideas start in Discord** — Drop suggestions in [#feature-requests](https://discord.gg/Pc7mXX786x) or open a [GitHub Issue](https://github.com/smashingtags/homelabarr-ce/issues)
2. **We build on feature branches** — Each change gets its own `feature/` branch
3. **Features merge to `dev`** — The dev branch is our staging area, live at [ce-dev.homelabarr.com](https://ce-dev.homelabarr.com)
4. **Community votes** — We announce proposed changes in Discord. You tell us what's good, what sucks, and what's missing
5. **Approved features merge to `main`** — Only community-validated changes ship to production

## Branch Structure

| Branch | Purpose | Live at |
|--------|---------|---------|
| `main` | Production — stable, released | [ce-demo.homelabarr.com](https://ce-demo.homelabarr.com) |
| `dev` | Staging — proposed changes for community review | [ce-dev.homelabarr.com](https://ce-dev.homelabarr.com) |
| `feature/*` | Work in progress — individual changes | — |

## Want to Contribute Code?

1. Fork the repo
2. Create a feature branch from `dev`: `git checkout -b feature/your-feature dev`
3. Make your changes
4. Open a PR targeting `dev` (not `main`)
5. We'll review, test on ce-dev, and get community feedback

## Adding App Templates

Want to add a new app to the catalog? 

1. Create a YAML file in the appropriate `apps/<category>/` directory
2. Follow the format of existing templates
3. Include proper Docker image tags, Traefik labels, and environment defaults
4. Open a PR targeting `dev`

See `apps/legacy/README.md` for examples of what NOT to add (deprecated/abandoned projects).

## Reporting Bugs

- Open a [GitHub Issue](https://github.com/smashingtags/homelabarr-ce/issues)
- Or drop it in [#help](https://discord.gg/Pc7mXX786x) on Discord
- Include your Docker version, OS, and steps to reproduce

## Community

- **Discord**: [discord.gg/Pc7mXX786x](https://discord.gg/Pc7mXX786x)
- **Reddit**: [r/homelabarr](https://reddit.com/r/homelabarr)


Built with ♥ by [Imogen Labs AI](https://imogenlabs.ai)
