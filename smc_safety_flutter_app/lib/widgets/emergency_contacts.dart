import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/constants/app_constants.dart';

class EmergencyContacts extends StatelessWidget {
  const EmergencyContacts({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'EMERGENCY CONTACTS',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _ContactBtn(
              label: 'Police',
              number: AppConstants.policeNumber,
              icon: Icons.local_police_rounded,
              color: const Color(0xFF3B82F6),
            ),
            const SizedBox(width: 8),
            _ContactBtn(
              label: 'Ambulance',
              number: AppConstants.ambulanceNumber,
              icon: Icons.local_hospital_rounded,
              color: const Color(0xFF00E676),
            ),
            const SizedBox(width: 8),
            _ContactBtn(
              label: 'Fire',
              number: AppConstants.fireNumber,
              icon: Icons.local_fire_department_rounded,
              color: const Color(0xFFFF6B35),
            ),
          ],
        ),
      ],
    );
  }
}

class _ContactBtn extends StatelessWidget {
  final String label;
  final String number;
  final IconData icon;
  final Color color;

  const _ContactBtn({
    required this.label,
    required this.number,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () async {
          final uri = Uri.parse('tel:$number');
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.4)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
              ),
              Text(
                number,
                style: TextStyle(color: color.withOpacity(0.7), fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
