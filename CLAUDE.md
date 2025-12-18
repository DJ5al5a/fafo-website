# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**FAFO (Friends and Family Outreach)** - A Florida-specific advocacy website providing educational resources for families dealing with the Department of Children and Families (DCF) child welfare system.

**Critical Context:** This is NOT a law firm. All content is educational only. Every page must maintain legal disclaimers stating FAFO does not provide legal advice.

## Architecture

This is a **pure static website** with no build process:

### Frontend Structure
- **12 HTML pages:** Home, Know Your Rights, DCF Policies, State Laws, Court Hearings, Reporting, Resources, FAQ, Court Checklist, Templates, Contact, Legal Disclaimer
- **Single CSS file:** `styles.css` (~18KB) with CSS variables for light/dark theming
- **Single JS file:** `script.js` (~3.5KB) for navigation, accordions, and dark mode toggle
- **AI Chatbot:** Client-side chatbot with server-configured API keys (Gemini + OpenRouter)
  - `chatbot.js` - UI logic and message handling
  - `chatbot-worker.js` - API communication layer
  - `chatbot-styles.css` - Chatbot styling with dark mode
  - `chatbot-config.js` - Server-side API keys (NOT in git, see .gitignore)
- **Google Analytics 4** tracking (Measurement ID: G-CJ0GGCZFM8)
- **Domain:** https://familyandfriendoutreach.com
- **Hosting:** Self-hosted on Synology NAS via Cloudflare Tunnel

### Dark Mode Support
- User-selectable theme toggle in navigation
- Theme persists via localStorage
- All colors use CSS variables that adapt to `[data-theme="dark"]`
- Toggle button switches between 🌙 Dark Mode / ☀️ Light Mode

### Backend (Optional/Unused)
- Node.js/Express server in `/backend` directory
- Designed for secure contact form submissions
- **Currently not deployed** - site uses Google Forms embedded iframe instead

## Development Workflow

### Local Testing

```bash
# Option 1: Open directly in browser
open index.html

# Option 2: Python HTTP server
python3 -m http.server 8000
# Visit http://localhost:8000
```

### Deploy to Production (Synology NAS)

**NAS Details:**
- IP: 192.168.1.104
- SSH User: dad
- Web root: `/volume1/web/`
- Port: 3535 (HTTP), 6565 (HTTPS)

**Deployment Commands:**

```bash
# Deploy all core files
scp *.html *.css script.js dad@192.168.1.104:/volume1/web/

# Deploy chatbot files (including config with API keys)
scp chatbot*.js chatbot*.css dad@192.168.1.104:/volume1/web/

# Verify deployment
ssh dad@192.168.1.104 "ls -lh /volume1/web/*.{html,css,js}"
```

**CRITICAL:** Always deploy `chatbot-config.js` - it contains production API keys and must be on the server but NEVER committed to git.

### CSS Version Management

**Critical:** Browser caching requires versioning CSS file references in HTML.

```bash
# Current version: v=7
# When making CSS changes:

# 1. Edit styles.css
# 2. Increment version in ALL HTML files
for file in *.html; do
    sed -i 's/styles\.css?v=7/styles.css?v=8/g' "$file"
done

# 3. Deploy both CSS and HTML files
ssh dad@192.168.1.104 'cat > /volume1/web/styles.css' < styles.css
for file in *.html; do
    ssh dad@192.168.1.104 'cat > /volume1/web/'"$file"'' < "$file"
done
```

**Current CSS version:** `v=7`

## Critical Design Requirements

### Content Tone & Style (NON-NEGOTIABLE)
- **Calm, firm, empowering** - never violent or threatening
- **Plain language** - no legal jargon (8th grade reading level)
- **Florida-specific** - all laws/procedures cite Florida Chapter 39
- **Source-based** - link only to official government sources
- **Lived experience** - grounded in real family experiences
- **No emojis** unless explicitly requested by user

