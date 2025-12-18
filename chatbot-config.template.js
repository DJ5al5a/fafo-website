// FAFO Chatbot Configuration Template
// Copy this file to chatbot-config.js and add your API key

// INSTRUCTIONS:
// 1. Copy this file: cp chatbot-config.template.js chatbot-config.js
// 2. Edit chatbot-config.js and replace YOUR_GEMINI_API_KEY_HERE with your actual key
// 3. Deploy chatbot-config.js to your NAS
// 4. NEVER commit chatbot-config.js to git (it's in .gitignore)

const CHATBOT_CONFIG = {
    gemini_api_key: 'YOUR_GEMINI_API_KEY_HERE',  // Get key from: https://aistudio.google.com/app/apikey
    auto_initialize: true  // Set to false if you want users to enter their own keys
};

// Note: This file is loaded BEFORE chatbot-worker.js, so it only defines the config.
// The actual initialization happens in chatbot-worker.js after setAPIKey() is defined.
