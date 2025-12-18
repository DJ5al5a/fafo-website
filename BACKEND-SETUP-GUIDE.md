# FAFO Backend Setup Guide

## Overview

Your FAFO website now has a **secure backend API** that protects your Gemini API key and provides chatbot functionality. This guide will walk you through the final setup steps.

## What's Been Completed ✅

1. **Backend API created** - Node.js/Express server with Gemini API proxy
2. **Chatbot updated** - Now uses secure backend instead of client-side API calls
3. **API key secured** - Moved from client-side (exposed) to server-side (.env file)
4. **Deployment scripts created** - Automated deployment tools
5. **Rate limiting added** - 10 requests/minute per IP for chatbot
6. **Files deployed to NAS** - Backend and frontend code uploaded

## What You Need to Do 🛠️

### Step 1: Install Node.js on Your Synology NAS

**Important:** The backend requires Node.js to run. You need to install it on your NAS.

**Option A: Using Synology Package Center (Recommended)**

1. Log into your Synology DSM web interface
2. Open **Package Center**
3. Search for **Node.js**
4. Click **Install** on the Node.js package
5. Wait for installation to complete

**Option B: Using Command Line**

If Node.js isn't available in Package Center for your DSM version:

```bash
ssh dad@192.168.1.104

# Download and install Node.js (example for ARM architecture)
# Check your NAS architecture first: uname -m
# Then download the appropriate version from nodejs.org
```

### Step 2: Install Backend Dependencies

Once Node.js is installed, run this command from your **local computer**:

```bash
./deploy-backend.sh
```

This script will:
- Deploy all backend files to NAS
- Install npm dependencies
- Start the backend server with PM2
- Show you the status

**Manual Alternative:**

```bash
ssh dad@192.168.1.104
cd /volume1/web/backend
npm install
npm start
```

### Step 3: Install PM2 (Process Manager)

PM2 keeps your backend running 24/7 and restarts it if it crashes:

```bash
ssh dad@192.168.1.104
npm install -g pm2
pm2 start /volume1/web/backend/server.js --name fafo-backend
pm2 save
pm2 startup  # Follow the instructions it gives you
```

### Step 4: Configure Cloudflare Tunnel (for /api/* routes)

You need to route `/api/*` requests to your backend server (port 3000).

**In Cloudflare Tunnel Dashboard:**

1. Go to https://one.dash.cloudflare.com/
2. Navigate to **Networks > Tunnels**
3. Click on your existing tunnel
4. Add a new **Public Hostname**:
   - **Subdomain:** (leave blank)
   - **Domain:** familyandfriendoutreach.com
   - **Path:** `/api`
   - **Type:** HTTP
   - **URL:** `http://192.168.1.104:3000`
5. Save

**Alternative (Path-based routing):**

Edit your tunnel config to route both static files and API:

```yaml
ingress:
  - hostname: familyandfriendoutreach.com
    path: /api
    service: http://192.168.1.104:3000
  - hostname: familyandfriendoutreach.com
    service: http://192.168.1.104:3535
  - service: http_status:404
```

### Step 5: Test the Backend

**Check if backend is running:**

```bash
ssh dad@192.168.1.104
curl http://localhost:3000/api/health
```

Expected response:
```json
{
  "status": "ok",
  "timestamp": "2025-12-17T...",
  "service": "FAFO Contact API"
}
```

**Test chatbot endpoint:**

```bash
curl -X POST http://localhost:3000/api/chat \
  -H "Content-Type: application/json" \
  -d '{"message":"What are my rights with DCF?","conversationHistory":[]}'
```

Should return a helpful response from the AI.

### Step 6: Test from Website

Once Cloudflare Tunnel is configured:

1. Visit https://familyandfriendoutreach.com
2. Click the chatbot button
3. Send a test message
4. Check browser console for errors (F12 > Console tab)

**If chatbot shows an error:**
- Check browser console for error messages
- Check backend logs: `ssh dad@192.168.1.104 "pm2 logs fafo-backend"`
- Verify Cloudflare Tunnel routes `/api` correctly

## Deployment Scripts Reference

### `./deploy.sh`
Deploys all **frontend files** (HTML, CSS, JS) to NAS.

Usage:
```bash
./deploy.sh
```

### `./deploy-backend.sh`
Deploys **backend files** and installs dependencies.

Usage:
```bash
./deploy-backend.sh
```

### `./increment-css-version.sh`
Increments CSS version number for cache busting.

Usage:
```bash
./increment-css-version.sh   # Updates all HTML files
./deploy.sh                  # Deploy updated files
```

## Backend Architecture

```
User Browser
    ↓
Cloudflare Tunnel
    ↓
Routes:
    / → 192.168.1.104:3535 (Static files - Web Station)
    /api → 192.168.1.104:3000 (Backend API - Node.js)
         ↓
    Backend API (server.js)
         ↓
    Gemini API (with secure API key)
```

