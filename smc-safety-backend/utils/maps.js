/**
 * Maps and Drainage Assets Generator
 * Generates realistic Solapur drainage/sewage locations
 */

const { detectZone } = require('./zones');

/**
 * Generate random coordinate within Solapur bounds
 * Latitude: 17.65 - 17.68
 * Longitude: 75.88 - 75.93
 */
const generateSolapurCoordinate = () => {
  const lat = 17.65 + Math.random() * (17.68 - 17.65);
  const lng = 75.88 + Math.random() * (75.93 - 75.88);
  
  return {
    lat: Math.round(lat * 100000) / 100000,  // 5 decimal places
    lng: Math.round(lng * 100000) / 100000
  };
};

/**
 * Asset types for drainage/sewage infrastructure
 */
const ASSET_TYPES = {
  MANHOLE: 'manhole',
  DRAIN: 'drain',
  SEWER: 'sewer'
};

/**
 * Risk tags for assets
 */
const RISK_TAGS = {
  NORMAL: 'NORMAL',
  HIGH: 'HIGH',
  FATAL: 'FATAL'
};

/**
 * Generate a single drainage asset with realistic data
 * @param {number} index - Asset index for naming
 * @returns {Object} Drainage asset object
 */
const generateDrainageAsset = (index) => {
  // Generate random coordinates
  const { lat, lng } = generateSolapurCoordinate();
  
  // Detect zone based on coordinates
  const zoneInfo = detectZone(lat, lng);
  
  // Randomly select asset type
  const types = Object.values(ASSET_TYPES);
  const type = types[Math.floor(Math.random() * types.length)];
  
  // Determine risk tag based on zone and randomness
  let riskTag;
  if (zoneInfo.riskLevel === 'HIGH') {
    // High risk zone: 60% FATAL, 30% HIGH, 10% NORMAL
    const rand = Math.random();
    if (rand < 0.6) riskTag = RISK_TAGS.FATAL;
    else if (rand < 0.9) riskTag = RISK_TAGS.HIGH;
    else riskTag = RISK_TAGS.NORMAL;
  } else if (zoneInfo.riskLevel === 'MEDIUM') {
    // Medium risk zone: 10% FATAL, 50% HIGH, 40% NORMAL
    const rand = Math.random();
    if (rand < 0.1) riskTag = RISK_TAGS.FATAL;
    else if (rand < 0.6) riskTag = RISK_TAGS.HIGH;
    else riskTag = RISK_TAGS.NORMAL;
  } else {
    // Low risk zone: 0% FATAL, 20% HIGH, 80% NORMAL
    const rand = Math.random();
    if (rand < 0.2) riskTag = RISK_TAGS.HIGH;
    else riskTag = RISK_TAGS.NORMAL;
  }
  
  // Generate asset name
  const typeLabel = type.charAt(0).toUpperCase() + type.slice(1);
  const zoneName = zoneInfo.zone.replace(' Solapur', '');
  const name = `${typeLabel}-${zoneName}-${String(index).padStart(3, '0')}`;
  
  // Generate description
  const descriptions = {
    manhole: [
      'Main sewage access point',
      'Underground maintenance access',
      'Drainage system entry',
      'Sewer line junction point'
    ],
    drain: [
      'Surface water drainage',
      'Storm water channel',
      'Rainwater collection drain',
      'Open drainage system'
    ],
    sewer: [
      'Underground sewer line',
      'Wastewater collection pipe',
      'Sewage disposal system',
      'Sanitation infrastructure'
    ]
  };
  
  const descArray = descriptions[type];
  const description = descArray[Math.floor(Math.random() * descArray.length)];
  
  // Generate maintenance data
  const statuses = ['operational', 'needs_maintenance', 'under_repair', 'critical'];
  const statusWeights = riskTag === RISK_TAGS.FATAL ? 
    [0.2, 0.3, 0.2, 0.3] : 
    [0.6, 0.25, 0.1, 0.05];
  
  let status = statuses[0];
  const rand = Math.random();
  let cumulative = 0;
  for (let i = 0; i < statuses.length; i++) {
    cumulative += statusWeights[i];
    if (rand < cumulative) {
      status = statuses[i];
      break;
    }
  }
  
  return {
    assetId: `ASSET-${String(index).padStart(4, '0')}`,
    type,
    name,
    description,
    lat,
    lng,
    zone: zoneInfo.zone,
    riskTag,
    riskLevel: zoneInfo.riskLevel,
    status,
    lastInspection: new Date(Date.now() - Math.random() * 90 * 24 * 60 * 60 * 1000).toISOString(), // Last 90 days
    nextInspection: new Date(Date.now() + Math.random() * 30 * 24 * 60 * 60 * 1000).toISOString(), // Next 30 days
    createdAt: new Date().toISOString()
  };
};

/**
 * Generate multiple drainage assets
 * @param {number} count - Number of assets to generate (default: 50)
 * @returns {Array} Array of drainage asset objects
 */
const generateDrainageAssets = (count = 50) => {
  const assets = [];
  
  for (let i = 1; i <= count; i++) {
    assets.push(generateDrainageAsset(i));
  }
  
  return assets;
};

/**
 * Get asset statistics
 * @param {Array} assets - Array of assets
 * @returns {Object} Statistics object
 */
const getAssetStatistics = (assets) => {
  const stats = {
    total: assets.length,
    byType: {},
    byRiskTag: {},
    byZone: {},
    byStatus: {}
  };
  
  assets.forEach(asset => {
    // Count by type
    stats.byType[asset.type] = (stats.byType[asset.type] || 0) + 1;
    
    // Count by risk tag
    stats.byRiskTag[asset.riskTag] = (stats.byRiskTag[asset.riskTag] || 0) + 1;
    
    // Count by zone
    stats.byZone[asset.zone] = (stats.byZone[asset.zone] || 0) + 1;
    
    // Count by status
    stats.byStatus[asset.status] = (stats.byStatus[asset.status] || 0) + 1;
  });
  
  return stats;
};

/**
 * Find nearest assets to a given location
 * @param {number} lat - Latitude
 * @param {number} lng - Longitude
 * @param {Array} assets - Array of assets
 * @param {number} limit - Max number of results
 * @returns {Array} Sorted array of nearest assets with distance
 */
const findNearestAssets = (lat, lng, assets, limit = 5) => {
  const { calculateDistance } = require('./zones');
  
  // Calculate distance for each asset
  const assetsWithDistance = assets.map(asset => ({
    ...asset,
    distance: calculateDistance(lat, lng, asset.lat, asset.lng)
  }));
  
  // Sort by distance and limit results
  return assetsWithDistance
    .sort((a, b) => a.distance - b.distance)
    .slice(0, limit);
};

module.exports = {
  generateSolapurCoordinate,
  generateDrainageAsset,
  generateDrainageAssets,
  getAssetStatistics,
  findNearestAssets,
  ASSET_TYPES,
  RISK_TAGS
};
