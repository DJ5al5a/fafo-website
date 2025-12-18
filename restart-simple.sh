#!/bin/bash
# Simple backend restart script

echo "Restarting FAFO backend..."

# Kill old backend
sudo pkill -9 -f "node /volume1/web/backend/server.js"
echo "Old backend killed"

# Wait
sleep 3

# Start new backend
cd /volume1/web/backend
node server.js > /tmp/fafo-backend.log 2>&1 &
echo "New backend started"

# Wait for startup
sleep 4

# Test it
echo ""
echo "Testing chatbot..."
curl -X POST http://localhost:3000/api/chat \
  -H "Content-Type: application/json" \
  -d '{"message":"What are my rights?","conversationHistory":[]}'
echo ""
