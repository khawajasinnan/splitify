import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  SupabaseConfig._();

  static const String supabaseUrl = 'https://bthvpywddldkfbfhmnxn.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ0aHZweXdkZGxka2ZiZmhtbnhuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc3MTU0NTQsImV4cCI6MjA4MzI5MTQ1NH0.MvcQdf8bFaII4wv0C2eNVK_MBAANWSk-AXjx7dZ8gYY';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
  }

  /// Get Supabase client instance
  static SupabaseClient get client => Supabase.instance.client;

  /// Get auth instance
  static GoTrueClient get auth => client.auth;

  /// Get current user
  static User? get currentUser => auth.currentUser;

  /// Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;
}
