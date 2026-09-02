import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/booking_model.dart';
import '../../models/package_model.dart';
import '../../models/photographer_model.dart';
import '../../providers/auth_provider.dart';
import '../../screens/auth/forgot_password_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/otp_verification_screen.dart';
import '../../screens/auth/phone_auth_screen.dart';
import '../../screens/auth/signup_screen.dart';
import '../../screens/booking/book_session_screen.dart';
import '../../screens/booking/booking_confirmation_screen.dart';
import '../../screens/booking/booking_detail_screen.dart';
import '../../screens/booking/booking_summary_screen.dart';
import '../../screens/booking/my_bookings_screen.dart';
import '../../screens/booking/payment_checkout_screen.dart';
import '../../screens/chat/chat_inbox_screen.dart';
import '../../screens/chat/chat_room_screen.dart';
import '../../screens/deliverables/deliverables_gallery_screen.dart';
import '../../screens/home/category_photographers_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/home/location_picker_screen.dart';
import '../../screens/main_shell_screen.dart';
import '../../screens/photographer/photographer_detail_screen.dart';
import '../../screens/photographer/portfolio_viewer_screen.dart';
import '../../screens/photographer/reviews_list_screen.dart';
import '../../screens/profile/edit_profile_screen.dart';
import '../../screens/profile/help_support_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/profile/saved_photographers_screen.dart';
import '../../screens/review/write_review_screen.dart';
import 'app_routes.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorHome = GlobalKey<NavigatorState>(debugLabel: 'shellHome');
final _shellNavigatorBookings = GlobalKey<NavigatorState>(debugLabel: 'shellBookings');
final _shellNavigatorChats = GlobalKey<NavigatorState>(debugLabel: 'shellChats');
final _shellNavigatorProfile = GlobalKey<NavigatorState>(debugLabel: 'shellProfile');

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateStreamProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.home,
    redirect: (context, state) {
      final isLoading = authState.isLoading;
      final hasUser = authState.value != null;
      final isAuthRoute = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.signup ||
          state.matchedLocation == AppRoutes.phoneAuth ||
          state.matchedLocation == AppRoutes.otpVerify ||
          state.matchedLocation == AppRoutes.forgotPassword;

      if (isLoading) return null;

      // If user is not logged in and not on an auth route, let them explore or redirect when necessary
      if (!hasUser && !isAuthRoute) {
        // Allow home browsing, but guard bookings, chat, and profile
        if (state.matchedLocation.startsWith('/my-bookings') ||
            state.matchedLocation.startsWith('/chat') ||
            state.matchedLocation.startsWith('/book') ||
            state.matchedLocation.startsWith('/edit-profile')) {
          return AppRoutes.login;
        }
      }

      if (hasUser && isAuthRoute) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      // -------------------------------------------------------------
      // AUTH ROUTES
      // -------------------------------------------------------------
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: AppRoutes.phoneAuth,
        builder: (context, state) => const PhoneAuthScreen(),
      ),
      GoRoute(
        path: AppRoutes.otpVerify,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return OtpVerificationScreen(
            verificationId: extra['verificationId'] ?? '',
            phone: extra['phone'] ?? '',
            name: extra['name'],
          );
        },
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // -------------------------------------------------------------
      // BOTTOM NAVIGATION SHELL ROUTE
      // -------------------------------------------------------------
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShellScreen(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Explore / Home
          StatefulShellBranch(
            navigatorKey: _shellNavigatorHome,
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),

          // Branch 1: My Bookings
          StatefulShellBranch(
            navigatorKey: _shellNavigatorBookings,
            routes: [
              GoRoute(
                path: AppRoutes.bookings,
                builder: (context, state) => const MyBookingsScreen(),
              ),
            ],
          ),

          // Branch 2: Real-time Messages
          StatefulShellBranch(
            navigatorKey: _shellNavigatorChats,
            routes: [
              GoRoute(
                path: AppRoutes.chats,
                builder: (context, state) => const ChatInboxScreen(),
              ),
            ],
          ),

          // Branch 3: Profile
          StatefulShellBranch(
            navigatorKey: _shellNavigatorProfile,
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // -------------------------------------------------------------
      // SUBROUTES & DETAIL SCREENS
      // -------------------------------------------------------------
      GoRoute(
        path: AppRoutes.locationPicker,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const LocationPickerScreen(),
      ),
      GoRoute(
        path: AppRoutes.categoryPhotographers,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final category = state.pathParameters['category'] ?? 'Photography';
          return CategoryPhotographersScreen(category: category);
        },
      ),
      GoRoute(
        path: AppRoutes.photographerDetail,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return PhotographerDetailScreen(photographerId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.portfolioViewer,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final images = List<String>.from(extra['images'] ?? []);
          final initialIndex = extra['initialIndex'] as int? ?? 0;
          return PortfolioViewerScreen(images: images, initialIndex: initialIndex);
        },
      ),
      GoRoute(
        path: AppRoutes.reviewsList,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          final name = state.uri.queryParameters['name'] ?? 'Creator';
          return ReviewsListScreen(photographerId: id, photographerName: name);
        },
      ),
      GoRoute(
        path: AppRoutes.bookSession,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final photographer = extra['photographer'] as PhotographerModel;
          final package = extra['selectedPackage'] as PackageModel?;
          final date = extra['initialDate'] as DateTime?;
          return BookSessionScreen(
            photographer: photographer,
            initialPackage: package,
            initialDate: date,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.bookingSummary,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return BookingSummaryScreen(bookingData: extra);
        },
      ),
      GoRoute(
        path: AppRoutes.paymentCheckout,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return PaymentCheckoutScreen(bookingData: extra);
        },
      ),
      GoRoute(
        path: AppRoutes.bookingConfirmation,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['bookingId'] ?? '';
          return BookingConfirmationScreen(bookingId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.bookingDetail,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['bookingId'] ?? '';
          return BookingDetailScreen(bookingId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.chatRoom,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['bookingId'] ?? '';
          return ChatRoomScreen(bookingId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.deliverablesGallery,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['bookingId'] ?? '';
          return DeliverablesGalleryScreen(bookingId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.writeReview,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final booking = state.extra as BookingModel;
          return WriteReviewScreen(booking: booking);
        },
      ),
      GoRoute(
        path: AppRoutes.editProfile,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.savedPhotographers,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const SavedPhotographersScreen(),
      ),
      GoRoute(
        path: AppRoutes.helpSupport,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const HelpSupportScreen(),
      ),
    ],
  );
});
