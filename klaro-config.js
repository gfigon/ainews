// Konfiguracja Klaro Cookie Consent dla roboaidigest.com
var klaroConfig = {
    // Wersja językowa
    lang: 'en',
    
    // Czy zastosować Consent Mode v2 (Google)
    mustConsent: true,
    
    // Czy zgody są opcjonalne (false = użytkownik musi wybrać)
    acceptAll: true,
    
    // Czy pokazać toggle dla wszystkich kategorii naraz
    hideDeclineAll: false,
    
    // Czy pokazać link do polityki prywatności
    privacyPolicy: '/privacy',
    
    // Ustawienia wyglądu - USUNIĘTE theme, będziemy sterować przez CSS
    styling: {
        theme: ['bottom', 'wide'],
    },
    
    // Tłumaczenia
    translations: {
        en: {
            consentModal: {
                title: 'Szanujemy Twoją prywatność',
                description: 'Używamy plików cookies i podobnych technologii do personalizacji treści, analizy ruchu i reklam. Możesz zarządzać swoimi preferencjami poniżej.',
            },
            consentNotice: {
                description: 'Używamy plików cookies do analizy ruchu, personalizacji treści i wyświetlania reklam. Możesz zarządzać swoimi preferencjami dotyczącymi cookies.',
                learnMore: 'Dostosuj ustawienia',
            },
            ok: 'Akceptuję wybrane',
            acceptAll: 'Akceptuję wszystkie',
            acceptSelected: 'Akceptuję wybrane',
            decline: 'Odrzuć wszystkie',
            save: 'Zapisz ustawienia',
            close: 'Zamknij',
        },
        en: {
            consentModal: {
                title: 'We value your privacy',
                description: 'We use cookies and similar technologies to personalize content, analyze traffic and improve your experience. You can manage your preferences below.',
            },
            consentNotice: {
                description: 'We use cookies to analyze traffic, personalize content. You can manage your cookie preferences.',
                learnMore: 'Customize settings',
            },
            purposes: {
                analytics: {
                    title: 'Analytics',
                    description: 'Helps us understand how visitors use our website.',
                },
            },
            ok: 'OK',
            acceptAll: 'Accept all',
            acceptSelected: 'Accept selected',
            decline: 'Decline',
            save: 'Save preferences',
            close: 'Close',
        },
    },
    
    // Definicje poszczególnych serwisów/cookies
    services: [
        {
            name: 'google-analytics',
            title: 'Google Analytics',
            purposes: ['analytics'],
            required: false,
            optOut: false,
            default: false,
            onlyOnce: false,
            cookies: [
                [/^_ga/, '/', 'roboaidigest.com'],
                [/^_gid/, '/', 'roboaidigest.com'],
            ],
            callback: function(consent, service) {
                // Consent Mode v2 dla Google Analytics
                if (consent) {
                    window.dataLayer = window.dataLayer || [];
                    function gtag(){dataLayer.push(arguments);}
                    gtag('consent', 'update', {
                        'analytics_storage': 'granted'
                    });
                } else {
                    window.dataLayer = window.dataLayer || [];
                    function gtag(){dataLayer.push(arguments);}
                    gtag('consent', 'update', {
                        'analytics_storage': 'denied'
                    });
                }
            },
        },
        {
            name: 'google-ads',
            title: 'Google Ads',
            purposes: ['marketing'],
            required: false,
            optOut: false,
            default: false,
            onlyOnce: false,
            cookies: [
                [/^_gcl_/, '/', 'roboaidigest.com'],
            ],
            callback: function(consent, service) {
                // Consent Mode v2 dla Google Ads
                if (consent) {
                    window.dataLayer = window.dataLayer || [];
                    function gtag(){dataLayer.push(arguments);}
                    gtag('consent', 'update', {
                        'ad_storage': 'granted',
                        'ad_user_data': 'granted',
                        'ad_personalization': 'granted'
                    });
                } else {
                    window.dataLayer = window.dataLayer || [];
                    function gtag(){dataLayer.push(arguments);}
                    gtag('consent', 'update', {
                        'ad_storage': 'denied',
                        'ad_user_data': 'denied',
                        'ad_personalization': 'denied'
                    });
                }
            },
        },
        {
            name: 'preferences',
            title: 'Preferencje użytkownika',
            purposes: ['personalization'],
            required: false,
            default: false,
            cookies: [
                ['user_preferences', '/', 'roboaidigest.com'],
            ],
        },
    ],
    
    // Domyślne zgody (przed wyborem użytkownika)
    default: {
        analytics: false,
        marketing: false,
        personalization: false,
        social: false,
    },
};

