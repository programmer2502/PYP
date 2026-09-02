import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/avatar_view.dart';
import '../../core/widgets/loading_indicator.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _handleSignOut(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimaryLight)),
        content: const Text('Are you sure you want to sign out of your account?', style: TextStyle(color: AppColors.textSecondaryLight)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondaryLight)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final authService = ref.read(authServiceProvider);
      await authService.signOut();
      if (context.mounted) {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        title: const Text(
          'Account & Profile',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimaryLight,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.textPrimaryLight),
            onPressed: () => context.push('/edit-profile'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: userState.when(
          data: (user) {
            if (user == null) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Not logged in'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => context.go('/login'),
                      child: const Text('Sign In'),
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ultra-Premium Glassmorphic Profile Hero Card
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F172A), Color(0xFF0B132B), Color(0xFF0D2137)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0B132B).withValues(alpha: 0.35),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Top Section: Avatar, Info & VIP Badge
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: const LinearGradient(
                                        colors: [AppColors.primary, Color(0xFF10B981)],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary.withValues(alpha: 0.4),
                                          blurRadius: 10,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: AvatarView(
                                      avatarUrl: user.avatarUrl,
                                      name: user.name,
                                      radius: 30,
                                    ),
                                  ),
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: const BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.check, color: Colors.white, size: 10),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            user.name,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white,
                                              letterSpacing: -0.2,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        const Icon(Icons.verified_rounded, color: AppColors.primary, size: 16),
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    Row(
                                      children: [
                                        const Icon(Icons.email_outlined, color: AppColors.darkHeaderSubtitle, size: 13),
                                        const SizedBox(width: 5),
                                        Expanded(
                                          child: Text(
                                            user.email,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.darkHeaderSubtitle,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            AppColors.primary.withValues(alpha: 0.25),
                                            const Color(0xFFF59E0B).withValues(alpha: 0.2),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(100),
                                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.auto_awesome_rounded, color: Color(0xFF4ADE80), size: 12),
                                          SizedBox(width: 5),
                                          Text(
                                            'PYP Elite VIP Member',
                                            style: TextStyle(
                                              color: Color(0xFF4ADE80),
                                              fontSize: 10,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 0.2,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Menu Items Section
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
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
                      children: [
                        _buildMenuTile(
                          icon: Icons.favorite_border_rounded,
                          title: 'Saved Photographers',
                          badgeBg: AppColors.badgePinkBg,
                          badgeIcon: AppColors.badgePinkIcon,
                          onTap: () => context.push('/saved-photographers'),
                        ),
                        const Divider(color: AppColors.cardBorderLight, height: 1, indent: 64),
                        _buildMenuTile(
                          icon: Icons.notifications_none_rounded,
                          title: 'Notification Settings',
                          badgeBg: AppColors.badgeSkyBg,
                          badgeIcon: AppColors.badgeSkyIcon,
                          onTap: () {},
                        ),
                        const Divider(color: AppColors.cardBorderLight, height: 1, indent: 64),
                        _buildMenuTile(
                          icon: Icons.help_outline_rounded,
                          title: 'Help & Support',
                          badgeBg: AppColors.badgeGreenBg,
                          badgeIcon: AppColors.badgeGreenIcon,
                          onTap: () => context.push('/help-support'),
                        ),
                        const Divider(color: AppColors.cardBorderLight, height: 1, indent: 64),
                        _buildMenuTile(
                          icon: Icons.privacy_tip_outlined,
                          title: 'Privacy Policy & Terms',
                          badgeBg: AppColors.badgeAmberBg,
                          badgeIcon: AppColors.badgeAmberIcon,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Sign Out Button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.cardBorderLight),
                    ),
                    child: ListTile(
                      onTap: () => _handleSignOut(context, ref),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
                      ),
                      title: const Text(
                        'Sign Out',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
          loading: () => const Center(child: LoadingIndicator(message: 'Loading profile...')),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required Color badgeBg,
    required Color badgeIcon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: badgeBg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: badgeIcon, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryLight,
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondaryLight, size: 20),
    );
  }
}

