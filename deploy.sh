#!/bin/bash
# FAFO Website Deployment Script
# Deploys all website files to Synology NAS

set -e  # Exit on any error

NAS_USER="dad"
NAS_HOST="192.168.1.104"
WEB_ROOT="/volume1/web"

echo "═══════════════════════════════════════════════════"
echo " FAFO Website Deployment"
echo "═══════════════════════════════════════════════════"
echo ""

# Deploy HTML files
echo "📄 Deploying HTML files..."
for file in *.html; do
    if [ -f "$file" ]; then
        ssh $NAS_USER@$NAS_HOST "cat > $WEB_ROOT/$file" < "$file"
        echo "  ✓ $file"
    fi
done

# Deploy CSS
echo ""
echo "🎨 Deploying CSS..."
ssh $NAS_USER@$NAS_HOST "cat > $WEB_ROOT/styles.css" < styles.css
echo "  ✓ styles.css"

ssh $NAS_USER@$NAS_HOST "cat > $WEB_ROOT/chatbot-styles.css" < chatbot-styles.css
echo "  ✓ chatbot-styles.css"

# Deploy JavaScript
echo ""
echo "⚙️  Deploying JavaScript..."
ssh $NAS_USER@$NAS_HOST "cat > $WEB_ROOT/script.js" < script.js
echo "  ✓ script.js"

ssh $NAS_USER@$NAS_HOST "cat > $WEB_ROOT/chatbot.js" < chatbot.js
echo "  ✓ chatbot.js"

ssh $NAS_USER@$NAS_HOST "cat > $WEB_ROOT/chatbot-worker.js" < chatbot-worker.js
echo "  ✓ chatbot-worker.js"

# Deploy chatbot config (contains API key - be careful!)
echo ""
echo "🔑 Deploying chatbot config..."
ssh $NAS_USER@$NAS_HOST "cat > $WEB_ROOT/chatbot-config.js" < chatbot-config.js
echo "  ✓ chatbot-config.js"

# Verify deployment
echo ""
echo "🔍 Verifying deployment..."
FILE_COUNT=$(ssh $NAS_USER@$NAS_HOST "ls $WEB_ROOT/*.html 2>/dev/null | wc -l")
echo "  ✓ Found $FILE_COUNT HTML files on NAS"

# Display timestamp
TIMESTAMP=$(ssh $NAS_USER@$NAS_HOST "date '+%Y-%m-%d %H:%M:%S'")
echo ""
echo "═══════════════════════════════════════════════════"
echo " ✅ Deployment Complete!"
echo " Server Time: $TIMESTAMP"
echo "═══════════════════════════════════════════════════"
echo ""
echo "🌐 Visit: https://familyandfriendoutreach.com"
echo ""
