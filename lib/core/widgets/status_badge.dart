import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final double fontSize;

  const StatusBadge({
    super.key,
    required this.status,
    this.fontSize = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: config.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: config.color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: config.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            config.label,
            style: TextStyle(
              color: config.color,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  _StatusConfig _getStatusConfig(String status) {
    switch (status.toLowerCase()) {
      case AppConstants.statusRequested:
        return const _StatusConfig('Requested', AppColors.accentAmber);
      case AppConstants.statusConfirmed:
        return const _StatusConfig('Confirmed', AppColors.info);
      case AppConstants.statusShootDay:
        return const _StatusConfig('Shoot Day', AppColors.primaryLight);
      case AppConstants.statusEditing:
        return const _StatusConfig('Editing Files', AppColors.accentRose);
      case AppConstants.statusDelivered:
        return const _StatusConfig('Delivered', AppColors.accentCyan);
      case AppConstants.statusCompleted:
        return const _StatusConfig('Completed', AppColors.success);
      case AppConstants.statusCancelled:
        return const _StatusConfig('Cancelled', AppColors.error);
      default:
        return _StatusConfig(
          status.isNotEmpty ? '${status[0].toUpperCase()}${status.substring(1)}' : 'Unknown',
          AppColors.textMutedDark,
        );
    }
  }
}

class _StatusConfig {
  final String label;
  final Color color;

  const _StatusConfig(this.label, this.color);
}
