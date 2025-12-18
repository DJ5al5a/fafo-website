require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const { body, validationResult } = require('express-validator');
const xss = require('xss-clean');
const hpp = require('hpp');
const nodemailer = require('nodemailer');
const fs = require('fs').promises;
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

// =====================================================
// SECURITY MIDDLEWARE
// =====================================================

// Helmet: Set security HTTP headers
app.use(helmet());

// CORS: Configure allowed origins
const allowedOrigins = [
  'http://localhost:8000',
  'http://127.0.0.1:8000',
  'http://192.168.1.165:8000',
  'http://192.168.1.104:3535',
  'https://familyandfriendoutreach.com',
  process.env.FRONTEND_URL
].filter(Boolean);

app.use(cors({
  origin: function(origin, callback) {
    // Allow requests with no origin (mobile apps, Postman, etc.)
    if (!origin) return callback(null, true);

    if (allowedOrigins.indexOf(origin) !== -1) {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  },
  credentials: true,
  methods: ['GET', 'POST'],
  allowedHeaders: ['Content-Type']
}));

// Body parser with size limits
app.use(express.json({ limit: '10kb' }));
app.use(express.urlencoded({ extended: true, limit: '10kb' }));

// Data sanitization against XSS
app.use(xss());

// Prevent parameter pollution
app.use(hpp());

// Rate limiting: Prevent spam and DoS attacks
const contactLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 3, // Limit each IP to 3 requests per windowMs
  message: {
    success: false,
    message: 'Too many contact form submissions from this IP. Please try again in 15 minutes.'
  },
  standardHeaders: true,
  legacyHeaders: false,
});

// Apply rate limiting to contact endpoint
app.use('/api/contact', contactLimiter);

// Rate limiting for chatbot API
const chatbotLimiter = rateLimit({
  windowMs: 1 * 60 * 1000, // 1 minute
  max: 10, // Limit each IP to 10 requests per minute
  message: {
    success: false,
    message: 'Too many chatbot requests. Please wait a moment before sending another message.'
  },
  standardHeaders: true,
  legacyHeaders: false,
});

app.use('/api/chat', chatbotLimiter);

// =====================================================
// EMAIL CONFIGURATION
// =====================================================

// Create transporter with your email service
// Using Gmail as example - you can use any SMTP service
const createTransporter = () => {
  return nodemailer.createTransport({
    host: process.env.SMTP_HOST || 'smtp.gmail.com',
    port: process.env.SMTP_PORT || 587,
    secure: false, // true for 465, false for other ports
    auth: {
      user: process.env.SMTP_USER, // Your email
      pass: process.env.SMTP_PASS  // Your app password
    }
  });
};

// =====================================================
// LOGGING FUNCTION
// =====================================================

const logSubmission = async (data) => {
  const logDir = path.join(__dirname, 'logs');
  const logFile = path.join(logDir, `submissions-${new Date().toISOString().split('T')[0]}.log`);

  try {
    // Create logs directory if it doesn't exist
    await fs.mkdir(logDir, { recursive: true });

    const logEntry = {
      timestamp: new Date().toISOString(),
      ip: data.ip,
      name: data.name,
      email: data.email,
      county: data.county,
      subject: data.subject
    };

    await fs.appendFile(logFile, JSON.stringify(logEntry) + '\n');
  } catch (error) {
    console.error('Error logging submission:', error);
  }
};

// =====================================================
// INPUT VALIDATION RULES
// =====================================================

const contactValidation = [
  body('name')
    .trim()
    .isLength({ min: 2, max: 100 })
    .withMessage('Name must be between 2 and 100 characters')
    .matches(/^[a-zA-Z\s'-]+$/)
    .withMessage('Name contains invalid characters'),

  body('email')
    .trim()
    .isEmail()
    .withMessage('Invalid email address')
    .normalizeEmail(),

  body('phone')
    .optional({ checkFalsy: true })
    .trim()
    .matches(/^[\d\s\-\(\)\+]+$/)
    .withMessage('Invalid phone number format')
    .isLength({ max: 20 }),

  body('county')
    .optional({ checkFalsy: true })
    .trim()
    .isLength({ max: 50 })
    .withMessage('County name too long'),

  body('subject')
    .trim()
    .isLength({ min: 1, max: 200 })
    .withMessage('Subject must be between 1 and 200 characters'),

  body('message')
    .trim()
    .isLength({ min: 10, max: 5000 })
    .withMessage('Message must be between 10 and 5000 characters')
];

// =====================================================
// API ROUTES
// =====================================================

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    service: 'FAFO Contact API'
  });
});

