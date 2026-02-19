import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/app_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/sos_button.dart';
import '../../widgets/zone_badge.dart';
import '../../widgets/emergency_contacts.dart';
import '../../widgets/blinking_sos.dart';

class WorkerHomeScreen extends StatefulWidget {
  const WorkerHomeScreen({super.key});

  @override
  State<WorkerHomeScreen> createState() => _WorkerHomeScreenState();
}

class _WorkerHomeScreenState extends State<WorkerHomeScreen>
    with TickerProviderStateMixin {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechAvailable = false;
  bool _listening = false;
  StreamSubscription? _connectivitySub;
  late AnimationController _statusCtrl;
  late Animation<double> _statusAnim;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _initConnectivity();
    _statusCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _statusAnim = Tween<double>(begin: 0.5, end: 1.0).animate(_statusCtrl);
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          setState(() => _listening = false);
          context.read<AppProvider>().setVoiceListening(false);
        }
      },
      onError: (_) {
        setState(() => _listening = false);
        context.read<AppProvider>().setVoiceListening(false);
      },
    );
    setState(() {});
  }

  void _initConnectivity() {
    Connectivity().checkConnectivity().then((result) {
      context.read<AppProvider>().setOnlineStatus(
        result.contains(ConnectivityResult.mobile) ||
        result.contains(ConnectivityResult.wifi),
      );
    });
    _connectivitySub = Connectivity().onConnectivityChanged.listen((result) {
      if (!mounted) return;
      context.read<AppProvider>().setOnlineStatus(
        result.contains(ConnectivityResult.mobile) ||
        result.contains(ConnectivityResult.wifi),
      );
    });
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    _statusCtrl.dispose();
    _speech.stop();
    super.dispose();
  }

  Future<void> _triggerSOS(String mode) async {
    HapticFeedback.heavyImpact();
    final provider = context.read<AppProvider>();

    if (!provider.isOnline) {
      // Offline SMS fallback
      _sendOfflineSMS(provider);
      return;
    }

    final success = await provider.triggerSOS(mode);
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('SOS failed - trying SMS fallback...'),
          backgroundColor: Colors.orange,
        ),
      );
      _sendOfflineSMS(provider);
    }
  }

  void _sendOfflineSMS(AppProvider provider) {
    final ts = DateTime.now().millisecondsSinceEpoch;
    final msg = 'SOS|${provider.workerId}|${provider.lat},${provider.lng}|${provider.zone}|$ts';
    final uri = Uri.parse('sms:112?body=${Uri.encodeComponent(msg)}');
    launchUrl(uri);
  }

  void _toggleVoiceListening() async {
    if (!_speechAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Speech recognition not available')),
      );
      return;
    }

    if (_listening) {
      await _speech.stop();
      setState(() => _listening = false);
      context.read<AppProvider>().setVoiceListening(false);
    } else {
      setState(() => _listening = true);
      context.read<AppProvider>().setVoiceListening(true);
      await _speech.listen(
        onResult: (result) {
          final words = result.recognizedWords.toLowerCase();
          final allKeywords = [
            ...AppConstants.sosKeywordsEn,
            ...AppConstants.sosKeywordsHi,
            ...AppConstants.sosKeywordsMr,
          ];
          for (final keyword in allKeywords) {
            if (words.contains(keyword.toLowerCase())) {
              _triggerSOS(AppConstants.sosModeVoice);
              break;
            }
          }
        },
        listenFor: const Duration(minutes: 5),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        localeId: 'en_IN',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final riskColor = AppTheme.riskColor(provider.riskLevel);

        return Scaffold(
          backgroundColor: const Color(AppConstants.colorBackground),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Header
                  _buildHeader(context, provider, riskColor),
                  const SizedBox(height: 20),

                  // Status cards row
                  _buildStatusRow(provider, riskColor),
                  const SizedBox(height: 24),

                  // Zone badge
                  ZoneBadge(zone: provider.zone, riskLevel: provider.riskLevel, large: true),
                  const SizedBox(height: 32),

                  // SOS Button
                  SOSButton(
                    onPressed: () => _triggerSOS(AppConstants.sosModeManual),
                    isSending: provider.sosSending,
                    justSent: provider.sosJustSent,
                    label: 'PRESS FOR EMERGENCY',
                  ),
                  const SizedBox(height: 32),

                  // Voice SOS
                  _buildVoiceSOSButton(provider),
                  const SizedBox(height: 16),

                  // Offline SOS
                  _buildOfflineSOSButton(provider),
                  const SizedBox(height: 32),

                  // GPS info
                  _buildGPSCard(provider),
                  const SizedBox(height: 20),

                  // Emergency contacts
                  const EmergencyContacts(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, AppProvider provider, Color riskColor) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
          color: const Color(0xFF00B4D8),
          onPressed: () => provider.setAppMode('select'),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'SMC WORKER',
                style: TextStyle(
                  color: Color(0xFF00B4D8),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: 2,
                ),
              ),
              Text(
                provider.workerName.isNotEmpty ? provider.workerName : 'Field Worker',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
        // Connectivity indicator
        AnimatedBuilder(
          animation: _statusAnim,
          builder: (_, __) {
            return Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: provider.isOnline
                    ? const Color(0xFF00E676).withOpacity(_statusAnim.value)
                    : const Color(0xFFFF1744).withOpacity(_statusAnim.value),
                boxShadow: [
                  BoxShadow(
                    color: provider.isOnline
                        ? const Color(0xFF00E676)
                        : const Color(0xFFFF1744),
                    blurRadius: 8,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatusRow(AppProvider provider, Color riskColor) {
    return Row(
      children: [
        _StatusCard(
          icon: Icons.badge_rounded,
          label: 'Worker ID',
          value: provider.workerId.isNotEmpty ? provider.workerId : 'N/A',
          color: const Color(0xFF00B4D8),
        ),
        const SizedBox(width: 10),
        _StatusCard(
          icon: provider.isCheckedIn ? Icons.check_circle_rounded : Icons.pending_rounded,
          label: 'Status',
          value: provider.isCheckedIn ? 'Active' : 'Offline',
          color: provider.isCheckedIn ? const Color(0xFF00E676) : const Color(0xFF64748B),
        ),
        const SizedBox(width: 10),
        _StatusCard(
          icon: Icons.wifi_rounded,
          label: 'Network',
          value: provider.isOnline ? 'Online' : 'Offline',
          color: provider.isOnline ? const Color(0xFF00E676) : const Color(0xFFFF1744),
        ),
      ],
    );
  }

  Widget _buildVoiceSOSButton(AppProvider provider) {
    return GestureDetector(
      onTap: _toggleVoiceListening,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: _listening
              ? const Color(0xFF00B4D8).withOpacity(0.15)
              : const Color(0xFF1A2332),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _listening
                ? const Color(0xFF00B4D8)
                : const Color(0xFF1E3A5F),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_listening)
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: PulsingDot(color: const Color(0xFF00B4D8), size: 10),
              )
            else
              const Icon(Icons.mic_rounded, color: Color(0xFF00B4D8), size: 20),
            const SizedBox(width: 10),
            Text(
              _listening ? 'LISTENING... say "SOS" or "HELP"' : 'TAP TO ACTIVATE VOICE SOS',
              style: TextStyle(
                color: _listening ? const Color(0xFF00B4D8) : const Color(0xFF64748B),
                fontWeight: FontWeight.bold,
                fontSize: 13,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfflineSOSButton(AppProvider provider) {
    return GestureDetector(
      onTap: () => _sendOfflineSMS(provider),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFD600).withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFFFD600).withOpacity(0.3)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sms_rounded, color: Color(0xFFFFD600), size: 18),
            SizedBox(width: 10),
            Text(
              'OFFLINE SMS SOS (No Internet)',
              style: TextStyle(
                color: Color(0xFFFFD600),
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGPSCard(AppProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2332),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E3A5F)),
      ),
      child: Row(
        children: [
          const Icon(Icons.gps_fixed_rounded, color: Color(0xFF00B4D8), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'GPS LOCATION',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${provider.lat.toStringAsFixed(5)}, ${provider.lng.toStringAsFixed(5)}',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          if (provider.gpsAccuracy > 0)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '±${provider.gpsAccuracy.toStringAsFixed(0)}m',
                  style: const TextStyle(color: Color(0xFF00E676), fontSize: 12),
                ),
                const Text(
                  'accuracy',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 10),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatusCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              label,
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 9),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
