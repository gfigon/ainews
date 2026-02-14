/*
 * Klaro Cookie Consent Configuration for Robo AI Digest
 * https://klaro.org
 */

var klaroConfig = {
    // The element ID that Klaro will create
    elementID: 'klaro',

    // How to store consent: 'cookie' or 'localStorage'
    storageMethod: 'cookie',

    // Name of the cookie to store consent
    cookieName: 'roboaidigest-consent',

    // Cookie expiration in days
    cookieExpiresAfterDays: 365,

    // Default consent (true = opt-in, false = opt-out)
    default: false,

    // Show the "accept all" button
    mustConsent: false,

    // Accept all services by default
    acceptAll: true,

    // Hide the banner after accepting
    hideDeclineAll: false,
    hideLearnMore: false,

    // Language
    lang: 'en',

    // Translations
    translations: {
        en: {
            consentModal: {
                title: 'We value your privacy',
                description: 'Here you can see and customize what information we collect from you.',
            },
            acceptAll: 'Accept all',
            acceptSelected: 'Accept selected',
            declineAll: 'Decline all',
            learnMore: 'Learn more',
            services: {
                ga: {
                    title: 'Google Analytics',
                    description: 'Collects anonymous information about how you use our website.',
                },
            },
        },
    },

    // Services to configure
    services: [
        {
            name: 'ga',
            title: 'Google Analytics',
            purposes: ['analytics'],
            onAccept: function(consent, app) {
                // Enable Google Analytics if consented
                if (consent) {
                    console.log('Google Analytics enabled');
                }
            },
            onDecline: function() {
                console.log('Google Analytics declined');
            },
        },
    ],
};
