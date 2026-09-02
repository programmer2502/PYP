import 'package:supabase_flutter/supabase_flutter.dart';

/// Centralized configuration for Supabase Backend Infrastructure
class SupabaseConfig {
  SupabaseConfig._();

  /// Project ID: ovtlrihpmetlxxkyxprx
  static const String projectId = 'ovtlrihpmetlxxkyxprx';

  /// Live Supabase Project URL
  static const String url = 'https://ovtlrihpmetlxxkyxprx.supabase.co';

  /// Publishable / Anon Public Key
  static const String anonKey = 'sb_publishable_aur4_0JDzHNFDhcDG9_Tvg_7xAIkVue';

  /// Supabase Client Instance Singleton Accessor
  static SupabaseClient get client => Supabase.instance.client;

  /// Supabase Auth Quick Accessor
  static GoTrueClient get auth => client.auth;

  /// Supabase Storage Quick Accessor
  static SupabaseStorageClient get storage => client.storage;
}
