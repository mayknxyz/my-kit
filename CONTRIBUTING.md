# Contributing to My Kit

Thank you for your interest in contributing to My Kit!

## Getting Started

1. Fork the repository
2. Clone your fork
3. Install My Kit in development mode

## Development Setup

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/my-kit.git
cd my-kit

# Install dependencies
# Requires: git, gh (GitHub CLI)
```

## How to Contribute

### Reporting Issues

- Use GitHub Issues for bug reports and feature requests
- Search existing issues before creating a new one
- Include clear reproduction steps for bugs

### Pull Requests

1. Create a branch from `main`
   ```bash
   git checkout -b 42-feature-description
   ```

2. Make your changes following project conventions

3. Test your changes

4. Commit using [Conventional Commits](https://www.conventionalcommits.org/):
   ```
   feat: add new feature
   fix: resolve bug
   docs: update documentation
   refactor: improve code structure
   ```

5. Push and create a PR
   ```bash
   git push origin 42-feature-description
   ```

### Code Style

- Shell scripts: Follow [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
- Use `shellcheck` for linting
- Keep commands focused and single-purpose

### Command Guidelines

When adding or modifying `/mykit.*` commands, follow the [Command Conventions](docs/CONVENTIONS.md):

1. **Action-based execution** - State-changing commands require an action (e.g., `create`, `run`)
2. **Preview by default** - Commands without action show what they'll do
3. **Clear errors** - Provide actionable error messages with remediation steps
4. **Issue linking** - All work linked to GitHub Issues (use `--no-issue` for exceptions)

### Documentation

- Update `README.md` for user-facing changes
- Update `docs/001_BLUEPRINT.md` for architectural changes
- Include examples in command help text

## Project Structure

```
.claude/commands/     # Slash command files
.mykit/scripts/       # Shell utilities
docs/                 # Documentation
```

## Questions?

Open an issue for questions or discussion.

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
