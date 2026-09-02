import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/avatar_view.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/rating_bar_widget.dart';
import '../../models/booking_model.dart';
import '../../models/review_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/photographer_provider.dart';

class WriteReviewScreen extends ConsumerStatefulWidget {
  final BookingModel booking;

  const WriteReviewScreen({
    super.key,
    required this.booking,
  });

  @override
  ConsumerState<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends ConsumerState<WriteReviewScreen> {
  double _rating = 5.0;
  final _commentController = TextEditingController();
  final List<File> _selectedPhotos = [];
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _pickPhotos() async {
    final picked = await _picker.pickMultiImage(imageQuality: 80);
    if (picked.isNotEmpty) {
      setState(() {
        _selectedPhotos.addAll(picked.map((x) => File(x.path)));
      });
    }
  }

  Future<void> _submitReview() async {
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write a brief feedback comment.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final user = ref.read(userProfileProvider).value;
    if (user == null) return;

    setState(() => _isSubmitting = true);

    try {
      final storageService = ref.read(storageServiceProvider);
      final firestoreService = ref.read(firestoreServiceProvider);

      final List<String> photoUrls = [];
      for (final file in _selectedPhotos) {
        final url = await storageService.uploadReviewPhoto(
          photographerId: widget.booking.photographerId,
          file: file,
        );
        photoUrls.add(url);
      }

      final review = ReviewModel(
        id: '',
        bookingId: widget.booking.id,
        photographerId: widget.booking.photographerId,
        customerId: user.id,
        customerName: user.name,
        customerAvatar: user.avatarUrl,
        rating: _rating,
        comment: _commentController.text.trim(),
        photos: photoUrls,
        createdAt: DateTime.now(),
      );

      await firestoreService.submitReview(review: review);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thank you! Your review has been published.'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'Write a Review',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimaryLight,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Creator Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
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
                    AvatarView(
                      avatarUrl: widget.booking.photographerAvatar,
                      name: widget.booking.photographerName,
                      radius: 24,
                      showBorder: true,
                      borderColor: AppColors.primary,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.booking.photographerName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimaryLight,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.booking.packageTitle,
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Star Rating
              Center(
                child: Column(
                  children: [
                    const Text(
                      'Rate Your Experience',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimaryLight),
                    ),
                    const SizedBox(height: 12),
                    RatingBarWidget(
                      rating: _rating,
                      itemSize: 36,
                      isInteractive: true,
                      onRatingUpdate: (val) => setState(() => _rating = val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Feedback Text
              CustomTextField(
                controller: _commentController,
                label: 'Your Review Feedback',
                hintText: 'Share your experience with the shoot, professionalism, quality of photos...',
                maxLines: 4,
              ),
              const SizedBox(height: 20),

              // Photo Attachments
              const Text(
                'Add Sample Photos (Optional)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondaryLight),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ..._selectedPhotos.map((file) => Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(file, width: 72, height: 72, fit: BoxFit.cover),
                          ),
                          Positioned(
                            top: 2,
                            right: 2,
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedPhotos.remove(file)),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(color: Colors.black82, shape: BoxShape.circle),
                                child: const Icon(Icons.close, size: 14, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      )),
                  GestureDetector(
                    onTap: _pickPhotos,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.cardBorderLight, style: BorderStyle.solid),
                      ),
                      child: const Icon(Icons.add_photo_alternate_outlined, color: AppColors.primary, size: 28),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Submit Button
              CustomButton(
                text: 'Publish Review',
                isLoading: _isSubmitting,
                backgroundColor: AppColors.primary,
                textColor: Colors.white,
                onPressed: _submitReview,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
