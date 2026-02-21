#!/bin/bash

# FAFO Law Sources Validation Script
# Purpose: Test URLs and validate law sources before adding to database
# Usage: ./validate_law_sources.sh [--check-urls] [--dry-run]
# Created: 2026-01-05

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Flags
CHECK_URLS=false
DRY_RUN=false

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --check-urls)
      CHECK_URLS=true
      shift
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --help)
      echo "Usage: $0 [--check-urls] [--dry-run]"
      echo ""
      echo "Options:"
      echo "  --check-urls   Test HTTP connectivity to all law source URLs"
      echo "  --dry-run      Show what would be inserted without actual insertion"
      echo "  --help         Show this help message"
      exit 0
      ;;
    *)
      echo -e "${RED}Unknown option: $1${NC}"
      exit 1
      ;;
  esac
done

# Logging functions
log() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }
header() { echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"; echo -e "${BLUE} $1${NC}"; echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"; }

# Law sources to validate
# Format: "TYPE|SOURCE_ID|TITLE|URL|TARGET_PAGE|TARGET_SECTION|PRIORITY"
LAW_SOURCES=(
  # Critical Statutes (Priority 10)
  "statute|FL_STAT_39.001|Florida Statute 39.001 - Definitions|http://www.leg.state.fl.us/statutes/index.cfm?App_mode=Display_Statute&URL=0000-0099/0039/Sections/0039.001.html|know-your-rights|definitions-section|10"
  "statute|FL_STAT_39.301|Florida Statute 39.301 - Shelter Hearings|http://www.leg.state.fl.us/statutes/index.cfm?App_mode=Display_Statute&URL=0000-0099/0039/Sections/0039.301.html|court-hearings|shelter-hearing|10"
  "statute|FL_STAT_39.401|Florida Statute 39.401 - Taking Children into Custody|http://www.leg.state.fl.us/statutes/index.cfm?App_mode=Display_Statute&URL=0000-0099/0039/Sections/0039.401.html|crisis-guide|custody-rights|10"
  "statute|FL_STAT_39.801|Florida Statute 39.801 - Termination of Parental Rights|http://www.leg.state.fl.us/statutes/index.cfm?App_mode=Display_Statute&URL=0000-0099/0039/Sections/0039.801.html|know-your-rights|tpr-section|10"

  # High Priority (8-9)
  "statute|FL_STAT_39.521|Florida Statute 39.521 - Case Plan Development|http://www.leg.state.fl.us/statutes/index.cfm?App_mode=Display_Statute&URL=0000-0099/0039/Sections/0039.521.html|dcf-policies|case-plan|8"
  "statute|FL_STAT_39.701|Florida Statute 39.701 - Judicial Review|http://www.leg.state.fl.us/statutes/index.cfm?App_mode=Display_Statute&URL=0000-0099/0039/Sections/0039.701.html|court-hearings|review-hearings|9"
  "statute|FL_STAT_39.502|Florida Statute 39.502 - Rights of Parents and Children|http://www.leg.state.fl.us/statutes/index.cfm?App_mode=Display_Statute&URL=0000-0099/0039/Sections/0039.502.html|know-your-rights|parent-child-rights|9"

  # DCF Policies (7-8)
  "policy|DCF_CFOP_175-1|CFOP 175-1 - Safety Methodology|https://www.myflfamilies.com/sites/default/files/2022-07/CFOP%20175-1%20Safety%20Methodology.pdf|crisis-guide|safety-assessment|8"
  "policy|DCF_CFOP_175-43|CFOP 175-43 - Family Functioning Assessment|https://www.myflfamilies.com/sites/default/files/2022-07/CFOP%20175-43%20Family%20Functioning%20Assessment.pdf|dcf-policies|assessments|7"

  # Forms (6-7)
  "form|FORM_8.201|Florida Form 8.201 - Dependency Petition|https://www.flcourts.gov/content/download/219474/file/8.201.pdf|templates|dependency-petition|6"
  "form|FORM_8.305|Florida Form 8.305 - Shelter Petition|https://www.flcourts.gov/content/download/219475/file/8.305.pdf|templates|shelter-petition|7"
)

