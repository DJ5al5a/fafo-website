#!/bin/bash

# Script to add schema.org structured data and Open Graph tags to all FAFO HTML pages
# This preserves existing content and adds SEO enhancements

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=========================================="
echo "Adding Schema.org Data to FAFO Pages"
echo "=========================================="
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Function to add schema to a standard content page
add_standard_schema() {
    local file="$1"
    local page_name="$2"
    local description="$3"
    local page_type="${4:-WebPage}"  # Default to WebPage

    echo -e "${BLUE}Processing: $file${NC}"

    # Check if schema already exists
    if grep -q "schema.org" "$file"; then
        echo -e "${YELLOW}  ⚠ Schema already exists, skipping${NC}"
        return
    fi

    # Create temp file with schema addition
    awk -v page_name="$page_name" -v description="$description" -v page_type="$page_type" -v file="$file" '
    /<title>/ {
        print
        print ""
        print "    <!-- Canonical URL -->"
        printf "    <link rel=\"canonical\" href=\"https://familyandfriendoutreach.com/%s\">\n", file
        print ""
        print "    <!-- Open Graph / Facebook -->"
        print "    <meta property=\"og:type\" content=\"article\">"
        printf "    <meta property=\"og:url\" content=\"https://familyandfriendoutreach.com/%s\">\n", file
        printf "    <meta property=\"og:title\" content=\"%s - FAFO\">\n", page_name
        printf "    <meta property=\"og:description\" content=\"%s\">\n", description
        print "    <meta property=\"og:site_name\" content=\"familyandfriendoutreach\">"
        print ""
        print "    <!-- Twitter -->"
        print "    <meta property=\"twitter:card\" content=\"summary_large_image\">"
        printf "    <meta property=\"twitter:url\" content=\"https://familyandfriendoutreach.com/%s\">\n", file
        printf "    <meta property=\"twitter:title\" content=\"%s - FAFO\">\n", page_name
        printf "    <meta property=\"twitter:description\" content=\"%s\">\n", description
        print "    <meta property=\"twitter:site\" content=\"@amotherscorned\">"
        print ""
        print "    <!-- Schema.org structured data -->"
        print "    <script type=\"application/ld+json\">"
        print "    {"
        print "      \"@context\": \"https://schema.org\","
        print "      \"@type\": \"" page_type "\","
        printf "      \"@id\": \"https://familyandfriendoutreach.com/%s#webpage\",\n", file
        printf "      \"url\": \"https://familyandfriendoutreach.com/%s\",\n", file
        printf "      \"name\": \"%s - FAFO\",\n", page_name
        printf "      \"description\": \"%s\",\n", description
        print "      \"isPartOf\": {"
        print "        \"@id\": \"https://familyandfriendoutreach.com/#website\""
        print "      },"
        print "      \"about\": {"
        print "        \"@id\": \"https://familyandfriendoutreach.com/#organization\""
        print "      },"
        print "      \"datePublished\": \"2024-12-01\","
        print "      \"dateModified\": \"2025-01-03\","
        print "      \"inLanguage\": \"en-US\","
        print "      \"publisher\": {"
        print "        \"@id\": \"https://familyandfriendoutreach.com/#organization\""
        print "      }"
        print "    }"
        print "    </script>"
        next
    }
    { print }
    ' "$file" > "${file}.tmp" && mv "${file}.tmp" "$file"

    echo -e "${GREEN}  ✓ Schema added${NC}"
}

# Add schema to each page with specific descriptions
echo -e "${BLUE}[1/14] Crisis Guide${NC}"
add_standard_schema "crisis-guide.html" "Crisis Guide" "Emergency action steps for families facing DCF investigation, removal, or shelter hearing. Know what to do RIGHT NOW to protect your rights and your children."

echo -e "\n${BLUE}[2/14] Know Your Rights${NC}"
add_standard_schema "know-your-rights.html" "Know Your Rights" "Constitutional rights for families in Florida child welfare cases. Understand your Fourth Amendment rights, due process protections, and legal definitions."

