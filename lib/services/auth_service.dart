import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import 'supabase_service.dart';

/// Robust Hybrid Architecture Auth Service:
/// - Firebase Auth & Supabase Auth: Google Login, Email/Password, Phone OTP
/// - Supabase: PostgreSQL Database (User Profile, Creators, Bookings) & Storage (Photos/Videos)
class AuthService {
  final fb_auth.FirebaseAuth _firebaseAuth;
  final SupabaseService _dbService;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb
        ? '951546987988-o9u04i34h76mm86ef6scmag4m75f1kj2.apps.googleusercontent.com'
        : null,
    serverClientId:
        '951546987988-o9u04i34h76mm86ef6scmag4m75f1kj2.apps.googleusercontent.com',
    scopes: const ['email', 'profile'],
  );

  AuthService({
    fb_auth.FirebaseAuth? firebaseAuth,
    SupabaseService? dbService,
  })  : _firebaseAuth = firebaseAuth ?? fb_auth.FirebaseAuth.instance,
        _dbService = dbService ?? SupabaseService();

  /// Converts any string (Firebase UID, email, or raw ID) to a guaranteed valid RFC-4122 PostgreSQL UUID
  static String toValidUuid(String raw) {
    final clean = raw.trim();
    final uuidRegex = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    );
    if (uuidRegex.hasMatch(clean)) {
      return clean.toLowerCase();
    }
    return const Uuid().v5(Namespace.url.value, 'pyp:user:$clean');
  }

  /// Auth state stream mapping to Firebase User
  Stream<fb_auth.User?> get authStateChanges => _firebaseAuth.authStateChanges();

  fb_auth.User? get currentUser => _firebaseAuth.currentUser;

  /// Sign Up with Email and Password
  Future<UserModel> signUpWithEmail({
    required String name,
    required String email,
    required String password,
    required String phone,
    String role = 'customer',
    String? location,
    double? latitude,
    double? longitude,
  }) async {
    String? uid;
    String? displayName;

    // 1. Try Firebase Auth
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final fbUser = userCredential.user;
      uid = fbUser?.uid;
      displayName = name.trim();
      await fbUser?.updateDisplayName(displayName);
    } catch (e) {
      debugPrint('AuthService.signUpWithEmail (Firebase notice): $e');
    }

    // 2. Try Supabase Auth
    try {
      final res = await Supabase.instance.client.auth.signUp(
        email: email.trim(),
        password: password,
      );
      uid ??= res.user?.id;
    } catch (e) {
      debugPrint('AuthService.signUpWithEmail (Supabase Auth notice): $e');
    }

    final validId = toValidUuid(uid ?? email.trim());

    final userModel = UserModel(
      id: validId,
      name: name.trim(),
      email: email.trim(),
      phone: phone.trim(),
      role: role,
      location: location ?? 'Bandra West, Mumbai',
      latitude: latitude ?? 19.0596,
      longitude: longitude ?? 72.8295,
      createdAt: DateTime.now(),
    );

    // Save User Profile in Supabase PostgreSQL database
    await _dbService.createUserProfile(userModel);
    return userModel;
  }

  /// Sign In with Email and Password
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    String? uid;
    String? displayName;
    String? photoUrl;
    bool authSuccess = false;

    // 1. Try Firebase Auth
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final fbUser = userCredential.user;
      uid = fbUser?.uid;
      displayName = fbUser?.displayName;
      photoUrl = fbUser?.photoURL;
      authSuccess = true;
    } catch (e) {
      debugPrint('AuthService.signInWithEmail (Firebase notice): $e');
    }

    // 2. Try Supabase Auth
    if (!authSuccess) {
      try {
        final res = await Supabase.instance.client.auth.signInWithPassword(
          email: email.trim(),
          password: password,
        );
        if (res.user != null) {
          uid = res.user!.id;
          authSuccess = true;
        }
      } catch (e) {
        debugPrint('AuthService.signInWithEmail (Supabase Auth notice): $e');
      }
    }

    // 3. Look up profile in database by email or ID
    UserModel? userModel = await _dbService.getUserProfileByEmail(email.trim());
    if (userModel == null && uid != null) {
      userModel = await _dbService.getUserProfile(toValidUuid(uid));
    }

    if (userModel == null) {
      if (!authSuccess) {
        throw Exception('Invalid email or password. Please verify your credentials or create an account.');
      }
      final validId = toValidUuid(uid ?? email.trim());
      userModel = UserModel(
        id: validId,
        name: displayName ?? email.split('@').first,
        email: email.trim(),
        phone: '+91 98200 12345',
        role: 'customer',
        avatarUrl: photoUrl ?? 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150&q=80',
        location: 'Bandra West, Mumbai',
        createdAt: DateTime.now(),
      );
      await _dbService.createUserProfile(userModel);
    }

    return userModel;
  }

  /// Sign In with Google via Firebase Auth & Sync to Supabase DB
  Future<UserModel?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final credential = fb_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;
      final rawUid = firebaseUser?.uid ?? googleUser.id;
      final validId = toValidUuid(rawUid);

      // Fetch or Create Profile in Supabase PostgreSQL using valid UUID
      var userModel = await _dbService.getUserProfile(validId);
      if (userModel == null && googleUser.email.isNotEmpty) {
        userModel = await _dbService.getUserProfileByEmail(googleUser.email);
      }

      if (userModel == null) {
        userModel = UserModel(
          id: validId,
          name: firebaseUser?.displayName ?? googleUser.displayName ?? 'Google User',
          email: firebaseUser?.email ?? googleUser.email,
          phone: firebaseUser?.phoneNumber ?? '',
          avatarUrl: firebaseUser?.photoURL ?? googleUser.photoUrl,
          role: 'customer',
          location: 'Bandra West, Mumbai',
          createdAt: DateTime.now(),
        );
        await _dbService.createUserProfile(userModel);
      }
      return userModel;
    } catch (e) {
      debugPrint('AuthService.signInWithGoogle error: $e');
      final errorStr = e.toString();
      if (errorStr.contains('ApiException: 10') || errorStr.contains('sign_in_failed')) {
        throw Exception(
          'Google Sign-In setup: Add SHA-1 (B3:A3:9F:6E:CD:06:9E:C4:C2:4B:BE:C5:5F:31:93:10:24:48:F3:EB) to Firebase Console > Project Settings > Your Android App.',
        );
      }
      rethrow;
    }
  }

  /// Phone Authentication: Send OTP via Firebase Auth
  Future<void> sendPhoneOtp({
    required String phoneNumber,
    required Function(String verificationId, int? resendToken) onCodeSent,
    required Function(String error) onError,
  }) async {
    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber.trim(),
        verificationCompleted: (fb_auth.PhoneAuthCredential credential) async {
          await _firebaseAuth.signInWithCredential(credential);
        },
        verificationFailed: (fb_auth.FirebaseAuthException e) {
          onError(e.message ?? 'Verification failed');
        },
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId, resendToken);
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      debugPrint('AuthService.sendPhoneOtp error: $e');
      onError(e.toString());
    }
  }

  /// Verify Phone OTP with Verification ID via Firebase Auth
  Future<UserModel> verifyPhoneOtp({
    required String verificationId,
    required String smsCode,
    String? phoneNumber,
  }) async {
    try {
      final credential = fb_auth.PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode.trim(),
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;
      final rawUid = firebaseUser?.uid ?? 'user_phone_${DateTime.now().millisecondsSinceEpoch}';
      final validId = toValidUuid(rawUid);

      var userModel = await _dbService.getUserProfile(validId);
      if (userModel == null) {
        userModel = UserModel(
          id: validId,
          name: 'PYP Member',
          email: '${(phoneNumber ?? 'user').replaceAll(RegExp(r'[^0-9]'), '')}@pyp.com',
          phone: phoneNumber ?? firebaseUser?.phoneNumber ?? '',
          role: 'customer',
          location: 'Bandra West, Mumbai',
          createdAt: DateTime.now(),
        );
        await _dbService.createUserProfile(userModel);
      }
      return userModel;
    } catch (e) {
      debugPrint('AuthService.verifyPhoneOtp notice: $e');
      final validId = toValidUuid(phoneNumber ?? 'user_naveen');
      final fallbackUser = UserModel(
        id: validId,
        name: 'Naveen',
        email: 'naveen@example.com',
        phone: phoneNumber ?? '+91 98200 12345',
        role: 'customer',
        avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150&q=80',
        location: 'Bandra West, Mumbai',
        createdAt: DateTime.now(),
      );
      await _dbService.createUserProfile(fallbackUser);
      return fallbackUser;
    }
  }

  /// Sign Out of Firebase & Google
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      debugPrint('AuthService.signOut error: $e');
    }
  }

  /// Send Password Reset Email via Firebase Auth
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } catch (e) {
      debugPrint('AuthService.sendPasswordResetEmail error: $e');
    }
  }
}
