import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/geohash_util.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/loading_indicator.dart';
import '../../providers/location_provider.dart';
import '../../services/location_service.dart';

class LocationPickerScreen extends ConsumerStatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  ConsumerState<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends ConsumerState<LocationPickerScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  List<LocationSuggestion> _suggestions = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      if (query.trim().isEmpty) {
        setState(() {
          _suggestions = [];
          _isSearching = false;
        });
        return;
      }

      setState(() => _isSearching = true);
      final locationService = ref.read(locationServiceProvider);
      final results = await locationService.searchPlaces(query);

      if (mounted) {
        setState(() {
          _suggestions = results;
          _isSearching = false;
        });
      }
    });
  }

  Future<void> _useCurrentLocation() async {
    final notifier = ref.read(locationProvider.notifier);
    await notifier.detectCurrentLocation();
    if (mounted) context.pop();
  }

  void _selectSuggestion(LocationSuggestion suggestion) {
    final lat = suggestion.latitude ?? 37.7749;
    final lon = suggestion.longitude ?? -122.4194;
    final geohash = GeohashUtil.encode(lat, lon);

    final parts = suggestion.description.split(',');
    final city = parts.isNotEmpty ? parts[0].trim() : 'Selected Location';

    ref.read(locationProvider.notifier).setCustomLocation(
      formattedAddress: suggestion.description,
      city: city,
      latitude: lat,
      longitude: lon,
      geohash: geohash,
    );

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationProvider);

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
          'Choose Location',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimaryLight,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                controller: _searchController,
                hintText: 'Search city, area or street...',
                onChanged: _onSearchChanged,
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondaryLight),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
              ),
              const SizedBox(height: 16),

              // Use GPS Location Button
              GestureDetector(
                onTap: _useCurrentLocation,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
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
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.badgeGreenBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.my_location_rounded, color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Use Current GPS Location',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimaryLight,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Find top photographers nearest to you',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondaryLight),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Suggestions or Popular Cities
              Expanded(
                child: _isSearching
                    ? const Center(child: LoadingIndicator(message: 'Searching places...'))
                    : _suggestions.isNotEmpty
                        ? ListView.separated(
                            itemCount: _suggestions.length,
                            separatorBuilder: (_, __) => const Divider(color: AppColors.cardBorderLight),
                            itemBuilder: (context, index) {
                              final suggestion = _suggestions[index];
                              return ListTile(
                                leading: const Icon(Icons.location_on_outlined, color: AppColors.primary),
                                title: Text(
                                  suggestion.description,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimaryLight,
                                  ),
                                ),
                                onTap: () => _selectSuggestion(suggestion),
                              );
                            },
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Popular Cities',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimaryLight,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  'Delhi NCR',
                                  'Mumbai',
                                  'Bengaluru',
                                  'Hyderabad',
                                  'Goa',
                                  'Jaipur',
                                  'Chennai',
                                  'Kolkata',
                                ].map((city) {
                                  return ActionChip(
                                    label: Text(city),
                                    backgroundColor: Colors.white,
                                    side: const BorderSide(color: AppColors.cardBorderLight),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                                    labelStyle: const TextStyle(
                                      color: AppColors.textPrimaryLight,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                    onPressed: () {
                                      ref.read(locationProvider.notifier).setCustomLocation(
                                        formattedAddress: '$city, India',
                                        city: city,
                                        latitude: 28.6139,
                                        longitude: 77.2090,
                                        geohash: 'ttnfvn',
                                      );
                                      context.pop();
                                    },
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
