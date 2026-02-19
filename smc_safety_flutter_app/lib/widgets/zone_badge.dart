import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_constants.dart';

class ZoneBadge extends StatelessWidget {
  final String zone;
  final String riskLevel;
  final bool large;

  const ZoneBadge({
    super.key,
    required this.zone,
    required this.riskLevel,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.riskColor(riskLevel);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 16 : 10,
        vertical: large ? 8 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(large ? 12 : 8),
        border: Border.all(color: color.withOpacity(0.5), width: 1.5),
        boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 8)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: large ? 10 : 8,
            height: large ? 10 : 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: color, blurRadius: 4)],
            ),
          ),
          SizedBox(width: large ? 8 : 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (large)
                Text(
                  zone,
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              Text(
                riskLevel,
                style: TextStyle(
                  color: color,
                  fontSize: large ? 11 : 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String getRiskLabel(String riskLevel) {
  switch (riskLevel.toUpperCase()) {
    case AppConstants.riskHigh:
      return 'DANGER ZONE';
    case AppConstants.riskMedium:
      return 'WARNING ZONE';
    default:
      return 'SAFE ZONE';
  }
}
