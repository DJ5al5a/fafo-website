-- FAFO Website PostgreSQL Schema
-- Database: circuitsorcerer
-- Purpose: Support n8n workflows for content management and law monitoring

-- =====================================================
-- TABLE 1: Content Update Requests
-- =====================================================

CREATE TABLE IF NOT EXISTS fafo_content_updates (
    id SERIAL PRIMARY KEY,
    requested_at TIMESTAMP DEFAULT NOW(),
    requested_by VARCHAR(100),               -- Telegram username or ID
    page_name VARCHAR(100) NOT NULL,         -- e.g., 'state-laws.html'
    section_id VARCHAR(255),                 -- HTML element ID or description
    old_content TEXT,                        -- Original content before update
    new_content TEXT NOT NULL,               -- Updated content
    status VARCHAR(50) DEFAULT 'pending',    -- 'pending', 'approved', 'denied', 'deployed'
    approved_at TIMESTAMP,
    deployed_at TIMESTAMP,
    deployment_id INTEGER,                   -- Reference to fafo_deployments
    notes TEXT,                              -- Optional notes/comments
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_fafo_content_status ON fafo_content_updates(status);
CREATE INDEX IF NOT EXISTS idx_fafo_content_page ON fafo_content_updates(page_name);
CREATE INDEX IF NOT EXISTS idx_fafo_content_requested ON fafo_content_updates(requested_at DESC);

COMMENT ON TABLE fafo_content_updates IS 'Tracks content update requests made via Telegram bot CMS';
COMMENT ON COLUMN fafo_content_updates.section_id IS 'HTML element ID or section description for targeted updates';

-- =====================================================
-- TABLE 2: Law Sources Being Monitored
-- =====================================================

CREATE TABLE IF NOT EXISTS fafo_law_sources (
    id SERIAL PRIMARY KEY,
    source_type VARCHAR(50) NOT NULL,        -- 'fl_statute', 'fl_admin_code', 'federal_law'
    source_id VARCHAR(255) NOT NULL,         -- e.g., 'FL-39.001', '65C-29'
    title VARCHAR(500) NOT NULL,             -- Full title of law/statute
    url TEXT NOT NULL,                       -- Official source URL
    last_checked TIMESTAMP,                  -- Last time this source was checked
    content_hash VARCHAR(64),                -- SHA-256 hash of current content
    target_page VARCHAR(100),                -- Which FAFO page references this law
    target_section VARCHAR(255),             -- Section within page to update
    active BOOLEAN DEFAULT TRUE,             -- Whether to monitor this source
    check_frequency VARCHAR(20) DEFAULT 'weekly',  -- 'daily', 'weekly', 'monthly'
    priority INTEGER DEFAULT 5,              -- 1-10, higher = more important
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(source_type, source_id)
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_fafo_law_sources_active ON fafo_law_sources(active, check_frequency);
CREATE INDEX IF NOT EXISTS idx_fafo_law_sources_type ON fafo_law_sources(source_type);
CREATE INDEX IF NOT EXISTS idx_fafo_law_sources_priority ON fafo_law_sources(priority DESC);

COMMENT ON TABLE fafo_law_sources IS 'Florida statutes and policies monitored for changes';
COMMENT ON COLUMN fafo_law_sources.content_hash IS 'SHA-256 hash used for change detection';
COMMENT ON COLUMN fafo_law_sources.priority IS '1-10 scale, affects notification urgency';

-- =====================================================
-- TABLE 3: Detected Law Changes
-- =====================================================

CREATE TABLE IF NOT EXISTS fafo_law_changes (
    id SERIAL PRIMARY KEY,
    source_id INTEGER NOT NULL REFERENCES fafo_law_sources(id) ON DELETE CASCADE,
    detected_at TIMESTAMP DEFAULT NOW(),
    change_type VARCHAR(50),                 -- 'addition', 'modification', 'deletion', 'formatting'
    old_content_hash VARCHAR(64),            -- Previous content hash
    new_content_hash VARCHAR(64),            -- New content hash
    summary TEXT,                            -- Plain-language summary of changes
    impact_assessment TEXT,                  -- OpenCode AI analysis of impact
    severity VARCHAR(20) NOT NULL,           -- 'minor' or 'major'
    affected_pages JSONB,                    -- Array of FAFO pages needing updates
    updated_html TEXT,                       -- Generated HTML for deployment
    status VARCHAR(50) DEFAULT 'pending',    -- 'pending', 'approved', 'denied', 'deployed'
    approved_by VARCHAR(100),                -- Telegram username who approved
    approved_at TIMESTAMP,
    deployed_at TIMESTAMP,
    deployment_id INTEGER,                   -- Reference to fafo_deployments
    ai_confidence DECIMAL(3,2),              -- 0.00-1.00, OpenCode confidence score
    requires_manual_review BOOLEAN DEFAULT FALSE,
    review_notes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_fafo_law_changes_status ON fafo_law_changes(status);
CREATE INDEX IF NOT EXISTS idx_fafo_law_changes_severity ON fafo_law_changes(severity);
CREATE INDEX IF NOT EXISTS idx_fafo_law_changes_source ON fafo_law_changes(source_id);
CREATE INDEX IF NOT EXISTS idx_fafo_law_changes_detected ON fafo_law_changes(detected_at DESC);

COMMENT ON TABLE fafo_law_changes IS 'Detected changes to monitored laws with AI analysis';
COMMENT ON COLUMN fafo_law_changes.severity IS 'minor = typos/dates, major = rights/requirements changes';
COMMENT ON COLUMN fafo_law_changes.ai_confidence IS 'OpenCode confidence in analysis (0.00-1.00)';

-- =====================================================
-- TABLE 4: Deployment History
-- =====================================================

CREATE TABLE IF NOT EXISTS fafo_deployments (
    id SERIAL PRIMARY KEY,
    deployed_at TIMESTAMP DEFAULT NOW(),
    deployment_type VARCHAR(50) NOT NULL,    -- 'manual', 'auto_minor', 'law_update', 'content_update'
    git_commit_hash VARCHAR(40),             -- Git commit SHA
    git_commit_message TEXT,                 -- Commit message
    files_modified JSONB,                    -- Array of modified files
    css_version INTEGER,                     -- CSS version after deployment
    js_version INTEGER,                      -- JS version after deployment
    status VARCHAR(50) DEFAULT 'in_progress', -- 'in_progress', 'success', 'failed', 'rolled_back'
    nas_deployed BOOLEAN DEFAULT FALSE,      -- Successfully deployed to NAS
    github_pushed BOOLEAN DEFAULT FALSE,     -- Successfully pushed to GitHub
    deployment_duration_seconds INTEGER,     -- Time taken for deployment
    error_message TEXT,                      -- Error details if deployment failed
    deployed_by VARCHAR(100),                -- User or system that triggered deployment
    rollback_of INTEGER,                     -- If this is a rollback, ID of failed deployment
    verified_at TIMESTAMP,                   -- When deployment was verified successful
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_fafo_deployments_status ON fafo_deployments(status);
CREATE INDEX IF NOT EXISTS idx_fafo_deployments_type ON fafo_deployments(deployment_type);
CREATE INDEX IF NOT EXISTS idx_fafo_deployments_date ON fafo_deployments(deployed_at DESC);
CREATE INDEX IF NOT EXISTS idx_fafo_deployments_git ON fafo_deployments(git_commit_hash);

COMMENT ON TABLE fafo_deployments IS 'Complete history of all deployments with status tracking';
COMMENT ON COLUMN fafo_deployments.rollback_of IS 'References deployment ID that was rolled back';

-- =====================================================
-- FOREIGN KEY CONSTRAINTS
-- =====================================================

-- Add foreign key from content_updates to deployments
ALTER TABLE fafo_content_updates
    ADD CONSTRAINT fk_content_deployment
    FOREIGN KEY (deployment_id)
    REFERENCES fafo_deployments(id)
    ON DELETE SET NULL;

-- Add foreign key from law_changes to deployments
ALTER TABLE fafo_law_changes
    ADD CONSTRAINT fk_lawchange_deployment
    FOREIGN KEY (deployment_id)
    REFERENCES fafo_deployments(id)
    ON DELETE SET NULL;

-- =====================================================
-- HELPER VIEWS
-- =====================================================

-- View: Pending updates requiring approval
CREATE OR REPLACE VIEW v_pending_updates AS
SELECT
    'content' AS update_type,
    id,
    page_name AS target,
    requested_at AS detected_at,
    status,
    'N/A' AS severity
FROM fafo_content_updates
WHERE status = 'pending'
UNION ALL
SELECT
    'law_change' AS update_type,
    lc.id,
    ls.source_id AS target,
    lc.detected_at,
    lc.status,
    lc.severity
FROM fafo_law_changes lc
JOIN fafo_law_sources ls ON lc.source_id = ls.id
WHERE lc.status = 'pending'
ORDER BY detected_at DESC;

COMMENT ON VIEW v_pending_updates IS 'Combined view of all pending content and law updates';

-- View: Recent deployment history
CREATE OR REPLACE VIEW v_recent_deployments AS
SELECT
    id,
    deployed_at,
    deployment_type,
    status,
    git_commit_hash,
    css_version,
    js_version,
    nas_deployed,
    github_pushed,
    deployed_by
FROM fafo_deployments
ORDER BY deployed_at DESC
LIMIT 50;

COMMENT ON VIEW v_recent_deployments IS 'Last 50 deployments for quick reference';

-- =====================================================
-- TRIGGERS FOR AUTO-UPDATE TIMESTAMPS
-- =====================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply trigger to all tables
CREATE TRIGGER update_fafo_content_updates_updated_at
    BEFORE UPDATE ON fafo_content_updates
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_fafo_law_sources_updated_at
    BEFORE UPDATE ON fafo_law_sources
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_fafo_law_changes_updated_at
    BEFORE UPDATE ON fafo_law_changes
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_fafo_deployments_updated_at
    BEFORE UPDATE ON fafo_deployments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- INITIAL DATA / SEED
-- =====================================================

-- Note: Initial law sources will be seeded separately via seed-law-sources.sql

-- =====================================================
-- GRANTS (adjust as needed for your n8n user)
-- =====================================================

-- Grant permissions to n8n database user (adjust username as needed)
-- GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO n8n_user;
-- GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO n8n_user;

-- =====================================================
-- SCHEMA VERSION TRACKING
-- =====================================================

CREATE TABLE IF NOT EXISTS schema_version (
    version INTEGER PRIMARY KEY,
    applied_at TIMESTAMP DEFAULT NOW(),
    description TEXT
);

INSERT INTO schema_version (version, description)
VALUES (1, 'Initial FAFO schema: content updates, law monitoring, deployments')
ON CONFLICT (version) DO NOTHING;

-- =====================================================
-- COMPLETION
-- =====================================================

-- Verify all tables created
DO $$
DECLARE
    table_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO table_count
    FROM information_schema.tables
    WHERE table_schema = 'public'
    AND table_name IN ('fafo_content_updates', 'fafo_law_sources', 'fafo_law_changes', 'fafo_deployments');

    IF table_count = 4 THEN
        RAISE NOTICE 'SUCCESS: All 4 FAFO tables created successfully!';
    ELSE
        RAISE WARNING 'WARNING: Expected 4 tables but found %', table_count;
    END IF;
END $$;
