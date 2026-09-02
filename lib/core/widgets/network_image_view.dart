import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../constants/app_colors.dart';

class NetworkImageView extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;
  final Widget? errorWidget;
  final Widget? placeholderWidget;

  const NetworkImageView({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 0.0,
    this.errorWidget,
    this.placeholderWidget,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (imageUrl == null || imageUrl!.trim().isEmpty) {
      return _buildError(isDark);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(
        imageUrl: imageUrl!,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) =>
            placeholderWidget ??
            Shimmer.fromColors(
              baseColor: isDark ? AppColors.cardDark : const Color(0xFFE2E8F0),
              highlightColor: isDark ? AppColors.cardBorderDark : const Color(0xFFF1F5F9),
              child: Container(
                width: width,
                height: height,
                color: isDark ? AppColors.cardDark : const Color(0xFFE2E8F0),
              ),
            ),
        errorWidget: (context, url, error) => errorWidget ?? _buildError(isDark),
      ),
    );
  }

  Widget _buildError(bool isDark) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight),
      ),
      child: Center(
        child: Icon(
          Icons.image_outlined,
          color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
          size: 28,
        ),
      ),
    );
  }
}
