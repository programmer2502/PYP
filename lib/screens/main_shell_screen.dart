import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_colors.dart';
import '../providers/chat_provider.dart';

class MainShellScreen extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainShellScreen({
    super.key,
    required this.navigationShell,
  });

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCountAsync = ref.watch(totalUnreadCountStreamProvider);
    final unreadCount = unreadCountAsync.value ?? 0;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(
            top: BorderSide(color: AppColors.cardBorderLight, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: _onTap,
          backgroundColor: Colors.white,
          indicatorColor: AppColors.primaryContainer,
          elevation: 0,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.explore_outlined, color: AppColors.textSecondaryLight),
              selectedIcon: Icon(Icons.explore_rounded, color: AppColors.primary),
              label: 'Explore',
            ),
            const NavigationDestination(
              icon: Icon(Icons.calendar_today_outlined, color: AppColors.textSecondaryLight),
              selectedIcon: Icon(Icons.calendar_today_rounded, color: AppColors.primary),
              label: 'Bookings',
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: unreadCount > 0,
                label: Text(
                  unreadCount > 99 ? '99+' : unreadCount.toString(),
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                ),
                backgroundColor: AppColors.accentRose,
                child: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.textSecondaryLight),
              ),
              selectedIcon: Badge(
                isLabelVisible: unreadCount > 0,
                label: Text(
                  unreadCount > 99 ? '99+' : unreadCount.toString(),
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                ),
                backgroundColor: AppColors.accentRose,
                child: const Icon(Icons.chat_bubble_rounded, color: AppColors.primary),
              ),
              label: 'Messages',
            ),
            const NavigationDestination(
              icon: Icon(Icons.person_outline_rounded, color: AppColors.textSecondaryLight),
              selectedIcon: Icon(Icons.person_rounded, color: AppColors.primary),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
