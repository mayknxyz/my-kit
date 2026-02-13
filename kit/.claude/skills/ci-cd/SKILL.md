---
name: ci-cd
description: >
  CI/CD with GitHub Actions, Cloudflare Pages deployment, and build pipelines. Use when
  setting up workflows, deploy pipelines, preview deployments, or caching strategies.
  Triggers: CI/CD, GitHub Actions, workflow, deploy, pipeline, preview deployment,
  Lighthouse CI, cache, build, continuous integration.
---

# CI/CD

Senior DevOps engineer. GitHub Actions. Cloudflare Pages deploy. See `cloudflare` skill for Cloudflare platform specifics, `git` skill for commit conventions.

## GitHub Actions Workflow Pattern

```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: oven-sh/setup-bun@v2
        with:
          bun-version: latest

      - name: Install dependencies
        run: bun install --frozen-lockfile

      - name: Lint
        run: bun run lint

      - name: Type check
        run: bun astro check

      - name: Build
        run: bun run build

      - name: Test
        run: bun test
```

## Cloudflare Pages Deploy

```yaml
  deploy:
    needs: build
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    permissions:
      contents: read
      deployments: write
    steps:
      - uses: actions/checkout@v4
      - uses: oven-sh/setup-bun@v2
      - run: bun install --frozen-lockfile
      - run: bun run build
      - uses: cloudflare/wrangler-action@v3
        with:
          apiToken: ${{ secrets.CLOUDFLARE_API_TOKEN }}
          accountId: ${{ secrets.CLOUDFLARE_ACCOUNT_ID }}
          command: pages deploy dist --project-name=my-project
```

## Preview Deployments on PR

```yaml
  preview:
    if: github.event_name == 'pull_request'
    runs-on: ubuntu-latest
    steps:
      # ... build steps ...
      - uses: cloudflare/wrangler-action@v3
        with:
          apiToken: ${{ secrets.CLOUDFLARE_API_TOKEN }}
          accountId: ${{ secrets.CLOUDFLARE_ACCOUNT_ID }}
          command: pages deploy dist --project-name=my-project --branch=${{ github.head_ref }}
```

## Caching Bun Dependencies

```yaml
      - name: Cache Bun dependencies
        uses: actions/cache@v4
        with:
          path: ~/.bun/install/cache
          key: bun-${{ runner.os }}-${{ hashFiles('**/bun.lockb') }}
          restore-keys: bun-${{ runner.os }}-
```

## Quality Checks in CI

```bash
# All-in-one web linting (a11y, perf, security, compat)
hint https://example.com

# Accessibility (multi-URL)
pa11y-ci

# Broken links
linkinator https://example.com --recurse

# Dead code
bunx knip

# Dependency vulnerabilities
snyk test
```

## MUST DO

- Use `--frozen-lockfile` for reproducible installs
- Run lint, type check, and build before deploy
- Use GitHub secrets for API tokens and account IDs
- Set up preview deployments for PRs
- Cache Bun dependencies to speed up builds
- Use `needs:` to enforce job ordering (build before deploy)

## MUST NOT

- Store secrets in workflow files — use GitHub repository secrets
- Skip build validation before deployment
- Deploy on PR merge without CI passing
- Use `latest` tags for actions in production (pin to `@v4` etc.)
- Run `bun install` without `--frozen-lockfile` in CI
- Skip type checking in CI pipeline
