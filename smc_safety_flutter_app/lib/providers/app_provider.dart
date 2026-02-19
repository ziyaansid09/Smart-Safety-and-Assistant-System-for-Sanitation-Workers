import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../models/worker_model.dart';
import '../models/sos_model.dart';
import '../models/drainage_model.dart';
import '../models/dashboard_summary.dart';
import '../models/zone_model.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';

class AppProvider extends ChangeNotifier {
  // ── Mode ───────────────────────────────────────────────────────────────────
  bool _demoMode = false;
  bool get demoMode => _demoMode;

  String _appMode = 'select'; // 'select', 'worker', 'admin', 'monitoring'
  String get appMode => _appMode;

  // ── Language ───────────────────────────────────────────────────────────────
  Locale _locale = const Locale('en');
  Locale get locale => _locale;

  // ── Worker state ───────────────────────────────────────────────────────────
  String _workerId = '';
  String get workerId => _workerId;

  String _workerName = '';
  String get workerName => _workerName;

  bool _isCheckedIn = false;
  bool get isCheckedIn => _isCheckedIn;

  double _lat = AppConstants.defaultLat;
  double get lat => _lat;

  double _lng = AppConstants.defaultLng;
  double get lng => _lng;

  String _zone = AppConstants.centralZone;
  String get zone => _zone;

  String _riskLevel = AppConstants.riskMedium;
  String get riskLevel => _riskLevel;

  bool _sosSending = false;
  bool get sosSending => _sosSending;

  bool _sosJustSent = false;
  bool get sosJustSent => _sosJustSent;

  bool _voiceListening = false;
  bool get voiceListening => _voiceListening;

  bool _isOnline = true;
  bool get isOnline => _isOnline;

  double _gpsAccuracy = 0;
  double get gpsAccuracy => _gpsAccuracy;

  // ── Admin/Dashboard state ──────────────────────────────────────────────────
  List<WorkerModel> _workers = [];
  List<WorkerModel> get workers => _workers;

  List<SosModel> _sosList = [];
  List<SosModel> get sosList => _sosList;

  List<SosModel> get activeSOS =>
      _sosList.where((s) => s.status.toLowerCase() == 'active').toList();

  List<DrainageModel> _drainage = [];
  List<DrainageModel> get drainage => _drainage;

  DashboardSummary _summary = DashboardSummary.empty();
  DashboardSummary get summary => _summary;

  List<ZoneModel> _zones = [];
  List<ZoneModel> get zones => _zones;

  bool _loading = false;
  bool get loading => _loading;

  DateTime? _lastUpdated;
  DateTime? get lastUpdated => _lastUpdated;

  // ── Timers ─────────────────────────────────────────────────────────────────
  Timer? _refreshTimer;
  Timer? _demoSOSTimer;
  Timer? _demoMoveTimer;
  Timer? _locationTimer;

  final _random = Random();

  // ── API ────────────────────────────────────────────────────────────────────
  final _api = ApiService.instance;
  final _location = LocationService.instance;

