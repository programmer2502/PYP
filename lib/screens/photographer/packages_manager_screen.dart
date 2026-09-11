import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../models/package_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/creator_provider.dart';
import '../../services/supabase_service.dart';

class PackagesManagerScreen extends ConsumerStatefulWidget {
  const PackagesManagerScreen({super.key});

  @override
  ConsumerState<PackagesManagerScreen> createState() => _PackagesManagerScreenState();
}

class _PackagesManagerScreenState extends ConsumerState<PackagesManagerScreen> {
  bool _isLoading = false;

  void _showPackageDialog({PackageModel? existingPackage}) {
    final titleCtrl = TextEditingController(text: existingPackage?.title ?? '');
    final descCtrl = TextEditingController(text: existingPackage?.description ?? '');
    final priceCtrl = TextEditingController(
        text: existingPackage != null ? existingPackage.price.toInt().toString() : '4999');
    final durationCtrl = TextEditingController(
        text: existingPackage != null ? (existingPackage.durationMinutes ~/ 60).toString() : '2');
    final deliverablesCtrl = TextEditingController(
        text: existingPackage != null ? existingPackage.deliverablesCount.toString() : '35');
    final turnaroundCtrl = TextEditingController(
        text: existingPackage != null ? existingPackage.turnaroundDays.toString() : '3');
    final numPhotosCtrl = TextEditingController(
        text: existingPackage != null ? existingPackage.numPhotographers.toString() : '1');
    final numVideosCtrl = TextEditingController(
        text: existingPackage != null ? existingPackage.numVideographers.toString() : '0');
    final numReelsCtrl = TextEditingController(
        text: existingPackage != null ? existingPackage.numReels.toString() : '0');
    final videoDurationCtrl = TextEditingController(
        text: existingPackage != null ? existingPackage.videoDurationMinutes.toString() : '0');

    String serviceType = existingPackage?.serviceType ?? 'Photography';
    final List<String> inclusions = List<String>.from(existingPackage?.inclusions ?? [
      'Color Graded High-Res Photos',
      'Online Private Delivery Gallery',
      'Outfit & Moodboard Styling',
    ]);
    final List<String> addOns = List<String>.from(existingPackage?.addOns ?? [
      'Additional Hour: ₹1,500',
      'Express 24-Hour Delivery: ₹2,000',
    ]);

    final inclusionCtrl = TextEditingController();
    final addOnCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.90,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.sell_rounded, color: AppColors.primary, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        existingPackage == null ? 'Create New Package' : 'Edit Package Tier',
                        style: const TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),

