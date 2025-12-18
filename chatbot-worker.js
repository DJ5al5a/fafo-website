// FAFO Legal Assistant - API Worker (Secure Backend Version)
// Handles communication with backend API proxy

// Backend API endpoint
const API_ENDPOINT = '/api/chat';

// Message history for context (max 10 messages to stay within limits)
let conversationHistory = [];

// Clear conversation history
function clearConversation() {
    conversationHistory = [];
    localStorage.removeItem('fafo_chat_history');
}

// Load conversation history from localStorage
function loadConversationHistory() {
    const saved = localStorage.getItem('fafo_chat_history');
    if (saved) {
        try {
            conversationHistory = JSON.parse(saved);
        } catch (e) {
            conversationHistory = [];
        }
    }
}

// Save conversation history to localStorage
function saveConversationHistory() {
    // Keep only last 10 messages to avoid token limits
    if (conversationHistory.length > 10) {
        conversationHistory = conversationHistory.slice(-10);
    }
    localStorage.setItem('fafo_chat_history', JSON.stringify(conversationHistory));
}

// Convert conversation history to backend format
function formatHistoryForBackend() {
    return conversationHistory.map(msg => ({
        role: msg.role === 'user' ? 'user' : 'model',
        parts: [{ text: msg.content }]
    }));
}

// Send message to backend API
async function sendMessageToBackend(userMessage) {
    const response = await fetch(API_ENDPOINT, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            message: userMessage,
            conversationHistory: formatHistoryForBackend()
        })
    });

    if (!response.ok) {
        const errorData = await response.json().catch(() => ({ error: 'Unknown error' }));

        // Check for rate limiting
        if (response.status === 429) {
            throw new Error('RATE_LIMIT_EXCEEDED');
        }

        // Check for quota errors
        if (errorData.error && (
            errorData.error.includes('quota') ||
            errorData.error.includes('rate limit') ||
            errorData.error.includes('RESOURCE_EXHAUSTED')
        )) {
            throw new Error('QUOTA_EXCEEDED');
        }

        throw new Error(errorData.error || `API request failed with status ${response.status}`);
    }

    const data = await response.json();

    if (!data.success || !data.message) {
        throw new Error('Invalid API response format');
    }

    return {
        message: data.message,
        conversationContext: data.conversationContext
    };
}

// Main function to send message
async function sendMessage(userMessage) {
    // Add user message to history
    conversationHistory.push({
        role: 'user',
        content: userMessage
    });

    try {
        const response = await sendMessageToBackend(userMessage);
        const assistantMessage = response.message;

        // Add assistant response to history
        conversationHistory.push({
            role: 'assistant',
            content: assistantMessage
        });

        // Save to localStorage
        saveConversationHistory();

        return assistantMessage;
    } catch (error) {
        console.error('Chatbot API error:', error);

        // Remove the user message we just added since the request failed
        conversationHistory.pop();

        // Return error message based on error type
        if (error.message === 'RATE_LIMIT_EXCEEDED') {
            return '⚠️ **Slow down just a bit**\n\n' +
                   'You\'re sending messages too quickly. Please wait a moment before sending another message.\n\n' +
                   'This helps us keep the service available for everyone.';
        } else if (error.message === 'QUOTA_EXCEEDED') {
            return '⚠️ **We\'re experiencing high traffic right now**\n\n' +
                   'Our chatbot has reached its daily message limit. This happens because we use a free service that allows 1,500 conversations per day.\n\n' +
                   '**What you can do:**\n' +
                   '- Try again in a few hours (limits reset at midnight Pacific Time)\n' +
                   '- <a href="contact.html">Contact us directly</a> and we\'ll get back to you soon\n' +
                   '- Browse our <a href="resources.html">Resources page</a> for immediate help\n\n' +
                   'We apologize for the inconvenience!';
        } else if (error.message.includes('Failed to fetch') || error.message.includes('NetworkError')) {
            return '⚠️ **Connection Error**\n\n' +
                   'Unable to reach the chatbot service. This could be due to:\n' +
                   '- Your internet connection\n' +
                   '- The server is temporarily unavailable\n\n' +
                   'Please check your connection and try again, or <a href="contact.html">contact us directly</a>.';
        } else {
            return `⚠️ **Error**: ${error.message}\n\nPlease try again or <a href="contact.html">contact us</a> directly for assistance.`;
        }
    }
}

// Initialize on load
loadConversationHistory();

console.log('✓ FAFO Chatbot Worker initialized (using secure backend API)');
