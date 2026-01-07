import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/constants/app_constants.dart';

/// Theme Toggle Switch Widget
class ThemeToggle extends ConsumerWidget {
  const ThemeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isDark ? AppColors.border : const Color(0xFFE2E8F0),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => ref.read(themeProvider.notifier).toggleTheme(),
          borderRadius: BorderRadius.circular(30),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  color: AppColors.magmaOrange,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Text(
                  isDark ? 'Dark Mode' : 'Light Mode',
                  style: TextStyle(
                    color: isDark ? AppColors.textPrimary : const Color(0xFF2D3748),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Switch(
                  value: isDark,
                  onChanged: (_) => ref.read(themeProvider.notifier).toggleTheme(),
                  activeTrackColor: AppColors.magmaOrange.withOpacity(0.5),
                  activeColor: AppColors.magmaOrange,
                  inactiveThumbColor: const Color(0xFF718096),
                  inactiveTrackColor: const Color(0xFFE2E8F0),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
