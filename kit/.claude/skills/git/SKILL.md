---
name: git
description: >
  Git workflow — conventional commits, branch strategy, PR conventions. Use when committing,
  branching, creating PRs, or managing git history. Triggers: git, commit, branch, PR,
  pull request, merge, rebase, conventional commits, git history.
---

# Git

Senior Git engineer. Conventional commits. Clean history. See `ci-cd` skill for GitHub Actions pipelines.

## Conventional Commits

```
<type>(<scope>): <description>

[optional body]
```

| Type | When |
|---|---|
| `feat` | New feature or capability |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `refactor` | Code change that neither fixes a bug nor adds a feature |
| `style` | Formatting, whitespace (not CSS styling) |
| `test` | Adding or updating tests |
| `chore` | Build scripts, deps, config, tooling |
| `perf` | Performance improvement |
| `ci` | CI/CD workflow changes |

### Examples

```
feat(contact): add Turnstile bot protection
fix(seo): correct JSON-LD schema for services page
refactor(components): extract hero section to organism
chore(deps): update Astro to 5.x
docs(readme): add deployment instructions
```

## Branch Strategy

```
main                          # production, always deployable
├── feature/add-blog          # new features
├── fix/contact-form-error    # bug fixes
├── chore/update-deps         # maintenance
└── refactor/extract-layout   # code improvements
```

- Branch from `main`, merge back to `main`
- Delete branches after merge
- Keep branches short-lived (< 1 week ideal)

## PR Conventions

```markdown
## Summary
- Add Turnstile bot protection to contact form
- Server-side token verification via Cloudflare API
- Error handling for failed verification

## Test plan
- [ ] Submit form with valid Turnstile token
- [ ] Verify rejection with invalid token
- [ ] Check error message display
```

- **Title**: Concise, under 70 chars, follows conventional commit format
- **Body**: Bullet summary + test plan
- **Size**: Small, focused PRs (< 400 lines changed)
- **Review**: Self-review diff before requesting review

## References

| Topic | File | Load When |
|-------|------|-----------|
| Advanced workflows | [workflows.md](references/workflows.md) | Rebase, cherry-pick, stash, conflict resolution, bisect, reflog |

## MUST DO

- Use conventional commit format for all commits
- Create feature branches from `main`
- Write descriptive PR titles and summaries
- Keep PRs small and focused on one concern
- Rebase feature branches on `main` before merging (clean history)
- Delete merged branches

## MUST NOT

- Force push to `main` — protect the production branch
- Commit secrets, `.env` files, or API keys
- Make giant PRs (500+ lines) — split into smaller PRs
- Use vague commit messages ("fix stuff", "update", "wip")
- Commit directly to `main` for non-trivial changes
- Leave stale branches after merging
