import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../models/portfolio_media_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/creator_provider.dart';
import '../../services/storage_service.dart';
import '../../services/supabase_service.dart';

class PortfolioManagerScreen extends ConsumerStatefulWidget {
  const PortfolioManagerScreen({super.key});

  @override
  ConsumerState<PortfolioManagerScreen> createState() => _PortfolioManagerScreenState();
}

class _PortfolioManagerScreenState extends ConsumerState<PortfolioManagerScreen> {
  String _selectedCategory = 'All';
  String _selectedMediaType = 'ALL';
  final ImagePicker _picker = ImagePicker();

  final List<String> _categories = [
    'All',
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

  void _showAddMediaModal() {
    final titleController = TextEditingController();
    final urlController = TextEditingController();
    final descController = TextEditingController();
    String mediaType = 'PHOTO';
    String uploadSource = 'DEVICE'; // 'DEVICE' or 'URL'
    String category = 'Portrait';
    String styleTag = 'Cinematic';
    bool isFeatured = false;
    XFile? selectedFile;
    Uint8List? selectedBytes;
    bool isUploading = false;
    String? uploadError;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Add Portfolio Media',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, fontFamily: 'Outfit'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Media Type Selector (Photo / Video / Reel)
                Row(
                  children: [
                    _buildModalTypeChip('Photo', 'PHOTO', Icons.photo_rounded, mediaType, (val) {
                      setModalState(() {
                        mediaType = val;
                        selectedFile = null;
                        selectedBytes = null;
                      });
                    }),
                    const SizedBox(width: 8),
                    _buildModalTypeChip('Video', 'VIDEO', Icons.videocam_rounded, mediaType, (val) {
                      setModalState(() {
                        mediaType = val;
                        selectedFile = null;
                        selectedBytes = null;
                      });
                    }),
                    const SizedBox(width: 8),
                    _buildModalTypeChip('Reel (9:16)', 'REEL', Icons.play_circle_rounded, mediaType, (val) {
                      setModalState(() {
                        mediaType = val;
                        selectedFile = null;
                        selectedBytes = null;
                      });
                    }),
                  ],
                ),
                const SizedBox(height: 14),

                // Upload Method Toggle: Device Upload vs URL
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setModalState(() => uploadSource = 'DEVICE'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: uploadSource == 'DEVICE' ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: uploadSource == 'DEVICE'
                                  ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))]
                                  : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.file_upload_outlined, size: 16, color: uploadSource == 'DEVICE' ? AppColors.primary : AppColors.textSecondaryLight),
                                const SizedBox(width: 6),
                                Text(
                                  'Upload from Device',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: uploadSource == 'DEVICE' ? AppColors.primary : AppColors.textSecondaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setModalState(() => uploadSource = 'URL'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: uploadSource == 'URL' ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: uploadSource == 'URL'
                                  ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))]
                                  : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.link_rounded, size: 16, color: uploadSource == 'URL' ? AppColors.primary : AppColors.textSecondaryLight),
                                const SizedBox(width: 6),
                                Text(
                                  'Paste Direct URL',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: uploadSource == 'URL' ? AppColors.primary : AppColors.textSecondaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Source Content: Device Picker vs URL Field
                if (uploadSource == 'DEVICE') ...[
                  if (selectedFile != null) ...[
                    // File Preview Card
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: selectedBytes != null && mediaType == 'PHOTO'
                                ? Image.memory(
                                    selectedBytes!,
                                    width: 56,
                                    height: 56,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    width: 56,
                                    height: 56,
                                    color: AppColors.primary.withValues(alpha: 0.1),
                                    child: Icon(
                                      mediaType == 'PHOTO' ? Icons.image_rounded : Icons.videocam_rounded,
                                      color: AppColors.primary,
                                      size: 28,
                                    ),
                                  ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  selectedFile!.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        mediaType,
                                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primary),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text('Ready to upload', style: TextStyle(fontSize: 12, color: Color(0xFF10B981), fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                            tooltip: 'Remove',
                            onPressed: () {
                              setModalState(() {
                                selectedFile = null;
                                selectedBytes = null;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Empty Upload Zone
                    GestureDetector(
                      onTap: () async {
                        try {
                          XFile? file;
                          if (mediaType == 'PHOTO') {
                            file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 90);
                          } else {
                            file = await _picker.pickVideo(source: ImageSource.gallery);
                          }
                          if (file != null) {
                            final bytes = await file.readAsBytes();
                            setModalState(() {
                              selectedFile = file;
                              selectedBytes = bytes;
                              uploadError = null;
                              if (titleController.text.isEmpty) {
                                final rawName = file!.name.split('.').first;
                                titleController.text = rawName.replaceAll('_', ' ').replaceAll('-', ' ');
                              }
                            });
                          }
                        } catch (e) {
                          setModalState(() => uploadError = 'Error selecting file: $e');
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFCBD5E1), style: BorderStyle.solid),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.cloud_upload_rounded, size: 28, color: AppColors.primary),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Tap to choose ${mediaType.toLowerCase()} from device',
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimaryLight),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              mediaType == 'PHOTO' ? 'Supports JPG, PNG, WEBP (High Resolution)' : 'Supports MP4, MOV, 4K clips (up to 100MB)',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ] else ...[
                  TextField(
                    controller: urlController,
                    decoration: InputDecoration(
                      labelText: 'Media URL (Image / 4K Stream / Reel Link)',
                      hintText: 'https://... or cloud video link',
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.cardBorderLight)),
                    ),
                  ),
                ],
                if (uploadError != null) ...[
                  const SizedBox(height: 8),
                  Text(uploadError!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                ],
                const SizedBox(height: 12),

                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Title / Subject',
                    hintText: 'e.g. Royal Udaipur Palace Wedding',
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.cardBorderLight)),
                  ),
                ),
                const SizedBox(height: 12),

                // Category Dropdown
                DropdownButtonFormField<String>(
                  initialValue: category,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.cardBorderLight)),
                  ),
                  items: _categories.where((c) => c != 'All').map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (val) => setModalState(() => category = val ?? 'Portrait'),
                ),
                const SizedBox(height: 12),

                // Style Tag
                DropdownButtonFormField<String>(
                  initialValue: styleTag,
                  decoration: InputDecoration(
                    labelText: 'Style Tag',
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.cardBorderLight)),
                  ),
                  items: ['Cinematic', 'Candid', 'Editorial', 'Natural', 'Luxury', 'Moody & Dark', 'Vintage'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (val) => setModalState(() => styleTag = val ?? 'Cinematic'),
                ),
                const SizedBox(height: 12),

                // Featured Switch
                SwitchListTile(
                  title: const Text('Feature on Creator Profile Cover', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  value: isFeatured,
                  activeThumbColor: AppColors.primary,
                  onChanged: (v) => setModalState(() => isFeatured = v),
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: isUploading
                        ? null
                        : () async {
                            final user = ref.read(currentUserProvider);
                            if (user == null) {
                              setModalState(() => uploadError = 'User profile not found. Please log in.');
                              return;
                            }

                            String finalMediaUrl = '';

                            if (uploadSource == 'DEVICE') {
                              if (selectedFile == null) {
                                setModalState(() => uploadError = 'Please select a photo or video to upload.');
                                return;
                              }

                              setModalState(() {
                                isUploading = true;
                                uploadError = null;
                              });

                              try {
                                finalMediaUrl = await ref.read(storageServiceProvider).uploadPortfolioMedia(
                                      photographerId: user.id,
                                      filePath: selectedFile!.path,
                                      fileBytes: selectedBytes,
                                      originalFileName: selectedFile!.name,
                                      mimeType: mediaType == 'PHOTO' ? 'image/jpeg' : 'video/mp4',
                                    );
                              } catch (e) {
                                setModalState(() {
                                  isUploading = false;
                                  uploadError = 'Storage upload failed: $e';
                                });
                                return;
                              }
                            } else {
                              if (urlController.text.trim().isEmpty) {
                                setModalState(() => uploadError = 'Please enter a valid media URL.');
                                return;
                              }
                              finalMediaUrl = urlController.text.trim();
                            }

                            final newMedia = PortfolioMediaModel(
                              id: 'media_${DateTime.now().millisecondsSinceEpoch}',
                              photographerId: user.id,
                              title: titleController.text.trim().isNotEmpty ? titleController.text.trim() : 'Portfolio Work',
                              description: descController.text.trim(),
                              mediaUrl: finalMediaUrl,
                              mediaType: mediaType,
                              category: category,
                              styleTag: styleTag,
                              isFeatured: isFeatured,
                              createdAt: DateTime.now(),
                            );

                            await ref.read(supabaseServiceProvider).savePortfolioMedia(newMedia);
                            ref.invalidate(creatorPortfolioMediaProvider);
                            if (context.mounted) {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Portfolio media added successfully!'),
                                  backgroundColor: Color(0xFF10B981),
                                ),
                              );
                            }
                          },
                    child: isUploading
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              ),
                              SizedBox(width: 12),
                              Text('Uploading to Cloud...', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                            ],
                          )
                        : const Text('Add to Portfolio', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModalTypeChip(String label, String value, IconData icon, String selectedValue, Function(String) onSelect) {
    final isSelected = selectedValue == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => onSelect(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: isSelected ? Colors.white : AppColors.textSecondaryLight),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: isSelected ? Colors.white : AppColors.textPrimaryLight),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaAsync = ref.watch(creatorPortfolioMediaProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Portfolio Manager', style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700, color: AppColors.textPrimaryLight)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textPrimaryLight),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_photo_alternate_rounded, color: AppColors.primary),
            tooltip: 'Add Media',
            onPressed: _showAddMediaModal,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs (Media Type: All, Photos, Videos, Reels)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildTypeFilterChip('All Media', 'ALL'),
                const SizedBox(width: 8),
                _buildTypeFilterChip('Photos', 'PHOTO'),
                const SizedBox(width: 8),
                _buildTypeFilterChip('Videos', 'VIDEO'),
                const SizedBox(width: 8),
                _buildTypeFilterChip('Reels', 'REEL'),
              ],
            ),
          ),

          // Categories Scrollable Bar
          Container(
            height: 46,
            color: Colors.white,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategory == cat;
                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  selectedColor: AppColors.primary.withValues(alpha: 0.15),
                  backgroundColor: const Color(0xFFF1F5F9),
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.primary : AppColors.textSecondaryLight,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 12,
                  ),
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedCategory = cat);
                  },
                );
              },
            ),
          ),
          const Divider(height: 1, color: AppColors.cardBorderLight),

          // Media Grid
          Expanded(
            child: mediaAsync.when(
              data: (mediaList) {
                final filtered = mediaList.where((m) {
                  final matchType = _selectedMediaType == 'ALL' || m.mediaType == _selectedMediaType;
                  final matchCat = _selectedCategory == 'All' || m.category == _selectedCategory;
                  return matchType && matchCat;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.photo_library_outlined, size: 56, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text('No media found in "$_selectedCategory"', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textSecondaryLight)),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Add Media Now'),
                          onPressed: _showAddMediaModal,
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.82,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    return _buildPortfolioCard(item);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error loading portfolio: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeFilterChip(String label, String value) {
    final isSelected = _selectedMediaType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedMediaType = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : AppColors.textSecondaryLight,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPortfolioCard(PortfolioMediaModel item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorderLight),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: item.thumbnailUrl ?? item.mediaUrl,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(color: const Color(0xFFF1F5F9)),
            errorWidget: (_, __, ___) => const Center(child: Icon(Icons.broken_image_rounded, color: Colors.grey)),
          ),
          // Dark Gradient Overlay at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 70,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black87],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          // Top Badges (Media Type & Featured)
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    item.isReel ? Icons.play_circle_rounded : (item.isVideo ? Icons.videocam_rounded : Icons.photo_rounded),
                    color: Colors.white,
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    item.mediaType,
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
          if (item.isFeatured)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Color(0xFFF59E0B), shape: BoxShape.circle),
                child: const Icon(Icons.star_rounded, color: Colors.white, size: 14),
              ),
            ),
          // Title & Category tag
          Positioned(
            bottom: 8,
            left: 10,
            right: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.title.isNotEmpty ? item.title : item.category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      '#${item.styleTag}',
                      style: const TextStyle(color: Color(0xFF4ADE80), fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () async {
                        await ref.read(supabaseServiceProvider).deletePortfolioMedia(item.id);
                        ref.invalidate(creatorPortfolioMediaProvider);
                      },
                      child: const Icon(Icons.delete_outline_rounded, color: Colors.white70, size: 16),
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
}
