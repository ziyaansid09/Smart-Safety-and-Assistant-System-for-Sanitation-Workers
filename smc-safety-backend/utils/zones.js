/**
 * Solapur Zone Detection and Risk Assessment
 * Defines risk zones based on GPS coordinates
 */

/**
 * Solapur Risk Zones (Hardcoded based on latitude)
 * 
 * North Solapur: lat >= 17.67 → HIGH RISK
 * Central Solapur: 17.64 <= lat < 17.67 → MEDIUM RISK
 * South Solapur: lat < 17.64 → LOW RISK
 */
const SOLAPUR_ZONES = {
  NORTH: {
    name: 'North Solapur',
    bounds: {
      minLat: 17.67,
      maxLat: 17.70,
      minLng: 75.88,
      maxLng: 75.93
    },
    riskLevel: 'HIGH',
    color: '#FF6B6B',
    description: 'High-risk industrial area with older sewage infrastructure'
  },
  CENTRAL: {
    name: 'Central Solapur',
    bounds: {
      minLat: 17.64,
      maxLat: 17.67,
      minLng: 75.88,
      maxLng: 75.93
    },
    riskLevel: 'MEDIUM',
    color: '#FFD93D',
    description: 'Commercial area with moderate sewage activity'
  },
  SOUTH: {
    name: 'South Solapur',
    bounds: {
      minLat: 17.61,
      maxLat: 17.64,
      minLng: 75.88,
      maxLng: 75.93
    },
    riskLevel: 'LOW',
    color: '#6BCB77',
    description: 'Residential area with newer infrastructure'
  }
};

/**
 * Detect zone based on GPS coordinates
 * @param {number} lat - Latitude
 * @param {number} lng - Longitude
 * @returns {Object} Zone information
 */
const detectZone = (lat, lng) => {
  // Validate coordinates
  if (!lat || !lng || isNaN(lat) || isNaN(lng)) {
    return {
      zone: 'Unknown',
      riskLevel: 'UNKNOWN',
      color: '#CCCCCC',
      message: 'Invalid coordinates'
    };
  }

  // Check if coordinates are within Solapur bounds
  const inSolapur = lat >= 17.61 && lat <= 17.70 && lng >= 75.88 && lng <= 75.93;
  
  if (!inSolapur) {
    return {
      zone: 'Outside Solapur',
      riskLevel: 'UNKNOWN',
      color: '#CCCCCC',
      message: 'Worker is outside Solapur Municipal Corporation boundaries'
    };
  }

  // Detect zone based on latitude (as per requirements)
  if (lat >= 17.67) {
    // North Solapur - HIGH RISK
    return {
      zone: SOLAPUR_ZONES.NORTH.name,
      riskLevel: SOLAPUR_ZONES.NORTH.riskLevel,
      color: SOLAPUR_ZONES.NORTH.color,
      description: SOLAPUR_ZONES.NORTH.description,
      bounds: SOLAPUR_ZONES.NORTH.bounds
    };
  } else if (lat >= 17.64 && lat < 17.67) {
    // Central Solapur - MEDIUM RISK
    return {
      zone: SOLAPUR_ZONES.CENTRAL.name,
      riskLevel: SOLAPUR_ZONES.CENTRAL.riskLevel,
      color: SOLAPUR_ZONES.CENTRAL.color,
      description: SOLAPUR_ZONES.CENTRAL.description,
      bounds: SOLAPUR_ZONES.CENTRAL.bounds
    };
  } else {
    // South Solapur - LOW RISK
    return {
      zone: SOLAPUR_ZONES.SOUTH.name,
      riskLevel: SOLAPUR_ZONES.SOUTH.riskLevel,
      color: SOLAPUR_ZONES.SOUTH.color,
      description: SOLAPUR_ZONES.SOUTH.description,
      bounds: SOLAPUR_ZONES.SOUTH.bounds
    };
  }
};

/**
 * Get all defined zones
 * @returns {Array} Array of zone objects
 */
const getAllZones = () => {
  return Object.values(SOLAPUR_ZONES);
};

/**
 * Check if zone is fatal/high risk
 * @param {string} riskLevel - Risk level (HIGH, MEDIUM, LOW)
 * @returns {boolean} True if fatal zone
 */
const isFatalZone = (riskLevel) => {
  return riskLevel === 'HIGH';
};

/**
 * Get risk color based on risk tag
 * @param {string} riskTag - NORMAL, HIGH, or FATAL
 * @returns {string} Color code
 */
const getRiskColor = (riskTag) => {
  const colors = {
    NORMAL: '#6BCB77',  // GREEN
    HIGH: '#FFD93D',    // YELLOW
    FATAL: '#FF6B6B'    // RED
  };
  return colors[riskTag] || '#CCCCCC';
};

/**
 * Calculate distance between two GPS coordinates (in km)
 * Uses Haversine formula
 * @param {number} lat1 - Latitude 1
 * @param {number} lng1 - Longitude 1
 * @param {number} lat2 - Latitude 2
 * @param {number} lng2 - Longitude 2
 * @returns {number} Distance in kilometers
 */
const calculateDistance = (lat1, lng1, lat2, lng2) => {
  const R = 6371; // Earth's radius in km
  const dLat = (lat2 - lat1) * Math.PI / 180;
  const dLng = (lng2 - lng1) * Math.PI / 180;
  
  const a = Math.sin(dLat/2) * Math.sin(dLat/2) +
            Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
            Math.sin(dLng/2) * Math.sin(dLng/2);
  
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
  const distance = R * c;
  
  return Math.round(distance * 100) / 100; // Round to 2 decimal places
};

module.exports = {
  SOLAPUR_ZONES,
  detectZone,
  getAllZones,
  isFatalZone,
  getRiskColor,
  calculateDistance
};
