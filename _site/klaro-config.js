// Konfiguracja Klaro Cookie Consent dla roboaidigest.com

var klaroConfig = {
    // Wersja językowa
    lang: 'en',
    
    // Czy użytkownik musi wybrać (true = wymusza wybór)
    mustConsent: false,
    
    // Czy pokazać przycisk "Accept all"
    acceptAll: true,
    
    // Czy pokazać przycisk "Decline all"  
    hideDeclineAll: false,
    
    // Stylizacja
    styling: {
        theme: ['bottom', 'wide'],
    },
    
    // Tłumaczenia angielskie
    translations: {
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
            acceptAll: 'Accept all',
            acceptSelected: 'Accept selected',
            decline: 'Decline all',
            save: 'Save preferences',
            close: 'Close',
        },
    },
    
    // Serwisy/cookies (puste - brak zewnętrznych skryptów)
    services: [],
    
    // Domyślne zgody
    default: {
        analytics: false,
    },
};