// Contact form submission endpoint
app.post('/api/contact', contactValidation, async (req, res) => {
  try {
    // Check for validation errors
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: errors.array()
      });
    }

    const { name, email, phone, county, subject, message } = req.body;
    const ip = req.ip || req.connection.remoteAddress;

    // Log the submission
    await logSubmission({ ip, name, email, county, subject });

    // Prepare email content
    const emailHtml = `
      <!DOCTYPE html>
      <html>
      <head>
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: linear-gradient(135deg, #0f172a 0%, #1e3a8a 100%); color: white; padding: 20px; border-radius: 8px 8px 0 0; }
          .content { background: #f9fafb; padding: 20px; border: 1px solid #e5e7eb; }
          .field { margin-bottom: 15px; }
          .label { font-weight: bold; color: #1e3a8a; }
          .value { margin-top: 5px; padding: 10px; background: white; border-left: 3px solid #b8860b; }
          .footer { background: #f1f5f9; padding: 15px; text-align: center; font-size: 12px; color: #6b7280; border-radius: 0 0 8px 8px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h2>New Contact Form Submission - FAFO</h2>
          </div>
          <div class="content">
            <div class="field">
              <div class="label">Name:</div>
              <div class="value">${name}</div>
            </div>
            <div class="field">
              <div class="label">Email:</div>
              <div class="value">${email}</div>
            </div>
            ${phone ? `
            <div class="field">
              <div class="label">Phone:</div>
              <div class="value">${phone}</div>
            </div>
            ` : ''}
            ${county ? `
            <div class="field">
              <div class="label">Florida County:</div>
              <div class="value">${county}</div>
            </div>
            ` : ''}
            <div class="field">
              <div class="label">Subject:</div>
              <div class="value">${subject}</div>
            </div>
            <div class="field">
              <div class="label">Message:</div>
              <div class="value">${message.replace(/\n/g, '<br>')}</div>
            </div>
            <div class="field">
              <div class="label">Submitted From:</div>
              <div class="value">IP: ${ip}</div>
            </div>
          </div>
          <div class="footer">
            <p>This submission was sent from the FAFO website contact form.</p>
            <p>Timestamp: ${new Date().toISOString()}</p>
          </div>
        </div>
      </body>
      </html>
    `;

    const emailText = `
New Contact Form Submission - FAFO

Name: ${name}
Email: ${email}
${phone ? `Phone: ${phone}\n` : ''}
${county ? `County: ${county}\n` : ''}
Subject: ${subject}

Message:
${message}

---
IP: ${ip}
Timestamp: ${new Date().toISOString()}
    `;

    // Send email
    const transporter = createTransporter();

    await transporter.sendMail({
      from: `"FAFO Contact Form" <${process.env.SMTP_USER}>`,
      to: process.env.RECIPIENT_EMAIL,
      replyTo: email,
      subject: `FAFO Contact: ${subject}`,
      text: emailText,
      html: emailHtml
    });

    // Send success response
    res.status(200).json({
      success: true,
      message: 'Thank you for contacting us. We will respond as soon as possible.'
    });

  } catch (error) {
    console.error('Contact form error:', error);

    // Don't expose internal errors to client
    res.status(500).json({
      success: false,
      message: 'There was an error processing your request. Please try again later or contact us directly at your social media.'
    });
  }
});

// =====================================================
// CHATBOT API PROXY
// =====================================================

