import 'package:geolocator/geolocator.dart';
import '../core/constants/app_constants.dart';

class LocationService {
  static LocationService? _instance;
  Position? _lastPosition;

  static LocationService get instance {
    _instance ??= LocationService._();
    return _instance!;
  }

  LocationService._();

  Position? get lastPosition => _lastPosition;

  double get currentLat => _lastPosition?.latitude ?? AppConstants.defaultLat;
  double get currentLng => _lastPosition?.longitude ?? AppConstants.defaultLng;

  String getCurrentZone([double? lat]) {
    final latitude = lat ?? currentLat;
    if (latitude >= AppConstants.northZoneMinLat) {
      return AppConstants.northZone;
    } else if (latitude >= AppConstants.centralZoneMinLat) {
      return AppConstants.centralZone;
    } else {
      return AppConstants.southZone;
    }
  }

  String getZoneRisk([double? lat]) {
    final zone = getCurrentZone(lat);
    if (zone == AppConstants.northZone) return AppConstants.riskHigh;
    if (zone == AppConstants.centralZone) return AppConstants.riskMedium;
    return AppConstants.riskLow;
  }

  Future<bool> requestPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }
    if (permission == LocationPermission.deniedForever) return false;

    return true;
  }

  Future<Position?> getCurrentPosition() async {
    try {
      final hasPermission = await requestPermissions();
      if (!hasPermission) return null;

      _lastPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return _lastPosition;
    } catch (e) {
      return null;
    }
  }

  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
  }
}
