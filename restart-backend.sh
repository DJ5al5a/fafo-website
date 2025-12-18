#!/bin/bash
# Restart FAFO Backend on Synology NAS

NAS_USER="dad"
NAS_HOST="192.168.1.104"
NODE_PATH="/volume1/@appstore/Node.js_v20/usr/local/bin/node"
BACKEND_DIR="/volume1/web/backend"

echo "═══════════════════════════════════════════════════"
echo " Restarting FAFO Backend"
echo "═══════════════════════════════════════════════════"
echo ""

# Find and kill old backend process
echo "🔍 Checking for running backend..."
PID=$(ssh $NAS_USER@$NAS_HOST "ps aux | grep 'node.*server.js' | grep -v grep | grep -v Synology | awk '{print \$2}'")

if [ -n "$PID" ]; then
    echo "  Found backend process: PID $PID"
    echo "  Stopping old backend..."
    ssh -t $NAS_USER@$NAS_HOST "sudo kill $PID"
    sleep 2
    echo "  ✓ Old backend stopped"
else
    echo "  No backend process found (okay if first run)"
fi

# Start new backend
echo ""
echo "🚀 Starting backend with updated code..."
ssh $NAS_USER@$NAS_HOST "cd $BACKEND_DIR && $NODE_PATH server.js > /tmp/fafo-backend.log 2>&1 &"

# Wait for startup
echo "  Waiting for backend to start..."
sleep 3

# Test health endpoint
echo ""
echo "🏥 Testing backend health..."
HEALTH=$(ssh $NAS_USER@$NAS_HOST "curl -s http://localhost:3000/api/health" | grep -o '"status":"ok"')

if [ -n "$HEALTH" ]; then
    echo "  ✓ Backend is healthy!"
else
    echo "  ❌ Backend health check failed"
    echo ""
    echo "  Check logs:"
    echo "  ssh $NAS_USER@$NAS_HOST 'cat /tmp/fafo-backend.log'"
    exit 1
fi

# Test chatbot endpoint
echo ""
echo "🤖 Testing chatbot endpoint..."
RESPONSE=$(ssh $NAS_USER@$NAS_HOST "curl -s -X POST http://localhost:3000/api/chat -H 'Content-Type: application/json' -d '{\"message\":\"Test\",\"conversationHistory\":[]}'" | grep -o '"success":true')

if [ -n "$RESPONSE" ]; then
    echo "  ✓ Chatbot is working!"
else
    echo "  ⚠️  Chatbot test failed (might be API quota issue)"
    echo ""
    echo "  Check the full response:"
    ssh $NAS_USER@$NAS_HOST "curl -s -X POST http://localhost:3000/api/chat -H 'Content-Type: application/json' -d '{\"message\":\"Test\",\"conversationHistory\":[]}'" | head -20
fi

# Show backend logs
echo ""
echo "📋 Recent backend logs:"
ssh $NAS_USER@$NAS_HOST "tail -20 /tmp/fafo-backend.log"

echo ""
echo "═══════════════════════════════════════════════════"
echo " Backend restart complete!"
echo "═══════════════════════════════════════════════════"
echo ""
echo "Monitor logs: ssh $NAS_USER@$NAS_HOST 'tail -f /tmp/fafo-backend.log'"
echo ""
