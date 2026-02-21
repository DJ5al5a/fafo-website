#!/bin/bash

# FAFO Website Production Build Script
# Minifies CSS/JS, increments versions, updates HTML references
# Usage: ./build-production.sh

set -e  # Exit on error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=================================="
echo "FAFO Production Build Script"
echo "=================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# =====================================================
# STEP 1: Check for required tools
# =====================================================

echo -e "${BLUE}[1/6] Checking for required tools...${NC}"

# Check for bun (preferred package manager per PAI preferences)
if ! command -v bun &> /dev/null; then
    echo -e "${YELLOW}Warning: bun not found. Will attempt to install minification tools with npx.${NC}"
    USE_NPX=true
else
    echo -e "${GREEN}✓ bun found${NC}"
    USE_NPX=false
fi

# =====================================================
# STEP 2: Minify CSS
# =====================================================

echo -e "\n${BLUE}[2/6] Minifying CSS (styles.css → styles.min.css)...${NC}"

if [ "$USE_NPX" = true ]; then
    # Use npx to run clean-css-cli without installing globally
    npx clean-css-cli -o styles.min.css styles.css
else
    # Use bun to run clean-css-cli
    bunx clean-css-cli -o styles.min.css styles.css
fi

# Get file sizes for comparison
ORIGINAL_CSS_SIZE=$(stat -f%z styles.css 2>/dev/null || stat -c%s styles.css 2>/dev/null || echo "unknown")
MINIFIED_CSS_SIZE=$(stat -f%z styles.min.css 2>/dev/null || stat -c%s styles.min.css 2>/dev/null || echo "unknown")

if [ "$ORIGINAL_CSS_SIZE" != "unknown" ] && [ "$MINIFIED_CSS_SIZE" != "unknown" ]; then
    REDUCTION=$((100 - (MINIFIED_CSS_SIZE * 100 / ORIGINAL_CSS_SIZE)))
    echo -e "${GREEN}✓ CSS minified: ${ORIGINAL_CSS_SIZE} bytes → ${MINIFIED_CSS_SIZE} bytes (${REDUCTION}% reduction)${NC}"
else
    echo -e "${GREEN}✓ CSS minified successfully${NC}"
fi

# =====================================================
# STEP 3: Minify JavaScript
# =====================================================

echo -e "\n${BLUE}[3/6] Minifying JavaScript (script.js → script.min.js)...${NC}"

if [ "$USE_NPX" = true ]; then
    # Use npx to run terser without installing globally
    npx terser script.js -o script.min.js --compress --mangle
else
    # Use bun to run terser
    bunx terser script.js -o script.min.js --compress --mangle
fi

# Get file sizes for comparison
ORIGINAL_JS_SIZE=$(stat -f%z script.js 2>/dev/null || stat -c%s script.js 2>/dev/null || echo "unknown")
MINIFIED_JS_SIZE=$(stat -f%z script.min.js 2>/dev/null || stat -c%s script.min.js 2>/dev/null || echo "unknown")

if [ "$ORIGINAL_JS_SIZE" != "unknown" ] && [ "$MINIFIED_JS_SIZE" != "unknown" ]; then
    REDUCTION=$((100 - (MINIFIED_JS_SIZE * 100 / ORIGINAL_JS_SIZE)))
    echo -e "${GREEN}✓ JS minified: ${ORIGINAL_JS_SIZE} bytes → ${MINIFIED_JS_SIZE} bytes (${REDUCTION}% reduction)${NC}"
else
    echo -e "${GREEN}✓ JS minified successfully${NC}"
fi

# =====================================================
# STEP 4: Increment version numbers
# =====================================================

echo -e "\n${BLUE}[4/6] Incrementing version numbers...${NC}"

# Extract current CSS version from any HTML file
CURRENT_CSS_VERSION=$(grep -o 'styles.css?v=[0-9]*' index.html | grep -o '[0-9]*' || echo "9")
CURRENT_JS_VERSION=$(grep -o 'script.js?v=[0-9]*' index.html | grep -o '[0-9]*' || echo "1")

# Increment versions
NEW_CSS_VERSION=$((CURRENT_CSS_VERSION + 1))
NEW_JS_VERSION=$((CURRENT_JS_VERSION + 1))

echo -e "  CSS version: ${CURRENT_CSS_VERSION} → ${NEW_CSS_VERSION}"
echo -e "  JS version: ${CURRENT_JS_VERSION} → ${NEW_JS_VERSION}"

# =====================================================
# STEP 5: Update HTML files with new versions
# =====================================================

echo -e "\n${BLUE}[5/6] Updating HTML files with new version numbers...${NC}"

# Get all HTML files (excluding chatbot-test.html)
HTML_FILES=$(find . -maxdepth 1 -name "*.html" ! -name "chatbot-test.html")

for file in $HTML_FILES; do
    # Update CSS reference to use minified version with new version
    sed -i.bak "s|styles\.css?v=[0-9]*|styles.min.css?v=${NEW_CSS_VERSION}|g" "$file"

    # Update JS reference to use minified version with new version
    sed -i.bak "s|script\.js?v=[0-9]*|script.min.js?v=${NEW_JS_VERSION}|g" "$file"

    # Also update if they're not using version numbers yet
    sed -i.bak "s|styles\.css\"|styles.min.css?v=${NEW_CSS_VERSION}\"|g" "$file"
    sed -i.bak "s|script\.js\"|script.min.js?v=${NEW_JS_VERSION}\"|g" "$file"

    # Remove backup files
    rm -f "${file}.bak"

    echo -e "${GREEN}  ✓ Updated $(basename "$file")${NC}"
done

# =====================================================
# STEP 6: Summary
# =====================================================

echo -e "\n${BLUE}[6/6] Build Summary${NC}"
echo "=================================="
echo -e "${GREEN}✓ Production build complete!${NC}"
echo ""
echo "Files created:"
echo "  • styles.min.css (v${NEW_CSS_VERSION})"
echo "  • script.min.css (v${NEW_JS_VERSION})"
echo ""
echo "HTML files updated: $(echo "$HTML_FILES" | wc -l)"
echo ""
echo "Next steps:"
echo "  1. Test the site locally to ensure everything works"
echo "  2. Deploy to NAS: ./deploy.sh"
echo "  3. Commit changes: git add . && git commit -m 'Build: Minify CSS/JS v${NEW_CSS_VERSION}'"
echo ""
echo "=================================="
