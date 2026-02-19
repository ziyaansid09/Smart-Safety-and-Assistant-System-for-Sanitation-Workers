# 🏙️ SMC Smart Safety & Assistance System - Backend API

## Solapur Municipal Corporation - Hackathon Project

Complete production-ready backend system for sanitation worker safety monitoring with GPS tracking, SOS alerts, multilingual support, and municipal analytics.

---

## 🚀 Quick Start (2 Minutes)

```bash
# 1. Install dependencies
npm install

# 2. Start server
npm start

# Server will run on http://localhost:5000
```

**That's it!** The system runs in demo mode without Firebase.

---

## 🔥 Firebase Setup (Optional but Recommended)

### Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click **"Add project"**
3. Enter project name: `smc-safety-system`
4. Disable Google Analytics (optional)
5. Click **"Create project"**

### Step 2: Enable Firestore

1. In Firebase Console, go to **"Build" → "Firestore Database"**
2. Click **"Create database"**
3. Select **"Start in test mode"**
4. Choose location closest to India (e.g., `asia-south1`)
5. Click **"Enable"**

### Step 3: Get Service Account Key

1. Go to **Project Settings** (gear icon)
2. Navigate to **"Service accounts"** tab
3. Click **"Generate new private key"**
4. Click **"Generate key"** in confirmation dialog
5. A JSON file will download automatically

### Step 4: Configure Backend

1. Rename downloaded file to: `firebase-service-account.json`
2. Place it in project root:
   ```
   smc-safety-backend/
   ├── firebase-service-account.json  ← HERE
   ├── server.js
   ├── package.json
   └── ...
   ```

3. Copy `.env.example` to `.env`:
   ```bash
   cp .env.example .env
   ```

4. Start server:
   ```bash
   npm start
   ```

You should see: `✅ Firebase Firestore connected successfully`

---

## 📦 Project Structure

```
smc-safety-backend/
├── package.json                 # Dependencies
├── server.js                    # Main server entry point
├── .env.example                 # Environment variables template
├── firebase-service-account.json # Your Firebase credentials (add this)
├── config/
│   └── firebase.js             # Firebase configuration
├── controllers/
│   ├── workers.controller.js   # Worker GPS tracking
│   ├── sos.controller.js       # Emergency SOS handling
│   ├── drainage.controller.js  # Drainage assets management
│   ├── zones.controller.js     # Solapur zone info
│   ├── dashboard.controller.js # Analytics dashboard
│   └── chatbot.controller.js   # Multilingual chatbot
├── routes/
│   ├── workers.routes.js
│   ├── sos.routes.js
│   ├── drainage.routes.js
│   ├── zones.routes.js
│   ├── dashboard.routes.js
│   └── chatbot.routes.js
├── utils/
│   ├── zones.js                # Solapur zone detection
│   ├── i18n.js                 # Multilingual support (EN/HI/MR)
│   └── maps.js                 # Drainage asset generator
├── services/
│   └── sms.js                  # Twilio SMS (optional)
├── data/
│   ├── solapur-zones.json      # Hardcoded zones data
│   └── datasets.json           # Municipal datasets
├── postman/
│   └── smc-safety-api.json     # Postman collection
└── README.md                    # This file
```

---

## 🔌 API Endpoints

### Workers (GPS Tracking)

**POST /api/workers/checkin**
```json
{
  "workerId": "W001",
  "name": "Ramesh Patil",
  "lat": 17.6799,
  "lng": 75.9088,
  "lang": "mr"
}
```

**GET /api/workers/all**
- Returns all active workers with locations

**GET /api/workers/:workerId**
- Get specific worker details

**GET /api/workers/:workerId/history**
- Get GPS location history

### SOS (Emergency Alerts)

**POST /api/sos/trigger**
```json
{
  "workerId": "W001",
  "lat": 17.6799,
  "lng": 75.9088,
  "mode": "manual",
  "lang": "mr"
}
```
Modes: `manual`, `voice`, `offline_sms`

**GET /api/sos/recent?limit=50**
- Get recent SOS events

**PUT /api/sos/:sosId/status**
```json
{
  "status": "RESPONDED"
}
```
Status: `ACTIVE`, `RESPONDED`, `RESOLVED`

