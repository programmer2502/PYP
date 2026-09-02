import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../constants/app_colors.dart';

class RatingBarWidget extends StatelessWidget {
  final double rating;
  final double itemSize;
  final bool isInteractive;
  final ValueChanged<double>? onRatingUpdate;
  final bool showRatingText;
  final Color? textColor;

  const RatingBarWidget({
    super.key,
    required this.rating,
    this.itemSize = 16.0,
    this.isInteractive = false,
    this.onRatingUpdate,
    this.showRatingText = true,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultTextColor = textColor ?? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isInteractive)
          RatingBar.builder(
            initialRating: rating,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemSize: itemSize,
            itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
            itemBuilder: (context, _) => const Icon(
              Icons.star_rounded,
              color: AppColors.accentAmber,
            ),
            onRatingUpdate: onRatingUpdate ?? (_) {},
          )
        else
          RatingBarIndicator(
            rating: rating,
            itemBuilder: (context, index) => const Icon(
              Icons.star_rounded,
              color: AppColors.accentAmber,
            ),
            itemCount: 5,
            itemSize: itemSize,
            direction: Axis.horizontal,
          ),
        if (showRatingText && !isInteractive) ...[
          const SizedBox(width: 6),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: itemSize * 0.85,
              fontWeight: FontWeight.w700,
              color: defaultTextColor,
            ),
          ),
        ],
      ],
    );
  }
}