                // Form body
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Service Type Selector
                        const Text('Service Category',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: ['Photography', 'Videography', 'Both (Combo)', 'Reels & Drone']
                                .map((type) {
                              final isSel = serviceType == type;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(type),
                                  selected: isSel,
                                  selectedColor: AppColors.primary,
                                  labelStyle: TextStyle(
                                    color: isSel ? Colors.white : AppColors.textPrimaryLight,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                  onSelected: (val) {
                                    if (val) setModalState(() => serviceType = type);
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Package Name
                        _buildInputField(
                          label: 'Package Name',
                          controller: titleCtrl,
                          hint: 'e.g. Royal Wedding Premium / Studio Portrait Standard',
                          icon: Icons.bookmark_border_rounded,
                        ),
                        const SizedBox(height: 14),

                        // Price & Duration
                        Row(
                          children: [
                            Expanded(
                              child: _buildInputField(
                                label: 'Price (₹ INR)',
                                controller: priceCtrl,
                                hint: '4999',
                                icon: Icons.currency_rupee_rounded,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildInputField(
                                label: 'Duration (Hours)',
                                controller: durationCtrl,
                                hint: '2',
                                icon: Icons.schedule_rounded,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Crew count
                        Row(
                          children: [
                            Expanded(
                              child: _buildInputField(
                                label: 'Photographers',
                                controller: numPhotosCtrl,
                                hint: '1',
                                icon: Icons.camera_alt_outlined,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildInputField(
                                label: 'Videographers',
                                controller: numVideosCtrl,
                                hint: '0',
                                icon: Icons.videocam_outlined,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Deliverables Details
                        Row(
                          children: [
                            Expanded(
                              child: _buildInputField(
                                label: 'Edited Photos',
                                controller: deliverablesCtrl,
                                hint: '35',
                                icon: Icons.photo_library_outlined,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildInputField(
                                label: '4K Reels Count',
                                controller: numReelsCtrl,
                                hint: '2',
                                icon: Icons.video_collection_outlined,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        Row(
                          children: [
                            Expanded(
                              child: _buildInputField(
                                label: 'Video Length (Mins)',
                                controller: videoDurationCtrl,
                                hint: '3',
                                icon: Icons.movie_creation_outlined,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildInputField(
                                label: 'Delivery Time (Days)',
                                controller: turnaroundCtrl,
                                hint: '3',
                                icon: Icons.local_shipping_outlined,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Description
                        _buildInputField(
                          label: 'Package Description',
                          controller: descCtrl,
                          hint: 'Describe what makes this package special and who it is best suited for...',
                          icon: Icons.notes_rounded,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 20),

                        // Inclusions Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Inclusions & Features',
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                            Text('${inclusions.length} items',
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...inclusions.asMap().entries.map((entry) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 16),
                                const SizedBox(width: 8),
                                Expanded(child: Text(entry.value, style: const TextStyle(fontSize: 13))),
                                InkWell(
                                  onTap: () => setModalState(() => inclusions.removeAt(entry.key)),
                                  child: const Icon(Icons.close, size: 16, color: Colors.grey),
                                ),
                              ],
                            ),
                          );
                        }),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: inclusionCtrl,
                                decoration: InputDecoration(
                                  hintText: 'Add an inclusion...',
                                  hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                if (inclusionCtrl.text.trim().isNotEmpty) {
                                  setModalState(() {
                                    inclusions.add(inclusionCtrl.text.trim());
                                    inclusionCtrl.clear();
                                  });
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              ),
                              child: const Text('Add', style: TextStyle(color: Colors.white, fontSize: 12)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Add-ons Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Optional Add-Ons',
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                            Text('${addOns.length} add-ons',
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...addOns.asMap().entries.map((entry) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.add_circle_outline_rounded, color: Color(0xFFF59E0B), size: 16),
                                const SizedBox(width: 8),
                                Expanded(child: Text(entry.value, style: const TextStyle(fontSize: 13))),
                                InkWell(
                                  onTap: () => setModalState(() => addOns.removeAt(entry.key)),
                                  child: const Icon(Icons.close, size: 16, color: Colors.grey),
                                ),
                              ],
                            ),
                          );
                        }),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: addOnCtrl,
                                decoration: InputDecoration(
                                  hintText: 'e.g. Drone Teaser: ₹3,000',
                                  hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                if (addOnCtrl.text.trim().isNotEmpty) {
                                  setModalState(() {
                                    addOns.add(addOnCtrl.text.trim());
                                    addOnCtrl.clear();
                                  });
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF59E0B),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              ),
                              child: const Text('Add', style: TextStyle(color: Colors.white, fontSize: 12)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),

                // Save button bar
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (titleCtrl.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter a package name')),
                          );
                          return;
                        }

                        Navigator.pop(context);
                        setState(() => _isLoading = true);

                        try {
                          final user = ref.read(currentUserProvider);
                          final photographerId = user?.id ?? 'creator_current';
                          final pkgId = existingPackage?.id ??
                              'pkg_${DateTime.now().millisecondsSinceEpoch}';

                          final package = PackageModel(
                            id: pkgId,
                            photographerId: photographerId,
                            title: titleCtrl.text.trim(),
                            serviceType: serviceType,
                            description: descCtrl.text.trim(),
                            price: double.tryParse(priceCtrl.text.trim()) ?? 4999.0,
                            durationMinutes: (int.tryParse(durationCtrl.text.trim()) ?? 2) * 60,
                            deliverablesCount: int.tryParse(deliverablesCtrl.text.trim()) ?? 35,
                            turnaroundDays: int.tryParse(turnaroundCtrl.text.trim()) ?? 3,
                            numPhotographers: int.tryParse(numPhotosCtrl.text.trim()) ?? 1,
                            numVideographers: int.tryParse(numVideosCtrl.text.trim()) ?? 0,
                            numReels: int.tryParse(numReelsCtrl.text.trim()) ?? 0,
                            videoDurationMinutes: int.tryParse(videoDurationCtrl.text.trim()) ?? 0,
                            inclusions: inclusions,
                            addOns: addOns,
                            isActive: existingPackage?.isActive ?? true,
                            isPopular: existingPackage?.isPopular ?? false,
                          );

                          final db = ref.read(supabaseServiceProvider);
                          if (existingPackage == null) {
                            await db.createPackage(package);
                          } else {
                            await db.updatePackage(package);
                          }

                          ref.invalidate(creatorPackagesProvider);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(existingPackage == null
                                    ? 'Package created successfully!'
                                    : 'Package updated!'),
                                backgroundColor: AppColors.primary,
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error saving package: $e')),
                            );
                          }
                        } finally {
                          if (mounted) setState(() => _isLoading = false);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        existingPackage == null ? 'Publish Package Tier' : 'Save Changes',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontFamily: 'Outfit',
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
            prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final packagesAsync = ref.watch(creatorPackagesProvider);

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
          'Services & Packages',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: AppColors.textPrimaryLight,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary, size: 24),
            tooltip: 'Add Package',
            onPressed: () => _showPackageDialog(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : packagesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              error: (err, _) => Center(child: Text('Error loading packages: $err')),
              data: (packages) {
                if (packages.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.sell_outlined, size: 48, color: AppColors.primary),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No Packages Created Yet',
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Create your photography & video tiers so clients can book you instantly.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () => _showPackageDialog(),
                            icon: const Icon(Icons.add, color: Colors.white),
                            label: const Text('Create First Package',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async => ref.refresh(creatorPackagesProvider),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: packages.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final pkg = packages[index];
                      return _buildPackageCard(pkg);
                    },
                  ),
                );
              },
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
        ),
        child: ElevatedButton.icon(
          onPressed: () => _showPackageDialog(),
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: const Text(
            'Add New Package Tier',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }

  Widget _buildPackageCard(PackageModel pkg) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: pkg.isActive ? Colors.grey.shade200 : Colors.red.shade100,
          width: 1.2,
        ),
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
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: pkg.isActive
                  ? AppColors.primary.withValues(alpha: 0.06)
                  : Colors.grey.shade100,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    pkg.serviceType,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (pkg.isPopular)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'POPULAR',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                const Spacer(),
                Text(
                  pkg.isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: pkg.isActive ? const Color(0xFF00A86B) : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(width: 4),
                Switch.adaptive(
                  value: pkg.isActive,
                  activeThumbColor: const Color(0xFF00A86B),
                  onChanged: (val) async {
                    final db = ref.read(supabaseServiceProvider);
                    await db.togglePackageActive(pkg.id, val);
                    ref.invalidate(creatorPackagesProvider);
                  },
                ),
              ],
            ),
          ),

          // Content body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        pkg.title,
                        style: const TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                    ),
                    Text(
                      '₹${pkg.price.toInt()}',
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                if (pkg.description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    pkg.description,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.3),
                  ),
                ],
                const SizedBox(height: 14),

                // Specs Chips Grid
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildSpecBadge(Icons.schedule_rounded, '${pkg.durationMinutes ~/ 60}h Duration'),
                    _buildSpecBadge(Icons.photo_library_outlined, '${pkg.deliverablesCount} Photos'),
                    if (pkg.numReels > 0)
                      _buildSpecBadge(Icons.video_collection_outlined, '${pkg.numReels} 4K Reels'),
                    if (pkg.numPhotographers > 0)
                      _buildSpecBadge(Icons.camera_alt_outlined, '${pkg.numPhotographers} Photographer'),
                    if (pkg.numVideographers > 0)
                      _buildSpecBadge(Icons.videocam_outlined, '${pkg.numVideographers} Videographer'),
                    _buildSpecBadge(Icons.local_shipping_outlined, '${pkg.turnaroundDays}d Turnaround'),
                  ],
                ),
                const SizedBox(height: 14),

                // Inclusions preview
                if (pkg.inclusions.isNotEmpty) ...[
                  const Divider(),
                  const SizedBox(height: 6),
                  ...pkg.inclusions.take(3).map((inc) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF00A86B)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                inc,
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      )),
                ],

                const SizedBox(height: 12),

                // Actions: Edit / Delete
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _confirmDeletePackage(pkg),
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 16),
                      label: const Text('Delete', style: TextStyle(color: Colors.red, fontSize: 13)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _showPackageDialog(existingPackage: pkg),
                      icon: const Icon(Icons.edit_rounded, size: 16, color: Colors.white),
                      label: const Text('Edit Tier',
                          style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.grey.shade700),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey.shade800)),
        ],
      ),
    );
  }

  void _confirmDeletePackage(PackageModel pkg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Package Tier?'),
        content: Text('Are you sure you want to remove "${pkg.title}"? Existing bookings will not be affected.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isLoading = true);
              try {
                final db = ref.read(supabaseServiceProvider);
                await db.deletePackage(pkg.id);
                ref.invalidate(creatorPackagesProvider);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Package deleted'), backgroundColor: Colors.red),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting package: $e')),
                  );
                }
              } finally {
                if (mounted) setState(() => _isLoading = false);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
