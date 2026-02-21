// Mobile Navigation Toggle with Touch Gesture Support
document.addEventListener('DOMContentLoaded', function() {
    const navToggle = document.querySelector('.nav-toggle');
    const navMenu = document.querySelector('.nav-menu');

    if (navToggle) {
        navToggle.addEventListener('click', function() {
            navMenu.classList.toggle('active');
            // Update ARIA attribute
            const isActive = navMenu.classList.contains('active');
            navToggle.setAttribute('aria-expanded', isActive);
        });
    }

    // Touch gesture support for mobile menu (swipe from left edge to open)
    let touchStartX = 0;
    let touchStartY = 0;
    let touchEndX = 0;
    let touchEndY = 0;

    document.addEventListener('touchstart', function(e) {
        touchStartX = e.changedTouches[0].screenX;
        touchStartY = e.changedTouches[0].screenY;
    }, { passive: true });

    document.addEventListener('touchend', function(e) {
        touchEndX = e.changedTouches[0].screenX;
        touchEndY = e.changedTouches[0].screenY;
        handleSwipeGesture();
    }, { passive: true });

    function handleSwipeGesture() {
        const swipeThreshold = 50; // Minimum distance for a swipe
        const swipeDistanceX = touchEndX - touchStartX;
        const swipeDistanceY = Math.abs(touchEndY - touchStartY);

        // Swipe from left edge to open menu (must start near left edge)
        if (touchStartX < 30 && swipeDistanceX > swipeThreshold && swipeDistanceY < 100) {
            if (navMenu && !navMenu.classList.contains('active')) {
                navMenu.classList.add('active');
                if (navToggle) navToggle.setAttribute('aria-expanded', 'true');
            }
        }

        // Swipe right to left to close menu (when menu is open)
        if (swipeDistanceX < -swipeThreshold && swipeDistanceY < 100) {
            if (navMenu && navMenu.classList.contains('active')) {
                navMenu.classList.remove('active');
                if (navToggle) navToggle.setAttribute('aria-expanded', 'false');
            }
        }
    }

    // Close mobile menu when clicking outside
    document.addEventListener('click', function(event) {
        if (navMenu && navMenu.classList.contains('active')) {
            if (!event.target.closest('.navbar')) {
                navMenu.classList.remove('active');
                if (navToggle) navToggle.setAttribute('aria-expanded', 'false');
            }
        }
    });

    // Accordion functionality with ARIA attributes
    const accordionHeaders = document.querySelectorAll('.accordion-header');

    accordionHeaders.forEach((header, index) => {
        // Add ARIA attributes for accessibility
        const accordionItem = header.parentElement;
        const accordionContent = accordionItem.querySelector('.accordion-content');

        // Generate unique IDs
        const headerId = `accordion-header-${index}`;
        const contentId = `accordion-content-${index}`;

        header.setAttribute('id', headerId);
        header.setAttribute('aria-expanded', 'false');
        header.setAttribute('aria-controls', contentId);

        accordionContent.setAttribute('id', contentId);
        accordionContent.setAttribute('role', 'region');
        accordionContent.setAttribute('aria-labelledby', headerId);

        header.addEventListener('click', function() {
            const wasActive = accordionItem.classList.contains('active');

            // Close all accordion items
            document.querySelectorAll('.accordion-item').forEach(item => {
                item.classList.remove('active');
                const btn = item.querySelector('.accordion-header');
                if (btn) btn.setAttribute('aria-expanded', 'false');
            });

            // Open clicked item if it wasn't active
            if (!wasActive) {
                accordionItem.classList.add('active');
                this.setAttribute('aria-expanded', 'true');
            }
        });
    });

    // Smooth scroll for anchor links
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function(e) {
            const href = this.getAttribute('href');
            if (href !== '#') {
                e.preventDefault();
                const target = document.querySelector(href);
                if (target) {
                    target.scrollIntoView({
                        behavior: 'smooth',
                        block: 'start'
                    });
                }
            }
        });
    });


    // Set active nav link based on current page
    const currentLocation = window.location.pathname.split('/').pop() || 'index.html';
    const navLinks = document.querySelectorAll('.nav-menu a');

    navLinks.forEach(link => {
        const linkPath = link.getAttribute('href');
        if (linkPath === currentLocation) {
            // Remove active class from all links
            navLinks.forEach(l => l.classList.remove('active'));
            // Add active class to current link
            link.classList.add('active');
        }
    });

    // Theme toggle functionality
    const themeToggle = document.querySelector('.theme-toggle');
    const html = document.documentElement;

    // Load saved theme or default to light
    const savedTheme = localStorage.getItem('theme') || 'light';
    html.setAttribute('data-theme', savedTheme);
    updateThemeToggleText(savedTheme);

    if (themeToggle) {
        themeToggle.addEventListener('click', function() {
            const currentTheme = html.getAttribute('data-theme');
            const newTheme = currentTheme === 'light' ? 'dark' : 'light';

            html.setAttribute('data-theme', newTheme);
            localStorage.setItem('theme', newTheme);
            updateThemeToggleText(newTheme);
        });
    }

    function updateThemeToggleText(theme) {
        if (themeToggle) {
            const icon = theme === 'light' ? '🌙' : '☀️';
            const text = theme === 'light' ? 'Dark Mode' : 'Light Mode';
            themeToggle.innerHTML = `${icon} ${text}`;
        }
    }

    // Print button functionality for templates page
    const printButtons = document.querySelectorAll('.print-btn');
    printButtons.forEach(button => {
        button.addEventListener('click', function() {
            window.print();
        });
    });

    // Preview button functionality for templates page
    const previewLinks = document.querySelectorAll('a[href^="#"][href*="-preview"]');
    const templatePreviewsSection = document.getElementById('template-previews');

    previewLinks.forEach(link => {
        link.addEventListener('click', function(e) {
            e.preventDefault();

            // Show the template previews section
            if (templatePreviewsSection) {
                templatePreviewsSection.style.display = 'block';
            }

            // Scroll to the specific preview
            const targetId = this.getAttribute('href');
            const targetElement = document.querySelector(targetId);

            if (targetElement) {
                setTimeout(() => {
                    targetElement.scrollIntoView({
                        behavior: 'smooth',
                        block: 'start'
                    });
                }, 100);
            }
        });
    });

    // Native Share API for mobile sharing
    // Add share buttons dynamically if Web Share API is supported
    if (navigator.share) {
        // Create share button for main content
        const pageTitle = document.title;
        const pageUrl = window.location.href;
        const metaDescription = document.querySelector('meta[name="description"]');
        const pageDescription = metaDescription ? metaDescription.content : 'Florida child welfare advocacy and resources';

        // Add share button to page header if it doesn't exist
        const mainContent = document.getElementById('main-content');
        if (mainContent) {
            const shareButton = document.createElement('button');
            shareButton.className = 'share-button';
            shareButton.innerHTML = '📤 Share this page';
            shareButton.setAttribute('aria-label', 'Share this page');
            shareButton.style.cssText = 'position: fixed; bottom: 20px; right: 20px; z-index: 100; padding: 12px 20px; background: var(--primary-color); color: white; border: none; border-radius: 50px; cursor: pointer; box-shadow: 0 4px 12px rgba(0,0,0,0.15); font-size: 14px; font-weight: 600; display: none;';

            // Show button on scroll (mobile only)
            let scrollTimeout;
            window.addEventListener('scroll', function() {
                if (window.innerWidth <= 768 && window.scrollY > 300) {
                    shareButton.style.display = 'block';
                    clearTimeout(scrollTimeout);
                    scrollTimeout = setTimeout(() => {
                        shareButton.style.display = 'none';
                    }, 3000); // Hide after 3 seconds of no scrolling
                }
            }, { passive: true });

            shareButton.addEventListener('click', async function() {
                try {
                    await navigator.share({
                        title: pageTitle,
                        text: pageDescription,
                        url: pageUrl
                    });
                } catch (error) {
                    // User cancelled share or browser doesn't support it
                    if (error.name !== 'AbortError') {
                        // Fallback: copy to clipboard
                        copyToClipboard(pageUrl);
                    }
                }
            });

            document.body.appendChild(shareButton);
        }
    }

    // Fallback: Copy to clipboard function
    function copyToClipboard(text) {
        if (navigator.clipboard && navigator.clipboard.writeText) {
            navigator.clipboard.writeText(text).then(function() {
                // Show temporary success message
                showToast('Link copied to clipboard!');
            }).catch(function() {
                // Fallback for older browsers
                fallbackCopyToClipboard(text);
            });
        } else {
            fallbackCopyToClipboard(text);
        }
    }

    function fallbackCopyToClipboard(text) {
        const textArea = document.createElement('textarea');
        textArea.value = text;
        textArea.style.position = 'fixed';
        textArea.style.left = '-9999px';
        document.body.appendChild(textArea);
        textArea.focus();
        textArea.select();

        try {
            document.execCommand('copy');
            showToast('Link copied to clipboard!');
        } catch (err) {
            showToast('Could not copy link');
        }

        document.body.removeChild(textArea);
    }

    function showToast(message) {
        const toast = document.createElement('div');
        toast.textContent = message;
        toast.style.cssText = 'position: fixed; bottom: 80px; right: 20px; background: var(--success-green, #28a745); color: white; padding: 12px 24px; border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.15); z-index: 1000; font-size: 14px; animation: slideIn 0.3s ease;';

        document.body.appendChild(toast);

        setTimeout(() => {
            toast.style.animation = 'slideOut 0.3s ease';
            setTimeout(() => {
                document.body.removeChild(toast);
            }, 300);
        }, 3000);
    }

    // Improve scroll performance with passive listeners
    // (Already applied to touch events above)

    // Reduce motion for users who prefer it
    const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)');

    if (prefersReducedMotion.matches) {
        // Disable smooth scrolling for users who prefer reduced motion
        document.querySelectorAll('a[href^="#"]').forEach(anchor => {
            anchor.addEventListener('click', function(e) {
                const href = this.getAttribute('href');
                if (href !== '#') {
                    e.preventDefault();
                    const target = document.querySelector(href);
                    if (target) {
                        target.scrollIntoView({
                            behavior: 'auto', // Instant scroll instead of smooth
                            block: 'start'
                        });
                    }
                }
            });
        });
    }
});
