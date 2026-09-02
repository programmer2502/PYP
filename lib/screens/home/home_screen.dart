import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/widgets/avatar_view.dart';
import '../../core/widgets/empty_state_view.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/loading_indicator.dart';
import '../../core/widgets/network_image_view.dart';
import '../../models/filter_model.dart';
import '../../models/photographer_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/photographer_provider.dart';
import 'search_filter_sheet.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        ref.read(paginatedPhotographersProvider.notifier).fetchMore();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      final currentFilter = ref.read(activeFilterProvider);
      ref.read(activeFilterProvider.notifier).state = currentFilter.copyWith(
        searchQuery: query.trim(),
        clearQuery: query.trim().isEmpty,
      );
      ref.read(paginatedPhotographersProvider.notifier).fetchInitial();
    });
  }

  void _onCategorySelected(String? category) {
    setState(() {
      _selectedCategory = category;
    });

    final currentFilter = ref.read(activeFilterProvider);
    ref.read(activeFilterProvider.notifier).state = currentFilter.copyWith(
      category: category,
      clearCategory: category == null,
    );
    ref.read(paginatedPhotographersProvider.notifier).fetchInitial();
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
    final userState = ref.watch(userProfileProvider);
    final user = userState.value;
    final locationState = ref.watch(locationProvider);
    final filter = ref.watch(activeFilterProvider);
    final photographersState = ref.watch(paginatedPhotographersProvider);
    final topRatedAsync = ref.watch(topRatedPhotographersProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            await ref.read(paginatedPhotographersProvider.notifier).fetchInitial();
          },
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // 1. Top Bar: Location & Avatar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Location selector pill
                      GestureDetector(
                        onTap: () => context.push('/location-picker'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(100),
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
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.location_on_rounded,
                                color: AppColors.primary,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        locationState.city.isNotEmpty ? locationState.city : 'Current Location',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimaryLight,
                                        ),
                                      ),
                                      const Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: AppColors.textSecondaryLight,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      // User Avatar with circular border
                      GestureDetector(
                        onTap: () => context.go('/profile'),
                        child: AvatarView(
                          avatarUrl: user?.avatarUrl,
                          name: user?.name ?? 'User',
                          radius: 20,
                          showBorder: true,
                          borderColor: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Modern Search Bar & Filter trigger
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.cardBorderLight),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: _onSearchChanged,
                            style: const TextStyle(
                              color: AppColors.textPrimaryLight,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Search by creator, style, or city...',
                              hintStyle: TextStyle(
                                color: AppColors.textMutedLight,
                                fontSize: 13,
                              ),
                              prefixIcon: Icon(
                                Icons.search_rounded,
                                color: AppColors.textSecondaryLight,
                                size: 22,
                              ),
                              contentPadding: EdgeInsets.symmetric(vertical: 14),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              filled: false,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: _openFilterSheet,
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            color: filter.activeFilterCount > 0 ? AppColors.primary : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: filter.activeFilterCount > 0 ? AppColors.primary : AppColors.cardBorderLight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(
                                Icons.tune_rounded,
                                color: filter.activeFilterCount > 0 ? Colors.white : AppColors.textPrimaryLight,
                                size: 22,
                              ),
                              if (filter.activeFilterCount > 0)
                                Positioned(
                                  top: 10,
                                  right: 10,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: AppColors.accentRose,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 3. Category System Carousel with Pastel Tile Badges (All, Wedding, Portrait, Event, Drone, Reels)
              SliverToBoxAdapter(
                child: Container(
                  height: 96,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      _buildCategoryTile(
                        title: 'All',
                        categoryKey: null,
                        icon: Icons.camera_alt_rounded,
                        bgColor: AppColors.badgeGreenBg,
                        iconColor: AppColors.badgeGreenIcon,
                      ),
                      const SizedBox(width: 14),
                      _buildCategoryTile(
                        title: 'Wedding',
                        categoryKey: 'Wedding',
                        icon: Icons.favorite_rounded,
                        bgColor: AppColors.badgeCoralBg,
                        iconColor: AppColors.badgeCoralIcon,
                        imageAsset: 'assets/images/wedding.jpg',
                      ),
                      const SizedBox(width: 14),
                      _buildCategoryTile(
                        title: 'Portrait',
                        categoryKey: 'Portrait',
                        icon: Icons.person_rounded,
                        bgColor: AppColors.badgeSkyBg,
                        iconColor: AppColors.badgeSkyIcon,
                        imageAsset: 'assets/images/portrait.png',
                      ),
                      const SizedBox(width: 14),
                      _buildCategoryTile(
                        title: 'Event',
                        categoryKey: 'Event',
                        icon: Icons.celebration_rounded,
                        bgColor: AppColors.badgePinkBg,
                        iconColor: AppColors.badgePinkIcon,
                        imageAsset: 'assets/images/event.png',
                      ),
                      const SizedBox(width: 14),
                      _buildCategoryTile(
                        title: 'Drone',
                        categoryKey: 'Drone',
                        icon: Icons.flight_rounded,
                        bgColor: AppColors.badgeAmberBg,
                        iconColor: AppColors.badgeAmberIcon,
                        isDrone: true,
                      ),
                      const SizedBox(width: 14),
                      _buildCategoryTile(
                        title: 'Reels',
                        categoryKey: 'Reels',
                        icon: Icons.movie_filter_rounded,
                        bgColor: AppColors.badgePurpleBg,
                        iconColor: AppColors.badgePurpleIcon,
                      ),
                    ],
                  ),
                ),
              ),

              // 4. Featured Hero Cards Section (Midnight Obsidian style from Reference UI)
              topRatedAsync.when(
                data: (topRated) {
                  if (topRated.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
                  return SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.fromLTRB(20, 10, 20, 12),
                          child: Row(
                            children: [
                              Icon(Icons.auto_awesome_rounded, color: AppColors.accentAmber, size: 18),
                              SizedBox(width: 6),
                              Text(
                                'Featured Spotlight',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimaryLight,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 240,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: topRated.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 14),
                            itemBuilder: (context, index) {
                              final item = topRated[index];
                              return _buildMidnightFeaturedCard(item);
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  );
                },
                loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
                error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
              ),

              // 5. Section Header: Explore Creators
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedCategory != null ? '$_selectedCategory Creators' : 'Available Photographers',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimaryLight,
                          letterSpacing: -0.3,
                        ),
                      ),
                      if (photographersState.photographers.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            '${photographersState.photographers.length} verified',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // 6. Photographers Sliver List
              _buildPhotographersSliver(photographersState),
            ],
          ),
        ),
      ),
    );
  }

  // Midnight Spotlight Hero Card (Reference Screen 1)
  Widget _buildMidnightFeaturedCard(PhotographerModel item) {
    return GestureDetector(
      onTap: () => context.push('/photographer/${item.id}'),
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          color: AppColors.darkHeader,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: AppColors.darkHeader.withValues(alpha: 0.2),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Cover Image
            NetworkImageView(
              imageUrl: item.coverImageUrl ?? item.avatarUrl,
              height: 240,
              width: 280,
              fit: BoxFit.cover,
            ),
            // Gradient Shade
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.3),
                    AppColors.darkHeader.withValues(alpha: 0.95),
                  ],
                ),
              ),
            ),
            // Overlay Info Content
            Positioned(
              left: 14,
              right: 14,
              bottom: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
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
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        CurrencyFormatter.format(item.startingPrice),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.accentEmerald,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Open now',
                        style: TextStyle(color: AppColors.accentEmerald, fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.star_rounded, color: AppColors.accentAmber, size: 14),
                      const SizedBox(width: 2),
                      Text(
                        '${item.rating.toStringAsFixed(1)} (${item.reviewCount})',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Quick Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.glassWhite,
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(color: AppColors.glassWhiteBorder),
                          ),
                          child: const Center(
                            child: Text(
                              'More info',
                              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: const Center(
                            child: Text(
                              'Book Now',
                              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                            ),
                          ),
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

  Widget _buildPhotographersSliver(PhotographersState state) {
    if (state.isLoading) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40.0),
          child: Center(child: LoadingIndicator(message: 'Searching creators...')),
        ),
      );
    }

    if (state.error != null) {
      return SliverToBoxAdapter(
        child: ErrorView(
          message: state.error!,
          onRetry: () => ref.read(paginatedPhotographersProvider.notifier).fetchInitial(),
        ),
      );
    }

    if (state.photographers.isEmpty) {
      return SliverToBoxAdapter(
        child: EmptyStateView(
          icon: Icons.camera_alt_outlined,
          title: 'No Creators Found',
          message: 'Try adjusting your location, price range or category filters.',
          actionText: 'Reset Filters',
          onAction: () {
            _searchController.clear();
            _selectedCategory = null;
            ref.read(activeFilterProvider.notifier).state = const FilterModel();
            ref.read(paginatedPhotographersProvider.notifier).fetchInitial();
          },
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == state.photographers.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Center(child: LoadingIndicator(size: 24)),
              );
            }

            final photographer = state.photographers[index];
            return _buildPhotographerCard(photographer);
          },
          childCount: state.photographers.length + (state.isLoadingMore ? 1 : 0),
        ),
      ),
    );
  }

  Widget _buildPhotographerCard(PhotographerModel item) {
    return GestureDetector(
      onTap: () => context.push('/photographer/${item.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.cardBorderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Photo
            Stack(
              children: [
                NetworkImageView(
                  imageUrl: item.coverImageUrl ??
                      (item.portfolioImages.isNotEmpty ? item.portfolioImages.first : item.avatarUrl),
                  height: 180,
                  width: double.infinity,
                ),
                // Rating pill
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
                        const SizedBox(width: 4),
                        Text(
                          '(${item.reviewCount})',
                          style: const TextStyle(
                            color: Color(0xFFCBD5E1),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (item.isVerified)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.verified_rounded, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'PRO',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            // Card Body
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
                            letterSpacing: -0.2,
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
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondaryLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${item.experienceYears}y experience',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondaryLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Category badges
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      ...item.categories.take(2).map((cat) => _buildBadge(cat, AppColors.badgeGreenBg, AppColors.badgeGreenIcon)),
                      ...item.styles.take(2).map((sty) => _buildBadge(sty, AppColors.badgeSkyBg, AppColors.badgeSkyIcon)),
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

  Widget _buildBadge(String text, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildCategoryTile({
    required String title,
    required String? categoryKey,
    required IconData icon,
    required Color bgColor,
    required Color iconColor,
    String? imageAsset,
    bool isDrone = false,
  }) {
    final isSelected = (_selectedCategory == categoryKey) ||
        (_selectedCategory == null && categoryKey == null);

    return GestureDetector(
      onTap: () => _onCategorySelected(categoryKey),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: isSelected ? bgColor : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? iconColor : AppColors.cardBorderLight,
                width: isSelected ? 2.0 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected ? iconColor.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.03),
                  blurRadius: isSelected ? 10 : 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Center(
                child: imageAsset != null
                    ? Image.asset(
                        imageAsset,
                        width: 54,
                        height: 54,
                        fit: BoxFit.cover,
                      )
                    : isDrone
                        ? Image.asset(
                            'assets/images/drone.png',
                            width: 38,
                            height: 38,
                            fit: BoxFit.contain,
                          )
                        : Icon(
                            icon,
                            color: isSelected ? iconColor : AppColors.textSecondaryLight,
                            size: 26,
                          ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? AppColors.primary : AppColors.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

