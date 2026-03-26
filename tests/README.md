# E2E Test Suite — READ ONLY FOR AGENTS

⚠️ **This directory is maintained exclusively by the orchestrator (Imogen) and Michael.**

## Rules

1. **Agents (Prospero, Puck, Portia, Rosalind, Viola, Ariel) must NEVER modify files in this directory.**
2. If your code breaks a test, **fix your code** — do not modify the test.
3. If you believe a test is wrong, create a task requesting a test update. Do not edit it yourself.
4. Modifying any file in `tests/` is an automatic task failure.

## Running Tests

```bash
# Against dev
TEST_BASE_URL=https://ce-dev.homelabarr.com npx playwright test

# Against staging
TEST_BASE_URL=https://ce-staging.homelabarr.com npx playwright test

# Against local
TEST_BASE_URL=http://localhost:8080 npx playwright test

# With UI
npx playwright test --ui

# Specific test file
npx playwright test tests/e2e/catalog.spec.ts

# Update visual baselines (orchestrator only)
npx playwright test --update-snapshots
```

## Test Coverage

| File | What it tests |
|------|---------------|
| `catalog.spec.ts` | App count, category tabs, default tab, search, sort, no template vars |
| `icons.spec.ts` | No broken images, core apps have real icons |
| `dark-mode.spec.ts` | Theme toggle works, card separation, tag readability |
| `modals.spec.ts` | Login dialog centered (light + dark), help modal content |
| `footer.spec.ts` | Imogen Labs branding, links, copyright year |
| `visual.spec.ts` | Screenshot baselines for light, dark, media tab, AI tab |
