#!/bin/bash
# Run this script ON the NAS (after SSH'ing in)

echo "═══════════════════════════════════════════════════"
echo " Restarting FAFO Backend"
echo "═══════════════════════════════════════════════════"
echo ""

# Stop old backend
echo "🛑 Stopping old backend..."
sudo pkill -f "node /volume1/web/backend/server.js"
sleep 2
echo "  ✓ Old backend stopped"

# Start new backend
echo ""
echo "🚀 Starting backend with updated code..."
cd /volume1/web/backend
node server.js > /tmp/fafo-backend.log 2>&1 &
sleep 3

# Get PID
PID=$(ps aux | grep "node /volume1/web/backend/server.js" | grep -v grep | awk '{print $2}')
echo "  ✓ Backend started (PID: $PID)"

# Test health
echo ""
echo "🏥 Testing backend health..."
curl -s http://localhost:3000/api/health | python -m json.tool || curl -s http://localhost:3000/api/health

echo ""
echo ""
echo "═══════════════════════════════════════════════════"
echo " ✅ Backend Restarted!"
echo "═══════════════════════════════════════════════════"
echo ""
echo "Monitor logs: tail -f /tmp/fafo-backend.log"
echo ""
