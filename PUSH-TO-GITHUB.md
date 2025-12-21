# Push FAFO Website to GitHub - Instructions

## Your Code is Ready!

All your code has been committed to Git locally. Now let's push it to GitHub.

---

## Step 1: Create GitHub Repository

1. **Go to:** https://github.com/new

2. **Fill in:**
   - **Repository name:** `fafo-website`
   - **Description:** `FAFO - Friends and Family Outreach: Florida advocacy website`
   - **Visibility:** Public (recommended) or Private
   - **IMPORTANT:** Leave ALL checkboxes UNCHECKED
     - ❌ Do NOT add README
     - ❌ Do NOT add .gitignore
     - ❌ Do NOT add license

3. **Click:** "Create repository"

---

## Step 2: Push Your Code

After creating the repository, run these commands:

```bash
cd /home/hecker/Projects/MOM/Site

# Set the correct remote URL
git remote set-url origin https://github.com/DJ5al5a/fafo-website.git

# Rename branch to main
git branch -M main

# Push to GitHub
git push -u origin main
```

**If it asks for credentials:**
- Username: `DJ5al5a`
- Password: Use a **Personal Access Token** (NOT your GitHub password)

---

## Step 3: Create Personal Access Token (If Needed)

If GitHub asks for a password and you don't have a token:

1. **Go to:** https://github.com/settings/tokens/new
2. **Note:** `FAFO Website Access`
3. **Expiration:** 90 days (or your preference)
4. **Scopes:** Check `repo` (full control of private repositories)
5. **Click:** "Generate token"
6. **Copy the token** (you won't see it again!)
7. **Use this token as your password** when pushing

---

## Step 4: Verify Upload

After pushing, visit:
https://github.com/DJ5al5a/fafo-website

You should see:
- ✅ 44 files
- ✅ All your HTML pages
- ✅ Documentation files
- ✅ Deployment scripts

---

## Alternative: Use SSH (No Passwords Needed)

If you prefer SSH authentication (recommended for frequent pushes):

```bash
# Generate SSH key (if you don't have one)
ssh-keygen -t ed25519 -C "your-email@example.com"

# Copy your public key
cat ~/.ssh/id_ed25519.pub

# Add it to GitHub:
# Go to: https://github.com/settings/keys
# Click "New SSH key"
# Paste the key and save

# Update remote to use SSH
git remote set-url origin git@github.com:DJ5al5a/fafo-website.git

# Push
git push -u origin main
```

---

## What's Included in the Push

✅ **All HTML Pages (12 total)**
- index.html
- know-your-rights.html
- dcf-policies.html
- state-laws.html
- court-hearings.html
- reporting.html
- resources.html
- faq.html
- court-checklist.html
- templates.html
- contact.html
- legal-disclaimer.html

✅ **Styles & Scripts**
- styles.css (with dark mode)
- script.js (navigation, accordions, theme toggle)

✅ **Backend** (optional/not deployed)
- backend/server.js
- backend/package.json
- backend/.env.example

✅ **Chatbot Files** (disabled but included)
- chatbot.js
- chatbot-worker.js
- chatbot-styles.css
- chatbot-config.template.js

✅ **Deployment Scripts**
- deploy.sh (frontend deployment)
- deploy-backend.sh (backend deployment)
- increment-css-version.sh (CSS cache busting)

✅ **Documentation**
- README.md
- CLAUDE.md (project instructions)
- BACKEND-SETUP-GUIDE.md
- NEXT-STEPS.md
- And more...

---

## What's NOT Included (Protected)

🔒 **Sensitive files automatically excluded by .gitignore:**
- ❌ chatbot-config.js (contains API key)
- ❌ backend/.env (contains API key)
- ❌ backend/node_modules/ (dependencies)
- ❌ *.log files

**These files stay local and on your NAS only!**

---

## Troubleshooting

### "Authentication failed"
- Make sure you're using a Personal Access Token, not your password
- Create one at: https://github.com/settings/tokens/new

### "Repository not found"
- Make sure you created the repository on GitHub first
- Check the repository name is exactly `fafo-website`

### "Remote already exists"
- That's fine! The `set-url` command will update it

### "Nothing to push"
- Your code is already on GitHub! Visit the URL to see it

---

## After Successful Push

Once pushed successfully:

1. **Visit your repo:** https://github.com/DJ5al5a/fafo-website
2. **Star your own repo** (optional but fun!)
3. **Add topics** (click gear icon): `advocacy`, `florida`, `dcf`, `legal-resources`
4. **Enable GitHub Pages** (optional - for free hosting):
   - Go to Settings > Pages
   - Source: Deploy from branch `main`
   - Save

---

## Quick Reference

```bash
# View what's been committed
git log --oneline

# Check current status
git status

# View remote URL
git remote -v

# Push after making changes
git add .
git commit -m "Description of changes"
git push
```

---

**Need Help?**

If you get stuck, I'm here to help! Just let me know what error message you see.

**Repository URL after creation:**
https://github.com/DJ5al5a/fafo-website

Good luck! 🚀
