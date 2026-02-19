import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/kpi_card.dart';
import '../../widgets/smc_map.dart';
import '../../widgets/sos_list_tile.dart';
import '../../widgets/analytics_charts.dart';
import '../../widgets/blinking_sos.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  bool _satelliteMode = true;
  int _selectedTab = 0;

  final List<String> _tabs = ['MAP', 'SOS FEED', 'ANALYTICS', 'WORKERS'];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _tabs.length, vsync: this);
    _tabCtrl.addListener(() {
      setState(() => _selectedTab = _tabCtrl.index);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().refreshDashboard();
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final activeSOS = provider.activeSOS;

        return Scaffold(
          backgroundColor: const Color(AppConstants.colorBackground),
          appBar: _buildAppBar(context, provider, activeSOS.length),
          body: Column(
            children: [
              // KPI Strip
              _buildKPIStrip(provider),
              // Tabs
              _buildTabBar(),
              // Content
              Expanded(
                child: TabBarView(
                  controller: _tabCtrl,
                  children: [
                    _buildMapTab(provider),
                    _buildSOSFeedTab(provider),
                    _buildAnalyticsTab(provider),
                    _buildWorkersTab(provider),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, AppProvider provider, int activeSOS) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
        color: const Color(0xFF00B4D8),
        onPressed: () => provider.setAppMode('select'),
      ),
      title: Column(
        children: [
          const Text(
            'SOLAPUR MUNICIPAL COMMAND CENTER',
            style: TextStyle(fontSize: 13, letterSpacing: 1.5),
          ),
          Text(
            'Smart Safety & Assistance System',
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withOpacity(0.4),
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
      actions: [
        // Active SOS count
        if (activeSOS > 0)
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Row(
              children: [
                BlinkingSOSIndicator(size: 20),
                const SizedBox(width: 4),
                Text(
                  '$activeSOS',
                  style: const TextStyle(
                    color: Color(0xFFFF1744),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        // Demo toggle
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: TextButton(
            onPressed: () => provider.toggleDemoMode(),
            style: TextButton.styleFrom(
              backgroundColor: provider.demoMode
                  ? const Color(0xFFFF6B35).withOpacity(0.2)
                  : Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            child: Text(
              provider.demoMode ? 'DEMO ON' : 'DEMO',
              style: TextStyle(
                color: provider.demoMode
                    ? const Color(0xFFFF6B35)
                    : const Color(0xFF64748B),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        // Refresh
        IconButton(
          icon: provider.loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF00B4D8)),
                )
              : const Icon(Icons.refresh_rounded, size: 20),
          color: const Color(0xFF00B4D8),
          onPressed: provider.loading ? null : () => provider.refreshDashboard(),
        ),
      ],
    );
  }

  Widget _buildKPIStrip(AppProvider provider) {
    final s = provider.summary;
    return Container(
      color: const Color(0xFF111827),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          _MiniKPI(
            label: 'Workers',
            value: '${s.activeWorkers}',
            color: const Color(0xFF00E676),
            icon: Icons.engineering_rounded,
          ),
          _divider(),
          _MiniKPI(
            label: 'SOS Active',
            value: '${provider.activeSOS.length}',
            color: provider.activeSOS.isNotEmpty
                ? const Color(0xFFFF1744)
                : const Color(0xFF00E676),
            icon: Icons.warning_rounded,
          ),
          _divider(),
          _MiniKPI(
            label: 'Drainage',
            value: '${s.drainageAssets > 0 ? s.drainageAssets : provider.drainage.length}',
            color: const Color(0xFF00B4D8),
            icon: Icons.water_drop_rounded,
          ),
          _divider(),
          _MiniKPI(
            label: 'Top Risk',
            value: s.topRiskZone.split(' ').first,
            color: const Color(0xFFFF1744),
            icon: Icons.location_on_rounded,
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 36,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        color: const Color(0xFF1E3A5F),
      );

  Widget _buildTabBar() {
    return Container(
      color: const Color(0xFF111827),
      child: Row(
        children: List.generate(_tabs.length, (i) {
          final selected = _selectedTab == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => _tabCtrl.animateTo(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: selected
                          ? const Color(0xFF00B4D8)
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  _tabs[i],
                  style: TextStyle(
                    color: selected
                        ? const Color(0xFF00B4D8)
                        : const Color(0xFF64748B),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMapTab(AppProvider provider) {
    return Stack(
      children: [
        SMCMap(
          workers: provider.workers,
          sosList: provider.sosList,
          drainage: provider.drainage,
          satelliteMode: _satelliteMode,
        ),
        // Map controls overlay
        Positioned(
          bottom: 16,
          right: 16,
          child: Column(
            children: [
              _MapBtn(
                icon: _satelliteMode ? Icons.map_rounded : Icons.satellite_rounded,
                label: _satelliteMode ? 'Normal' : 'Satellite',
                onTap: () => setState(() => _satelliteMode = !_satelliteMode),
              ),
            ],
          ),
        ),
        // Legend overlay
        Positioned(
          top: 12,
          left: 12,
          child: _buildMapLegend(),
        ),
        // Last updated
        if (provider.lastUpdated != null)
          Positioned(
            bottom: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Updated ${_timeAgo(provider.lastUpdated!)}',
                style: const TextStyle(color: Colors.white54, fontSize: 10),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMapLegend() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.75),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LegendItem(color: const Color(0xFFFF1744), label: 'HIGH RISK / SOS'),
          const SizedBox(height: 4),
          _LegendItem(color: const Color(0xFFFFD600), label: 'MEDIUM RISK'),
          const SizedBox(height: 4),
          _LegendItem(color: const Color(0xFF00E676), label: 'LOW RISK'),
          const SizedBox(height: 4),
          _LegendItem(color: const Color(0xFF00B4D8), label: 'DRAINAGE'),
        ],
      ),
    );
  }

  Widget _buildSOSFeedTab(AppProvider provider) {
    final sosList = provider.sosList;
    if (sosList.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_rounded, color: Color(0xFF00E676), size: 48),
            SizedBox(height: 12),
            Text('No SOS alerts', style: TextStyle(color: Colors.white54)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: provider.refreshDashboard,
      color: const Color(0xFF00B4D8),
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: sosList.length,
        itemBuilder: (_, i) => SOSListTile(
          sos: sosList[i],
          onResolve: () => provider.resolveSOS(sosList[i].id),
        ),
      ),
    );
  }

  Widget _buildAnalyticsTab(AppProvider provider) {
    final s = provider.summary;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPI grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              KpiCard(
                title: 'Active Workers',
                value: '${s.activeWorkers > 0 ? s.activeWorkers : provider.workers.length}',
                icon: Icons.engineering_rounded,
                color: const Color(0xFF00E676),
                subtitle: 'Currently deployed',
              ),
              KpiCard(
                title: 'SOS Active',
                value: '${provider.activeSOS.length}',
                icon: Icons.warning_rounded,
                color: provider.activeSOS.isNotEmpty
                    ? const Color(0xFFFF1744)
                    : const Color(0xFF00E676),
                subtitle: 'Need attention',
              ),
              KpiCard(
                title: 'Drainage Assets',
                value: '${s.drainageAssets > 0 ? s.drainageAssets : provider.drainage.length}',
                icon: Icons.water_drop_rounded,
                color: const Color(0xFF00B4D8),
                subtitle: 'Mapped manholes',
              ),
              KpiCard(
                title: 'Top Risk Zone',
                value: s.topRiskZone.split(' ').first,
                icon: Icons.location_on_rounded,
                color: const Color(0xFFFF1744),
                subtitle: s.topRiskZone,
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Zone distribution
          _SectionHeader(title: 'Zone Distribution', icon: Icons.donut_large_rounded),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ZoneDistributionChart(
                zoneDistribution: s.zoneDistribution.isNotEmpty
                    ? s.zoneDistribution
                    : {
                        'North': provider.workers
                            .where((w) => w.zone.contains('North'))
                            .length,
                        'Central': provider.workers
                            .where((w) => w.zone.contains('Central'))
                            .length,
                        'South': provider.workers
                            .where((w) => w.zone.contains('South'))
                            .length,
                      },
              ),
            ),
          ),
          const SizedBox(height: 20),
          // SOS by mode
          _SectionHeader(title: 'SOS by Mode', icon: Icons.bar_chart_rounded),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SOSModeChart(
                sosByMode: s.sosByMode.isNotEmpty
                    ? s.sosByMode
                    : {
                        'manual': provider.sosList
                            .where((s) => s.mode == 'manual')
                            .length,
                        'voice': provider.sosList
                            .where((s) => s.mode == 'voice')
                            .length,
                        'offline_sms': provider.sosList
                            .where((s) => s.mode == 'offline_sms')
                            .length,
                      },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkersTab(AppProvider provider) {
    final workers = provider.workers;
    if (workers.isEmpty) {
      return const Center(
        child: Text('No workers online', style: TextStyle(color: Colors.white54)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: workers.length,
      itemBuilder: (_, i) {
        final w = workers[i];
        final riskColor = AppTheme.riskColor(w.riskLevel);
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: riskColor.withOpacity(0.15),
                border: Border.all(color: riskColor.withOpacity(0.5)),
              ),
              child: Icon(Icons.engineering_rounded, color: riskColor, size: 20),
            ),
            title: Text(w.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Row(
              children: [
                Icon(Icons.location_on, size: 11, color: Colors.grey[500]),
                const SizedBox(width: 3),
                Expanded(
                  child: Text(
                    w.zone,
                    style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  w.id,
                  style: TextStyle(color: riskColor, fontSize: 11, fontWeight: FontWeight.bold),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 3),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: riskColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    w.riskLevel,
                    style: TextStyle(color: riskColor, fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    return '${diff.inMinutes}m ago';
  }
}

class _MiniKPI extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _MiniKPI({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(color: color, blurRadius: 8)],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 10, color: color.withOpacity(0.6)),
              const SizedBox(width: 3),
              Text(
                label,
                style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 9),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MapBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MapBtn({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.75),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF1E3A5F)),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF00B4D8), size: 20),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(color: Colors.white54, fontSize: 8)),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 9)),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF00B4D8), size: 18),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFF00B4D8),
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}
