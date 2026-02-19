class DrainageModel {
  final String id;
  final String name;
  final double lat;
  final double lng;
  final String type;
  final String status;
  final String zone;

  DrainageModel({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.type,
    required this.status,
    required this.zone,
  });

  factory DrainageModel.fromJson(Map<String, dynamic> json) {
    return DrainageModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Drainage Point',
      lat: (json['lat'] ?? json['latitude'] ?? 17.6599).toDouble(),
      lng: (json['lng'] ?? json['longitude'] ?? 75.9064).toDouble(),
      type: json['type']?.toString() ?? 'manhole',
      status: json['status']?.toString() ?? 'active',
      zone: json['zone']?.toString() ?? 'Central Solapur',
    );
  }
}
