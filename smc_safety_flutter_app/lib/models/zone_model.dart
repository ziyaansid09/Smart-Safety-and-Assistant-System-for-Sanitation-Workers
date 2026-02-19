class ZoneModel {
  final String id;
  final String name;
  final String riskLevel;
  final List<List<double>> boundaries;
  final int workerCount;

  ZoneModel({
    required this.id,
    required this.name,
    required this.riskLevel,
    required this.boundaries,
    required this.workerCount,
  });

  factory ZoneModel.fromJson(Map<String, dynamic> json) {
    List<List<double>> bounds = [];
    if (json['boundaries'] is List) {
      for (var b in json['boundaries']) {
        if (b is List && b.length >= 2) {
          bounds.add([b[0].toDouble(), b[1].toDouble()]);
        }
      }
    }
    return ZoneModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      riskLevel: json['riskLevel']?.toString() ?? 'LOW',
      boundaries: bounds,
      workerCount: (json['workerCount'] ?? 0) as int,
    );
  }
}