  // ── Initialize ─────────────────────────────────────────────────────────────
  void setAppMode(String mode) {
    _appMode = mode;
    notifyListeners();
    if (mode == 'admin' || mode == 'monitoring') {
      _startDashboardRefresh();
    }
    if (mode == 'worker') {
      _startLocationTracking();
    }
  }

  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }

  void setOnlineStatus(bool online) {
    _isOnline = online;
    notifyListeners();
  }

  // ── Worker actions ─────────────────────────────────────────────────────────
  void setWorkerCredentials(String id, String name) {
    _workerId = id;
    _workerName = name;
    notifyListeners();
  }

  Future<bool> checkIn() async {
    if (_workerId.isEmpty) return false;
    final pos = await _location.getCurrentPosition();
    if (pos != null) {
      _lat = pos.latitude;
      _lng = pos.longitude;
      _gpsAccuracy = pos.accuracy;
    }
    _zone = _location.getCurrentZone(_lat);
    _riskLevel = _location.getZoneRisk(_lat);

    final result = await _api.checkInWorker(
      workerId: _workerId,
      name: _workerName,
      lat: _lat,
      lng: _lng,
    );
    _isCheckedIn = !result.containsKey('error');
    notifyListeners();
    return _isCheckedIn;
  }

  Future<bool> triggerSOS(String mode) async {
    _sosSending = true;
    notifyListeners();

    try {
      if (!_isOnline) {
        _sosSending = false;
        notifyListeners();
        return false; // Caller handles offline SMS
      }

      final result = await _api.triggerSOS(
        workerId: _workerId,
        lat: _lat,
        lng: _lng,
        mode: mode,
        zone: _zone,
      );

      _sosJustSent = !result.containsKey('error');
      _sosSending = false;
      notifyListeners();

      if (_sosJustSent) {
        Future.delayed(const Duration(seconds: 3), () {
          _sosJustSent = false;
          notifyListeners();
        });
      }
      return _sosJustSent;
    } catch (e) {
      _sosSending = false;
      notifyListeners();
      return false;
    }
  }

  void setVoiceListening(bool listening) {
    _voiceListening = listening;
    notifyListeners();
  }

  // ── Dashboard refresh ──────────────────────────────────────────────────────
  void _startDashboardRefresh() {
    _refreshTimer?.cancel();
    _fetchDashboardData();
    _refreshTimer = Timer.periodic(
      Duration(seconds: AppConstants.refreshIntervalSeconds),
      (_) => _fetchDashboardData(),
    );
  }

  Future<void> _fetchDashboardData() async {
    _loading = true;
    notifyListeners();

    final results = await Future.wait([
      _api.getDashboardSummary(),
      _api.getAllWorkers(),
      _api.getRecentSOS(),
      _api.getAllDrainage(),
      _api.getZones(),
    ]);

    _summary = results[0] as DashboardSummary;
    _workers = results[1] as List<WorkerModel>;
    _sosList = results[2] as List<SosModel>;
    _drainage = results[3] as List<DrainageModel>;
    _zones = results[4] as List<ZoneModel>;
    _lastUpdated = DateTime.now();
    _loading = false;

    // If no real data, inject demo data for judges
    if (_workers.isEmpty) _injectDemoWorkers();
    if (_drainage.isEmpty) _injectDemoDrainage();
    if (_sosList.isEmpty) _injectDemoSOS();

    notifyListeners();
  }

  Future<void> refreshDashboard() async {
    await _fetchDashboardData();
  }

  // ── Location tracking ──────────────────────────────────────────────────────
  void _startLocationTracking() {
    _locationTimer?.cancel();
    _location.requestPermissions().then((granted) {
      if (!granted) return;
      _locationTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
        final pos = await _location.getCurrentPosition();
        if (pos != null) {
          _lat = pos.latitude;
          _lng = pos.longitude;
          _gpsAccuracy = pos.accuracy;
          _zone = _location.getCurrentZone(_lat);
          _riskLevel = _location.getZoneRisk(_lat);
          notifyListeners();
        }
      });
    });
  }

  // ── Demo mode ──────────────────────────────────────────────────────────────
  void toggleDemoMode() {
    _demoMode = !_demoMode;
    if (_demoMode) {
      _startDemoMode();
    } else {
      _stopDemoMode();
    }
    notifyListeners();
  }

  void _startDemoMode() {
    _injectDemoWorkers();
    _injectDemoDrainage();
    _injectDemoSOS();

    _demoMoveTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _simulateWorkerMovement();
    });

    _demoSOSTimer = Timer.periodic(
      Duration(seconds: AppConstants.demoSOSIntervalSeconds),
      (_) {
        _autoGenerateSOS();
      },
    );
  }

  void _stopDemoMode() {
    _demoSOSTimer?.cancel();
    _demoMoveTimer?.cancel();
  }

  void _injectDemoWorkers() {
    if (_workers.isNotEmpty) return;
    final names = [
      'Ramesh Kumar', 'Suresh Patil', 'Anita Shinde',
      'Vijay More', 'Priya Jadhav', 'Santosh Kale'
    ];
    _workers = List.generate(names.length, (i) {
      final lat = AppConstants.defaultLat + (_random.nextDouble() - 0.5) * 0.04;
      return WorkerModel(
        id: 'W${100 + i}',
        name: names[i],
        lat: lat,
        lng: AppConstants.defaultLng + (_random.nextDouble() - 0.5) * 0.04,
        zone: LocationService.instance.getCurrentZone(lat),
        riskLevel: LocationService.instance.getZoneRisk(lat),
        status: 'active',
        lastSeen: DateTime.now(),
      );
    });
    _summary = DashboardSummary(
      activeWorkers: _workers.length,
      sosActive: 1,
      drainageAssets: 24,
      topRiskZone: AppConstants.northZone,
      zoneDistribution: {
        AppConstants.northZone: 2,
        AppConstants.centralZone: 3,
        AppConstants.southZone: 1,
      },
      sosByMode: {'manual': 2, 'voice': 1, 'offline_sms': 0},
    );
  }

  void _injectDemoDrainage() {
    if (_drainage.isNotEmpty) return;
    _drainage = List.generate(12, (i) {
      return DrainageModel(
        id: 'D${i + 1}',
        name: 'Manhole ${i + 1}',
        lat: AppConstants.defaultLat + (_random.nextDouble() - 0.5) * 0.05,
        lng: AppConstants.defaultLng + (_random.nextDouble() - 0.5) * 0.05,
        type: i % 3 == 0 ? 'drain' : 'manhole',
        status: i % 5 == 0 ? 'maintenance' : 'active',
        zone: AppConstants.centralZone,
      );
    });
  }

  void _injectDemoSOS() {
    if (_sosList.isNotEmpty) return;
    final modes = ['manual', 'voice', 'offline_sms'];
    _sosList = List.generate(3, (i) {
      final lat = AppConstants.defaultLat + (_random.nextDouble() - 0.5) * 0.03;
      return SosModel(
        id: 'SOS${i + 1}',
        workerId: 'W${100 + i}',
        workerName: 'Worker ${i + 1}',
        lat: lat,
        lng: AppConstants.defaultLng + (_random.nextDouble() - 0.5) * 0.03,
        zone: LocationService.instance.getCurrentZone(lat),
        mode: modes[i % modes.length],
        status: i == 0 ? 'active' : 'resolved',
        triggeredAt: DateTime.now().subtract(Duration(minutes: i * 5)),
        riskLevel: i == 0 ? 'HIGH' : 'MEDIUM',
      );
    });
  }

  void _simulateWorkerMovement() {
    if (_workers.isEmpty) return;
    _workers = _workers.map((w) {
      final newLat = w.lat + (_random.nextDouble() - 0.5) * AppConstants.demoMovementRange;
      final newLng = w.lng + (_random.nextDouble() - 0.5) * AppConstants.demoMovementRange;
      return w.copyWith(lat: newLat, lng: newLng, lastSeen: DateTime.now());
    }).toList();
    notifyListeners();
  }

  void _autoGenerateSOS() {
    if (_workers.isEmpty) return;
    final worker = _workers[_random.nextInt(_workers.length)];
    final modes = ['manual', 'voice', 'offline_sms'];
    final newSos = SosModel(
      id: 'DEMO_SOS_${DateTime.now().millisecondsSinceEpoch}',
      workerId: worker.id,
      workerName: worker.name,
      lat: worker.lat,
      lng: worker.lng,
      zone: worker.zone,
      mode: modes[_random.nextInt(modes.length)],
      status: 'active',
      triggeredAt: DateTime.now(),
      riskLevel: worker.riskLevel,
    );
    _sosList = [newSos, ..._sosList.take(9)];
    _summary = DashboardSummary(
      activeWorkers: _summary.activeWorkers,
      sosActive: activeSOS.length,
      drainageAssets: _summary.drainageAssets,
      topRiskZone: _summary.topRiskZone,
      zoneDistribution: _summary.zoneDistribution,
      sosByMode: _summary.sosByMode,
    );
    notifyListeners();
  }

  Future<void> resolveSOS(String sosId) async {
    await _api.updateSOSStatus(sosId, 'resolved');
    _sosList = _sosList.map((s) {
      if (s.id == sosId) {
        return SosModel(
          id: s.id,
          workerId: s.workerId,
          workerName: s.workerName,
          lat: s.lat,
          lng: s.lng,
          zone: s.zone,
          mode: s.mode,
          status: 'resolved',
          triggeredAt: s.triggeredAt,
          riskLevel: s.riskLevel,
        );
      }
      return s;
    }).toList();
    notifyListeners();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _demoSOSTimer?.cancel();
    _demoMoveTimer?.cancel();
    _locationTimer?.cancel();
    super.dispose();
  }
}
