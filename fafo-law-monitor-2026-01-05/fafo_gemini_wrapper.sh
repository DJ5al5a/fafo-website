#!/bin/bash

# FAFO Gemini Law Analyzer - Direct API Wrapper
# Purpose: Call Gemini API directly for law analysis
# Location: /volume1/docker/home-it-department/fafo_gemini_wrapper.sh
# Usage: ./fafo_gemini_wrapper.sh SOURCE_ID OLD_CONTENT NEW_CONTENT

set -euo pipefail

# Configuration
GEMINI_API_KEY="${GEMINI_API_KEY:-AIzaSyDGuzoSmSOejyNXYN3JsAndjzltDO2nqrc}"
GEMINI_MODEL="gemini-2.5-flash"
TEMP_DIR="/tmp/fafo_gemini_$$"
OUTPUT_FILE="${TEMP_DIR}/analysis_output.json"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}[FAFO Gemini]${NC} $1" >&2; }
error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }
warn() { echo -e "${YELLOW}[WARNING]${NC} $1" >&2; }

# Check arguments
if [ $# -ne 3 ]; then
    error "Usage: $0 SOURCE_ID OLD_CONTENT NEW_CONTENT"
    exit 1
fi

SOURCE_ID="$1"
OLD_CONTENT="$2"
NEW_CONTENT="$3"

log "Analyzing law change: $SOURCE_ID using Gemini 2.5 Flash"

# Create temp directory
mkdir -p "$TEMP_DIR"
trap "rm -rf '$TEMP_DIR'" EXIT

# Build the analysis prompt
read -r -d '' ANALYSIS_PROMPT <<'PROMPT' || true
You are a legal analyst specializing in Florida child welfare law (Chapter 39). You are helping maintain the FAFO (Friends and Family Outreach) website, which provides plain-language guidance for families dealing with DCF investigations.

**Task:** Analyze the law change below and provide structured output for updating the FAFO website.

**Law Source:** {SOURCE_ID}

**OLD CONTENT:**
```
{OLD_CONTENT}
```

**NEW CONTENT:**
```
{NEW_CONTENT}
```

**Your Analysis Must Include:**

1. **Summary** (2-3 sentences, 8th grade reading level):
   - What changed in plain language?
   - Why does this matter for FAFO users (families dealing with DCF)?

2. **Severity Classification**:
   - "minor" = Typos, dates, formatting, administrative changes that don't affect families' rights or procedures
   - "major" = Changes to rights, requirements, procedures, timeframes that FAFO users need to know

3. **Affected FAFO Pages** (list all that need updates):
   - crisis-guide, know-your-rights, court-hearings, dcf-policies, state-laws, resources, reporting, templates, faq

4. **Impact Assessment** (5-10 sentences):
   - How does this change affect families?
   - What should FAFO users know?
   - Any new rights or responsibilities?
   - Any warnings or action items?

5. **Updated HTML Content** (ONLY if severity = "major"):
   - Generate HTML that explains the change in FAFO's style
   - Use plain language (8th grade reading level)
   - Include specific statute references
   - Match FAFO's tone: calm, firm, empowering
   - Use semantic HTML with classes: warning-box, important-update, etc.

6. **Recommendations**:
   - What FAFO should do with this information
   - Urgency level and timeline

**Output Format (JSON ONLY, no markdown, no explanations):**
{
  "summary": "Plain-language summary here",
  "severity": "minor or major",
  "affected_pages": ["page1", "page2"],
  "impact_assessment": "Detailed impact here",
  "updated_html": "HTML content here (or null if minor)",
  "recommendations": "What FAFO should do"
}

**CRITICAL RULES:**
- Output ONLY valid JSON, no markdown code fences, no explanations
- Use ONLY plain language (no legal jargon)
- Explain in terms families understand
- Focus on practical impact
- If minor change, set updated_html to null
- If major change, provide complete HTML section
PROMPT

# Replace placeholders
ANALYSIS_PROMPT="${ANALYSIS_PROMPT//\{SOURCE_ID\}/$SOURCE_ID}"
ANALYSIS_PROMPT="${ANALYSIS_PROMPT//\{OLD_CONTENT\}/$OLD_CONTENT}"
ANALYSIS_PROMPT="${ANALYSIS_PROMPT//\{NEW_CONTENT\}/$NEW_CONTENT}"

# Create JSON request for Gemini API
cat > "${TEMP_DIR}/request.json" <<EOF
{
  "contents": [{
    "parts": [{
      "text": $(echo "$ANALYSIS_PROMPT" | jq -Rs .)
    }]
  }],
  "generationConfig": {
    "temperature": 0.3,
    "topP": 0.95,
    "topK": 40,
    "maxOutputTokens": 8192
  }
}
EOF

log "Calling Gemini API..."

# Call Gemini API
if curl -s -X POST \
  "https://generativelanguage.googleapis.com/v1beta/models/${GEMINI_MODEL}:generateContent?key=${GEMINI_API_KEY}" \
  -H "Content-Type: application/json" \
  -d @"${TEMP_DIR}/request.json" \
  > "${TEMP_DIR}/api_response.json" 2>"${TEMP_DIR}/error.log"; then

    log "API call successful"

    # Extract the text content from Gemini response
    if jq -r '.candidates[0].content.parts[0].text' "${TEMP_DIR}/api_response.json" > "${TEMP_DIR}/raw_text.txt" 2>/dev/null; then
        # Clean up markdown code fences if present
        sed 's/^```json$//' "${TEMP_DIR}/raw_text.txt" | sed 's/^```$//' | grep -v '^$' > "$OUTPUT_FILE"

        # Validate JSON
        if command -v jq >/dev/null 2>&1; then
            if jq empty "$OUTPUT_FILE" 2>/dev/null; then
                log "Analysis complete and validated"
                cat "$OUTPUT_FILE"
                exit 0
            else
                error "Invalid JSON from Gemini"
                warn "Raw output:"
                cat "$OUTPUT_FILE" >&2
                exit 3
            fi
        else
            # No jq, just output
            cat "$OUTPUT_FILE"
            exit 0
        fi
    else
        error "Failed to extract text from API response"
        cat "${TEMP_DIR}/api_response.json" >&2
        exit 3
    fi
else
    error "Gemini API call failed"
    cat "${TEMP_DIR}/error.log" >&2
    exit 2
fi
