import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/loading_indicator.dart';
import '../../models/package_model.dart';
import '../../models/photographer_model.dart';
import '../../providers/booking_provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/photographer_provider.dart';

class BookSessionScreen extends ConsumerStatefulWidget {
  final PhotographerModel photographer;
  final PackageModel? initialPackage;
  final DateTime? initialDate;

  const BookSessionScreen({
    super.key,
    required this.photographer,
    this.initialPackage,
    this.initialDate,
  });

  @override
  ConsumerState<BookSessionScreen> createState() => _BookSessionScreenState();
}

class _BookSessionScreenState extends ConsumerState<BookSessionScreen> {
  final _formKey = GlobalKey<FormState>();
  late PackageModel? _selectedPackage;
  late DateTime _selectedDay;
  late DateTime _focusedDay;
  String? _selectedTimeSlot;
  String _selectedEventType = 'Photography';
  int _guestCount = 1; // Team size / Duration units
  bool _isCalendarExpanded = false;
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  final _clientNameController = TextEditingController();

  static const List<String> _timeSlots = [
    '08:00 AM - 10:00 AM',
    '10:00 AM - 12:00 PM',
    '12:00 PM - 02:00 PM',
    '02:00 PM - 04:00 PM',
    '04:00 PM - 06:00 PM',
    '06:00 PM - 08:00 PM',
  ];

