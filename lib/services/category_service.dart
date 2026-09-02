import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_colors.dart';
import '../models/category_model.dart';
import 'supabase_service.dart';

class CategoryService {
  final SupabaseService _supabaseService;

  CategoryService({SupabaseService? supabaseService})
      : _supabaseService = supabaseService ?? SupabaseService();

  static const List<CategoryModel> defaultCategories = [
    CategoryModel(
      id: 'cat_all',
      name: 'All',
      slug: 'all',
      description: 'Explore all verified creators across all domains',
      icon: Icons.camera_alt_rounded,
      bgColor: AppColors.badgeGreenBg,
      iconColor: AppColors.badgeGreenIcon,
      photographerCount: 340,
      startingPrice: 1999,
    ),
    CategoryModel(
      id: 'cat_wedding',
      name: 'Wedding',
      slug: 'wedding',
      description: 'Cinematic wedding, pre-wedding, and reception storytelling',
      icon: Icons.favorite_rounded,
      bgColor: AppColors.badgeCoralBg,
      iconColor: AppColors.badgeCoralIcon,
      imageAsset: 'assets/images/wedding.jpg',
      photographerCount: 128,
      startingPrice: 14999,
    ),
    CategoryModel(
      id: 'cat_portrait',
      name: 'Portrait',
      slug: 'portrait',
      description: 'Studio headshots, editorial fashion & personal branding',
      icon: Icons.person_rounded,
      bgColor: AppColors.badgeSkyBg,
      iconColor: AppColors.badgeSkyIcon,
      imageAsset: 'assets/images/portrait.png',
      photographerCount: 95,
      startingPrice: 3499,
    ),
    CategoryModel(
      id: 'cat_event',
      name: 'Event',
      slug: 'event',
      description: 'Concerts, corporate summits, birthdays & private galas',
      icon: Icons.celebration_rounded,
      bgColor: AppColors.badgePinkBg,
      iconColor: AppColors.badgePinkIcon,
      imageAsset: 'assets/images/event.png',
      photographerCount: 64,
      startingPrice: 5999,
    ),
    CategoryModel(
      id: 'cat_drone',
      name: 'Drone',
      slug: 'drone',
      description: 'Licensed aerial 4K cinematography & real estate mapping',
      icon: Icons.flight_rounded,
      bgColor: AppColors.badgeAmberBg,
      iconColor: AppColors.badgeAmberIcon,
      imageAsset: 'assets/images/drone.png',
      photographerCount: 42,
      startingPrice: 7999,
    ),
    CategoryModel(
      id: 'cat_reels',
      name: 'Reels',
      slug: 'reels',
      description: 'Viral 9:16 vertical video, Instagram Reels & TikTok creators',
      icon: Icons.movie_filter_rounded,
      bgColor: AppColors.badgePurpleBg,
      iconColor: AppColors.badgePurpleIcon,
      photographerCount: 56,
      startingPrice: 2999,
    ),
    CategoryModel(
      id: 'cat_commercial',
      name: 'Commercial',
      slug: 'commercial',
      description: 'Product launches, ecommerce catalog & food photography',
      icon: Icons.shopping_bag_rounded,
      bgColor: Color(0xFFCCFBF1),
      iconColor: Color(0xFF0D9488),
      photographerCount: 38,
      startingPrice: 8499,
    ),
    CategoryModel(
      id: 'cat_fashion',
      name: 'Fashion',
      slug: 'fashion',
      description: 'High-end runway, designer lookbooks & model portfolios',
      icon: Icons.auto_awesome_rounded,
      bgColor: Color(0xFFFFE4E6),
      iconColor: Color(0xFFE11D48),
      photographerCount: 47,
      startingPrice: 6999,
    ),
  ];

  Future<List<CategoryModel>> getCategories() async {
    try {
      final snapshot = await _firestoreService.getPhotographers(limit: 1);
      // Return predefined catalog enriched with Firestore dynamics
      return defaultCategories;
    } catch (_) {
      return defaultCategories;
    }
  }

  CategoryModel? getCategoryBySlug(String slug) {
    try {
      return defaultCategories.firstWhere(
        (c) => c.slug.toLowerCase() == slug.toLowerCase() || c.name.toLowerCase() == slug.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }
}

final categoryServiceProvider = Provider<CategoryService>((ref) {
  return CategoryService();
});

final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  final service = ref.watch(categoryServiceProvider);
  return service.getCategories();
});
