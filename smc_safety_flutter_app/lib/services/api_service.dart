import 'package:dio/dio.dart';
import '../core/constants/app_constants.dart';
import '../models/worker_model.dart';
import '../models/sos_model.dart';
import '../models/drainage_model.dart';
import '../models/dashboard_summary.dart';
import '../models/zone_model.dart';

class ApiService {
  late final Dio _dio;
  static ApiService? _instance;

  static ApiService get instance {
    _instance ??= ApiService._();
    return _instance!;
  }

  ApiService._() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  }

  // ── Dashboard ──────────────────────────────────────────────────────────────
  Future<DashboardSummary> getDashboardSummary() async {
    try {
      final response = await _dio.get('/dashboard/summary');
      if (response.data is Map) {
        return DashboardSummary.fromJson(response.data as Map<String, dynamic>);
      }
      return DashboardSummary.empty();
    } catch (e) {
      return DashboardSummary.empty();
    }
  }

  // ── Workers ────────────────────────────────────────────────────────────────
  Future<List<WorkerModel>> getAllWorkers() async {
    try {
      final response = await _dio.get('/workers/all');
      final List data = response.data is List
          ? response.data
          : (response.data['workers'] ?? []);
      return data.map((w) => WorkerModel.fromJson(w)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<WorkerModel?> getWorker(String workerId) async {
    try {
      final response = await _dio.get('/workers/$workerId');
      return WorkerModel.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>> checkInWorker({
    required String workerId,
    required String name,
    required double lat,
    required double lng,
  }) async {
    try {
      final response = await _dio.post('/workers/checkin', data: {
        'workerId': workerId,
        'name': name,
        'lat': lat,
        'lng': lng,
      });
      return response.data ?? {};
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  // ── SOS ───────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> triggerSOS({
    required String workerId,
    required double lat,
    required double lng,
    required String mode,
    String? zone,
  }) async {
    try {
      final response = await _dio.post('/sos/trigger', data: {
        'workerId': workerId,
        'lat': lat,
        'lng': lng,
        'mode': mode,
        if (zone != null) 'zone': zone,
      });
      return response.data ?? {'success': true};
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  Future<List<SosModel>> getRecentSOS() async {
    try {
      final response = await _dio.get('/sos/recent');
      final List data = response.data is List
          ? response.data
          : (response.data['sos'] ?? response.data['alerts'] ?? []);
      return data.map((s) => SosModel.fromJson(s)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> updateSOSStatus(String sosId, String status) async {
    try {
      await _dio.put('/sos/$sosId/status', data: {'status': status});
      return true;
    } catch (e) {
      return false;
    }
  }

  // ── Drainage ───────────────────────────────────────────────────────────────
  Future<List<DrainageModel>> getAllDrainage() async {
    try {
      final response = await _dio.get('/drainage/all');
      final List data = response.data is List
          ? response.data
          : (response.data['drainage'] ?? response.data['assets'] ?? []);
      return data.map((d) => DrainageModel.fromJson(d)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<DrainageModel>> getNearbyDrainage(double lat, double lng) async {
    try {
      final response = await _dio.get('/drainage/nearby', queryParameters: {
        'lat': lat,
        'lng': lng,
      });
      final List data = response.data is List ? response.data : [];
      return data.map((d) => DrainageModel.fromJson(d)).toList();
    } catch (e) {
      return [];
    }
  }

  // ── Zones ──────────────────────────────────────────────────────────────────
  Future<List<ZoneModel>> getZones() async {
    try {
      final response = await _dio.get('/zones');
      final List data = response.data is List
          ? response.data
          : (response.data['zones'] ?? []);
      return data.map((z) => ZoneModel.fromJson(z)).toList();
    } catch (e) {
      return [];
    }
  }

  // ── Chatbot ────────────────────────────────────────────────────────────────
  Future<String> queryChatbot(String query, {String language = 'en'}) async {
    try {
      final response = await _dio.post('/chatbot/query', data: {
        'query': query,
        'language': language,
      });
      return response.data['reply']?.toString() ??
          response.data['response']?.toString() ??
          'No response from server.';
    } catch (e) {
      return 'Unable to connect to server. Please check your connection.';
    }
  }
}
