import 'package:flutter/material.dart';
import '../models/sos_model.dart';
import '../core/theme/app_theme.dart';
import 'blinking_sos.dart';

class SOSListTile extends StatelessWidget {
  final SosModel sos;
  final VoidCallback? onResolve;

  const SOSListTile({super.key, required this.sos, this.onResolve});

  @override
  Widget build(BuildContext context) {
    final statusColor = AppTheme.statusColor(sos.status);
    final timeAgo = _timeAgo(sos.triggeredAt);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: sos.isActive
            ? BlinkingSOSIndicator(size: 36)
            : Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: statusColor.withOpacity(0.2),
                  border: Border.all(color: statusColor),
                ),
                child: Icon(
                  Icons.check,
                  color: statusColor,
                  size: 18,
                ),
              ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                sos.workerName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: statusColor.withOpacity(0.5)),
              ),
              child: Text(
                sos.status.toUpperCase(),
                style: TextStyle(
                  color: statusColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.location_on, size: 12, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  sos.zone,
                  style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                ),
                const SizedBox(width: 12),
                Icon(Icons.mic, size: 12, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  sos.mode.replaceAll('_', ' ').toUpperCase(),
                  style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              timeAgo,
              style: TextStyle(fontSize: 10, color: Colors.grey[500]),
            ),
          ],
        ),
        trailing: sos.isActive && onResolve != null
            ? TextButton(
                onPressed: onResolve,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF00E676),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                child: const Text('RESOLVE', style: TextStyle(fontSize: 10)),
              )
            : null,
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
