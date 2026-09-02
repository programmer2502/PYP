import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/widgets/empty_state_view.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/loading_indicator.dart';
import '../../core/widgets/network_image_view.dart';
import '../../models/filter_model.dart';
import '../../models/photographer_model.dart';
import '../../providers/photographer_provider.dart';
import 'search_filter_sheet.dart';

class CategoryPhotographersScreen extends ConsumerStatefulWidget {
  final String category;

  const CategoryPhotographersScreen({
    super.key,
    required this.category,
  });

  @override
  ConsumerState<CategoryPhotographersScreen> createState() =>
      _CategoryPhotographersScreenState();
}

class _CategoryPhotographersScreenState
    extends ConsumerState<CategoryPhotographersScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(activeFilterProvider.notifier).state =
          FilterModel(category: widget.category);
      ref.read(paginatedPhotographersProvider.notifier).fetchInitial();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        ref.read(paginatedPhotographersProvider.notifier).fetchMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SearchFilterSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paginatedPhotographersProvider);
    final filter = ref.watch(activeFilterProvider);

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
        title: Text(
          '${widget.category} Photographers',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimaryLight,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: IconButton(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.tune_rounded, color: AppColors.textPrimaryLight),
                  if (filter.activeFilterCount > 0)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          filter.activeFilterCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              onPressed: _openFilterSheet,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: _buildBody(state),
      ),
    );
  }

  Widget _buildBody(PhotographersState state) {
    if (state.isLoading) {
      return const Center(child: LoadingIndicator(message: 'Loading creators...'));
    }

    if (state.error != null) {
      return ErrorView(
        message: state.error!,
        onRetry: () =>
            ref.read(paginatedPhotographersProvider.notifier).fetchInitial(),
      );
    }

    if (state.photographers.isEmpty) {
      return EmptyStateView(
        icon: Icons.camera_alt_outlined,
        title: 'No ${widget.category} Creators',
        message: 'There are no creators currently found in this category.',
        actionText: 'Reset Filters',
        onAction: () {
          ref.read(activeFilterProvider.notifier).state =
              FilterModel(category: widget.category);
          ref.read(paginatedPhotographersProvider.notifier).fetchInitial();
        },
      );
    }

    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: state.photographers.length + (state.isLoadingMore ? 1 : 0),
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        if (index == state.photographers.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Center(child: LoadingIndicator(size: 24)),
          );
        }

        final item = state.photographers[index];
        return _buildCard(item);
      },
    );
  }

  Widget _buildCard(PhotographerModel item) {
    return GestureDetector(
      onTap: () => context.push('/photographer/${item.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.cardBorderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                NetworkImageView(
                  imageUrl: item.coverImageUrl ??
                      (item.portfolioImages.isNotEmpty ? item.portfolioImages.first : item.avatarUrl),
                  height: 170,
                  width: double.infinity,
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, color: AppColors.accentAmber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          item.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimaryLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        'From ${CurrencyFormatter.format(item.startingPrice)}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondaryLight),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.location,
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
