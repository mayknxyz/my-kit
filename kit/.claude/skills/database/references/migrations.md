# D1 Migration Workflow

Multi-environment migration discipline for Cloudflare D1. Every schema change must be applied to **all target environments** before the work is considered complete.

## Environments

| Environment | Flag | Purpose |
|-------------|------|---------|
| Local | `--local` | Local development via Miniflare |
| Preview | `--remote --env preview` | Preview/staging deployments |
| Production | `--remote --env production` | Live production database |

## Step-by-Step Workflow

### 1. Create the migration file

```bash
bunx wrangler d1 migrations create my-database "description_of_change"
```

This creates a numbered SQL file in `migrations/`. Write idempotent SQL:

```sql
-- Always use IF NOT EXISTS / IF EXISTS for safety
CREATE TABLE IF NOT EXISTS notifications (
  id TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
  user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  message TEXT NOT NULL,
  read INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_notifications_user ON notifications(user_id);
```

### 2. Apply to local

```bash
bunx wrangler d1 migrations apply my-database --local
```

### 3. Test locally

Run the app, verify the schema change works. Run any affected tests.

### 4. Apply to preview

```bash
bunx wrangler d1 migrations apply my-database --remote --env preview
```

### 5. Test on preview

Verify the preview deployment works with the new schema.

### 6. Apply to production

```bash
bunx wrangler d1 migrations apply my-database --remote --env production
```

### 7. Verify production

Confirm production is stable after the migration.

## Verification Commands

Check migration state per environment:

```bash
# Local
bunx wrangler d1 migrations list my-database --local

# Preview
bunx wrangler d1 migrations list my-database --remote --env preview

# Production
bunx wrangler d1 migrations list my-database --remote --env production
```

## Pre-Deployment Checklist

Before considering any schema change complete:

- [ ] Migration SQL file created in `migrations/` directory
- [ ] SQL is idempotent (`IF NOT EXISTS` / `IF EXISTS`)
- [ ] Applied to local and tested
- [ ] Applied to preview and tested
- [ ] Applied to production and verified
- [ ] Migration state matches across all target environments

## Common Pitfalls

### Forgetting to create a migration after schema changes

**Problem:** Making schema changes directly (e.g., via D1 console) without a migration file.

**Prevention:** Every schema change starts with `wrangler d1 migrations create`. No exceptions. The migration file is the source of truth.

### Applying to local only

**Problem:** Running `--local` and forgetting to apply to preview and production.

**Prevention:** Treat migration apply as a three-step process: local, preview, production. Use `migrations list` to verify all environments are in sync before marking work complete.

### Local DB drift from remote environments

**Problem:** Making ad-hoc local changes that diverge from what preview/production have.

**Prevention:** Never modify the local database outside of migration files. If the local DB is out of sync, drop it and re-apply all migrations:

```bash
rm -rf .wrangler/state
bunx wrangler d1 migrations apply my-database --local
```

## Rollback Patterns

D1 does not have built-in rollback. Write forward-only migrations that are safe to apply:

```sql
-- Adding a column (safe, no data loss)
ALTER TABLE posts ADD COLUMN summary TEXT;

-- Removing a column (write as separate migration, after code stops using it)
ALTER TABLE posts DROP COLUMN legacy_field;

-- Renaming with safety (SQLite doesn't support RENAME COLUMN before 3.25)
ALTER TABLE posts RENAME COLUMN old_name TO new_name;
```

For destructive changes, create a new migration that reverses the effect:

```sql
-- 0005_add_feature_flag.sql
ALTER TABLE users ADD COLUMN beta_enabled INTEGER NOT NULL DEFAULT 0;

-- 0006_remove_feature_flag.sql (if rollback needed)
ALTER TABLE users DROP COLUMN beta_enabled;
```