// Chatbot endpoint - proxies requests to Gemini API
app.post('/api/chat', async (req, res) => {
  try {
    const { message, conversationHistory } = req.body;

    // Validate input
    if (!message || typeof message !== 'string') {
      return res.status(400).json({
        success: false,
        error: 'Message is required and must be a string'
      });
    }

    if (message.length > 2000) {
      return res.status(400).json({
        success: false,
        error: 'Message is too long (max 2000 characters)'
      });
    }

    // Gemini API endpoint (using correct model name)
    const geminiEndpoint = `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${process.env.GEMINI_API_KEY}`;

    // System prompt for FAFO chatbot
    const SYSTEM_PROMPT = `You are the FAFO Legal Assistant, a helpful chatbot for the Friends and Family Outreach (FAFO) website. FAFO helps Florida families dealing with DCF investigations and dependency court.

CRITICAL RULES:
1. You are NOT a lawyer and do NOT provide legal advice
2. Always remind users to consult a qualified dependency attorney
3. Base answers on Florida law (Chapter 39, FL Statutes)
4. Be empathetic - these families are in crisis
5. Direct users to specific pages on the FAFO website when relevant
6. For document templates, guide step-by-step but remind them to review with attorney

KNOWLEDGE BASE:
- Constitutional Rights: 4th Amendment (no warrantless entry), 5th Amendment (right to remain silent), 14th Amendment (family integrity)
- DCF Investigation Process: 60-day timeline, findings (verified/some indicators/unsubstantiated)
- Court Process: Shelter hearing (24 hrs), arraignment, case plan, judicial reviews
- Legal Terms: Admit, consent, deny, abandon, abuse, neglect, unsubstantiated, immediate danger
- Available Resources: Court templates, tracking logs, motion templates, legal aid directories

AVAILABLE PAGES ON FAFO WEBSITE:
- know-your-rights.html - Constitutional rights, what to do when DCF contacts you
- dcf-policies.html - DCF operating procedures and policies
- state-laws.html - Florida Chapter 39 statutes
- court-hearings.html - Court process and hearing types
- resources.html - Legal aid, DCF oversight agencies, support resources
- templates.html - Court document templates and tracking logs
- reporting.html - How to file complaints against DCF
- faq.html - Common questions and answers
- contact.html - Contact form

IMPORTANT PHONE NUMBERS:
- FL Bar Lawyer Referral: 1-800-342-8011
- Florida Abuse Hotline: 1-800-96-ABUSE (1-800-962-2873)

Your responses should be:
- Clear and actionable
- Empathetic and supportive
- Legally accurate (based on FL Chapter 39)
- Direct users to specific FAFO pages with links like: <a href="know-your-rights.html">Know Your Rights</a>
- Include relevant warnings/disclaimers
- Use formatting: **bold** for emphasis, numbered lists for steps
- Keep responses concise but thorough (aim for 150-300 words)`;

    // Build conversation contents array for Gemini
    const contents = [];

    // Add conversation history if provided (max 10 messages)
    if (conversationHistory && Array.isArray(conversationHistory)) {
      const recentHistory = conversationHistory.slice(-10);
      contents.push(...recentHistory);
    }

    // Add current user message
    contents.push({
      role: 'user',
      parts: [{ text: message }]
    });

    // Prepare request body for Gemini
    const requestBody = {
      contents: contents,
      systemInstruction: {
        parts: [{ text: SYSTEM_PROMPT }]
      },
      generationConfig: {
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 1024,
      }
    };

    // Make request to Gemini API
    const response = await fetch(geminiEndpoint, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(requestBody)
    });

    if (!response.ok) {
      const errorData = await response.json().catch(() => ({}));
      console.error('Gemini API error:', errorData);

      return res.status(response.status).json({
        success: false,
        error: 'Failed to get response from AI service',
        details: errorData
      });
    }

    const data = await response.json();

    // Extract response text from Gemini response
    const assistantMessage = data.candidates?.[0]?.content?.parts?.[0]?.text;

    if (!assistantMessage) {
      return res.status(500).json({
        success: false,
        error: 'No response generated'
      });
    }

    // Return successful response (in Gemini-compatible format for frontend)
    res.json({
      success: true,
      message: assistantMessage,
      conversationContext: {
        role: 'model',
        parts: [{ text: assistantMessage }]
      }
    });

  } catch (error) {
    console.error('Chatbot API error:', error);
    res.status(500).json({
      success: false,
      error: 'An error occurred while processing your request'
    });
  }
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: 'Endpoint not found'
  });
});

// Global error handler
app.use((err, req, res, next) => {
  console.error('Server error:', err);
  res.status(500).json({
    success: false,
    message: 'Internal server error'
  });
});

// =====================================================
// START SERVER
// =====================================================

app.listen(PORT, () => {
  console.log(`
╔═══════════════════════════════════════════════════╗
║  FAFO Backend Server                              ║
║  Status: Running                                  ║
║  Port: ${PORT}                                        ║
║  Environment: ${process.env.NODE_ENV || 'development'}                         ║
║                                                   ║
║  Endpoints:                                       ║
║  - POST /api/contact (Contact Form)              ║
║  - POST /api/chat (AI Chatbot Proxy)             ║
║  - GET  /api/health (Health Check)               ║
╚═══════════════════════════════════════════════════╝
  `);

  // Verify email configuration
  if (!process.env.SMTP_USER || !process.env.SMTP_PASS) {
    console.warn('\n⚠️  WARNING: Email credentials not configured!');
    console.warn('Please set SMTP_USER and SMTP_PASS in your .env file\n');
  }

  if (!process.env.RECIPIENT_EMAIL) {
    console.warn('\n⚠️  WARNING: Recipient email not configured!');
    console.warn('Please set RECIPIENT_EMAIL in your .env file\n');
  }

  // Verify Gemini API key
  if (!process.env.GEMINI_API_KEY) {
    console.warn('\n⚠️  WARNING: Gemini API key not configured!');
    console.warn('Please set GEMINI_API_KEY in your .env file\n');
    console.warn('Chatbot endpoint will not work without this.\n');
  } else {
    console.log('\n✓ Gemini API key configured - Chatbot endpoint ready\n');
    console.log('  Using model: gemini-2.5-flash (latest stable version)\n');
  }
});

module.exports = app;
