import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routing/app_routes.dart';
import '../../models/photographer_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/supabase_service.dart';

class CreatorOnboardingScreen extends ConsumerStatefulWidget {
  const CreatorOnboardingScreen({super.key});

  @override
  ConsumerState<CreatorOnboardingScreen> createState() =>
      _CreatorOnboardingScreenState();
}

class _CreatorOnboardingScreenState
    extends ConsumerState<CreatorOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _taglineController = TextEditingController();
  final _bioController = TextEditingController();
  final _startingPriceController = TextEditingController(text: '4999');
  final _hourlyRateController = TextEditingController(text: '1999');
  final _locationController = TextEditingController(text: 'Bandra West, Mumbai');
  final _experienceController = TextEditingController(text: '5');

  final List<String> _selectedCategories = ['Wedding', 'Portrait'];
  final List<String> _selectedStyles = ['Cinematic', 'Editorial'];
  final List<String> _equipmentList = ['Sony A7 IV', '85mm f/1.4 GM', 'Godox AD200'];

  final List<String> _allCategories = [
    'Wedding',
    'Portrait',
    'Fashion',
    'Commercial',
    'Event',
    'Reels',
    'Drone',
    'Pre-Wedding',
  ];

  final List<String> _allStyles = [
    'Cinematic',
    'Editorial',
    'Candid',
    'Vibrant & Warm',
    'Moody & Dark',
    'Vintage',
  ];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    if (user?.displayName != null) {
      _nameController.text = user!.displayName!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _taglineController.dispose();
    _bioController.dispose();
    _startingPriceController.dispose();
    _hourlyRateController.dispose();
    _locationController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  Future<void> _completeProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final user = ref.read(currentUserProvider);
      final userId = user?.uid ?? 'creator_${DateTime.now().millisecondsSinceEpoch}';

      final photographer = PhotographerModel(
        id: userId,
        userId: userId,
        name: _nameController.text.trim(),
        email: user?.email ?? 'creator@pyp.com',
        phone: user?.phoneNumber ?? '+91 98200 12345',
        avatarUrl: user?.photoURL ??
            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500&q=80',
        coverImageUrl:
            'https://images.unsplash.com/photo-1492691527719-9d1e07e534b4?w=1200&q=80',
        tagline: _taglineController.text.trim().isNotEmpty
            ? _taglineController.text.trim()
            : 'Award-Winning Visual Storyteller & Cinematographer',
        bio: _bioController.text.trim().isNotEmpty
            ? _bioController.text.trim()
            : 'Passionate about crafting cinematic frames, natural light portraits, and timeless visual memories.',
        categories: _selectedCategories,
        styles: _selectedStyles,
        equipment: _equipmentList,
        startingPrice: double.tryParse(_startingPriceController.text) ?? 4999.0,
        hourlyRate: double.tryParse(_hourlyRateController.text) ?? 1999.0,
        rating: 5.0,
        reviewCount: 1,
        experienceYears: int.tryParse(_experienceController.text) ?? 5,
        location: _locationController.text.trim(),
        latitude: 19.0596,
        longitude: 72.8295,
        portfolioImages: [
          'https://images.unsplash.com/photo-1519741497674-611481863552?w=800&q=80',
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800&q=80',
          'https://images.unsplash.com/photo-1511285560929-80b456fea0bc?w=800&q=80',
        ],
        createdAt: DateTime.now(),
      );

      final supabase = ref.read(supabaseServiceProvider);
      await supabase.createPhotographerProfile(photographer);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Studio profile created successfully! Welcome to Creator Studio.'),
            backgroundColor: AppColors.primary,
          ),
        );
        context.go(AppRoutes.creatorDashboard);
      }
    } catch (e) {
      if (mounted) {
        context.go(AppRoutes.creatorDashboard);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Complete Creator Profile',
          style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified_rounded, color: AppColors.primary, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Set Up Your Studio',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                fontFamily: 'Outfit',
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Showcase your packages & portfolio to thousands of potential clients.',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Full Name / Studio Name
                const Text('Studio / Creator Name', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'e.g. Arjun Mehta Studios',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.business_rounded),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Please enter name' : null,
                ),
                const SizedBox(height: 20),

                // Tagline
                const Text('Tagline', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _taglineController,
                  decoration: InputDecoration(
                    hintText: 'e.g. Vogue Featured • Cinematic Light Specialist',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.flash_on_rounded),
                  ),
                ),
                const SizedBox(height: 20),

                // Pricing Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Starting Price (₹)', style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _startingPriceController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: '4999',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              prefixText: '₹ ',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Hourly Rate (₹)', style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _hourlyRateController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: '1999',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              prefixText: '₹ ',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Location & Experience
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('City / Location', style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _locationController,
                            decoration: InputDecoration(
                              hintText: 'Bandra West, Mumbai',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              prefixIcon: const Icon(Icons.location_on_rounded),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Exp (Yrs)', style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _experienceController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: '5',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Categories
                const Text('Shoot Categories', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _allCategories.map((cat) {
                    final isSelected = _selectedCategories.contains(cat);
                    return FilterChip(
                      selected: isSelected,
                      label: Text(cat),
                      selectedColor: AppColors.primary.withValues(alpha: 0.15),
                      checkmarkColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.primary : Colors.grey.shade800,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedCategories.add(cat);
                          } else {
                            _selectedCategories.remove(cat);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Styles
                const Text('Photography Styles', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _allStyles.map((style) {
                    final isSelected = _selectedStyles.contains(style);
                    return FilterChip(
                      selected: isSelected,
                      label: Text(style),
                      selectedColor: AppColors.primary.withValues(alpha: 0.15),
                      checkmarkColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.primary : Colors.grey.shade800,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedStyles.add(style);
                          } else {
                            _selectedStyles.remove(style);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 36),

                // Submit CTA
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _completeProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            'Complete Profile & Open Studio →',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontFamily: 'Outfit',
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
