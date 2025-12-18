# FAFO Backend Server

Secure Node.js/Express backend for the FAFO contact form.

## Quick Setup

### 1. Install Dependencies
```bash
cd /home/hecker/Projects/MOM/Site/backend
npm install
```

### 2. Configure Environment
```bash
cp .env.example .env
nano .env  # Edit with your email credentials
```

**Required Settings:**
- `SMTP_USER`: Your Gmail address
- `SMTP_PASS`: Gmail App Password (NOT your regular password!)
- `RECIPIENT_EMAIL`: Where to send form submissions

**Get Gmail App Password:**
1. Go to https://myaccount.google.com/apppasswords
2. Create app password for "Mail"
3. Copy 16-character password to .env

### 3. Run Server
```bash
# Development (auto-restart on changes)
npm run dev

# Production
npm start
```

Server runs on: http://localhost:3000

## Security Features

✅ Helmet - HTTP header security
✅ CORS - Cross-origin protection
✅ Rate Limiting - 3 requests per 15min
✅ Input Validation - Strict validation
✅ XSS Protection - Sanitizes inputs
✅ Size Limits - 10kb max request
✅ Logging - Tracks all submissions

## API Endpoints

**POST /api/contact** - Submit contact form
**GET /api/health** - Health check

## Testing

Send test email:
```bash
npm test
```

## Deployment Options

**Option 1: Heroku (Easiest)**
- Free tier available
- Automatic SSL
- Instructions: heroku-deploy.md

**Option 2: DigitalOcean**
- $5/month
- Full control
- Instructions: digitalocean-deploy.md

**Option 3: Vercel/Netlify**
- Free serverless
- Instructions: serverless-deploy.md
