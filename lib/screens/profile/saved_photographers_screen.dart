import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/empty_state_view.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/loading_indicator.dart';
import '../../core/widgets/network_image_view.dart';
import '../../core/widgets/rating_bar_widget.dart';
import '../../providers/photographer_provider.dart';

class SavedPhotographersScreen extends ConsumerWidget {
  const SavedPhotographersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topRatedAsync = ref.watch(topRatedPhotographersProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.cardBorderLight),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, size: 20, color: AppColors.textPrimaryLight),
              onPressed: () => context.pop(),
            ),
          ),
        ),
        title: const Text(
          'Saved Photographers',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimaryLight,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: topRatedAsync.when(
          data: (creators) {
            if (creators.isEmpty) {
              return const EmptyStateView(
                icon: Icons.favorite_border_rounded,
                title: 'No Saved Photographers',
                message: 'Tap the heart icon on any photographer profile to save them for future shoots.',
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              itemCount: creators.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = creators[index];
                return GestureDetector(
                  onTap: () => context.push('/photographer/${item.id}'),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.cardBorderLight),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: NetworkImageView(
                            imageUrl: item.avatarUrl,
                            width: 60,
                            height: 60,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimaryLight,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.location,
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                              ),
                              const SizedBox(height: 4),
                              RatingBarWidget(rating: item.rating, itemSize: 13),
                            ],
                          ),
                        ),
                        const Icon(Icons.favorite_rounded, color: AppColors.accentRose),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: LoadingIndicator(message: 'Loading saved creators...')),
          error: (e, _) => ErrorView(message: e.toString()),
        ),
      ),
    );
  }
}
