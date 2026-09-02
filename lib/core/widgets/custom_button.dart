import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isSecondary;
  final bool isOutlined;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double height;
  final double borderRadius;
  final double? width;
  final EdgeInsetsGeometry? padding;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
    this.isOutlined = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.height = 54.0,
    this.borderRadius = 100.0, // Modern pill button shape
    this.width,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    if (isOutlined) {
      return SizedBox(
        height: height,
        width: width ?? double.infinity,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            backgroundColor: backgroundColor ?? Colors.white,
            side: BorderSide(
              color: backgroundColor != null ? backgroundColor! : AppColors.cardBorderLight,
              width: 1.2,
            ),
            padding: padding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          child: _buildChild(textColor ?? AppColors.textPrimaryLight),
        ),
      );
    }

    final effectiveBg = isSecondary
        ? (backgroundColor ?? Colors.white)
        : (backgroundColor ?? AppColors.primary);

    final effectiveFg = isSecondary
        ? (textColor ?? AppColors.textPrimaryLight)
        : (textColor ?? Colors.white);

    return SizedBox(
      height: height,
      width: width ?? double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: effectiveBg,
          foregroundColor: effectiveFg,
          elevation: isSecondary ? 0 : 2,
          shadowColor: isSecondary ? Colors.transparent : AppColors.primary.withValues(alpha: 0.3),
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: isSecondary
                ? const BorderSide(color: AppColors.cardBorderLight, width: 1.2)
                : BorderSide.none,
          ),
        ),
        child: _buildChild(effectiveFg),
      ),
    );
  }

  Widget _buildChild(Color fgColor) {
    if (isLoading) {
      return SizedBox(
        height: 22,
        width: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(fgColor),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: fgColor),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: fgColor,
              letterSpacing: -0.2,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: fgColor,
        letterSpacing: -0.2,
      ),
    );
  }
}
