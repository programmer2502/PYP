import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'network_image_view.dart';

class AvatarView extends StatelessWidget {
  final String? avatarUrl;
  final String name;
  final double radius;
  final bool showBorder;
  final Color? borderColor;

  const AvatarView({
    super.key,
    required this.avatarUrl,
    required this.name,
    this.radius = 24.0,
    this.showBorder = false,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final diameter = radius * 2;
    final initials = _getInitials(name);

    Widget content;
    if (avatarUrl != null && avatarUrl!.trim().isNotEmpty) {
      content = NetworkImageView(
        imageUrl: avatarUrl,
        width: diameter,
        height: diameter,
        borderRadius: radius,
        errorWidget: _buildInitials(diameter, initials),
      );
    } else {
      content = _buildInitials(diameter, initials);
    }

    if (showBorder) {
      return Container(
        width: diameter + 4,
        height: diameter + 4,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: borderColor ?? AppColors.primary,
            width: 2,
          ),
        ),
        padding: const EdgeInsets.all(2),
        child: ClipOval(child: content),
      );
    }

    return ClipOval(child: content);
  }

  Widget _buildInitials(double diameter, String initials) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryGradientStart, AppColors.primaryGradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: radius * 0.75,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _getInitials(String input) {
    final parts = input.trim().split(' ');
    if (parts.isEmpty || parts[0].isEmpty) return '?';
    if (parts.length > 1 && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }
}
