class AppConstants {
  // API
  static const String baseUrl = 'http://localhost:5000/api';

  // Map defaults - Solapur
  static const double defaultLat = 17.6599;
  static const double defaultLng = 75.9064;
  static const double defaultZoom = 13.0;

  // Zone thresholds
  static const double northZoneMinLat = 17.67;
  static const double centralZoneMinLat = 17.64;

  // Zone names
  static const String northZone = 'North Solapur';
  static const String centralZone = 'Central Solapur';
  static const String southZone = 'South Solapur';

  // Risk levels
  static const String riskHigh = 'HIGH';
  static const String riskMedium = 'MEDIUM';
  static const String riskLow = 'LOW';

  // Emergency contacts
  static const String policeNumber = '112';
  static const String policeAlt = '100';
  static const String ambulanceNumber = '108';
  static const String fireNumber = '101';

  // SOS modes
  static const String sosModeManual = 'manual';
  static const String sosModeVoice = 'voice';
  static const String sosModeOfflineSms = 'offline_sms';

  // Voice SOS keywords
  static const List<String> sosKeywordsEn = ['sos', 'help'];
  static const List<String> sosKeywordsHi = ['madad', 'सहायता'];
  static const List<String> sosKeywordsMr = ['madat', 'मदत'];

  // Dashboard refresh interval
  static const int refreshIntervalSeconds = 5;

  // Demo mode
  static const int demoSOSIntervalSeconds = 15;
  static const double demoMovementRange = 0.005;

  // SOS SMS template
  static const String sosSmsTemplate = 'SOS|{workerId}|{lat},{lng}|{zone}|{timestamp}';

  // Colors (hex)
  static const int colorGreen = 0xFF00E676;
  static const int colorYellow = 0xFFFFD600;
  static const int colorRed = 0xFFFF1744;
  static const int colorBackground = 0xFF0A0E1A;
  static const int colorSurface = 0xFF111827;
  static const int colorCard = 0xFF1A2332;
  static const int colorAccent = 0xFF00B4D8;
  static const int colorText = 0xFFE2E8F0;
  static const int colorTextMuted = 0xFF64748B;
}