### Drainage Assets

**GET /api/drainage/all**
- Get all 50 drainage assets (auto-generated)

**POST /api/drainage/add**
```json
{
  "type": "manhole",
  "lat": 17.6650,
  "lng": 75.9000,
  "name": "Manhole-Central-001"
}
```

**GET /api/drainage/nearby?lat=17.67&lng=75.90&limit=5**
- Find nearest drainage assets

### Zones

**GET /api/zones**
- Get all Solapur zones (North/Central/South)

### Dashboard

**GET /api/dashboard/summary**
- Complete dashboard statistics
- Worker counts, SOS events, zone stats
- Municipal datasets

### Chatbot

**POST /api/chatbot/query**
```json
{
  "query": "show worker status",
  "lang": "en"
}
```

---

## 🌍 Solapur Risk Zones

Automatic detection based on GPS coordinates:

| Zone | Latitude Range | Risk Level | Color |
|------|---------------|------------|-------|
| **North Solapur** | >= 17.67 | HIGH | Red (#FF6B6B) |
| **Central Solapur** | 17.64 - 17.67 | MEDIUM | Yellow (#FFD93D) |
| **South Solapur** | < 17.64 | LOW | Green (#6BCB77) |

---

## 🗣️ Multilingual Support

Supported languages:
- **English (en)** - Default
- **Hindi (hi)** - हिन्दी
- **Marathi (mr)** - मराठी

All API responses localized based on `lang` parameter.

Voice keywords for SOS:
- English: `sos`, `help`, `emergency`
- Hindi: `madad`, `सहायता`, `bachao`
- Marathi: `madat`, `मदत`, `वाचवा`

---

## 📞 Emergency Contacts

Hardcoded for Solapur:
- **Police**: 112 / 100
- **Ambulance**: 108 / 112
- **Fire**: 101 / 112

---

## ⚡ Features

### ✅ Implemented

1. **GPS Worker Tracking**
   - Real-time location check-ins
   - Automatic zone detection
   - Location history logging

2. **Triple SOS System**
   - Manual SOS trigger
   - Voice command detection
   - Offline SMS support

3. **Solapur Risk Zoning**
   - Hardcoded lat/lng based zones
   - Automatic risk assessment
   - Fatal zone alerts

4. **Sewage & Drainage Mapping**
   - 50 auto-generated realistic assets
   - Types: manholes, drains, sewers
   - Risk tagging: NORMAL/HIGH/FATAL

5. **Multilingual System**
   - EN / HI / MR support
   - Localized responses
   - Voice keyword detection

6. **Safety Rules**
   - Auto-alerts for fatal zones
   - Worker inactivity detection
   - Risk-based notifications

7. **Rule-based Chatbot**
   - Worker status queries
   - Emergency procedures
   - Safety information

8. **Municipal Analytics**
   - Dashboard summaries
   - Zone statistics
   - Industry datasets

---

## 🧪 Testing

### Using Postman

1. Import collection: `postman/smc-safety-api.json`
2. Set base URL: `http://localhost:5000`
3. Test endpoints in order:
   - Health check
   - Worker check-in
   - Trigger SOS
   - Get zones
   - Dashboard summary

### Using curl

```bash
# Health check
curl http://localhost:5000/api/health

# Worker check-in
curl -X POST http://localhost:5000/api/workers/checkin \
  -H "Content-Type: application/json" \
  -d '{"workerId":"W001","name":"Test Worker","lat":17.67,"lng":75.90,"lang":"en"}'

# Trigger SOS
curl -X POST http://localhost:5000/api/sos/trigger \
  -H "Content-Type: application/json" \
  -d '{"workerId":"W001","lat":17.67,"lng":75.90,"mode":"manual","lang":"en"}'

# Get zones
curl http://localhost:5000/api/zones

# Dashboard
curl http://localhost:5000/api/dashboard/summary
```

---

## 📱 SMS Integration (Optional)

### Setup Twilio

1. Sign up at [Twilio](https://www.twilio.com)
2. Get Account SID and Auth Token
3. Get a Twilio phone number
4. Add to `.env`:
   ```
   TWILIO_ACCOUNT_SID=your_sid_here
   TWILIO_AUTH_TOKEN=your_token_here
   TWILIO_PHONE_NUMBER=+1234567890
   ```

SMS will be sent automatically on SOS triggers.

---

## 🎬 2-Minute Hackathon Demo

### Demo Script

**Minute 1: System Overview**
1. Start server: `npm start`
2. Show: "System ready" message
3. Open: `http://localhost:5000/api/health`
4. Explain: Backend for Solapur Municipal Corporation

**Minute 2: Live Demo**
1. **Worker Check-in**
   - Show Postman POST `/api/workers/checkin`
   - Lat: 17.6799 (North Solapur - HIGH RISK)
   - Response: Zone detected, warning shown

2. **SOS Trigger**
   - Show Postman POST `/api/sos/trigger`
   - Mode: manual, Language: mr (Marathi)
   - Response: Localized confirmation

3. **Dashboard**
   - Show GET `/api/dashboard/summary`
   - Display: Worker counts, zones, assets

4. **Chatbot**
   - Show POST `/api/chatbot/query`
   - Query: "emergency procedure"
   - Response: Multilingual procedure steps

5. **Firebase Console** (if setup)
   - Show live data in Firestore
   - Collections: workers, sos_events, drainage_assets

---

## 🐛 Troubleshooting

### Firebase Connection Issues

**Error**: "Firebase initialization failed"
```bash
# Check if service account file exists
ls firebase-service-account.json

# Make sure filename is exactly: firebase-service-account.json
```

### Port Already in Use

**Error**: "Port 5000 already in use"
```bash
# Change port in .env
echo "PORT=5001" >> .env

# Or kill process on port 5000
# Mac/Linux: lsof -ti:5000 | xargs kill -9
# Windows: netstat -ano | findstr :5000, then taskkill /PID <PID> /F
```

### Module Not Found

**Error**: "Cannot find module 'express'"
```bash
# Reinstall dependencies
rm -rf node_modules package-lock.json
npm install
```

---

## 📊 System Requirements

- **Node.js**: v16 or higher
- **npm**: v7 or higher
- **Firebase**: Account (free tier)
- **Internet**: Required for Firebase (optional in demo mode)

---

## 🔐 Security Notes

### For Development/Hackathon:
- ✅ Test mode Firestore rules OK
- ✅ Service account key in project OK
- ⚠️ Don't commit service account key to GitHub

### For Production:
- ❌ Never use test mode Firestore
- ✅ Implement proper security rules
- ✅ Use environment variables
- ✅ Enable Firebase Authentication
- ✅ Set up rate limiting

---

## 📝 Environment Variables

```bash
# Server
PORT=5000
NODE_ENV=development

# Firebase
FIREBASE_SERVICE_ACCOUNT_PATH=./firebase-service-account.json

# Twilio (Optional)
TWILIO_ACCOUNT_SID=your_sid
TWILIO_AUTH_TOKEN=your_token
TWILIO_PHONE_NUMBER=+1234567890

# Safety Settings
WORKER_INACTIVE_THRESHOLD_MINUTES=15
FATAL_ZONE_ALERT_ENABLED=true

# Default Language
DEFAULT_LANGUAGE=en
```

---

## 🎯 Hackathon Ready!

This backend is:
- ✅ Complete and production-ready
- ✅ Fully commented for learning
- ✅ Works immediately after `npm start`
- ✅ Runs in demo mode without Firebase
- ✅ All endpoints functional
- ✅ Multilingual support built-in
- ✅ Municipal data included
- ✅ Postman collection provided

---

## 👥 Team Credits

**Project**: SMC Smart Safety & Assistance System  
**Organization**: Solapur Municipal Corporation  
**Purpose**: Hackathon - Samved 2024  
**Tech Stack**: Node.js, Express, Firebase, Twilio  

---

## 📧 Support

For issues or questions:
1. Check troubleshooting section
2. Review API endpoint examples
3. Test with Postman collection
4. Check Firebase Console for data

---

**Built with ❤️ for Solapur Municipal Corporation**

