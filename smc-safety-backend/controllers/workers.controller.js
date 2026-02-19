/**
 * Workers Controller
 * Handles worker check-ins, GPS tracking, and status management
 */

const { getDB, isFirebaseInitialized } = require('../config/firebase');
const { detectZone, isFatalZone } = require('../utils/zones');
const { getMessage, isValidLanguage } = require('../utils/i18n');

/**
 * Worker Check-in
 * POST /api/workers/checkin
 * Body: { workerId, name, lat, lng, lang }
 */
exports.checkin = async (req, res) => {
  try {
    const { workerId, name, lat, lng, lang } = req.body;

    // Validate required fields
    if (!workerId || !lat || !lng) {
      return res.status(400).json({
        success: false,
        message: 'Missing required fields: workerId, lat, lng'
      });
    }

    // Validate coordinates
    const latitude = parseFloat(lat);
    const longitude = parseFloat(lng);
    
    if (isNaN(latitude) || isNaN(longitude)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid coordinates'
      });
    }

    // Validate language (default to English)
    const language = isValidLanguage(lang) ? lang.toLowerCase() : 'en';

    // Detect zone based on GPS coordinates
    const zoneInfo = detectZone(latitude, longitude);

    // Prepare worker data
    const workerData = {
      workerId,
      name: name || `Worker-${workerId}`,
      lat: latitude,
      lng: longitude,
      zone: zoneInfo.zone,
      riskLevel: zoneInfo.riskLevel,
      status: 'ACTIVE',
      lang: language,
      lastSeen: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    };

    // Prepare location history entry
    const locationData = {
      workerId,
      lat: latitude,
      lng: longitude,
      zone: zoneInfo.zone,
      riskLevel: zoneInfo.riskLevel,
      timestamp: new Date().toISOString()
    };

    const db = getDB();
    
    if (isFirebaseInitialized()) {
      // Firebase mode
      // Update or create worker document
      await db.collection('workers').doc(workerId).set(workerData, { merge: true });
      
      // Add location history
      await db.collection('locations').add(locationData);
      
      console.log(`✅ Worker ${workerId} checked in at ${zoneInfo.zone}`);
    } else {
      // In-memory mode (demo)
      console.log(`📍 Worker ${workerId} check-in (DEMO MODE):`, workerData);
    }

    // Check if entering fatal zone and create alert
    if (isFatalZone(zoneInfo.riskLevel)) {
      const alertData = {
        workerId,
        type: 'FATAL_ZONE_ENTRY',
        severity: 'CRITICAL',
        message: getMessage('entering_fatal_zone', language),
        zone: zoneInfo.zone,
        lat: latitude,
        lng: longitude,
        timestamp: new Date().toISOString()
      };

      if (isFirebaseInitialized()) {
        await db.collection('alerts').add(alertData);
      }
      
      console.log(`🚨 FATAL ZONE ALERT for worker ${workerId}`);
    }

    // Return localized success response
    res.json({
      success: true,
      message: getMessage('checkin_success', language),
      data: {
        workerId,
        zone: zoneInfo.zone,
        riskLevel: zoneInfo.riskLevel,
        color: zoneInfo.color,
        timestamp: new Date().toISOString()
      },
      warning: isFatalZone(zoneInfo.riskLevel) ? getMessage('entering_fatal_zone', language) : null
    });

  } catch (error) {
    console.error('❌ Check-in error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error during check-in',
      error: error.message
    });
  }
};

/**
 * Get All Workers
 * GET /api/workers/all
 */
exports.getAllWorkers = async (req, res) => {
  try {
    const db = getDB();
    let workers = [];

    if (isFirebaseInitialized()) {
      const snapshot = await db.collection('workers').get();
      workers = snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));
    } else {
      // Demo mode - return sample data
      workers = [
        {
          workerId: 'W001',
          name: 'Ramesh Patil',
          lat: 17.6799,
          lng: 75.9088,
          zone: 'North Solapur',
          riskLevel: 'HIGH',
          status: 'ACTIVE',
          lang: 'mr',
          lastSeen: new Date().toISOString()
        },
        {
          workerId: 'W002',
          name: 'Suresh Kumar',
          lat: 17.6550,
          lng: 75.9000,
          zone: 'Central Solapur',
          riskLevel: 'MEDIUM',
          status: 'ACTIVE',
          lang: 'hi',
          lastSeen: new Date().toISOString()
        },
        {
          workerId: 'W003',
          name: 'Mahesh Jadhav',
          lat: 17.6250,
          lng: 75.9050,
          zone: 'South Solapur',
          riskLevel: 'LOW',
          status: 'ACTIVE',
          lang: 'mr',
          lastSeen: new Date().toISOString()
        }
      ];
    }

    res.json({
      success: true,
      count: workers.length,
      data: workers
    });

  } catch (error) {
    console.error('❌ Get workers error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error fetching workers',
      error: error.message
    });
  }
};

/**
 * Get Worker by ID
 * GET /api/workers/:workerId
 */
exports.getWorkerById = async (req, res) => {
  try {
    const { workerId } = req.params;
    const db = getDB();

    if (isFirebaseInitialized()) {
      const doc = await db.collection('workers').doc(workerId).get();
      
      if (!doc.exists) {
        return res.status(404).json({
          success: false,
          message: 'Worker not found'
        });
      }

      res.json({
        success: true,
        data: {
          id: doc.id,
          ...doc.data()
        }
      });
    } else {
      // Demo mode
      res.json({
        success: true,
        data: {
          workerId,
          name: `Worker-${workerId}`,
          status: 'ACTIVE',
          message: 'Demo mode - worker data simulated'
        }
      });
    }

  } catch (error) {
    console.error('❌ Get worker error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error fetching worker',
      error: error.message
    });
  }
};

/**
 * Get Worker Location History
 * GET /api/workers/:workerId/history
 */
exports.getWorkerHistory = async (req, res) => {
  try {
    const { workerId } = req.params;
    const limit = parseInt(req.query.limit) || 50;
    const db = getDB();

    if (isFirebaseInitialized()) {
      const snapshot = await db.collection('locations')
        .where('workerId', '==', workerId)
        .orderBy('timestamp', 'desc')
        .limit(limit)
        .get();

      const history = snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));

      res.json({
        success: true,
        count: history.length,
        data: history
      });
    } else {
      // Demo mode
      res.json({
        success: true,
        count: 0,
        data: [],
        message: 'Demo mode - no history available'
      });
    }

  } catch (error) {
    console.error('❌ Get history error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error fetching history',
      error: error.message
    });
  }
};

module.exports = exports;
