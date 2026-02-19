class SosModel {
  final String id;
  final String workerId;
  final String workerName;
  final double lat;
  final double lng;
  final String zone;
  final String mode;
  final String status;
  final DateTime triggeredAt;
  final String riskLevel;

  SosModel({
    required this.id,
    required this.workerId,
    required this.workerName,
    required this.lat,
    required this.lng,
    required this.zone,
    required this.mode,
    required this.status,
    required this.triggeredAt,
    required this.riskLevel,
  });

  factory SosModel.fromJson(Map<String, dynamic> json) {
    return SosModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      workerId: json['workerId']?.toString() ?? '',
      workerName: json['workerName']?.toString() ?? 'Unknown Worker',
      lat: (json['lat'] ?? json['latitude'] ?? 17.6599).toDouble(),
      lng: (json['lng'] ?? json['longitude'] ?? 75.9064).toDouble(),
      zone: json['zone']?.toString() ?? 'Central Solapur',
      mode: json['mode']?.toString() ?? 'manual',
      status: json['status']?.toString() ?? 'active',
      triggeredAt: json['triggeredAt'] != null
          ? DateTime.tryParse(json['triggeredAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      riskLevel: json['riskLevel']?.toString() ?? 'HIGH',
    );
  }

  bool get isActive => status.toLowerCase() == 'active';
  bool get isPending => status.toLowerCase() == 'pending';
}
