const { getDB, isFirebaseInitialized } = require('../config/firebase');
const { generateDrainageAssets, getAssetStatistics, findNearestAssets } = require('../utils/maps');

exports.getAll = async (req, res) => {
  try {
    const db = getDB();
    if (isFirebaseInitialized()) {
      const snapshot = await db.collection('drainage_assets').get();
      const assets = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
      res.json({ success: true, count: assets.length, data: assets });
    } else {
      const assets = generateDrainageAssets(50);
      res.json({ success: true, count: assets.length, data: assets, demo: true });
    }
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error fetching drainage assets', error: error.message });
  }
};

exports.add = async (req, res) => {
  try {
    const { type, lat, lng, name, description } = req.body;
    if (!type || !lat || !lng) {
      return res.status(400).json({ success: false, message: 'Missing required fields' });
    }
    const { detectZone } = require('../utils/zones');
    const zoneInfo = detectZone(lat, lng);
    const assetData = { type, lat, lng, name, description, zone: zoneInfo.zone, riskLevel: zoneInfo.riskLevel, createdAt: new Date().toISOString() };
    const db = getDB();
    if (isFirebaseInitialized()) {
      const ref = await db.collection('drainage_assets').add(assetData);
      res.json({ success: true, message: 'Asset added', data: { id: ref.id, ...assetData } });
    } else {
      res.json({ success: true, message: 'Demo mode - asset simulated', data: assetData });
    }
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error adding asset', error: error.message });
  }
};

exports.getNearby = async (req, res) => {
  try {
    const { lat, lng, limit } = req.query;
    if (!lat || !lng) {
      return res.status(400).json({ success: false, message: 'Missing lat/lng parameters' });
    }
    const db = getDB();
    if (isFirebaseInitialized()) {
      const snapshot = await db.collection('drainage_assets').get();
      const assets = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
      const nearest = findNearestAssets(parseFloat(lat), parseFloat(lng), assets, parseInt(limit) || 5);
      res.json({ success: true, count: nearest.length, data: nearest });
    } else {
      const assets = generateDrainageAssets(50);
      const nearest = findNearestAssets(parseFloat(lat), parseFloat(lng), assets, parseInt(limit) || 5);
      res.json({ success: true, count: nearest.length, data: nearest, demo: true });
    }
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error finding nearby assets', error: error.message });
  }
};

module.exports = exports;
