import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../models/review_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/creator_provider.dart';
import '../../services/supabase_service.dart';

class CreatorReviewsScreen extends ConsumerWidget {
  const CreatorReviewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final photographerId = user?.id ?? 'creator_current';
    final profileAsync = ref.watch(creatorProfileProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimaryLight, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Client Reviews & Ratings',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: AppColors.textPrimaryLight,
          ),
        ),
      ),
      body: FutureBuilder<List<ReviewModel>>(
        future: ref.read(supabaseServiceProvider).getReviews(photographerId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          final reviews = snapshot.data ?? [];
          final profile = profileAsync.value;
          final double rating = reviews.isNotEmpty
              ? (reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length)
              : (profile?.rating ?? 0.0);
          final int reviewCount = reviews.isNotEmpty ? reviews.length : (profile?.reviewCount ?? 0);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Rating Overview Card
                _buildRatingHeroCard(rating, reviewCount, reviews),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'All Verified Reviews (${reviews.length})',
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                    const Icon(Icons.verified_user_rounded, color: Color(0xFF00A86B), size: 18),
                  ],
                ),
                const SizedBox(height: 12),

                if (reviews.isEmpty)
                  _buildEmptyReviewsCard()
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: reviews.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final r = reviews[index];
                      return _buildReviewCard(r);
                    },
                  ),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRatingHeroCard(double rating, int reviewCount, List<ReviewModel> reviews) {
    final count5 = reviews.where((r) => r.rating >= 4.5).length;
    final count4 = reviews.where((r) => r.rating >= 3.5 && r.rating < 4.5).length;
    final count3 = reviews.where((r) => r.rating >= 2.5 && r.rating < 3.5).length;
    final count2 = reviews.where((r) => r.rating >= 1.5 && r.rating < 2.5).length;
    final count1 = reviews.where((r) => r.rating < 1.5).length;
    final total = reviews.isNotEmpty ? reviews.length.toDouble() : 1.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
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
          // Left: Big Score
          Column(
            children: [
              Text(
                rating > 0 ? rating.toStringAsFixed(2) : '0.0',
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    Icons.star_rounded,
                    color: i < rating.round() ? const Color(0xFFF59E0B) : Colors.grey.shade300,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$reviewCount Verified Shoots',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(width: 24),

          // Right: Star distribution bars
          Expanded(
            child: Column(
              children: [
                _buildStarBar(5, reviews.isNotEmpty ? count5 / total : 0.0),
                _buildStarBar(4, reviews.isNotEmpty ? count4 / total : 0.0),
                _buildStarBar(3, reviews.isNotEmpty ? count3 / total : 0.0),
                _buildStarBar(2, reviews.isNotEmpty ? count2 / total : 0.0),
                _buildStarBar(1, reviews.isNotEmpty ? count1 / total : 0.0),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStarBar(int star, double percent) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text('$star★', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey.shade600)),
          const SizedBox(width: 6),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percent,
                backgroundColor: const Color(0xFFF1F5F9),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF59E0B)),
                minHeight: 6,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '${(percent * 100).toInt()}%',
            style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(ReviewModel r) {
    final dateStr = DateFormat('dd MMMM yyyy').format(r.createdAt);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                backgroundImage: (r.userAvatar.isNotEmpty) ? NetworkImage(r.userAvatar) : null,
                child: r.userAvatar.isEmpty
                    ? Text(
                        r.userName.isNotEmpty ? r.userName[0].toUpperCase() : '?',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.userName,
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      dateStr,
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 14),
                    const SizedBox(width: 4),
                    Text(
                      r.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        color: Color(0xFFF59E0B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (r.comment.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              r.comment,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.4),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyReviewsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.star_outline_rounded, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            const Text(
              'No Verified Reviews Yet',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Ratings and feedback from your clients will appear here as bookings are completed.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
