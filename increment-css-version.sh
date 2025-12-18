#!/bin/bash
# CSS Version Incrementer
# Automatically increments CSS version in all HTML files for cache busting

set -e

# Get current version from index.html
CURRENT=$(grep -oP 'styles\.css\?v=\K\d+' index.html | head -1)

if [ -z "$CURRENT" ]; then
    echo "❌ Error: Could not find current CSS version in index.html"
    exit 1
fi

NEW=$((CURRENT + 1))

echo "═══════════════════════════════════════════════════"
echo " CSS Version Increment"
echo "═══════════════════════════════════════════════════"
echo ""
echo "Current version: v=$CURRENT"
echo "New version: v=$NEW"
echo ""

# Update all HTML files
echo "Updating HTML files..."
for file in *.html; do
    if [ -f "$file" ]; then
        sed -i "s/styles\.css?v=$CURRENT/styles.css?v=$NEW/g" "$file"
        echo "  ✓ $file"
    fi
done

echo ""
echo "═══════════════════════════════════════════════════"
echo " ✅ CSS version updated to v=$NEW"
echo "═══════════════════════════════════════════════════"
echo ""
echo "Next steps:"
echo "1. Deploy files: ./deploy.sh"
echo "2. Test in incognito mode to verify CSS changes"
echo ""
