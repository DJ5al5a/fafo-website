# FAFO Database Setup

This directory contains PostgreSQL schema and seed data for FAFO n8n workflows.

## Prerequisites

- PostgreSQL database `circuitsorcerer` running on NAS (192.168.1.104)
- PostgreSQL user with CREATE TABLE permissions
- psql command-line tool or database GUI (pgAdmin, DBeaver, etc.)

## Files

1. **fafo-schema.sql** - Creates 4 tables for FAFO workflows:
   - `fafo_content_updates` - Content update tracking
   - `fafo_law_sources` - Law sources to monitor
   - `fafo_law_changes` - Detected law changes
   - `fafo_deployments` - Deployment history

2. **seed-law-sources.sql** - Seeds initial Florida statutes and policies (25+ sources)

## Installation Steps

### Option 1: Using psql (Command Line)

```bash
# Connect to PostgreSQL database
psql -h 192.168.1.104 -U your_username -d circuitsorcerer

# Or if using local socket
psql -d circuitsorcerer

# Once connected, run the schema
\i /home/hecker/Projects/Web/MOM/Site/database/fafo-schema.sql

# Then seed the law sources
\i /home/hecker/Projects/Web/MOM/Site/database/seed-law-sources.sql
```

### Option 2: Direct psql Execution

```bash
# Execute schema creation
psql -h 192.168.1.104 -U your_username -d circuitsorcerer \
  -f /home/hecker/Projects/Web/MOM/Site/database/fafo-schema.sql

# Execute seed data
psql -h 192.168.1.104 -U your_username -d circuitsorcerer \
  -f /home/hecker/Projects/Web/MOM/Site/database/seed-law-sources.sql
```

### Option 3: Using Database GUI

1. Open pgAdmin, DBeaver, or similar tool
2. Connect to database: `circuitsorcerer` on `192.168.1.104`
3. Open and execute `fafo-schema.sql`
4. Open and execute `seed-law-sources.sql`

## Verification

After running both scripts, verify the installation:

```sql
-- Check that all 4 tables exist
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name LIKE 'fafo_%'
ORDER BY table_name;

-- Expected output:
-- fafo_content_updates
-- fafo_deployments
-- fafo_law_changes
-- fafo_law_sources

-- Check law sources were seeded (should be 25+)
SELECT
    source_type,
    COUNT(*) as count
FROM fafo_law_sources
GROUP BY source_type
ORDER BY source_type;

-- Expected output:
-- federal_law       5
-- fl_admin_code     3
-- fl_statute       17

-- View high-priority law sources
SELECT source_id, title, priority, check_frequency
FROM fafo_law_sources
WHERE priority >= 9
ORDER BY priority DESC, source_id;
```

## Database Schema Overview

### Table Relationships

```
fafo_law_sources
    ↓ (one-to-many)
fafo_law_changes
    ↓ (many-to-one)
fafo_deployments
    ↑ (many-to-one)
fafo_content_updates
```

### Key Features

- **Auto-updating timestamps**: All tables have `created_at` and `updated_at`
- **Foreign key constraints**: Ensures referential integrity
- **Indexes**: Optimized for common queries (status, dates, priorities)
- **Views**: `v_pending_updates`, `v_recent_deployments` for quick access
- **Comments**: All tables and critical columns have documentation

## n8n Integration

These tables are designed to work with n8n workflows:

1. **fafo-content-cms.json** - Uses `fafo_content_updates` and `fafo_deployments`
2. **fafo-law-monitor-weekly.json** - Uses `fafo_law_sources` and `fafo_law_changes`
3. **fafo-deployment.json** - Uses `fafo_deployments`

## Maintenance

### Backup

```bash
# Backup FAFO tables only
pg_dump -h 192.168.1.104 -U your_username -d circuitsorcerer \
  -t fafo_content_updates \
  -t fafo_law_sources \
  -t fafo_law_changes \
  -t fafo_deployments \
  > fafo-backup-$(date +%Y%m%d).sql
```

### Adding New Law Sources

```sql
INSERT INTO fafo_law_sources (
    source_type,
    source_id,
    title,
    url,
    target_page,
    target_section,
    priority,
    check_frequency
) VALUES (
    'fl_statute',
    'FL-39.XXX',
    'Your Law Title Here',
    'http://www.leg.state.fl.us/statutes/...',
    'target-page.html',
    'section-id',
    8,  -- 1-10 priority
    'weekly'  -- or 'daily', 'monthly'
);
```

### Clean Up Old Data

```sql
-- Archive old deployments (keep last 100)
DELETE FROM fafo_deployments
WHERE id NOT IN (
    SELECT id FROM fafo_deployments
    ORDER BY deployed_at DESC
    LIMIT 100
);

-- Clean up denied content updates older than 90 days
DELETE FROM fafo_content_updates
WHERE status = 'denied'
  AND updated_at < NOW() - INTERVAL '90 days';
```

## Troubleshooting

### Permission Denied

If you get permission errors, grant access to your n8n database user:

```sql
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO n8n_user;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO n8n_user;
```

### Schema Already Exists

The schema uses `CREATE TABLE IF NOT EXISTS`, so it's safe to run multiple times. To completely reset:

```sql
-- WARNING: This deletes all FAFO data
DROP TABLE IF EXISTS fafo_content_updates CASCADE;
DROP TABLE IF EXISTS fafo_law_changes CASCADE;
DROP TABLE IF EXISTS fafo_law_sources CASCADE;
DROP TABLE IF EXISTS fafo_deployments CASCADE;
DROP VIEW IF EXISTS v_pending_updates CASCADE;
DROP VIEW IF EXISTS v_recent_deployments CASCADE;
DROP FUNCTION IF EXISTS update_updated_at_column CASCADE;

-- Then re-run the schema and seed scripts
```

## Next Steps

After database setup:

1. Configure n8n credentials for PostgreSQL connection
2. Import n8n workflow files from `/home/hecker/Projects/n8n-workflows/`
3. Test database connectivity from n8n
4. Set up Telegram bot for content CMS workflow

## Support

For issues or questions, refer to:
- Main plan: `/home/hecker/.claude/plans/peppy-shimmying-candle.md`
- FAFO documentation: `/home/hecker/Projects/Web/MOM/Site/CLAUDE.md`