### Legal Disclaimers (MANDATORY)
Every page footer must include:
- "FAFO is not a law firm and does not provide legal advice"
- "Information on this site is for educational purposes only"
- "Consult a licensed attorney for legal advice about your specific situation"

### Color & Theme System

**Light Mode Variables:**
```css
--primary-color: #1e3a8a (justice blue)
--secondary-color: #b8860b (justice gold)
--text-dark: #1f2937 (dark gray text)
--text-light: #6b7280 (light gray text)
--bg-white: #ffffff (white backgrounds)
--bg-light: #f8fafc (light gray backgrounds)
```

**Dark Mode Variables:**
```css
--primary-color: #3b82f6 (brighter blue)
--secondary-color: #d4a017 (brighter gold)
--text-dark: #e5e7eb (light gray text)
--text-light: #9ca3af (medium gray text)
--bg-white: #111827 (dark backgrounds)
--bg-light: #1f2937 (lighter dark backgrounds)
```

**IMPORTANT:** Never use hardcoded colors in HTML or CSS. Always use CSS variables so dark mode works correctly.

### Mobile Responsiveness
- Mobile-first design
- Breakpoints: 768px (tablet), 480px (phone)
- Hamburger menu on mobile with `max-height: 700px` for full menu
- All navigation items must be visible on mobile

## Key Pages & Content

### Know Your Rights (know-your-rights.html)
**Most critical page.** Includes:
- Constitutional rights (4th, 5th, 14th Amendments)
- **Legal Terms Section** with definitions for: ADMIT, CONSENT, DENY, ABANDON/ABANDONMENT, IMMEDIATE DANGER/THREAT
- Strong warnings: "Everything you say to DCF WILL be used against you"
- "DCF workers are NOT your friends, no matter what they say"

### Court Hearings (court-hearings.html)
**High priority.** Prominently features:
- "10-day waiver trap" warning (waiving right to 10-day notice for hearings)
- All hearing types explained (Shelter, Arraignment, Adjudicatory, Disposition, etc.)
- Court pressure tactics
- What to expect at each hearing type

