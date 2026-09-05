import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/app_theme.dart';
import 'core/routing/app_router.dart';
import 'core/supabase/supabase_config.dart';
import 'services/notification_service.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Status bar styling - crisp transparent with dark icons for light theme
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize Firebase (Auth & Google/Email/OTP)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization notice: $e');
  }

  // Initialize Supabase Backend (PostgreSQL DB + Storage)
  try {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );

    // Initialize Local & Push Notifications
    final notificationService = NotificationService();
    await notificationService.initialize(
      onSelectNotification: (route, data) {
        if (route.isNotEmpty) {
          rootNavigatorKey.currentState?.pushNamed(route);
        }
      },
    );
  } catch (e) {
    debugPrint('Supabase initialization notice: $e');
  }

  runApp(
    const ProviderScope(
      child: PYPApp(),
    ),
  );
}

class PYPApp extends ConsumerWidget {
  const PYPApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'PYP - Pick Your Photographer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
