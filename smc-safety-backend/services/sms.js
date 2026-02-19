/**
 * SMS Service using Twilio
 * Optional SMS escalation for SOS events
 */

require('dotenv').config();

let twilioClient = null;
let isTwilioConfigured = false;

/**
 * Initialize Twilio client
 */
const initializeTwilio = () => {
  try {
    const accountSid = process.env.TWILIO_ACCOUNT_SID;
    const authToken = process.env.TWILIO_AUTH_TOKEN;
    
    if (!accountSid || !authToken || accountSid.includes('your_') || authToken.includes('your_')) {
      console.log('⚠️  Twilio not configured (optional)');
      console.log('   To enable SMS escalation:');
      console.log('   1. Sign up at https://www.twilio.com');
      console.log('   2. Get Account SID and Auth Token');
      console.log('   3. Add to .env file');
      return false;
    }
    
    const twilio = require('twilio');
    twilioClient = twilio(accountSid, authToken);
    isTwilioConfigured = true;
    console.log('✅ Twilio SMS service initialized');
    return true;
    
  } catch (error) {
    console.log('⚠️  Twilio initialization failed:', error.message);
    return false;
  }
};

/**
 * Send SMS notification
 * @param {string} to - Recipient phone number (E.164 format: +919876543210)
 * @param {string} message - SMS message body
 * @returns {Promise<Object>} Twilio API response or mock response
 */
const sendSMS = async (to, message) => {
  try {
    // If Twilio not configured, return mock success
    if (!isTwilioConfigured) {
      console.log('📱 SMS would be sent (Twilio not configured):');
      console.log(`   To: ${to}`);
      console.log(`   Message: ${message}`);
      return {
        success: true,
        mock: true,
        message: 'SMS not sent - Twilio not configured'
      };
    }
    
    // Validate phone number format
    if (!to.startsWith('+')) {
      console.log('⚠️  Phone number must be in E.164 format (+919876543210)');
      return {
        success: false,
        error: 'Invalid phone number format'
      };
    }
    
    // Send SMS via Twilio
    const response = await twilioClient.messages.create({
      body: message,
      from: process.env.TWILIO_PHONE_NUMBER,
      to: to
    });
    
    console.log('✅ SMS sent successfully:', response.sid);
    return {
      success: true,
      sid: response.sid,
      status: response.status
    };
    
  } catch (error) {
    console.error('❌ SMS send failed:', error.message);
    return {
      success: false,
      error: error.message
    };
  }
};

/**
 * Send SOS alert SMS to supervisor
 * @param {Object} sosData - SOS event data
 * @param {string} supervisorPhone - Supervisor phone number
 * @returns {Promise<Object>} SMS response
 */
const sendSOSAlert = async (sosData, supervisorPhone) => {
  const { getMessage } = require('../utils/i18n');
  
  // Format SMS message
  const message = `
🚨 EMERGENCY SOS ALERT

Worker ID: ${sosData.workerId}
Location: ${sosData.lat}, ${sosData.lng}
Zone: ${sosData.zone}
Mode: ${sosData.mode}
Time: ${new Date().toLocaleString('en-IN', { timeZone: 'Asia/Kolkata' })}

Action Required: Immediate response needed!

-SMC Safety System
`.trim();

  return await sendSMS(supervisorPhone, message);
};

/**
 * Send worker check-in notification
 * @param {Object} workerData - Worker data
 * @param {string} recipientPhone - Recipient phone number
 * @returns {Promise<Object>} SMS response
 */
const sendCheckinNotification = async (workerData, recipientPhone) => {
  const message = `
✅ Worker Check-in

Worker: ${workerData.name} (${workerData.workerId})
Location: ${workerData.zone}
Status: ${workerData.status}
Time: ${new Date().toLocaleString('en-IN', { timeZone: 'Asia/Kolkata' })}

-SMC Safety System
`.trim();

  return await sendSMS(recipientPhone, message);
};

/**
 * Send zone alert notification
 * @param {Object} alertData - Alert data
 * @param {string} workerPhone - Worker phone number
 * @returns {Promise<Object>} SMS response
 */
const sendZoneAlert = async (alertData, workerPhone) => {
  const message = `
⚠️ ZONE ALERT

${alertData.message}

Worker ID: ${alertData.workerId}
Zone: ${alertData.zone}
Risk Level: ${alertData.riskLevel}

Stay safe!

-SMC Safety System
`.trim();

  return await sendSMS(workerPhone, message);
};

/**
 * Check if Twilio is configured
 * @returns {boolean} True if configured
 */
const isSMSEnabled = () => {
  return isTwilioConfigured;
};

/**
 * Format phone number to E.164 format
 * @param {string} phone - Phone number (various formats)
 * @returns {string} E.164 formatted phone number
 */
const formatPhoneNumber = (phone) => {
  // Remove all non-digit characters
  const digits = phone.replace(/\D/g, '');
  
  // If it's an Indian number without country code, add +91
  if (digits.length === 10) {
    return `+91${digits}`;
  }
  
  // If it already has country code
  if (digits.length > 10) {
    return `+${digits}`;
  }
  
  return phone;
};

// Initialize Twilio on module load
initializeTwilio();

module.exports = {
  initializeTwilio,
  sendSMS,
  sendSOSAlert,
  sendCheckinNotification,
  sendZoneAlert,
  isSMSEnabled,
  formatPhoneNumber
};
