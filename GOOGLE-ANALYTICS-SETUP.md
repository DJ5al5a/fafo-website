# Google Analytics Setup for FAFO Website

## Step 1: Create Google Analytics Account

1. Go to https://analytics.google.com/
2. Sign in with your Google account
3. Click **"Start measuring"**
4. Create an account:
   - Account name: `FAFO Website`
   - Check data sharing settings (optional)
   - Click **"Next"**

## Step 2: Set Up Property

1. Property name: `Friends and Family Outreach`
2. Reporting time zone: `United States - Eastern Time`
3. Currency: `United States Dollar (USD)`
4. Click **"Next"**

## Step 3: Business Information

1. Industry: `Non-Profit`
2. Business size: `Small (1-10 employees)`
3. How you plan to use Google Analytics: Check all that apply
4. Click **"Create"**

## Step 4: Get Your Measurement ID

1. Choose platform: **"Web"**
2. Set up data stream:
   - Website URL: `https://familyandfriendoutreach.com`
   - Stream name: `FAFO Main Website`
   - Click **"Create stream"**

3. **COPY YOUR MEASUREMENT ID** - It looks like: `G-XXXXXXXXXX`

## Step 5: Add Tracking Code to Website

Add this code to the `<head>` section of **EVERY HTML page** (right after the `<meta>` tags):

```html
<!-- Google Analytics -->
<script async src="https://www.googletagmanager.com/gtag/js?id=G-XXXXXXXXXX"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'G-XXXXXXXXXX');
</script>
<!-- End Google Analytics -->
```

**Replace `G-XXXXXXXXXX` with your actual Measurement ID!**

## Step 6: Test Analytics

1. Visit your website: https://familyandfriendoutreach.com
2. In Google Analytics, go to **Reports → Realtime**
3. You should see yourself as an active user!

## What You Can Track

Once set up, you'll be able to see:

### Audience Metrics
- **How many families are visiting** - Daily, weekly, monthly visitors
- **Where they're from** - Cities and states across Florida
- **What devices they use** - Mobile vs desktop usage

### Behavior Metrics
- **Most viewed pages** - Which pages help the most families
- **Time on page** - How long people read each section
- **Bounce rate** - Are people finding what they need?

### Acquisition Metrics
- **Traffic sources** - How people find your site (Google search, social media, direct)
- **Search terms** - What people search for to find you
- **Referral sites** - Other websites linking to you

### Goal Tracking (Advanced)
You can set up goals to track:
- Contact form submissions
- Downloads of PDF resources
- Clicks on external legal aid links
- Time spent on critical pages (Know Your Rights, Court Hearings)

## Privacy Considerations

**Important:** Google Analytics respects user privacy:
- Doesn't collect personally identifiable information
- Users can opt-out with browser extensions
- Complies with privacy regulations

**Add to your Legal Disclaimer page:**
```
This website uses Google Analytics to understand how families use our resources
and to improve our content. Analytics collects anonymized usage data only.
No personally identifiable information is collected.
```

## Useful Reports

### Weekly Check-Ins
1. **Audience Overview** - Total visitors this week
2. **Top Pages** - Which resources are most helpful
3. **Acquisition Channels** - How people found you

### Monthly Reviews
1. **Trending pages** - What's gaining traction
2. **Geographic data** - Are you reaching families statewide?
3. **Mobile usage** - Ensure mobile experience is good

### Impact Tracking
- Track when you share links on X/Twitter
- See traffic spikes after posting resources
- Understand which content resonates most

---

**Need Help?**
- Google Analytics Help Center: https://support.google.com/analytics
- Free Google Analytics courses: https://analytics.google.com/analytics/academy/
