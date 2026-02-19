class WorkerModel {
  final String id;
  final String name;
  final double lat;
  final double lng;
  final String zone;
  final String riskLevel;
  final String status;
  final DateTime? lastSeen;

  WorkerModel({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.zone,
    required this.riskLevel,
    required this.status,
    this.lastSeen,
  });

  factory WorkerModel.fromJson(Map<String, dynamic> json) {
    return WorkerModel(
      id: json['workerId']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Worker',
      lat: (json['lat'] ?? json['latitude'] ?? 17.6599).toDouble(),
      lng: (json['lng'] ?? json['longitude'] ?? 75.9064).toDouble(),
      zone: json['zone']?.toString() ?? 'Central Solapur',
      riskLevel: json['riskLevel']?.toString() ?? 'LOW',
      status: json['status']?.toString() ?? 'active',
      lastSeen: json['lastSeen'] != null
          ? DateTime.tryParse(json['lastSeen'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'workerId': id,
      'name': name,
      'lat': lat,
      'lng': lng,
      'zone': zone,
      'riskLevel': riskLevel,
      'status': status,
    };
  }

  WorkerModel copyWith({
    String? id,
    String? name,
    double? lat,
    double? lng,
    String? zone,
    String? riskLevel,
    String? status,
    DateTime? lastSeen,
  }) {
    return WorkerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      zone: zone ?? this.zone,
      riskLevel: riskLevel ?? this.riskLevel,
      status: status ?? this.status,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }
}
