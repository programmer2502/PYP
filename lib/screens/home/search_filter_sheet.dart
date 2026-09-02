import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/widgets/custom_button.dart';
import '../../models/filter_model.dart';
import '../../providers/photographer_provider.dart';

class SearchFilterSheet extends ConsumerStatefulWidget {
  const SearchFilterSheet({super.key});

  @override
  ConsumerState<SearchFilterSheet> createState() => _SearchFilterSheetState();
}

class _SearchFilterSheetState extends ConsumerState<SearchFilterSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 1. Basic Filters State
  String? _selectedCategory;
  final TextEditingController _locationController = TextEditingController();
  late RangeValues _priceRange;
  String? _selectedServiceType;

  // 2. Availability Filters State
  DateTime? _selectedDate;
  String? _selectedTimeSlot;
  int? _selectedDurationHours;

  // 3. Advanced Filters State
  List<String> _selectedStyles = [];
  List<String> _selectedEquipment = [];
  double _minRating = 0.0;
  int? _minExperienceYears;
  double _maxDistanceKm = 50.0;

  // Sorting
  String _sortBy = 'best_match';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    final currentFilter = ref.read(activeFilterProvider);
    _selectedCategory = currentFilter.category;
    _locationController.text = currentFilter.location ?? '';
    _priceRange = RangeValues(
      currentFilter.minPrice ?? 500,
      currentFilter.maxPrice ?? 50000,
    );
    _selectedServiceType = currentFilter.serviceType;

    _selectedDate = currentFilter.date;
    _selectedTimeSlot = currentFilter.timeSlot;
    _selectedDurationHours = currentFilter.durationHours;

    _selectedStyles = List.from(currentFilter.styles);
    _selectedEquipment = List.from(currentFilter.equipment);
    _minRating = currentFilter.minRating ?? 0.0;
    _minExperienceYears = currentFilter.minExperienceYears;
    _maxDistanceKm = currentFilter.maxDistanceKm ?? 50.0;
    _sortBy = currentFilter.sortBy;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final updated = FilterModel(
      category: _selectedCategory != 'All' ? _selectedCategory : null,
      location: _locationController.text.trim().isNotEmpty ? _locationController.text.trim() : null,
      minPrice: _priceRange.start > 500 ? _priceRange.start : null,
      maxPrice: _priceRange.end < 50000 ? _priceRange.end : null,
      serviceType: _selectedServiceType,
      date: _selectedDate,
      timeSlot: _selectedTimeSlot,
      durationHours: _selectedDurationHours,
      styles: _selectedStyles,
      equipment: _selectedEquipment,
      minRating: _minRating > 0 ? _minRating : null,
      minExperienceYears: _minExperienceYears,
      maxDistanceKm: _maxDistanceKm < 100 ? _maxDistanceKm : null,
      sortBy: _sortBy,
    );

    ref.read(activeFilterProvider.notifier).state = updated;
    ref.read(paginatedPhotographersProvider.notifier).fetchInitial();
    Navigator.pop(context);
  }

  void _resetAll() {
    setState(() {
      _selectedCategory = null;
      _locationController.clear();
      _priceRange = const RangeValues(500, 50000);
      _selectedServiceType = null;
      _selectedDate = null;
      _selectedTimeSlot = null;
      _selectedDurationHours = null;
      _selectedStyles = [];
      _selectedEquipment = [];
      _minRating = 0.0;
      _minExperienceYears = null;
      _maxDistanceKm = 100.0;
      _sortBy = 'best_match';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.86,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.cardBorderLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter & Matching Engine',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimaryLight,
                    letterSpacing: -0.3,
                  ),
                ),
                TextButton(
                  onPressed: _resetAll,
                  child: const Text(
                    'Reset All',
                    style: TextStyle(
                      color: AppColors.accentRose,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3-Tier Filter Tabs: Basic Filters | Availability | Advanced
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(100),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.textSecondaryLight,
              labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Basic Filters'),
                Tab(text: 'Availability'),
                Tab(text: 'Advanced'),
              ],
            ),
          ),
          const Divider(color: AppColors.cardBorderLight, height: 1),

          // Tab Content Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBasicFiltersTab(),
                _buildAvailabilityTab(),
                _buildAdvancedTab(),
              ],
            ),
          ),

          // Bottom Action Bar
          Container(
            padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.cardBorderLight)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Apply & Rank Results',
                    icon: Icons.auto_awesome_rounded,
                    backgroundColor: AppColors.primary,
                    textColor: Colors.white,
                    onPressed: _applyFilters,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 1: BASIC FILTERS
  // -------------------------------------------------------------
  Widget _buildBasicFiltersTab() {
    final categories = ['All', 'Wedding', 'Portrait', 'Event', 'Commercial', 'Drone', 'Fashion', 'Food', 'Maternity'];
    final serviceTypes = ['Standard Shoot', 'Full Day Coverage', 'Drone Included', 'Cinematic Video Reel'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Category Selector
          const Text(
            'Photography Category',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimaryLight),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: categories.map((cat) {
              final isSelected = (_selectedCategory == cat) || (_selectedCategory == null && cat == 'All');
              return ChoiceChip(
                label: Text(cat),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() => _selectedCategory = cat == 'All' ? null : cat);
                },
                selectedColor: AppColors.primary,
                backgroundColor: Colors.white,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimaryLight,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                side: BorderSide(color: isSelected ? AppColors.primary : AppColors.cardBorderLight),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
              );
            }).toList(),
          ),
          const SizedBox(height: 22),

          // 2. Location & Radius
          const Text(
            'Target Location / City',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimaryLight),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _locationController,
            style: const TextStyle(fontSize: 13, color: AppColors.textPrimaryLight),
            decoration: InputDecoration(
              hintText: 'e.g. Bandra, Mumbai or Bengaluru',
              prefixIcon: const Icon(Icons.location_on_outlined, color: AppColors.primary, size: 20),
              filled: true,
              fillColor: AppColors.backgroundLight,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.cardBorderLight),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.cardBorderLight),
              ),
            ),
          ),
          const SizedBox(height: 22),

          // 3. Budget Range
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Budget Range',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimaryLight),
              ),
              Text(
                '${CurrencyFormatter.format(_priceRange.start)} - ${CurrencyFormatter.format(_priceRange.end)}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primary),
              ),
            ],
          ),
          RangeSlider(
            values: _priceRange,
            min: 500,
            max: 50000,
            divisions: 99,
            activeColor: AppColors.primary,
            inactiveColor: AppColors.chipBorderLight,
            onChanged: (values) => setState(() => _priceRange = values),
          ),
          const SizedBox(height: 18),

          // 4. Service / Package Type
          const Text(
            'Service Package Type',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimaryLight),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: serviceTypes.map((type) {
              final isSelected = _selectedServiceType == type;
              return ChoiceChip(
                label: Text(type),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() => _selectedServiceType = selected ? type : null);
                },
                selectedColor: AppColors.primary,
                backgroundColor: Colors.white,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimaryLight,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                side: BorderSide(color: isSelected ? AppColors.primary : AppColors.cardBorderLight),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 2: AVAILABILITY ENGINE FILTERS
  // -------------------------------------------------------------
  Widget _buildAvailabilityTab() {
    final timeSlots = ['Morning (09:00 AM - 12:00 PM)', 'Afternoon (01:00 PM - 04:00 PM)', 'Golden Hour (04:30 PM - 06:30 PM)', 'Night / Evening'];
    final durations = [1, 2, 4, 8];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Date Calendar Picker
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Required Shoot Date',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimaryLight),
              ),
              if (_selectedDate != null)
                Text(
                  DateFormatter.formatDate(_selectedDate!),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.cardBorderLight),
            ),
            child: TableCalendar(
              firstDay: DateTime.now(),
              lastDay: DateTime.now().add(const Duration(days: 90)),
              focusedDay: _selectedDate ?? DateTime.now(),
              currentDay: DateTime.now(),
              selectedDayPredicate: (day) => _selectedDate != null && isSameDay(_selectedDate!, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() => _selectedDate = selectedDay);
              },
              calendarFormat: CalendarFormat.month,
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
              calendarStyle: CalendarStyle(
                selectedDecoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                defaultTextStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 22),

          // 2. Preferred Time Slot
          const Text(
            'Time of Day',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimaryLight),
          ),
          const SizedBox(height: 10),
          Column(
            children: timeSlots.map((slot) {
              final isSelected = _selectedTimeSlot == slot;
              return GestureDetector(
                onTap: () => setState(() => _selectedTimeSlot = isSelected ? null : slot),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.badgeGreenBg : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: isSelected ? AppColors.primary : AppColors.cardBorderLight),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.access_time_rounded, size: 16, color: isSelected ? AppColors.primary : AppColors.textSecondaryLight),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          slot,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? AppColors.primary : AppColors.textPrimaryLight,
                          ),
                        ),
                      ),
                      if (isSelected) const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 18),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // 3. Expected Session Duration
          const Text(
            'Session Duration',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimaryLight),
          ),
          const SizedBox(height: 10),
          Row(
            children: durations.map((dur) {
              final isSelected = _selectedDurationHours == dur;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ChoiceChip(
                    label: Center(
                      child: Text(
                        '$dur hr${dur > 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.white : AppColors.textPrimaryLight,
                        ),
                      ),
                    ),
                    selected: isSelected,
                    showCheckmark: false,
                    onSelected: (selected) {
                      setState(() => _selectedDurationHours = selected ? dur : null);
                    },
                    selectedColor: AppColors.primary,
                    backgroundColor: Colors.white,
                    side: BorderSide(color: isSelected ? AppColors.primary : AppColors.cardBorderLight),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 3: ADVANCED FILTERS (Style, Equipment, Rating, Experience)
  // -------------------------------------------------------------
  Widget _buildAdvancedTab() {
    final experienceLevels = [
      {'label': '1+ Years', 'val': 1},
      {'label': '3+ Years', 'val': 3},
      {'label': '5+ Years (Pro)', 'val': 5},
      {'label': '8+ Years (Master)', 'val': 8},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Sort / Rank Strategy
          const Text(
            'Sort / Rank Results By',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimaryLight),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSortChip('⚡ Best Match Score', 'best_match'),
              _buildSortChip('⭐ Top Rated', 'rating'),
              _buildSortChip('💰 Price: Low to High', 'price_asc'),
              _buildSortChip('💎 Price: High to Low', 'price_desc'),
              _buildSortChip('🏆 Most Experienced', 'experience'),
            ],
          ),
          const SizedBox(height: 24),

          // 2. Minimum Rating
          const Text(
            'Minimum Rating Threshold',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimaryLight),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildRatingChip('Any', 0.0),
              const SizedBox(width: 8),
              _buildRatingChip('3.5+ ★', 3.5),
              const SizedBox(width: 8),
              _buildRatingChip('4.0+ ★', 4.0),
              const SizedBox(width: 8),
              _buildRatingChip('4.5+ ★', 4.5),
              const SizedBox(width: 8),
              _buildRatingChip('4.8+ ★', 4.8),
            ],
          ),
          const SizedBox(height: 24),

          // 3. Experience Level
          const Text(
            'Minimum Professional Experience',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimaryLight),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: experienceLevels.map((exp) {
              final isSelected = _minExperienceYears == exp['val'];
              return ChoiceChip(
                label: Text(exp['label'] as String),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() => _minExperienceYears = selected ? (exp['val'] as int) : null);
                },
                selectedColor: AppColors.primary,
                backgroundColor: Colors.white,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimaryLight,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                side: BorderSide(color: isSelected ? AppColors.primary : AppColors.cardBorderLight),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // 4. Photography Style Tags
          const Text(
            'Creative Style Tags',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimaryLight),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppConstants.styles.map((style) {
              final isSelected = _selectedStyles.contains(style);
              return FilterChip(
                label: Text(style),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedStyles.add(style);
                    } else {
                      _selectedStyles.remove(style);
                    }
                  });
                },
                selectedColor: AppColors.primary,
                backgroundColor: Colors.white,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimaryLight,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                checkmarkColor: Colors.white,
                side: BorderSide(color: isSelected ? AppColors.primary : AppColors.cardBorderLight),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // 5. Gear & Equipment Tags
          const Text(
            'Equipment & Gear Tags',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimaryLight),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppConstants.equipmentTags.map((gear) {
              final isSelected = _selectedEquipment.contains(gear);
              return FilterChip(
                label: Text(gear),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedEquipment.add(gear);
                    } else {
                      _selectedEquipment.remove(gear);
                    }
                  });
                },
                selectedColor: AppColors.primary,
                backgroundColor: Colors.white,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimaryLight,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                checkmarkColor: Colors.white,
                side: BorderSide(color: isSelected ? AppColors.primary : AppColors.cardBorderLight),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip(String label, String value) {
    final isSelected = _sortBy == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) setState(() => _sortBy = value);
      },
      selectedColor: AppColors.primary,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textPrimaryLight,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      side: BorderSide(color: isSelected ? AppColors.primary : AppColors.cardBorderLight),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
    );
  }

  Widget _buildRatingChip(String label, double rating) {
    final isSelected = _minRating == rating;
    return Expanded(
      child: ChoiceChip(
        label: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : AppColors.textPrimaryLight,
            ),
          ),
        ),
        selected: isSelected,
        showCheckmark: false,
        onSelected: (selected) {
          if (selected) setState(() => _minRating = rating);
        },
        selectedColor: AppColors.primary,
        backgroundColor: Colors.white,
        side: BorderSide(color: isSelected ? AppColors.primary : AppColors.cardBorderLight),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      ),
    );
  }
}
