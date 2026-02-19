/**
 * Firebase Admin SDK Configuration
 * Handles connection to Firebase Firestore database
 */

const admin = require('firebase-admin');
const path = require('path');
require('dotenv').config();

let db = null;
let isInitialized = false;

/**
 * Initialize Firebase Admin SDK
 * Attempts to load service account key from file
 * Falls back to demo mode if not found
 */
const initializeFirebase = () => {
  try {
    if (isInitialized) {
      console.log('⚠️  Firebase already initialized');
      return db;
    }

    // Try to load service account key
    let serviceAccount;
    const serviceAccountPath = process.env.FIREBASE_SERVICE_ACCOUNT_PATH || './firebase-service-account.json';
    
    try {
      serviceAccount = require(path.resolve(serviceAccountPath));
      console.log('✅ Service account key loaded successfully');
    } catch (error) {
      console.log('⚠️  No firebase-service-account.json found');
      console.log('📝 To use real Firebase:');
      console.log('   1. Go to Firebase Console > Project Settings > Service Accounts');
      console.log('   2. Click "Generate New Private Key"');
      console.log('   3. Save as firebase-service-account.json in project root');
      console.log('');
      console.log('🔧 Running in DEMO MODE with in-memory storage');
      return null;
    }

    // Initialize Firebase Admin
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount)
    });

    // Get Firestore instance
    db = admin.firestore();
    
    // Configure Firestore settings
    db.settings({
      timestampsInSnapshots: true,
      ignoreUndefinedProperties: true
    });

    isInitialized = true;
    console.log('✅ Firebase Firestore connected successfully');
    return db;

  } catch (error) {
    console.error('❌ Firebase initialization failed:', error.message);
    console.log('💡 Make sure your firebase-service-account.json is valid');
    return null;
  }
};

/**
 * Get Firestore database instance
 */
const getDB = () => {
  if (!db && !isInitialized) {
    return initializeFirebase();
  }
  return db;
};

/**
 * Get Firebase Admin instance
 */
const getAdmin = () => {
  return admin;
};

/**
 * Check if Firebase is properly initialized
 */
const isFirebaseInitialized = () => {
  return isInitialized && db !== null;
};

module.exports = {
  initializeFirebase,
  getDB,
  getAdmin,
  isFirebaseInitialized
};
