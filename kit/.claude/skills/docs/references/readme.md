# README Template Reference

Full README template with mandatory and optional sections. Copy, fill in, delete unused optional sections.

## Template

```markdown
# Project Name

Brief one-line description of what this project does.

## Overview

2-3 sentences explaining the project's purpose and who it's for. Answer: "Why does this exist?" and "Who should use it?"

## Prerequisites

- [Node.js](https://nodejs.org/) >= 20
- [pnpm](https://pnpm.io/) (or npm/bun)
- Any other required tools or accounts

## Installation

```bash
git clone https://github.com/user/project.git
cd project
pnpm install
```

## Usage

```bash
# Development
pnpm dev

# Build
pnpm build

# Preview production build
pnpm preview
```

### Key Commands

| Command | Description |
|---------|-------------|
| `pnpm dev` | Start development server |
| `pnpm build` | Build for production |
| `pnpm test` | Run tests |
| `pnpm lint` | Lint and format check |

## Configuration

Describe key configuration files and environment variables:

| Variable | Required | Description |
|----------|----------|-------------|
| `DATABASE_URL` | Yes | D1 database connection |
| `API_KEY` | Yes | External service API key |

## Project Structure (optional)

```
src/
├── components/    # UI components
├── layouts/       # Page layouts
├── pages/         # Route pages
└── lib/           # Utilities and helpers
```

## Contributing (optional)

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/add-widget`)
3. Commit changes using conventional commits
4. Push to your branch and open a PR

## License

[MIT](LICENSE)
```

## Section Rules

### Mandatory Sections

Every README must have these:

| Section | Purpose |
|---------|---------|
| Title + description | What is this? |
| Overview | Why does it exist? |
| Prerequisites | What do I need? |
| Installation | How do I set it up? |
| Usage | How do I use it? |
| License | What can I do with it? |

### Optional Sections

Include only when relevant:

| Section | When to Include |
|---------|----------------|
| Configuration | Project has env vars or config files |
| Project Structure | Non-obvious directory layout |
| Contributing | Open-source or team project |
| API Reference | Library or API project |
| Deployment | Non-trivial deploy process |
| Troubleshooting | Common setup issues |

## Anti-Pattern Table

| Bad | Good | Why |
|-----|------|-----|
| No installation steps | Step-by-step with copy-paste commands | New devs can't guess setup |
| "See docs folder" with no overview | Overview + link to detailed docs | README is the entry point |
| Outdated badge wall | 0-3 relevant badges (build, version, license) | Visual clutter hurts readability |
| Giant README (500+ lines) | README overview + linked detailed docs | README is an index, not a book |
| "Run `npm start`" with no context | Full command with expected output | Reduces "is it working?" confusion |
| Prerequisites buried in install steps | Separate prerequisites section | Fail fast before starting setup |
