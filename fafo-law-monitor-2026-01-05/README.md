# FAFO Law Monitor Project

**Date Created:** 2026-01-05
**Location:** `/home/hecker/Projects/web/mom/site/fafo-law-monitor-2026-01-05/`

---

## Project Overview

Automated law monitoring system for familyandfriendoutreach.com that:
- Monitors Florida Chapter 39 statutes for changes
- Uses AI (Grok via OpenCode) to analyze law changes
- Sends Telegram notifications requiring manual approval
- Maintains change history in PostgreSQL database

---

## Files in This Folder

### Documentation (Start Here!)

1. **QUICK-REFERENCE.md** (5 min read)
   - Cheat sheet for common commands
   - Database queries
   - Troubleshooting shortcuts
   - **Start here for quick setup**

2. **FAFO-LAW-MONITOR-COMPLETE-GUIDE.md** (15 min read)
   - Complete documentation
   - Architecture diagrams
   - Full database schema
   - Step-by-step setup instructions
   - Troubleshooting guide

3. **NETWORKCHUCK-STYLE-SETUP.md**
   - Architecture comparison
   - NetworkChuck SSH + AI agent pattern
   - Session management explanation

### n8n Workflows

4. **fafo-law-monitor-networkchuck-style.json** ⭐ RECOMMENDED
   - Uses SSH to call OpenCode directly
   - Grok AI analysis
   - Session ID tracking
   - Clean architecture

5. **fafo-law-monitor-weekly-enhanced.json**
   - AI-enhanced version
   - Uses wrapper script approach

6. **fafo-law-monitor-weekly-backup.json**
   - Basic version without AI
   - Simple change detection only

### Database Scripts

7. **add_law_sources.sql**
   - Bulk insert 20+ law sources
   - Pre-configured Florida Chapter 39 statutes
   - DCF policies and court forms
   - Ready to run: `psql -U postgres -d fafo_db -f add_law_sources.sql`

8. **validate_law_sources.sh** (executable)
   - Validates law sources before insertion
   - Checks URL accessibility
   - Dry-run mode available
   - Run: `./validate_law_sources.sh --help`

### Wrapper Scripts

9. **fafo_gemini_wrapper.sh**
   - Alternative: Uses Gemini API instead of OpenCode
   - Direct curl to Google Gemini
   - For comparison/fallback

---

## Quick Start

### 1. Add Law Sources to Database

```bash
cd /home/hecker/Projects/web/mom/site/fafo-law-monitor-2026-01-05/

# Validate first (optional)
./validate_law_sources.sh --dry-run

# Insert into database
psql -U postgres -d fafo_db -f add_law_sources.sql
```

### 2. Import n8n Workflow

```bash
# Import this file to n8n:
fafo-law-monitor-networkchuck-style.json

# Update credentials:
- PostgreSQL: POSTGRES_CRED_ID
- SSH: SSH_CRED_ID
- Telegram: TELEGRAM_CRED_ID
```

### 3. Test OpenCode Connection

```bash
ssh -p 6969 dad@192.168.1.104 \
'cd /volume1/docker/home-it-department && \
 /var/services/homes/opencode/.opencode/bin/opencode run \
 --model opencode/grok-code "Return JSON: {\"test\": true}"'
```

### 4. Run Workflow

- Manually trigger in n8n UI
- Check execution logs
- Verify Telegram notification

---

## Project Structure

```
fafo-law-monitor-2026-01-05/
├── README.md                                  ← You are here
│
├── Documentation/
│   ├── QUICK-REFERENCE.md                     ← Start here
│   ├── FAFO-LAW-MONITOR-COMPLETE-GUIDE.md     ← Full docs
│   └── NETWORKCHUCK-STYLE-SETUP.md            ← Architecture
│
├── n8n Workflows/
│   ├── fafo-law-monitor-networkchuck-style.json  ⭐ Main workflow
│   ├── fafo-law-monitor-weekly-enhanced.json
│   └── fafo-law-monitor-weekly-backup.json
│
├── Database/
│   ├── add_law_sources.sql                    ← Bulk insert
│   └── validate_law_sources.sh                ← Validation tool
│
└── Scripts/
    └── fafo_gemini_wrapper.sh                 ← Gemini alternative
```

---

## Key Information

### SSH Connection (NAS)
- **Host:** 192.168.1.104
- **Port:** 6969
- **User:** dad

### OpenCode Binary Path
```
/var/services/homes/opencode/.opencode/bin/opencode
```

### Database Tables
- `fafo_law_sources` - Law sources to monitor
- `fafo_law_changes` - Detected changes with AI analysis

### Workflow Schedule
- **Trigger:** Monday at 6:00 AM
- **Cron:** `0 6 * * 1`

---

## Important Links

- **Florida Statutes:** http://www.leg.state.fl.us/statutes/
- **DCF Policies:** https://www.myflfamilies.com/service-programs/child-family-wellbeing/protective-services/
- **FAFO Website:** familyandfriendoutreach.com

---

## Next Steps After Setup

1. Monitor first workflow execution
2. Test approval flow via Telegram
3. Verify AI analysis quality
4. Adjust law source priorities if needed
5. Add more statutes to monitor

---

## Need Help?

- Quick commands: See `QUICK-REFERENCE.md`
- Full documentation: See `FAFO-LAW-MONITOR-COMPLETE-GUIDE.md`
- Troubleshooting: See complete guide section 6

---

**Created:** 2026-01-05
**Status:** Ready to deploy
**Version:** 1.0.0
