-- FAFO Law Sources Bulk Insert Script
-- Purpose: Populate fafo_law_sources table with common Florida Chapter 39 laws
-- Usage: psql -U postgres -d fafo_db -f add_law_sources.sql
-- Created: 2026-01-05

BEGIN;

-- ============================================================================
-- Core Chapter 39 Statutes (Priority: 10 - Critical)
-- ============================================================================

INSERT INTO fafo_law_sources (
  source_type, source_id, title, url,
  target_page, target_section, priority, active
) VALUES
  -- Definitions
  ('statute', 'FL_STAT_39.001', 'Florida Statute 39.001 - Definitions (Child Welfare)',
   'http://www.leg.state.fl.us/statutes/index.cfm?App_mode=Display_Statute&URL=0000-0099/0039/Sections/0039.001.html',
   'know-your-rights', 'definitions-section', 10, true),

  -- Shelter Hearings
  ('statute', 'FL_STAT_39.301', 'Florida Statute 39.301 - Shelter Hearings and Placement',
   'http://www.leg.state.fl.us/statutes/index.cfm?App_mode=Display_Statute&URL=0000-0099/0039/Sections/0039.301.html',
   'court-hearings', 'shelter-hearing', 10, true),

  -- Taking Children into Custody
  ('statute', 'FL_STAT_39.401', 'Florida Statute 39.401 - Taking Children into Custody',
   'http://www.leg.state.fl.us/statutes/index.cfm?App_mode=Display_Statute&URL=0000-0099/0039/Sections/0039.401.html',
   'crisis-guide', 'custody-rights', 10, true),

  -- Termination of Parental Rights
  ('statute', 'FL_STAT_39.801', 'Florida Statute 39.801 - Grounds for Termination of Parental Rights',
   'http://www.leg.state.fl.us/statutes/index.cfm?App_mode=Display_Statute&URL=0000-0099/0039/Sections/0039.801.html',
   'know-your-rights', 'tpr-section', 10, true);

-- ============================================================================
-- Important Procedures (Priority: 8-9 - High)
-- ============================================================================

INSERT INTO fafo_law_sources (
  source_type, source_id, title, url,
  target_page, target_section, priority, active
) VALUES
  -- Case Plan Development
  ('statute', 'FL_STAT_39.521', 'Florida Statute 39.521 - Case Plan Development',
   'http://www.leg.state.fl.us/statutes/index.cfm?App_mode=Display_Statute&URL=0000-0099/0039/Sections/0039.521.html',
   'dcf-policies', 'case-plan', 8, true),

  -- Judicial Review
  ('statute', 'FL_STAT_39.701', 'Florida Statute 39.701 - Judicial Review of Dependency Cases',
   'http://www.leg.state.fl.us/statutes/index.cfm?App_mode=Display_Statute&URL=0000-0099/0039/Sections/0039.701.html',
   'court-hearings', 'review-hearings', 9, true),

  -- Permanency Hearings
  ('statute', 'FL_STAT_39.621', 'Florida Statute 39.621 - Permanency Hearings',
   'http://www.leg.state.fl.us/statutes/index.cfm?App_mode=Display_Statute&URL=0000-0099/0039/Sections/0039.621.html',
   'court-hearings', 'permanency-hearing', 9, true),

  -- Adjudicatory Hearings
  ('statute', 'FL_STAT_39.507', 'Florida Statute 39.507 - Adjudicatory Hearings',
   'http://www.leg.state.fl.us/statutes/index.cfm?App_mode=Display_Statute&URL=0000-0099/0039/Sections/0039.507.html',
   'court-hearings', 'adjudicatory-hearing', 9, true);

-- ============================================================================
-- DCF Operating Procedures (Priority: 7-8 - High)
-- ============================================================================

INSERT INTO fafo_law_sources (
  source_type, source_id, title, url,
  target_page, target_section, priority, active
) VALUES
  -- Safety Methodology
  ('policy', 'DCF_CFOP_175-1', 'CFOP 175-1 - Safety Methodology',
   'https://www.myflfamilies.com/sites/default/files/2022-07/CFOP%20175-1%20Safety%20Methodology.pdf',
   'crisis-guide', 'safety-assessment', 8, true),

  -- Family Functioning Assessment
  ('policy', 'DCF_CFOP_175-43', 'CFOP 175-43 - Family Functioning Assessment',
   'https://www.myflfamilies.com/sites/default/files/2022-07/CFOP%20175-43%20Family%20Functioning%20Assessment.pdf',
   'dcf-policies', 'assessments', 7, true),

  -- Case Plan Development
  ('policy', 'DCF_CFOP_175-48', 'CFOP 175-48 - Case Plan Development and Judicial Review',
   'https://www.myflfamilies.com/sites/default/files/2022-07/CFOP%20175-48%20Case%20Plan%20Development.pdf',
   'dcf-policies', 'case-plan', 7, true);

