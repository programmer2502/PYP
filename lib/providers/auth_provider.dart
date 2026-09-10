import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/supabase_service.dart';

// Service provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Firebase Auth user stream provider
final authStateStreamProvider = StreamProvider<fb_auth.User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

// Current Unified UserModel provider
final currentUserProvider = Provider<UserModel?>((ref) {
  final userProfileState = ref.watch(userProfileProvider);
  return userProfileState.value;
});

// Current UserModel state notifier
class UserProfileNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final AuthService _authService;
  final SupabaseService _dbService;

  UserProfileNotifier(this._authService, this._dbService)
      : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    // 1. Check if Firebase has an existing authenticated session
    final fbUser = _authService.currentUser;
    if (fbUser != null) {
      try {
        final validId = AuthService.toValidUuid(fbUser.uid);
        var userModel = await _dbService.getUserProfile(validId);
        if (userModel == null && fbUser.email != null) {
          userModel = await _dbService.getUserProfileByEmail(fbUser.email!);
        }
        if (userModel != null) {
          state = AsyncValue.data(userModel);
          return;
        }
      } catch (e) {
        debugPrint('UserProfileNotifier fb init error: $e');
      }
    }

    // 2. Check if Supabase Auth has an existing session
    try {
      final supaUser = Supabase.instance.client.auth.currentUser;
      if (supaUser != null) {
        final validId = AuthService.toValidUuid(supaUser.id);
        var userModel = await _dbService.getUserProfile(validId);
        if (userModel == null && supaUser.email != null) {
          userModel = await _dbService.getUserProfileByEmail(supaUser.email!);
        }
        if (userModel != null) {
          state = AsyncValue.data(userModel);
          return;
        }
      }
    } catch (_) {}

    // 3. Listen to Firebase auth changes (sign-in, Google sign-in, token refresh)
    _authService.authStateChanges.listen((user) async {
      if (user != null) {
        try {
          final validId = AuthService.toValidUuid(user.uid);
          var userModel = await _dbService.getUserProfile(validId);
          if (userModel == null && user.email != null) {
            userModel = await _dbService.getUserProfileByEmail(user.email!);
          }
          if (userModel != null) {
            state = AsyncValue.data(userModel);
          }
        } catch (e, st) {
          state = AsyncValue.error(e, st);
        }
      }
    });

    // 4. Default user profile if nothing is cached
    state = AsyncValue.data(UserModel(
      id: AuthService.toValidUuid('user_naveen'),
      name: 'Naveen',
      email: 'naveen@example.com',
      phone: '+91 98200 12345',
      role: 'customer',
      avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150&q=80',
      location: 'Bandra West, Mumbai',
      createdAt: DateTime.now(),
    ));
  }

  void setUser(UserModel? user) {
    state = AsyncValue.data(user);
  }

  void clearUser() {
    state = const AsyncValue.data(null);
  }

  Future<void> refresh() async {
    final current = state.value;
    if (current != null) {
      state = const AsyncValue.loading();
      try {
        var userModel = await _dbService.getUserProfile(current.id);
        if (userModel == null && current.email.isNotEmpty) {
          userModel = await _dbService.getUserProfileByEmail(current.email);
        }
        state = AsyncValue.data(userModel ?? current);
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
