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
  ConsumerState<CreatorOnboardingScreen> createState() => _CreatorOnboardingScreenState();
}

class _CreatorOnboardingScreenState extends ConsumerState<CreatorOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _taglineController = TextEditingController();
  final _bioController = TextEditingController();
  final _cityController = TextEditingController(text: 'Mumbai');
  final _serviceAreaController = TextEditingController(text: 'Mumbai, Bandra, Thane & Navi Mumbai');
  final _startingPriceController = TextEditingController(text: '4999');
  final _hourlyRateController = TextEditingController(text: '1999');
  final _experienceController = TextEditingController(text: '5');
  final _avatarUrlController = TextEditingController();

  String _creatorType = 'both'; // 'photography', 'videography', 'both'

  final List<String> _selectedCategories = ['Wedding', 'Portrait', 'Event'];
  final List<String> _selectedStyles = ['Cinematic', 'Editorial', 'Candid'];
  final List<String> _equipmentList = ['Sony A7 IV', '85mm f/1.4 GM', 'Godox AD200', 'DJI RS3'];

  final List<String> _allCategories = [
    'Wedding',
    'Engagement',
    'Pre-Wedding',
    'Birthday',
    'Portrait',
    'Fashion',
    'Commercial',
    'Event',
    'Product',
    'Reels',
    'Drone',
  ];

  final List<String> _allStyles = [
    'Candid',
    'Cinematic',
    'Editorial',
    'Natural',
    'Luxury',
    'Documentary',
    'Vibrant & Warm',
    'Moody & Dark',
    'Outdoor',
    'Indoor',
    'Vintage',
  ];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    if (user != null) {
      if (user.name.isNotEmpty) _nameController.text = user.name;
      if (user.phone.isNotEmpty) _phoneController.text = user.phone;
      if (user.avatarUrl != null && user.avatarUrl!.isNotEmpty) {
        _avatarUrlController.text = user.avatarUrl!;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _taglineController.dispose();
    _bioController.dispose();
    _cityController.dispose();
    _serviceAreaController.dispose();
    _startingPriceController.dispose();
    _hourlyRateController.dispose();
    _experienceController.dispose();
    _avatarUrlController.dispose();
    super.dispose();
  }

  Future<void> _completeProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final user = ref.read(currentUserProvider);
      final userId = user?.id ?? '';

      final photographer = PhotographerModel(
        id: userId,
        userId: userId,
        name: _nameController.text.trim(),
        email: user?.email ?? '',
        phone: _phoneController.text.trim().isNotEmpty
            ? _phoneController.text.trim()
            : (user?.phone ?? ''),
        avatarUrl: _avatarUrlController.text.trim().isNotEmpty
            ? _avatarUrlController.text.trim()
            : user?.avatarUrl,
        coverImageUrl: null,
        tagline: _taglineController.text.trim().isNotEmpty
            ? _taglineController.text.trim()
            : 'Professional Visual Creator',
        bio: _bioController.text.trim(),
        categories: _selectedCategories,
        styles: _selectedStyles,
        equipment: _equipmentList,
        startingPrice: double.tryParse(_startingPriceController.text) ?? 0.0,
        hourlyRate: double.tryParse(_hourlyRateController.text) ?? 0.0,
        rating: 0.0,
        reviewCount: 0,
        experienceYears: int.tryParse(_experienceController.text) ?? 0,
        location: _cityController.text.trim(),
        serviceArea: _serviceAreaController.text.trim(),
        creatorType: _creatorType,
        latitude: 19.0760,
        longitude: 72.8777,
        portfolioImages: const [],
        createdAt: DateTime.now(),
      );

      final supabase = ref.read(supabaseServiceProvider);
      await supabase.createPhotographerProfile(photographer);

      // Upgrade user profile role to 'creator'
      if (user != null) {
        final updatedUser = user.copyWith(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          role: 'creator',
          avatarUrl: _avatarUrlController.text.trim(),
          location: _cityController.text.trim(),
        );
        await ref.read(userProfileProvider.notifier).updateUser(updatedUser);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Creator studio verified & published! Welcome aboard.'),
            backgroundColor: AppColors.primary,
          ),
        );
        context.go(AppRoutes.creatorDashboard);
      }
    } catch (e) {
      debugPrint('Creator onboarding notice: $e');
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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Creator Studio Onboarding',
          style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700, color: AppColors.textPrimaryLight),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textPrimaryLight),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.camera_alt_rounded, color: AppColors.primary, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Set Up Your Studio Profile',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: Colors.white,
                                fontFamily: 'Outfit',
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Showcase your craft, receive client bookings, and unlock escrow payouts.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // SECTION 1: Personal & Brand Info
                _buildSectionHeader('1. Personal & Studio Identity', Icons.person_rounded),
                const SizedBox(height: 12),
                _buildCard([
                  TextFormField(
                    controller: _nameController,
                    decoration: _inputDecoration('Studio / Full Name', 'e.g. Studio / Professional Name', Icons.person_outline),
                    validator: (v) => v?.trim().isEmpty == true ? 'Studio/Name is required' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: _inputDecoration('Business Phone Number', 'Enter your contact number', Icons.phone_outlined),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _avatarUrlController,
                    decoration: _inputDecoration('Profile Photo URL', 'https://...', Icons.image_outlined),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _taglineController,
                    decoration: _inputDecoration('Professional Tagline', 'e.g. Award-Winning Cinematic Visuals', Icons.star_border_rounded),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _bioController,
                    maxLines: 3,
                    decoration: _inputDecoration('Professional Bio', 'Tell clients about your shooting style and experience...', Icons.article_outlined),
                  ),
                ]),
                const SizedBox(height: 24),

                // SECTION 2: Specialization & Creator Type
                _buildSectionHeader('2. Craft & Medium', Icons.movie_filter_rounded),
                const SizedBox(height: 12),
                _buildCard([
                  const Text(
                    'What type of creator are you?',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimaryLight),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildTypeChoice('Photography', 'photography', Icons.camera_alt_rounded),
                      const SizedBox(width: 8),
                      _buildTypeChoice('Videography', 'videography', Icons.videocam_rounded),
                      const SizedBox(width: 8),
                      _buildTypeChoice('Both', 'both', Icons.auto_awesome_rounded),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _experienceController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration('Years of Experience', 'e.g. 5', Icons.timeline_rounded),
                  ),
                ]),
                const SizedBox(height: 24),

                // SECTION 3: Service Area & Location
                _buildSectionHeader('3. Location & Service Coverage', Icons.location_on_rounded),
                const SizedBox(height: 12),
                _buildCard([
                  TextFormField(
                    controller: _cityController,
                    decoration: _inputDecoration('Primary City', 'e.g. Mumbai', Icons.location_city_rounded),
                    validator: (v) => v?.trim().isEmpty == true ? 'City is required' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _serviceAreaController,
                    decoration: _inputDecoration('Service Area Coverage', 'e.g. South Mumbai, Bandra, Thane, Goa', Icons.map_outlined),
                  ),
                ]),
                const SizedBox(height: 24),

                // SECTION 4: Categories & Photography Styles
                _buildSectionHeader('4. Services & Aesthetic Styles', Icons.style_rounded),
                const SizedBox(height: 12),
                _buildCard([
                  const Text('Categories Offered:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimaryLight)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _allCategories.map((cat) {
                      final isSelected = _selectedCategories.contains(cat);
                      return FilterChip(
                        label: Text(cat),
                        selected: isSelected,
                        selectedColor: AppColors.primary.withValues(alpha: 0.15),
                        checkmarkColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: isSelected ? AppColors.primary : AppColors.textSecondaryLight,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 12,
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
                  const SizedBox(height: 16),
                  const Text('Photography & Video Styles:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimaryLight)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _allStyles.map((style) {
                      final isSelected = _selectedStyles.contains(style);
                      return FilterChip(
                        label: Text(style),
                        selected: isSelected,
                        selectedColor: const Color(0xFF10B981).withValues(alpha: 0.15),
                        checkmarkColor: const Color(0xFF10B981),
                        labelStyle: TextStyle(
                          color: isSelected ? const Color(0xFF10B981) : AppColors.textSecondaryLight,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 12,
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
                ]),
                const SizedBox(height: 24),

                // SECTION 5: Pricing
                _buildSectionHeader('5. Baseline Pricing', Icons.currency_rupee_rounded),
                const SizedBox(height: 12),
                _buildCard([
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _startingPriceController,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration('Starting Price (₹)', '4999', Icons.sell_outlined),
                          validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _hourlyRateController,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration('Hourly Rate (₹)', '1999', Icons.timer_outlined),
                        ),
                      ),
                    ],
                  ),
                ]),
                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                      shadowColor: AppColors.primary.withValues(alpha: 0.4),
                    ),
                    onPressed: _isLoading ? null : _completeProfile,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Launch Creator Studio →',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Outfit'),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            fontFamily: 'Outfit',
            color: AppColors.textPrimaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildTypeChoice(String label, String value, IconData icon) {
    final isSelected = _creatorType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _creatorType = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.transparent,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? Colors.white : AppColors.textSecondaryLight, size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, String hint, IconData icon) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, size: 20, color: AppColors.textSecondaryLight),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.cardBorderLight)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.cardBorderLight)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
    );
  }
}
