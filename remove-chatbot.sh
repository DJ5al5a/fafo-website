#!/bin/bash
# Remove chatbot references from all HTML files

echo "Removing chatbot from HTML files..."

for file in *.html; do
    # Skip the chatbot test file
    if [ "$file" = "chatbot-test.html" ]; then
        continue
    fi

    # Remove chatbot lines
    sed -i '/<!-- FAFO Chatbot -->/,/<script src="chatbot\.js"><\/script>/d' "$file"

    echo "  ✓ Removed chatbot from $file"
done

echo ""
echo "✅ Chatbot removed from all HTML files!"
echo "Note: Chatbot files (chatbot*.js, chatbot*.css) are still in the project but not loaded."
