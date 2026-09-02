import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/empty_state_view.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/loading_indicator.dart';
import '../../core/widgets/network_image_view.dart';
import '../../core/widgets/rating_bar_widget.dart';
import '../../models/package_model.dart';
import '../../models/photographer_model.dart';
import '../../providers/photographer_provider.dart';
import 'portfolio_viewer_screen.dart';

class PhotographerDetailScreen extends ConsumerStatefulWidget {
  final String photographerId;

  const PhotographerDetailScreen({
    super.key,
    required this.photographerId,
  });

  @override
  ConsumerState<PhotographerDetailScreen> createState() =>
      _PhotographerDetailScreenState();
}

class _PhotographerDetailScreenState
    extends ConsumerState<PhotographerDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  PackageModel? _selectedPackage;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedCalendarDay;
  String _selectedSlot = '02:00 PM';
  bool _isSaved = false;

  static const List<String> _quickSlots = [
    '10:00 AM',
    '11:30 AM',
    '02:00 PM',
    '04:00 PM',
    '05:30 PM',
    '07:00 PM',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _proceedToBooking(PhotographerModel photographer) {
    context.push(
      '/book/${photographer.id}',
      extra: {
        'photographer': photographer,
        'selectedPackage': _selectedPackage,
        'initialDate': _selectedCalendarDay,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final photographerAsync =
        ref.watch(photographerDetailProvider(widget.photographerId));
    final packagesAsync =
        ref.watch(photographerPackagesProvider(widget.photographerId));

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: photographerAsync.when(
        data: (photographer) {
          if (photographer == null) {
            return const Scaffold(
              body: Center(child: Text('Photographer not found')),
            );
          }

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                // 1. Hero Cover Image with Overlay Header Card (Reference Screen 1)
                SliverAppBar(
                  expandedHeight: 340.0,
                  pinned: true,
                  backgroundColor: AppColors.darkHeader,
                  elevation: 0,
                  leading: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_rounded, size: 20, color: AppColors.textPrimaryLight),
                        onPressed: () => context.pop(),
                      ),
                    ),
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            _isSaved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            size: 20,
                            color: _isSaved ? AppColors.accentRose : AppColors.textPrimaryLight,
                          ),
                          onPressed: () {
                            setState(() => _isSaved = !_isSaved);
                            ref.read(photographerRepositoryProvider).toggleSavePhotographer(
                                  userId: 'current_user',
                                  photographerId: photographer.id,
                                );
                          },
                        ),
                      ),
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Cover Photo
                        NetworkImageView(
                          imageUrl: photographer.coverImageUrl ?? photographer.avatarUrl,
                          fit: BoxFit.cover,
                        ),
                        // Dark Gradient Overlay
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.2),
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.8),
                              ],
                            ),
                          ),
                        ),
                        // Dark Info Card at Bottom of Hero (Reference UI style)
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 16,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.darkHeader,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        photographer.name,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                          letterSpacing: -0.3,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (photographer.isVerified) ...[
                                      const SizedBox(width: 6),
                                      const Icon(Icons.verified_rounded, color: AppColors.primaryLight, size: 18),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: AppColors.accentEmerald,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Text(
                                      'Available now',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.accentEmerald,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    const Icon(Icons.star_rounded, size: 16, color: AppColors.accentAmber),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${photographer.rating.toStringAsFixed(1)} (${photographer.reviewCount} Reviews)',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // Action Pills
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        decoration: BoxDecoration(
                                          color: AppColors.glassWhite,
                                          borderRadius: BorderRadius.circular(100),
                                          border: Border.all(color: AppColors.glassWhiteBorder),
                                        ),
                                        child: const Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.info_outline_rounded, size: 14, color: Colors.white),
                                            SizedBox(width: 6),
                                            Text(
                                              'More info',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => _proceedToBooking(photographer),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary,
                                            borderRadius: BorderRadius.circular(100),
                                          ),
                                          child: const Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.explore_outlined, size: 14, color: Colors.white),
                                              SizedBox(width: 6),
                                              Text(
                                                'Get Direction',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 2. Navigation Tabs
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverTabBarDelegate(
                    Container(
                      color: AppColors.backgroundLight,
                      child: TabBar(
                        controller: _tabController,
                        labelColor: AppColors.primary,
                        unselectedLabelColor: AppColors.textSecondaryLight,
                        indicatorColor: AppColors.primary,
                        indicatorWeight: 3,
                        labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                        tabs: const [
                          Tab(text: 'Services'),
                          Tab(text: 'Slots'),
                          Tab(text: 'Portfolio'),
                          Tab(text: 'Reviews'),
                        ],
                      ),
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildServicesTab(photographer, packagesAsync),
                _buildSlotsTab(photographer),
                _buildPortfolioTab(photographer),
                _buildReviewsTab(photographer),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: LoadingIndicator(message: 'Loading creator profile...'),
        ),
        error: (e, _) => ErrorView(message: e.toString()),
      ),
      bottomNavigationBar: photographerAsync.value != null
          ? _buildDualBottomBar(photographerAsync.value!)
          : null,
    );
  }

  // 1. Services Tab with Colored Option Cards (Reference UI)
  Widget _buildServicesTab(
      PhotographerModel photographer, AsyncValue<List<PackageModel>> packagesAsync) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bio / Overview
          if (photographer.bio.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.cardBorderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'About Creator',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimaryLight),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    photographer.bio,
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondaryLight, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          const Text(
            'Packages & Pricing',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimaryLight),
          ),
          const SizedBox(height: 12),

          packagesAsync.when(
            data: (packages) {
              if (packages.isEmpty) {
                return const EmptyStateView(
                  icon: Icons.inventory_2_outlined,
                  title: 'No custom packages',
                  message: 'Standard hourly session available.',
                );
              }

              final badgeColors = [
                (AppColors.badgeGreenBg, AppColors.badgeGreenIcon),
                (AppColors.badgeCoralBg, AppColors.badgeCoralIcon),
                (AppColors.badgePinkBg, AppColors.badgePinkIcon),
                (AppColors.badgeSkyBg, AppColors.badgeSkyIcon),
              ];

              return Column(
                children: packages.asMap().entries.map((entry) {
                  final index = entry.key;
                  final pkg = entry.value;
                  final isSelected = _selectedPackage?.id == pkg.id;
                  final (bg, iconColor) = badgeColors[index % badgeColors.length];

                  return GestureDetector(
                    onTap: () => setState(() => _selectedPackage = pkg),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.chipSelectedBg : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.cardBorderLight,
                          width: isSelected ? 1.8 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: bg,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(Icons.camera_alt_rounded, color: iconColor, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  pkg.title,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: isSelected ? AppColors.primaryDark : AppColors.textPrimaryLight,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '${pkg.durationMinutes} min • ${pkg.deliverablesCount} Deliverables',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                CurrencyFormatter.format(pkg.price),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              ),
                              if (isSelected) ...[
                                const SizedBox(height: 2),
                                const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.primary),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const LoadingIndicator(),
            error: (e, _) => ErrorView(message: e.toString()),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // 2. Available Slots Tab (Reference Screen 1)
  Widget _buildSlotsTab(PhotographerModel photographer) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.cardBorderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Available slots for today',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimaryLight),
                ),
                const SizedBox(height: 14),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 2.2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: _quickSlots.length,
                  itemBuilder: (context, index) {
                    final slot = _quickSlots[index];
                    final isSelected = _selectedSlot == slot;

                    return InkWell(
                      onTap: () => setState(() => _selectedSlot = slot),
                      borderRadius: BorderRadius.circular(12),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.chipSelectedBg : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.cardBorderLight,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            slot,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? AppColors.primaryDark : AppColors.textPrimaryLight,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // 3. Portfolio Tab
  Widget _buildPortfolioTab(PhotographerModel photographer) {
    if (photographer.portfolioUrls.isEmpty) {
      return const EmptyStateView(
        icon: Icons.photo_library_outlined,
        title: 'No portfolio items',
        message: 'This creator has not uploaded sample photos yet.',
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: photographer.portfolioUrls.length,
      itemBuilder: (context, index) {
        final url = photographer.portfolioUrls[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PortfolioViewerScreen(
                  imageUrls: photographer.portfolioUrls,
                  initialIndex: index,
                ),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: NetworkImageView(imageUrl: url, fit: BoxFit.cover),
          ),
        );
      },
    );
  }

  // 4. Reviews Tab
  Widget _buildReviewsTab(PhotographerModel photographer) {
    final reviewsAsync = ref.watch(photographerReviewsProvider(photographer.id));

    return reviewsAsync.when(
      data: (reviews) {
        if (reviews.isEmpty) {
          return const EmptyStateView(
            icon: Icons.rate_review_outlined,
            title: 'No reviews yet',
            message: 'Be the first to book and review this creator!',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: reviews.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final review = reviews[index];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.cardBorderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        review.userName,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimaryLight),
                      ),
                      RatingBarWidget(rating: review.rating, itemSize: 13),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    review.comment,
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondaryLight, height: 1.4),
                  ),
                ],
              ),
            );
          },
        );
      },
      loading: () => const LoadingIndicator(),
      error: (e, _) => ErrorView(message: e.toString()),
    );
  }

  // Dual Bottom Action Bar (Reference Screen 1: Food Menu / Book a Table style)
  Widget _buildDualBottomBar(PhotographerModel photographer) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'View Portfolio',
                isOutlined: true,
                onPressed: () => _tabController.animateTo(2),
                height: 52,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomButton(
                text: 'Book a Session',
                backgroundColor: AppColors.primary,
                textColor: Colors.white,
                onPressed: () => _proceedToBooking(photographer),
                height: 52,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _SliverTabBarDelegate(this.child);

  @override
  double get minExtent => 48;
  @override
  double get maxExtent => 48;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) => false;
}
