import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: const Color(0xFF0A0E1A),
          appBar: AppBar(title: const Text('SETTINGS')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _SettingsSection(title: 'LANGUAGE'),
              _LangOption(
                flag: '🇬🇧',
                label: 'English',
                selected: provider.locale.languageCode == 'en',
                onTap: () => provider.setLocale(const Locale('en')),
              ),
              _LangOption(
                flag: '🇮🇳',
                label: 'Hindi (हिंदी)',
                selected: provider.locale.languageCode == 'hi',
                onTap: () => provider.setLocale(const Locale('hi')),
              ),
              _LangOption(
                flag: '🇮🇳',
                label: 'Marathi (मराठी)',
                selected: provider.locale.languageCode == 'mr',
                onTap: () => provider.setLocale(const Locale('mr')),
              ),
              const SizedBox(height: 24),
              _SettingsSection(title: 'DEMO MODE'),
              Card(
                child: SwitchListTile(
                  title: const Text('Demo Mode',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    provider.demoMode
                        ? 'Simulating worker movement & auto SOS'
                        : 'Enable to demo without backend',
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  value: provider.demoMode,
                  onChanged: (_) => provider.toggleDemoMode(),
                  secondary: Icon(
                    Icons.play_circle_rounded,
                    color: provider.demoMode
                        ? const Color(0xFFFF6B35)
                        : const Color(0xFF64748B),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _SettingsSection(title: 'ABOUT'),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.info_rounded, color: Color(0xFF00B4D8)),
                  title: const Text('SMC Smart Safety Platform',
                      style: TextStyle(color: Colors.white)),
                  subtitle: const Text('Version 1.0.0',
                      style: TextStyle(color: Colors.white54, fontSize: 12)),
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.location_city_rounded, color: Color(0xFF00B4D8)),
                  title: const Text('Solapur Municipal Corporation',
                      style: TextStyle(color: Colors.white)),
                  subtitle: const Text('Solapur, Maharashtra, India',
                      style: TextStyle(color: Colors.white54, fontSize: 12)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  const _SettingsSection({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF64748B),
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class _LangOption extends StatelessWidget {
  final String flag;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LangOption({
    required this.flag,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Text(flag, style: const TextStyle(fontSize: 24)),
        title: Text(
          label,
          style: TextStyle(
            color: selected ? const Color(0xFF00B4D8) : Colors.white,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        trailing: selected
            ? const Icon(Icons.check_circle_rounded, color: Color(0xFF00B4D8))
            : null,
        onTap: onTap,
      ),
    );
  }
}
