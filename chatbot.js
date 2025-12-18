// FAFO Legal Assistant - UI Logic
// Handles chatbot interface, message display, and user interactions

class FAFOChatbot {
    constructor() {
        this.isOpen = false;
        this.isMinimized = false;
        this.isLoading = false;
        this.messagesContainer = null;
        this.inputField = null;
        this.sendButton = null;
        this.chatWindow = null;
        this.floatingButton = null;

        this.suggestedPrompts = [
            "What does 'unsubstantiated' mean?",
            "How do I fill out the Motion for Return of Children?",
            "Where can I find legal aid?",
            "What are my constitutional rights?"
        ];

        this.init();
    }

    init() {
        this.createFloatingButton();
        this.createChatWindow();
        this.attachEventListeners();
        this.loadSavedMessages();
    }

    createFloatingButton() {
        const button = document.createElement('button');
        button.id = 'fafo-chatbot-button';
        button.className = 'fafo-chatbot-button';
        button.setAttribute('aria-label', 'Open FAFO Legal Assistant');
        button.innerHTML = `
            <span class="chatbot-icon">⚖️</span>
            <span class="chatbot-button-text">Ask FAFO Assistant</span>
        `;
        document.body.appendChild(button);
        this.floatingButton = button;

        button.addEventListener('click', () => {
            this.toggleChat();
        });
    }

    createChatWindow() {
        const chatWindow = document.createElement('div');
        chatWindow.id = 'fafo-chatbot-window';
        chatWindow.className = 'fafo-chatbot-window';
        chatWindow.style.display = 'none';

        chatWindow.innerHTML = `
            <div class="chatbot-header">
                <div class="chatbot-header-left">
                    <span class="chatbot-header-icon">⚖️</span>
                    <span class="chatbot-header-title">FAFO Legal Assistant</span>
                </div>
                <div class="chatbot-header-right">
                    <button class="chatbot-minimize-btn" aria-label="Minimize" title="Minimize">
                        <span>−</span>
                    </button>
                    <button class="chatbot-close-btn" aria-label="Close" title="Close">
                        <span>✕</span>
                    </button>
                </div>
            </div>

            <div class="chatbot-disclaimer">
                <p><strong>⚠️ Not Legal Advice:</strong> This assistant provides educational information only. Always consult a qualified dependency attorney for legal advice about your specific situation.</p>
            </div>

            <div class="chatbot-messages" id="chatbot-messages">
                <div class="chatbot-message chatbot-message-assistant">
                    <div class="chatbot-message-content">
                        <p>👋 Hello! I'm the FAFO Legal Assistant. I can help you with:</p>
                        <ul>
                            <li>Understanding your rights with DCF</li>
                            <li>Finding resources and legal aid</li>
                            <li>Filling out court documents</li>
                            <li>Navigating the dependency court process</li>
                        </ul>
                        <p><strong>How can I help you today?</strong></p>
                    </div>
                </div>
            </div>

            <div class="chatbot-suggested-prompts" id="chatbot-suggested-prompts">
                ${this.suggestedPrompts.map(prompt => `
                    <button class="chatbot-prompt-btn" data-prompt="${this.escapeHtml(prompt)}">
                        ${this.escapeHtml(prompt)}
                    </button>
                `).join('')}
            </div>

            <div class="chatbot-input-container">
                <textarea
                    class="chatbot-input"
                    id="chatbot-input"
                    placeholder="Type your question..."
                    rows="1"
                    aria-label="Message input"
                ></textarea>
                <button class="chatbot-send-btn" id="chatbot-send-btn" aria-label="Send message">
                    <span>➤</span>
                </button>
            </div>
        `;

        document.body.appendChild(chatWindow);
        this.chatWindow = chatWindow;
        this.messagesContainer = document.getElementById('chatbot-messages');
        this.inputField = document.getElementById('chatbot-input');
        this.sendButton = document.getElementById('chatbot-send-btn');
    }

    attachEventListeners() {
        // Send message button
        this.sendButton.addEventListener('click', () => this.handleSendMessage());

        // Enter key in input (shift+enter for new line)
        this.inputField.addEventListener('keydown', (e) => {
            if (e.key === 'Enter' && !e.shiftKey) {
                e.preventDefault();
                this.handleSendMessage();
            }
        });

        // Auto-resize textarea
        this.inputField.addEventListener('input', () => {
            this.inputField.style.height = 'auto';
            this.inputField.style.height = Math.min(this.inputField.scrollHeight, 120) + 'px';
        });

        // Minimize button
        this.chatWindow.querySelector('.chatbot-minimize-btn').addEventListener('click', () => {
            this.minimizeChat();
        });

        // Close button
        this.chatWindow.querySelector('.chatbot-close-btn').addEventListener('click', () => {
            this.closeChat();
        });

        // Suggested prompts
        this.chatWindow.querySelectorAll('.chatbot-prompt-btn').forEach(btn => {
            btn.addEventListener('click', (e) => {
                const prompt = e.target.getAttribute('data-prompt');
                this.inputField.value = prompt;
                this.handleSendMessage();
            });
        });
    }

    toggleChat() {
        if (this.isOpen) {
            this.closeChat();
        } else {
            this.openChat();
        }
    }

    openChat() {
        this.chatWindow.style.display = 'flex';
        this.floatingButton.style.display = 'none';
        this.isOpen = true;
        this.isMinimized = false;
        this.chatWindow.classList.remove('minimized');
        this.scrollToBottom();
        this.inputField.focus();
    }

