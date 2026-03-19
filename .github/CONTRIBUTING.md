# Contributing to HomelabARR CE

Thanks for your interest in contributing!

## How to Contribute

1. Fork the repo
2. Create a feature branch (`git checkout -b feature/my-feature`)
3. Make your changes
4. Run the tests (`npm test`)
5. Submit a pull request

## Development Setup

```bash
git clone https://github.com/YOUR-USERNAME/homelabarr-ce.git
cd homelabarr-ce
npm install
npm run dev
```

This starts the Vite dev server (frontend on `:5173`) and Express backend (`:8092`) concurrently.

## Adding App Templates

App templates go in `server/templates/` as YAML files. Look at existing templates for the format. Each template defines a Docker Compose stack for a single application.

## Reporting Bugs

Open a [GitHub Issue](https://github.com/smashingtags/homelabarr-ce/issues) or ask in [Discord #help](https://discord.gg/Pc7mXX786x).

Include:
- What you expected vs what happened
- Steps to reproduce
- OS, Docker version, browser

## Code Style

- TypeScript for frontend code
- JavaScript (ES modules) for backend
- Use the existing ESLint config (`npm run lint`)

## License

By contributing, you agree that your contributions will be licensed under the [MIT License](../LICENSE).
