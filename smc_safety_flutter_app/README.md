# SMC Smart Safety Platform — Flutter Frontend

> **Solapur Municipal Corporation Smart Safety & Assistance System**
> Real-time GPS monitoring, SOS alerting, multilingual support, and risk zone visualization for sanitation workers.

---

## 🚀 Quick Start

### Prerequisites

- Flutter SDK ≥ 3.0.0
- Dart SDK ≥ 3.0.0
- Android Studio / Xcode
- Google Maps API Key

---

## 📦 Installation

```bash
# 1. Navigate to project folder
cd smc_safety_flutter_app

# 2. Install dependencies
flutter pub get

# 3. Generate localizations
flutter gen-l10n

# 4. Run the app
flutter run
```

---

## 🗺 Google Maps API Key Setup

### Android
Edit `android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_ACTUAL_KEY_HERE" />
```

### iOS
Edit `ios/Runner/AppDelegate.swift`:
```swift
GMSServices.provideAPIKey("YOUR_ACTUAL_KEY_HERE")
```

**To get an API Key:**
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Enable **Maps SDK for Android** and **Maps SDK for iOS**
3. Create credentials → API Key
4. Restrict key to your app bundle ID / SHA-1

---

## 🔌 Backend Connection

The app connects to:
```
http://localhost:5000/api
```

For physical devices, update `lib/core/constants/app_constants.dart`:
```dart
static const String baseUrl = 'http://YOUR_LOCAL_IP:5000/api';
```

Find your local IP:
```bash
# Mac/Linux
ifconfig | grep "inet "

# Windows
ipconfig
```

For Android emulator, use `10.0.2.2` instead of `localhost`.

---

## 📱 App Modes

### 👷 Worker Field App
- Large animated SOS button
- Voice SOS (say "help", "SOS", "madad", "madat")
- Offline SMS fallback when no internet
- Live GPS tracking with zone display
- Emergency contacts (Police 112, Ambulance 108, Fire 101)

### 🧑‍💼 Admin Dashboard
- Live satellite map with worker markers
- Animated blinking SOS markers
- KPI analytics strip
- Live SOS feed with resolve functionality
- Zone risk visualization with overlays
- Auto-refreshes every 5 seconds

### 🌐 Public Monitoring
- Read-only aggregated statistics
- Zone map with drainage markers
- No personal worker data exposed

---

## 🎮 Demo Mode

Toggle **Demo Mode** in the Admin Dashboard appbar or Settings:

- Simulates 6 workers moving in real time
- Auto-generates SOS alerts every 15 seconds
- No backend required
- Perfect for hackathon demonstrations

---

## 🌍 Language Support

The app supports three languages:
- 🇬🇧 English (`en`)
- 🇮🇳 Hindi (`hi`) — हिंदी
- 🇮🇳 Marathi (`mr`) — मराठी

Change in **Settings** screen.

---

## 🏗 Project Structure

```
lib/
├── core/
│   ├── constants/      → AppConstants (API URL, zone thresholds, colors)
│   ├── theme/          → AppTheme (dark smart-city theme)
│   └── localization/   → ARB files (en, hi, mr)
├── models/             → WorkerModel, SOSModel, DrainageModel, etc.
├── services/
│   ├── api_service.dart    → Centralized REST client (Dio)
│   └── location_service.dart → GPS + zone detection
├── providers/
│   └── app_provider.dart   → State management (Provider)
├── screens/
│   ├── worker/         → Worker check-in + home (SOS interface)
│   ├── admin/          → Admin dashboard + chatbot + settings
│   └── monitoring/     → Public monitoring view
├── widgets/            → Reusable UI components
└── main.dart           → Entry point + router
```

---

## 🗺 Zone Logic

| Zone | Latitude | Risk | Color |
|------|----------|------|-------|
| North Solapur | ≥ 17.67 | HIGH | 🔴 Red |
| Central Solapur | 17.64–17.67 | MEDIUM | 🟡 Yellow |
| South Solapur | < 17.64 | LOW | 🟢 Green |

---

## 📡 API Endpoints Used

| Method | Endpoint | Used By |
|--------|----------|---------|
| POST | /workers/checkin | Worker check-in |
| GET | /workers/all | Admin map |
| POST | /sos/trigger | SOS button |
| GET | /sos/recent | SOS feed |
| PUT | /sos/:id/status | Resolve SOS |
| GET | /dashboard/summary | KPI cards |
| GET | /drainage/all | Map markers |
| GET | /zones | Zone overlays |
| POST | /chatbot/query | AI assistant |

---

## 🎯 Demo Flow for Judges

1. **Launch app** → Mode selection screen
2. **Select Admin Dashboard** → Enable Demo Mode
3. See live worker movement on satellite map
4. Watch SOS alerts auto-generate every 15 seconds
5. Check Analytics tab for KPI cards and charts
6. Switch to Worker App → Check in as W101 / Ramesh Kumar
7. Press the large red SOS button
8. Toggle Voice SOS → say "help"
9. Try language switching (EN/HI/MR) in Settings
10. Switch to Public Monitoring for read-only view

---

## 🛠 Troubleshooting

**Map not loading:** Add your Google Maps API key as described above.

**Backend not connecting:** Ensure Node.js backend is running on port 5000. For emulators, use `10.0.2.2:5000`.

**Location not working:** Accept location permissions when prompted. For emulators, set a mock location in Extended Controls.

**Speech not working:** Accept microphone permission. Works best on physical device.

---

## 📄 License

Solapur Municipal Corporation Smart Safety Platform — Hackathon Project 2024
