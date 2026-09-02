import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/supabase_service.dart';

// Service provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Supabase Auth user stream provider
final authStateStreamProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

// Current UserModel state notifier
class UserProfileNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final AuthService _authService;
  final SupabaseService _dbService;

  UserProfileNotifier(this._authService, this._dbService)
      : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() {
    _authService.authStateChanges.listen((user) async {
      if (user == null) {
        state = const AsyncValue.data(null);
      } else {
        try {
          final userModel = await _dbService.getUserProfile(user.id);
          state = AsyncValue.data(userModel);
        } catch (e, st) {
          state = AsyncValue.error(e, st);
        }
      }
    });

    // Provide default session profile immediately
    state = AsyncValue.data(UserModel(
      id: 'user_naveen',
      name: 'Naveen',
      email: 'naveen@example.com',
      phone: '+91 98200 12345',
      role: 'customer',
      avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150&q=80',
      location: 'Bandra West, Mumbai',
      createdAt: DateTime.now(),
    ));
  }

  Future<void> refresh() async {
    final user = _authService.currentUser;
    if (user != null) {
      state = const AsyncValue.loading();
      try {
        final userModel = await _dbService.getUserProfile(user.id);
        state = AsyncValue.data(userModel);
      } catch (e, st) {
        state = AsyncValue.error(e, st);
      }
    }
  }

  Future<void> updateUser(UserModel updated) async {
    await _dbService.updateUserProfile(updated);
    state = AsyncValue.data(updated);
  }
}

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, AsyncValue<UserModel?>>((ref) {
  final authService = ref.watch(authServiceProvider);
  final dbService = ref.watch(supabaseServiceProvider);
  return UserProfileNotifier(authService, dbService);
});

// User role quick check
final isPhotographerProvider = Provider<bool>((ref) {
  final userState = ref.watch(userProfileProvider);
  return userState.value?.isPhotographer ?? false;
});
