const { getDB, isFirebaseInitialized } = require('../config/firebase');
const { getMessage, getEmergencyContacts } = require('../utils/i18n');

exports.query = async (req, res) => {
  try {
    const { query, lang } = req.body;
    if (!query) {
      return res.status(400).json({ success: false, message: 'Query is required' });
    }
    const language = lang || 'en';
    const lowerQuery = query.toLowerCase();
    let response = '';
    
    if (lowerQuery.includes('status') || lowerQuery.includes('worker')) {
      const db = getDB();
      if (isFirebaseInitialized()) {
        const snapshot = await db.collection('workers').get();
        const workers = snapshot.docs.map(doc => doc.data());
        response = `Total Workers: ${workers.length}\nActive: ${workers.filter(w => w.status === 'ACTIVE').length}\nEmergency: ${workers.filter(w => w.status === 'EMERGENCY').length}`;
      } else {
        response = getMessage('worker_status_safe', language);
      }
    } else if (lowerQuery.includes('alert') || lowerQuery.includes('danger')) {
      const db = getDB();
      if (isFirebaseInitialized()) {
        const snapshot = await db.collection('alerts').orderBy('timestamp', 'desc').limit(5).get();
        response = snapshot.empty ? 'No active alerts' : `Active Alerts: ${snapshot.size}\nCheck dashboard for details`;
      } else {
        response = 'No active alerts currently';
      }
    } else if (lowerQuery.includes('emergency') || lowerQuery.includes('procedure') || lowerQuery.includes('help')) {
      response = getMessage('emergency_procedure', language) + '\n\n' + getMessage('emergency_contacts', language);
    } else if (lowerQuery.includes('contact')) {
      response = getMessage('emergency_contacts', language);
    } else {
      response = getMessage('chatbot_greeting', language);
    }
    
    res.json({ success: true, query, response, language });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Chatbot error', error: error.message });
  }
};

module.exports = exports;
