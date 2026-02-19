import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/theme/app_theme.dart';

class ZoneDistributionChart extends StatelessWidget {
  final Map<String, int> zoneDistribution;

  const ZoneDistributionChart({super.key, required this.zoneDistribution});

  @override
  Widget build(BuildContext context) {
    if (zoneDistribution.isEmpty) {
      return const SizedBox(
        height: 160,
        child: Center(child: Text('No zone data', style: TextStyle(color: Colors.grey))),
      );
    }

    final entries = zoneDistribution.entries.toList();
    final total = entries.fold<int>(0, (sum, e) => sum + e.value);

    final colors = [
      const Color(0xFFFF1744),
      const Color(0xFFFFD600),
      const Color(0xFF00E676),
    ];

    return SizedBox(
      height: 160,
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sections: List.generate(entries.length, (i) {
                  final e = entries[i];
                  final pct = total == 0 ? 0.0 : e.value / total * 100;
                  return PieChartSectionData(
                    value: e.value.toDouble(),
                    title: '${pct.toStringAsFixed(0)}%',
                    color: colors[i % colors.length],
                    radius: 50,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }),
                sectionsSpace: 3,
                centerSpaceRadius: 30,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(entries.length, (i) {
              final e = entries[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: colors[i % colors.length],
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e.key.split(' ').first,
                          style: const TextStyle(fontSize: 11, color: Colors.white70),
                        ),
                        Text(
                          '${e.value} workers',
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class SOSModeChart extends StatelessWidget {
  final Map<String, int> sosByMode;

  const SOSModeChart({super.key, required this.sosByMode});

  @override
  Widget build(BuildContext context) {
    if (sosByMode.isEmpty) {
      return const SizedBox(
        height: 120,
        child: Center(child: Text('No SOS data', style: TextStyle(color: Colors.grey))),
      );
    }

    final entries = sosByMode.entries.toList();
    final max = entries.fold<int>(0, (m, e) => e.value > m ? e.value : m);
    final colors = {
      'manual': const Color(0xFFFF1744),
      'voice': const Color(0xFF00B4D8),
      'offline_sms': const Color(0xFFFFD600),
    };

    return SizedBox(
      height: 120,
      child: BarChart(
        BarChartData(
          maxY: (max + 1).toDouble(),
          gridData: FlGridData(
            show: true,
            getDrawingHorizontalLine: (_) => FlLine(
              color: Colors.white10,
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) {
                  final i = v.toInt();
                  if (i >= entries.length) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      entries[i].key.replaceAll('_', '\n'),
                      style: const TextStyle(fontSize: 8, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: List.generate(entries.length, (i) {
            final e = entries[i];
            final color = colors[e.key] ?? const Color(0xFF00B4D8);
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: e.value.toDouble(),
                  color: color,
                  width: 20,
                  borderRadius: BorderRadius.circular(4),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: (max + 1).toDouble(),
                    color: color.withOpacity(0.1),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