**Benefits:**
- ✅ API key hidden server-side
- ✅ Rate limiting (10 requests/min per IP)
- ✅ Request logging for debugging
- ✅ Better error handling
- ✅ Conversation context maintained
- ✅ CORS security configured

## Security Notes

### API Key Protection

**Old way (INSECURE - fixed!):**
```javascript
// Client-side - API key exposed in browser!
const API_KEY = 'AIzaSy...'
fetch(`https://...?key=${API_KEY}`)
```

**New way (SECURE):**
```javascript
// Client-side - no API key!
fetch('/api/chat', {
    method: 'POST',
    body: JSON.stringify({ message: '...' })
})

// Server-side (.env file - not accessible to users)
GEMINI_API_KEY=AIzaSy...
```

### Environment Variables

The `.env` file contains sensitive information:
```
GEMINI_API_KEY=AIzaSyC5DavCg5qSKsqfOAYerdtx2iHYf7oOsgo
PORT=3000
NODE_ENV=production
FRONTEND_URL=https://familyandfriendoutreach.com
```

**Never commit this file to git!** It's already in `.gitignore`.

### File Permissions

Ensure backend files are readable by the Node.js process:
```bash
ssh dad@192.168.1.104
chmod 600 /volume1/web/backend/.env  # Only owner can read
chmod 644 /volume1/web/backend/server.js
chmod 644 /volume1/web/backend/package.json
```

## Monitoring & Logs

### View Backend Logs

```bash
# If using PM2:
ssh dad@192.168.1.104
pm2 logs fafo-backend

# Real-time logs:
pm2 logs fafo-backend --lines 100

# Error logs only:
pm2 logs fafo-backend --err
```

### Check Backend Status

```bash
ssh dad@192.168.1.104
pm2 status
pm2 monit  # Live monitoring
```

### Restart Backend

```bash
# If code changes:
./deploy-backend.sh  # Automatically restarts

# Manual restart:
ssh dad@192.168.1.104
pm2 restart fafo-backend
```

## Troubleshooting

### Chatbot shows "Connection Error"

**Check:**
1. Backend is running: `ssh dad@192.168.1.104 "pm2 status fafo-backend"`
2. Backend health: `ssh dad@192.168.1.104 "curl http://localhost:3000/api/health"`
3. Cloudflare Tunnel routes `/api` to port 3000
4. Browser console for specific errors (F12)

### Backend won't start

**Check:**
1. Node.js installed: `ssh dad@192.168.1.104 "node --version"`
2. Dependencies installed: `ssh dad@192.168.1.104 "ls /volume1/web/backend/node_modules"`
3. .env file exists: `ssh dad@192.168.1.104 "cat /volume1/web/backend/.env"`
4. Port 3000 available: `ssh dad@192.168.1.104 "netstat -an | grep 3000"`

### "QUOTA_EXCEEDED" errors

This means you've hit Gemini's free tier limits (1,500 requests/day).

**Solutions:**
- Wait until midnight Pacific Time (quota resets)
- Upgrade to Gemini API paid tier
- Add fallback to OpenRouter (has free models too)

### Rate limiting too strict

Edit `backend/server.js` line 75-84:
```javascript
const chatbotLimiter = rateLimit({
  windowMs: 1 * 60 * 1000,  // 1 minute
  max: 20,  // Increase from 10 to 20
  // ...
});
```

Then redeploy: `./deploy-backend.sh`

## Next Steps

After backend is running:

1. ✅ Test chatbot thoroughly
2. ✅ Monitor logs for a few days
3. ✅ Adjust rate limits if needed
4. ⏳ Rotate old API key (if desired)
5. ⏳ Set up uptime monitoring
6. ⏳ Add email alerts for backend crashes

## Budget-Friendly Monitoring

Since you're on a tight budget, here are **free** monitoring options:

### 1. UptimeRobot (Free Tier)
- Monitor up to 50 endpoints
- 5-minute checks
- Email/SMS alerts
- Monitor: `https://familyandfriendoutreach.com/api/health`

### 2. PM2 Email Alerts
```bash
# On NAS:
pm2 install pm2-auto-pull
pm2 set pm2-auto-pull:emailTo your-email@gmail.com
```

### 3. Cloudflare Analytics
- Already included with your Cloudflare setup
- See traffic patterns, errors, response times
- Dashboard: https://dash.cloudflare.com/

## Summary

You're almost there! The heavy lifting is done. All you need to do is:

1. **Install Node.js on NAS** (via Package Center)
2. **Run `./deploy-backend.sh`** (installs and starts backend)
3. **Configure Cloudflare Tunnel** (route `/api` to port 3000)
4. **Test** (visit website, click chatbot, send message)

That's it! Your chatbot will now work securely without exposing your API key to users.

Questions? Check the logs or feel free to ask!

---

**Last Updated:** December 17, 2025
**Backend Version:** 1.0.0
**Status:** Ready for deployment (pending Node.js installation)
