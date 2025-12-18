#!/bin/bash
# FAFO Backend Deployment Script
# Deploys backend API to Synology NAS

set -e  # Exit on any error

NAS_USER="dad"
NAS_HOST="192.168.1.104"
BACKEND_PATH="/volume1/web/backend"

echo "═══════════════════════════════════════════════════"
echo " FAFO Backend Deployment"
echo "═══════════════════════════════════════════════════"
echo ""

# Create backend directory if it doesn't exist
echo "📁 Creating backend directory..."
ssh $NAS_USER@$NAS_HOST "mkdir -p $BACKEND_PATH"
echo "  ✓ Directory created"

# Deploy backend files
echo ""
echo "📄 Deploying backend files..."
ssh $NAS_USER@$NAS_HOST "cat > $BACKEND_PATH/server.js" < backend/server.js
echo "  ✓ server.js"

ssh $NAS_USER@$NAS_HOST "cat > $BACKEND_PATH/package.json" < backend/package.json
echo "  ✓ package.json"

ssh $NAS_USER@$NAS_HOST "cat > $BACKEND_PATH/.env" < backend/.env
echo "  ✓ .env (contains API keys - keep secure!)"

# Install dependencies
echo ""
echo "📦 Installing dependencies..."
echo "  Running: npm install in $BACKEND_PATH"
ssh $NAS_USER@$NAS_HOST "cd $BACKEND_PATH && npm install"

# Check if PM2 is installed
echo ""
echo "🔍 Checking PM2 installation..."
if ssh $NAS_USER@$NAS_HOST "command -v pm2 >/dev/null 2>&1"; then
    echo "  ✓ PM2 is installed"

    # Check if server is already running
    if ssh $NAS_USER@$NAS_HOST "pm2 list | grep -q fafo-backend"; then
        echo ""
        echo "🔄 Restarting existing backend..."
        ssh $NAS_USER@$NAS_HOST "cd $BACKEND_PATH && pm2 restart fafo-backend"
    else
        echo ""
        echo "🚀 Starting backend with PM2..."
        ssh $NAS_USER@$NAS_HOST "cd $BACKEND_PATH && pm2 start server.js --name fafo-backend"
        ssh $NAS_USER@$NAS_HOST "pm2 save"
    fi

    # Show status
    echo ""
    echo "📊 Backend Status:"
    ssh $NAS_USER@$NAS_HOST "pm2 status fafo-backend"
else
    echo "  ⚠️  PM2 is not installed"
    echo ""
    echo "  To install PM2 globally:"
    echo "  ssh $NAS_USER@$NAS_HOST"
    echo "  npm install -g pm2"
    echo "  pm2 startup"
    echo ""
    echo "  For now, starting backend without PM2..."
    echo "  (This will run in the foreground - use PM2 for production)"
    ssh $NAS_USER@$NAS_HOST "cd $BACKEND_PATH && node server.js" &
fi

echo ""
echo "═══════════════════════════════════════════════════"
echo " ✅ Backend Deployment Complete!"
echo "═══════════════════════════════════════════════════"
echo ""
echo "Backend API running at: http://192.168.1.104:3000"
echo "Health check: http://192.168.1.104:3000/api/health"
echo ""
echo "Endpoints:"
echo "  POST /api/chat     - Chatbot API proxy"
echo "  POST /api/contact  - Contact form"
echo "  GET  /api/health   - Health check"
echo ""