-- ============================================================================
-- Court Forms (Priority: 6-7 - Medium)
-- ============================================================================

INSERT INTO fafo_law_sources (
  source_type, source_id, title, url,
  target_page, target_section, priority, active
) VALUES
  -- Dependency Petition
  ('form', 'FORM_8.201', 'Florida Form 8.201 - Dependency Petition',
   'https://www.flcourts.gov/content/download/219474/file/8.201.pdf',
   'templates', 'dependency-petition', 6, true),

  -- Shelter Petition
  ('form', 'FORM_8.305', 'Florida Form 8.305 - Shelter Petition',
   'https://www.flcourts.gov/content/download/219475/file/8.305.pdf',
   'templates', 'shelter-petition', 7, true),

  -- Order on Shelter Petition
  ('form', 'FORM_8.306', 'Florida Form 8.306 - Order on Shelter Petition',
   'https://www.flcourts.gov/content/download/219476/file/8.306.pdf',
   'templates', 'shelter-order', 6, true),

  -- Case Plan
  ('form', 'FORM_8.401', 'Florida Form 8.401 - Case Plan',
   'https://www.flcourts.gov/content/download/219477/file/8.401.pdf',
   'templates', 'case-plan-form', 6, true);

-- ============================================================================
-- Additional Important Statutes (Priority: 7-8 - Medium-High)
-- ============================================================================

INSERT INTO fafo_law_sources (
  source_type, source_id, title, url,
  target_page, target_section, priority, active
) VALUES
  -- Reporting Abuse
  ('statute', 'FL_STAT_39.201', 'Florida Statute 39.201 - Mandatory Reporting of Abuse',
   'http://www.leg.state.fl.us/statutes/index.cfm?App_mode=Display_Statute&URL=0000-0099/0039/Sections/0039.201.html',
   'reporting', 'mandatory-reporting', 7, true),

  -- Rights of Parents and Children
  ('statute', 'FL_STAT_39.502', 'Florida Statute 39.502 - Rights of Parents and Children',
   'http://www.leg.state.fl.us/statutes/index.cfm?App_mode=Display_Statute&URL=0000-0099/0039/Sections/0039.502.html',
   'know-your-rights', 'parent-child-rights', 9, true),

  -- Guardian Ad Litem
  ('statute', 'FL_STAT_39.822', 'Florida Statute 39.822 - Guardian Ad Litem',
   'http://www.leg.state.fl.us/statutes/index.cfm?App_mode=Display_Statute&URL=0000-0099/0039/Sections/0039.822.html',
   'court-hearings', 'guardian-ad-litem', 7, true),

  -- Relative and Nonrelative Placement
  ('statute', 'FL_STAT_39.5085', 'Florida Statute 39.5085 - Relative and Nonrelative Placement',
   'http://www.leg.state.fl.us/statutes/index.cfm?App_mode=Display_Statute&URL=0000-0099/0039/Sections/0039.5085.html',
   'resources', 'placement-options', 8, true);

COMMIT;

-- ============================================================================
-- Verification Queries
-- ============================================================================

-- Show summary of inserted sources
SELECT
  source_type,
  COUNT(*) as total_sources,
  AVG(priority) as avg_priority,
  MIN(priority) as min_priority,
  MAX(priority) as max_priority
FROM fafo_law_sources
WHERE active = true
GROUP BY source_type
ORDER BY avg_priority DESC;

-- Show all sources by priority
SELECT
  priority,
  source_type,
  source_id,
  title,
  target_page
FROM fafo_law_sources
WHERE active = true
ORDER BY priority DESC, source_id ASC;

-- Verify URLs are accessible (requires curl)
-- Run this separately to test URLs:
-- SELECT source_id, url FROM fafo_law_sources WHERE active = true;
