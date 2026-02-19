const { getAllZones } = require('../utils/zones');
const zonesData = require('../data/solapur-zones.json');

exports.getAll = async (req, res) => {
  try {
    res.json({ success: true, count: zonesData.zones.length, data: zonesData.zones });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error fetching zones', error: error.message });
  }
};

module.exports = exports;