# Validation results
TOTAL_SOURCES=${#LAW_SOURCES[@]}
VALID_SOURCES=0
INVALID_SOURCES=0
ACCESSIBLE_URLS=0
INACCESSIBLE_URLS=0

header "FAFO Law Sources Validation"

log "Found $TOTAL_SOURCES law sources to validate"
echo ""

# Function to check URL accessibility
check_url() {
  local url="$1"
  local source_id="$2"

  if $CHECK_URLS; then
    if curl -s -f -L --max-time 10 --head "$url" > /dev/null 2>&1; then
      echo -e "  ${GREEN}✓${NC} URL accessible"
      ((ACCESSIBLE_URLS++))
      return 0
    else
      echo -e "  ${RED}✗${NC} URL not accessible (HTTP error or timeout)"
      ((INACCESSIBLE_URLS++))
      return 1
    fi
  else
    echo -e "  ${BLUE}⊘${NC} URL check skipped (use --check-urls to enable)"
  fi
}

# Validate each source
for source in "${LAW_SOURCES[@]}"; do
  IFS='|' read -r TYPE SOURCE_ID TITLE URL TARGET_PAGE TARGET_SECTION PRIORITY <<< "$source"

  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${GREEN}Source:${NC} $SOURCE_ID"
  echo -e "${GREEN}Title:${NC} $TITLE"
  echo -e "${GREEN}Type:${NC} $TYPE"
  echo -e "${GREEN}Priority:${NC} $PRIORITY"
  echo -e "${GREEN}Target:${NC} $TARGET_PAGE → $TARGET_SECTION"
  echo -e "${GREEN}URL:${NC} $URL"

  # Validate fields
  VALID=true

  if [[ -z "$SOURCE_ID" ]]; then
    error "  Missing source_id"
    VALID=false
  fi

  if [[ -z "$TITLE" ]]; then
    error "  Missing title"
    VALID=false
  fi

  if [[ -z "$URL" ]]; then
    error "  Missing URL"
    VALID=false
  fi

  if [[ ! "$PRIORITY" =~ ^[1-9]$|^10$ ]]; then
    error "  Invalid priority (must be 1-10): $PRIORITY"
    VALID=false
  fi

  if [[ ! "$TYPE" =~ ^(statute|policy|form|rule)$ ]]; then
    warn "  Unusual source type: $TYPE"
  fi

  # Check URL if requested
  if [[ "$VALID" == true ]]; then
    check_url "$URL" "$SOURCE_ID"

    if [[ "$VALID" == true ]]; then
      ((VALID_SOURCES++))
      echo -e "  ${GREEN}✓ VALID${NC}"
    fi
  else
    ((INVALID_SOURCES++))
    echo -e "  ${RED}✗ INVALID${NC}"
  fi

  echo ""
done

# Summary
header "Validation Summary"
echo -e "${GREEN}Valid sources:${NC} $VALID_SOURCES / $TOTAL_SOURCES"
echo -e "${RED}Invalid sources:${NC} $INVALID_SOURCES / $TOTAL_SOURCES"

if $CHECK_URLS; then
  echo -e "${GREEN}Accessible URLs:${NC} $ACCESSIBLE_URLS / $TOTAL_SOURCES"
  echo -e "${RED}Inaccessible URLs:${NC} $INACCESSIBLE_URLS / $TOTAL_SOURCES"
fi

echo ""

# Exit status
if [[ $INVALID_SOURCES -gt 0 ]]; then
  error "Validation failed: $INVALID_SOURCES invalid sources found"
  exit 1
fi

if $CHECK_URLS && [[ $INACCESSIBLE_URLS -gt 0 ]]; then
  warn "Some URLs are not accessible, but validation passed"
  warn "This may be due to network issues or temporary unavailability"
fi

log "All sources validated successfully!"

if $DRY_RUN; then
  echo ""
  header "Dry Run - SQL Preview"
  echo "-- The following SQL would be executed:"
  echo ""
  echo "BEGIN;"
  echo ""

  for source in "${LAW_SOURCES[@]}"; do
    IFS='|' read -r TYPE SOURCE_ID TITLE URL TARGET_PAGE TARGET_SECTION PRIORITY <<< "$source"

    echo "INSERT INTO fafo_law_sources ("
    echo "  source_type, source_id, title, url,"
    echo "  target_page, target_section, priority, active"
    echo ") VALUES ("
    echo "  '$TYPE', '$SOURCE_ID', '$TITLE',"
    echo "  '$URL',"
    echo "  '$TARGET_PAGE', '$TARGET_SECTION', $PRIORITY, true"
    echo ");"
    echo ""
  done

  echo "COMMIT;"
  echo ""
  log "Dry run complete. No changes made to database."
fi

exit 0