    closeChat() {
        this.chatWindow.style.display = 'none';
        this.floatingButton.style.display = 'flex';
        this.isOpen = false;
        this.isMinimized = false;
    }

    minimizeChat() {
        this.isMinimized = !this.isMinimized;
        if (this.isMinimized) {
            this.chatWindow.classList.add('minimized');
        } else {
            this.chatWindow.classList.remove('minimized');
            this.scrollToBottom();
        }
    }

    async handleSendMessage() {
        const message = this.inputField.value.trim();
        if (!message || this.isLoading) return;

        // Check if API key is set
        if (!hasAPIKey()) {
            this.addMessage('assistant', '⚠️ **API Key Required**\n\nThe chatbot API key is not configured. Please contact the site administrator to set up the API key in chatbot-config.js.');
            return;
        }

        // Hide suggested prompts after first message
        const suggestedPromptsEl = document.getElementById('chatbot-suggested-prompts');
        if (suggestedPromptsEl) {
            suggestedPromptsEl.style.display = 'none';
        }

        // Add user message
        this.addMessage('user', message);

        // Clear input
        this.inputField.value = '';
        this.inputField.style.height = 'auto';

        // Show loading indicator
        this.showLoading();

        try {
            // Send to API using Gemini
            const response = await sendMessage(message);

            // Add assistant response
            this.addMessage('assistant', response);
        } catch (error) {
            this.addMessage('assistant', `⚠️ Error: ${error.message}\n\nPlease try again or <a href="contact.html">contact us</a> for assistance.`);
        } finally {
            this.hideLoading();
        }
    }

    addMessage(role, content) {
        const messageDiv = document.createElement('div');
        messageDiv.className = `chatbot-message chatbot-message-${role}`;

        const contentDiv = document.createElement('div');
        contentDiv.className = 'chatbot-message-content';

        // Convert markdown-style formatting to HTML
        const formattedContent = this.formatMessage(content);
        contentDiv.innerHTML = formattedContent;

        messageDiv.appendChild(contentDiv);

        // Remove loading indicator if present
        const loadingIndicator = this.messagesContainer.querySelector('.chatbot-loading');
        if (loadingIndicator) {
            this.messagesContainer.removeChild(loadingIndicator);
        }

        this.messagesContainer.appendChild(messageDiv);
        this.scrollToBottom();

        // Save messages to localStorage
        this.saveMessages();
    }

    formatMessage(text) {
        // Convert markdown-style formatting to HTML
        let formatted = text;

        // Bold (**text**)
        formatted = formatted.replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>');

        // Links already in HTML format are kept as-is
        // Convert markdown links [text](url) to HTML
        formatted = formatted.replace(/\[(.+?)\]\((.+?)\)/g, '<a href="$2">$1</a>');

        // Line breaks
        formatted = formatted.replace(/\n/g, '<br>');

        // Lists (simple handling)
        formatted = formatted.replace(/^- (.+)$/gm, '<li>$1</li>');
        formatted = formatted.replace(/^(\d+)\. (.+)$/gm, '<li>$2</li>');

        return formatted;
    }

    showLoading() {
        this.isLoading = true;
        this.sendButton.disabled = true;
        this.inputField.disabled = true;

        const loadingDiv = document.createElement('div');
        loadingDiv.className = 'chatbot-message chatbot-message-assistant chatbot-loading';
        loadingDiv.innerHTML = `
            <div class="chatbot-message-content">
                <div class="chatbot-typing-indicator">
                    <span></span>
                    <span></span>
                    <span></span>
                </div>
            </div>
        `;

        this.messagesContainer.appendChild(loadingDiv);
        this.scrollToBottom();
    }

    hideLoading() {
        this.isLoading = false;
        this.sendButton.disabled = false;
        this.inputField.disabled = false;

        const loadingIndicator = this.messagesContainer.querySelector('.chatbot-loading');
        if (loadingIndicator) {
            this.messagesContainer.removeChild(loadingIndicator);
        }
    }

    scrollToBottom() {
        if (this.messagesContainer) {
            setTimeout(() => {
                this.messagesContainer.scrollTop = this.messagesContainer.scrollHeight;
            }, 100);
        }
    }

    saveMessages() {
        const messages = Array.from(this.messagesContainer.querySelectorAll('.chatbot-message'))
            .filter(msg => !msg.classList.contains('chatbot-loading'))
            .map(msg => ({
                role: msg.classList.contains('chatbot-message-user') ? 'user' : 'assistant',
                content: msg.querySelector('.chatbot-message-content').textContent
            }));

        localStorage.setItem('fafo_chatbot_messages', JSON.stringify(messages.slice(-20))); // Keep last 20 messages
    }

    loadSavedMessages() {
        const saved = localStorage.getItem('fafo_chatbot_messages');
        if (saved) {
            try {
                const messages = JSON.parse(saved);
                // Clear welcome message if we have saved messages
                if (messages.length > 0) {
                    this.messagesContainer.innerHTML = '';
                    messages.forEach(msg => {
                        this.addMessage(msg.role, msg.content);
                    });
                }
            } catch (e) {
                console.error('Failed to load saved messages:', e);
            }
        }
    }

    escapeHtml(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }
}

// Initialize chatbot when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
    window.fafoChatbot = new FAFOChatbot();
});
