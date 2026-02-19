import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import 'worker_home_screen.dart';

class WorkerCheckInScreen extends StatefulWidget {
  const WorkerCheckInScreen({super.key});

  @override
  State<WorkerCheckInScreen> createState() => _WorkerCheckInScreenState();
}

class _WorkerCheckInScreenState extends State<WorkerCheckInScreen> {
  final _workerIdCtrl = TextEditingController(text: 'W101');
  final _nameCtrl = TextEditingController(text: 'Ramesh Kumar');
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _workerIdCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _checkIn() async {
    if (_workerIdCtrl.text.trim().isEmpty || _nameCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Please fill in all fields');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });

    final provider = context.read<AppProvider>();
    provider.setWorkerCredentials(
      _workerIdCtrl.text.trim(),
      _nameCtrl.text.trim(),
    );
    await provider.checkIn();

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const WorkerHomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D1B2A), Color(0xFF0A0E1A)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_rounded, color: Color(0xFF00B4D8)),
                      onPressed: () => context.read<AppProvider>().setAppMode('select'),
                    ),
                    const Expanded(
                      child: Text(
                        'WORKER CHECK-IN',
                        style: TextStyle(
                          color: Color(0xFF00E676),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 40),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF00E676).withOpacity(0.15),
                    border: Border.all(color: const Color(0xFF00E676).withOpacity(0.4), width: 2),
                  ),
                  child: const Icon(Icons.engineering_rounded, color: Color(0xFF00E676), size: 40),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Identify yourself to begin tracking',
                  style: TextStyle(color: Colors.white54, fontSize: 13),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _workerIdCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Worker ID',
                    prefixIcon: Icon(Icons.badge_rounded, color: Color(0xFF00B4D8)),
                    hintText: 'e.g. W101',
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person_rounded, color: Color(0xFF00B4D8)),
                    hintText: 'Your full name',
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: const TextStyle(color: Color(0xFFFF1744), fontSize: 13),
                  ),
                ],
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _loading ? null : _checkIn,
                    icon: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.login_rounded),
                    label: Text(_loading ? 'Checking in...' : 'CHECK IN & START'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00E676),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF1744).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFF1744).withOpacity(0.2)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline_rounded, color: Color(0xFFFF1744), size: 18),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'GPS tracking and SOS monitoring will begin after check-in',
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
