import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/network_image_view.dart';
import '../../models/photographer_model.dart';

class PortfolioViewerScreen extends StatefulWidget {
  final List<String>? images;
  final List<String>? imageUrls;
  final int initialIndex;
  final PhotographerModel? photographer;

  const PortfolioViewerScreen({
    super.key,
    this.images,
    this.imageUrls,
    this.initialIndex = 0,
    this.photographer,
  });

  List<String> get effectiveImages => images ?? imageUrls ?? [];

  @override
  State<PortfolioViewerScreen> createState() => _PortfolioViewerScreenState();
}

class _PortfolioViewerScreenState extends State<PortfolioViewerScreen> {
  late PageController _pageController;
  late int _currentIndex;
  String _selectedMediaType = 'Photos';
  String _selectedStyle = 'All';

  final List<String> _mediaTypes = ['Photos', 'Videos', 'Reels'];
  final List<String> _styles = ['All', 'Editorial', 'Cinematic', 'Moody & Dark', 'Vibrant & Warm', 'Wedding'];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _proceedToBooking() {
    if (widget.photographer != null) {
      context.push(
        '/book/${widget.photographer!.id}',
        extra: {
          'photographer': widget.photographer,
        },
      );
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.effectiveImages;

    if (images.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(
          child: Text('No media available', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Column(
          children: [
            Text(
              widget.photographer?.name ?? 'Portfolio Gallery',
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
            ),
            Text(
              '${_currentIndex + 1} of ${images.length} works',
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Media Type Selector (Photos | Videos | Reels)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: _mediaTypes.map((type) {
                final isSelected = _selectedMediaType == type;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedMediaType = type),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        type,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Style Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: _styles.map((style) {
                final isSelected = _selectedStyle == style;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(style),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedStyle = style);
                    },
                    selectedColor: AppColors.primary,
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  ),
                );
              }).toList(),
            ),
          ),

          // Main Media Viewer
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: images.length,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              itemBuilder: (context, index) {
                final url = images[index];
                return InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 4.0,
                  child: Center(
                    child: NetworkImageView(
                      imageUrl: url,
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              },
            ),
          ),

          // Similar Work Thumbnails Strip
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SizedBox(
              height: 60,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: images.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final isCurrent = index == _currentIndex;
                  return GestureDetector(
                    onTap: () {
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Container(
                      width: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isCurrent ? AppColors.primary : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: NetworkImageView(
                          imageUrl: images[index],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Bottom Action: [ Book Creator ]
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: CustomButton(
                text: widget.photographer != null
                    ? 'Book ${widget.photographer!.name} (From ₹${widget.photographer!.startingPrice.toInt()})'
                    : 'Book This Creator',
                backgroundColor: AppColors.primary,
                textColor: Colors.white,
                onPressed: _proceedToBooking,
                height: 50,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
