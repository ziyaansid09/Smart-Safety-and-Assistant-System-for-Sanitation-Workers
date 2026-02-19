import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/worker_model.dart';
import '../models/sos_model.dart';
import '../models/drainage_model.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';

class SMCMap extends StatefulWidget {
  final List<WorkerModel> workers;
  final List<SosModel> sosList;
  final List<DrainageModel> drainage;
  final bool satelliteMode;
  final bool showHeatmap;

  const SMCMap({
    super.key,
    required this.workers,
    required this.sosList,
    required this.drainage,
    this.satelliteMode = true,
    this.showHeatmap = false,
  });

  @override
  State<SMCMap> createState() => _SMCMapState();
}

class _SMCMapState extends State<SMCMap> {
  GoogleMapController? _controller;
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};
  Set<Polygon> _polygons = {};
  Timer? _blinkTimer;
  bool _blinkOn = true;

  static const CameraPosition _defaultCamera = CameraPosition(
    target: LatLng(AppConstants.defaultLat, AppConstants.defaultLng),
    zoom: AppConstants.defaultZoom,
  );

  @override
  void initState() {
    super.initState();
    _startBlinkTimer();
  }

  @override
  void didUpdateWidget(SMCMap old) {
    super.didUpdateWidget(old);
    _buildMarkers();
  }

  void _startBlinkTimer() {
    _blinkTimer = Timer.periodic(const Duration(milliseconds: 600), (_) {
      setState(() {
        _blinkOn = !_blinkOn;
        _buildMarkers();
      });
    });
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  void _buildMarkers() {
    final markers = <Marker>{};
    final circles = <Circle>{};

    // Worker markers
    for (final worker in widget.workers) {
      final color = AppTheme.riskColor(worker.riskLevel);
      final hue = _colorToHue(color);

      markers.add(Marker(
        markerId: MarkerId('worker_${worker.id}'),
        position: LatLng(worker.lat, worker.lng),
        icon: BitmapDescriptor.defaultMarkerWithHue(hue),
        infoWindow: InfoWindow(
          title: worker.name,
          snippet: '${worker.zone} • ${worker.riskLevel}',
        ),
      ));
    }

    // SOS markers with blinking circles
    for (final sos in widget.sosList) {
      if (sos.isActive) {
        markers.add(Marker(
          markerId: MarkerId('sos_${sos.id}'),
          position: LatLng(sos.lat, sos.lng),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: 'SOS: ${sos.workerName}',
            snippet: '${sos.zone} • ${sos.mode}',
          ),
          zIndex: 2,
        ));

        // Blinking circle
        circles.add(Circle(
          circleId: CircleId('sos_circle_${sos.id}'),
          center: LatLng(sos.lat, sos.lng),
          radius: _blinkOn ? 150 : 80,
          fillColor: Colors.red.withOpacity(_blinkOn ? 0.25 : 0.1),
          strokeColor: Colors.red.withOpacity(_blinkOn ? 0.9 : 0.3),
          strokeWidth: 2,
        ));
      }
    }

    // Drainage markers
    for (final d in widget.drainage) {
      markers.add(Marker(
        markerId: MarkerId('drain_${d.id}'),
        position: LatLng(d.lat, d.lng),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: InfoWindow(title: d.name, snippet: d.type),
        alpha: 0.8,
      ));
    }

    // Zone polygons / heatmap
    final polygons = _buildZonePolygons();

    if (mounted) {
      setState(() {
        _markers = markers;
        _circles = circles;
        _polygons = polygons;
      });
    }
  }

  Set<Polygon> _buildZonePolygons() {
    // Static zone boundaries for Solapur
    return {
      Polygon(
        polygonId: const PolygonId('north_zone'),
        points: const [
          LatLng(17.67, 75.88),
          LatLng(17.67, 75.94),
          LatLng(17.73, 75.94),
          LatLng(17.73, 75.88),
        ],
        fillColor: const Color(0xFFFF1744).withOpacity(0.15),
        strokeColor: const Color(0xFFFF1744).withOpacity(0.5),
        strokeWidth: 2,
      ),
      Polygon(
        polygonId: const PolygonId('central_zone'),
        points: const [
          LatLng(17.64, 75.88),
          LatLng(17.64, 75.94),
          LatLng(17.67, 75.94),
          LatLng(17.67, 75.88),
        ],
        fillColor: const Color(0xFFFFD600).withOpacity(0.12),
        strokeColor: const Color(0xFFFFD600).withOpacity(0.4),
        strokeWidth: 2,
      ),
      Polygon(
        polygonId: const PolygonId('south_zone'),
        points: const [
          LatLng(17.60, 75.88),
          LatLng(17.60, 75.94),
          LatLng(17.64, 75.94),
          LatLng(17.64, 75.88),
        ],
        fillColor: const Color(0xFF00E676).withOpacity(0.10),
        strokeColor: const Color(0xFF00E676).withOpacity(0.4),
        strokeWidth: 2,
      ),
    };
  }

  double _colorToHue(Color color) {
    final r = color.red / 255;
    final g = color.green / 255;
    final b = color.blue / 255;
    final max = [r, g, b].reduce((a, b) => a > b ? a : b);
    final min = [r, g, b].reduce((a, b) => a < b ? a : b);
    if (max == min) return 0;
    double h;
    final d = max - min;
    if (max == r) {
      h = (g - b) / d + (g < b ? 6 : 0);
    } else if (max == g) {
      h = (b - r) / d + 2;
    } else {
      h = (r - g) / d + 4;
    }
    return (h / 6) * 360;
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: _defaultCamera,
      mapType: widget.satelliteMode ? MapType.satellite : MapType.normal,
      markers: _markers,
      circles: _circles,
      polygons: _polygons,
      onMapCreated: (controller) {
        _controller = controller;
        _buildMarkers();
      },
      myLocationButtonEnabled: false,
      compassEnabled: true,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
    );
  }
}
