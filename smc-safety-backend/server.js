/**
 * SMC Smart Safety & Assistance System - Main Server
 * Solapur Municipal Corporation
 * 
 * Complete backend API for sanitation worker safety monitoring
 */

const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
require('dotenv').config();

const { initializeFirebase, isFirebaseInitialized, getDB } = require('./config/firebase');
const { generateDrainageAssets } = require('./utils/maps');

// Initialize Express app
const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Request logging middleware
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
  next();
});

// Initialize Firebase
console.log('\n🔥 Initializing Firebase...\n');
initializeFirebase();

// Import routes
const workersRoutes = require('./routes/workers.routes');
const sosRoutes = require('./routes/sos.routes');
const drainageRoutes = require('./routes/drainage.routes');
const zonesRoutes = require('./routes/zones.routes');
const dashboardRoutes = require('./routes/dashboard.routes');
const chatbotRoutes = require('./routes/chatbot.routes');

// API Routes
app.use('/api/workers', workersRoutes);
app.use('/api/sos', sosRoutes);
app.use('/api/drainage', drainageRoutes);
app.use('/api/zones', zonesRoutes);
app.use('/api/dashboard', dashboardRoutes);
app.use('/api/chatbot', chatbotRoutes);

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({
    success: true,
    message: 'SMC Safety System API is running',
    version: '1.0.0',
    timestamp: new Date().toISOString(),
    firebase: isFirebaseInitialized() ? 'Connected' : 'Demo Mode',
    endpoints: {
      workers: '/api/workers',
      sos: '/api/sos',
      drainage: '/api/drainage',
      zones: '/api/zones',
      dashboard: '/api/dashboard',
      chatbot: '/api/chatbot'
    }
  });
});

// Root endpoint
app.get('/', (req, res) => {
  res.json({
    name: 'SMC Smart Safety & Assistance System',
    organization: 'Solapur Municipal Corporation',
    description: 'Backend API for sanitation worker safety monitoring',
    version: '1.0.0',
    documentation: '/api/health',
    status: 'operational'
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: 'Endpoint not found',
    path: req.path,
    availableEndpoints: '/api/health'
  });
});

// Error handling middleware
app.use((error, req, res, next) => {
  console.error('❌ Server error:', error);
  res.status(500).json({
    success: false,
    message: 'Internal server error',
    error: process.env.NODE_ENV === 'development' ? error.message : undefined
  });
});

/**
 * Initialize database with default data on startup
 */
const initializeDatabase = async () => {
  try {
    if (!isFirebaseInitialized()) {
      console.log('⚠️  Firebase not initialized - skipping database seeding');
      return;
    }

    const db = getDB();
    
    // Check if drainage assets already exist
    const assetsSnapshot = await db.collection('drainage_assets').limit(1).get();
    
    if (assetsSnapshot.empty) {
      console.log('📊 Initializing drainage assets...');
      
      // Generate 50 realistic Solapur drainage assets
      const assets = generateDrainageAssets(50);
      
      // Batch write to Firestore
      const batch = db.batch();
      assets.forEach(asset => {
        const ref = db.collection('drainage_assets').doc();
        batch.set(ref, asset);
      });
      
      await batch.commit();
      console.log('✅ Initialized 50 drainage assets');
    } else {
      console.log('✅ Drainage assets already exist');
    }

    // Initialize zones data
    const zonesSnapshot = await db.collection('zones').limit(1).get();
    if (zonesSnapshot.empty) {
      const zonesData = require('./data/solapur-zones.json');
      const batch = db.batch();
      zonesData.zones.forEach(zone => {
        const ref = db.collection('zones').doc(zone.zoneId);
        batch.set(ref, zone);
      });
      await batch.commit();
      console.log('✅ Initialized zones data');
    }

  } catch (error) {
    console.error('❌ Database initialization error:', error.message);
  }
};

// Start server
app.listen(PORT, async () => {
  console.log('\n' + '='.repeat(60));
  console.log('🏙️  SMC SMART SAFETY & ASSISTANCE SYSTEM');
  console.log('   Solapur Municipal Corporation');
  console.log('='.repeat(60));
  console.log(`\n🚀 Server running on: http://localhost:${PORT}`);
  console.log(`📡 API Base URL: http://localhost:${PORT}/api`);
  console.log(`📊 Health Check: http://localhost:${PORT}/api/health`);
  console.log(`\n⏰ Started at: ${new Date().toLocaleString('en-IN', { timeZone: 'Asia/Kolkata' })}`);
  console.log(`\n🔧 Environment: ${process.env.NODE_ENV || 'development'}`);
  
  if (isFirebaseInitialized()) {
    console.log('🔥 Firebase: Connected');
  } else {
    console.log('⚠️  Firebase: Demo Mode (in-memory storage)');
  }
  
  console.log('\n📚 Available Endpoints:');
  console.log('   POST /api/workers/checkin - Worker GPS check-in');
  console.log('   GET  /api/workers/all - Get all workers');
  console.log('   POST /api/sos/trigger - Trigger emergency SOS');
  console.log('   GET  /api/sos/recent - Get recent SOS events');
  console.log('   GET  /api/drainage/all - Get all drainage assets');
  console.log('   POST /api/drainage/add - Add drainage asset');
  console.log('   GET  /api/zones - Get Solapur zones');
  console.log('   GET  /api/dashboard/summary - Dashboard summary');
  console.log('   POST /api/chatbot/query - Chatbot query');
  
  console.log('\n' + '='.repeat(60) + '\n');
  
  // Initialize database with default data
  await initializeDatabase();
  
  console.log('✅ System ready for requests!\n');
});

// Graceful shutdown
process.on('SIGINT', () => {
  console.log('\n\n🛑 Shutting down gracefully...');
  process.exit(0);
});

process.on('SIGTERM', () => {
  console.log('\n\n🛑 Shutting down gracefully...');
  process.exit(0);
});

module.exports = app;
