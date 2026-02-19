class DashboardSummary {
  final int activeWorkers;
  final int sosActive;
  final int drainageAssets;
  final String topRiskZone;
  final Map<String, int> zoneDistribution;
  final Map<String, int> sosByMode;

  DashboardSummary({
    required this.activeWorkers,
    required this.sosActive,
    required this.drainageAssets,
    required this.topRiskZone,
    required this.zoneDistribution,
    required this.sosByMode,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    Map<String, int> zoneDist = {};
    if (json['zoneDistribution'] is Map) {
      (json['zoneDistribution'] as Map).forEach((k, v) {
        zoneDist[k.toString()] = (v as num).toInt();
      });
    }
    Map<String, int> sosModes = {};
    if (json['sosByMode'] is Map) {
      (json['sosByMode'] as Map).forEach((k, v) {
        sosModes[k.toString()] = (v as num).toInt();
      });
    }
    return DashboardSummary(
      activeWorkers: (json['activeWorkers'] ?? 0) as int,
      sosActive: (json['sosActive'] ?? 0) as int,
      drainageAssets: (json['drainageAssets'] ?? 0) as int,
      topRiskZone: json['topRiskZone']?.toString() ?? 'North Solapur',
      zoneDistribution: zoneDist,
      sosByMode: sosModes,
    );
  }

  factory DashboardSummary.empty() {
    return DashboardSummary(
      activeWorkers: 0,
      sosActive: 0,
      drainageAssets: 0,
      topRiskZone: 'N/A',
      zoneDistribution: {},
      sosByMode: {},
    );
  }
}
