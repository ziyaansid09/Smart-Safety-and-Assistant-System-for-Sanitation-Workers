/**
 * SOS Controller
 * Handles emergency SOS triggers in manual, voice, and offline modes
 */

const { getDB, isFirebaseInitialized } = require('../config/firebase');
const { detectZone } = require('../utils/zones');
const { getMessage, detectLanguageFromVoice } = require('../utils/i18n');
const { sendSOSAlert, isSMSEnabled } = require('../services/sms');

/**
 * Trigger SOS
 * POST /api/sos/trigger
 * Body: { workerId, lat, lng, zone, mode, lang, voiceText }
 */
exports.trigger = async (req, res) => {
  try {
    const { workerId, lat, lng, zone, mode, lang, voiceText } = req.body;

    // Validate required fields
    if (!workerId || !lat || !lng) {
      return res.status(400).json({
        success: false,
        message: 'Missing required fields: workerId, lat, lng'
      });
    }

    // Validate SOS mode (manual, voice, offline_sms)
    const sosMode = mode || 'manual';
    if (!['manual', 'voice', 'offline_sms'].includes(sosMode)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid SOS mode. Must be: manual, voice, or offline_sms'
      });
    }

    // Parse coordinates
    const latitude = parseFloat(lat);
    const longitude = parseFloat(lng);

    // Detect language (from voice if applicable, otherwise use provided lang)
    let language = lang || 'en';
    if (sosMode === 'voice' && voiceText) {
      language = detectLanguageFromVoice(voiceText);
    }

    // Detect zone if not provided
    const zoneInfo = zone ? { zone, riskLevel: 'UNKNOWN' } : detectZone(latitude, longitude);

    // Create SOS event
    const sosData = {
      workerId,
      lat: latitude,
      lng: longitude,
      zone: zoneInfo.zone,
      riskLevel: zoneInfo.riskLevel,
      mode: sosMode,
      lang: language,
      voiceText: voiceText || null,
      status: 'ACTIVE',
      timestamp: new Date().toISOString(),
      respondedAt: null
    };

    // Create corresponding alert
    const alertData = {
      workerId,
      type: 'SOS_EMERGENCY',
      severity: 'CRITICAL',
      message: `SOS triggered by worker ${workerId} in ${zoneInfo.zone}`,
      lat: latitude,
      lng: longitude,
      zone: zoneInfo.zone,
      mode: sosMode,
      timestamp: new Date().toISOString()
    };

    const db = getDB();
    let sosId = null;

    if (isFirebaseInitialized()) {
      // Firebase mode
      const sosRef = await db.collection('sos_events').add(sosData);
      await db.collection('alerts').add(alertData);
      
      // Update worker status to EMERGENCY
      await db.collection('workers').doc(workerId).update({
        status: 'EMERGENCY',
        lastSOS: new Date().toISOString()
      });

      sosId = sosRef.id;
      console.log(`🆘 SOS triggered by worker ${workerId} - ID: ${sosId}`);
    } else {
      // Demo mode
      sosId = `SOS-${Date.now()}`;
      console.log(`🆘 SOS triggered (DEMO MODE):`, sosData);
    }

    // Optional: Send SMS notification if Twilio configured
    if (isSMSEnabled()) {
      // In production, get supervisor phone from database
      const supervisorPhone = process.env.SUPERVISOR_PHONE || '+919876543210';
      await sendSOSAlert(sosData, supervisorPhone);
    }

    // Return localized confirmation
    res.status(201).json({
      success: true,
      message: getMessage('sos_received', language),
      confirmation: getMessage('sos_recorded', language),
      data: {
        sosId,
        workerId,
        zone: zoneInfo.zone,
        mode: sosMode,
        timestamp: sosData.timestamp,
        emergencyContacts: {
          police: '112 / 100',
          ambulance: '108 / 112',
          fire: '101 / 112'
        }
      }
    });

  } catch (error) {
    console.error('❌ SOS trigger error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error triggering SOS',
      error: error.message
    });
  }
};

/**
 * Get Recent SOS Events
 * GET /api/sos/recent?limit=50
 */
exports.getRecent = async (req, res) => {
  try {
    const limit = parseInt(req.query.limit) || 50;
    const status = req.query.status; // ACTIVE, RESPONDED, RESOLVED
    const db = getDB();

    if (isFirebaseInitialized()) {
      let query = db.collection('sos_events').orderBy('timestamp', 'desc').limit(limit);
      
      if (status) {
        query = query.where('status', '==', status.toUpperCase());
      }

      const snapshot = await query.get();
      const sosEvents = snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));

      res.json({
        success: true,
        count: sosEvents.length,
        data: sosEvents
      });
    } else {
      // Demo mode
      res.json({
        success: true,
        count: 0,
        data: [],
        message: 'Demo mode - no SOS events'
      });
    }

  } catch (error) {
    console.error('❌ Get SOS events error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error fetching SOS events',
      error: error.message
    });
  }
};

/**
 * Update SOS Status
 * PUT /api/sos/:sosId/status
 * Body: { status }
 */
exports.updateStatus = async (req, res) => {
  try {
    const { sosId } = req.params;
    const { status } = req.body;

    if (!['ACTIVE', 'RESPONDED', 'RESOLVED'].includes(status)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid status. Must be: ACTIVE, RESPONDED, or RESOLVED'
      });
    }

    const db = getDB();

    if (isFirebaseInitialized()) {
      const updateData = { status };
      
      if (status === 'RESPONDED') {
        updateData.respondedAt = new Date().toISOString();
      } else if (status === 'RESOLVED') {
        updateData.resolvedAt = new Date().toISOString();
      }

      await db.collection('sos_events').doc(sosId).update(updateData);

      res.json({
        success: true,
        message: `SOS status updated to ${status}`
      });
    } else {
      res.json({
        success: true,
        message: 'Demo mode - status update simulated'
      });
    }

  } catch (error) {
    console.error('❌ Update SOS status error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error updating SOS status',
      error: error.message
    });
  }
};

module.exports = exports;
