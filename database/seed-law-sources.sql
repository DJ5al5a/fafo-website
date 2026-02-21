-- FAFO Law Sources Seed Data
-- Populates fafo_law_sources with initial Florida statutes and policies to monitor

-- =====================================================
-- FLORIDA CHAPTER 39 STATUTES (Primary Focus)
-- =====================================================

INSERT INTO fafo_law_sources (source_type, source_id, title, url, target_page, target_section, priority, check_frequency, notes)
VALUES

-- Core Purpose & Definitions
('fl_statute', 'FL-39.001', 'Chapter 39 - Purposes and intent; personnel standards',
 'http://www.leg.state.fl.us/statutes/index.cfm?App_mode=Display_Statute&URL=0000-0099/0039/Sections/0039.001.html',
 'state-laws.html', 'section-39-001', 10, 'weekly',
 'Core purpose of Florida child welfare law - fundamental to entire system'),

('fl_statute', 'FL-39.01', 'Chapter 39 - Definitions',
 'http://www.leg.state.fl.us/statutes/index.cfm?App_mode=Display_Statute&URL=0000-0099/0039/Sections/0039.01.html',
 'state-laws.html', 'section-39-01', 10, 'weekly',
 'Defines key terms: abuse, neglect, abandonment, shelter, etc.'),

-- Reporting & Investigation
('fl_statute', 'FL-39.201', 'Mandatory reports of child abuse, abandonment, or neglect',
 'http://www.leg.state.fl.us/statutes/index.cfm?App_mode=Display_Statute&URL=0000-0099/0039/Sections/0039.201.html',
 'dcf-policies.html', 'section-reporting', 9, 'weekly',
 'Mandatory reporter requirements - affects who must report suspected abuse'),

('fl_statute', 'FL-39.202', 'Immunity from liability in cases of child abandonment',
 'http://www.leg.state.fl.us/statutes/index.cfm?App_mode=Display_Statute&URL=0000-0099/0039/Sections/0039.202.html',
 'dcf-policies.html', 'section-reporting', 6, 'monthly',
 'Safe haven law - immunity for reporting'),

('fl_statute', 'FL-39.301', 'Initiation of protective investigations',
 'http://www.leg.state.fl.us/statutes/index.cfm?App_mode=Display_Statute&URL=0000-0099/0039/Sections/0039.301.html',
 'dcf-policies.html', 'section-investigation', 9, 'weekly',
 'How DCF investigations are started and conducted'),

('fl_statute', 'FL-39.302', 'Protective investigations of institutional child abuse, abandonment, or neglect',
 'http://www.leg.state.fl.us/statutes/index.cfm?App_mode=Display_Statute&URL=0000-0099/0039/Sections/0039.302.html',
 'dcf-policies.html', 'section-investigation', 7, 'monthly',
 'Investigations in facilities (schools, daycares, etc.)'),

-- Taking Children Into Custody
('fl_statute', 'FL-39.401', 'Taking a child into custody',
 'http://www.leg.state.fl.us/statutes/index.cfm?App_mode=Display_Statute&URL=0000-0099/0039/Sections/0039.401.html',
 'know-your-rights.html', 'section-removal', 10, 'weekly',
 'CRITICAL: Conditions under which DCF can remove children - parents must know this'),

('fl_statute', 'FL-39.402', 'Placement in a shelter',
 'http://www.leg.state.fl.us/statutes/index.cfm?App_mode=Display_Statute&URL=0000-0099/0039/Sections/0039.402.html',
 'court-hearings.html', 'section-shelter', 9, 'weekly',
 'Where children can be placed after removal'),

-- Court Proceedings
('fl_statute', 'FL-39.501', 'Petition for dependency',
 'http://www.leg.state.fl.us/statutes/index.cfm?App_mode=Display_Statute&URL=0000-0099/0039/Sections/0039.501.html',
 'court-hearings.html', 'section-petition', 8, 'monthly',
 'How dependency cases are initiated in court'),

('fl_statute', 'FL-39.506', 'Shelter hearing',
 'http://www.leg.state.fl.us/statutes/index.cfm?App_mode=Display_Statute&URL=0000-0099/0039/Sections/0039.506.html',
 'court-hearings.html', 'section-shelter-hearing', 10, 'weekly',
 'CRITICAL: First court hearing within 24 hours - 10-day waiver trap'),

('fl_statute', 'FL-39.507', 'Arraignment hearing',
 'http://www.leg.state.fl.us/statutes/index.cfm?App_mode=Display_Statute&URL=0000-0099/0039/Sections/0039.507.html',
 'court-hearings.html', 'section-arraignment', 8, 'monthly',
 'Parents admit or deny allegations'),

('fl_statute', 'FL-39.521', 'Adjudicatory hearings',
 'http://www.leg.state.fl.us/statutes/index.cfm?App_mode=Display_Statute&URL=0000-0099/0039/Sections/0039.521.html',
 'court-hearings.html', 'section-adjudication', 8, 'monthly',
 'Trial to determine if child is dependent'),

('fl_statute', 'FL-39.701', 'Judicial review',
 'http://www.leg.state.fl.us/statutes/index.cfm?App_mode=Display_Statute&URL=0000-0099/0039/Sections/0039.701.html',
 'court-hearings.html', 'section-review', 7, 'monthly',
 'Ongoing court review of case progress'),

-- Parental Rights
('fl_statute', 'FL-39.801', 'Termination of parental rights',
 'http://www.leg.state.fl.us/statutes/index.cfm?App_mode=Display_Statute&URL=0000-0099/0039/Sections/0039.801.html',
 'court-hearings.html', 'section-tpr', 10, 'weekly',
 'CRITICAL: Grounds for terminating parental rights - highest stakes'),

