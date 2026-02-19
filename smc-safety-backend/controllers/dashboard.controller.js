const { getDB, isFirebaseInitialized } = require('../config/firebase');
const datasetsData = require('../data/datasets.json');

exports.getSummary = async (req, res) => {
  try {
    const db = getDB();
    const summary = { workersCount: 0, sosActive: 0, drainageCount: 0, zoneStats: {}, topRiskZones: [], lastUpdated: new Date().toISOString() };
    
    if (isFirebaseInitialized()) {
      const [workers, sos, assets, zones] = await Promise.all([
        db.collection('workers').get(),
        db.collection('sos_events').where('status', '==', 'ACTIVE').get(),
        db.collection('drainage_assets').get(),
        db.collection('zones').get()
      ]);
      summary.workersCount = workers.size;
      summary.sosActive = sos.size;
      summary.drainageCount = assets.size;
    } else {
      summary.workersCount = 3;
      summary.sosActive = 0;
      summary.drainageCount = 50;
      summary.demo = true;
    }
    
    summary.datasets = datasetsData;
    res.json({ success: true, data: summary });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error fetching dashboard', error: error.message });
  }
};

module.exports = exports;
