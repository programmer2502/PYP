import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/widgets/avatar_view.dart';
import '../../core/widgets/empty_state_view.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/loading_indicator.dart';
import '../../core/widgets/network_image_view.dart';
import '../../core/widgets/rating_bar_widget.dart';
import '../../models/review_model.dart';
import '../../providers/photographer_provider.dart';

class ReviewsListScreen extends ConsumerWidget {
  final String photographerId;
  final String photographerName;

  const ReviewsListScreen({
    super.key,
    required this.photographerId,
    required this.photographerName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(photographerReviewsProvider(photographerId));

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: Text('Reviews for $photographerName'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: reviewsAsync.when(
          data: (reviews) {
            if (reviews.isEmpty) {
              return const EmptyStateView(
                icon: Icons.rate_review_outlined,
                title: 'No Reviews Yet',
                message: 'This creator has not received any client reviews yet.',
              );
            }

            final avgRating = reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;

            return CustomScrollView(
              slivers: [
                // Aggregate Rating Header
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.cardBorderDark),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Text(
                              avgRating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimaryDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            RatingBarWidget(rating: avgRating, itemSize: 18, showRatingText: false),
                            const SizedBox(height: 6),
                            Text(
                              'Based on ${reviews.length} reviews',
                              style: const TextStyle(
                                color: AppColors.textSecondaryDark,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Reviews List
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final review = reviews[index];
                        return _buildReviewCard(context, review);
                      },
                      childCount: reviews.length,
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: LoadingIndicator(message: 'Loading verified reviews...')),
          error: (e, _) => ErrorView(message: e.toString()),
        ),
      ),
    );
  }

  Widget _buildReviewCard(BuildContext context, ReviewModel review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AvatarView(
                avatarUrl: review.customerAvatar,
                name: review.customerName,
                radius: 18,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.customerName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimaryDark,
                      ),
                    ),
                    Text(
                      DateFormatter.formatRelativeTime(review.createdAt),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMutedDark,
                      ),
                    ),
                  ],
                ),
              ),
              RatingBarWidget(
                rating: review.rating,
                itemSize: 14,
                showRatingText: false,
              ),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              review.comment,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondaryDark,
                height: 1.4,
              ),
            ),
          ],
          if (review.photos.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 70,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: review.photos.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, pIndex) {
                  final photo = review.photos[pIndex];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: NetworkImageView(
                      imageUrl: photo,
                      width: 70,
                      height: 70,
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
