class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String phoneAuth = '/phone-auth';
  static const String otpVerify = '/otp-verify';
  static const String forgotPassword = '/forgot-password';

  // Shell Tabs
  static const String home = '/home';
  static const String bookings = '/my-bookings';
  static const String chats = '/chats';
  static const String profile = '/profile';

  // Subroutes
  static const String locationPicker = '/location-picker';
  static const String categoryPhotographers = '/category/:category';
  static const String photographerDetail = '/photographer/:id';
  static const String portfolioViewer = '/photographer/:id/portfolio';
  static const String reviewsList = '/photographer/:id/reviews';
  static const String bookSession = '/book/:photographerId';
  static const String bookingSummary = '/booking-summary';
  static const String paymentCheckout = '/payment-checkout';
  static const String bookingConfirmation = '/booking-confirmation/:bookingId';
  static const String bookingDetail = '/booking/:bookingId';
  static const String chatRoom = '/chat/:bookingId';
  static const String deliverablesGallery = '/deliverables/:bookingId';
  static const String writeReview = '/review/:bookingId';
  static const String editProfile = '/edit-profile';
  static const String savedPhotographers = '/saved-photographers';
  static const String helpSupport = '/help-support';
}
