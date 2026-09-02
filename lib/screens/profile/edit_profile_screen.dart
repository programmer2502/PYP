import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/avatar_view.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../providers/auth_provider.dart';
import '../../providers/photographer_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _bioController = TextEditingController();
  File? _newAvatarFile;
  final ImagePicker _picker = ImagePicker();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProfileProvider).value;
    if (user != null) {
      _nameController.text = user.name;
      _phoneController.text = user.phone;
      _locationController.text = user.location ?? '';
      _bioController.text = user.bio ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) {
      setState(() {
        _newAvatarFile = File(picked.path);
      });
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final currentUser = ref.read(userProfileProvider).value;
    if (currentUser == null) return;

    setState(() => _isSaving = true);

    try {
      String? avatarUrl = currentUser.avatarUrl;
      if (_newAvatarFile != null) {
        final storageService = ref.read(storageServiceProvider);
        avatarUrl = await storageService.uploadAvatar(
          userId: currentUser.id,
          file: _newAvatarFile!,
        );
      }

      final updatedUser = currentUser.copyWith(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        location: _locationController.text.trim(),
        bio: _bioController.text.trim(),
        avatarUrl: avatarUrl,
        updatedAt: DateTime.now(),
      );

      await ref.read(userProfileProvider.notifier).updateUser(updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: AppColors.success),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update failed: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProfileProvider).value;

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
          'Edit Profile',
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
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Avatar Picker with Camera Badge
                Center(
                  child: Stack(
                    children: [
                      if (_newAvatarFile != null)
                        ClipOval(
                          child: Image.file(
                            _newAvatarFile!,
                            width: 96,
                            height: 96,
                            fit: BoxFit.cover,
                          ),
                        )
                      else
                        AvatarView(
                          avatarUrl: user?.avatarUrl,
                          name: user?.name ?? 'User',
                          radius: 48,
                          showBorder: true,
                          borderColor: AppColors.primary,
                        ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickAvatar,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                CustomTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  hintText: 'John Doe',
                  validator: Validators.required,
                  prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.textSecondaryLight, size: 20),
                ),
                const SizedBox(height: 18),

                CustomTextField(
                  controller: _phoneController,
                  label: 'Mobile Number',
                  hintText: '+91 9876543210',
                  keyboardType: TextInputType.phone,
                  validator: Validators.phone,
                  prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.textSecondaryLight, size: 20),
                ),
                const SizedBox(height: 18),

                CustomTextField(
                  controller: _locationController,
                  label: 'City / Location',
                  hintText: 'e.g. Mumbai, India',
                  prefixIcon: const Icon(Icons.location_on_outlined, color: AppColors.textSecondaryLight, size: 20),
                ),
                const SizedBox(height: 18),

                CustomTextField(
                  controller: _bioController,
                  label: 'Bio / About You',
                  hintText: 'Write a brief description...',
                  maxLines: 3,
                ),
                const SizedBox(height: 32),

                CustomButton(
                  text: 'Save Changes',
                  isLoading: _isSaving,
                  backgroundColor: AppColors.primary,
                  textColor: Colors.white,
                  onPressed: _handleSave,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