### Resources (resources.html)
- Legal aid organizations (statewide and regional)
- **ADA Accommodations section** for disability services in court
- **DCF Oversight & Watchdog Organizations** including:
  - OPPAGA (Florida Legislature's watchdog)
  - DCF Office of Inspector General
  - DCF Accountability Portal
  - Florida Auditor General
  - Federal ACF oversight
- Court-appointed attorney information

### FAQ (faq.html)
- 13 comprehensive questions in accordion format
- Organized in 4 sections: Initial DCF Contact, Court Process, Rights & Documentation, Case Plan
- Cross-linked to other pages

### Court Checklist (court-checklist.html)
- Complete court preparation guide
- What to bring, dress code, courtroom behavior
- Day-before and morning-of checklists

### Templates (templates.html)
- 5 printable templates: Visit Log, Communication Log, Case Plan Tracker, Hearing Notes, Wallet-sized Rights Card
- All print-ready with clear instructions

## Chatbot Architecture

### API Key Configuration (Server-Side)
The chatbot uses **server-configured API keys** stored in `chatbot-config.js`:

```javascript
const CHATBOT_CONFIG = {
    gemini_api_key: 'AIzaSy...',
    openrouter_api_key: 'sk-or-v1-...',
    auto_initialize: true
};

if (CHATBOT_CONFIG.auto_initialize) {
    if (typeof setAPIKey === 'function') {
        setAPIKey(CHATBOT_CONFIG.gemini_api_key, 'gemini');
        setAPIKey(CHATBOT_CONFIG.openrouter_api_key, 'openrouter');
    }
}
```

**Critical:** This file loads AFTER `chatbot-worker.js` (which defines `setAPIKey()`) to avoid timing issues.

### Script Loading Order
HTML files must load chatbot scripts in this exact order:
```html
<link rel="stylesheet" href="chatbot-styles.css">
<script src="chatbot-config.js"></script>
<script src="chatbot-worker.js"></script>
<script src="chatbot.js"></script>
```

### Chatbot Features
- **Auto-loaded API keys** - No user configuration needed
- **No settings UI** - Keys are server-configured only
- **Dual API support** - Gemini (primary) + OpenRouter (backup)
- **Model:** `google/gemini-2.0-flash-exp:free` on OpenRouter
- **Suggested prompts:** Quick-start questions for users
- **Dark mode compatible** - Uses same CSS variables as main site

### System Prompt
The chatbot is configured with comprehensive knowledge of:
- Florida Chapter 39 statutes
- Constitutional rights (4th, 5th, 14th Amendments)
- DCF investigation process
- Court hearings and timelines
- Legal terms definitions
- Website page content and links

It ALWAYS reminds users it's not a lawyer and to consult an attorney.

## Common Issues & Fixes

### Chatbot API Keys Not Loading
**Symptom:** Users see "API Key Required" message
**Cause:** Script loading order issue - `setAPIKey()` not defined when config runs
**Fix:** Verify `chatbot-worker.js` loads before `chatbot-config.js` in HTML (line order matters!)

### Chatbot Settings Button Removed
**Important:** The chatbot has NO settings UI. API keys are server-configured only. If you see settings UI, it's outdated code.

### CSS/Dark Mode Not Displaying Correctly

**Root cause:** Hardcoded colors instead of CSS variables

**Prevention:**
- Always use `var(--variable-name)` for colors
- Never use hardcoded hex colors like `#ffffff`, `color: white`, `background: white`
- Test in both light and dark mode before deploying

**Recent fixes applied:**
- All info boxes, warning boxes, important notices use `rgba()` with low opacity
- Footer uses `var(--footer-bg)`, `var(--footer-text)`, `var(--footer-text-dim)`
- Navigation uses `var(--nav-text)`
- Accordion headers use `var(--text-dark)`

### CSS Not Updating on Live Site

**Problem:** Browser caches CSS aggressively.

**Solutions:**
1. Increment version parameter: `styles.css?v=X` → `styles.css?v=X+1`
2. Update version in ALL 12 HTML files using sed command
3. Deploy both CSS and all HTML files
4. Test in incognito/private browsing mode
5. Hard refresh: Ctrl+Shift+R (Windows/Linux) or Cmd+Shift+R (Mac)

### Mobile Menu Issues

**Contact Us Button Wrapping:**
```css
.nav-menu .btn-primary {
    white-space: nowrap;
    min-width: 120px;
}
```

**Menu Text Invisible (white on white):**
```css
@media (max-width: 768px) {
    .nav-menu a {
        color: var(--text-dark) !important;
    }
}
```

**Menu Cutting Off Items:**
```css
.nav-menu.active {
    max-height: 700px; /* Was 500px */
}
```

## Adding New Content

### Creating a New Page

1. Copy structure from existing page
2. Update `<title>` and meta description
3. Include Google Analytics tracking code in `<head>`
4. Add page to navigation in ALL 12 HTML files:
```html
<li><a href="new-page.html">New Page</a></li>
```
5. Include footer with legal disclaimers
6. Test mobile responsive layout
7. Deploy to NAS

### Adding External Links

**ONLY link to official sources:**
- Florida Statutes: `https://www.leg.state.fl.us/statutes/`
- Florida Courts: `https://www.flcourts.gov/`
- Florida DCF: `https://www.myflfamilies.com/`
- Legal aid organizations (verified official websites)

**Never** link to:
- Personal blogs
- Opinion sites
- Unofficial resources
- Commercial services

### Creating Accordion Sections

```html
<div class="accordion-item">
    <button class="accordion-header">
        <span>Question or section title?</span>
        <span class="accordion-icon">▼</span>
    </button>
    <div class="accordion-content">
        <div class="accordion-content-inner">
            <p>Content goes here...</p>
        </div>
    </div>
</div>
```

## Deployment Infrastructure

### Production Setup
- **Frontend Host:** Synology NAS (192.168.1.104)
- **Web Server:** Synology Web Station v4.3.0
- **HTTP Port:** 3535
- **HTTPS Port:** 6565
- **Document Root:** `/volume1/web/`

### Cloudflare Tunnel Configuration
- **Domain:** familyandfriendoutreach.com
- **Service Type:** HTTP
- **Internal URL:** 192.168.1.104:3535
- **No TLS Verify:** Enabled
- **SSL:** Automatic via Cloudflare proxy (orange cloud)

### Backup Strategy
CSS backups exist on NAS at `/volume1/web/styles.css.backup`

## Analytics & Tracking

**Google Analytics 4:**
- Measurement ID: G-CJ0GGCZFM8
- Tracking code in `<head>` of all 12 pages
- Access: https://analytics.google.com/

**Key Metrics to Monitor:**
- Total visitors (monthly growth)
- Most viewed pages (which resources help most)
- Traffic sources (how people find the site)
- Geographic distribution (reaching all Florida counties?)
- Mobile vs desktop usage (optimize mobile experience)

## Social Media

**X/Twitter:** @amotherscorned
- Link in contact page (prominent button with X icon)
- Link in all page footers
- SVG icon embedded inline

## File Organization

```
/home/hecker/Projects/MOM/Site/
├── *.html (12 files)
├── styles.css (18KB, current version v=7)
├── script.js (3.5KB)
├── README.md
├── CLAUDE.md (this file)
├── GOOGLE-ANALYTICS-SETUP.md
├── ENHANCEMENTS-SUMMARY.md
├── COMPLETE-IMPLEMENTATION-GUIDE.md
├── DEPLOYMENT-SUMMARY.md
├── FINAL-STATUS.md
├── .claude/
│   └── agents/
│       └── fafo-agent.md (specialized agent for this project)
└── backend/ (optional, not deployed)
    ├── server.js
    ├── package.json
    └── .env.example
```

## Specialized Agent

**FAFO Website Manager Agent** located at `.claude/agents/fafo-agent.md`

Capabilities:
- Content creation with proper tone and disclaimers
- Deployment procedures
- CSS/dark mode troubleshooting
- Analytics monitoring
- Common issue resolution

Use when working on FAFO-specific tasks to ensure compliance with content guidelines and legal requirements.

## Documentation Files

- **README.md** - Project overview and basic usage
- **CLAUDE.md** - This file (comprehensive development guide)
- **GOOGLE-ANALYTICS-SETUP.md** - GA4 setup instructions
- **DEPLOYMENT-SUMMARY.md** - Technical infrastructure details
- **FINAL-STATUS.md** - Current status and next steps
- **ENHANCEMENTS-SUMMARY.md** - Summary of features added

## Maintenance Schedule

- **Weekly:** Check Google Analytics for traffic patterns
- **Bi-weekly:** Monitor Google Forms submissions
- **Quarterly:** Verify all external links still work
- **Annually:** Review legal information for statute changes
- **As needed:** Update resource contact information

## Important Constraints

### What to AVOID
- Generic development practices (already understood)
- Obvious instructions
- Making up information about "common tasks" or "tips"
- Adding features not explicitly requested
- Over-engineering simple changes
- Creating documentation files proactively (only when asked)
- Using emojis unless explicitly requested

### What to MAINTAIN
- Legal disclaimers on every page
- Plain language (no jargon)
- Florida-specific content only
- Official source links only
- Calm, firm, empowering tone
- Dark mode compatibility for all colors
- Mobile-first responsive design

---

**Last Updated:** December 15, 2024
**Current Status:** Site fully operational with 12 pages, dark mode support, comprehensive resources
**CSS Version:** v=7
