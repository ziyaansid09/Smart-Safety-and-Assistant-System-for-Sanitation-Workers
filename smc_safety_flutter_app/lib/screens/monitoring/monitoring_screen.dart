import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/kpi_card.dart';
import '../../widgets/smc_map.dart';
import '../../widgets/analytics_charts.dart';

class MonitoringScreen extends StatefulWidget {
  const MonitoringScreen({super.key});

  @override
  State<MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends State<MonitoringScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().refreshDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final s = provider.summary;

        return Scaffold(
          backgroundColor: const Color(AppConstants.colorBackground),
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
              color: const Color(0xFF00B4D8),
              onPressed: () => provider.setAppMode('select'),
            ),
            title: Column(
              children: [
                const Text(
                  'PUBLIC MONITORING',
                  style: TextStyle(fontSize: 13, letterSpacing: 1.5),
                ),
                Text(
                  'Solapur Municipal Corporation',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white.withOpacity(0.4),
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: provider.loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child:
                            CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF00B4D8)),
                      )
                    : const Icon(Icons.refresh_rounded, size: 20),
                color: const Color(0xFF00B4D8),
                onPressed: provider.loading ? null : () => provider.refreshDashboard(),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Public info banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00B4D8).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF00B4D8).withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.public_rounded, color: Color(0xFF00B4D8), size: 16),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Public view — Aggregated statistics only. No personal worker data is displayed.',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Map
                const _SectionTitle(title: 'ZONE MAP', icon: Icons.map_rounded),
                const SizedBox(height: 10),
                Container(
                  height: 250,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    overflow: Clip.antiAlias,
                    border: Border.all(color: const Color(0xFF1E3A5F)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SMCMap(
                      workers: const [], // No personal worker data
                      sosList: const [], // No SOS data in public view
                      drainage: provider.drainage,
                      satelliteMode: true,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Stats
                const _SectionTitle(title: 'STATISTICS', icon: Icons.bar_chart_rounded),
                const SizedBox(height: 10),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.4,
                  children: [
                    KpiCard(
                      title: 'Workers Deployed',
                      value: '${s.activeWorkers > 0 ? s.activeWorkers : provider.workers.length}',
                      icon: Icons.engineering_rounded,
                      color: const Color(0xFF00E676),
                    ),
                    KpiCard(
                      title: 'Drainage Assets',
                      value: '${s.drainageAssets > 0 ? s.drainageAssets : provider.drainage.length}',
                      icon: Icons.water_drop_rounded,
                      color: const Color(0xFF00B4D8),
                    ),
                    KpiCard(
                      title: 'Zones Covered',
                      value: '3',
                      icon: Icons.layers_rounded,
                      color: const Color(0xFFFFD600),
                    ),
                    KpiCard(
                      title: 'Response Ready',
                      value: '24/7',
                      icon: Icons.access_time_filled_rounded,
                      color: const Color(0xFF00E676),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Zone info
                const _SectionTitle(title: 'ZONE RISK LEVELS', icon: Icons.location_on_rounded),
                const SizedBox(height: 10),
                _buildZoneInfo(),
                const SizedBox(height: 20),

                // Zone distribution chart
                const _SectionTitle(title: 'WORKER DISTRIBUTION', icon: Icons.donut_large_rounded),
                const SizedBox(height: 10),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: ZoneDistributionChart(
                      zoneDistribution: s.zoneDistribution.isNotEmpty
                          ? s.zoneDistribution
                          : {
                              'North': 2,
                              'Central': 3,
                              'South': 1,
                            },
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Footer
                Center(
                  child: Text(
                    'Data auto-refreshes every ${AppConstants.refreshIntervalSeconds} seconds',
                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Solapur Municipal Corporation © 2024',
                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 10),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildZoneInfo() {
    final zones = [
      {
        'name': 'North Solapur',
        'risk': 'HIGH',
        'desc': 'Lat ≥ 17.67 • Dense sewage network',
        'color': const Color(0xFFFF1744),
      },
      {
        'name': 'Central Solapur',
        'risk': 'MEDIUM',
        'desc': 'Lat 17.64–17.67 • Mixed infrastructure',
        'color': const Color(0xFFFFD600),
      },
      {
        'name': 'South Solapur',
        'risk': 'LOW',
        'desc': 'Lat < 17.64 • Newer infrastructure',
        'color': const Color(0xFF00E676),
      },
    ];

    return Column(
      children: zones.map((z) {
        final color = z['color'] as Color;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.25)),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.location_on_rounded, color: color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      z['name'] as String,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      z['desc'] as String,
                      style: const TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Text(
                  z['risk'] as String,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF00B4D8), size: 16),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF00B4D8),
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}