  @override
  void initState() {
    super.initState();
    _selectedPackage = widget.initialPackage;
    final now = DateTime.now();
    _selectedDay = widget.initialDate ?? DateTime(now.year, now.month, now.day + 1);
    _focusedDay = _selectedDay;
    _selectedTimeSlot = _timeSlots[1]; // Default preselect 10 AM slot

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final loc = ref.read(locationProvider);
      if (loc.formattedAddress.isNotEmpty && loc.formattedAddress != 'Select Location') {
        _addressController.text = loc.formattedAddress;
      }
    });
  }

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    _clientNameController.dispose();
    super.dispose();
  }

  void _proceedToSummary() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a time slot for the shoot.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final double basePrice = _selectedPackage?.price ?? widget.photographer.startingPrice;
    final double platformFee = basePrice * AppConstants.platformFeeRate;
    final double taxAmount = (basePrice + platformFee) * AppConstants.taxRate;
    final double totalAmount = basePrice + platformFee + taxAmount;

    context.push(
      '/booking-summary',
      extra: {
        'photographer': widget.photographer,
        'package': _selectedPackage,
        'eventDate': _selectedDay,
        'timeSlot': _selectedTimeSlot!,
        'eventType': _selectedEventType,
        'locationAddress': _addressController.text.trim().isNotEmpty
            ? _addressController.text.trim()
            : widget.photographer.location,
        'customNotes': _notesController.text.trim(),
        'basePrice': basePrice,
        'platformFee': platformFee,
        'taxAmount': taxAmount,
        'totalAmount': totalAmount,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final packagesAsync = ref.watch(photographerPackagesProvider(widget.photographer.id));
    final bookedSlotsAsync = ref.watch(
      bookedSlotsProvider((photographerId: widget.photographer.id, date: _selectedDay)),
    );

    final double currentPrice = _selectedPackage?.price ?? widget.photographer.startingPrice;

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
          'Book a Session',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimaryLight,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Dark Header Photographer Card (Reference UI Style)
                _buildDarkHeaderCard(),
                const SizedBox(height: 16),

                // 2. Expandable Date & Day Strip Card
                _buildDateSelectorCard(),
                const SizedBox(height: 16),

                // 3. Time Slot Selector Card
                _buildTimeSlotCard(bookedSlotsAsync),
                const SizedBox(height: 16),

                // 4. Team Size / Stepper Card
                _buildStepperCard(),
                const SizedBox(height: 16),

                // 5. Package Selection Section
                _buildPackageSelection(packagesAsync),
                const SizedBox(height: 16),

                // 6. Special Requests Card
                _buildSpecialRequestsCard(),
                const SizedBox(height: 16),

                // 7. Venue & Client Details
                _buildVenueAndClientCard(),
                const SizedBox(height: 100), // padding for floating bottom bar
              ],
            ),
          ),
        ),
      ),
      bottomSheet: _buildBottomActionBar(currentPrice),
    );
  }

  Widget _buildDarkHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.darkHeader,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkHeader.withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.photographer.name,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.photographer.specialties.isNotEmpty
                ? widget.photographer.specialties.join(' • ')
                : 'Crafted Moments • Candid & Cinematic • Top Rated',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.darkHeaderSubtitle,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 14, color: AppColors.darkHeaderSubtitle),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  widget.photographer.location,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.darkHeaderSubtitle,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelectorCard() {
    final dateFormat = DateFormat('EEE d MMM');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          InkWell(
            onTap: () => setState(() => _isCalendarExpanded = !_isCalendarExpanded),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.badgeGreenBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Date',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                        Text(
                          dateFormat.format(_selectedDay),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimaryLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.cardBorderLight),
                  ),
                  child: Icon(
                    _isCalendarExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Collapsed Horizontal Day Strip OR Expanded Full Calendar
          if (!_isCalendarExpanded) _buildHorizontalDayStrip() else _buildFullCalendarView(),
        ],
      ),
    );
  }

  Widget _buildHorizontalDayStrip() {
    // Generate next 14 days
    final now = DateTime.now();
    final days = List.generate(14, (index) => now.add(Duration(days: index)));

    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final day = days[index];
          final isSelected = isSameDay(_selectedDay, day);
          final dayName = DateFormat('EEE').format(day);
          final dayNum = DateFormat('d').format(day);

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDay = day;
                _focusedDay = day;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 58,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.cardBorderLight,
                  width: 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white.withValues(alpha: 0.9) : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dayNum,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? Colors.white : AppColors.textPrimaryLight,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFullCalendarView() {
    return TableCalendar(
      firstDay: DateTime.now(),
      lastDay: DateTime.now().add(const Duration(days: 120)),
      focusedDay: _focusedDay,
      calendarFormat: CalendarFormat.month,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
          _isCalendarExpanded = false; // Collapse after selection
        });
      },
      calendarStyle: CalendarStyle(
        defaultTextStyle: const TextStyle(color: AppColors.textPrimaryLight, fontWeight: FontWeight.w600),
        weekendTextStyle: const TextStyle(color: AppColors.accentRose, fontWeight: FontWeight.w600),
        selectedDecoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          color: AppColors.primaryContainer,
          shape: BoxShape.circle,
        ),
        todayTextStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
      ),
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimaryLight,
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _buildTimeSlotCard(AsyncValue<List<String>> bookedSlotsAsync) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.badgeSkyBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.access_time_rounded, size: 18, color: AppColors.badgeSkyIcon),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Time',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                  Text(
                    _selectedTimeSlot ?? 'Choose Time Slot',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          bookedSlotsAsync.when(
            data: (bookedSlots) {
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _timeSlots.map((slot) {
                  final isBooked = bookedSlots.contains(slot);
                  final isSelected = _selectedTimeSlot == slot;

                  return InkWell(
                    onTap: isBooked ? null : () => setState(() => _selectedTimeSlot = slot),
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.chipSelectedBg
                            : isBooked
                                ? const Color(0xFFF1F5F9)
                                : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : isBooked
                                  ? const Color(0xFFE2E8F0)
                                  : AppColors.cardBorderLight,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Text(
                        slot,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isBooked
                              ? AppColors.textMutedLight
                              : isSelected
                                  ? AppColors.primaryDark
                                  : AppColors.textPrimaryLight,
                          decoration: isBooked ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const LoadingIndicator(size: 20),
            error: (_, __) => const Text('Error loading availability'),
          ),
        ],
      ),
    );
  }

  Widget _buildStepperCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.badgeCoralBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.people_outline_rounded, size: 18, color: AppColors.badgeCoralIcon),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Party size / Photographers',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                  Text(
                    '$_guestCount Pro Photographer${_guestCount > 1 ? 's' : ''}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Stepper Counter: [-] count [+]
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: AppColors.cardBorderLight),
            ),
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    if (_guestCount > 1) {
                      setState(() => _guestCount--);
                    }
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Icon(Icons.remove, size: 16, color: AppColors.textPrimaryLight),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    '$_guestCount',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    if (_guestCount < 5) {
                      setState(() => _guestCount++);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add, size: 14, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageSelection(AsyncValue<List<PackageModel>> packagesAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Service Package',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 10),
        packagesAsync.when(
          data: (packages) {
            if (packages.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorderLight),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Standard Photography Session',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimaryLight),
                    ),
                    Text(
                      CurrencyFormatter.format(widget.photographer.startingPrice),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.primary),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: packages.asMap().entries.map((entry) {
                final index = entry.key;
                final pkg = entry.value;
                final isSelected = _selectedPackage?.id == pkg.id;

                final bgColors = [
                  AppColors.badgeGreenBg,
                  AppColors.badgeCoralBg,
                  AppColors.badgePinkBg,
                  AppColors.badgeSkyBg,
                ];
                final iconColors = [
                  AppColors.badgeGreenIcon,
                  AppColors.badgeCoralIcon,
                  AppColors.badgePinkIcon,
                  AppColors.badgeSkyIcon,
                ];

                final badgeBg = bgColors[index % bgColors.length];
                final badgeIcon = iconColors[index % iconColors.length];

                return GestureDetector(
                  onTap: () => setState(() => _selectedPackage = pkg),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.chipSelectedBg : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.cardBorderLight,
                        width: isSelected ? 1.5 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: badgeBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.camera_alt_outlined, color: badgeIcon, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pkg.title,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected ? AppColors.primaryDark : AppColors.textPrimaryLight,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${pkg.durationMinutes} min • ${pkg.deliverablesCount} Deliverables',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          CurrencyFormatter.format(pkg.price),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
          loading: () => const LoadingIndicator(size: 24),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildSpecialRequestsCard() {
    return Container(
      width: double.infinity,
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
            'Special Requests',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondaryLight,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _notesController,
            maxLines: 2,
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimaryLight),
            decoration: const InputDecoration(
              hintText: 'Any specific shoot ideas, moodboard, outfits, or timing preferences...',
              hintStyle: TextStyle(fontSize: 13, color: AppColors.textMutedLight),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              filled: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVenueAndClientCard() {
    return Container(
      width: double.infinity,
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
            'Shoot Venue Address',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondaryLight,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _addressController,
            validator: Validators.required,
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimaryLight, fontWeight: FontWeight.w600),
            decoration: const InputDecoration(
              hintText: 'Enter venue address, studio, or outdoor spot',
              hintStyle: TextStyle(fontSize: 13, color: AppColors.textMutedLight, fontWeight: FontWeight.normal),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              filled: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(double currentPrice) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Est.',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondaryLight, fontWeight: FontWeight.w600),
                ),
                Text(
                  CurrencyFormatter.format(currentPrice),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimaryLight,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: CustomButton(
              text: 'Book a Session',
              onPressed: _proceedToSummary,
              backgroundColor: AppColors.primary,
              textColor: Colors.white,
              height: 52,
            ),
          ),
        ],
      ),
    );
  }
}
