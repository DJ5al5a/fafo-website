# Gemini API Quota Issue - Quick Fix Guide

## Current Situation

Your backend is working perfectly! ✅
The issue is with the **Gemini API key quota**.

**Error:** `Quota exceeded for metric: generativelanguage.googleapis.com/generate_content_free_tier_requests, limit: 0`

## What This Means

Your API key (`AIzaSyC5DavCg5qSKsqfOAYerdtx2iHYf7oOsgo`) shows **limit: 0**, which means either:

1. ⏰ **Brand new key** - Sometimes takes 5-10 minutes to activate
2. 🚫 **Quota exhausted** - Hit daily/minute limits during testing
3. 🔒 **Restricted key** - Key might have restrictions set

## Solution 1: Wait & Retry (Easiest)

The error message said "retry in 16s" - quotas reset at:
- **Per-minute limit:** Resets every 60 seconds
- **Per-day limit:** Resets at midnight Pacific Time

Try again in **5-10 minutes**.

## Solution 2: Generate Fresh API Key (Recommended)

### Step 1: Go to Google AI Studio
https://aistudio.google.com/apikey

### Step 2: Delete Old Key
1. Find key: `AIzaSyC5DavCg5qSKsqfOAYerdtx2iHYf7oOsgo`
2. Click **Delete**
3. Confirm deletion

### Step 3: Create New Key
1. Click **Create API Key**
2. Select **Create API key in new project** (or existing if you prefer)
3. Copy the new key

### Step 4: Update Backend
```bash
# SSH to NAS
ssh dad@192.168.1.104

# Edit .env file
nano /volume1/web/backend/.env

# Change this line:
GEMINI_API_KEY=your_new_api_key_here

# Save: Ctrl+O, Enter, Ctrl+X
```

### Step 5: Restart Backend
```bash
# Use the helper script from your local machine:
./restart-backend.sh

# OR manually on NAS:
ssh dad@192.168.1.104
sudo pkill -f "node server.js"
cd /volume1/web/backend
node server.js &
```

## Solution 3: Check Your Quotas

Visit: https://ai.dev/usage?tab=rate-limit

- Log in with the Google account that created the API key
- Check **Gemini API** usage
- Look for:
  - **Requests per minute:** Should be 15/min for free tier
  - **Requests per day:** Should be 1,500/day for free tier
  - **Tokens per minute:** Should be sufficient

## Gemini Models & Quotas

I updated your backend to use **gemini-1.5-flash** (stable model) instead of **gemini-2.0-flash-exp** (experimental).

### Free Tier Limits:

| Model | RPM (Requests/min) | RPD (Requests/day) | TPM (Tokens/min) |
|-------|--------------------|--------------------|------------------|
| **gemini-1.5-flash** | 15 | 1,500 | 1M |
| gemini-2.0-flash-exp | 10 | 50 ⚠️ | 4M |

**gemini-1.5-flash is much better for free tier!**

## Testing After Fix

Once you have a working API key:

### Test 1: Health Check
```bash
curl http://localhost:3000/api/health
```

Expected: `{"status":"ok", ...}`

### Test 2: Chatbot
```bash
curl -X POST http://localhost:3000/api/chat \
  -H "Content-Type: application/json" \
  -d '{"message":"What are my rights?","conversationHistory":[]}'
```

Expected: Long JSON response with `"success":true` and helpful message.

### Test 3: From Website
1. Visit https://familyandfriendoutreach.com
2. Click chatbot button
3. Send message: "What are my rights with DCF?"
4. Should get helpful response

## Quick Commands Reference

```bash
# Restart backend (from local machine)
./restart-backend.sh

# Check backend logs
ssh dad@192.168.1.104 "tail -50 /tmp/fafo-backend.log"

# Check backend process
ssh dad@192.168.1.104 "ps aux | grep 'node server.js'"

# Test health
ssh dad@192.168.1.104 "curl http://localhost:3000/api/health"

# Test chatbot
ssh dad@192.168.1.104 'curl -X POST http://localhost:3000/api/chat -H "Content-Type: application/json" -d "{\"message\":\"test\",\"conversationHistory\":[]}"'
```

## If Chatbot Still Doesn't Work

### Check 1: Is backend running?
```bash
ssh dad@192.168.1.104 "ps aux | grep 'node server.js'"
```
Should show a node process.

### Check 2: Is Cloudflare Tunnel routing /api?
Test from outside your network:
```bash
curl https://familyandfriendoutreach.com/api/health
```
Should return the same health response.

If this fails, you need to configure Cloudflare Tunnel to route `/api` to `http://192.168.1.104:3000`.

### Check 3: API Key Valid?
Test directly with Google:
```bash
curl "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=YOUR_API_KEY" \
  -H 'Content-Type: application/json' \
  -d '{"contents":[{"parts":[{"text":"test"}]}]}'
```

Should return AI response, not error.

## Alternative: OpenRouter (Backup)

If Gemini quotas keep being an issue, we can add **OpenRouter** as a fallback. They have free models too:

- Free tier: 200 requests/day
- Model: `google/gemini-2.0-flash-exp:free`
- Sign up: https://openrouter.ai/

Let me know if you want me to add OpenRouter support!

## Summary

**Your backend code is perfect!** ✅
**The only issue is API key quotas.** ⚠️

**Next steps:**
1. Try again in 5-10 minutes (quota might reset)
2. OR generate a fresh API key
3. Update `.env` file
4. Restart backend with `./restart-backend.sh`
5. Test chatbot

---

**Questions?** Check backend logs or test the health endpoint to debug further.

Good luck! 🚀
