/**
 * Internationalization (i18n) Module
 * Supports English (EN), Hindi (HI), and Marathi (MR)
 */

/**
 * Language translations for common messages
 */
const translations = {
  // SOS Confirmation Messages
  sos_received: {
    en: 'SOS received. Help dispatched.',
    hi: 'SOS प्राप्त हुआ। सहायता भेजी जा रही है।',
    mr: 'SOS मिळाला. मदत पाठवली जात आहे.'
  },
  
  sos_recorded: {
    en: 'Your emergency has been recorded. Stay safe!',
    hi: 'आपातकाल दर्ज किया गया। सुरक्षित रहें!',
    mr: 'तुमची आपत्कालीन परिस्थिती नोंदवली गेली. सुरक्षित रहा!'
  },

  // Check-in Messages
  checkin_success: {
    en: 'Check-in successful. Location recorded.',
    hi: 'चेक-इन सफल। स्थान दर्ज किया गया।',
    mr: 'चेक-इन यशस्वी. स्थान नोंदवले.'
  },

  // Zone Warnings
  entering_high_risk: {
    en: 'Warning: You are entering a high-risk zone!',
    hi: 'चेतावनी: आप उच्च जोखिम क्षेत्र में प्रवेश कर रहे हैं!',
    mr: 'चेतावणी: तुम्ही उच्च-जोखीम झोनमध्ये प्रवेश करत आहात!'
  },

  entering_fatal_zone: {
    en: 'DANGER: Fatal zone! Evacuate immediately!',
    hi: 'खतरा: घातक क्षेत्र! तुरंत निकलें!',
    mr: 'धोका: प्राणघातक झोन! ताबडतोब बाहेर पडा!'
  },

  // Alert Messages
  worker_inactive: {
    en: 'Worker inactive for over 15 minutes. Check required.',
    hi: 'कार्यकर्ता 15 मिनट से अधिक समय से निष्क्रिय। जांच आवश्यक।',
    mr: 'कामगार 15 मिनिटांपेक्षा जास्त काळ निष्क्रिय. तपासणी आवश्यक.'
  },

  // Chatbot Responses
  chatbot_greeting: {
    en: 'Hello! How can I assist you with safety information?',
    hi: 'नमस्ते! मैं सुरक्षा जानकारी में आपकी कैसे मदद कर सकता हूं?',
    mr: 'नमस्कार! मी सुरक्षा माहितीमध्ये तुम्हाला कशी मदत करू शकतो?'
  },

  worker_status_safe: {
    en: 'All workers are currently safe.',
    hi: 'सभी कार्यकर्ता वर्तमान में सुरक्षित हैं।',
    mr: 'सर्व कामगार सध्या सुरक्षित आहेत.'
  },

  emergency_procedure: {
    en: '1. Call emergency services\n2. Evacuate immediately\n3. Inform supervisor',
    hi: '1. आपातकालीन सेवाओं को कॉल करें\n2. तुरंत निकलें\n3. पर्यवेक्षक को सूचित करें',
    mr: '1. आपत्कालीन सेवांना कॉल करा\n2. ताबडतोब बाहेर पडा\n3. पर्यवेक्षकाला कळवा'
  },

  // Emergency Contacts
  emergency_contacts: {
    en: 'Emergency Contacts:\nPolice: 112/100\nAmbulance: 108/112\nFire: 101/112',
    hi: 'आपातकालीन संपर्क:\nपुलिस: 112/100\nएम्बुलेंस: 108/112\nफायर: 101/112',
    mr: 'आपत्कालीन संपर्क:\nपोलीस: 112/100\nरुग्णवाहिका: 108/112\nअग्निशमन: 101/112'
  },

  // Safety Tips
  safety_tip_oxygen: {
    en: 'Always check oxygen levels before entering confined spaces.',
    hi: 'सीमित स्थानों में प्रवेश करने से पहले हमेशा ऑक्सीजन स्तर की जांच करें।',
    mr: 'मर्यादित जागेत प्रवेश करण्यापूर्वी नेहमी ऑक्सिजन पातळी तपासा.'
  },

  safety_tip_gear: {
    en: 'Wear all safety equipment including mask, gloves, and boots.',
    hi: 'मास्क, दस्ताने और जूते सहित सभी सुरक्षा उपकरण पहनें।',
    mr: 'मास्क, हातमोजे आणि बूटांसह सर्व सुरक्षा उपकरणे घाला.'
  }
};

/**
 * Voice command keywords for SOS detection
 */
const voiceKeywords = {
  sos: ['sos', 'help', 'emergency', 'danger'],
  madad: ['madad', 'सहायता', 'मदद', 'bachao', 'बचाओ'],  // Hindi
  madat: ['madat', 'मदत', 'वाचवा']  // Marathi
};

/**
 * Get translated message
 * @param {string} key - Message key
 * @param {string} lang - Language code (en, hi, mr)
 * @returns {string} Translated message
 */
const getMessage = (key, lang = 'en') => {
  const normalizedLang = (lang || 'en').toLowerCase();
  
  if (translations[key] && translations[key][normalizedLang]) {
    return translations[key][normalizedLang];
  }
  
  // Fallback to English if translation not found
  if (translations[key] && translations[key].en) {
    return translations[key].en;
  }
  
  return 'Message not available';
};

/**
 * Detect language from voice keywords
 * @param {string} voiceText - Voice command text
 * @returns {string} Detected language code
 */
const detectLanguageFromVoice = (voiceText) => {
  if (!voiceText) return 'en';
  
  const lowerText = voiceText.toLowerCase();
  
  // Check for Hindi keywords
  if (voiceKeywords.madad.some(keyword => lowerText.includes(keyword))) {
    return 'hi';
  }
  
  // Check for Marathi keywords
  if (voiceKeywords.madat.some(keyword => lowerText.includes(keyword))) {
    return 'mr';
  }
  
  // Default to English
  return 'en';
};

/**
 * Get all supported languages
 * @returns {Array} Array of language objects
 */
const getSupportedLanguages = () => {
  return [
    { code: 'en', name: 'English', nativeName: 'English' },
    { code: 'hi', name: 'Hindi', nativeName: 'हिन्दी' },
    { code: 'mr', name: 'Marathi', nativeName: 'मराठी' }
  ];
};

/**
 * Validate language code
 * @param {string} lang - Language code
 * @returns {boolean} True if valid
 */
const isValidLanguage = (lang) => {
  return ['en', 'hi', 'mr'].includes((lang || '').toLowerCase());
};

/**
 * Format multiple messages with language support
 * @param {Array} keys - Array of message keys
 * @param {string} lang - Language code
 * @returns {string} Combined translated messages
 */
const getMessages = (keys, lang = 'en') => {
  return keys.map(key => getMessage(key, lang)).join('\n\n');
};

/**
 * Get emergency contacts in specified language
 * @param {string} lang - Language code
 * @returns {Object} Emergency contact information
 */
const getEmergencyContacts = (lang = 'en') => {
  return {
    police: { numbers: ['112', '100'], label: getMessage('emergency_contacts', lang).split('\n')[1] },
    ambulance: { numbers: ['108', '112'], label: getMessage('emergency_contacts', lang).split('\n')[2] },
    fire: { numbers: ['101', '112'], label: getMessage('emergency_contacts', lang).split('\n')[3] }
  };
};

module.exports = {
  translations,
  voiceKeywords,
  getMessage,
  getMessages,
  detectLanguageFromVoice,
  getSupportedLanguages,
  isValidLanguage,
  getEmergencyContacts
};
