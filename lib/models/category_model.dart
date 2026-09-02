import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class CategoryModel {
  final String id;
  final String name;
  final String slug;
  final String description;
  final IconData icon;
  final Color bgColor;
  final Color iconColor;
  final String? imageAsset;
  final int photographerCount;
  final double startingPrice;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.icon,
    required this.bgColor,
    required this.iconColor,
    this.imageAsset,
    this.photographerCount = 0,
    this.startingPrice = 1999,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map, String id) {
    return CategoryModel(
      id: id,
      name: map['name'] as String? ?? '',
      slug: map['slug'] as String? ?? '',
      description: map['description'] as String? ?? '',
      icon: _getIconData(map['iconName'] as String?),
      bgColor: _getColor(map['bgColorHex'] as String?, AppColors.badgeGreenBg),
      iconColor: _getColor(map['iconColorHex'] as String?, AppColors.primary),
      imageAsset: map['imageAsset'] as String?,
      photographerCount: (map['photographerCount'] as num?)?.toInt() ?? 0,
      startingPrice: (map['startingPrice'] as num?)?.toDouble() ?? 1999,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'slug': slug,
      'description': description,
      'imageAsset': imageAsset,
      'photographerCount': photographerCount,
      'startingPrice': startingPrice,
    };
  }

  static IconData _getIconData(String? iconName) {
    switch (iconName) {
      case 'heart':
      case 'wedding':
        return Icons.favorite_rounded;
      case 'portrait':
      case 'user':
        return Icons.person_rounded;
      case 'event':
      case 'champagne':
        return Icons.celebration_rounded;
      case 'drone':
        return Icons.flight_rounded;
      case 'reels':
      case 'video':
        return Icons.movie_filter_rounded;
      case 'commercial':
      case 'product':
        return Icons.shopping_bag_rounded;
      case 'fashion':
        return Icons.auto_awesome_rounded;
      case 'all':
      default:
        return Icons.camera_alt_rounded;
    }
  }

  static Color _getColor(String? hex, Color fallback) {
    if (hex == null) return fallback;
    try {
      final buffer = StringBuffer();
      if (hex.length == 6 || hex.length == 7) buffer.write('ff');
      buffer.write(hex.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return fallback;
    }
  }
}
