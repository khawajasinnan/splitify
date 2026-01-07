import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/supabase_config.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/theme_provider.dart';
import 'presentation/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await SupabaseConfig.initialize();
  
  runApp(const ProviderScope(child: HisabApp()));
}

class HisabApp extends ConsumerWidget {
  const HisabApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    
    return MaterialApp(
      title: 'Splitlify - Your Digital Bill Splitter',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      darkTheme: AppTheme.darkTheme,
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
    );
  }
}