('fl_statute', 'FL-39.806', 'Grounds for termination of parental rights',
 'http://www.leg.state.fl.us/statutes/index.cfm?App_mode=Display_Statute&URL=0000-0099/0039/Sections/0039.806.html',
 'court-hearings.html', 'section-tpr-grounds', 10, 'weekly',
 'Specific legal grounds for TPR - parents must understand these');

-- =====================================================
-- FLORIDA ADMINISTRATIVE CODE (DCF Policies)
-- =====================================================

INSERT INTO fafo_law_sources (source_type, source_id, title, url, target_page, target_section, priority, check_frequency, notes)
VALUES

('fl_admin_code', '65C-29', 'Protective Investigations',
 'https://www.flrules.org/gateway/ChapterHome.asp?Chapter=65C-29',
 'dcf-policies.html', 'section-65c-29', 9, 'weekly',
 'DCF administrative rules for investigations - detailed procedures'),

('fl_admin_code', '65C-30', 'Shelter and Foster Care',
 'https://www.flrules.org/gateway/ChapterHome.asp?Chapter=65C-30',
 'dcf-policies.html', 'section-shelter-placement', 7, 'monthly',
 'Rules for shelter and foster care placement'),

('fl_admin_code', '65C-28', 'Child Welfare Services',
 'https://www.flrules.org/gateway/ChapterHome.asp?Chapter=65C-28',
 'dcf-policies.html', 'section-services', 7, 'monthly',
 'General child welfare services requirements');

-- =====================================================
-- FEDERAL LAWS (Relevant to Florida cases)
-- =====================================================

INSERT INTO fafo_law_sources (source_type, source_id, title, url, target_page, target_section, priority, check_frequency, notes)
VALUES

('federal_law', '42-USC-671', 'Title IV-E Foster Care',
 'https://www.govinfo.gov/content/pkg/USCODE-2011-title42/html/USCODE-2011-title42-chap7-subchapIV-partE-sec671.htm',
 'resources.html', 'section-federal-rights', 6, 'monthly',
 'Federal foster care funding and requirements'),

('federal_law', 'ASFA-1997', 'Adoption and Safe Families Act',
 'https://www.congress.gov/105/plaws/publ89/PLAW-105publ89.pdf',
 'state-laws.html', 'section-federal-laws', 5, 'yearly',
 'Federal law requiring reasonable efforts and timelines'),

('federal_law', 'ICWA', 'Indian Child Welfare Act',
 'https://www.govinfo.gov/content/pkg/USCODE-2011-title25/html/USCODE-2011-title25-chap21.htm',
 'know-your-rights.html', 'section-icwa', 6, 'yearly',
 'Special protections for Native American children');

-- =====================================================
-- CONSTITUTIONAL PROVISIONS
-- =====================================================

INSERT INTO fafo_law_sources (source_type, source_id, title, url, target_page, target_section, priority, check_frequency, notes)
VALUES

('federal_law', 'US-CONST-IV-14', 'Fourteenth Amendment - Due Process',
 'https://constitution.congress.gov/constitution/amendment-14/',
 'know-your-rights.html', 'section-constitutional-rights', 8, 'yearly',
 'Due process rights in child welfare cases'),

('federal_law', 'US-CONST-IV-4', 'Fourth Amendment - Search and Seizure',
 'https://constitution.congress.gov/constitution/amendment-4/',
 'know-your-rights.html', 'section-constitutional-rights', 8, 'yearly',
 'Protection against unreasonable searches - home visits');

-- =====================================================
-- VERIFICATION
-- =====================================================

-- Count and display seeded sources
DO $$
DECLARE
    source_count INTEGER;
    statute_count INTEGER;
    admin_code_count INTEGER;
    federal_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO source_count FROM fafo_law_sources;
    SELECT COUNT(*) INTO statute_count FROM fafo_law_sources WHERE source_type = 'fl_statute';
    SELECT COUNT(*) INTO admin_code_count FROM fafo_law_sources WHERE source_type = 'fl_admin_code';
    SELECT COUNT(*) INTO federal_count FROM fafo_law_sources WHERE source_type = 'federal_law';

    RAISE NOTICE '================================================';
    RAISE NOTICE 'FAFO Law Sources Seeded Successfully!';
    RAISE NOTICE '================================================';
    RAISE NOTICE 'Total Sources: %', source_count;
    RAISE NOTICE 'FL Statutes (Chapter 39): %', statute_count;
    RAISE NOTICE 'FL Admin Code (DCF Rules): %', admin_code_count;
    RAISE NOTICE 'Federal Laws & Constitution: %', federal_count;
    RAISE NOTICE '================================================';
    RAISE NOTICE 'Priority 10 (Critical): % sources', (SELECT COUNT(*) FROM fafo_law_sources WHERE priority = 10);
    RAISE NOTICE 'Priority 9-8 (High): % sources', (SELECT COUNT(*) FROM fafo_law_sources WHERE priority >= 8 AND priority < 10);
    RAISE NOTICE 'Priority 7-6 (Medium): % sources', (SELECT COUNT(*) FROM fafo_law_sources WHERE priority >= 6 AND priority < 8);
    RAISE NOTICE 'Priority 5-1 (Low): % sources', (SELECT COUNT(*) FROM fafo_law_sources WHERE priority < 6);
    RAISE NOTICE '================================================';
END $$;

-- Display the seeded sources
SELECT
    source_type,
    source_id,
    title,
    priority,
    check_frequency,
    target_page
FROM fafo_law_sources
ORDER BY priority DESC, source_type, source_id;