echo -e "\n${BLUE}[3/14] Court Hearings${NC}"
add_standard_schema "court-hearings.html" "Court Hearings Guide" "Complete guide to Florida dependency court hearings: shelter hearings, arraignment, adjudication, disposition, and TPR. Avoid the 10-day waiver trap."

echo -e "\n${BLUE}[4/14] Court Checklist${NC}"
add_standard_schema "court-checklist.html" "Court Preparation Checklist" "Essential checklist for preparing for dependency court hearings in Florida. What to bring, what to expect, and how to present yourself."

echo -e "\n${BLUE}[5/14] DCF Policies${NC}"
add_standard_schema "dcf-policies.html" "DCF Policies & Procedures" "Florida Department of Children and Families investigation procedures, timelines, and administrative rules explained in plain language."

echo -e "\n${BLUE}[6/14] State Laws${NC}"
add_standard_schema "state-laws.html" "Florida State Laws" "Florida Chapter 39 statutes explained in plain language. Understand the laws governing child welfare cases in Florida."

echo -e "\n${BLUE}[7/14] Resources${NC}"
add_standard_schema "resources.html" "Legal Resources & Support" "Legal aid organizations, disability accommodations, DCF oversight agencies, and support resources for Florida families."

echo -e "\n${BLUE}[8/14] Reporting${NC}"
add_standard_schema "reporting.html" "Reporting & Accountability" "How to file complaints against DCF, report misconduct to oversight agencies, and hold the system accountable."

echo -e "\n${BLUE}[9/14] Templates${NC}"
add_standard_schema "templates.html" "Printable Templates" "Free printable tracking logs, court checklists, and rights cards for families navigating Florida child welfare cases."

echo -e "\n${BLUE}[10/14] FAQ${NC}"
# FAQ page uses FAQPage schema
echo -e "${BLUE}Processing: faq.html${NC}"
if grep -q "schema.org" "faq.html"; then
    echo -e "${YELLOW}  ⚠ Schema already exists, skipping${NC}"
else
    # For FAQ, we'll add FAQPage schema (more complex, would need to extract Q&A pairs)
    add_standard_schema "faq.html" "Frequently Asked Questions" "Common questions about Florida child welfare cases, DCF investigations, court proceedings, and parental rights answered." "FAQPage"
    echo -e "${GREEN}  ✓ FAQPage schema added (Note: Could be enhanced with individual Q&A pairs)${NC}"
fi

echo -e "\n${BLUE}[11/14] Contact${NC}"
add_standard_schema "contact.html" "Contact Us" "Contact familyandfriendoutreach (FAFO) for support and guidance during your child welfare case. We're here to listen and help."

echo -e "\n${BLUE}[12/14] Privacy Policy${NC}"
add_standard_schema "privacy-policy.html" "Privacy Policy" "FAFO privacy policy: zero tracking, no analytics, no cookies. Your privacy is protected when you visit our site."

echo -e "\n${BLUE}[13/14] Legal Disclaimer${NC}"
add_standard_schema "legal-disclaimer.html" "Legal Disclaimer" "FAFO is not a law firm and does not provide legal advice. Important legal disclaimers and limitations."

echo -e "\n${BLUE}[14/14] Template Pages${NC}"
# Skip template pages that aren't main content (court-notes, communication-log, visit-log)
echo -e "${YELLOW}  ⚠ Skipping printable template pages (court-notes, communication-log, visit-log)${NC}"

echo ""
echo "=========================================="
echo -e "${GREEN}✓ Schema.org data added to all pages!${NC}"
echo "=========================================="
echo ""
echo "What was added to each page:"
echo "  • Canonical URL tag"
echo "  • Open Graph tags (Facebook sharing)"
echo "  • Twitter Card tags"
echo "  • Schema.org JSON-LD structured data"
echo ""
echo "Next steps:"
echo "  1. Test with Google Rich Results Test: https://search.google.com/test/rich-results"
echo "  2. Test with Facebook Sharing Debugger: https://developers.facebook.com/tools/debug/"
echo "  3. Rebuild for production: ./build-production.sh"
echo "  4. Deploy to NAS: ./deploy.sh"
echo ""
