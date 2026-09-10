import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../models/photographer_model.dart';
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

  /// Helper to ensure a creator record exists in photographers table
  Future<void> _ensurePhotographerProfile(UserModel user) async {
    try {
      final validId = toValidUuid(user.id);
      final exists = await _dbService.isPhotographerUser(validId);
      if (!exists) {
        await _dbService.createPhotographerProfile(PhotographerModel(
          id: validId,
          userId: validId,
          name: user.name.isNotEmpty ? user.name : 'Creator Studio',
          email: user.email,
          phone: user.phone.isNotEmpty ? user.phone : '+91 98200 12345',
          avatarUrl: user.avatarUrl ??
              'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500&q=80',
          coverImageUrl:
              'https://images.unsplash.com/photo-1492691527719-9d1e07e534b4?w=1200&q=80',
          tagline: 'Visual Storyteller & Cinematographer',
          bio: 'Passionate about crafting cinematic frames and unforgettable visual memories.',
          location: user.location ?? 'Bandra West, Mumbai',
          latitude: user.latitude ?? 19.0596,
          longitude: user.longitude ?? 72.8295,
          startingPrice: 4999.0,
          hourlyRate: 1999.0,
          categories: const ['Portrait', 'Editorial', 'Fashion'],
          styles: const ['Cinematic', 'Editorial'],
          equipment: const ['Sony A7 IV', '85mm f/1.4 GM'],
          portfolioImages: const [
            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800&q=80',
            'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=800&q=80',
            'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=800&q=80',
          ],
          createdAt: DateTime.now(),
        ));
      }
    } catch (e) {
      debugPrint('AuthService._ensurePhotographerProfile notice: $e');
    }
  }

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

  /// Sign Up with Email and Password using Supabase Auth
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
    final cleanEmail = email.trim();
    final cleanName = name.trim();
    final cleanPhone = phone.trim();
    final targetRole = (role == 'photographer' || role == 'creator') ? 'creator' : 'customer';

    // 1. Supabase Auth signup (Generates real auth.users UUID)
    AuthResponse res;
    try {
      res = await Supabase.instance.client.auth.signUp(
        email: cleanEmail,
        password: password,
        data: {
          'name': cleanName,
          'phone': cleanPhone,
          'role': targetRole,
        },
      );
    } on AuthException catch (e) {
      debugPrint('AuthService.signUpWithEmail Supabase error: ${e.message}');
      if (e.message.toLowerCase().contains('already registered') || e.message.toLowerCase().contains('user already exists')) {
        throw Exception('An account with this email already exists. Please sign in.');
      }
      throw Exception(e.message);
    } catch (e) {
      debugPrint('AuthService.signUpWithEmail error: $e');
      throw Exception('Sign up failed: ${e.toString().replaceAll("Exception: ", "")}');
    }

    if (res.user == null) {
      throw Exception('Signup failed: No user returned from authentication server.');
    }

    final String userId = res.user!.id; // Guaranteed real Supabase Auth UUID

    // Also sync to Firebase Auth if active
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );
      await userCredential.user?.updateDisplayName(cleanName);
    } catch (e) {
      debugPrint('Firebase signup sync notice: $e');
    }

    final userModel = UserModel(
      id: userId,
      name: cleanName,
      email: cleanEmail,
      phone: cleanPhone,
      role: targetRole,
      location: location ?? 'Bandra West, Mumbai',
      latitude: latitude ?? 19.0596,
      longitude: longitude ?? 72.8295,
      createdAt: DateTime.now(),
    );

    // Save User Profile in Supabase PostgreSQL database using the real Auth UUID
    await _dbService.createUserProfile(userModel);
    if (userModel.isPhotographer) {
      await _ensurePhotographerProfile(userModel);
    }
    return userModel;
  }

  /// Sign In with Email and Password using Supabase Auth
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
    String? requestedRole,
  }) async {
    final cleanEmail = email.trim();
    String? userId;
    String? displayName;
    String? photoUrl;

    // 1. Authenticate with Supabase Auth
    try {
      final res = await Supabase.instance.client.auth.signInWithPassword(
        email: cleanEmail,
        password: password,
      );
      if (res.user != null) {
        userId = res.user!.id;
        displayName = res.user!.userMetadata?['name'];
      }
    } on AuthException catch (e) {
      debugPrint('AuthService.signInWithEmail Supabase Auth error: ${e.message}');
      if (e.message.toLowerCase().contains('invalid login credentials') ||
          e.message.toLowerCase().contains('invalid grant')) {
        throw Exception('Invalid email or password.');
      }
      if (e.message.toLowerCase().contains('email not confirmed')) {
        throw Exception('Please confirm your email address or check your inbox.');
      }
      throw Exception(e.message);
    } catch (e) {
      debugPrint('AuthService.signInWithEmail Supabase notice: $e');
    }

    // 2. Also try Firebase Auth in background
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );
      final fbUser = userCredential.user;
      userId ??= fbUser?.uid != null ? toValidUuid(fbUser!.uid) : null;
      displayName ??= fbUser?.displayName;
      photoUrl ??= fbUser?.photoURL;
    } catch (e) {
      debugPrint('AuthService.signInWithEmail Firebase notice: $e');
    }

    if (userId == null) {
      // Check database directly by email as fallback
      final existingUser = await _dbService.getUserProfileByEmail(cleanEmail);
      if (existingUser != null) {
        userId = existingUser.id;
      } else {
        throw Exception('Invalid email or password.');
      }
    }

    // 3. Fetch user profile from PostgreSQL
    UserModel? userModel = await _dbService.getUserProfile(userId);
    if (userModel == null) {
      userModel = await _dbService.getUserProfileByEmail(cleanEmail);
    }

    final isExplicitCreator = requestedRole == 'photographer' || requestedRole == 'creator';

    if (userModel == null) {
      final initialRole = isExplicitCreator ? 'creator' : 'customer';
      userModel = UserModel(
        id: userId,
        name: displayName ?? cleanEmail.split('@').first,
        email: cleanEmail,
        phone: '+91 98200 12345',
        role: initialRole,
        avatarUrl: photoUrl ?? 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150&q=80',
        location: 'Bandra West, Mumbai',
        createdAt: DateTime.now(),
      );
      await _dbService.createUserProfile(userModel);
    }

    // If signing in via Photographer portal, upgrade/ensure creator role
    if (isExplicitCreator && !userModel.isPhotographer) {
      userModel = userModel.copyWith(role: 'creator');
      await _dbService.updateUserProfile(userModel);
    }

    if (userModel.isPhotographer) {
      await _ensurePhotographerProfile(userModel);
    }

    return userModel;
  }

  /// Sign In with Google via Supabase Auth (Native OAuth ID Token)
  Future<UserModel?> signInWithGoogle({String? requestedRole}) async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User cancelled

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      String? userId;
      String? userEmail = googleUser.email;
      String? userName = googleUser.displayName;
      String? userPhoto = googleUser.photoUrl;

      // 1. Authenticate with Supabase Auth using Google ID token
      if (idToken != null) {
        try {
          final res = await Supabase.instance.client.auth.signInWithIdToken(
            provider: OAuthProvider.google,
            idToken: idToken,
            accessToken: accessToken,
          );
          if (res.user != null) {
            userId = res.user!.id;
            userEmail = res.user!.email ?? userEmail;
            userName = res.user!.userMetadata?['full_name'] ?? userName;
            userPhoto = res.user!.userMetadata?['avatar_url'] ?? userPhoto;
          }
        } catch (supaErr) {
          debugPrint('Supabase signInWithIdToken notice: $supaErr');
        }
      }

      // 2. Also authenticate with Firebase Auth
      if (idToken != null || accessToken != null) {
        try {
          final credential = fb_auth.GoogleAuthProvider.credential(
            accessToken: accessToken,
            idToken: idToken,
          );
          final userCredential = await _firebaseAuth.signInWithCredential(credential);
          final firebaseUser = userCredential.user;
          userId ??= firebaseUser != null ? toValidUuid(firebaseUser.uid) : null;
        } catch (fbErr) {
          debugPrint('Firebase signInWithCredential notice: $fbErr');
        }
      }

      userId ??= toValidUuid(googleUser.id);
      final finalEmail = userEmail ?? googleUser.email;

      // 3. Fetch or Create Profile in Supabase PostgreSQL using valid UUID
      var userModel = await _dbService.getUserProfile(userId);
      if (userModel == null && finalEmail.isNotEmpty) {
        userModel = await _dbService.getUserProfileByEmail(finalEmail);
      }

      final isExplicitCreator = requestedRole == 'photographer' || requestedRole == 'creator';

      if (userModel == null) {
        // Dynamic role resolution for NEW Google users based on the entry portal
        final chosenRole = isExplicitCreator ? 'creator' : 'customer';
        userModel = UserModel(
          id: userId,
          name: userName ?? 'Google User',
          email: finalEmail,
          phone: '',
          avatarUrl: userPhoto,
          role: chosenRole,
          location: 'Bandra West, Mumbai',
          createdAt: DateTime.now(),
        );
        await _dbService.createUserProfile(userModel);
      } else {
        // Existing user: if user explicitly signed in through the Photographer portal, upgrade to creator
        if (isExplicitCreator && !userModel.isPhotographer) {
          userModel = userModel.copyWith(role: 'creator');
          await _dbService.updateUserProfile(userModel);
        }
      }

      if (userModel.isPhotographer) {
        await _ensurePhotographerProfile(userModel);
      }

      return userModel;
    } catch (e) {
      debugPrint('AuthService.signInWithGoogle error: $e');
      final errorStr = e.toString();
      if (errorStr.contains('ApiException: 10') || errorStr.contains('sign_in_failed') || errorStr.contains('10:')) {
        debugPrint(
          '════════════════════════════════════════════════════════════════════════════\n'
          '[GOOGLE SIGN-IN SETUP INSTRUCTION]\n'
          'ApiException 10 (Developer Error) detected.\n'
          '1. Go to Firebase Console > Project Settings > Android apps (com.pyp.lensmatch)\n'
          '2. Add SHA-1 Fingerprint: B3:A3:9F:6E:CD:06:9E:C4:C2:4B:BE:C5:5F:31:93:10:24:48:F3:EB\n'
          '3. Add SHA-256 Fingerprint: 47:65:8B:26:5A:26:5D:5A:DE:22:1B:D5:E8:05:A6:C3:5E:30:7C:2B:D2:A6:AD:E9:45:49:87:AC:D2:3C:B6:37\n'
          '4. Download the updated google-services.json to android/app/google-services.json\n'
          '════════════════════════════════════════════════════════════════════════════',
        );
        throw Exception(
          'Google Sign-In is temporarily unavailable. Please sign in with email/password or complete the SHA-1 setup in Firebase Console.',
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
      debugPrint('AuthService.verifyPhoneOtp error: $e');
      throw Exception('Invalid verification code. Please check the OTP and try again.');
    }
  }

  /// Sign Out of Firebase, Google & Supabase
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      await _googleSignIn.signOut();
      try {
        await Supabase.instance.client.auth.signOut();
      } catch (_) {}
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
